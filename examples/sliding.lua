local abs = math.abs

local Slider = require("best.slider")
local MotionConstraint = require("MotionConstraint")
local SliderThumb = require("SliderThumb")

--[[
    createSlider({
        startPoint = {x=10,y=4};
        endPoint = {x=10,y=20};
        thickness = 24;

        thumb = {
            length = 60;
            thumbColor = 0x70;
        }
    })
]]
local function createSlider(params)
    if not params.startPoint or not params.endPoint then 
        return nil, "must specify startPoint and endPoint"
    end

    local thickness = params.thickness or 24
    local startPoint = params.startPoint
    local endPoint = params.endPoint
    local dx = params.endPoint.x - params.startPoint.x;
    local dy = params.endPoint.y - params.startPoint.y;

    local orientation = "vertical"
    if abs(dx) > abs(dy) then
        orientation = "horizontal"
    end


    -- create the thumb
    local thumbParams = params.thumb or {}
    thumbParams.length  = thumbParams.length or 60;
    thumbParams.thumbColor = thumbParams.thumbColor or 0x70;
    if orientation == "vertical" then
        thumbParams.frame = {x=0;y=0,width=thickness,height=thumbParams.length};
    else
        thumbParams.frame = {x=0;y=0,width=thumbParams.length,height=thickness};
    end

    local sliderThumb = SliderThumb:new(thumbParams)


    -- Now figure out the frame of the entire slider
    local sliderFrame
    local sliderContraint
    local sliderStart
    local sliderEnd

    if orientation == "vertical" then
        sliderFrame = {x=startPoint.x-thickness/2, y=startPoint.y, width = thickness, height=abs(dy)}
        sliderConstraint = MotionConstraint:new({
            minX = 0, maxX = 0,
            minY = 0, maxY = sliderFrame.height-sliderThumb.frame.height})
        sliderStart = {x=thickness/2, y=0};
        sliderEnd = {x=thickness/2, y = sliderFrame.height}
    else
        sliderFrame = {x=startPoint.x, y=startPoint.y-thickness/2, width = abs(dx), height=thickness}
        sliderConstraint = MotionConstraint:new({
            minX = 0, maxX = sliderFrame.width - sliderThumb.frame.width,
            minY = 0, maxY = 0})
        sliderStart = {x=0,y=thickness/2};
        sliderEnd = {x=sliderFrame.width, y=thickness/2};
    end


    local sliderParams = {
        title = params.title, 
        trackColor = params.trackColor or color(0xff,0,0); 
        position={x=0,y=0}; 
        startPoint = sliderStart;
        endPoint = sliderEnd;
        frame= sliderFrame;
        constraint = sliderConstraint;
        thumb = sliderThumb;
    }

    local slider = Slider:new(sliderParams)

    return slider
end

return {
    createSlider = createSlider;
}