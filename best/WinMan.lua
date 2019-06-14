--[[
    This single file represents the guts of a desktop windowing environment

    By default, it will create a topmost window that spans the entire
    current desktop.  You can control what is seen 'behind' the 
    desktop by your choice of wallpaper.

    If you select no wallpaper:  WMSetWallpaper(nil), then the only
    thing you'll see on the desktop are the apps that you create,
    otherwise, you'll see what's behind on the regular Windows desktop.

    Typical usage:

    -- This first line MUST come before any user code
    require("DeskTopper")

    -- This MUST be the last line of the user code
    DeskTopper {startup = startupFunctioin}


    This will essentially create a desktop environment ready for windows and other 
    graphics to be created.


    window:new()

    A note about Drawing 'out of band'
    Since we draw based on a framerate, it's important to draw when we want to.
    In that case, we use the user32 call: RedrawWindow, and all our drawing
    happens inside the WM_ERASEBKGND message.

    We do this instead of relying on WM_PAINT, because that one is posted and proessed 
    in a non-deterministic way.  Using Redraw and the background, we can ensure an sync
    call to drawing, which gets us closer to our frame rate.

    Useful for the future
    https://blog.getpaint.net/2017/08/12/win32-how-to-get-the-refresh-rate-for-a-window/
    https://msdn.microsoft.com/magazine/dn745861.aspx


Dealing with monitor
HMONITOR monitor = MonitorFromWindow(hwnd, MONITOR_DEFAULTTONEAREST);
MONITORINFO info;
info.cbSize = sizeof(MONITORINFO);
GetMonitorInfo(monitor, &info);
int monitor_width = info.rcMonitor.right - info.rcMonitor.left;
int monitor_height = info.rcMonitor.bottom - info.rcMonitor.top;

]]

local ffi = require("ffi")
local C = ffi.C 
local bit = require("bit")
local band, bor = bit.band, bit.bor

local BEST_system = require("BEST_system")
local BEST_uievents = require("BEST_uievents")
local BEST_uisignaling = require("BEST_uisignaling")
local BEST_win32 = require("BEST_win32")






--[[
    Here we are at the specifics of what makes this particular kind of application shell.
    In the case DeskTopper, the window is the full size of the screen, as well as being
    a topmost window.
]]
local function start(params)
    params = params or {}

    -- First thing to do is let the system know we are
    -- going to be DPI aware
    local oldContext = C.SetThreadDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);

    -- Now figure out the size of the desktop (primary monitor)
    gScreenX = C.GetSystemMetrics(C.SM_CXSCREEN)
    gScreenY = C.GetSystemMetrics(C.SM_CYSCREEN)
    gSystemDpi = C.GetDpiForSystem();

    params.width = 1920;
    params.height = 1440;
    params.title = params.title or "WinMan";
    --params.winstyle = C.WS_CAPTION;
    --params.winxstyle = bor(C.WS_EX_NOREDIRECTIONBITMAP);
    params.winxstyle = bor(C.WS_EX_LAYERED, C.WS_EX_NOREDIRECTIONBITMAP);
--    params.winxstyle = bor(C.WS_EX_LAYERED, C.WS_EX_TOPMOST, C.WS_EX_NOREDIRECTIONBITMAP);
    params.frameRate = params.frameRate or 30;

    run(BEST_win32, params)
end

return start