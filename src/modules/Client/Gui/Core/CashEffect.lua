-- CashEffect
-- MrAsync
-- 03/29/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local BaseObject = require('BaseObject')

local CashEffect = setmetatable({}, BaseObject)
CashEffect.__index = CashEffect

function CashEffect.new(amount)
    local self = setmetatable(BaseObject.new(), CashEffect)


    
    return self
end

function CashEffect:Destroy()
    
end

return CashEffect