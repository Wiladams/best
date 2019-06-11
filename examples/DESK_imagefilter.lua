package.path = "../best/?.lua;"..package.path;

--[[
    This is an example of a startup for bestdesk.exe
    The general idea is, you want to specify how the desktop
    looks upon starting the application.

    So, this is part configuration, part app playground.  Really
    there should be specifically named desktop configurations, and 
    all the app specifics should be in "APP_specific.lua" files, which 
    the configuration simply loads.

    Of particular note, there MUST be a globaly 'startup()' function.
    This is what bestdesk.exe is expecting to see, and will use it 
    as a startup.  None of the BEST environment is available to the 
    configuration until this startup function has been called.

    In particular, none of the scheduler functions are available.
]]


local BView = require("BView")
local functor = require("functor")
local Checkerboard = require("CheckerGraphic")
local vkeys = require("vkeys")
local ContextRecorder = require("ContextRecorder")
local app = require("APP_imagefilter")

local function handleKeyEvent(event)
    if event.keyCode == vkeys.VK_ESCAPE then
        halt()
    end
end



local function main()
    -- Establish event handler for typed keys
    -- this will occur at a desktop level, regardless
    -- of how keys are handled within individual windows
    on("gap_keytyped", handleKeyEvent)
--[[
    local dSize = WMGetDesktopSize()

    -- Create a checkerboard pattern to use as the
    -- desktop wallpaper
    local wp = Checkerboard:new({
        frame={x=0,y=0,width=dSize.width,height=dSize.height},
        --columns = 64,
        --rows = 64
    })
    WMSetWallpaper(wp)
--]]
    app()
end

function startup()
    spawn(main)
end
