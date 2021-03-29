-- Furniture
-- MrAsync
-- 03/28/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local FurnitureTemplates = require("FurnitureTemplates")
local BaseObject = require('BaseObject')

local Furniture = setmetatable({}, BaseObject)
Furniture.__index = Furniture

function Furniture.new(player, itemName, worldPosition)
    local self = setmetatable(BaseObject.new(), Furniture)
    
    self.Player = player
    self.Salon = player:GetSalon()

    self.Name = itemName
    self.Position = worldPosition

    self.Object = FurnitureTemplates:Clone(itemName)
    self.Object.Parent = self.Salon.PlacementContainer
    self._maid:GiveTask(self.Object)

    self.Object:SetPrimaryPartCFrame(self.Position)

    return self
end

function Furniture:Destroy()
    self._maid:Destroy()
end

return Furniture