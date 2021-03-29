-- Sidebar
-- MrAsync
-- 03/28/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local SignalProvider = require("SignalProvider")
local GuiTemplates = require("GuiTemplates")
local BasicPane = require('BasicPane')

local Sidebar = setmetatable({}, BasicPane)
Sidebar.__index = Sidebar

function Sidebar.new()
    local self = setmetatable(BasicPane.new(GuiTemplates:Clone("SidebarTemplate")), Sidebar)
    
    self.SidebarButtonClicked = SignalProvider:Get("SidebarButtonClicked")

    for _, frame in pairs(self.Gui:GetChildren()) do
        if (frame:IsA("ImageLabel")) then continue end

        frame.Button.MouseButton1Click:Connect(function()
            self.SidebarButtonClicked:Fire(frame.Name)
        end)
    end

    return self
end

function Sidebar:Destroy()
    
end

return Sidebar