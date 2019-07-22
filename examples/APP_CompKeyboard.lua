
local keyboard = require("GCompKeyboard")

function app(params)
    local win1 = WMCreateWindow({
        frame={x=0, y=0,
            width=640,height=320
        }
    })
    win1:setTitle("STOP_CompKeyboard.lua")
    
    local kbd = keyboard:new({frame={x=10, y = 10, width = 610, height=290}})
    --local size = kbd:getPreferredSize()
    --print("kbd size: ", size.width, size.height)

    win1:add(kbd)
    win1:show()

    while true do
        win1:draw()
        yield();
    end
end

require("windowapp")

return app