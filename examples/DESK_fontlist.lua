--package.path = "../?.lua;"..package.path;

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
local MotionConstraint = require("MotionConstraint")
local SliderThumb = require("SliderThumb")

local BView = require("BView")
local page = require("FontListPage")
local functor = require("functor")
local Checkerboard = require("CheckerGraphic")
local vkeys = require("vkeys")
local ContextRecorder = require("ContextRecorder")

local function handleKeyEvent(event)
    if event.keyCode == vkeys.VK_ESCAPE then
        halt()
    end
end

local function app()
    
    -- start by creating a window
    local winFrame = {frame = {x=40,y=40, width = 800, height = 600}}
    local win1 = WMCreateWindow(winFrame)

    -- Now start to compose window contents
    -- create the window and its contents
    -- this should go into a seprate 'app'
    local pageSize = page:getPreferredSize()
    local p = page:new({frame = {x=0, y = 0, width = pageSize.width, height = pageSize.height}})
    local view = BView:new({
        frame = {x=40,y=40,width = pageSize.width, height = win1.frame.height-80},
        page = p,
    })

    function win1.drawBackground(self, ctx)
        ctx:fill(255)
        ctx:rect(0,0,self.frame.width, self.frame.height)
    end

    win1:add(view)
 
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


    --win1:add(hSlider)
    win1:add(vSlider)

    local function handleChange(a,b,c)
        print("handleChange: ",a,b,c)
    end

    on(vSlider, functor(view.handleVerticalPositionChange, view))


    win1:show()

    local function drawproc()
         win1:draw()
    end

    local recorder = ContextRecorder:new({
        frameRate = 10;
        maxFrames = 100;
        drawingContext = win1.drawingContext;
        basename = "output\\fontlist";
    })
    --recorder:record();

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
    WMSetWallpaper(wp)

    app()
end

function startup()
    spawn(main)
end

return main