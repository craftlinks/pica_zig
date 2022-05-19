const std = @import("std");
const mem = @import("std").mem;
pub const zwin32 = @import("zwin32");
pub const w32 = zwin32.base;


/// kernel32 external function that converts the current thread into a fiber
extern "kernel32" fn ConvertThreadToFiber(lpParameter: ?*anyopaque) callconv(w32.WINAPI) ?*anyopaque;

/// Wrapper function for ConvertThreadToFiber.
/// Returns a fiber address if the call succeeds.
/// Returns an error if the call fails
pub fn convertThreadToFiber(lparam: ?*anyopaque) !*anyopaque {
    const lpParameter = lparam;
    const lpFiber = ConvertThreadToFiber(lpParameter);
    if (lpFiber) |fiber| return fiber;
    const err = w32.kernel32.GetLastError();
    return w32.unexpectedError(err);
}

// ---------------------------------------------------------------------------

pub const WindowAttributes = struct {

    /// The window's title.
    title: [*:0]const u8 = "PiCaLib Window",
    /// The window's position.
    position: [2]i32 = .{50,50},
    /// The window's size.
    size: [2]i32 = .{640, 480},
};


// ---------------------------------------------------------------------------
pub const Window = struct {

    handle: w32.HWND = undefined,
    main_fiber: ?*anyopaque = null,
    /// The window attributes.
    attributes: WindowAttributes = .{},

    // -----------------------------------------------------------------------

    /// Creates a new window with the given window attributes.
    pub fn initialize(
        allocator: std.mem.Allocator,
        window: *Window,
    ) !void {        
        
        _ = allocator;
        
        // Check if the user is uysing a valid window version.
        checkIfWindowsVersionIsSupported();

        const main_fiber = try convertThreadToFiber(null);

        const winclass = w32.user32.WNDCLASSEXA {
            .style = w32.user32.CS_HREDRAW | w32.user32.CS_VREDRAW,
            .lpfnWndProc = processWindowMessage,
            .cbClsExtra = 0,
            .cbWndExtra = 0,
            .hInstance = @ptrCast(w32.HINSTANCE, w32.kernel32.GetModuleHandleW(null)),
            .hIcon = null,
            .hCursor = w32.LoadCursorA(null, @intToPtr(w32.LPCSTR, 32515)),
            .hbrBackground = null,
            .lpszMenuName = null,
            .lpszClassName = "picaWINDOW",
            .hIconSm = null,
        };
        _ = try w32.user32.registerClassExA(&winclass);

        const style = w32.user32.WS_OVERLAPPED +
        w32.user32.WS_VISIBLE +
        w32.user32.WS_SYSMENU +
        w32.user32.WS_CAPTION +
        w32.user32.WS_MINIMIZEBOX;

        const window_position = if (mem.eql(i32, &window.attributes.position, &[2]i32{0,0}))
            [2]i32{w32.user32.CW_USEDEFAULT, w32.user32.CW_USEDEFAULT}
        else window.attributes.position;

        var rect = w32.RECT{
                .left = 0,
                .top = 0,
                .right = window.attributes.size[0],
                .bottom = window.attributes.size[1],
            };
        _ = w32.user32.AdjustWindowRectEx(&rect, style, 0, 0);

        const window_size = if (mem.eql(i32, &window.attributes.size, &[2]i32{0,0}))
            [2]i32{w32.user32.CW_USEDEFAULT, w32.user32.CW_USEDEFAULT}
        else 
            [2]i32{
                rect.right - rect.left,
                rect.bottom - rect.top,
            };

        const wnd = try w32.user32.createWindowExA(
            0,
            "picaWINDOW",
            window.attributes.title,
            style,
            window_position[0],
            window_position[1],
            window_size[0],
            window_size[1],
            null,
            null,
            winclass.hInstance,
            null,
        );
        
        // Fill our window structure.
        window.handle = wnd;
        window.main_fiber = main_fiber; 
    }
};

// ---------------------------------------------------------------------------

fn processWindowMessage(
    window: w32.HWND,
    message: w32.UINT,
    wparam: w32.WPARAM,
    lparam: w32.LPARAM,
) callconv(w32.WINAPI) w32.LRESULT {

    switch (message) {
        w32.user32.WM_DESTROY => {
            w32.user32.PostQuitMessage(0);
        },
        else => {
          return w32.user32.DefWindowProcA(window, message, wparam, lparam);
      },
    }

    return 0;

}

// ---------------------------------------------------------------------------

/// Check if Windows version is supported.
fn checkIfWindowsVersionIsSupported() void {
     var version: w32.OSVERSIONINFOW = undefined;
    _ = w32.ntdll.RtlGetVersion(&version);

    var os_is_supported = false;
    if (version.dwMajorVersion > 10) {
        os_is_supported = true;
    } else if (
        version.dwMajorVersion == 10 and version.dwBuildNumber >= 18363
    ) {
        os_is_supported = true;
    }

    if (!os_is_supported) {
        _ = w32.user32.messageBoxA(
            null,
            "This program requires Windows 10 Build 18363.1350+ or newer. Please upgrade your Windows version."
            ,
            "Error",
            w32.user32.MB_OK | w32.user32.MB_ICONERROR,
        ) catch 0;
        w32.kernel32.ExitProcess(0);
    }
}



   

