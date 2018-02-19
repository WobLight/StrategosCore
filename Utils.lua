local S
if StrategosCore == nil then 
    StrategosCore = {}
end
S = StrategosCore
setmetatable(S, {__index = getfenv() })

setfenv(1, S)

function strarg(s,...)
    if type(arg[1]) == "table" then
        arg = arg[1]
    end
    for k,v in arg do
        s = string.gsub(s, "%%"..k, v)
    end
    return s
end

function buildDefaults(t, d)
    for k,v in d do
        if type(v) == "table" then
            if not t[k] then
                t[k] = {}
            end
            buildDefaults(t[k], v)
        end
    end
    setmetatable(t, {__index = d})
end
