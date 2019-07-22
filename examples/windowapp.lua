--[[
    If you are using bestwin.exe...

    This is a convenience for making a single window application.
    Simply include this at the bottom of any file that implements
    a global 'app()' function.

    This file implements the requisite 'startup()' function that bestwin.exe
    needs to see, and also implements the 'esc == exit' function.
]]




local vkeys = require("vkeys")

--[[
    quick and dirty get app up on the window
--]]
-- quit when user presses escape
local function handleKeyEvent(event)
    if event.keyCode == vkeys.VK_ESCAPE then
        halt()
    end
end

local function main()
    on("gap_keytyped", handleKeyEvent)

    if not app then
        print("windowapp: MUST specify a global 'app' function")
        halt()
        return false;
    end
    
    app()
end

--[[
    If we're being used as a standalone app, then 
        this setup function is called.
]]

function startup()
    print("STARTUP")
    spawn(main)
end

