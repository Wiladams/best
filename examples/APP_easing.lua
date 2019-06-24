--[[
    APP_easing

    Display the various easing/interpolation functions
]]

local GraphicGroup = require("GraphicGroup")
local easing = require("easing")
local radians = math.rad
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
end

local function app(params)

    local winparams = {frame = {x=0,y=0, width = 800, height = 2000}}
    local win1 = WMCreateWindow(winparams)
 
    function win1.drawBackground(self, ctx)
        ctx:fill(255);
        ctx:fillAll()
    end

    local easing1 = EasingGraph:new({frame = {x=10,y=10,width=200,height=240}})

    local easing2 = EasingGraph:new({interpolator = easing.easeInQuad, frame = {x=10,y=300,width=200,height=240}})
    local easing3 = EasingGraph:new({interpolator = easing.easeOutQuad, frame = {x=240,y=300,width=200,height=240}})
    local easing4 = EasingGraph:new({interpolator = easing.easeInOutQuad, frame = {x=480,y=300,width=200,height=240}})

    local easing5 = EasingGraph:new({interpolator = easing.easeInCubic, frame = {x=10,y=590,width=200,height=240}})
    local easing6 = EasingGraph:new({interpolator = easing.easeOutCubic, frame = {x=240,y=590,width=200,height=240}})
    local easing7 = EasingGraph:new({interpolator = easing.easeInOutCubic, frame = {x=480,y=590,width=200,height=240}})

    local easing8 = EasingGraph:new({interpolator = easing.easeInQuart, frame = {x=10,y=880,width=200,height=240}})
    local easing9 = EasingGraph:new({interpolator = easing.easeOutQuart, frame = {x=240,y=880,width=200,height=240}})
    local easing10 = EasingGraph:new({interpolator = easing.easeInOutQuart, frame = {x=480,y=880,width=200,height=240}})

    local easing11 = EasingGraph:new({interpolator = easing.easeInSine, frame = {x=10,y=1170,width=200,height=240}})
    local easing12 = EasingGraph:new({interpolator = easing.easeOutSine, frame = {x=240,y=1170,width=200,height=240}})
    local easing13 = EasingGraph:new({interpolator = easing.easeInOutSine, frame = {x=480,y=1170,width=200,height=240}})


    win1:add(easing1)

    win1:add(easing2)
    win1:add(easing3)
    win1:add(easing4)

    win1:add(easing5)
    win1:add(easing6)
    win1:add(easing7)

    win1:add(easing8)
    win1:add(easing9)
    win1:add(easing10)

    win1:add(easing11)
    win1:add(easing12)
    win1:add(easing13)

    win1:show()

---[[
    while true do 
        win1:draw()
        yield();
    end
--]]

    local function drawproc()
         win1:draw()
    end

    --periodic(1000/20, drawproc)
end

return app
