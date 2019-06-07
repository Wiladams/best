local maths = require("maths")

local map = maths.map
local constrain = maths.constrain


local MotionConstraint = {}
local MotionConstraint_mt = {
    __index = MotionConstraint
}

function MotionConstraint.new(self, obj)
    obj = obj or {}
    obj.minX = obj.minX or 0;
    obj.minY = obj.minY or 0;
    obj.maxX = obj.maxX or 1;
    obj.maxY = obj.maxY or 1;

    setmetatable(obj, MotionConstraint_mt)
    
    return obj;
end

function MotionConstraint.tryChange(self, subject, change)
    --print("tryChange: ", change.dx, change.dy)
    local x = constrain(subject.x+change.dx, self.minX, self.maxX)
    local y = constrain(subject.y+change.dy, self.minY, self.maxY)
    --print("tryChange, 2.0: ", x, y)

    local dx = x - subject.x;
    local dy = y - subject.y;

    return {dx = dx,dy = dy}
end

return MotionConstraint