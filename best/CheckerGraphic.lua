--[[
    Draw a checkerboard pattern, assuming the p5 environment
]]

local Checkerboard = {}
setmetatable(Checkerboard, {
    __call = function(self, ...)
        return self:new(...)
    end
})
local Checkerboard_mt = {
    __index = Checkerboard
}

function Checkerboard.init(self, params)
    params = params or {}

    params.frame = params.frame or {x=0,y=0,width=640,height=640}

    params.columns = params.columns or 8
    params.rows = params.rows or 8
    params.color1 = params.color1 or color(30)
    params.color2 = params.color2 or color(127)

    params.tilewidth = params.frame.width / params.columns;
	params.tileheight = params.frame.height / params.rows;
	params.boxwidth = params.tilewidth / 2;
	params.boxheight = params.tileheight / 2;

    setmetatable(params, Checkerboard_mt)

    return params
end

function Checkerboard.new(self, params)
    return self:init(params)
end



function Checkerboard.draw(self, dc)
    dc:rectMode(CORNER);
	dc:noStroke();
    
    local c1 = self.color1;
    local c2 = self.color2;

    for r = 0, self.rows-1 do
        -- Flip which color comes first
        -- per each row
        if r % 2 == 0 then
            c1 = self.color1
            c2 = self.color2
        else
            c1 = self.color2;
            c2 = self.color1;
        end

        for c = 0, (self.columns)-1 do
            -- alternate colors per column
            if c % 2 == 0 then
		        dc:fill(c1);
                dc:rect(c*self.tilewidth, r*self.tileheight, self.tilewidth, self.tileheight);
            else
                dc:fill(c2)
                dc:rect(c*self.tilewidth, r*self.tileheight, self.tilewidth, self.tileheight);
            end
        end
    end
end

return Checkerboard
