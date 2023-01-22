const std = @import("std");

const gir = @import("gir");

const c = gir.c;

const emit = @import("mod.zig");

/// Subdirectory for this type
pub const subdir_path = "objects";

/// Create if not exists and open the subdirectory
pub fn getSubdir(output_dir: *std.fs.Dir) !std.fs.Dir {
    return output_dir.makeOpenPath(subdir_path, .{}) catch {
        std.log.err(
            "Couldn't create the `{s}` subdirectory.",
            .{subdir_path},
        );
        return error.Error;
    };
}

/// Emit an object
pub fn from(
    info: *c.GIBaseInfo,
    info_name: [:0]const u8,
    subdir: *std.fs.Dir,
) !void {
    const object = @ptrCast(*c.GIObjectInfo, info);
    _ = object;
    std.log.info("Emitting object `{s}`...", .{info_name});
    // Create a file
    const file_path = emit.concatZig(info_name);
    const file = subdir.createFile(file_path, .{}) catch {
        std.log.warn("Couldn't create the `{s}` file.", .{file_path});
        return error.Error;
    };
    defer file.close();
}
