
local DeskTopper = require("DeskTopper")

local circleapp = require("BEST_circle")


local function startup()
    spawn(circleapp, {frame = {x=10, y=10, width=320, height=240}})
end

DeskTopper {width = 640, height=480, startup = startup}