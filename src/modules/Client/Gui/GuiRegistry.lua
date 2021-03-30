-- GuiRegistry
-- MrAsync
-- 01/12/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local DataService = require("DataService")

local PlayerGui = Player:WaitForChild("PlayerGui")

local GuiRegistry = {}
local Registry = {}

--// Registers a gui to the registry
function GuiRegistry:RegisterGui(guiName, object)
    if (Registry[guiName]) then
        return warn(string.format("Gui with name %s has already been registered!", guiName))
    end

    object.Gui.Parent = self.Container
    Registry[guiName] = object
end

--// Removes registered gui
function GuiRegistry:UnregisterGui(guiName)
    if (Registry[guiName] == nil) then
        return warn(string.format("Gui with name %s has not been registered!", guiName))
    end

    Registry[guiName] = nil
end

--// Returns a gui from the registry
function GuiRegistry:GetGui(guiName)
    return Registry[guiName]
end

--// Returns boolean reflecting if a gui of that class exists
function GuiRegistry:GuiOfClassExists(className)
    for guiName, _ in pairs(Registry) do
        if (string.sub(guiName, 1, string.len(className)) == className) then
            return true
        end
    end

    return false
end

function GuiRegistry:Init()
    self.Container = Instance.new("ScreenGui")
    self.Container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.Container.ResetOnSpawn = false
    self.Container.Name = "CoreGameGui"
    self.Container.Parent = PlayerGui  
    
    self:RegisterGui("Dialog", require("Dialog").new())
    self:RegisterGui("Sidebar", require("Sidebar").new())
    self:RegisterGui("Inventory", require("Inventory").new())
end
    
return GuiRegistry