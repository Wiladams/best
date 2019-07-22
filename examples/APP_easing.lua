--[[
    APP_easing

    Display the various easing/interpolation functions
]]

local vkeys = require("vkeys")
local GraphicGroup = require("GraphicGroup")
local functor = require("functor")
local easing = require("easing")
local radians = math.rad
local maths = require("maths")
local map = maths.map

local EasingGraph = require("GEasingGraph")
local BPanel = require("BPage")
local BView = require("BView")
local sliding = require("sliding")

local easings = {
    {row = 1, column = 1, title = "easeLinear", interpolator = easing.easeLinear};

    {row = 2, column = 1, title = "easeInQuad", interpolator = easing.easeInQuad};
    {row = 2, column = 2, title = "easeOutQuad", interpolator = easing.easeOutQuad};
    {row = 2, column = 3, title = "easeInOutQuad", interpolator = easing.easeInOutQuad};

    {row = 3, column = 1, title = "easeInCubic", interpolator = easing.easeInCubic};
    {row = 3, column = 2, title = "easeOutCubic", interpolator = easing.easeOutCubic};
    {row = 3, column = 3, title = "easeInOutCubic", interpolator = easing.easeInOutCubic};

    {row = 4, column = 1, title = "easeInQuart", interpolator = easing.easeInQuart};
    {row = 4, column = 2, title = "easeOutQuart", interpolator = easing.easeOutQuart};
    {row = 4, column = 3, title = "easeInOutQuart", interpolator = easing.easeInOutQuart};

    {row = 5, column = 1, title = "easeInQuint", interpolator = easing.easeInQuint};
    {row = 5, column = 2, title = "easeOutQuint", interpolator = easing.easeOutQuint};
    {row = 5, column = 3, title = "easeInOutQuint", interpolator = easing.easeInOutQuint};

    {row = 6, column = 1, title = "easeInSine", interpolator = easing.easeInSine};
    {row = 6, column = 2, title = "easeOutSine", interpolator = easing.easeOutSine};
    {row = 6, column = 3, title = "easeInOutSine", interpolator = easing.easeInOutSine};

    {row = 7, column = 1, title = "easeInExpo", interpolator = easing.easeInExpo};
    {row = 7, column = 2, title = "easeOutExpo", interpolator = easing.easeOutExpo};
    {row = 7, column = 3, title = "easeInOutExpo", interpolator = easing.easeInOutExpo};

    {row = 8, column = 1, title = "easeInCirc", interpolator = easing.easeInCirc};
    {row = 8, column = 2, title = "easeOutCirc", interpolator = easing.easeOutCirc};
    {row = 8, column = 3, title = "easeInOutCirc", interpolator = easing.easeInOutCirc};

}

function app(params)

    local winparams = {frame = {x=0,y=0, width = 800, height = 1024}}
    local win1 = WMCreateWindow(winparams)
 
    function win1.drawBackground(self, ctx)
        ctx:fill(255);
        ctx:fillAll()
    end

    local panel = BPanel:new({frame={x=0, y=0,width=0,height=0}})

    -- create the easing graphics
    local xmargin = 10;
    local ymargin = 10;
    local cellWidth = 200;
    local cellHeight = 240;
    local widthGap = 40;
    local heightGap = 40;

    for _, entry in ipairs(easings) do 
        local x = xmargin + (entry.column-1) * (cellWidth + widthGap)
        local y = ymargin + (entry.row-1) * (cellHeight + heightGap)
        entry.frame = {x=x, y=y, width = cellWidth, height=cellHeight}
        --print(x,y,entry.frame.width, entry.frame.height)
        local easing = EasingGraph:new(entry)
        panel:addChild(easing)
    end

    local psize = panel:getPreferredSize()
    --print("Panel Size: ", psize.width, psize.height)

    local view = BView:new({
        frame={x=8,y=8, width = 700, height = 800},
        page = panel
    })

    local boxSlider = sliding.createSlider({
        startPoint = {x=view.frame.x+view.frame.width+10,y=view.frame.y};
        endPoint = {x=view.frame.x+view.frame.width+10, y=view.frame.y+view.frame.height};
        thickness = 24;

        thumb = {
            length = 60;
            thumbColor = 0x70;
        }
    })

    -- connect slider to viewbox
    on(boxSlider, functor(view.handleVerticalPositionChange, view))

    win1:add(view)
    win1:add(boxSlider)

    win1:show()

---[[
    while true do 
        win1:draw()
        yield();
    end
--]]

    local function drawproc()
         win1:draw()
    end

    --periodic(1000/20, drawproc)
end



require("windowapp")


return app
