
local AnalogClock = require("AnalogClock")

function app()
    local size = AnalogClock:getPreferredSize()

    local params = {
        frame = {x =0; y =0;
            width = size.width+8; height = size.height+8 }
    }

    local win1 = WMCreateWindow(params)
    
    -- stub this so there's no background d
    function win1.drawBackground(self, ctx)
    end

    local clock = AnalogClock:new()

    win1:add(clock)
    win1:show()

    local function drawproc()
        win1:draw();
    end
    
    periodic(1000/30, drawproc)

end

require("windowapp")

return app