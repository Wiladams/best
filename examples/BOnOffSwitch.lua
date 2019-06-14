--[[
    This is a basic on/off switch.  we could generalize to a multi-state
    switch, where this would just be a specialization, but this will
    do for now.

    The switch will change state based on doing a mouseUp within
    its frame.  mousedown and drag have no effect.

    It will signal with:
    self, "changedstate", self.isOn

    That's enough information for a handler to know which switch
    is doing the signaling, the fact that it's a change state
    and what is the new current state.  That's good, but, the handler
    may not run before the state changes again, so it can call
    getOnState() and get the current state directly.

    You can construct a switch by simply calling the new() method with 
    a frame.  If you don't specify a frame (default constructor), you'll get
    a simple switch with a default size, and location 0,0
]]
local GraphicGroup = require("GraphicGroup")

local BOnOffSwitch = {
    thickness = 32;
}
setmetatable(BOnOffSwitch, {
    __index = GraphicGroup
})

local BOnOffSwitch_mt = {
    __index = BOnOffSwitch;
}

function BOnOffSwitch.new(self, obj)
    obj = obj or {
        frame = {x=0,y=0,width=self.thickness*2,height=self.thickness};
    }
    obj = GraphicGroup:new(obj)

    obj.frame = obj.frame or {x=0,y=0,width=self.thickness*2,height=self.thickness}
    obj.thumbRadius = (obj.frame.height/2)-2
    
    setmetatable(obj, BOnOffSwitch_mt)
    
    return obj;
end

-- For anyone who's curious, they can call
-- this function to determine whether the switch
-- is currently 'on'==true or not.
function BOnOffSwitch.getOnState(self)
    return self.isOn
end

-- change state and trigger a signal based
-- on mouseUp activity
function BOnOffSwitch.mouseUp(self, event)
    self.isOn = not self.isOn;
    signalAll(self, self, "changedstate", self.isOn)

    return true;
end

-- In order to get different appearance, simply implement a 
-- different version of draw.  Doing it as drawBackground might
-- be better so GraphicGroup drawing behavior is maintained.
function BOnOffSwitch.drawBackground(self, ctx)
    --print("BOnOffSwitch.draw")
    -- create a roundRect for our frame
    local rrect = BLRoundRect(0,0,self.frame.width,self.frame.height,self.frame.height/2,self.frame.height/2)

    -- fill in the background depending on our current state
    if self.isOn then 
        ctx:stroke(0)
        ctx:fill(63,0x7f,0xff)    -- turquoise
        ctx:fillRoundRect(rrect)
        ctx:strokeRoundRect(rrect)

        -- draw thumb
        ctx:noStroke()
        ctx:fill(255)
        ctx:circle(self.frame.width-self.thumbRadius-2, self.frame.height/2, self.thumbRadius)
    else
        ctx:stroke(0)
        ctx:fill(0x7f)  -- mid-gray
        ctx:fillRoundRect(rrect)
        ctx:strokeRoundRect(rrect)

        ctx:noStroke();
        ctx:fill(0)
        ctx:circle(self.thumbRadius+2, self.frame.height/2, self.thumbRadius)
    end

end

return BOnOffSwitch;
