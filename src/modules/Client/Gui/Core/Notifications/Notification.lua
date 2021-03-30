-- Notification
-- MrAsync
-- 03/01/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local TweenService = game:GetService("TweenService")

local GuiTemplates = require("GuiTemplates")
local Config = require('NotificationConfig')
local BasicPane = require('BasicPane')

local Notification = setmetatable({}, BasicPane)
Notification.__index = Notification

function Notification.new(notificationData)
    local self = setmetatable(BasicPane.new(GuiTemplates:Clone("NotificationTemplate")), Notification)
    
    self._Text = notificationData.Text

    self.Gui.Text = self._Text
    self.Gui.Size = Config.NotificationSize
    self.Gui.Position = Config.HiddenPosition

    self._YPosition = Config.HiddenPosition.Y.Scale
    self._YSize = Config.NotificationSize.Y.Scale

    self._PopTime = tick() + Config.NotificationTime

    return self
end

function Notification:Push()
    TweenService:Create(
        self.Gui,
        Config.PushTweenInfo,
        {Position = Config.VisiblePosition}
    ):Play()
end

function Notification:MoveUp()
    self._YPosition -= self._YSize

    TweenService:Create(
        self.Gui,
        Config.PushTweenInfo,
        {Position = UDim2.fromScale(
            Config.VisiblePosition.X.Scale,
            self._YPosition
        )}
    ):Play()
end

function Notification:Destroy()
    local exitTween = TweenService:Create(
        self.Gui,
        Config.PopTweenInfo,
        {Position = UDim2.fromScale(
            Config.HiddenPosition.X.Scale,
            self._YPosition
        )}
    )
    
    -- Give tween to maid
    self._maid:GiveTask(exitTween)

    -- Destroy when the tween completes
    exitTween.Completed:Connect(function(playbackState)
        if (not playbackState == Enum.PlaybackState.Completed) then return end

        self._maid:Destroy()
    end)
    
    exitTween:Play()
end

return Notification