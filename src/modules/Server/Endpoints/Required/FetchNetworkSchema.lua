-- GetNetworkSchema
-- MrAsync
-- 03/06/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local Promise = require('Promise')

return function(playerManager)
    return Promise.new(function(resolve, reject)
        if (playerManager._HasFetchedNetworkSchema) then
            return reject({
                error = "Already feteched NetworkSchema"
            })
        end

        playerManager._HasFetchedNetworkSchema = true

        -- Grab config
        local Config = require("NetworkConfig")
        local tempEndpoints = {}

        -- Cache endpoints in temporary table to remove callback
        for endpointName, _ in pairs(Config.Endpoints) do
            table.insert(tempEndpoints, endpointName)
        end
        
        return resolve({
            Signals = Config.Signals,
            Endpoints = tempEndpoints
        })
    end)
end