const std = @import("std");

const gir = @import("gir");

const c = gir.c;

const misc = @import("misc.zig");

/// Process-global default GIRepository
var repository: *c.GIRepository = undefined;

/// A shared error handle
var err: ?*c.GError = null;

/// Prepare output writers
const stderr = std.io.getStdErr().writer();
const stdout = std.io.getStdOut().writer();

/// Run the program
pub fn main() !void {
    // Get the singleton process-global default GIRepository
    repository = c.g_irepository_get_default();
    // Load the namespace
    _ = c.g_irepository_require(repository, "GIRepository", null, 0, &err);
    if (err) |_| {
        misc.errorWith("Couldn't load the namespace.", .{}) catch {};
        std.os.exit(1);
    }
    // Print the loaded namespaces
    const namespaces = c.g_irepository_get_loaded_namespaces(repository);
    const n_namespaces = std.mem.span(@ptrCast([*:null]?[*:0]u8, namespaces)).len;
    for (namespaces[0..n_namespaces]) |namespace| {
        std.debug.print("{s}\n", .{namespace});
    }
}
