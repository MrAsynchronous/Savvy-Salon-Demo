--- Scores actions and picks the highest rated one every frame
-- @module ScoredActionService
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local RunService = game:GetService("RunService")

local InputKeyMap = require("InputKeyMap")
local ScoredAction = require("ScoredAction")
local ScoredActionPicker = require("ScoredActionPicker")

local ScoredActionService = {}

function ScoredActionService:Init()
	self._scoredActionPicker = {}

	local count = 0
	for _, inputMode in pairs(InputKeyMap) do
		count = count + 1
		self._scoredActionPicker[inputMode] = ScoredActionPicker.new()
	end

	if count > 10 then
		-- Paranoid about performance
		warn("[ScoredActionService.Init] - Lots of actions bound! Do we need all of these")
	end

	RunService.Stepped:Connect(function()
		-- TODO: Push to end of frame so we don't delay input by a frame?
		self:_update()
	end)
end

function ScoredActionService:GetScoredAction(inputKeyMap)
	assert(type(inputKeyMap) == "table", "Bad inputKeyMap")
	assert(self._scoredActionPicker, "Not initialized")

	local picker = self._scoredActionPicker[inputKeyMap]
	if not picker then
		error("[ScoredActionService] - Tried to get a scored action for a non-existant input key map")
	end

	local action = ScoredAction.new()

	picker:AddAction(action)

	return action
end

function ScoredActionService:_update()
	for _, picker in pairs(self._scoredActionPicker) do
		picker:Update()
	end
end

return ScoredActionService