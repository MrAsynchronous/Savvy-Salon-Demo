-- ButtonConfig
-- Synth
-- 01/12/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local Table = require('Table')

return Table.readonly({
    ColorTweenInfo = TweenInfo.new(0.1),
    
    TextHoverColor = Color3.fromRGB(255, 100, 100),
    ImageHoverShade = 100
})