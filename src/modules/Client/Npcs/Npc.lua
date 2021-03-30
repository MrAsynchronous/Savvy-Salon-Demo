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

local Npc = setmetatable({}, BaseObject)
Npc.__index = Npc

function Npc.new(salon, npcName, spawnPoint)
    local self = setmetatable(BaseObject.new(), Npc)

    self.Salon = salon
    self.Placements = self.Salon.Placements

    -- Clone np
    self.Character = Templates:Clone(npcName)
    self.Character.Parent = Workspace
    self.Character:SetPrimaryPartCFrame(spawnPoint)
    self._maid:GiveTask(self.Character)

    -- Create proximity prompt
    self.Prompt = Instance.new("ProximityPrompt")
    self.Prompt.Parent = self.Character.PrimaryPart
    self.Prompt.RequiresLineOfSight = false
    self.Prompt.ActionText = "Interact"
    self.Prompt.ObjectText = npcName
    self.Prompt.HoldDuration = 0.25
    self.Prompt.Enabled = false
    self._maid:GiveTask(self.Prompt)

    self.State = 1
    self.Moving = false

    -- Get salon
    NetworkService:Request("RequestSalon"):Then(function(salon)
        self.Salon = salon
    end)

    return self
end

--// Exits the NPC
function Npc:Exit()
    local exitPoint = self.Salon.NpcExitPoint.Position

    -- Move to exit
    self:MoveToPoint(exitPoint)

    -- Method call yields, so we can just cleanup
    -- here without any problems
    self:Destroy()
end

--// Makes the NPC wait at the 
function Npc:Wait()
    local waitingChair = self.Placements:FindFirstChild("WaitingChair")
    local position = waitingChair:GetPrimaryPartCFrame().Position

    -- Move character to chair
    self:MoveToPoint(position)

    -- Make character sit
    self.Character:SetPrimaryPartCFrame(waitingChair:FindFirstChildOfClass("Seat").CFrame)
end

--// Plays and animation on the character
function Npc:RunAnimation(animationId)
    local animation = Instance.new("Animation")
    animation.AnimationId = string.format("rbxassetid://%s", animationId)
    self._maid:GiveTask(animation)

    local track = self.Character.Humanoid:LoadAnimation(animation)
    track:Play()
end

function Npc:MoveToPoint(point)
    self.Moving = true

    -- Generate path waypoints
    local path = PathfindingService:FindPathAsync(self.Character.PrimaryPart.Position, point)
    local waypoints = path:GetWaypoints()
    local normalizedWaypoints = {}

    -- Create a position buffer so we can tween position of character
    local positionBuffer = Instance.new("CFrameValue")
    positionBuffer.Value = self.Character.PrimaryPart.CFrame
    positionBuffer.Changed:Connect(function(newCFrame)
        self.Character:SetPrimaryPartCFrame(newCFrame)
    end)

    -- Normalize Y's of waypoint positions
    for i, waypoint in pairs(waypoints) do
        normalizedWaypoints[i] = Vector3.new(
            waypoint.Position.X,
            4.25, --self.Salon.PrimaryPart.Position.Y + ((0.5 * self.Character.PrimaryPart.Size.Y) + self.Character.Humanoid.HipHeight),
            waypoint.Position.Z
        )
    end

    -- Play walking animation
    self:RunAnimation("2510202577")

    -- Move throughout waypoints, YIELDS
    for i, waypoint in pairs(normalizedWaypoints) do
        local tween = TweenService:Create(
            positionBuffer,
            TweenInfo.new(0.25, Enum.EasingStyle.Linear),
            {Value = CFrame.new(waypoint, (normalizedWaypoints[i + 1] and normalizedWaypoints[i + 1] or positionBuffer.Value.LookVector))}
        )

        -- Play and wait for tween to complete
        tween:Play()
        tween.Completed:Wait()
    end

    -- Stop all animations after character is done moving
    for _, track in pairs(self.Character.Humanoid:GetPlayingAnimationTracks()) do
        if (track.Animation.AnimationId == "rbxassetid://2510196951") then continue end

        track:Stop()
    end

    self.Moving = false
end

function Npc:Destroy()
    self._maid:Destroy()
end

return Npc