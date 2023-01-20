const std = @import("std");

const lib = @import("lib.zig");

const Cast = lib.Cast;
const c = lib.c;

pub const RepositoryLoadFlags = enum(c_int) {
    LAZY = c.G_IREPOSITORY_LOAD_FLAG_LAZY,
};

const RepositoryError = enum(c_int) {
    TYPELIB_NOT_FOUND = c.G_IREPOSITORY_ERROR_TYPELIB_NOT_FOUND,
    NAMESPACE_MISMATCH = c.G_IREPOSITORY_ERROR_NAMESPACE_MISMATCH,
    NAMESPACE_VERSION_CONFLICT = c.G_IREPOSITORY_ERROR_NAMESPACE_VERSION_CONFLICT,
    LIBRARY_NOT_FOUND = c.G_IREPOSITORY_ERROR_LIBRARY_NOT_FOUND,
};

pub const Repository = extern struct {
    const Self = @This();
    const C = c.GIRepository;
    parent: c.GObject,
    priv: ?*c.GIRepositoryPrivate,
    usingnamespace Cast(Self);
    pub fn getType() c.GType {
        return c.g_irepository_get_type();
    }
    pub fn getDefault() *Self {
        return c.g_irepository_get_default();
    }
    pub fn prependSearchPath(directory: [*c]const u8) void {
        c.g_irepository_prepend_search_path(directory);
    }
    pub fn prependLibraryPath(directory: [*c]const u8) void {
        c.g_irepository_prepend_library_path(directory);
    }
    pub fn getSearchPath() [*c].GSList {
        return c.g_irepository_get_search_path();
    }
    pub fn loadTypelib(
        self: *Self,
        typelib: [*c]c.GITypelib,
        flags: RepositoryLoadFlags,
        @"error": [*c][*c]c.GError,
    ) [*c]const u8 {
        return c.g_irepository_load_typelib(self, typelib, flags, @"error");
    }
    pub fn isRegistered(
        self: *Self,
        namespace_: [*c]const c.gchar,
        version: [*c]const c.gchar,
    ) c.gboolean {
        return c.g_irepository_is_registered(self, namespace_, version);
    }
    pub fn findByName(
        self: *Self,
        namespace_: [*c]const c.gchar,
        name: [*c]const c.gchar,
    ) [*c]c.GIBaseInfo {
        return c.g_irepository_find_by_name(self, namespace_, name);
    }
    pub fn enumerateVersions(
        self: *Self,
        namespace_: [*c]const c.gchar,
    ) [*c]c.GList {
        return c.g_irepository_enumerate_versions(self, namespace_);
    }
    pub fn require(
        self: *Self,
        namespace_: [*c]const c.gchar,
        version: [*c]const c.gchar,
        flags: RepositoryLoadFlags,
        @"error": [*c][*c]c.GError,
    ) ?*c.GITypelib {
        return c.g_irepository_require(
            self,
            namespace_,
            version,
            flags,
            @"error",
        );
    }
    pub fn requirePrivate(
        self: *Self,
        typelib_dir: [*c]const c.gchar,
        namespace_: [*c]const c.gchar,
        version: [*c]const c.gchar,
        flags: RepositoryLoadFlags,
        @"error": [*c][*c]c.GError,
    ) ?*c.GITypelib {
        return c.g_irepository_require_private(
            self,
            typelib_dir,
            namespace_,
            version,
            flags,
            @"error",
        );
    }
    pub fn getImmediateDependencies(
        self: *Self,
        namespace_: [*c]const c.gchar,
    ) [*c][*c]c.gchar {
        return c.g_irepository_get_immediate_dependencies(self, namespace_);
    }
    pub fn getDependencies(
        self: *Self,
        namespace_: [*c]const c.gchar,
    ) [*c][*c]c.gchar {
        return c.g_irepository_get_dependencies(self, namespace_);
    }
    pub fn getLoadedNamespaces(self: *Self) [*c][*c]c.gchar {
        return c.g_irepository_get_loaded_namespaces(self);
    }
    pub fn findByGtype(self: *Self, gtype: c.GType) [*c]c.GIBaseInfo {
        return c.g_irepository_find_by_gtype(self, gtype);
    }
    pub fn getObjectGtypeInterfaces(
        self: *Self,
        gtype: c.GType,
        n_interfaces_out: [*c]c.guint,
        interfaces_out: [*c][*c][*c]c.GIInterfaceInfo,
    ) void {
        c.g_irepository_get_object_gtype_interfaces(
            self,
            gtype,
            n_interfaces_out,
            interfaces_out,
        );
    }
    pub fn getNInfos(self: *Self, namespace_: [*c]const c.gchar) c.gint {
        return c.g_irepository_get_n_infos(self, namespace_);
    }
    pub fn getInfo(
        self: *Self,
        namespace_: [*c]const c.gchar,
        index: c.gint,
    ) [*c]c.GIBaseInfo {
        return c.g_irepository_get_info(self, namespace_, index);
    }
    pub fn findByErrorDomain(self: *Self, domain: c.GQuark) [*c]c.GIEnumInfo {
        return c.g_irepository_find_by_error_domain(self, domain);
    }
    pub fn getTypelibPath(
        self: *Self,
        namespace_: [*c]const c.gchar,
    ) [*c]const c.gchar {
        return c.g_irepository_get_typelib_path(self, namespace_);
    }
    pub fn getSharedLibrary(
        self: *Self,
        namespace_: [*c]const c.gchar,
    ) [*c]const c.gchar {
        return c.g_irepository_get_shared_library(self, namespace_);
    }
    pub fn getCPrefix(
        self: *Self,
        namespace_: [*c]const c.gchar,
    ) [*c]const c.gchar {
        return c.g_irepository_get_c_prefix(self, namespace_);
    }
    pub fn getVersion(
        self: *Self,
        namespace_: [*c]const c.gchar,
    ) [*c]const c.gchar {
        return c.g_irepository_get_version(self, namespace_);
    }
    pub fn getOptionGroup() ?*c.GOptionGroup {
        return c.g_irepository_get_option_group();
    }
    pub fn dump(arg: [*c]const u8, @"error": [*c][*c]c.GError) c.gboolean {
        return c.g_irepository_dump(arg, @"error");
    }
};
