-- Confirmation
-- MrAsync
-- 01/15/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local CurrencyLabel = require("CurrencyLabel")
local GuiTemplates = require("GuiTemplates")
local Config = require("ConfirmationConfig")
local GuiRegistry = require("GuiRegistry")
local BasicPane = require('BasicPane')
local DarkBlur = require("DarkBlur")
local Shimmer = require("Shimmer")
local Button = require("Button")


local Confirmation = setmetatable({}, BasicPane)
Confirmation.__index = Confirmation

function Confirmation.new(config, dontAutoOpen)
    if (GuiRegistry:GuiOfClassExists("Confirmation") or GuiRegistry:GuiOfClassExists("Popup")) then return end

    local self = setmetatable(BasicPane.new(GuiTemplates:Clone("ConfirmationTemplate")), Confirmation)

    self.UUID = string.format("Confirmation_%s", HttpService:GenerateGUID(false))
    GuiRegistry:RegisterGui(self.UUID, {Gui = self.Gui})

    self.Gui.Visible = false
    self.Gui.Size = Config.ClosedSize
    self.Gui.Position = Config.Position

    self.HideOnAccept = true
    self.HideOnDecline = true

    self._Container = self.Gui.Container
    self._Title = self._Container.Title
    self._Description = self._Container.Description

    -- Create button objects for buttons
    self.LeftButton = Button.new(self._Container.Left)
    self.RightButton = Button.new(self._Container.Right)
    self.CloseButton = Button.new(self._Container.Close)
    self.DarkBlur = DarkBlur.new()

    -- Apply text
    self._Title.Text = (config.TitleText or Config.DefaultTitleText)
    self._Description.Text = (config.DescriptionText or Config.DefaultDescriptionText)
    self.LeftButton.Gui.ButtonText.Text = (config.LeftButtonText or Config.DefaultLeftButtonText)
    self.RightButton.Gui.ButtonText.Text = (config.RightButtonText or Config.DefaultRightButtonText)

    -- Socket for button click events
    self.LeftButtonClicked = self.LeftButton.MouseButton1Click
    self.RightButtonClicked = self.RightButton.MouseButton1Click
    self.CloseButtonClicked = self.CloseButton.MouseButton1Click

    self._maid:GiveTask(self.Gui)
    self._maid:GiveTask(self.DarkBlur)
    self._maid:GiveTask(self.LeftButton)
    self._maid:GiveTask(self.RightButton)
    self._maid:GiveTask(self.CloseButton)

    -- Hide gui by default
    self._maid:GiveTask(self.CloseButtonClicked:Connect(function()
        if (not self.HideOnDecline) then return end

        self:Destroy()
    end))

    -- Only open UI by default
    if (dontAutoOpen == nil) then
        self:Show()
    end

    return self
end

--// Tweens the confirmation into view
function Confirmation:Show()
    self.Gui.Visible = true
    self.DarkBlur:Show()

    -- Construct and play tween
    local tweenInfo = TweenInfo.new(Config.DefaultTweenTime, Config.DefaultEasingStyle, Config.DefaultEasingDirection)
    TweenService:Create(self.Gui, tweenInfo, {Size = Config.OpenSize}):Play()
end

--// Creates a robux label on the left button
function Confirmation:CreateLeftCurrencyLabel(currencyType, text)
    self._LeftCurrencyLabel = CurrencyLabel.new(self.LeftButton.Gui, currencyType, text)
    self._maid:GiveTask(self._LeftCurrencyLabel)

    return self._LeftCurrencyLabel
end

--// Creates a Robux label on the right button
function Confirmation:CreateRightCurrencyLabel(currencyType, text)
    self._RightCurrencyLabel = CurrencyLabel.new(self.RightButton.Gui, currencyType, text)
    self._maid:GiveTask(self._RightCurrencyLabel)

    return self._RightCurrencyLabel
end

--// Creates a shimmer for the left button
function Confirmation:CreateLeftShimmer()
    self._LeftShimmer = Shimmer.new(self.LeftButton.Gui)
    self._maid:GiveTask(self._LeftShimmer)

    return self._LeftShimmer
end

--// Creates a shimmer for the right button
function Confirmation:CreateRightShimmer()
    self._RightShimmer = Shimmer.new(self.RightButton.Gui)
    self._maid:GiveTask(self._RightShimmer)

    return self._RightShimmer
end

--// Sets the callback function for the left button
function Confirmation:SetLeftButtonClick(callback)
    self._maid:GiveTask(self.LeftButtonClicked:Connect(callback))
end

--// Sets the callback function for the right button
function Confirmation:SetRightButtonClick(callback)
    self._maid:GiveTask(self.RightButtonClicked:Connect(callback))
end

--// Sets the callback function for the close button
function Confirmation:SetCloseButtonClick(callback)
    self._maid:GiveTask(self.CloseButtonClicked:Connect(callback))
end

function Confirmation:Destroy()
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

return Confirmation