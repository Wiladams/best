local maths = require("maths")
local map = maths.map
local log10 = math.log10

local GLogLines = {
    lineIncrement = 0.5;
    offsetIncrement = 0.05;     -- increase/decrease this amount for speed
    offsetAmount = 0;  
}
local GLogLines_mt = {
    __index = GLogLines;
}


function GLogLines.new(self, obj)
    obj = obj or {
        lineIncrement = self.lineIncrement;
        offsetIncrement = self.offsetIncrement;     -- increase/decrease this amount for speed
        offsetAmount = self.offsetAmount;    
    }
    obj.lineIncrement = obj.lineIncrement or self.lineIncrement;
    obj.offsetIncrement = obj.offsetIncrement or self.offsetIncrement;
    obj.offsetAmount = obj.offsetAmount or 0;

    setmetatable(obj, GLogLines_mt)

    return obj;
end

function GLogLines.draw(self, ctx)
    ctx:stroke(255,0,0)
    local x1 = 0
    local x2 = self.frame.width

    if self.offsetAmount < self.offsetIncrement then
        self.offsetAmount = self.lineIncrement
    end

    for i=1,10, self.lineIncrement do
        local y = map(log10(i+self.offsetAmount), 0, 1, self.frame.height, self.frame.height/2)
        ctx:line(x1, y, x2, y)
    end

    -- shift line a little bit
    self.offsetAmount = self.offsetAmount - self.offsetIncrement
end

return GLogLines
