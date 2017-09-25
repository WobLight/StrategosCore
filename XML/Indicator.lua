local S
if StrategosCore == nil then 
    StrategosCore = {}
end
setmetatable(StrategosCore, {__index = getfenv() })
S = StrategosCore

setfenv(1, S)

Indicator = {}
setmetatable(Indicator, {__index = getfenv() })

setfenv(1, Indicator)

function Indicator:new(o)
    local super = getmetatable(o).__index
    setmetatable(o, { __index = function(self, k)
        return Indicator[k] or super(self,k)
    end })
    Object.attach(o,{})
    o.ring = getglobal(o:GetName().."Ring")
    o.ring:SetFrameLevel(o:GetFrameLevel())
    o.pin = getglobal(o:GetName().."Pin")
end

function Indicator:setNode(node)
    if self.node then
        Object.disconnect(self.node, "factionChanged", self, updateFaction)
    end
    Object.connect(node, "factionChanged", self, updateFaction)
    self.node = node
    self.ring:setTimer(node.timer)
    self:updateFaction()
end

local factionColor = {
    {1,1,1}, {0,0,1}, {1,0,0}
}

function Indicator:updateFaction()
    self.ring:setColor(factionColor[(self.node.assaultingFaction or 0)+1])
    if not self.colorful then
        self.pin:SetVertexColor(unpack(factionColor[(self.node.faction or 0)+1]))
    end
end
