---
-- @classmod BasicKeymapControls
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local BaseObject = require("BaseObject")
--local CameraStackService = require("CameraStackService")
local fastSpawn = require("fastSpawn")
local HapticFeedbackUtils = require("HapticFeedbackUtils")
local InputKeyMapUtils = require("InputKeyMapUtils")
local ScoredActionService = require("ScoredActionService")
local ScoredActionUtils = require("ScoredActionUtils")
local ScreenGuiProvider = require("ScreenGuiProvider")
local Signal = require("Signal")
-- local SoundUtilsClient = require("SoundUtilsClient")

local BasicKeymapControls = setmetatable({}, BaseObject)
BasicKeymapControls.ClassName = "BasicKeymapControls"
BasicKeymapControls.__index = BasicKeymapControls

function BasicKeymapControls.new(inputType, text, doNotShowEntry)
	local self = setmetatable(BaseObject.new(), BasicKeymapControls)

	self._inputType = assert(inputType, "No inputType")
	self._text = assert(text, "No text")

	self._key = HttpService:GenerateGUID(false)

	self.Activated = Signal.new()
	self._maid:GiveTask(self.Activated)

	self.Deactivated = Signal.new()
	self._maid:GiveTask(self.Deactivated)

	self._maid:GiveTask(self.Activated:Connect(function()
		HapticFeedbackUtils.smallVibrate(UserInputService:GetLastInputType())
		--CameraStackService:GetImpulseCamera():Impulse(Vector3.new(0.25, 0, 0.25*(math.random()-0.5)))
		-- SoundUtilsClient.playTemplate("ButtonPlopTemplate")
	end))

	self._scoredAction = ScoredActionService:GetScoredAction(self._inputType)
	self._scoredAction:SetScore(math.huge) -- Let's just reserve this!
	self._maid:GiveTask(self._scoredAction)

	self:_bindControls()

	return self
end

function BasicKeymapControls:_bindControls()
	self._maid:GiveTask(ScoredActionUtils.connectToPreferred(self._scoredAction, function(maid)
		ContextActionService:BindActionAtPriority(
			self._key .. "BasicKeymapControl",
			function(actionName, userInputState, inputObject)
				if userInputState == Enum.UserInputState.Begin then
					self.Activated:Fire()
				elseif userInputState == Enum.UserInputState.End then
					self.Deactivated:Fire()
				end
			end,
			InputKeyMapUtils.isTouchButton(self._inputType),
			Enum.ContextActionPriority.High.Value,
			unpack(InputKeyMapUtils.getInputTypesForActionBinding(self._inputType)))
		ContextActionService:SetTitle(self._key .. "BasicKeymapControl", self._text)

		maid:GiveTask(function()
			ContextActionService:UnbindAction(self._key .. "BasicKeymapControl")
		end)

		if InputKeyMapUtils.isTouchButton(self._inputType) then
			-- TODO: Eventually use custom buttons :/
			fastSpawn(function()
				-- Yielding
				local button = ContextActionService:GetButton(self._key .. "BasicKeymapControl")
				if not button then
					return
				end

				if not self.Destroy then
					return
				end

				local screenGui = button:FindFirstAncestorOfClass("ScreenGui")
				if not screenGui then
					return
				end

				screenGui.DisplayOrder = ScreenGuiProvider:GetDisplayOrder("INPUT_TOUCH_BUTTONS")
			end)
		end

		if InputKeyMapUtils.isTapInWorld(self._inputType) then
			maid:GiveTask(UserInputService.TouchTapInWorld:Connect(function(position, processedByUI)
				if not processedByUI then
					self.Activated:Fire()
				end
			end))
		end
	end))
end

return BasicKeymapControls