-- LoadingDots
-- MrAsync
-- 02/26/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local GuiTemplates = require("GuiTemplates")
local Config = require("LoadingDotsConfig")
local GuiRegistry = require("GuiRegistry")
local BasicPane = require('BasicPane')

local LoadingDots = setmetatable({}, BasicPane)
LoadingDots.__index = LoadingDots

function LoadingDots.new()
    local self = setmetatable(BasicPane.new(GuiTemplates:Clone("LoadingDotsTemplate")), LoadingDots)
    
    self.UUID = string.format("LoadingDots_%s", HttpService:GenerateGUID(false))
    GuiRegistry:RegisterGui(self.UUID, {Gui = self.Gui})

    self._Dots = {
        {Dot = self.Gui.DotOne},
        {Dot = self.Gui.DotTwo},
        {Dot = self.Gui.DotThree}
    }

    -- Initialize tweens for each dot
    for _, dotData in pairs(self._Dots) do
        dotData.Tween = TweenService:Create(
            dotData.Dot,
            Config.DotTweenInfo,
            {Position = dotData.Dot.Position - UDim2.fromScale(0, 0.5)}
        )

        self._maid:GiveTask(dotData.Tween)
    end

    -- Setup listeners
    for i, dotData in pairs(self._Dots) do
        local previousDot = self._Dots[(i - 1 < 1) and 3 or (i - 1)]
        
        self._maid:GiveTask(previousDot.Tween.Completed:Connect(function(playbackState)
            if (not playbackState == Enum.PlaybackState.Completed) then return end

            dotData.Tween:Play()
        end))
    end

    self.Gui.Position = Config.DefaultClosedPosition
    self.Gui.Visible = false

    return self
end

function LoadingDots:Show()
    self.Gui.Visible = true

    TweenService:Create(
        self.Gui,
        Config.GuiTweenInfo,
        {Position = Config.DefaultOpenPosition}
    ):Play()

    -- Play first tween
    self._Dots[1].Tween:Play()
end

function LoadingDots:Destroy()
    local exitTween = TweenService:Create(
        self.Gui,
        Config.GuiTweenInfo,
        {Position = Config.DefaultClosedPosition}
    )

    self._maid:GiveTask(exitTween)

    self._maid:GiveTask(exitTween.Completed:Connect(function(playbackState)
        if (not playbackState == Enum.PlaybackState.Completed) then return end

        GuiRegistry:UnregisterGui(self.UUID)
        self._maid:Destroy()
    end))

    exitTween:Play()
end

return LoadingDots