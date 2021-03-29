
--- Holds input keys for the game
-- @module InputKeyMap
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local Table = require("Table")
local INPUT_MODES = require("INPUT_MODES")
local InputKeyMapUtils = require("InputKeyMapUtils")

return Table.readonly({
	PLACEMENT = {
		InputKeyMapUtils.createKeyMap(INPUT_MODES.KeyboardAndMouse, { Enum.KeyCode.F });
		InputKeyMapUtils.createKeyMap(INPUT_MODES.Gamepads, { Enum.KeyCode.DPadUp });
		--InputKeyMapUtils.createKeyMap(INPUT_MODES.Touch, { "TouchButton" });
	};
	BUY_PLATE = {
		InputKeyMapUtils.createKeyMap(INPUT_MODES.KeyboardAndMouse, { Enum.KeyCode.G });
		InputKeyMapUtils.createKeyMap(INPUT_MODES.Gamepads, { Enum.KeyCode.DPadDown });
	};
	FREE_CAMERA = {
		InputKeyMapUtils.createKeyMap(INPUT_MODES.KeyboardAndMouse, { Enum.KeyCode.U });
		--InputKeyMapUtils.createKeyMap(INPUT_MODES.Gamepads, { Enum.KeyCode.DPadDown });
	}
})