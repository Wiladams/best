local GraphicGroup = require("GraphicGroup")
local easing = require("easing")
local maths = require("maths")
local map = maths.map


local EasingGraph = {}
setmetatable(EasingGraph, {
    __index = GraphicGroup;
})
local EasingGraph_mt = {
    __index = EasingGraph;
}

function EasingGraph.new(self, obj)
    obj = GraphicGroup:new(obj)

    obj.interpolator = obj.interpolator or easing.easeLinear;
    obj.duration = obj.duration or 1.0;
    obj.startValue = obj.startValue or 0;
    obj.changeInValue = obj.changeInValue or 1.0;

    setmetatable(obj, EasingGraph_mt)

    return obj;
end

function EasingGraph.drawBackground(self, ctx)
    ctx:stroke(0)
    ctx:noFill();
    ctx:rect(0,0,self.frame.width, self.frame.height)
end

function EasingGraph.drawForeground(self, ctx)
    local apath = BLPath()
    apath:moveTo(4,200-4)
    for t = 0, self.duration, 0.1 do
        local value = self.interpolator(t, self.startValue, self.changeInValue, self.duration)
        local x = map(t, 0, self.duration, 4, 200-4)
        local y = map(value, self.startValue, self.startValue+self.changeInValue, 200-4, 4)
        apath:lineTo(x,y)
    end
    ctx:stroke(0)
    ctx:strokeWidth(4)
    ctx:strokePath(apath)

    -- draw title
    if self.title then
    ctx:fill(0)
    ctx:textSize(24)
    ctx:text(self.title, 4, self.frame.height-6)
    end
end

return EasingGraph
