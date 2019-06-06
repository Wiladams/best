package.path = "../?.lua;"..package.path;

local DeskTopper = require("DeskTopper")


local RGBExplorer = require("examples.RGBExplorer")
local AngleIndicator = require("examples.AngleIndicator")
local AnalogClock = require("examples.AnalogClock")

local radians = math.rad

local desktopWidth = 1200
local desktopHeight = 1080


local function app(params)
    local win1 = WMCreateWindow(params)

    local rgbExp = RGBExplorer:new()
    rgbExp:moveTo(10,10)
    
    local angi = AngleIndicator:new({value = radians(75), frame = {x=400, y=20}})
    local clock = AnalogClock:new({frame = {x=640, y=20}})

    win1:add(rgbExp)
    win1:add(angi)
    win1:add(clock)

    win1:show()

    local function handleSliderChange(slider, sig)
        print(slider.title, sig, string.format("%32.f",slider:getPosition()), slider:getValue())
    end

    local function drawproc()
        win1:draw()
    end

    periodic(1000/10, drawproc)

end


local function startup()
    spawn(app, {frame = {x=4, y=4, width=1024, height=768}})
end

DeskTopper {width = desktopWidth, height=desktopHeight, startup = startup, frameRate=30}