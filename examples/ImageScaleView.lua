local ffi = require("ffi")
local C = ffi.C 

-- Take and image and show it smaller and larger
-- using a specified filter technique
local enum = require("enum")
local DrawingContext = require("DrawingContext")

local BLImageScaleFilter = enum {
    BL_IMAGE_SCALE_FILTER_NONE = 0,
    BL_IMAGE_SCALE_FILTER_NEAREST = 1,
    BL_IMAGE_SCALE_FILTER_BILINEAR = 2,
    BL_IMAGE_SCALE_FILTER_BICUBIC = 3,
    BL_IMAGE_SCALE_FILTER_BELL = 4,
    BL_IMAGE_SCALE_FILTER_GAUSS = 5,
    BL_IMAGE_SCALE_FILTER_HERMITE = 6,
    BL_IMAGE_SCALE_FILTER_HANNING = 7,
    BL_IMAGE_SCALE_FILTER_CATROM = 8,
    BL_IMAGE_SCALE_FILTER_BESSEL = 9,
    BL_IMAGE_SCALE_FILTER_SINC = 10,
    BL_IMAGE_SCALE_FILTER_LANCZOS = 11,
    BL_IMAGE_SCALE_FILTER_BLACKMAN = 12,
    BL_IMAGE_SCALE_FILTER_MITCHELL = 13,
    BL_IMAGE_SCALE_FILTER_USER = 14,
    BL_IMAGE_SCALE_FILTER_COUNT = 15
};


local ImageScaleView = {}
local ImageScaleView_mt = {
    __index = ImageScaleView;
}

function ImageScaleView.new(self, obj)
    if not obj then return nil, "must specify image" end
    if not obj.image then return nil, "must specify image" end

    obj.frame = obj.frame or {x=0,y=0,width = 1024, height = 768};
    obj.filter = obj.filter or C.BL_IMAGE_SCALE_FILTER_NEAREST
    obj.filterName = BLImageScaleFilter[obj.filter]

    --print("ImageScaleView.frame: ", obj.frame.x, obj.frame.y, obj.frame.width, obj.frame.height)

    -- Create two images which will receive the smaller, and larger 
    -- resampled images
    obj.smallerImage = BLImage(256, 256)
    obj.largerImage = BLImage(768, 768)

    obj.smallMidX = (obj.frame.width - obj.largerImage:size().w)/2

    -- create smaller image
    local success = obj.image:resample(obj.smallerImage, obj.smallerImage:size(), obj.filter, obj.options)
 
    -- create larger image
    local success = obj.image:resample(obj.largerImage, obj.largerImage:size(), obj.filter, obj.options)

    setmetatable(obj, ImageScaleView_mt)

    return obj;
end

function ImageScaleView.drawBackground(self, ctx)
    -- draw caption indicating what kind of filtering we're doing
    -- draw background with neutral gray
    ctx:stroke(0)
    ctx:fill(0xC0);
    ctx:rect(0,0,self.frame.width, self.frame.height)

    -- caption of filter name
    ctx:fill(0);
    ctx:textFont("segoe ui");
    ctx:textSize(16);
    ctx:text(self.filterName, 20, 40);
end

function ImageScaleView.draw(self, ctx)
    self:drawBackground(ctx)

    -- draw the smaller image
    ctx:blit(self.smallerImage, self.smallMidX-128, (self.frame.height/2)-128)

    -- draw the larger image
    ctx:blit(self.largerImage, self.frame.width-self.largerImage:size().w, 0)
end


return ImageScaleView

