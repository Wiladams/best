
local FontMonger = require("FontMonger")
local monger = FontMonger:new()

local faceCount = 0;
for family, subfamily, facedata in monger:faces() do
    faceCount = faceCount + 1;
    --print(family, subfamily, facedata.face:fullName())
end

local FontListPage = {
    fontSize = 16;
    cellHeight = 32;
    cellWidth = 400;
}
local FontListPage_mt = {
    __index = FontListPage;
}

function FontListPage.getPreferredSize(self)
    return {width=FontListPage.cellWidth, height=FontListPage.cellHeight*faceCount}
end

function FontListPage.new(self, obj)
    obj = obj or {
        fontSize = FontListPage.fontSize;
        cellHeight = FontListPage.cellHeight;
        cellWidth = FontListPage.cellWidth;
    }
    
    obj.fontSize = obj.fontSize or FontListPage.fontSize;
    obj.cellHeight = obj.cellHeight or FontListPage.cellHeight;
    obj.cellWidth = obj.cellWidth or FontListPage.cellWidth;
    obj.frame = obj.frame or {x=0,y=0,width=obj.cellWidth, height=obj.cellHeight*faceCount}
    
    setmetatable(obj, FontListPage_mt)

    return obj
end

function FontListPage.draw(self, ctx)
    ctx:textSize(self.fontSize);
    ctx:fill(0)

    local x = 4;
    local y = self.cellHeight;
    for family, subfamily, facedata in monger:faces() do
        ctx:textFont(family)
        ctx:text(facedata.face:fullName(), x, y)
        y = y + self.cellHeight;
    end
end

return FontListPage