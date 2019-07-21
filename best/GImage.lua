-- A graphic image
-- Basically has a size and image
require("blend2d")

local GImage = {}
local GImage_mt = {
    __index = GImage;
}


function GImage.new(self, obj)
    if not obj then return nil end

    -- must have width, height, and image
    if not obj.image then
        return nil, 'must specify at least image'
    end

    --print("obj.frame: ", obj.frame.x, obj.frame.y, obj.frame.width, obj.frame.height)

    obj.frame = obj.frame or {x=0,y=0,width=obj.image:size().w, height = obj.image:size().h}
    obj.imageArea = obj.imageArea or BLRectI({0,0,obj.image:size().w, obj.image:size().h})
    obj.dstFrame = obj.dstFrame or BLRect({0,0,obj.frame.width, obj.frame.height})

    setmetatable(obj, GImage_mt)

    return obj;
end

function GImage.createFromFile(self, filename)
    local img, err = BLImageCodec:readImageFromFile(filename)
    if not img then
        return nil, err
    end

    return GImage:new({
        image = img, 
        frame = {x=0,y=0,width=img:size().w, height=img:size().h}
    })
end

--[[
    Sets where the image will be displayed within the context
    of the graphics context
]]
function GImage.setFrame(self, x,y,width,height)
    self.frame = {x = x, y = y, width = width, height = height}
    self.dstFrame = BLRect({x,y,width, height})
    
    return self;
end

function GImage.moveTo(self, x, y)
    self.frame.x = x;
    self.frame.y = y;
    self.dstFrame.x = x;
    self.dstFrame.y = y;
end

function GImage.draw(self, ctx)
    --print("GImage.draw: ", tostring(self.dstFrame), self.image, tostring(self.imageArea))
    ctx:stretchBlt(self.dstFrame, self.image, self.imageArea)
    --ctx:blit(self.image)
end


function GImage.subImage(self, x,y,w,h)
    local imageArea = BLRectI(x,y,w,h)
    GImage:new({image = self.image, width = w, height = h, imageArea = imageArea})
end

return GImage
