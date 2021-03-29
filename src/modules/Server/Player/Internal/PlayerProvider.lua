-- PlayerUtility
-- MrAsync
-- 03/06/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local ServerBinders = require("ServerBinders")
local Promise = require('Promise')

return function(player)
    local playerManager = ServerBinders.Player:Get(player)

    if (playerManager) then
        return playerManager
    else
        local startTime = tick()

        repeat
            wait()

            playerManager = ServerBinders.Player:Get(player)
        until (playerManager or (tick() - startTime >= 5))

        return playerManager
    end
end