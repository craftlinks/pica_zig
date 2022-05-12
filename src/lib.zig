const std = @import("std");
pub const zwin32 = @import("zwin32");
pub const base = @import("zwin32.base");


pub const WindowAttributes = struct {

    // --WindowAttributes struct fields--

    /// The window's title.
    title: []const u8 = "PiCaLib Window",
    /// The window's position.
    position: [2]i32 = .{50, 50},
    /// The window's size.
    size: [2]i32 = .{640, 480},
};

pub const Window = struct {

    // --Window struct fields--
    
    /// The window attributes.
    attributes: WindowAttributes = .{},

    
    // --Window struct functions--
    
    /// Creates a new window with default window attributes. 
    pub fn new() Window {
        
        const window_attributes =  .{};
        const window = Window.newWithAttributes(&window_attributes);

        return window;
    }

    /// Creates a new window with the given window attributes.
    pub fn newWithAttributes (comptime window_attributes: *const WindowAttributes) Window {
        const window: Window = .{
            .attributes = window_attributes.*,
        }; 
        return window;
    }

};

