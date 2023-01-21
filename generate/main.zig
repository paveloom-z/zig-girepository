const std = @import("std");

const gir = @import("gir");

const c = gir.c;

const input = @import("input.zig");

/// Namespace in question
const target_namespace_name = "GIRepository";

/// Process-global default GIRepository
var repository: *c.GIRepository = undefined;

/// A shared error handle
var g_err: ?*c.GError = null;

/// Prepare output writers
const stderr = std.io.getStdErr().writer();
const stdout = std.io.getStdOut().writer();

/// Override the default logger
pub fn log(
    comptime message_level: std.log.Level,
    comptime scope: @Type(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    const level_txt = comptime switch (message_level) {
        .err => "ERROR",
        .warn => "WARNING",
        .info => "INFO",
        .debug => "DEBUG",
    };
    const prefix = if (scope == .default) ": " else "(" ++ @tagName(scope) ++ "): ";
    std.debug.getStderrMutex().lock();
    defer std.debug.getStderrMutex().unlock();
    nosuspend stderr.print(level_txt ++ prefix ++ format ++ "\n", args) catch return;
}

/// A callback in case of an interrupt
fn onInterrupt(signal: c_int) align(1) callconv(.C) void {
    _ = signal;
    std.os.exit(1);
}

/// Run the program
pub fn main() !void {
    // Setup an interrupt signal handler
    const sigaction = std.os.Sigaction{
        .handler = .{ .handler = onInterrupt },
        .mask = std.os.empty_sigset,
        .flags = 0,
    };
    try std.os.sigaction(std.os.SIG.INT, &sigaction, null);
    // Prepare an arena-wrapped allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();
    // Prepare an arguments iterator
    var args = try std.process.argsWithAllocator(allocator);
    // Try to create the directory
    var output_dir = input.getOutputDir(&args) catch {
        std.log.err("Couldn't get the output directory.", .{});
        std.os.exit(1);
    };
    defer output_dir.close();
    // Get the singleton process-global default GIRepository
    repository = c.g_irepository_get_default();
    // Load the namespace
    _ = c.g_irepository_require(
        repository,
        target_namespace_name,
        null,
        0,
        &g_err,
    );
    if (g_err) |_| {
        std.log.err("Couldn't load the namespace.", .{});
        std.os.exit(1);
    }
    // Get the number of metadata entries in the target namespace
    const infos_n = c.g_irepository_get_n_infos(repository, target_namespace_name);
    // For each index of the metadata entries
    var i: c.gint = 0;
    while (i < infos_n) : (i += 1) {
        // Get the metadata entry
        const info = c.g_irepository_get_info(repository, target_namespace_name, i);
        defer c.g_base_info_unref(info);
        // Depending on the type of the entry
        const info_name = c.g_base_info_get_name(info);
        const info_type = c.g_base_info_get_type(info);
        switch (info_type) {
            c.GI_INFO_TYPE_INVALID => {
                std.log.warn(
                    "Invalid type `{s}`.",
                    .{info_name},
                );
            },
            c.GI_INFO_TYPE_FUNCTION => {
                std.log.info(
                    "Function `{s}`",
                    .{info_name},
                );
            },
            c.GI_INFO_TYPE_CALLBACK => {
                std.log.info(
                    "Callback `{s}`",
                    .{info_name},
                );
            },
            c.GI_INFO_TYPE_STRUCT => {
                std.log.info(
                    "Struct `{s}`",
                    .{info_name},
                );
            },
            c.GI_INFO_TYPE_BOXED => {
                std.log.info(
                    "Boxed `{s}`",
                    .{info_name},
                );
            },
            c.GI_INFO_TYPE_ENUM => {
                std.log.info(
                    "Enum `{s}`",
                    .{info_name},
                );
            },
            c.GI_INFO_TYPE_FLAGS => {
                std.log.info(
                    "Flags `{s}`",
                    .{info_name},
                );
            },
            c.GI_INFO_TYPE_OBJECT => {
                std.log.info(
                    "Object `{s}`",
                    .{info_name},
                );
            },
            c.GI_INFO_TYPE_INTERFACE => {
                std.log.info(
                    "Interface `{s}`",
                    .{info_name},
                );
            },
            c.GI_INFO_TYPE_CONSTANT => {
                std.log.info(
                    "Constant `{s}`",
                    .{info_name},
                );
            },
            c.GI_INFO_TYPE_UNION => {
                std.log.info(
                    "Union `{s}`",
                    .{info_name},
                );
            },
            c.GI_INFO_TYPE_VALUE => {
                std.log.info(
                    "Value `{s}`",
                    .{info_name},
                );
            },
            c.GI_INFO_TYPE_SIGNAL => {
                std.log.info(
                    "Signal `{s}`",
                    .{info_name},
                );
            },
            c.GI_INFO_TYPE_VFUNC => {
                std.log.info(
                    "VFunc `{s}`",
                    .{info_name},
                );
            },
            c.GI_INFO_TYPE_PROPERTY => {
                std.log.info(
                    "Property `{s}`",
                    .{info_name},
                );
            },
            c.GI_INFO_TYPE_FIELD => {
                std.log.info(
                    "Field `{s}`",
                    .{info_name},
                );
            },
            c.GI_INFO_TYPE_ARG => {
                std.log.info(
                    "Argument `{s}`",
                    .{info_name},
                );
            },
            c.GI_INFO_TYPE_TYPE => {
                std.log.info(
                    "Type `{s}`",
                    .{info_name},
                );
            },
            c.GI_INFO_TYPE_UNRESOLVED => {
                std.log.warn(
                    "Unresolved type `{s}`.",
                    .{info_name},
                );
            },
            else => {
                std.log.warn(
                    "No handler for type `{s}`.",
                    .{info_name},
                );
            },
        }
    }
}
