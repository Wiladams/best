local BOnOffSwitch = require("BOnOffSwitch")

local function app(params)
    -- create a simple windows
    local win1 = WMCreateWindow({frame = {x=10,y=10,width=640,height=480}})
    
    function win1.drawBackground(self, ctx)
        ctx:fill(0xC0)
        ctx:rect(0,0,self.frame.width, self.frame.height)
    end

    -- create on/off switch
    local sw0 = BOnOffSwitch:new()
    local sw1 = BOnOffSwitch:new({frame={x=10,y=50,width=64,height=32}})
    local sw2 = BOnOffSwitch:new({frame={x=10,y=90,width=128,height=32}})
    local sw3 = BOnOffSwitch:new({frame={x=10,y=130,width=256,height=32}})

    win1:add(sw0)
    win1:add(sw1)
    win1:add(sw2)
    win1:add(sw3)

    win1:show();
    
    local function drawproc()
        win1:draw()
    end

    periodic(1000/10, drawproc)
end

return app