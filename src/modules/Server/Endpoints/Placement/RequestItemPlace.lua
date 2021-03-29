-- RequestItemPlace
-- MrAsync
-- 03/28/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local Furniture = require("Furniture")
local Promise = require('Promise')

return function(playerManager, itemName, worldPosition)
    return Promise.new(function(resolve, reject)
        local salon = playerManager:GetSalon()

        local furnitureObject = Furniture.new(playerManager, itemName, worldPosition)
        salon:CachePlacement(furnitureObject)

        resolve()
    end)
end