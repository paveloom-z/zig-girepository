const std = @import("std");

/// Create a namespace for the casting functions
pub fn Cast(comptime T: type) type {
    return struct {
        /// Cast the pointer to a Zig struct to a pointer to a C struct
        pub inline fn toC(ptr: anytype) ?*T.C {
            return @ptrCast(?*T.C, ptr);
        }
        /// Cast the `const` pointer to a Zig struct to a `const` pointer to a C struct
        pub inline fn toConstC(ptr: anytype) ?*const T.C {
            return @ptrCast(?*const T.C, ptr);
        }
        /// Cast the pointer to a C struct to a pointer to a Zig struct
        pub inline fn fromC(ptr: anytype) ?*T {
            return @ptrCast(?*T, ptr);
        }
        /// Cast the `const` pointer to a C struct to a `const` pointer to a Zig struct
        pub inline fn fromConstC(ptr: anytype) ?*const T {
            return @ptrCast(?*const T, ptr);
        }
    };
}
