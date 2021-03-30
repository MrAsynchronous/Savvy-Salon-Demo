--[[
    ProfileConfig.lua
    lxuca
    06/03/2021
--]]

local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local Table = require('Table')

return Table.readonly({
    DataKey = "PlayerData_PreAlpha_V1",

    DataSchema = {
        Cash = 0,

        _Visits = 0,
        _Playtime = 0
    },
    
    InstanceApiSchema = {
        "Name",
        "UserId",
        
        "CharacterAdded"
    }
})