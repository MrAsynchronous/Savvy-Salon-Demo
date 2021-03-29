-- Salon
-- MrAsync
-- 03/27/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local BaseObject = require('BaseObject')

local Salon = setmetatable({}, BaseObject)
Salon.__index = Salon

function Salon.new(player, salonObject)
    local self = setmetatable(BaseObject.new(), Salon)
    
    self.Object = salonObject
    self.Player = player

    self._PrimaryPart = self.Object.PrimaryPart
    self._Position = self._PrimaryPart.Position
    self._CFrame = self._PrimaryPart.CFrame
    self._Size = self._PrimaryPart.Size

    self.Placements = {}
    self.PlacementContainer = self.Object.Placements

    -- Move character to plot
    self._maid:GiveTask(self.Player.CharacterAdded:Connect(function(character)
        local rootPart = character:WaitForChild("HumanoidRootPart")

        delay(0.5, function()
            rootPart.CFrame = CFrame.new(self._Position + (self._CFrame.LookVector * (self._Size.X / 1.5)) + Vector3.new(0, 4, 0), self._Position)
        end)
    end))

    return self
end

function Salon:CachePlacement(furniturePlacement)
    table.insert(self.Placements, furniturePlacement)
end

function Salon:Destroy()
    for _, placement in pairs(self.Placements) do
        placement:Destroy()
    end
end

return Salon