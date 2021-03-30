-- TutorialRunner
-- MrAsync
-- 03/28/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local PathfindingService = game:GetService("PathfindingService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local PlacementService = require("PlacementService")
local SignalProvider = require("SignalProvider")
local NetworkService = require("NetworkService")
local CameraService = require("CameraService")
local GuiTemplates = require("GuiTemplates")
local GuiRegistry = require("GuiRegistry")
local Config = require("TutorialConfig")
local Npc = require("Npc")

local Path = PathfindingService:CreatePath()
local Player = Players.LocalPlayer
local DialogData = Config.Dialog
local CurrentDialog = 0
local LastUpdate = 0

local TutorialRunner = {}

--// Runs a grapheme effect
function TutorialRunner:RunGrapheme(dontShowOnFinish)
    local dialogData = DialogData[CurrentDialog]
    if (dialogData == nil) then
        return self:Destroy()
    end

    -- Hide the button so players don't go too fast
    self:HideNextButton()

    -- Split words
    local words = string.split(dialogData.Text, " ")
    local currentWord = 0

    SoundService.Dialog:Play()

    RunService:BindToRenderStep("NpcGrapheme", 1, function()
        if (tick() - LastUpdate < .06) then return end
        LastUpdate = tick()
        currentWord += 1

        -- Concat the things
        local newText=  table.concat(words, " ", 1, currentWord)

        self.OnScreenTextLabel.Text = newText
        self.TextLabel.Text = newText

        -- Cleanup connection
        if (currentWord + 1 > #words) then
            if (dontShowOnFinish == nil) then
                self:ShowNextButton()
            end

            SoundService.Dialog:Stop()

            PlacementService:SetPlaceLock(false)
            RunService:UnbindFromRenderStep("NpcGrapheme")
        end
    end)
end
   
--// Moves dialog to the next scene
function TutorialRunner:AdvanceDialog()
    if (not self.InfoContainer.Visible) then return end
    CurrentDialog += 1

    local dialogData = DialogData[CurrentDialog]
    if (dialogData == nil) then
        local inventoryGui = GuiRegistry:GetGui("Inventory").Gui
        local sidebarGui = GuiRegistry:GetGui("Sidebar").Gui
        inventoryGui.Arrow.Visible = false
        sidebarGui.Arrow.Visible = false

        self.OnScreenDialog.Visible = false
        self.FirstNpc.Prompt.Enabled = true

        local deskCFrame = self.PlacedItems.SecretaryDesk.PrimaryPart.CFrame
        local deskSize = self.PlacedItems.SecretaryDesk.PrimaryPart.Size * deskCFrame.LookVector
        self.FirstNpc:MoveToPoint(deskCFrame.Position + ((deskCFrame.LookVector * deskSize.Magnitude)))

        SignalProvider:Get("SidebarButtonClicked"):Connect(function(name)
            if (name ~= "Inventory") then return end

            GuiRegistry:GetGui("Inventory"):Toggle()
        end)

        return
    end

    if (dialogData.Animation) then
        for _, track in pairs(self.Npc.Humanoid:GetPlayingAnimationTracks()) do
            if (track.Animation.AnimationId == "rbxassetid://2510196951") then continue end

            track:Stop()
        end

        local animation = Instance.new("Animation")
        animation.AnimationId = dialogData.Animation

        local track = self.Npc.Humanoid:LoadAnimation(animation)
        track:Play()
    end

    self.Npc.Head.IdleFace.Texture = dialogData.Face or "rbxassetid://226216895"
    
    -- Handle other cases here
    -- This is not good, but since it's a demo project i'll let it slide
    if (CurrentDialog == 2) then
        self.DialogGui.Enabled = false
        self:HideNextButton()

        -- Move her
        CameraService:GetCamera().CameraSubject = self.Npc.PrimaryPart
        CameraService:GetCamera().CameraType = Enum.CameraType.Follow

        local noramalizedLookPoint = Vector3.new(
            self.SalonObject.NatashaLookPoint.Position.X,
            self.Npc.PrimaryPart.Position.Y,
            self.SalonObject.NatashaLookPoint.Position.Z
        )

        local path = PathfindingService:FindPathAsync(self.Npc.PrimaryPart.Position, self.SalonObject.NatashaPoint.Position)
        local waypoints = path:GetWaypoints()
        local normalizedWaypoints = {}

        local positionBuffer = Instance.new("CFrameValue")
        positionBuffer.Value = self.Npc.PrimaryPart.CFrame
        positionBuffer.Changed:Connect(function(newCFrame)
            self.Npc:SetPrimaryPartCFrame(newCFrame)
        end)

        -- Normalize Y's of waypoint positions
        for i, waypoint in pairs(waypoints) do
            normalizedWaypoints[i] = Vector3.new(
                waypoint.Position.X,
                self.Npc.PrimaryPart.Position.Y,
                waypoint.Position.Z
            )
        end

        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://2510202577"

        local track = self.Npc.Humanoid:LoadAnimation(animation)
        track:Play()

        for i, waypoint in pairs(normalizedWaypoints) do
            local tween = TweenService:Create(
                positionBuffer,
                TweenInfo.new(0.25, Enum.EasingStyle.Linear),
                {Value = CFrame.new(waypoint, (normalizedWaypoints[i + 1] and normalizedWaypoints[i + 1] or noramalizedLookPoint))}
            )

            tween:Play()
            tween.Completed:Wait()
        end

        self.Npc.PrimaryPart.Anchored = true

        self.SalonObject.DESTROY1:Destroy()
        self.SalonObject.DESTROY2:Destroy()
        self.SalonObject.Door.CanCollide = false

        animation:Destroy()
        track:Stop()

        self:ShowNextButton()
        self.DialogGui.Enabled = true

        self:RunGrapheme()
        CameraService:EnterNpc(self.Npc)
    elseif (CurrentDialog == 3) then
        self.DialogGui.Enabled = false
        self.OnScreenDialog.Visible = true

        self:RunGrapheme()
        self.FirstNpc = Npc.new("Charlette", CFrame.new(self.SalonObject.FirstNpc.Position, self.SalonObject.CharacterSpawnLookPoint.Position), true)
        self.FirstNpc:RunAnimation("507770239")
        
        delay(1, function()
            local currentCFrame = CameraService:GetCamera().CFrame
            CameraService:MoveToPoint(CFrame.new(currentCFrame.Position, self.SalonObject.OhNoPoint.Position), false, 1)
            SoundService.Gasp:Play()
    
            spawn(function()
                delay(1, function()
                    self.Npc:SetPrimaryPartCFrame(CFrame.new(0, 1000, 0))
                end)
            end)
        end)
    elseif (CurrentDialog == 4) then
        Player.Character.PrimaryPart.CFrame = CFrame.new(self.SalonObject.CharacterSpawnPoint.Position, self.SalonObject.CharacterSpawnLookPoint.Position)
        Player.Character.PrimaryPart.Anchored = false

        CameraService:ReturnToPlayer()

        self.SalonObject.CharacterSpawnLookPoint:Destroy()
        self.SalonObject.CharacterSpawnPoint:Destroy()
        self.SalonObject.NatashaLookPoint:Destroy()
        self.SalonObject.NatashaPoint:Destroy()
        self.SalonObject.OhNoPoint:Destroy()

        -- Make arrow go boop
        local sidebarGui = GuiRegistry:GetGui("Sidebar").Gui
        sidebarGui.Arrow.Visible = true

        -- Make arrow bounce
        TweenService:Create(sidebarGui.Arrow,
            TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, -1, true),
            {Position = UDim2.fromScale(2, 0.507)}
        ):Play()

        -- Wait for inventory to open
        local connection
        connection = SignalProvider:Get("SidebarButtonClicked"):Connect(function(name)
            if (name ~= "Inventory") then return end

            connection:Disconnect()
            self:ShowNextButton()
            self:AdvanceDialog()
        end)

        self:RunGrapheme(true)
    elseif (CurrentDialog == 5 or CurrentDialog == 6 or CurrentDialog == 7 or CurrentDialog == 8) then
        local sidebarGui = GuiRegistry:GetGui("Sidebar").Gui
        local inventory = GuiRegistry:GetGui("Inventory")
        local inventoryGui = inventory.Gui
        sidebarGui.Arrow.Visible = false
        inventoryGui.Arrow.Visible = true

        inventory:SetVisible(true)

        local connection
        connection = SignalProvider:Get("ItemPlaced"):Connect(function(name, object)
            if (name ~= dialogData.ItemName) then return end

            self.PlacedItems[name] = object

            connection:Disconnect()
            self:ShowNextButton()
            self:AdvanceDialog()
        end)

        self:RunGrapheme(true)
    else
        self:RunGrapheme()
    end
end

--// Hides the button
function TutorialRunner:HideNextButton()
    self.InfoContainer.Visible = false
    self.OnScreenInfoContainer.Visible = false

    PlacementService:SetPlaceLock(true)
end

--// Shows the button
function TutorialRunner:ShowNextButton()
    self.InfoContainer.Visible = true
    self.OnScreenInfoContainer.Visible = true
end

--// Begings the whole process
function TutorialRunner:EnterDialog()
    UserInputService.InputBegan:Connect(function(inputObject, gameProcessed)
        if (gameProcessed) then return end

        if (inputObject.KeyCode == Enum.KeyCode.Space) then
            self:AdvanceDialog()
        end
    end)

    local character = Player.Character or Player.CharacterAdded:Wait()
    character:WaitForChild("HumanoidRootPart").Anchored = true
    character:SetPrimaryPartCFrame(CFrame.new(0, 1000, 0))

    -- Setup the camera
    CameraService:EnterNpc(self.Npc)

    -- Start advancing
    self:AdvanceDialog()
end

function TutorialRunner:Destroy()
    self.DialogGui:Destroy()
    self.Npc:Destroy()

    CameraService:ReturnToPlayer()
end

function TutorialRunner:Init()
    NetworkService:Request("RequestSalon"):Then(function(salonObject)
        self.SalonObject = salonObject
    end)

    self.Npc = self.SalonObject.Npcs.Natasha

    -- Create dialog
    self.DialogGui = GuiTemplates:Clone("DialogGui")
    self.InfoContainer = self.DialogGui.Container.TextContainer.InfoContainer
    self.TextLabel = self.DialogGui.Container.TextContainer.Label
    self.OnScreenDialog = GuiRegistry:GetGui("Dialog").Gui
    self.OnScreenTextLabel = self.OnScreenDialog.TextContainer.Label
    self.OnScreenInfoContainer = self.OnScreenDialog.TextContainer.InfoContainer

    self.PlacedItems = {}

    TweenService:Create(GuiRegistry:GetGui("Inventory").Gui.Arrow,
        TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, -1, true),
        {Position = UDim2.fromScale(.125, -.5)}
    ):Play()

    -- Tween color
    TweenService:Create(
        self.InfoContainer.Icon,
        TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, -1, true),
        {Size = UDim2.fromScale(0.085, 1)}
    ):Play()

    self.DialogGui.Adornee = self.Npc.PrimaryPart

    GuiRegistry:RegisterGui("NatashaDialog", {Gui = self.DialogGui})

    -- Wait a few seconds before entering dialog
    delay(3, function()
        self:EnterDialog()
    end)
end

return TutorialRunner