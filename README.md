# PiCa -- Zig Helper Libary for Win32 Window Management
## Getting started

Copy `zpica` folder to a `libs` subdirectory of the root of your project.

Then in your `build.zig` add:

```zig
const std = @import("std");
const zpica = @import("libs/zpica/build.zig");

pub fn build(b: *std.build.Builder) void {
    ...
    exe.addPackage(zpica.pkg);
}
```

Now in your code you may import and use zwin32:

```zig
const zpica = @import("zpica");

pub fn main() !void {
    ...
}
```

zpica uses zwin32 standalone Zig bindings for Win32 API by [Michal Ziulek](https://github.com/michal-z) 