-- Dialog
-- MrAsync
-- 03/28/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local TweenService = game:GetService("TweenService")

local SignalProvider = require("SignalProvider")
local GuiTemplates = require("GuiTemplates")
local BasicPane = require('BasicPane')

local Dialog = setmetatable({}, BasicPane)
Dialog.__index = Dialog

function Dialog.new()
    local self = setmetatable(BasicPane.new(GuiTemplates:Clone("DialogTemplate")), Dialog)

    self.VisibleChanged:Connect(function(state)
        if (state) then
            self.Gui.Visible = true

            TweenService:Create(self.Gui, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Position = UDim2.fromScale(0, 0)}):Play()
        else
            TweenService:Create(self.Gui, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.fromScale(0, -1)}):Play()

            delay(0.25, function()
                self.Gui.Visible = false
            end)
        end
    end)

    return self
end

function Dialog:Destroy()
    
end

return Dialog