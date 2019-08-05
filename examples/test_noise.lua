local ffi = require("ffi")
local noise = require("noise")

local map = {
    scale = 1;
    dx = 0;
    dy = 0;
    sizeX = 64;
    sizeY = 64;
    elevation = ffi.new("float[64][64]")
}


-- generate noise
for i = -1,1, 0.001 do

        print(noise(i, 0, 0))

end

--[[
for x=0,map.sizeX-1 do
    for y=0,map.sizeY-1 do
      map.elevation[x][y] = noise(x/map.scale + map.dx, y/map.scale + map.dy,0)
    end
end

for x=1,map.sizeX-1 do
    for y=1,map.sizeY-1 do
      io.write(map.elevation[x][y], '..')
    end
    io.write("\n")
end
--]]