--[[
    The general purpose of this file is to turn various of the Windows 'events' into a 
    nice consumable lua event.  So, we do message parsing, going from some specific WM_XXX
    to something much nicer.

    This is primarily for keyboard and mouse, but it also handles
    Joystick
    Touch
    Gesture
    RawInput (including USB HID)
]]
local ffi = require("ffi")
local C = ffi.C 

local bit = require("bit")
local band, bor = bit.band, bit.bor
local rshift, lshift = bit.rshift, bit.lshift;

-- BUGBUG, these should be 'g'
wmFocusWindow = nil
wmLastMouseWindow = nil;


local exports = {}

-- encapsulate a mouse event
local function wm_mouse_event(hwnd, msg, wparam, lparam)
    -- assign previous mouse position
    if mouseX then pmouseX = mouseX end
    if mouseY then pmouseY = mouseY end

    -- assign new mouse position
    mouseX = tonumber(band(lparam,0x0000ffff));
    mouseY = tonumber(rshift(band(lparam, 0xffff0000),16));

    local event = {
        screenX = mouseX;
        screenY = mouseY;
        parentX = mouseX;
        parentY = mouseY;
        x = mouseX;
        y = mouseY;

        control = band(wparam, C.MK_CONTROL) ~= 0;
        shift = band(wparam, C.MK_SHIFT) ~= 0;
        lbutton = band(wparam, C.MK_LBUTTON) ~= 0;
        rbutton = band(wparam, C.MK_RBUTTON) ~= 0;
        mbutton = band(wparam, C.MK_MBUTTON) ~= 0;
        xbutton1 = band(wparam, C.MK_XBUTTON1) ~= 0;
        xbutton2 = band(wparam, C.MK_XBUTTON2) ~= 0;
    }

    mousePressed = event.lbutton or event.rbutton or event.mbutton;

    if msg == C.WM_MOUSEMOVE  then
        event.activity = 'mousemove'
        if mousePressed then
            event.isDragging = true;
        end
    elseif msg == C.WM_LBUTTONDOWN or 
        msg == C.WM_RBUTTONDOWN or
        msg == C.WM_MBUTTONDOWN or
        msg == C.WM_XBUTTONDOWN then
        event.activity = 'mousedown';
    elseif msg == C.WM_LBUTTONUP or
        msg == C.WM_RBUTTONUP or
        msg == C.WM_MBUTTONUP or
        msg == C.WM_XBUTTONUP then
        event.activity = 'mouseup'
    elseif msg == C.WM_MOUSEWHEEL then
        event.activity = 'mousewheel';
    elseif msg == C.WM_MOUSELEAVE then
        event.activity = "mouseleave"
    else
        res = C.DefWindowProcA(hwnd, msg, wparam, lparam);
        return false, res
    end

    return event;
end

--[[
    Here in MouseActivity, we're concerned with dealing with event
    propagation.  Here we decide which window has 'focus', where events
    are sent to, when they are used to change focus, etc.

    One key operation is to turn the mouse eventfrom 'screen' coordinates
    to window coordinates.  That way the window can deal with the mouse
    actvity in their own coordinate space.

    BUGBUG - All this switching of which window is topmost, focus, etc
    should be handled elsewhere by a mouseEvent behavior thing.
--]]
function exports.MouseActivity(hwnd, msg, wparam, lparam)
    local res = 0;

    local event, res = wm_mouse_event(hwnd, msg, wparam, lparam)

    if not event then
        return res;
    end

    -- find topmost window for mouse
    local win = WMWindowAt(mouseX, mouseY)
    --print("mouse: ", mouseX, mouseY, win)
    --[[
    if win then
        local x, y = WMScreenToWin(win, event.parentX, event.parentY)
        event.x = x;
        event.y = y;
    end
--]]
    if event.activity == "mousemove" then
        if win then
            if win == wmFocusWindow then
                win:mouseEvent(event)
            else
                event.subactivity = "hover"
                win:mouseEvent(event)
            end
        end
    elseif event.activity == "mousedown" then
        if win then
            if win ~= wmFocusWindow then
                WMSetForegroundWindow(win)
            end
            win:mouseEvent(event)
        else
            WMSetFocus(nil)
        end
    elseif event.activity == "mouseup" then
        if win then
            if win == wmFocusWindow then
                win:mouseEvent(event)
            else
                WMSetFocus(win)
            end
        else
            WMSetFocus(nil)
        end
    else
        if win and win == wmFocusWindow then
            win:mouseEvent(event)
        end
    end

    wmLastMouseWindow = win;

    return 0;
end

function exports.KeyboardActivity(hwnd, msg, wparam, lparam)
    -- encapsulate a keyboard event
    local function wm_keyboard_event(hwnd, msg, wparam, lparam)

        local event = {
            keyCode = wparam;
            repeatCount = band(lparam, 0xffff);  -- 0 - 15
            scanCode = rshift(band(lparam, 0xff0000),16);      -- 16 - 23
            isExtended = band(lparam, 0x1000000) ~= 0;    -- 24
            wasDown = band(lparam, 0x40000000) ~= 0; -- 30
        }
    
        return event;
    end
    
    
    --print("onKeyboardActivity")
    local res = 0;

    local event = wm_keyboard_event(hwnd, msg, wparam, lparam)

    --print("event.keyCode: ", string.format("0x%x",event.keyCode), event.activity)

    if msg == C.WM_KEYDOWN or 
        msg == C.WM_SYSKEYDOWN then
        event.activity = "keydown"
        if wmFocusWindow then
            wmFocusWindow:keyEvent(event)
        end
        signalAll("gap_keydown", event)
    elseif msg == C.WM_KEYUP or
        msg == C.WM_SYSKEYUP then
        event.activity = "keyup"
        if wmFocusWindow then
            wmFocusWindow:keyEvent(event)
        end
        signalAll("gap_keyup", event)
    elseif msg == C.WM_CHAR or
        msg == C.WM_SYSCHAR then
        event.activity = "keytyped"
        event.keyChar = wparam
        if wmFocusWindow then
            wmFocusWindow:keyEvent(event)
        end
        signalAll("gap_keytyped", event)
    else 
        res = C.DefWindowProcA(hwnd, msg, wparam, lparam);
    end

    --print("event.keyCode: ", msg, string.format("0x%x",event.keyCode), event.activity)

    return res;
end


local function wm_joystick_event(hwnd, msg, wParam, lParam)
    local event = {
        Buttons = wParam;
        x = LOWORD(lParam);
        y = HIWORD(lParam);
    }

    if msg == C.MM_JOY1BUTTONDOWN or
    msg == C.MM_JOY2BUTTONDOWN then
        event.Buttons = wParam;
    elseif msg == C.MM_JOY1BUTTONUP or
    msg == C.MM_JOY2BUTTONUP then
        event.Buttons = wParam;
    elseif msg == C.MM_JOY1MOVE or 
        msg == C.MM_JOY2MOVE then
    elseif msg == C.MM_JOY1ZMOVE or
        msg == C.MM_JOY2ZMOVE then
    end


    return event
end

function exports.JoystickActivity(hwnd, msg, wparam, lparam)
    --print("JoystickActivity: ", msg, wparam, lparam)
    local res = 0;

    local event = wm_joystick_event(hwnd, msg, wparam, lparam)

    if msg == C.MM_JOY1BUTTONDOWN or 
        msg == C.MM_JOY2BUTTONDOWN then
        signalAll("gap_joydown", event)
    elseif msg == C.MM_JOY1BUTTONUP or msg == C.MM_JOY2BUTTONUP then
        signalAll("gap_joyup", event)
    elseif msg == C.MM_JOY1MOVE or msg == C.MM_JOY2MOVE then
        signalAll("gap_joymove", event)
    elseif msg == C.MM_JOY1ZMOVE or msg == C.MM_JOY2ZMOVE then
        event.z = LOWORD(lparam)
        signalAll("gap_joyzmove", event)
    end

    return res;
end

function exports.CommandActivity(hwnd, msg, wparam, lparam)
    if onCommand then
        onCommand({source = tonumber(HIWORD(wparam)), id=tonumber(LOWORD(wparam))})
    end

    return 0
end

function exports.TouchActivity(hwnd, msg, wparam, lparam)
    --print("TouchActivity - 1.0")
    local function wm_touch_event()
        -- cInputs could be set to a maximum value (10) and
        -- we could reuse the same allocated array each time
        -- rather than allocating a new one each time.
        --print("wm_touch_event 0.0: ", wparam)
        local cInputs = tonumber(LOWORD(wparam))
        --print("wm_touch_event 1.0: ", cInputs)
        local pInputs = ffi.new("TOUCHINPUT[?]", cInputs)
        local cbSize = ffi.sizeof("TOUCHINPUT")
        --print("wm_touch_event 2.0: ", pInputs, cbSize)
        local bResult = C.GetTouchInputInfo(ffi.cast("HTOUCHINPUT",lparam), cInputs, pInputs,cbSize);
        --print("wm_touch_event 3.0: ", bResult)

        if bResult == 0 then
            return nil, C.GetLastError()
        end
        --print("wm_touch_event 4.0: ", bResult)

        -- Construct an event with all the given information
        local events = {}
        local PT = ffi.new("POINT")
        for i=0,cInputs-1 do
            PT.x = pInputs[i].x/100;
            PT.y = pInputs[i].y/100;
            --print("wm_touch_event 4.1: ", PT.x, PT.y)
            local bResult = C.ScreenToClient(hwnd, PT)
            --print("wm_touch_event 4.2: ", bResult, PT.x, PT.y)
            local event = {
                ID = pInputs[i].dwID;
                x = PT.x;
                y = PT.y;
                rawX = pInputs[i].x;
                rawY = pInputs[i].y;
            }

            if band(pInputs[i].dwMask, C.TOUCHINPUTMASKF_CONTACTAREA) ~= 0 then
                event.rawWidth = pInputs[i].cxContact;
                event.rawHeight = pInputs[i].cyContact;
                event.width = event.rawWidth/100;
                event.height = event.rawHeight/100;
            end

            table.insert(events, event)
        end
        --print("wm_touch_event 5.0: ", bResult)

        return events
    end

    --print("TouchActivity - 2.0")
    local events, err = wm_touch_event()
    --print("TouchActivity - 3.0")
    if events then
        signalAll("gap_touch", events)
    end

    --print("TouchActivity - 4.0")
    local bResult = C.CloseTouchInputHandle(ffi.cast("HTOUCHINPUT",lparam))
    --print("TouchActivity - 5.0")
    
    return 0
end


function exports.GestureActivity(hwnd, msg, wparam, lparam)

    local pGestureInfo = ffi.new("GESTUREINFO")
    pGestureInfo.cbSize = ffi.sizeof("GESTUREINFO")

    local bResult = C.GetGestureInfo(ffi.cast("HGESTUREINFO",lparam), pGestureInfo);

    print("GestureActivity: ", pGestureInfo.dwID)

    if bResult == 0 then
        -- error getting gestureinfo, so just pass through 
        -- to default and return that result
        return C.DefWindowProcA(hwnd, msg, wparam, lparam);
    end

    -- Pass these through for default handling
    if pGestureInfo.dwID == C.GID_BEGIN or pGestureInfo.dwID == C.GID_END then
        res = C.DefWindowProcA(hwnd, msg, wparam, lparam);
        return res;
    end

    local event = {
        ID = pGestureInfo.dwID;
        x = pGestureInfo.ptsLocation.x;
        y = pGestureInfo.ptsLocation.y;
        instance = pGestureInfo.dwInstanceID;
        sequence = pGestureInfo.dwSequenceID;
        arguments = pGestureInfo.ullArguments;
        flags = pGestureInfo.dwFlags;
    }

    local bResult = C.CloseGestureInfoHandle(ffi.cast("HGESTUREINFO",lparam))
    
    signalAll("gap_gesture", event)

    return 0
end


return exports