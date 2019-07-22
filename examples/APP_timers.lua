

local functor = require("functor")
local GraphicGroup = require("GraphicGroup")

local floor = math.floor




local TimeDisplay = {}
setmetatable(TimeDisplay, {
    __index = GraphicGroup
})
local TimeDisplay_mt = {
    __index = TimeDisplay;
}

function TimeDisplay.new(self, obj)
    local obj = GraphicGroup:new(obj)
    obj.interval = obj.interval or 1
    obj.duration = 0

    setmetatable(obj, TimeDisplay_mt)
    periodic(obj.interval, functor(obj.onTick, obj))

    return obj
end

function TimeDisplay.draw(self, ctx)
    local seconds = self.duration / 1000
    local hours = math.floor(seconds / (60 * 60))
    local minutes = math.floor((seconds - (hours * 60*60)) / 60)
    local clockseconds = seconds - (hours * 3600) - (minutes * 60)
    local secondsfrac = clockseconds - floor(clockseconds)

    --print(seconds, hours, minutes, clockseconds)

    ctx:fill(255)
    ctx:stroke(0)
    ctx:strokeWidth(2)
    ctx:rect(0,0,self.frame.width, self.frame.height)

    -- draw the text
    ctx:noStroke();
    ctx:fill(0)
    ctx:textSize(36)
    local timestr = string.format("%02d:%02d:%2.2f", hours, minutes, clockseconds)
    ctx:text(timestr, 4, self.frame.height - 4)
end

function TimeDisplay.onTick(self, seconds)
    self.duration = self.duration + self.interval;
end


function app(params)

    local winparams = {frame = {x=0,y=0, width = 1024, height = 800}}
    local win1 = WMCreateWindow(winparams)
 
    function win1.drawBackground(self, ctx)
        ctx:fill(255);
        ctx:fillAll()
    end

    local margin = 10
    local fwidth = 240;
    local fheight = 48;
    local fgap = 10;

    local timers = {}
    for i=1,4 do 
        table.insert(timers, TimeDisplay:new({interval = 1000/10, frame={x=margin+(i-1)*(fwidth+fgap),y=margin,width=fwidth,height=fheight}}))
    end
    for i=1,4 do 
        table.insert(timers, TimeDisplay:new({interval = 1000/4, frame={x=margin+(i-1)*(fwidth+fgap),y=margin+1*(fheight+fgap),width=fwidth,height=fheight}}))
    end
    for i=1,4 do 
        table.insert(timers, TimeDisplay:new({interval = 1000/2, frame={x=margin+(i-1)*(fwidth+fgap),y=margin+2*(fheight+fgap),width=fwidth,height=fheight}}))
    end
    for i=1,4 do 
        table.insert(timers, TimeDisplay:new({interval = 1000/1, frame={x=margin+(i-1)*(fwidth+fgap),y=margin+3*(fheight+fgap),width=fwidth,height=fheight}}))
    end

    for _, t in ipairs(timers) do
        win1:add(t)
    end

    win1:show()


    local function drawproc()
        win1:draw()
    end

    periodic(1000/30, drawproc)
end

require("windowapp")


return app