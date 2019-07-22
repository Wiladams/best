

local PanelAnimator = require("PanelAnimator")



local function app(params)

    -- create a simple windows
    local win1 = WMCreateWindow({frame = {x=10,y=10,width=800,height=800}})
    
    function win1.drawBackground(self, ctx)
        ctx:fill(0xff)
        ctx:rect(0,0,self.frame.width, self.frame.height)

        gstyle:DrawSunkenRect(ctx, 10, 240, 160, 40)
        gstyle:DrawRaisedRect(ctx, 200, 240, 160, 40)
    end

     



    win1:show();
    
    local function drawproc()
        win1:draw()
    end

    periodic(1000/10, drawproc)
end

--[[
    quick and dirty get app up on the window
--]]
-- quit when user presses escape
local function handleKeyEvent(event)
    if event.keyCode == vkeys.VK_ESCAPE then
        halt()
    end
end


local function main()
    on("gap_keytyped", handleKeyEvent)

    app()
end

--[[
    If we're being used as a standalone app, then 
    this setup function is called.
]]
print("has startup: ", startup)
if not startup then
    function startup()
        print("STARTUP")
        spawn(main)
    end
end

return app