-- CameraConfig
-- MrAsync
-- 03/27/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local Table = require('Table')

return Table.readonly({
    NpcOffset = Vector3.new(0, 3, 7),
    NpcRotation = CFrame.Angles(0, math.rad(45), 0)
})