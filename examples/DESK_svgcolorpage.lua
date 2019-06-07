--[[
    This is an example of a startup for bestdesk.exe
    The general idea is, you want to specify how the desktop
    looks upon starting the application.

    So, this is part configuration, part app playground.  Really
    there should be specifically named desktop configurations, and 
    all the app specifics should be in "APP_specific.lua" files, which 
    the configuration simply loads.

    Of particular note, there MUST be a globaly 'startup()' function.
    This is what bestdesk.exe is expecting to see, and will use it 
    as a startup.  None of the BEST environment is available to the 
    configuration until this startup function has been called.

    In particular, none of the scheduler functions are available.
]]

local Slider = require("slider")
local BView = require("BView")
local page = require("GSVGColorPage")
local functor = require("functor")
local Checkerboard = require("CheckerGraphic")
local radians = math.rad
local vkeys = require("vkeys")


local function handleKeyEvent(event)
    if event.keyCode == vkeys.VK_ESCAPE then
        halt()
    end
end

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

local function main()
    -- Establish event handler for typed keys
    -- this will occur at a desktop level, regardless
    -- of how keys are handled within individual windows
    on("gap_keytyped", handleKeyEvent)
    
    local dSize = WMGetDesktopSize()

    -- Create a checkerboard pattern to use as the
    -- desktop wallpaper
    local wp = Checkerboard:new({
        frame={x=0,y=0,width=dSize.width,height=dSize.height},
        --columns = 64,
        --rows = 64
    })
    --WMSetWallpaper(wp)

    app()
end

function startup()
    spawn(main)
end

return main