local SpiroGraphic = require("SpiroGraphic")

function app(params)
    local params = {
        frame={x=0, y=0,
            width=640,height=480
        }
    }

    local win1 = WMCreateWindow(params)
    win1:setTitle("BEST spirograph")
    win1:setUseTitleBar(true)

    local spg = SpiroGraphic:new(params.frame)

    win1:add(spg)
    win1:show()

    while true do
        win1:draw()
        yield();
    end
end

require("windowapp")

return app