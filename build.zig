const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
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
    // Add the dependencies
    inline for (.{
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
