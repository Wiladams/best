
local ffi = require("ffi")
local C = ffi.C

local GraphicGroup = require("GraphicGroup")

local Slider = require("slider")
local MotionConstraint = require("MotionConstraint")
local SliderThumb = require("SliderThumb")
local sliding = require("sliding")


local GImage = require("GImage")

local BView = require("BView")
local functor = require("functor")
local ImageScaleView = require("ImageScaleView")


function app()
    local srcImage, err = GImage:createFromFile("resources\\baboon.png")
    srcImage:moveTo(40,40)

    local winFrame = {frame = {x=40,y=40, width = 1280, height = 1024}}
    local win1 = WMCreateWindow(winFrame)

    function win1.drawBackground(self, ctx)
        ctx:fill(0xC3)
        ctx:rect(0,0,self.frame.width, self.frame.height)

        -- draw a sunken line at 580
        ctx:strokeWidth(2)
        ctx:stroke(0x7f)
        ctx:line(4,580,self.frame.width-4, 580)
        
        ctx:stroke(0xF3)
        ctx:line(4, 582, self.frame.width-4, 582)
        ctx:line(self.frame.width-4, 580, self.frame.width-4,582)
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
    

    local boxSlider = Slider:create{
        startPoint ={x=viewbox.frame.x+viewbox.frame.width+12,y=viewbox.frame.y}, 
        endPoint={x=viewbox.frame.x+viewbox.frame.width+12;y=viewbox.frame.y+viewbox.frame.height}};

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

require("windowapp")

return app
