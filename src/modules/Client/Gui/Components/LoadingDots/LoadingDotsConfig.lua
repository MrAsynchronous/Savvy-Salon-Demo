-- LoadingDotsConfig
-- MrAsync
-- 02/26/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local Table = require('Table')

return Table.readonly({
    
    DotTweenInfo = TweenInfo.new(
        .25,
        Enum.EasingStyle.Quint,
        Enum.EasingDirection.Out,
        0,
        true,
        0.1
    ),

    GuiTweenInfo = TweenInfo.new(
        0.5,
        Enum.EasingStyle.Quint,
        Enum.EasingDirection.Out
    ),

    DefaultOpenPosition = UDim2.new(1, -15, 1, -15),
    DefaultClosedPosition = UDim2.new(1.15, -15, 1, -15)
})