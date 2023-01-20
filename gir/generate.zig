const std = @import("std");

const gir = @import("gir");

const c = gir.c;

/// An arena-wrapped allocator
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

/// Process-global default GIRepository
var repository: *c.GIRepository = undefined;

/// A shared error handle
// var error: *c.GError = undefined;

/// Path to the GIR file
const gir_file_path = "/usr/share/gir-1.0/GIRepository-2.0.gir";

/// Name of the `typelib` file
const typelib_file_name = "grepository.typelib";

/// Path of the `typelib` file
var typelib_file_path: [:0]const u8 = undefined;

/// Prepare standard writers
const stderr = std.io.getStdErr().writer();
const stdout = std.io.getStdOut().writer();

/// Print an error to the `stderr` and gracefully
/// propagate a dummy error to the rest of the program
inline fn errorWith(comptime fmt: []const u8, args: anytype) anyerror {
    stderr.print(
        "ERROR: " ++ fmt ++ "\n",
        args,
    ) catch {};
    return error.Error;
}

/// Get the path to the `typelib` file
fn typelibFilePath(buffer: []u8) ![:0]const u8 {
    // Get this source file path
    const source_file_path = @src().file;
    // Output to a file in the same place
    // where this source file is
    const n_replacements = std.mem.replace(
        u8,
        source_file_path,
        std.fs.path.basename(source_file_path),
        typelib_file_name,
        buffer,
    );
    if (n_replacements != 1) {
        return errorWith("Couldn't define the output file path.", .{});
    }
    // Return the path
    return std.mem.span(@ptrCast([*:0]const u8, buffer));
}

/// Generate the `typelib` file
fn generateTypelib() !void {
    stdout.print(
        "Generating the `typelib` file...\n",
        .{},
    ) catch {};
    // Test whether the GIR file exists
    std.fs.accessAbsolute(gir_file_path, .{}) catch {
        return errorWith("No such file: `{s}`.", .{gir_file_path});
    };
    // Define the path to the `typelib` file
    var buffer = [_]u8{0} ** 100;
    typelib_file_path = try typelibFilePath(&buffer);
    // Call the `typelib` compiler
    var child_process = std.ChildProcess.init(
        &.{
            "g-ir-compiler",
            gir_file_path,
            "-o",
            typelib_file_path,
        },
        arena.allocator(),
    );
    child_process.spawn() catch {
        return errorWith(
            "Couldn't spawn a child process. Does `g-ir-compiler` exist?",
            .{},
        );
    };
    const term = child_process.wait() catch {
        return errorWith(
            "Call to `g-ir-compiler` failed.",
            .{},
        );
    };
    switch (term) {
        .Exited => |code| {
            if (code != 0) {
                return errorWith(
                    "The child process exited with code {}.",
                    .{code},
                );
            }
        },
        else => {},
    }
}

/// Run the program
pub fn main() !void {
    // Generate the `typelib` file
    generateTypelib() catch {
        errorWith(
            "Couldn't generate the `typelib` file.",
            .{},
        ) catch {};
        return;
    };
    // Get the singleton process-global default GIRepository
    // repository = c.g_irepository_get_default();
    // Free the memory
    arena.deinit();
}
