-- Popup
-- MrAsync
-- 03/11/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local GuiTemplates = require("GuiTemplates")
local GuiRegistry = require("GuiRegistry")
local BasicPane = require('BasicPane')
local Config = require("PopupConfig")
local DarkBlur = require("DarkBlur")
local Button = require("Button")

local Popup = setmetatable({}, BasicPane)
Popup.__index = Popup

function Popup.new(config, dontAutoOpen)
    if (GuiRegistry:GuiOfClassExists("Confirmation") or GuiRegistry:GuiOfClassExists("Popup")) then return end

    local self = setmetatable(BasicPane.new(GuiTemplates:Clone("PopupTemplate")), Popup)

    self.UUID = string.format("Popup_%s", HttpService:GenerateGUID(false))
    GuiRegistry:RegisterGui(self.UUID, {Gui = self.Gui})
    
    self.Gui.Visible = false
    self.Gui.Size = Config.ClosedSize
    self.Gui.Position = Config.Position

    self.HideOnOk = true

    self._Container = self.Gui.Container
    self._Title = self._Container.Title
    self._Description = self._Container.Description

    -- Create button objects for buttons
    self.CloseButton = Button.new(self._Container.Close)
    self.OkButton = Button.new(self._Container.Ok)
    self.DarkBlur = DarkBlur.new()

    -- Apply text
    self._Title.Text = (config.TitleText or Config.DefaultTitleText)
    self._Description.Text = (config.DescriptionText or Config.DefaultDescriptionText)
    self.OkButton.Gui.ButtonText.Text = (config.ButtonText or Config.DefaultButtonText)

    -- Socket for button click events
    self.CloseButtonClicked = self.CloseButton.MouseButton1Click
    self.ButtonClicked = self.OkButton.MouseButton1Click
    
    self._maid:GiveTask(self.Gui)
    self._maid:GiveTask(self.DarkBlur)
    self._maid:GiveTask(self.OkButton)
    self._maid:GiveTask(self.CloseButton)

    -- Hide gui by default
    self._maid:GiveTask(self.CloseButtonClicked:Connect(function()
        self:Destroy()
    end))

    self._maid:GiveTask(self.ButtonClicked:Connect(function()
        self:Destroy()
    end))

    -- Only open UI by default
    if (dontAutoOpen == nil) then
        self:Show()
    end

    return self
end

--// Tweens the confirmation into view
function Popup:Show()
    self.Gui.Visible = true

    self.DarkBlur:Show()

    -- Construct and play tween
    local tweenInfo = TweenInfo.new(Config.DefaultTweenTime, Config.DefaultEasingStyle, Config.DefaultEasingDirection)
    TweenService:Create(self.Gui, tweenInfo, {Size = Config.OpenSize}):Play()
end

--// Sets the callback function for the right button
function Popup:SetRightButtonClick(callback)
    self._maid:GiveTask(self.RightButtonClicked:Connect(callback))
end

--// Sets the callback function for the close button
function Popup:SetCloseButtonClick(callback)
    self._maid:GiveTask(self.CloseButtonClicked:Connect(callback))
end

function Popup:Destroy()
    self.DarkBlur:Destroy()

    local tweenInfo = TweenInfo.new(Config.DefaultTweenTime, Config.DefaultEasingStyle, Config.DefaultEasingDirection)
    local closeTween = TweenService:Create(self.Gui, tweenInfo, {Size = Config.ClosedSize})
    closeTween.Completed:Connect(function(playbackState)
        if (not playbackState == Enum.PlaybackState.Completed) then return end
        
        GuiRegistry:UnregisterGui(self.UUID)

        self._maid:Destroy()
    end)

    closeTween:Play()
end

return Popup