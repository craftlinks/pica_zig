const std = @import("std");
pub const zwin32 = @import("zwin32");
pub const base = @import("zwin32.base");


pub const WindowAttributes = struct {

    title: []const u8 = "PiCaLib Window",
    position: [2]i32 = .{50, 50},
    size: [2]i32 = .{640, 480},
};

pub const Window = struct {

    attributes: WindowAttributes = .{},


    pub fn new() Window {
        
        const window_attributes =  .{};

        const window = Window.newWithAttributes(&window_attributes);

        return window;
    
    }

    pub fn newWithAttributes (comptime window_attributes: *const WindowAttributes) Window {
        const window: Window = .{
            .attributes = window_attributes.*,
        }; 
        return window;
    
    }

};

