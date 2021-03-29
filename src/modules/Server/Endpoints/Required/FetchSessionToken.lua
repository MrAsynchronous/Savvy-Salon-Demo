-- FetchSessionToken
-- MrAsync
-- 03/07/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local Promise = require('Promise')

return function(playerManager)
    return Promise.new(function(resolve, reject)
        if (playerManager._HasFetchedSessionToken) then
            return reject("Already fetched session token!")
        end

        playerManager._HasFetchedSessionToken = true
        
        return resolve(playerManager._PublicToken)
    end)
end