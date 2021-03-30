-- NotificationContainer
-- MrAsync
-- 03/02/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local RunService = game:GetService("RunService")

local NetworkService = require("NetworkService")
local SignalProvider = require("SignalProvider") 
local Notification = require("Notification")
local GuiTemplates = require("GuiTemplates")
local BasicPane = require('BasicPane')

local NotificationContainer = setmetatable({}, BasicPane)
NotificationContainer.__index = NotificationContainer

function NotificationContainer.new()
    local self = setmetatable(BasicPane.new(GuiTemplates:Clone("NotificationContainerTemplate")), NotificationContainer)
    
    self._NotificationQueue = {}
    self._NotificationStack = {}

    self._PushEvent = SignalProvider:Get("PushNotification")

    NetworkService:ObserveSignal("PushNotification"):Connect(function(notificationData)
        return self:_PushNotification(notificationData)
    end)

    self:Init()

    return self
end

--// Pushes a new notification to the front of the queue
function NotificationContainer:_PushNotification(notificationData)
    assert(typeof(notificationData), "Invalid notification data")

    return table.insert(self._NotificationQueue, notificationData)
end

function NotificationContainer:Init()
    self._PushEvent:Connect(function(notificationData)
        return self:_PushNotification(notificationData)
    end)

    -- Iterate through queue on PreRender
    RunService.RenderStepped:Connect(function()

        -- Garbage collection
        -- Could've been handled within each notification class, but this
        -- ensures that all notifications are destroyed
        for index, notif in ipairs(self._NotificationStack) do
            if (tick() >= notif._PopTime) then
                notif:Destroy()

                table.remove(self._NotificationStack, index)
            end
        end

        -- Pop the first notification from the queue, construct a new notification object
        local notificationData = table.remove(self._NotificationQueue, 1)
        if (not notificationData) then return end

        local notificationObject = Notification.new(notificationData)
        notificationObject.Gui.Parent = self.Gui

        -- Move all notifications upward
        for _, notification in ipairs(self._NotificationStack) do
            notification:MoveUp()
        end

        -- Push notification into frame
        notificationObject:Push()

        -- Add notification to stack
        table.insert(self._NotificationStack, 1, notificationObject)
    end)
end

function NotificationContainer:Destroy()
    warn("Cannot destroy notification container!")
end

return NotificationContainer