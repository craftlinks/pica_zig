const std = @import("std");
const mem = @import("std").mem;
pub const zwin32 = @import("zwin32");
pub const w32 = zwin32.base;
pub const POINT = w32.POINT;

// ----------------------------------------------------------------------------
// Constants
const GWLP_USERDATA = -21;


// ----------------------------------------------------------------------------
// Win32 Fibers (aka "co-routines")

extern "kernel32" fn ConvertThreadToFiber(lpParameter: ?*anyopaque)
    callconv(w32.WINAPI) ?*anyopaque;

fn convertThreadToFiber(lparam: ?*anyopaque) !*anyopaque {
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

fn createFiber(
    dwStackSize: usize,
    lpStartAddress: *const anyopaque,
    lpParameter:  * anyopaque,
) !*anyopaque {
    const lpFiber = CreateFiber(dwStackSize, lpStartAddress, lpParameter);
    if (lpFiber) |fiber| return fiber;
    const err = w32.kernel32.GetLastError();
    return w32.unexpectedError(err);
}

extern "kernel32" fn SwitchToFiber(lpFiber: *anyopaque)
    callconv(w32.WINAPI) void;


fn switchToFiber(lpFiber: *anyopaque) void {
    SwitchToFiber(lpFiber);
}

// ---------------------------------------------------------------------------
// Misc

extern "user32" fn ClientToScreen( hWnd: ?w32.HWND, lpPoint: *POINT) 
    callconv(w32.WINAPI) w32.BOOL;

// ---------------------------------------------------------------------------
// SetTimer

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

fn setTimer(
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

// ---------------------------------------------------------------------------
// Register RAWINPUTDEVICE for mouse.

const RAWINPUTDEVICE = extern struct {
    usUsagePage: w32.USHORT,
    usUsage: w32.USHORT,
    dwFlags: w32.DWORD,
    hwndTarget: w32.HWND,
};

extern "user32" fn RegisterRawInputDevices(
    pRawInputDevices: *const RAWINPUTDEVICE,
    uiNumDevices: usize,
    cbSize: usize
) callconv(w32.WINAPI) usize;

fn registerRawInputDevices(
    pRawInputDevices: *const RAWINPUTDEVICE,
    uiNumDevices: usize,
    cbSize: usize
) !void {
    const ret = RegisterRawInputDevices(pRawInputDevices, uiNumDevices, cbSize);
    if (ret == 0) {
        const err = w32.kernel32.GetLastError();
        return w32.unexpectedError(err);
    }
}

// ---------------------------------------------------------------------------

const Time = struct {
    delta_ticks: i64 = 0,
    delta_nanoseconds: i64 = 0,
    delta_microseconds: i64 = 0,
    delta_milliseconds: i64 = 0,
    delta_seconds: f64 = 0,
    ticks: i64 = 0,
    nanoseconds: i64 = 0,
    microseconds: i64 = 0,
    milliseconds: i64 = 0,
    seconds: f32 = 0,
    initial_ticks: i64 = 0,
    ticks_per_second: i64 = 0,
};

// ---------------------------------------------------------------------------

const Button = struct {
    down: bool = false,
    pressed: bool = false,
    released: bool = false,

    pub fn update_button(self: Button, is_down: bool) void {
        const was_down = self.down;
        self.down = is_down;
        self.pressed = !was_down and is_down;
        self.released = was_down and !is_down;
    }
};



const Mouse = struct {
    left_button: Button = .{},
    right_button: Button = .{},
    wheel: i32 = 0,
    delta_wheel: i32 = 0,
    position: [2]i32 = .{0, 0},   
    delta_position: [2]i32 = .{0, 0},
};

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
    time: Time = .{},
    initialized: bool = false,
    quit: bool = false,
    mouse: Mouse = .{},
};

// ---------------------------------------------------------------------------
pub fn initialize(window: *Window) !void {
    try windowInitialize(window);
    try timeInitialize(window);
    try mouseInitialize(window);
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
        windowMessageFiberProc, 
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

fn timeInitialize(window: *Window) !void {
    var large_integer: i64 = 0;
    
    _ = w32.kernel32.QueryPerformanceFrequency(
        &large_integer
    );
    window.time.ticks_per_second = large_integer;
    
    _ = w32.kernel32.QueryPerformanceCounter(
        &large_integer
    );  
    window.time.initial_ticks = large_integer;
    
}


fn timePull(window: *Window) !void {
    var large_integer: i64 = 0;
    _ = w32.kernel32.QueryPerformanceCounter(
        &large_integer
    );
    const current_ticks: i64 = large_integer;
    window.time.delta_ticks = current_ticks 
        - window.time.ticks 
        - window.time.initial_ticks;
    window.time.ticks = current_ticks - window.time.initial_ticks;
    
    window.time.delta_nanoseconds =  @divTrunc(1000 * 1000 * 1000 * window.time.delta_ticks, window.time.ticks_per_second);
    window.time.delta_microseconds = @divTrunc(window.time.delta_nanoseconds,1000); 
    window.time.delta_milliseconds = @divTrunc(window.time.delta_microseconds,1000); 
    window.time.delta_seconds = @intToFloat(f64,window.time.delta_ticks) / @intToFloat(f64,window.time.ticks_per_second); 

    window.time.nanoseconds =  @divTrunc(1000 * 1000 * 1000 * window.time.ticks, window.time.ticks_per_second);
    window.time.microseconds = @divTrunc(window.time.nanoseconds,1000);
    window.time.milliseconds = @divTrunc(window.time.microseconds,1000);
    window.time.seconds = @intToFloat(f32,window.time.ticks) / @intToFloat(f32,window.time.ticks_per_second);
}

// ----------------------------------------------------------------------------

fn mouseInitialize(window: *Window) !void {
    const raw_input_device: RAWINPUTDEVICE = .{
        .usUsagePage =1,
        .usUsage = 2,
        .dwFlags = 0,
        .hwndTarget = window.handle,
    };
    try registerRawInputDevices(
        &raw_input_device,
        1,
        @sizeOf(RAWINPUTDEVICE),
    );
}

fn mousePull(window: *Window) !void {
    _  = window;
    var mouse_position = POINT{.x = 0, .y = 0};
    _ = w32.GetCursorPos(&mouse_position);
    mouse_position.x -= window.attributes.position[0];
    mouse_position.y -= window.attributes.position[1];
    window.mouse.position = .{mouse_position.x, mouse_position.y};
}

// ----------------------------------------------------------------------------

pub fn pull(window: *Window) anyerror!bool {
    if (!window.initialized) return error.WindowNotInitialized;
    try windowPull(window);
    try timePull(window);
    try mousePull(window);
    


    return window.quit;
}

// ---------------------------------------------------------------------------

fn windowMessageFiberProc(window: *Window) callconv(w32.WINAPI) void {
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
    
    window.attributes.resized = false;
    window.mouse.delta_position[0] = 0;
    window.mouse.delta_position[1] = 0;
    window.mouse.delta_wheel = 0;
    window.mouse.left_button.pressed = false;
    window.mouse.left_button.released = false;
    window.mouse.right_button.pressed = false;
    window.mouse.right_button.released = false;
    
    switchToFiber(window.message_fiber.?);
    var client_rect: w32.RECT = .{.left = 0, .right = 0, .top = 0, .bottom = 0}; 
    _ = w32.GetClientRect(window.handle, &client_rect);

    window.attributes.size[0] = client_rect.right - client_rect.left;
    window.attributes.size[1] = client_rect.bottom - client_rect.top;

    var window_position: w32.POINT = .{
        .x = client_rect.left,
        .y = client_rect.top
    };

    _ = ClientToScreen(window.handle, &window_position);
    window.attributes.position[0] = window_position.x;
    window.attributes.position[1] = window_position.y;
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



   

