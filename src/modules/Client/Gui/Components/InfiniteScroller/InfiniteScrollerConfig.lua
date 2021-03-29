-- InfiniteScrollerConfig
-- MrAsync
-- 02/24/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local Table = require('Table')

return Table.readonly({
    StartingPoint = UDim2.fromScale(0.5, 0.5),
    Padding = 0.03,

    CenterBounds = {
        Min = .49,
        Max = .51
    },

    CardTweenInfo = TweenInfo.new(
        0.4,
        Enum.EasingStyle.Quint,
        Enum.EasingDirection.Out
    )
})