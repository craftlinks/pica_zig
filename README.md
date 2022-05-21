# zPiCa - Zig Helper Libary for Win32 Window Management (!!WIP!!)
## Getting started

Copy `pica` folder to a `libs` subdirectory of the root of your project.

Then in your `build.zig` add:

```zig
const std = @import("std");
const zpica = @import("libs/pica/build.zig");

pub fn build(b: *std.build.Builder) void {
    ...
    exe.addPackage(pica.pkg);
}
```

Now in your code you may import and use zwin32:

```zig
const pica = @import("pica");

pub fn main() !void {
    ...
}
```
An example window application using `pica` can be found in `pica/src/example`  

To run the example use:
```
zig build run
```



`pica` uses `zwin32` standalone Zig bindings for Win32 API by [Michal Ziulek](https://github.com/michal-z) 
