-- ReqestSalon
-- MrAsync
-- 03/27/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local Promise = require('Promise')

return function(playerManager)
    return Promise.new(function(resolve)
        local salonObject = playerManager:GetSalon()

        return resolve(salonObject.Object)
    end)
end