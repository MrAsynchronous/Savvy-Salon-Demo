-- PlayButton
-- MrAsync
-- 03/28/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local SignalProvider = require("SignalProvider")
local GuiTemplates = require("GuiTemplates")
local GuiRegistry = require("GuiRegistry")
local BasicPane = require('BasicPane')

local PlayButton = setmetatable({}, BasicPane)
PlayButton.__index = PlayButton

function PlayButton.new()
    local self = setmetatable(BasicPane.new(GuiTemplates:Clone("PlayButtonTemplate")), PlayButton)

    self.Signal = SignalProvider:Get("PlayButtonClicked")
    self.Camera = Workspace.CurrentCamera
    self.Camera.CameraType = Enum.CameraType.Scriptable
    
    self.Blur = Instance.new("BlurEffect")
    self.Blur.Size = 12
    self.Blur.Parent = self.Camera

    GuiRegistry:GetGui("Sidebar").Gui.Visible = false

    local rot = 1
    RunService:BindToRenderStep("CAMERAEFECT", 1, function()
        rot += 0.1

        self.Camera.CFrame = CFrame.new(Vector3.new(80.5044403, 43.73806, 387.648712)) *
        CFrame.Angles(0, math.rad(-rot), 0) * 
        CFrame.Angles(math.rad(-20), 0, 0)
    end)

    self.Gui.Button.MouseButton1Click:Connect(function()
        SoundService.Click:Play()

        GuiRegistry:GetGui("Sidebar").Gui.Visible = true
        RunService:UnbindFromRenderStep("CAMERAEFECT")

        self.Signal:Fire()
        self.Blur:Destroy()
        
        self.Gui:Destroy()
    end)

    return self
end

function PlayButton:Destroy()
    
end

return PlayButton