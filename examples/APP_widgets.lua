--package.path = "../best/?.lua;../?.lua;"..package.path;

local BOnOffSwitch = require("BOnOffSwitch")
local BTextLabel = require("BTextLabel")
local Slider = require("slider")

local function app(params)
    -- create a simple windows
    local win1 = WMCreateWindow({frame = {x=10,y=10,width=640,height=480}})
    
    function win1.drawBackground(self, ctx)
        ctx:fill(0xff)
        ctx:rect(0,0,self.frame.width, self.frame.height)
    end

    -- text labels
    local lbl1 = BTextLabel:new({frame = {x=10,y=50, width = 60, height=32}, fontSize=16, text="Switch 1:"})
    local lbl2 = BTextLabel:new({frame = {x=10,y=90, width = 60, height=32}, fontSize=16, text="Switch 2:"})
    local lbl3 = BTextLabel:new({frame = {x=10,y=130, width = 60, height=32}, fontSize=16, text="Switch 3:"})
    
    win1:add(lbl1)
    win1:add(lbl2)
    win1:add(lbl3)
    
    
    -- create on/off switch
    local sw0 = BOnOffSwitch:new()
    local sw1 = BOnOffSwitch:new({frame={x=80,y=50,width=64,height=32}})
    local sw2 = BOnOffSwitch:new({frame={x=80,y=90,width=128,height=32}})
    local sw3 = BOnOffSwitch:new({frame={x=80,y=130,width=256,height=32}})


    win1:add(sw0)
    win1:add(sw1)
    win1:add(sw2)
    win1:add(sw3)

    -- Create some sliders
    -- vertical
    local sli1 = Slider:create{startPoint ={x=400,y=60}, endPoint={x=400;y=360}};
    -- horizontal
    local sli2 = Slider:create{startPoint ={x=80,y=180}, endPoint={x=320;y=180}};

    win1:add(sli1)
    win1:add(sli2)

    win1:show();
    
    local function drawproc()
        win1:draw()
    end

    periodic(1000/10, drawproc)
end

return app