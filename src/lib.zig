const std = @import("std");
const mem = @import("std").mem;
pub const zwin32 = @import("zwin32");
pub const w32 = zwin32.base;

const GWLP_USERDATA = -21;

/// kernel32 external function that converts the current thread into a fiber
extern "kernel32" fn ConvertThreadToFiber(lpParameter: ?*anyopaque)
    callconv(w32.WINAPI) ?*anyopaque;

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

extern "kernel32" fn CreateFiber(
    dwStackSize: usize,
    lpStartAddress: *const anyopaque,
    lpParameter: w32.LPVOID,
) callconv(w32.WINAPI) ?*anyopaque;

pub fn createFiber(
    dwStackSize: usize,
    lpStartAddress: *const anyopaque,
    lpParameter:  * anyopaque,
) !*anyopaque {
    const lpFiber = CreateFiber(dwStackSize, lpStartAddress, lpParameter);
    if (lpFiber) |fiber| return fiber;
    const err = w32.kernel32.GetLastError();
    return w32.unexpectedError(err);
}

const TIMERPROC = fn (
    hwnd: w32.HWND,
    parm1: w32.UINT,
    parm2: usize,
    parm3: w32.DWORD
) callconv(w32.WINAPI) w32.LPVOID;

extern "user32" fn SetTimer(
    hwnd: ?w32.HWND,
    nIDEvent: usize,
    uElapse: w32.UINT,
    lpTimerFunc: ?TIMERPROC
) callconv(w32.WINAPI) usize;

pub fn setTimer(
    hwnd: ?w32.HWND,
    nIDEvent: usize,
    uElapse: w32.UINT,
    lpTimerFunc: ?TIMERPROC
) !usize {
    const timer: usize = SetTimer(hwnd, nIDEvent, uElapse, lpTimerFunc);
    if (timer != 0) return timer;
    const err = w32.kernel32.GetLastError();
    return w32.unexpectedError(err);
}

extern "kernel32" fn SwitchToFiber(lpFiber: *anyopaque)
    callconv(w32.WINAPI) void;


pub fn switchToFiber(lpFiber: *anyopaque) void {
    SwitchToFiber(lpFiber);
}


// ---------------------------------------------------------------------------

pub const WindowAttributes = struct {

    /// The window's title.
    title: [*:0]const u8 = "PiCaLib Window",
    /// The window's position.
    position: [2]i32 = .{50,50},
    /// The window's size.
    size: [2]i32 = .{640, 480},
    /// The window's size has changed.
    resized: bool = false,
};


// ---------------------------------------------------------------------------
pub const Window = struct {

    handle: w32.HWND = undefined,
    device_context: w32.HDC = undefined,
    main_fiber: ?*anyopaque = null,
    message_fiber: ?*anyopaque = null,
    attributes: WindowAttributes = .{},
    initialized: bool = false,
    quit: bool = false,

   
};

// ---------------------------------------------------------------------------
pub fn initialize(window: *Window) !void {
    try windowInitialize(window);
}


// ----------------------------------------------------------------------------

/// Creates a new window with the given window attributes.
fn windowInitialize(
    window: *Window,
) !void {        
    
    // Check if the user is uysing a valid window version.
    checkIfWindowsVersionIsSupported();

    window.main_fiber = try convertThreadToFiber(null);
    window.message_fiber = try createFiber(
        0,
        window_message_fiber_proc, 
        window
    );

    const winclass = w32.user32.WNDCLASSEXA {
        .style = w32.user32.CS_HREDRAW | w32.user32.CS_VREDRAW,
        .lpfnWndProc = processWindowMessage,
        .cbClsExtra = 0,
        .cbWndExtra = 0,
        .hInstance = @ptrCast(
            w32.HINSTANCE,
            w32.kernel32.GetModuleHandleW(null)
        ),
        .hIcon = null,
        .hCursor = null, // w32.LoadCursorA(null, @intToPtr(w32.LPCSTR, 32512)),
        .hbrBackground = null,
        .lpszMenuName = null,
        .lpszClassName = "picaWINDOW",
        .hIconSm = null,
    };
    _ = try w32.user32.registerClassExA(&winclass);

    const style = w32.user32.WS_OVERLAPPEDWINDOW + w32.user32.WS_VISIBLE;

    const window_position = if (mem.eql(
            i32,
            &window.attributes.position,
            &[2]i32{0,0}
        )
    ) [2]i32{w32.user32.CW_USEDEFAULT, w32.user32.CW_USEDEFAULT}
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

    window.handle = try w32.user32.createWindowExA(
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

    const dwNewLong = @intCast(isize, @ptrToInt(window));
    std.debug.print("dwNewLong: {any} \n", .{dwNewLong});

    _ = try w32.user32.setWindowLongPtrA(
        window.handle,
        GWLP_USERDATA,
        dwNewLong
    );
    window.device_context = try w32.user32.getDC(window.handle);
    
    window.initialized = true; 
}

// ----------------------------------------------------------------------------

pub fn pull(window: *Window) anyerror!bool {
    if (!window.initialized) return error.WindowNotInitialized;
    try windowPull(window);
    


    return window.quit;
}

// ---------------------------------------------------------------------------

fn window_message_fiber_proc(window: *Window) callconv(w32.WINAPI) void {
    _ = setTimer(window.handle, 1, 1, null) catch unreachable;
    var message = std.mem.zeroes(w32.user32.MSG);
    while (true) {    
        if (w32.user32.peekMessageA(
                    &message,
                    null,
                    0,
                    0,
                    w32.user32.PM_REMOVE
                ) catch false
            ) {
            _ = w32.user32.translateMessage(&message);
            _ = w32.user32.dispatchMessageA(&message);
        }
        switchToFiber(window.main_fiber.?);
    }
}

// ---------------------------------------------------------------------------

fn processWindowMessage(
    window_handle: w32.HWND,
    message: w32.UINT,
    wparam: w32.WPARAM,
    lparam: w32.LPARAM,
) callconv(w32.WINAPI) w32.LRESULT {

    const _window_ptr: isize = w32.user32.getWindowLongPtrA(
        window_handle,
        GWLP_USERDATA
    ) catch unreachable;
    
    if(_window_ptr == 0) return w32.user32.DefWindowProcA(
        window_handle,
        message,
        wparam,
        lparam
    );
    
    var window: *Window = @intToPtr(*Window, @intCast(usize, _window_ptr));
    _ = window;

    switch (message) {
        
        w32.user32.WM_SIZE => {
            window.attributes.resized = true;
        },
        
        w32.user32.WM_TIMER => {
            switchToFiber(window.main_fiber.?);

        },
        
        w32.user32.WM_DESTROY => {
            std.debug.print("WM_DESTROY\n", .{});
            window.quit = true;
        },
        else => {
            return w32.user32.DefWindowProcA(
                window_handle,
                message,
                wparam, 
                lparam
            );
        },
    }

    return 0;

}

// ---------------------------------------------------------------------------
fn windowPull(window: *Window) !void {
    switchToFiber(window.message_fiber.?);
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



   

