--- Retrieves GuiTemplates
-- @module GuiTemplates
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TemplateProvider = require("TemplateProvider")

return TemplateProvider.new(ReplicatedStorage.Assets)