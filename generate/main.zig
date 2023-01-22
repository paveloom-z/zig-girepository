const std = @import("std");

const gir = @import("gir");

const c = gir.c;

const emit = @import("emit/mod.zig");
const input = @import("input.zig");

/// Namespace in question
const target_namespace_name = "GIRepository";

/// Process-global default GIRepository
var repository: *c.GIRepository = undefined;

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
    // Prepare an output directory
    var output_dir = input.getOutputDir(allocator) catch {
        std.log.err("Couldn't get the output directory.", .{});
        std.os.exit(1);
    };
    defer output_dir.close();
    // Get the singleton process-global default GIRepository
    repository = c.g_irepository_get_default();
    // Emit code from the target namespace
    emit.from(
        repository,
        target_namespace_name,
        &output_dir,
    ) catch {
        std.log.err("Couldn't emit code from the target namespace.", .{});
        std.os.exit(1);
    };
}
