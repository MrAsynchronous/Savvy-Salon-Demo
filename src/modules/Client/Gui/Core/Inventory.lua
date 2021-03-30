-- Inventory
-- MrAsync
-- 03/28/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local PlacementService = require("PlacementService")

local FurnitureTemplates = require("FurnitureTemplates")
local NetworkService = require("NetworkService")
local SignalProvider = require("SignalProvider")
local GuiTemplates = require("GuiTemplates")
local BasicPane = require('BasicPane')

local Dependencies = {
    SecretaryDesk = "None",
    WaitingChair = "SecretaryDesk",
    ShampooStation = "WaitingChair",
    CuttingStation = "ShampooStation"
}

local Inventory = setmetatable({}, BasicPane)
Inventory.__index = Inventory

local function GetCameraDistance(object, camera)
    local objectSize = (object:IsA('Model') and object:GetModelSize() or object.Size)
    local objectRadius = objectSize.Magnitude * 0.5
    local halfFOV = math.rad(camera.FieldOfView / 2)

    local distance = objectRadius / math.tan(halfFOV)
    return distance
end

function Inventory.new()
    local self = setmetatable(BasicPane.new(GuiTemplates:Clone("InventoryTemplate")), Inventory)

    self.SidebarButtonClicked = SignalProvider:Get("SidebarButtonClicked")

    NetworkService:Request("RequestSalon"):Then(function(salon)
        self.Salon = salon
    end)

    self.Gui.CloseButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)

    self:SetVisible(false)
    self.Gui.Visible = false

    self.VisibleChanged:Connect(function(state)
        if (state) then
            self.Gui.Visible = true

            TweenService:Create(self.Gui, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Position = UDim2.fromScale(.5, .907)}):Play()
        else
            TweenService:Create(self.Gui, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.fromScale(.5, 1.25)}):Play()

            delay(0.25, function()
                self.Gui.Visible = false
            end)
        end
    end)

    for _, child in pairs(self.Gui.Container:GetChildren()) do
        if (not child:IsA("ImageButton")) then continue end

        local camera = Instance.new("Camera")
        camera.Parent = child.Viewport

        local object = FurnitureTemplates:Clone(child.Name)
        object.Parent = child.Viewport
        object:SetPrimaryPartCFrame(CFrame.new(0, 0, 0))

        child.Viewport.CurrentCamera = camera

        local primaryPart = object.PrimaryPart
        local objectSize = object.PrimaryPart.Size
        local objectCFrame = primaryPart.CFrame
        camera.CFrame = CFrame.new(objectCFrame.Position + Vector3.new(0, objectSize.Y + 2, 0) + (objectCFrame.LookVector * (GetCameraDistance(object, camera) + 3)), objectCFrame.Position)

        child.MouseButton1Click:Connect(function()
            SoundService.Click:Play()

            if (Dependencies[child.Name] ~= "None" and not self.Salon.Placements:FindFirstChild(Dependencies[child.Name])) then return end

            PlacementService:StartPlacing(child.Name)

            self:Toggle()
            child:Destroy()
        end)
    end

    local rot = 0
    RunService.RenderStepped:Connect(function()
        rot -= 0.4

        for _, child in pairs(self.Gui.Container:GetChildren()) do
            if (not child:IsA("ImageButton")) then continue end

            local object = child.Viewport:FindFirstChildOfClass("Model")
            local objectCFrame = object.PrimaryPart.CFrame

            object:SetPrimaryPartCFrame(CFrame.new(objectCFrame.Position) * CFrame.Angles(0, math.rad(rot), 0))
        end
    end)

    return self
end

function Inventory:Destroy()
    
end

return Inventory