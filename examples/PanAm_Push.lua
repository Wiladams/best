--[[
    panel 2 pushes panel 1 out of frame

    Assume panel 1 and panel 2 exist
--]]

local PanelAnimator = require("PanelAnimator")

local PanAmPush = {}
setmetatable(PanAmPush, {
    __index = PanelAnimation;
})

function PanAmPush.new(self, obj)
    local obj = PanelAnimator:new(obj)
    
    setmetatable(obj, PanAmPush_mt)
    return obj;
end

function PanAmPush.update(self, u)
end


return PanAmPush