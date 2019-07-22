--[[
    A panel animator takes two graphics and 
    performs a multi-frame animation between them.

    This is meant to be a base class, from which various
    interestesting animations are derived.
]]
local PanelAnimator = {}
local PanelAnimator_mt = {
    __index = PanelAnimator;
}

function PanelAnimator.new(self, obj)
    if not obj then
        return nil;
    end
    
    obj.duration = obj.duration or 1

    setmetatable(obj, PanelAnimator_mt)
    
    -- setup a timer
    return obj;
end

function PanelAnimator.start(self)
end

function PanelAnimator.stop(self)
end

function PanelAnimator.draw(self, ctx)
    -- draw the two panels
    self.panel1:draw(ctx)
    self.panel2:draw(ctx)
end

function PanelAnimator.update(self, u)
    -- do nothing interesting
end

return PanelAnimator