local maths = require("maths")
local map = maths.map
local max = math.max

--[[
    The BView has a couple of primary
    purposes.
    1) Be a clipping region for an underlying graphic
    2) Be a drawing transformation for the underlying graphic

    The clipping region is taken care of by simply having a .frame
    property.  The higher level (window, or graphicgroup) will automatically
    clip, and translate to this coordinate system.

    Beyond that, the view is essentially a two dimensional slider thumb.
    You can alter it's base transformation using setPosition(posX, posY)

    The position varies between 0 and 1 in both directions.

    The view must know how to map from the position value to the appropriate
    transformation values.  This is done based on the size and potential
    location of the view relative to the size and location of the page.
]]
local BView = {}
local BView_mt = {
    __index = BView
}

function BView.new(self, obj)
    obj = obj or {}
    setmetatable(obj, BView_mt)
    obj.Tx = 0;
    obj.Ty = 0;
    
    return obj
end


function BView.calcTransform(self, px, py)
    local pageSize = self.page:getPreferredSize()
    local x = map(px, 0,1, 0, max(0, pageSize.width - self.frame.width))
    local y = map(py, 0,1, 0, max(0, pageSize.height - self.frame.height))

    --print("BView.calcTransform: ", x, y)

    return x, y
end

function BView.setPosition(self, px, py)
    --print("BView.setPosition: ", px, py)
    self.Tx, self.Ty = self:calcTransform(px, py)
end

function BView.handleVerticalPositionChange(self, slider)
    --print("BView.handleVerticalPositionChange: ", slider, slider:getPosition())

    local pos = {x=0,y=0}
    if slider then
        pos = slider:getPosition()
    end

    self:setPosition(pos.x, pos.y)
end

function BView.handleHorizontalPositionChange(self, slider)
    --print("BView.handleHorizontalPositionChange: ", slider)
    local ypos = 0;
    local xpos = 0;
    
    if slider then
        xpos = slider:getPosition()
    end

    self:setPosition(xpos, ypos)
end

function BView.draw(self, ctx)
    -- draw ourselves a border for debugging
    ctx:noFill()
    ctx:stroke(255,0,0)
    ctx:strokeWidth(1)
    ctx:rect(0,0,self.frame.width, self.frame.height)

    -- Now save state and do transform
    ctx:save()
    ctx:translate(-self.Tx, -self.Ty)
    self.page:draw(ctx)
    ctx:restore()
end

return BView
