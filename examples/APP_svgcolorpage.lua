local Slider = require("slider")
local BView = require("BView")
local page = require("GSVGColorPage")


local function app()
    -- create the window and its contents
    -- this could be done as a separate app, but
    -- we'll do it all here to show how a quick desktop
    -- can be created.
    local pageSize = page:getPreferredSize()
--print("pageSize: ", pageSize.width, pageSize.height)
    local p = page:new({frame = {x=0, y = 0, width = pageSize.width, height = pageSize.height}})
    local view = BView:new({
        frame = {x=40,y=40,width = pageSize.width/2, height = pageSize.height/2},
        page = p,
    })

    local winFrame = {frame = {x=40,y=40, width = 1024, height = 768}}
    local win1 = WMCreateWindow(winFrame)
    function win1.drawBackground(self, ctx)
        ctx:fill(255)
        ctx:rect(0,0,self.frame.width, self.frame.height)
    end

    win1:add(view)
 
    -- create a slider
    local thumbHeight = 24
    local halfThumbHeight = thumbHeight/2
    local thumbWidth = 60
    local thumbRadius = 4;

    local hSlider = Slider:new({
        title = "horizontal", 
        bgColor = color(0xff,0,0), 
        position=0, 
        thumbRect = BLRoundRect(0,12-halfThumbHeight,thumbWidth,thumbHeight,thumbRadius, thumbRadius),
        frame={x=view.frame.x, y=view.frame.y+view.frame.height+24, width=view.frame.width, height=20}
    })

    --local verticalSlider = Slider:new({title = "vertical", bgColor = color(0,0xff,0), position=0.5, frame={x=20, y=68, width=240, height=20}})



    win1:add(hSlider)
    --win1:add(vSlider)

    on(hSlider, functor(view.handlePositionChange, view, hSlider))
    --on(obj.greenSlider, functor(obj.handleComponentChange, obj))

    win1:show()

    local function drawproc()
         win1:draw()
    end

    periodic(1000/20, drawproc)
end