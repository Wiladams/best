package.path = "../?.lua;"..package.path;


local Slider = require("slider")
local MotionConstraint = require("MotionConstraint")
local SliderThumb = require("SliderThumb")
local GImage = require("best.GImage")

local BView = require("BView")
local page = require("FontListPage")
local functor = require("functor")


local function app()
    local srcImage, err = GImage:createFromFile("resources\\baboon.png")
    --print("srcImage: ", srcImage, err)
    srcImage:moveTo(40,40)

    local winFrame = {frame = {x=40,y=40, width = 1280, height = 1024}}
    local win1 = WMCreateWindow(winFrame)

    function win1.drawBackground(self, ctx)
        ctx:fill(255)
        ctx:rect(0,0,self.frame.width, self.frame.height)
    end

    function win1.drawForeground(self, ctx)
        --print("win1.drawForeground")
        ctx:stretchBlt (srcImage.dstFrame, srcImage.image, srcImage.imageArea)

        print("bResult: ", bResult)
    end

    --win1:add(srcImage)

    local function drawproc()
        win1:draw()
    end

    periodic(1000/1, drawproc)
end


return app
