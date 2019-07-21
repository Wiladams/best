local GraphicGroup = require("GraphicGroup")

local BTextLabel = {
    TypeFamily = "segoe ui";
    FontSize = 14;
    TextColor = 0;
}
setmetatable(BTextLabel, {
    __index = GraphicGroup;
})
local BTextLabel_mt = {
    __index = BTextLabel;
}

--[[
    Things you can specify
    textColor
    typeFamily
    fontSize
    text
    frame
    alignment (horizontal, vertical)
]]
function BTextLabel.new(self, obj)
    obj = obj or {frame={x=0,y=0,width=32,height=32}}
    obj = GraphicGroup:new(obj)
    
    obj.typeFamily = obj.typeFamily or self.TypeFamily;
    obj.fontSize = obj.fontSize or self.FontSize;
    obj.text = obj.text or "";
    obj.alignment = obj.alignment or {horizontal = LEFT, vertical = MIDDLE};
    obj.textColor = obj.textColor or self.TextColor;

    setmetatable(obj, BTextLabel_mt)
    
    return obj;
end

function BTextLabel.drawBackground(self, ctx)
    ctx:stroke(0)
    ctx:rect(0,0,self.frame.width, self.frame.height)

    ctx:noStroke();
    ctx:textSize(self.fontSize)
    ctx:textFont(self.typeFamily)
    ctx:textAlign(self.alignment.horizontal, self.alignment.vertical)
    ctx:fill(self.textColor)

    ctx:text(self.text, 0, self.frame.height/2)
end

return BTextLabel