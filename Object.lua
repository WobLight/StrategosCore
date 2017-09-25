local S
if StrategosCore == nil then 
    StrategosCore = {}
end
S = StrategosCore
setmetatable(S, {__index = getfenv() })

setfenv(1, S)

Connection = {}


function Connection:new(source, siganl, target, slot)
      local o = {source = source, signal = siganl, target = target, slot = slot}
      setmetatable(o, self)
      self.__index = self
      return o
end

function Connection:trigger(source, ...)
    if self.target then
        if self.target._object then
            self.target._object.source = self
        end
        self.slot(self.target, unpack(arg))
    else
        self.slot(unpack(arg))
    end
end
function Connection:disconnect()
    Object.disconnect(self.source, self.signal, self.target, self.slot)
end
    

Object = {}

function Object.attach(self, signals)
    self._object = self._object or {connections = {}}
    local conn = self._object.connections
    for _,s in signals or {} do
        local s = s
        conn[s] = conn[s] or {}
        self[s] = self[s] or function (self, ...)
            for _,c in self._object.connections[s] do
                c:trigger(source, unpack(arg))
            end
        end
    end
end

function Object.connect(source, signal, target, slot)
    if type(source) ~= "table" then
        error(format("Bad argument #1: table expected, got %s. Usage: connect(source, signal, target or nil, callback)", type(source)))
    elseif not source._object then
        error("Bad argument #1: no Object attached")
    elseif type(signal) ~= "string" then
        error(format("Bad argument #2: string expected, got %s. Usage: connect(source, signal, target or nil, callback)", type(signal)))
    elseif target and type(target) ~= "table" then
        error(format("Bad argument #3: table or nil expected, got %s. Usage: connect(source, signal, target or nil, callback)", type(target)))
    elseif type(slot) ~= "function" then
        error(format("Bad argument #4: function expected, got %s. Usage: connect(source, signal, target or nil, callback)", type(target)))
    end
    if not source[signal] then
        debug(format("Warining: connecting to unknown signal %s", signal))
    end
    table.insert(source._object.connections[signal], Connection:new(source, signal, target, slot))
end

function Object.disconnect(source, signal, target, slot)
    local connections = source._object.connections
    for k,c in connections[signal] do
        if c.target == target and c.slot == slot then
            table.remove(connections,k)
        end
    end
end
