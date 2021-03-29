-- CurrencyLabel
-- MrAsync
-- 01/19/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local TextService = game:GetService("TextService")

local Config = require("CurrencyLabelConfig")
local GuiTemplates = require("GuiTemplates")
local BaseObject = require('BaseObject')

local CurrencyLabel = setmetatable({}, BaseObject)
CurrencyLabel.__index = CurrencyLabel

function CurrencyLabel.new(gui, currency, text, color)
    local self = setmetatable(BaseObject.new(GuiTemplates:Clone("CurrencyLabelTemplate")), CurrencyLabel)
    
    self.Gui = self._obj
    self.Parent = gui

    self.Gui.Parent = gui
    self.Gui.ZIndex = gui.ZIndex + 1
    self.Gui.Label.Text = text

    self.Gui.CurrencyIcon.Image = Config.Labels[currency]
    self.Gui.Label.TextColor3 = (color or Config.DefaultColor)
    self.Gui.CurrencyIcon.ImageColor3 = (color or Config.DefaultColor)
    self.Gui.CurrencyIcon.UIAspectRatioConstraint.AspectRatio = Config.Ratios[currency]

    -- Hide any other text that may interfere with robux label
    if (gui:IsA("TextLabel") or gui:IsA("TextBox")) then
        gui.TextTransparency = 1
    end

    if (gui:FindFirstChildOfClass("TextLabel")) then
        gui:FindFirstChildOfClass("TextLabel").TextTransparency = 1
    end

    self._maid:GiveTask(self.Gui)

    return self
end

function CurrencyLabel:Destroy()
    if (self.Parent:IsA("TextLabel") or self.Parent:IsA("TextBox")) then
        self.Parent.TextTransparency = 0
    end 

    if (self.Parent:FindFirstChildOfClass("TextLabel")) then
        self.Parent:FindFirstChildOfClass("TextLabel").TextTransparency = 0
    end

    self._maid:Destroy()
end

return CurrencyLabel