
local keyboard = require("GPianoKeyboard")

function app()
    local params = {
        frame={x=0, y=0,
            width=640,height=320
        }
    }

    local win1 = WMCreateWindow(params)
    --win1:setUseTitleBar(true)

    local kbdsets = 8
    local kbdwidth = params.frame.width/kbdsets
    local kbdheight = 240

    -- add separate instances of the keyboard
    for i=1,kbdsets do
        kbd = keyboard:new({frame={x= (i-1)*kbdwidth,y=0, width=kbdwidth, height=kbdheight}, scale = {x=kbdwidth, y=kbdheight}})   
        win1:add(kbd)
    end

    win1:show()

    while true do
        win1:draw()
        yield();
    end
end

require("windowapp")

return app

