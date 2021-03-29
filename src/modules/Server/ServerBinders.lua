--- Holds binders
-- @classmod ServerBinders
-- @author Synth_o

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local Binder = require("Binder")
local PlayerBinder = require("PlayerBinder")
local BinderProvider = require("BinderProvider")

return BinderProvider.new(function(self)

    self:Add(PlayerBinder.new("Player", require("Player")))

end)