-- Codes
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

local Codes = setmetatable({}, BasicPane)
Codes.__index = Codes

function Codes.new()
    local self = setmetatable(BasicPane.new(GuiTemplates:Clone("CodesTemplate")), Codes)

    self.SidebarButtonClicked = SignalProvider:Get("SidebarButtonClicked")
    self.Gui.CloseButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)

    self:SetVisible(false)
    self.Gui.Visible = false
    self.Gui.Position = UDim2.fromScale(.5, 1.5)

    self.VisibleChanged:Connect(function(state)
        if (state) then
            self.Gui.Visible = true

            TweenService:Create(self.Gui, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Position = UDim2.fromScale(.5, .5)}):Play()
        else
            TweenService:Create(self.Gui, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.fromScale(.5, 1.5)}):Play()

            delay(0.25, function()
                self.Gui.Visible = false
            end)
        end
    end)

    self.Gui.Redeem.MouseButton1Click:Connect(function()
        NetworkService:Request("RequestCodeSubmit", self.Gui.CodeInput.Text):Then(function()
            SignalProvider:Get("PushNotification"):Fire({Text = "Code Redeemed!"})
        end)
    end)

    self.SidebarButtonClicked:Connect(function(name)
        if (name ~= "Twitter") then return end

        self:Toggle()
    end)

    return self
end

function Codes:Destroy()
    
end

return Codes