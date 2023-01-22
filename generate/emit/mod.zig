const std = @import("std");

const gir = @import("gir");

const c = gir.c;

const object = @import("object.zig");

/// A buffer for paths
var buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;

/// Concatenate `.zig` to the end of the path
pub fn concatZig(info_name: [:0]const u8) [:0]const u8 {
    const ext = ".zig";
    const file_name = buffer[0..(info_name.len + ext.len) :0];
    std.mem.copy(u8, file_name, info_name);
    std.mem.copy(u8, file_name[info_name.len..], ext);
    return file_name;
}

/// Emit code from a target namespace
pub fn from(
    repository: *c.GIRepository,
    target_namespace_name: [:0]const u8,
    output_dir: *std.fs.Dir,
) !void {
    // Prepare a shared error handle
    var g_err: ?*c.GError = null;
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
    // Prepare output directories
    var object_subdir = try object.getSubdir(output_dir);
    defer object_subdir.close();
    // Get the number of metadata entries in the target namespace
    const infos_n = c.g_irepository_get_n_infos(repository, target_namespace_name);
    // For each index of the metadata entries
    var i: c.gint = 0;
    while (i < infos_n) : (i += 1) {
        // Get the metadata entry
        const info = c.g_irepository_get_info(repository, target_namespace_name, i);
        defer c.g_base_info_unref(info);
        // Depending on the type of the entry, emit the code
        const info_name = std.mem.span(@ptrCast(
            [*:0]const u8,
            c.g_base_info_get_name(info),
        ));
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
            c.GI_INFO_TYPE_OBJECT => object.from(
                info,
                info_name,
                &object_subdir,
            ) catch {
                std.log.warn(
                    "Couldn't emit object `{s}`",
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