local GLogLines = require("GLogLines")

function app()
    local win1 = WMCreateWindow({frame={x=0,y=0,width=1024,height=768}})
    local plane = GLogLines:new({frame = {x=0,y=0,width=win1.frame.width, height=win1.frame.height}})


    function win1.drawBackground(self, ctx)
        ctx:setFillStyle(BLRgba32(0xFFF0F0A0))
        ctx:fillAll();
        
        ctx:fill(0xA0, 0xF0, 0xF0)    -- sky
        ctx:noStroke();
        ctx:rect(0,0,self.frame.width,(self.frame.height/2)-20)
    end

    win1:add(plane)
    win1:show()

    local function drawproc()
        win1:draw()
    end

    periodic(1000/30, drawproc)
end


require("windowapp")
