--- Main injection point
-- @script ClientrMain
-- @author Synth_o

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))

Cmdr:SetActivationKeys({ Enum.KeyCode.Semicolon })
Cmdr:SetPlaceName('Lunar')

local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local Players = game:GetService("Players")

--// Order matters
require("HumanoidTracker").new(Players.LocalPlayer)
require("ScoredActionService"):Init()
require("FurnitureTemplates"):Init()
require("GuiTemplates"):Init()

-- Client binders
require("ClientBinders"):Init()

-- High Level services
require("NetworkService"):Init()
require("DataService"):Init()
require("CameraService"):Init()

-- Medium level module
require("PlacementService"):Init()
require("SignalProvider"):Init()
require("GuiRegistry"):Init()

-- Low level things
require("TutorialRunner"):Init()
require("NpcService"):Init()

-- Binders
require("ClientBinders"):AfterInit()