--- Main injection point
-- @script ServerMain
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

require("NetworkOwnerService"):Init()
require("FurnitureTemplates"):Init()
require("ServerTemplates"):Init()
require("ServerBinders"):Init()
require("AdminService"):Init()

-- Required
require("NetworkService"):Init()

require("SalonService"):Init()

-- Binders
require("ServerBinders"):AfterInit()