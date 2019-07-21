
local Window = require("Window")

appContext = nil;

gSystemDpi = nil;
gDesktopDpi = nil;
gScreenX = nil;
gScreenY = nil;
gWallpaper = nil;


-- list of windows in environment
local windowGroup = {}

--[[
    System calls
]]
-- internal function to bring someting to the end of a list
-- with graphics things, this will be the 'front' in terms
-- of windows in 'z-order'
local function bringToFront(list, frontmost)
    local newlist = {}
    for _, listitem in ipairs(list) do
        if listitem ~= frontmost then
            table.insert(newlist, listitem)
        end
    end
    table.insert(newlist, frontmost)

    return newlist
end

function WMGetWindowGroup()
    return windowGroup;
end

-- Return the drawing context for the highest level thing
-- to draw on.  This is usually the composition window.
function WMGetDesktopContext()
    return appContext;
end

function WMGetSystemDpi()
    return gSystemDpi;
end

function WMGetSystemSize()
    return {width = gScreenX, height = gScreenY}
end

function WMGetDesktopDpi()
    return gDesktopDpi;
end

function WMGetDesktopSize()
    return {width = gScreenX, height = gScreenY}
end

function WMSetForegroundWindow(win)
    -- create a new window list where
    -- the selected window is on top of z-order
    windowGroup = bringToFront(windowGroup, win)
    WMSetFocus(win)
    
    return true;
end

function WMSetWallpaper(paper)
    gWallpaper = paper
end

function WMGetWallpaper()
    return gWallpaper;
end

function WMScreenToWin(win, x, y)
    return x-win.frame.x, y-win.frame.y
end

--[[
    static const int TWF_FINETOUCH      = 0x00000001;
static const int TWF_WANTPALM       = 0x00000002;
]]
function WMTouchOn(flags)
    flags = flags or 0
    local bResult = C.RegisterTouchWindow(appWindowHandle, flags);
    if bResult ~= 0 then
        touchIsOn = true;
        return true;
    end

    return false
end

function WMTouchOff()
    local bResult = C.UnregisterTouchWindow(appWindowHandle);
    touchIsOff = true;

    if bResult ~= 0 then
        return true;
    end
    return false;
end

function WMSetFocus(win)
    if win then
        if wmFocusWindow then
            wmFocusWindow:loseFocus()
        end
        win:setFocus()
    else
        if wmFocusWindow then
            wmFocusWindow:loseFocus()
        end
    end

    wmFocusWindow = win
end


local function contains(frame, x, y)
    return x >= frame.x and x < frame.x+frame.width and
        y >= frame.y and y < frame.y+frame.height
end

function WMWindowAt(x, y)

    for i = #windowGroup, 1, -1 do
        win = windowGroup[i]
        if contains(win.frame, x, y) then
            return win
        end
    end

    return nil;
end

-- Create a WinMan window
function WMCreateWindow(params)
    local win = Window:new (params)

    -- set the dpi on the drawing context
    
    table.insert(windowGroup, win)
    --windowGroup:add(win)

    return win
end

function WMDestroyWindow(win)
    -- remove window from list of windows
    local newlist = {}
    for _, item in ipairs(windowGroup) do
        if item ~= win then
            table.insert(newlist, item)
        end 
    end
    windowGroup = newlist;
    -- At this point, the window won't be composited again
    -- because it's out of the windowGroup

    -- give the window a chance to do any cleanup
    -- if it wants to
    win:destroy();
end

--[[
    https://docs.microsoft.com/en-us/windows/desktop/inputdev/using-raw-input
]]
-- Raw input utility functions
local HID_MOUSE    = 2;
local HID_KEYBOARD = 6;

-- Register for mouse and keyboard
local function HID_RegisterDevice(hTarget, usage, onlyWindow)
    
    local hid = ffi.new("RAWINPUTDEVICE");
    hid.usUsagePage = 1;
    hid.usUsage = usage;
    hid.dwFlags = bor(C.RIDEV_DEVNOTIFY , C.RIDEV_INPUTSINK);
    hid.hwndTarget = hTarget;

    local bResult = C.RegisterRawInputDevices(hid, 1, ffi.sizeof("RAWINPUTDEVICE"));
    print("HID_RegisterDevice: ", hTarget, bResult, C.GetLastError())
end

local function HID_UnregisterDevice(usage)
    local hid = ffi.new("RAWINPUTDEVICE");
    hid.usUsagePage = 1;
    hid.usUsage = usage;
    hid.dwFlags = C.RIDEV_REMOVE;
    hid.hwndTarget = nil;

    C.RegisterRawInputDevices(hid, 1, ffi.sizeof("RAWINPUTDEVICE"));
end


function WMRawInputOn(kind, localWindow)
    if kind then
        -- if a specific kind is named, then only register for that kind
        return HID_RegisterDevice(appWindowHandle, HID_MOUSE, localWindow)
    end

    -- if no kind is named,then register for all kinds
    HID_RegisterDevice(appWindowHandle, HID_MOUSE, localWindow)
    HID_RegisterDevice(appWindowHandle, HID_KEYBOARD, localWindow)
    
    return true;
end

function WMRawInputOff(kind)
    if kind then
        return HID_UnregisterDevice(HID_MOUSE);
    end
    
    HID_UnregisterDevice(HID_MOUSE);
    HID_UnregisterDevice(HID_KEYBOARD);
end
