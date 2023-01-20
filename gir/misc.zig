const std = @import("std");

const stderr = std.io.getStdErr().writer();

/// Print an error to the `stderr` and gracefully
/// propagate a dummy error to the rest of the program
pub inline fn errorWith(comptime fmt: []const u8, args: anytype) anyerror {
    stderr.print(
        "ERROR: " ++ fmt ++ "\n",
        args,
    ) catch {};
    return error.Error;
}
