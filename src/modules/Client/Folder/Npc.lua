-- Npc
-- MrAsync
-- 03/29/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local PathfindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local NetworkService = require("NetworkService")
local Templates = require("FurnitureTemplates")
local BaseObject = require('BaseObject')

local StateExchange = {
    [1] = "SecretaryDesk",
    [2] = "WaitingChair",
    [3] = "ShampooStation",
    [4] = "CuttingStation"
}

local Npc = setmetatable({}, BaseObject)
Npc.__index = Npc

function Npc.new(npcName, spawnPoint)
    local self = setmetatable(BaseObject.new(), Npc)

    self.Character = Templates:Clone(npcName)
    self.Character.Parent = Workspace
    self.Character:SetPrimaryPartCFrame(spawnPoint)

    NetworkService:Request("RequestSalon"):Then(function(salon)
        self.Salon = salon
    end)

    self.State = 1

    self.Prompt = Instance.new("ProximityPrompt")
    self.Prompt.Parent = self.Character.PrimaryPart
    self.Prompt.HoldDuration = 0
    self.Prompt.ObjectText = npcName
    self.Prompt.ActionText = "Interact"
    self.Prompt.RequiresLineOfSight = false
    self.Prompt.Enabled = false
    
    return self
end

function Npc:AdvanceState()
    self.State += 1

    return StateExchange[self.State]
end

function Npc:RunAnimation(animationId)
    local animation = Instance.new("Animation")
    animation.AnimationId = string.format("rbxassetid://%s", animationId)

    local track = self.Character.Humanoid:LoadAnimation(animation)
    track:Play()
end

function Npc:MoveToPoint(point)
    local path = PathfindingService:FindPathAsync(self.Character.PrimaryPart.Position, point)
    local waypoints = path:GetWaypoints()
    local normalizedWaypoints = {}

    local positionBuffer = Instance.new("CFrameValue")
    positionBuffer.Value = self.Character.PrimaryPart.CFrame
    positionBuffer.Changed:Connect(function(newCFrame)
        self.Character:SetPrimaryPartCFrame(newCFrame)
    end)

    -- Normalize Y's of waypoint positions
    for i, waypoint in pairs(waypoints) do
        normalizedWaypoints[i] = Vector3.new(
            waypoint.Position.X,
            self.Character.PrimaryPart.Position.Y,
            waypoint.Position.Z
        )
    end

    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://2510202577"

    local track = self.Character.Humanoid:LoadAnimation(animation)
    track:Play()

    for i, waypoint in pairs(normalizedWaypoints) do
        local tween = TweenService:Create(
            positionBuffer,
            TweenInfo.new(0.25, Enum.EasingStyle.Linear),
            {Value = CFrame.new(waypoint, (normalizedWaypoints[i + 1] and normalizedWaypoints[i + 1] or positionBuffer.Value.LookVector))}
        )

        tween:Play()
        tween.Completed:Wait()
    end

    for _, track in pairs(self.Character.Humanoid:GetPlayingAnimationTracks()) do
        if (track.Animation.AnimationId == "rbxassetid://2510196951") then continue end

        track:Stop()
    end
end

function Npc:Destroy()
    
end

return Npc