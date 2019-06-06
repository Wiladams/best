--[[
    A simple shell of a test program for STOP_ apps.  Create a STOPlet, then
        execute it like this:

    > luajit test_STOP stoplet 

    Give the stoplet name without the trailing '.lua'.  This will create a default sized
    desktop (1280x1024) and a default window for the STOPlet to run in (1024x768)
--]]

local DeskTopper = require("DeskTopper")

local appname = arg[1]


if not appname then 
    print("you must specify a STOPlet name")
    return nil 
end

local app = require(appname)
local desktopWidth = 1920
local desktopHeight = 1920

local function startup()
    spawn(app, {frame = {x=0, y=0, width=desktopWidth, height=desktopHeight}})
end

DeskTopper {startup = startup, frameRate=30}