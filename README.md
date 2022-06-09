# Zica - Zig Helper Libary for Win32 Window Management

## What is Zica?

`Zica` is a windows only library for creating and managing native windows 
optimized for game or simulation loops.   
Design is from [Per Vognsen's Mu API](https://gist.github.com/pervognsen/6a67966c5dc4247a0021b95c8d0a7b72). 
More information about this design can be found [here](https://www.youtube.com/watch?v=NG_mUhc8LRw),
and [here](https://www.youtube.com/watch?v=pAIdfsT7-EU). 

`Zica` also uses `zwin32` standalone Zig bindings for Win32 API by [Michal Ziulek](https://github.com/michal-z) 

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

To run the example application, run the following snippet from the root folder:
```
zig build run
```


