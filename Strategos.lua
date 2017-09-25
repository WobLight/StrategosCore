local S
if StrategosCore == nil then 
    StrategosCore = {}
end
S = StrategosCore
setmetatable(S, {__index = getfenv() })

function toString(a)
    if a == nil then return "nil" end
    if a == true then return "TRUE" end
    if a == false then return "FALSE" end
    if type(a) == "string" then return "\""..a.."\"" end
    if type(a) == "table" then
        local out = ""
        if a[0] and a.GetName then
            out = format("%s ", a:GetName())
        end
        out = out .. "{"
        local sep = ""
        for k,v in a do
            out = out..sep..toString(k)..": "..toString(v)
            sep = ", "
        end
        return out.."}"
    end
    return tostring(a)
end

function debug(s, force)
    if not (DEBUG or force) then return end
    DEFAULT_CHAT_FRAME:AddMessage("StrategosCore: "..toString(s))
end
