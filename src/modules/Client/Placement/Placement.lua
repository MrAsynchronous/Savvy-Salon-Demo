-- Placement
-- MrAsync
-- 03/27/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Templates = require("FurnitureTemplates")
local CameraService = require("CameraService")
local Config = require("PlacementConfig")
local BaseObject = require('BaseObject')
local Signal = require("Signal")
local Math = require("Math")
local AABB = require("AABB")

local Placement = setmetatable({}, BaseObject)
Placement.__index = Placement

function Placement.new(SalonObject, itemName)
    local self = setmetatable(BaseObject.new(), Placement)

    -- Localize
    self.Camera = CameraService:GetCamera()
    self.Player = Players.LocalPlayer
    self.Mouse = self.Player:GetMouse()
    self.Salon = SalonObject

    -- Signals
    self.Placed = Signal.new()
    self.Cancelled = Signal.new()

    -- Construct object
    self.Object = Templates:Clone(itemName)
    self.Object.Parent = self.Camera
    self._maid:GiveTask(self.Object)

    self.DummyPart = self.Object.PrimaryPart:Clone()
    self.DummyPart.Parent = self.Camera
    self._maid:GiveTask(self.DummyPart.Touched:Connect(function() end))

    -- Localize
    self.CanvasCFrame, self.CanvasSize = self:_GetCanvasData(self.Salon.PrimaryPart)
    self.ObjectSize = self.Object.PrimaryPart.Size
    self.Rotation = 0

    self.Mouse.TargetFilter = self.Object

    -- Create raycastParams
    self.RaycastParams = RaycastParams.new()
    self.RaycastParams.FilterDescendantsInstances = {self.Player.Character, self.Object}

    self.Object.PrimaryPart.Transparency = 0.5
    self.Object.PrimaryPart.Color = Config.PrimaryPartColor

    for _, child in pairs(self.Object:GetDescendants()) do
        if (not child:IsA("BasePart")) then continue end

        child.CanCollide = false
    end

    -- Listen to input
    self._maid:GiveTask(UserInputService.InputBegan:Connect(function(inputObject, gameProcessed)
        if (gameProcessed) then return end

        if (inputObject.UserInputType == Config.Keybinds.ItemPlace) then
            if (self:_IsColliding()) then return end

            self.Placed:Fire(self.WorldPosition)
        elseif (inputObject.KeyCode == Config.Keybinds.ItemRotate) then
            self.Rotation += math.pi / 2
        elseif (inputObject.KeyCode == Config.Keybinds.ItemCancel) then
            self.Cancelled:Fire()
        end
    end))

    -- Update on render stepped
    self._maid:GiveTask(RunService.RenderStepped:Connect(function()
        return self:_UpdatePosition()
    end))
    
    return self
end

--// Updates the position relative to the mouse
function Placement:_UpdatePosition()
    local clampedPosition = self:_ClampVector(self.Mouse.Hit.Position)


    self.DummyPart.CFrame = clampedPosition
    self.Object:SetPrimaryPartCFrame(self.Object.PrimaryPart.CFrame:Lerp(
        clampedPosition,
        Config.LerpSpeed
    ))

    if (self:_IsColliding()) then
        self.Object.PrimaryPart.Color = Config.CollisionPartColor
    else
        self.Object.PrimaryPart.Color = Config.PrimaryPartColor
    end
end

function Placement:_IsColliding()
    local touchingParts = self.DummyPart:GetTouchingParts()

    for _, part in pairs(touchingParts) do
        if (part:IsDescendantOf(self.Salon)) then
            return true
        end
    end

    return false
end

function Placement:_ClampVector(vector)
    --Sterilize rotation (thanks crut)
    local int, rest = math.modf(self.Rotation / Config.RotationIncrement)
    local rotation = int * Config.RotationIncrement

    --Calculate model size
    local ObjectSize = AABB.worldBoundingBox(CFrame.Angles(0, rotation, 0), self.ObjectSize)
    ObjectSize = Vector3.new(math.abs(Math.round(ObjectSize.X)), math.abs(ObjectSize.Y), math.abs(Math.round(ObjectSize.Z)))

	-- get the position relative to the surface's CFrame
	local lpos = self.CanvasCFrame:pointToObjectSpace(vector);
	-- the max bounds the model can be from the surface's center
	local size2 = (self.CanvasSize - Vector2.new(ObjectSize.X, ObjectSize.Z)) / 2

	-- constrain the position using size2
	local x = math.clamp(lpos.x, -size2.X, size2.X);
	local y = math.clamp(lpos.y, -size2.Y, size2.Y);

    x = math.sign(x) * ((math.abs(x) - math.abs(x) % Config.GridSize) + (size2.X % Config.GridSize))
	y = math.sign(y) * ((math.abs(y) - math.abs(y) % Config.GridSize) + (size2.Y % Config.GridSize))

    self.WorldPosition = self.CanvasCFrame * CFrame.new(x, y, -ObjectSize.Y / 2) * CFrame.Angles(-math.pi / 2, rotation, 0)

    --Construct CFrame
    return self.WorldPosition
end

function Placement:_GetCanvasData(canvas)
    local plotSize = canvas.Size

    local up = Vector3.new(0, 1, 0)
    local back = -Vector3.FromNormalId(Enum.NormalId.Top)

    local dot = back:Dot(Vector3.new(0, 1, 0))
    local axis = (math.abs(dot) == 1) and Vector3.new(-dot, 0, 0) or up

    local right = CFrame.fromAxisAngle(axis, math.pi / 2) * back
    local top = back:Cross(right).Unit

    local plateCFrame = canvas.CFrame * CFrame.fromMatrix(-back * plotSize / 2, right, top, back)
    local plateSize = Vector2.new((plotSize * right).Magnitude, (plotSize * top).Magnitude)

    return plateCFrame, plateSize
end

function Placement:Destroy()
    self._maid:Destroy()
end

return Placement