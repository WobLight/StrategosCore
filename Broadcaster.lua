local S
if StrategosCore == nil then 
    StrategosCore = {}
end
S = StrategosCore
setmetatable(S, {__index = getfenv() })
setfenv(1, S)

local frame = CreateFrame("frame")
frame:RegisterEvent("CHAT_MSG_ADDON")
frame.index = {}

Broadcaster = {rtt = 0}

function Broadcaster:new(name)
    local o = {name = name, lookup = {}, mid = 0}
    if strlen(o.name) > 16 then
        debug("name exeeds maximum length",1)
        return
    end
    if frame.index[name] then
        debug(format("A Broadcaster named \"%s\" is already registered.",name))
        return
    end
    Object.attach(o, {"messageRecieved"})
    setmetatable(o, self)
    self.__index = self
    frame.index[name] = o
    return o
end

function Broadcaster.getByName(name)
    return frame.index[name]
end

function Broadcaster.processMessage()
    local time = GetTime()
    local self = this.index[arg1]
    if self then
        _, _, mid, msg = strfind(arg2,"^(%x+)\t(.*)$")
        mid = tonumber(mid, 16)
        if arg4 == UnitName("player") then
            local o = self.lookup[mid]
            local diff = time - o.time
            Broadcaster.rtt = Broadcaster.rtt * 0.9 + diff * 0.1
            o:looped(diff)
            self.lookup[mid] = nil
        else
            self:messageRecieved({sender = arg4, channel = arg3, id = mid, time = time, message = msg})
        end
    end
end
frame:SetScript("OnEvent", Broadcaster.processMessage)
            
function Broadcaster:sendMessage(msg, channel)
    local mid = self.mid
    self.mid = self.mid +1
    local fmsg = format("%x\t%s",mid,msg)
    if strlen(self.name) + strlen(fmsg) +1 > 256 then
        debug("Message \""..msg.."\" exeeds maximum length",1)
        return false
    end
    SendAddonMessage(self.name, fmsg, channel)
    local ret = {time = GetTime(), id = mid}
    self.lookup[mid] = ret
    Object.attach(ret,{"looped"})
    mid = mid +1
    return ret
end

function Broadcaster:unregister()
    frame.index[self.name] = nil
    function self.sendMessage()
        debug(format("Attempted to send message through unregistered Broadcaster \"%s\".",self.name))
    end
end
