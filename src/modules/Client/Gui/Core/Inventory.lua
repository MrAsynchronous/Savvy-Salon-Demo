-- Inventory
-- MrAsync
-- 03/28/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local PlacementService = require("PlacementService")

local NetworkService = require("NetworkService")
local SignalProvider = require("SignalProvider")
local GuiTemplates = require("GuiTemplates")
local BasicPane = require('BasicPane')

local Dependencies = {
    SecretaryDesk = "None",
    WaitingChair = "SecretaryDesk",
    ShampooStation = "WaitingChair",
    CuttingStation = "ShampooStation"
}

local Inventory = setmetatable({}, BasicPane)
Inventory.__index = Inventory

function Inventory.new()
    local self = setmetatable(BasicPane.new(GuiTemplates:Clone("InventoryTemplate")), Inventory)

    self.SidebarButtonClicked = SignalProvider:Get("SidebarButtonClicked")

    NetworkService:Request("RequestSalon"):Then(function(salon)
        self.Salon = salon
    end)

    self.Gui.CloseButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)

    self:SetVisible(false)
    self.Gui.Visible = false

    self.VisibleChanged:Connect(function(state)
        if (state) then
            self.Gui.Visible = true

            TweenService:Create(self.Gui, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Position = UDim2.fromScale(.5, .907)}):Play()
        else
            TweenService:Create(self.Gui, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.fromScale(.5, 1.25)}):Play()

            delay(0.25, function()
                self.Gui.Visible = false
            end)
        end
    end)

    for _, child in pairs(self.Gui.Container:GetChildren()) do
        if (not child:IsA("ImageButton")) then continue end

        child.MouseButton1Click:Connect(function()
            SoundService.Click:Play()

            if (Dependencies[child.Name] ~= "None" and not self.Salon.Placements:FindFirstChild(Dependencies[child.Name])) then return end

            PlacementService:StartPlacing(child.Name)

            self:Toggle()
            child:Destroy()
        end)
    end

    return self
end

function Inventory:Destroy()
    
end

return Inventory