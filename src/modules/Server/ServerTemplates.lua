--- Retrieves GuiTemplates
-- @module GuiTemplates
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local ServerStorage = game:GetService("ServerStorage")

local TemplateProvider = require("TemplateProvider")

return TemplateProvider.new(ServerStorage.Assets)