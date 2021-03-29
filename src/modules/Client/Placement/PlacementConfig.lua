-- PlacementConfig
-- MrAsync
-- 03/27/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local Table = require('Table')

return Table.readonly({
    GridSize = 1,
    LerpSpeed = 0.35,
    RotationIncrement = math.pi / 2,

    PrimaryPartColor = Color3.fromRGB(165, 105, 189),
    CollisionPartColor = Color3.fromRGB(231, 76, 60),

    Keybinds = {
        ItemPlace = Enum.UserInputType.MouseButton1,
        ItemRotate = Enum.KeyCode.R,
        ItemCancel = Enum.KeyCode.X
    }  
})