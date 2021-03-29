-- CameraService
-- MrAsync
-- 03/27/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local Config = require("CameraConfig")
local Maid = require("Maid")

local CameraService = {}

function CameraService:EnterNpc(npcObject)
    self:ControlCamera()

    local rootPart = npcObject:FindFirstChild("HumanoidRootPart")
    local lookVector = rootPart.CFrame.LookVector
    local rightVector = rootPart.CFrame.RightVector
    local upVector = rootPart.CFrame.UpVector

    self.Camera.CFrame = CFrame.new(rootPart.Position + (lookVector * Config.NpcOffset.Z) + (rightVector * Config.NpcOffset.X) + (upVector * Config.NpcOffset.Y), rootPart.Position)
end

--// Tweens or sets the camera cframe to a new position
function CameraService:MoveToPoint(cframe, dontTween, time)
    self:ControlCamera()

    if (dontTween) then
        self.Camera.CFrame = cframe
    else
        TweenService:Create(self.Camera, TweenInfo.new(time, Enum.EasingStyle.Quint), {CFrame = cframe}):Play()
    end
end

function CameraService:ControlCamera()
    self.Camera.CameraType = Enum.CameraType.Scriptable
end
    
--// Resets Camera to it's default state
function CameraService:ReturnToPlayer()
    self._maid:DoCleaning()

    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    UserInputService.MouseIconEnabled = true

    local character = self.Player.Character
    if (not character) then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if (not humanoid) then return end

    self.Camera.CameraSubject = humanoid
    self.Camera.CameraType = Enum.CameraType.Custom
end

--// Returns camera
function CameraService:GetCamera()
    return self.Camera
end

function CameraService:Init()
    self.Camera = Workspace.CurrentCamera
    self.Player = Players.LocalPlayer

    self._maid = Maid.new()
end


return CameraService