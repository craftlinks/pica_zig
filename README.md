**Project requires [0.10.0-dev.2562 (master)](https://ziglang.org/download/) or newer to compile.**

# Zica - Zig Helper Libary for minimal overhead Win32 Window Management

## What is Zica?

`Zica` is a Microsoft Windows only library for creating and managing `Win32` windows 
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
const zica = @import("zica");

// A global variable to hold our zica window (required)
var window: zica.Window = .{};

pub fn main() !void {
    
    // Initialize and show the window (required)
    try zica.initialize(&window);
    
    while(zica.pull(&window)) |quit| {
        if (quit) break;
        ...
    }
}
```
An example window application using `zica` can be found in `zica/src/example`  

To run the example application, run the following snippet from the root folder:
```
zig build run
```


