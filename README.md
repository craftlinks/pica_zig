# ZiCa - Zig Helper Libary for Win32 Window Management (!!WIP!!)
## Getting started

Copy `zica` folder to a `libs` subdirectory of the root of your project.

Then in your `build.zig` add:

```zig
const std = @import("std");
const zica = @import("libs/zica/build.zig");

pub fn build(b: *std.build.Builder) void {
    ...
    exe.addPackage(zica.pkg);
}
```

Now in your code you may import and use `zica`:

```zig
const zica = @import("pica");

pub fn main() !void {
    ...
}
```
An example window application using `zica` can be found in `zica/src/example`  

To run the example use:
```
zig build run
```



`zica` uses `zwin32` standalone Zig bindings for Win32 API by [Michal Ziulek](https://github.com/michal-z) 
