local S
if StrategosCore == nil then 
    StrategosCore = {}
end
S = StrategosCore
setmetatable(S, {__index = getfenv() })

setfenv(1, S)

local tid = 0
Timer = {timers = {},}

function Timer:new(duration)
      local o = {duration = duration, id = tid, oneShot = true}
      tid = tid +1
      Object.attach(o, {"started","stopped","triggered"})
      setmetatable(o, self)
      self.__index = self
      return o
end


function Timer:start(d)
    self.m_started = GetTime()
    self.duration = d or self.duration
    if self:remaning() > 0 then
        self:started()
    else
        self:stopped()
    end
end

function Timer:set(s, d)
    self.duration = d or self.duration
    self.m_started = GetTime() - self.duration + s
    if self:remaning() > 0 then
        self:started()
    else
        self:stopped()
    end
end

function Timer:elapsed()
    return self.m_started and GetTime() - self.m_started
end

function Timer:remaning()
    if not (self.m_started and self.duration) then return end
    local t = self.duration  - (GetTime() - self.m_started)
    return t >= 0 and t
end

function Timer:stop()
    self.m_started = nil
    self:stopped()
end

function Timer:setActive(active)
    if active or active == nil then
        if Timer.timers[self.id] then
            debug("Timer already active.")
            return
        end
        Timer.timers[self.id] = self
    else
        if not Timer.timers[self.id] then
            debug("Timer already inactive.")
            return
        end
        Timer.timers[self.id] = nil
    end
end
    

Timer.coreTimer = CreateFrame("frame")
Timer.coreTimer:SetScript("OnUpdate", function()
    for _, timer in Timer.timers do
        if timer.m_started and not timer:remaning() then
            timer:stop()
            timer:triggered()
            if not timer.oneShot then
                timer:start()
            end
        end
    end
end)
