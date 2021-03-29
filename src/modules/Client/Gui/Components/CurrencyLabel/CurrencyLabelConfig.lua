-- CurrencyLabelConfig
-- MrAsync
-- 01/19/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local Table = require('Table')

return Table.readonly({
    Labels = {
        Robux = "rbxassetid://6269612812",
        Credits = "rbxassetid://6273651174"
    },

    Ratios = {
        Robux = 0.85,
        Credits = 1
    },

    DefaultColor = Color3.fromRGB(255, 255, 255)
})