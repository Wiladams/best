--[[
    A slider is a graphic that provides for some constrained motion.  The constraint
    is expressed in the form of a MotionConstraint object.

    There is a 'track', which represents the motion a 'thumb' will travel over
    during user interaction.  The track and constraint go hand in hand, as the track
    is a representation of the MotionConstraint.

    The constraint can express two dimensions and not just one.
]]
local GraphicGroup = require("GraphicGroup")
local maths = require("maths")

local map = maths.map
local constrain = maths.constrain


--[[
    Basic slider class
]]

local Slider = {
    trackThickness = 4;
}
setmetatable(Slider, {
    __index = GraphicGroup;
})
local Slider_mt = {
    __index = Slider;
}

function Slider.new(self, obj)
    obj = GraphicGroup:new(obj)

    obj.lowValue = obj.lowValue or 0
    obj.highValue = obj.highValue or 255
    obj.position = obj.position or {x=0,y=0};
    obj.dragging = false;

    setmetatable(obj,Slider_mt)

    obj:setPosition(obj.position)

    return obj
end


function Slider.drawBackground(self, ctx)
    -- draw line between endpoints
    ctx:strokeWidth(Slider.trackThickness)
    ctx:stroke(120)
    ctx:line(self.startPoint.x, self.startPoint.y, self.endPoint.x, self.endPoint.y)

    -- draw a couple of circles at the ends
    ctx:noStroke()
    ctx:fill(10)
    ctx:circle(self.startPoint.x, self.startPoint.y, (Slider.trackThickness/2)+2)
    ctx:circle(self.endPoint.x, self.endPoint.y, (Slider.trackThickness/2)+2)
end

function Slider.drawForeground(self, ctx)
    self.thumb:draw(ctx)
end

--[[
    Returns a number in range  [0..1]
]]
function Slider.getPosition(self)
    return self.position;
    --return map(self.thumb.frame.x, self.constraint.minX, self.constraint.maxX, 0, 1)
end

function Slider.setPosition(self, pos)
    self.position.x = constrain(pos.x, 0,1)
    self.position.y = constrain(pos.y, 0,1)
    
    local locY = map(pos.y, 0,1, self.constraint.minY, self.constraint.maxY)
    local locX = map(pos.x, 0,1, self.constraint.minX, self.constraint.maxX)
  

    self.thumb:moveTo(locX, locY)

    self.lastLocation = {x = self.thumb.frame.x, y = self.thumb.frame.y}
end

function Slider.getValue(self)
    return map(self:getPosition(), 0, 1, self.lowValue, self.highValue);
end

function Slider.changeThumbLocation(self, change)
    local movement = self.constraint:tryChange(self.thumb.frame, change)
--print("movement: ", movement.dx, movement.dy)

    self.thumb:moveBy(movement.dx, movement.dy)
    
    local position = self.constraint:calcPosition(self.thumb.frame)
    self.position = position;

    -- tell anyone who's interested that something has changed
    signalAll(self, self, "changeposition")
end

function Slider.mouseDown(self, event)
    self.dragging = true;
    self.lastLocation = {x=event.x, y=event.y};
end

function Slider.mouseUp(self, event)
    self.dragging = false;
end

function Slider.mouseMove(self, event)
    --print("Slider.mouseMove: ", event.x, event.y, self.dragging)

    if self.dragging then 
        local change = {
            dy = event.y - self.lastLocation.y;
            dx = event.x - self.lastLocation.x;    
        }
        self:changeThumbLocation(change)
    end
    self.lastLocation = {x = event.x, y = event.y}
end

return Slider
