
local GFontIconPage = require("GFontIconPage")

function app()
    local size = GFontIconPage:getPreferredSize()
print("SIZE: ", size.width)
    local params = {
        frame = {
            x =0; y =0;
            width = size.width; height = 768 
        }
    }

    local win1 = WMCreateWindow(params)
    local fip = GFontIconPage:new({frame = {x=10, y = 10, width =params.frame.width, height = params.frame.height}})

    win1:add(fip)
    win1:show()

    local function drawproc()
        win1:draw();
    end
    
    periodic(1000/10, drawproc)
end

return app