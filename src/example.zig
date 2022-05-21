const std = @import("std");
const pica = @import("pica");


// A global variable to hold our pica window (required)
var window: pica.Window = .{};

pub fn main() !void {

    // Create main memory allocator for our application.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    
    const allocator = gpa.allocator();
    _ =allocator;
    
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

    while(pica.pull(&window)) |quit| {
        if (quit) break;
        // Do stuff



    } else |err| switch (err) {
        error.WindowNotInitialized => {
          std.debug.print("Initialize Window before calling pica.pull", .{});
        },
        else => {
            std.debug.print("Unknown error", .{});
        }
    }
    
    
}