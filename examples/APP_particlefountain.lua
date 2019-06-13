
local radians = math.rad

local function app(params)
    local graphic = require("GParticleFountain")
    local dSize = WMGetDesktopSize()

    local winparams = {frame = {x=0,y=0, width = dSize.width, height = dSize.height-40}}
    local win1 = WMCreateWindow(winparams)
 
    function win1.drawBackground(self, ctx)
        --print("win1.drawBackground")
        -- doing the clear might waste some time
        -- need to be more aware of whether there is
        -- a background to be drawn, and whether clearing
        -- is the desired behavior or not

        ctx:fill(30);
        ctx:fillAll()
    end

    function win1.mouseEvent(self, event)
        --print("win1.mouseEvent: ", event.activity, event.x, event.y)
        if event.activity == "mousedown" then
            local g = graphic:new({origin = {x=event.x, y = event.y}})
            self:add(g)
        end
    end

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

return app