-- RequestCodeSubmit
-- MrAsync
-- 03/30/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local Promise = require('Promise')

return function(playerManager, input)
    return Promise.new(function(resolve, reject)
        
        print(input)

        resolve()
    end)
end