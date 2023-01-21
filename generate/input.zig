const std = @import("std");

const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();

/// Handle the failed to open case
fn failedOpen(output_dir_path: []const u8) anyerror {
    std.log.err(
        "Couldn't open the output directory `{s}`",
        .{output_dir_path},
    );
    return error.Error;
}

// Ask the user whether we should proceed
// with overwriting the directory
fn askOverwriteDir() !void {
    while (true) {
        stdout.print(
            "\rOverwrite the output directory? (y/n) > ",
            .{},
        ) catch {};
        const answer = try stdin.readByte();
        switch (answer) {
            'y' => break,
            'n' => {
                return error.Error;
            },
            else => continue,
        }
    }
}

/// Handle the creation errors
fn handleFsError(
    fs_err: std.os.MakeDirError,
    output_dir_path: []const u8,
) !void {
    switch (fs_err) {
        std.os.MakeDirError.PathAlreadyExists => {
            try askOverwriteDir();
        },
        else => {
            std.log.err(
                "Couldn't create the directory `{s}`",
                .{output_dir_path},
            );
            return error.Error;
        },
    }
}

/// Get the output directory from the arguments
pub fn getOutputDir(args: *std.process.ArgIterator) !std.fs.Dir {
    // Skip the first argument (which is a path to the binary)
    _ = args.skip();
    // Try to get the second argument
    const output_dir_path = args.next() orelse {
        std.log.err("Please provide a path to the output directory.", .{});
        return error.Error;
    };
    // Prepare the output directory
    if (std.fs.path.isAbsolute(output_dir_path)) {
        std.fs.makeDirAbsolute(output_dir_path) catch |fs_err| {
            try handleFsError(fs_err, output_dir_path);
        };
        return std.fs.openDirAbsolute(output_dir_path, .{}) catch {
            return failedOpen(output_dir_path);
        };
    } else {
        const cwd = std.fs.cwd();
        cwd.makeDir(output_dir_path) catch |fs_err| {
            try handleFsError(fs_err, output_dir_path);
        };
        return cwd.openDir(output_dir_path, .{}) catch {
            return failedOpen(output_dir_path);
        };
    }
}
