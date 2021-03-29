--- Providers screenGuis with a given display order for easy use
-- @module ScreenGuiProvider
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Table = require("Table")
local String = require("String")

local ScreenGuiProvider = {}

--- Returns a new ScreenGui at DisplayOrder specified
-- @tparam string orderName Order name of screenGui
function ScreenGuiProvider:Get(orderName)
	if not RunService:IsRunning() then
		return self:_mockScreenGui()
	end

	local localPlayer = Players.LocalPlayer
	if not localPlayer then
		error("[ScreenGuiProvider] - No localPlayer")
	end

	local playerGui = localPlayer.PlayerGui

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = String.toCamelCase(orderName)
	screenGui.ResetOnSpawn = false
	screenGui.AutoLocalize = false
	screenGui.DisplayOrder = self:GetDisplayOrder(orderName)
	screenGui.Parent = playerGui
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	return screenGui
end

function ScreenGuiProvider:GetDisplayOrder(orderName)
	assert(type(orderName) == "string")
	assert(self._order[orderName], ("No DisplayOrder with orderName '%s'"):format(tostring(orderName)))

	return self._order[orderName]
end

function ScreenGuiProvider:SetupMockParent(target)
	assert(not RunService:IsRunning())
	assert(target)

	rawset(self, "_mockParent", target)

	return function()
		if rawget(self, "_mockParent") == target then
			rawset(self, "_mockParent", nil)
		end
	end
end

function ScreenGuiProvider:_mockScreenGui()
	assert(rawget(self, "_mockParent"), "No _mockParent set")

	local mock = Instance.new("Frame")
	mock.Size = UDim2.new(1, 0, 1, 0)
	mock.BackgroundTransparency = 1
	mock.Parent = rawget(self, "_mockParent")

	return mock
end

return Table.readonly(ScreenGuiProvider)