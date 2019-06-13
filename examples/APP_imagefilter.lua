
local ffi = require("ffi")
local C = ffi.C

local GraphicGroup = require("GraphicGroup")

local Slider = require("slider")
local MotionConstraint = require("MotionConstraint")
local SliderThumb = require("SliderThumb")
local GImage = require("GImage")

local BView = require("BView")
local functor = require("functor")
local ImageScaleView = require("ImageScaleView")



local function VerticalSlider(view)
    -- create a slider
    local vSliderThumb = SliderThumb:new({
        frame = {x=0,y=0,width=24,height=60};
    })


    local vSliderFrame = {x=view.frame.x+view.frame.width + 4, y=view.frame.y, width=vSliderThumb.frame.width, height=view.frame.height}
    local vSliderConstraint = MotionConstraint:new({
        minX = 0, maxX = 0,
        minY = 0, maxY = vSliderFrame.height-vSliderThumb.frame.height})

    local vSliderParams = {
        title = "vertical", 
        bgColor = color(0xff,0,0); 
        position={x=0,y=0}; 
        startPoint = {x=vSliderFrame.width/2, y=0};
        endPoint = {x=vSliderFrame.width/2, y = vSliderFrame.height};
        frame= vSliderFrame;
        constraint = vSliderConstraint;
        thumb = vSliderThumb;
    }

    local vSlider = Slider:new(vSliderParams)

    return vSlider
end

local function app()
    local srcImage, err = GImage:createFromFile("resources\\baboon.png")
    srcImage:moveTo(40,40)

    local winFrame = {frame = {x=40,y=40, width = 1280, height = 1400}}
    local win1 = WMCreateWindow(winFrame)

    function win1.drawBackground(self, ctx)
        ctx:fill(255)
        ctx:rect(0,0,self.frame.width, self.frame.height)
    end

    -- Create filter views
    local filterCount = 13
    local filterPage = GraphicGroup:new({
        frame = {x=0,y=0,width = 1200,height=768*filterCount}
    })

    for i=1,filterCount do
        local filter = ImageScaleView:new({
            frame = {x=0,y=(i-1)*768, width=1200, height=768 };
            image = srcImage.image;
            filter = i;
        })
        filterPage:add(filter)
    end
    
    function filterPage.getPreferredSize(self)
        return {width = self.frame.width, height = self.frame.height}
    end


    local viewbox = BView:new({
        frame = {x=20, y = 600, width =1200, height =780};
        page = filterPage;
    })
    
    local boxSlider = VerticalSlider(viewbox)

    win1:add(srcImage);
    win1:add(viewbox);
    win1:add(boxSlider);

    -- connect slider to viewbox
    on(boxSlider, functor(viewbox.handleVerticalPositionChange, viewbox))


    local function drawproc()
        win1:draw()
    end

    periodic(1000/15, drawproc)
end


return app
