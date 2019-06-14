
local functor = require("functor")
local vkeys = require("vkeys")
local app = require("APP_widgets")

local function handleKeyEvent(event)
    if event.keyCode == vkeys.VK_ESCAPE then
        halt()
    end
end


local function main()
    on("gap_keytyped", handleKeyEvent)

    app()
end



function startup()
    spawn(main)
end