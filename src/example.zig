const std = @import("std");
const pica = @import("pica");

pub fn main() !void {

    const window_attributes = pica.WindowAttributes {
            .title = "New Window",
            .position = .{100, 100},
            .size = .{400, 400},
        };

    const window = pica.Window.newWithAttributes(&window_attributes);
    std.debug.print("window title: {s}\n", .{window.attributes.title});
    std.debug.print("window position: {any}\n", .{window.attributes.position});
    std.debug.print("window size: {any}\n", .{window.attributes.size});  
}