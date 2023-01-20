### Notices

#### Mirrors

Repository:
- [Codeberg](https://codeberg.org/paveloom-z/zig-girepository)
- [GitHub](https://github.com/paveloom-z/zig-girepository)
- [GitLab](https://gitlab.com/paveloom-g/zig/zig-girepository)

#### Prerequisites

Make sure you have installed:

- A development library for `gobject-introspection`
- [Zig](https://ziglang.org) (`v0.10.1`)

#### Build

To build and install the library, run `zig build install`.

To run unit tests, run `zig build test`.

See `zig build --help` for more build options.

#### Integrate

To integrate the bindings into your project:

1) Add this repository as a dependency in `zigmod.yml`:

    ```yml
    # <...>
    root_dependencies:
      - src: git https://github.com/paveloom-z/zig-girepository
    ```

2) Make sure you have added the dependencies in your build script:

    ```zig
    // <...>
    const deps = @import("deps.zig");
    const girepository_pkg = deps.pkgs.girepository.pkg.?;
    // <...>
    pub fn build(b: *std.build.Builder) !void {
      // <...>
      // For each step
      inline for (steps) |step| {
          // Add the library package
          step.addPackage(girepository_pkg);
          // Link the libraries
          step.linkLibC();
          step.linkSystemLibrary("gobject-introspection-1.0");
          // Use the `stage1` compiler
          step.use_stage1 = true;
      }
      // <...>
    }
    ```
