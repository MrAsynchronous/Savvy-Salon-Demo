-- GetDataSchema
-- MrAsync
-- 03/06/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local Promise = require('Promise')

return function(playerManager)
    return Promise.new(function(resolve, reject)
        local playerData = playerManager:GetData()

        -- Cleanse table of non-replicatable values
        for dataKey, _ in pairs(playerData) do
            if (string.sub(dataKey, 1, 1) == '_') then
                playerData[dataKey] = nil
            end
        end

        return resolve(playerData)
    end)
end