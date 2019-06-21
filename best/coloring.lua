require("blend2d")

--[[
	Convert to luminance using ITU-R Recommendation BT.709 (CCIR Rec. 709)
	This is the one that matches modern HDTV and LCD monitors
    This is a simple 'grayscale' conversion

    You can pass parameters in one of two ways
    type(r) == table then
    red     = r[1]
    green   = r[2]
    blue    = r[3]
--]]
local function lumaBT709(r,g,b)

    if type(r) == "table" then
        local lum = (0.2125 * r[1]) + (0.7154 * r[2]) + (0.0721 * r[3])
        return lum
    end

    lum = (0.2125 * r) + (0.7154 * g) + (0.0721 * b)

	return lum;
end

local function color(...)
    --function DrawingContext.color(self, ...)
        local nargs = select('#', ...)
    
        -- There can be 1, 2, 3, or 4, arguments
        --	print("Color.new - ", nargs)
        
        local r = 0
        local g = 0
        local b = 0
        local a = 255
        
        if (nargs == 1) then
                r = select(1,...)
                g = r
                b = r
                a = 255;
        elseif nargs == 2 then
                r = select(1,...)
                g = r
                b = r
                a = select(2,...)
        elseif nargs == 3 then
                r = select(1,...)
                g = select(2,...)
                b = select(3,...)
                a = 255
        elseif nargs == 4 then
            r = select(1,...)
            g = select(2,...)
            b = select(3,...)
            a = select(4,...)
        end
        
        local pix = BLRgba32()
    --print("r,g,b: ", r,g,b)
        pix.r = r
        pix.g = g
        pix.b = b 
        pix.a = a
    
        return pix;
    end

return {
    luma = lumaBT709;
    color = color;
}