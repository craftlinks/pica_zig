const std = @import("std");
const pica = @import("pica");


// A global variable to hold our pica window (required)
var window: pica.Window = .{};

pub fn main() !void {

    // Create main memory allocator for our application.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    
    const allocator = gpa.allocator();
    
    // Define the attributes of our window (optional)
    var window_attributes = pica.WindowAttributes {
        .title = "New Window",
        .position = .{10, 10},
        .size = .{1920, 1080},
    };

    // Set the window attributes (optional)
    window.attributes = window_attributes;
    
    // Initialize and show the window (required)
    try pica.Window.initialize(allocator, &window);
    
    std.debug.print("{any}\n", .{window});
}