const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    // Add standard target options
    const target = b.standardTargetOptions(.{});
    // Add standard release options
    const mode = b.standardReleaseOptions();
    // Add the library
    const girepository = b.addStaticLibrary("girepository", "src/lib.zig");
    girepository.setBuildMode(mode);
    girepository.install();
    // Add the unit tests
    const unit_tests_step = b.step("test", "Run the unit tests");
    const unit_tests = b.addTest("src/lib.zig");
    unit_tests.setBuildMode(mode);
    unit_tests_step.dependOn(&unit_tests.step);
    unit_tests.test_evented_io = true;
    // Define the library package
    const lib_pkg = std.build.Pkg{
        .name = "gir",
        .source = .{ .path = "src/lib.zig" },
        .dependencies = &.{},
    };
    // Add the generate executable
    const generate = b.addExecutable("generate", "gir/generate.zig");
    // For each executable
    inline for (.{
        .{ generate, "Generate the bindings" },
    }) |tuple| {
        // Unpack the tuple
        const step = tuple[0];
        const run_step_name = tuple[1];
        // Make sure they can be built and installed
        step.setTarget(target);
        step.setBuildMode(mode);
        step.install();
        // Add the library package
        step.addPackage(lib_pkg);
        // Add a run step
        if (step.install_step) |install_step| {
            const run_step = b.step(step.name, run_step_name);
            const run_cmd = step.run();
            run_cmd.step.dependOn(&install_step.step);
            if (b.args) |args| {
                run_cmd.addArgs(args);
            }
            run_step.dependOn(&run_cmd.step);
        }
    }
    // Add the dependencies
    inline for (.{
        generate,
        girepository,
        unit_tests,
    }) |step| {
        // Link the libraries
        step.linkLibC();
        step.linkSystemLibrary("gobject-introspection-1.0");
        // Use the `stage1` compiler
        step.use_stage1 = true;
    }
}
