local S
if StrategosCore == nil then 
    StrategosCore = {}
end
S = StrategosCore
setmetatable(S, {__index = getfenv() })

setfenv(1, S)

Ring = {}

function Ring:new(o)
    local super = getmetatable(o).__index
    setmetatable(o, { __index = function(self, k)
        return Ring[k] or super(self,k)
    end })
    Object.attach(o,{})
end

function Ring:onStarted()
    self.stopping = false
    self:Show()
end

function Ring:setReversed(reversed)
    this.reverse = reverse
end

function Ring:setTimer(t)
    if self.timer then
        Object.disconnect(self.timer, "started", self, self.onStarted)
        Object.disconnect(self.timer, "stopped", self, self.Hide)
    end
    self.timer = t
    Object.connect(t, "started", self, self.onStarted)
    Object.connect(t, "stopped", self, self.Hide)
    if not t:elapsed() then
        self:Hide()
    end
end

function Ring:setColor(rgba)
    local _,f = self:GetRegions()
    f:SetVertexColor(unpack(rgba))
end

local function rotate(this, r)
    function c(x,y)
        local sin = math.sin(r)
        local cos = math.cos(r)
        return (x*cos - y * sin)/2+0.5, -(x*sin + y * cos)/2 + 0.5
    end
    local ulx, uly = c(-1,1)
    local llx, lly = c(-1,-1)
    local urx, ury = c(1,1)
    local lrx, lry = c(1,-1)
    this:SetTexCoord(
        ulx,uly,
        llx,lly,
        urx,ury,
        lrx,lry)
end

function Ring:OnUpdate()
    if this.stopping ~= true then
        local elapsed = this.timer:elapsed()
        if elapsed then
            local finished = elapsed / this.timer.duration;
            if ( finished <= 1.0 ) then
                    local r = finished *math.pi*2;
                    rotate(this:GetRegions(),this.reverse and -r or r)
                    return
            end
            this.stopping = true
            this:Hide()
        else
            rotate(this:GetRegions(), 0)
        end
    else
    end
end
