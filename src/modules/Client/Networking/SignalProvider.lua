-- SignalProvider
-- Synth
-- 01/24/2021


--[[

    A signal provider 

]]


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local Signal = require("Signal")

local SignalProvider = {}
local Signals = {}

--// Returns the signal or creates a new one
function SignalProvider:Get(name)
    local signal = (Signals[name] or self:_Register(name))

    return signal
end

--// Removes a signal from memory
function SignalProvider:Remove(name)
    if (Signals[name] == nil) then
        return warn(string.format("Signal with name %s has not been registered!", name))
    end

    Signals[name]:Destroy()
    Signals[name] = nil
end

--// Creates a new signal, and caches it in memory
function SignalProvider:_Register(name)
    if (Signals[name]) then
        return warn(string.format("Signal with name %s has already been registered!", name))
    end

    local signal = Signal.new()
    Signals[name] = signal

    return signal
end

function SignalProvider:Init()

end
    
return SignalProvider