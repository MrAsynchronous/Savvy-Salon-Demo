-- PopupConfig
-- MrAsync
-- 03/11/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local Table = require('Table')

return Table.readonly({
    DefaultButtonText = "Ok",
    DefaultTitleText = "Notice",
    DefaultDescriptionText = "You shouldn't be seeing this.  MrAsync did something wrong.",

    ClosedSize = UDim2.fromScale(0, 0),
    Position = UDim2.fromScale(0.5, 0.5),
    OpenSize = UDim2.fromScale(.36, .23),

    DefaultTweenTime = 0.25,
    DefaultEasingStyle = Enum.EasingStyle.Quint,
    DefaultEasingDirection = Enum.EasingDirection.Out
})