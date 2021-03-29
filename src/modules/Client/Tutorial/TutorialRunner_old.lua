-- TutorialRunner
-- MrAsync
-- 03/28/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local SignalProvider = require("SignalProvider")
local NetworkService = require("NetworkService")
local Templates = require("FurnitureTemplates")
local CameraService = require("CameraService")
local GuiRegistry = require("GuiRegistry")
local Config = require("TutorialConfig")

local TutorialRunner = {}

function TutorialRunner:AdvanceDialog(npcDialogData, index)    
    RunService:UnbindFromRenderStep("NpcGrapheme")
    self.DialogGui.Container.TextContainer.Label.Text = ""

    local lastUpdate = tick()
    RunService:BindToRenderStep("NpcGrapheme", 1, function()
        if (tick() - lastUpdate < .025) then return end
        lastUpdate = tick()

        local sub = string.len(self.DialogGui.Container.TextContainer.Label.Text) + 1
        self.DialogGui.Container.TextContainer.Label.Text = string.sub(npcDialogData[index].Text, 1, sub)

        if (sub + 1 > string.len(npcDialogData[index].Text)) then
            RunService:UnbindFromRenderStep("NpcGrapheme")
        end
    end)
end

function TutorialRunner:SetupAnimation(npc, id)
    local humanoid = npc:FindFirstChildOfClass("Humanoid")

    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        track:Stop()
    end

    local animation = Instance.new("Animation")
    animation.AnimationId = id

    local track = humanoid:LoadAnimation(animation)
    track:Play()
end

function TutorialRunner:SetupNatasha()
    local natasha = self.Npcs.Natasha

    CameraService:EnterNpc(natasha)
    self.DialogGui.Adornee = natasha.PrimaryPart

    local currentIndex = 1
    self.DialogGui.Container.Next.MouseButton1Click:Connect(function()
        currentIndex += 1

        local dialogData = Config.Dialog.Natasha[currentIndex]

        if (dialogData == nil) then
            CameraService:ReturnToPlayer()
            GuiRegistry:UnregisterGui("Dialog")
            return
        end

        if (dialogData.ArrowToInventory) then
            local sidebarGui = GuiRegistry:GetGui("Sidebar").Gui
            sidebarGui.Arrow.Visible = true
            self.DialogGui.Container.Next.Visible = false

            local connection
            connection = SignalProvider:Get("SidebarButtonClicked"):Connect(function(name)
                if (name ~= "Inventory") then return end

                connection:Disconnect()
                sidebarGui.Arrow.Visible = false
                self.DialogGui.Container.Next.Visible = true

                currentIndex += 1

                self:AdvanceDialog(Config.Dialog.Natasha, currentIndex)
            end)

            TweenService:Create(sidebarGui.Arrow,
                TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, -1, true),
                {Position = UDim2.fromScale(2, 0.507)}
            ):Play()
        elseif (dialogData.ArrowToDesk) then
            local inventoryGui = GuiRegistry:GetGui("Inventory").Gui
            inventoryGui.Arrow.Visible = true
            self.DialogGui.Container.Next.Visible = false

            local connection
            connection = SignalProvider:Get("ItemPlaceBegan"):Connect(function(itemName)
                if (itemName ~= "SecretaryDesk") then return end

                connection:Disconnect()
                inventoryGui.Arrow.Visible = false
                self.DialogGui.Container.Next.Visible = true

                currentIndex += 1

                self:AdvanceDialog(Config.Dialog.Natasha, currentIndex)
            end)

            TweenService:Create(inventoryGui.Arrow,
                TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, -1, true),
                {Position = UDim2.fromScale(.125, -.5)}
            ):Play()
        end

        if (Config.Dialog.Natasha[currentIndex].Animation ~= nil) then
            self:SetupAnimation(natasha, Config.Dialog.Natasha[currentIndex].Animation)
        end

        self:AdvanceDialog(Config.Dialog.Natasha, currentIndex)
    end)

    if (Config.Dialog.Natasha[currentIndex].Animation ~= nil) then
        self:SetupAnimation(natasha, Config.Dialog.Natasha[currentIndex].Animation)
    end

    self:AdvanceDialog(Config.Dialog.Natasha, currentIndex)
end
    
function TutorialRunner:Init()
    NetworkService:Request("RequestSalon"):Then(function(salon)
        self.Salon = salon
        self.Npcs = salon.Npcs
        self.Placements = salon.Placements
    end)

    self.DialogGui = Templates:Clone("DialogGui")
    GuiRegistry:RegisterGui("Dialog", {Gui = self.DialogGui})

    delay(5, function()
        TutorialRunner:SetupNatasha()
    end)
end

return TutorialRunner