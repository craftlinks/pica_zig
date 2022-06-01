const std = @import("std");
const pica = @import("pica");


// A global variable to hold our pica window (required)
var window: pica.Window = .{};

pub fn main() !void {

    // Define the attributes of our window (optional)
    var window_attributes = pica.WindowAttributes {
        .title = "PiCA Window Example",
        .position = .{10, 10},
        .size = .{800, 600},
    };

    // Set the window attributes (optional)
    // TODO Geert: Can attributes be set after the window is created?
    window.attributes = window_attributes;
    
    // Initialize and show the window (required)
    try pica.initialize(&window);
    std.debug.print("{any}\n", .{window});

    var last_print_time: f32 = 0.0;
    while(pica.pull(&window)) |quit| {
        if (quit) break;
        if ( window.time.seconds - last_print_time >  1.0) {
            std.debug.print("pos: {any}, mouse: {any}, ms: {any}, delta_us: {any}\n", 
            .{
                window.attributes.position,
                window.mouse.position,
                window.time.milliseconds,
                window.time.delta_microseconds
            });
            last_print_time = window.time.seconds;
        }

    } else |err| switch (err) {
        error.WindowNotInitialized => {
          std.debug.print("Initialize Window before calling pica.pull", .{});
        },
        else => {
            std.debug.print("Unknown error", .{});
        }
    }
}
