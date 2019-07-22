--local ffi = require("ffi")
--require("blend2d")
local GraphicGroup = require("GraphicGroup")

--local BLRect = ffi.typeof("struct BLRect")

local BPage = {}
setmetatable(BPage, {
    __index = GraphicGroup
})
local BPage_mt = {
    __index = BPage
}

function BPage.new(self, obj)
    obj = GraphicGroup:new(obj)
    obj.bounds = obj.bounds or BLRect(0,0,0,0)

    setmetatable(obj, BPage_mt)
    
    return obj;
end

function BPage.getPreferredSize(self)
    return {width=self.bounds.w, height=self.bounds.h}
end

function BPage.addChild(self, child)
    self:add(child)
    
    -- increase the size of the bounds
    self.bounds = self.bounds + BLRect(child.frame.x, child.frame.y, child.frame.width, child.frame.height)
    self.frame = {x=self.bounds.x,y=self.bounds.y, width = self.bounds.w, height=self.bounds.h}
end

return BPage
