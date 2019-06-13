

local SliderThumb = {
    thumbRadius = 8;
    thumbThickness = 24
}
local SliderThumb_mt = {
    __index = SliderThumb;
}


function SliderThumb.new(self, obj)
    obj = obj or {
        frame = {x=0,y=0,width = SliderThumb.thumThickness,height=SliderThumb.thumbThickness};
        thumbColor = color(0xff, 0,0);
        radius = SliderThumb.thumbRadius;
    }
    obj.radius = obj.radius or SliderThumb.thumbRadius
    obj.thumbColor = obj.thumbColor or color(0xC0)
    obj.shape = BLRoundRect(0, 0, obj.frame.width, obj.frame.height, obj.radius, obj.radius);

    setmetatable(obj, SliderThumb_mt)

    return obj;
end

-- a lozinger rounded rect
function SliderThumb.draw(self, ctx)
    ctx:fill(self.thumbColor)
    ctx:fillRoundRect(self.shape)
end

function SliderThumb.moveBy(self, dx, dy)
    self:moveTo(self.frame.x+dx, self.frame.y+dy)
end

function SliderThumb.moveTo(self, x, y)
    self.frame.x = x;
    self.frame.y = y;
end

return SliderThumb 