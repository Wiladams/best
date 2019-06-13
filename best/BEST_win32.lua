local ffi = require("ffi")
local C = ffi.C 

local bit = require("bit")
local band, bor = bit.band, bit.bor
local rshift, lshift = bit.rshift, bit.lshift;

local win32 = require("win32")
local sched = require("scheduler")

local BEST_uievents = require("BEST_uievents")

local BLDIBSection = require("BLDIBSection")
local DrawingContext = require("DrawingContext")
DrawingContext:exportConstants()





local LOWORD = win32.LOWORD
local HIWORD = win32.HIWORD


--[[
    Global state for applications
]]
frameCount = 0;
FrameRate = 30;

mouseX = 0;
mouseY = 0;


-- Internal State
local appSurface = nil;
local appContext = nil;
local appBackground = nil;
local appImage = nil;
local appWindowHandle = nil;
local appWindowDC = nil;




local windowGroup = {}

local EnvironmentReady = false;






-- Internal functions
-- Take our desktop backing store and flush it to the
-- windows screen in as fast as a manner as possible.
local function flushToScreen()

    -- Using the UpdateLayeredWindow approach can be very useful as we have
    -- a bitmap that is our own composition of all things being drawn.
    -- we can pass that along to Window for easy composition
    -- This should save us one Blt to a side buffer, and eliminate using any GDI
    -- besides the DIBSection which serves the purpose of being the bitmap
    
    local wrect = ffi.new("RECT")
    C.GetWindowRect(appWindowHandle, wrect);
    local hdcDst = C.GetDC(nil);     -- use palette of screen, maybe not needed
    local pptDst = ffi.new("POINT", {0,0});     -- we're not changing position
    local psize  = ffi.new("SIZE", {wrect.right-wrect.left,wrect.bottom-wrect.top});     -- we're not repositioning the window
    local hdcSrc = appSurface.DC;     -- we're doing drawing, so this should be set
    local pptSrc = ffi.new("POINT", {0,0});
    local crKey = 0;
    local dwFlags = C.ULW_ALPHA;

    local pblend = ffi.new("BLENDFUNCTION");
    pblend.BlendOp = C.AC_SRC_OVER;
    pblend.BlendFlags = 0
    pblend.SourceConstantAlpha = 255;
    pblend.AlphaFormat = C.AC_SRC_ALPHA;

    local success = C.UpdateLayeredWindow(appWindowHandle, 
            hdcDst,
            pptDst, 
            psize, 
            hdcSrc, pptSrc,
            crKey,
            pblend,
            dwFlags) ~= 0;


    C.ReleaseDC(nil, hdcDst)

    return success;
end


--[[
    Within composeFrame, we compose the entire desktop, by compositing
    the individual windows and various and sundry other drawing tasks
    that are appropriate to the desktop.
]]
local function composeFrame()
    if not EnvironmentReady then return end

    frameCount = frameCount + 1;
    --print("composeFrame: ", frameCount, #windowGroup.children)

    -- Clear the app context so we start with a clean slate
    appContext:clear()

    if gWallpaper then
        gWallpaper:draw(appContext)
    end

    -- iterate through the windows
    -- compositing each one
    for _, win in ipairs(WMGetWindowGroup()) do
        -- if we don't want transparent windows
        -- then src_copy
        -- there can be a per-window attribute for this
        -- and other composite operations
        --appContext:setCompOp(C.BL_COMP_OP_SRC_COPY)
        appContext:setCompOp(C.BL_COMP_OP_SRC_OVER)

        local readyBuff = win:getReadyBuffer()
        if readyBuff then
            appContext:blit(readyBuff, win.frame.x, win.frame.y)
        end
    end

    -- force a redraw to the screen
    flushToScreen()
end


local ps = ffi.new("PAINTSTRUCT");

local function WindowProc(hwnd, msg, wparam, lparam)
    --print(string.format("WindowProc: msg: 0x%x, %s", msg, wmmsgs[msg]), wparam, lparam)

    local res = 0;

    if msg == C.WM_DESTROY then
        C.PostQuitMessage(0);
        signalAllImmediate('gap_quitting');
        return 0;

    elseif msg >= C.WM_MOUSEFIRST and msg <= C.WM_MOUSELAST then
        res = BEST_uievents.MouseActivity(hwnd, msg, wparam, lparam)
    elseif msg >= C.WM_KEYFIRST and msg <= C.WM_KEYLAST then
        res = BEST_uievents.KeyboardActivity(hwnd, msg, wparam, lparam)
    elseif msg >= C.MM_JOY1MOVE and msg <= C.MM_JOY2BUTTONUP then
        res = BEST_uievents.JoystickActivity(hwnd, msg, wparam, lparam)
    --elseif msg == C.WM_COMMAND then
    --    res = CommandActivity(hwnd, msg, wparam, lparam)
    elseif msg == C.WM_TOUCH then
        res = BEST_uievents.TouchActivity(hwnd, msg, wparam, lparam)
    elseif msg == C.WM_GESTURE then
        res = BEST_uievents.GestureActivity(hwnd, msg, wparam, lparam)
    elseif msg == C.WM_INPUT then
        -- do stuff with raw input
        --print("WM_INPUT: ", wparam)
        -- create appropriate events from raw data
        res = C.DefWindowProcA(hwnd, msg, wparam, lparam)
    elseif msg == C.WM_ERASEBKGND then
        --print("WM_ERASEBKGND: ", frameCount)
        --local hdc = ffi.cast("HDC", wparam); 
        res = 0; 
    elseif msg == C.WM_PAINT then
        -- multiple WM_PAINT commands can be issued
        -- while dragging the window around, but the msgLoop
        -- is not involved as windowProc is called directly
        -- in order to properly update the framecount, we need
        -- to use a system timer, and handle WM_TIMER messages
        --print("WindowProc.WM_PAINT:", frameCount, wparam, lparam)

        local ps = ffi.new("PAINTSTRUCT");
		local hdc = C.BeginPaint(hwnd, ps);

        C.EndPaint(hwnd, ps);
        res = 0
    elseif msg == C.WM_DPICHANGED then
        local dpiY = tonumber(HIWORD(wparam));
        local dpiX = tonumber(LOWORD(wparam));

        local hWndInsertAfter = nil;
        local r = ffi.cast("RECT *", lparam)
        local X = r.left;
        local Y = r.top;
        local cx = r.right - r.left;
        local cy = r.bottom - r.top;
        local uFlags = bor(C.SWP_NOMOVE, C.SWP_NOOWNERZORDER, C.SWP_NOACTIVATE, C.SWP_NOZORDER)
        local bResult = C.SetWindowPos(hwnd, hWndInsertAfter, X, Y, cx, cy, uFlags);

        --print("WinMan.msg, WM_DPICHANGED: ", dpiX, r.left, r.top, cx, cy, bResult)

        return 0
    else
        res = C.DefWindowProcA(hwnd, msg, wparam, lparam);
    end

	return res
end
jit.off(WindowProc)


local function msgLoop()
    --  create some a loop to process window messages
    --print("msgLoop - BEGIN")
    local msg = ffi.new("MSG")
    local res = 0;

    while (true) do
        --print("LOOP")
        -- we use peekmessage, so we don't stall on a GetMessage
        --while (C.PeekMessageA(msg, nil, 0, 0, C.PM_REMOVE) ~= 0) do
        local haveMessage = C.PeekMessageA(msg, nil, 0, 0, C.PM_REMOVE) ~= 0
        if haveMessage then
            -- If we see a quit message, it's time to stop the program
            -- ideally we'd call an 'onQuit' and wait for that to return
            -- before actually halting.  That will give the app a chance
            -- to do some cleanup
            if msg.message == C.WM_QUIT then
                --print("msgLoop - QUIT")
                halt();
            end

            res = C.TranslateMessage(msg)
            res = C.DispatchMessageA(msg)
        end

        yield();
        -- ideally this routine would be a coroutine
        -- at the scheduler level, switching between 
        -- normal scheduled tasks, and windows message looping
        -- then message processing would be better interspersed
        -- with tasks, rather than being scheduled at the end
        -- of the ready list
        --coroutine.yield(true)
    end   
end


local function createWin32Window(params)
    params = params or {width=1024, height=768, title="GraphicApplication"}
    
    params.x = params.x or 0
    params.y = params.y or 0
    params.width = params.width or 1024;    -- should be desktop size
    params.height = params.height or 768;   -- should be desktop size
    
    params.title = params.title or "Blend2d App";

    -- set global variables
    width = params.width;
    height = params.height;

    -- You MUST register a window class before you can use it.
    local winclassname = "bs2appwindow"
    local winatom, err = win32.RegisterWindowClass(winclassname, WindowProc)

    if not winatom then
        print("Window class not registered: ", err);
        return false, err;
    end


    params.winclass = params.class or winclassname
    params.winstyle = params.winstyle or C.WS_POPUP
    params.winxstyle = params.winxstyle or C.WS_EX_LAYERED

    -- create an instance of a window
    local winHandle, err = win32.CreateWindowHandle(params)

    if not winHandle then
        print("NO WINDOW HANDLE: ", err)
        return false, err
    end
    
    return winHandle
end



local function init(params)
    -- We can create the app Surface from the beginning
    -- as it's fairly independent
    appSurface, err = BLDIBSection(params)
    appImage = appSurface.Image
    --appContext = BLContext(appImage)
    params.BackingBuffer = appImage
    appContext = DrawingContext(params)
    --appImage = appContext:getReadyBuffer()

    -- Fill context with background color to start
    appContext:clear() 

    FrameRate = params.frameRate or 30;

    -- Start the message loop going so window
    -- creation can occur
    spawn(msgLoop);
    yield();


    -- Create the actual Window which will represent
    -- the Managed window UI Surface
    appWindowHandle,err = createWin32Window(params)
    appWindowDC = C.GetDC(appWindowHandle)
    gDesktopDpi = C.GetDpiForWindow (appWindowHandle);


    local bResult = C.ShowWindow(appWindowHandle, C.SW_SHOW);

    -- Setup to deal with user inputs
    --setupUIHandlers();
    --yield();

    EnvironmentReady = true;

    yield();

    if params.startup then
        spawn(params.startup, params)
    end
    --yield()

    -- setup the periodic frame calling
    local framePeriod = math.floor(1000/FrameRate)
    periodic(framePeriod, composeFrame)
end

return init