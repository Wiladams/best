local vkeys = require("vkeys")

--[[
    quick and dirty get app up on the window
--]]
-- quit when user presses escape
local function handleKeyEvent(event)
    if event.keyCode == vkeys.VK_ESCAPE then
        halt()
    end
end

local function main()
    on("gap_keytyped", handleKeyEvent)

    app()
end

--[[
    If we're being used as a standalone app, then 
        this setup function is called.
]]

function startup()
    print("STARTUP")
    spawn(main)
end

