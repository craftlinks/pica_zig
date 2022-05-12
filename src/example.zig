const std = @import("std");
const pica = @import("pica");

pub fn main() !void {

    std.debug.print("Hello World!\n", .{});
    pica.print_hello();


}

//     const winclass = w32.user32.WNDCLASSEXA{
//         .style = 0,
//         .lpfnWndProc = processWindowMessage,
//         .cbClsExtra = 0,
//         .cbWndExtra = 0,
//         .hInstance = @ptrCast(w32.HINSTANCE, w32.kernel32.GetModuleHandleW(null)),
//         .hIcon = null,
//         .hCursor = w32.LoadCursorA(null, @intToPtr(w32.LPCSTR, 32512)),
//         .hbrBackground = null,
//         .lpszMenuName = null,
//         .lpszClassName = @ptrCast(w32.LPCSTR, "HelloWorld"),
//         .hIconSm = null,
//     };
//     _ = try w32.user32.registerClassExA(&winclass);


// }

// fn processWindowMessage(
//     window: w32.HWND,
//     message: w32.UINT,
//     wparam: w32.WPARAM,
//     lparam: w32.LPARAM,
// ) callconv(w32.WINAPI) w32.LRESULT {

//     return w32.user32.defWindowProcA(window, message, wparam, lparam);

// }
    