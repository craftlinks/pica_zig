const std = @import("std");
const zica = @import("zica");
const SHIFT = zica.SHIFT;
const CTR = zica.CTR;

// A global variable to hold our zica window (required)
var window: zica.Window = .{};

pub fn main() !void {

    // Define the attributes of our window (optional)
    var window_attributes = zica.WindowAttributes {
        .title = "zica Window Example",
        .position = .{10, 10},
        .size = .{800, 600},
    };

    // Set the window attributes (optional)
    // TODO Geert: Can attributes be set after the window is created?
    window.attributes = window_attributes;
    
    // Initialize and show the window (required)
    try zica.initialize(&window);

    var last_print_time: f32 = 0.0;
    while(zica.pull(&window)) |quit| {
        if (quit) break;
        if ( window.time.seconds - last_print_time >  1.0) {
            std.debug.print("pos: {any}, mouse: {any}, wheel: {any}, ms: {any}, delta_us: {any}\n", 
            .{
                window.attributes.position,
                window.mouse.position,
                window.mouse.wheel,
                window.time.milliseconds,
                window.time.delta_microseconds
            });
            last_print_time = window.time.seconds;
        }
        if (window.mouse.left_button.pressed) {
            std.debug.print("LEFT_MOUSE_BUTTON_PRESSED\n", .{});
        }
        if (window.mouse.left_button.released) {
            std.debug.print("LEFT_MOUSE_BUTTON_RELEASED\n", .{});
        }
        if (window.mouse.right_button.pressed) {
            std.debug.print("RIGHT_MOUSE_BUTTON_PRESSED\n", .{});
        }
        if (window.mouse.right_button.released) {
            std.debug.print("RIGHT_MOUSE_BUTTON_RELEASED\n", .{});
        }
        if (window.mouse.middle_button.pressed) {
            std.debug.print("MIDDLE_MOUSE_BUTTON_PRESSED\n", .{});
        }
        if (window.mouse.middle_button.released) {
            std.debug.print("MIDDLE_MOUSE_BUTTON_RELEASED\n", .{});
        }
        if (window.text_length > 0) {
            const text = window.text[0..window.text_length+1];
            std.debug.print("{s}\n", .{text});
        }
        if (window.keys[SHIFT].pressed) {
            std.debug.print("SHIFT is pressed!\n", .{});
        }
        if (window.keys[CTR].pressed) {
            std.debug.print("CTR is pressed!\n", .{});
        }
    } else |err| switch (err) {
        error.WindowNotInitialized => {
          std.debug.print("Initialize Window before calling zica.pull", .{});
        },
        else => {
            std.debug.print("Unknown error", .{});
        }
    }
}
