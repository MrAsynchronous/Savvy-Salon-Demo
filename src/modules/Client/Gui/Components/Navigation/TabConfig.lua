-- TabConfig
-- Synth
-- 01/12/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local Table = require('Table')

return Table.readonly({
    LineTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),

    LineOffset = function(button)
        return UDim2.new(button.Position.X.Scale, 0, button.Position.Y.Scale + (button.Size.Y.Scale * 1.45), 0)
    end
})