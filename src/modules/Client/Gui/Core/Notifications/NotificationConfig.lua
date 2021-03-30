-- NotificationConfig
-- MrAsync
-- 03/01/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local Table = require('Table')

return Table.readonly({
    NotificationTime = 3,

    NotificationSize = UDim2.fromScale(1, .2),

    VisiblePosition = UDim2.fromScale(1, 1),
    HiddenPosition = UDim2.fromScale(0, 1),

    PushTweenInfo = TweenInfo.new(
        0.35,
        Enum.EasingStyle.Quint,
        Enum.EasingDirection.Out
    ),

    PopTweenInfo = TweenInfo.new(
        0.35,
        Enum.EasingStyle.Quint,
        Enum.EasingDirection.In
    )
})