-- PlacementService
-- MrAsync
-- 03/27/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local UserInputService = game:GetService("UserInputService")

local SignalProvider = require("SignalProvider")
local NetworkService = require("NetworkService")
local Placement = require("Placement")
local Maid = require("Maid")

local PlacementService = {}
local CurrentSession = nil
local SalonObject = nil
local _maid = Maid.new()

function PlacementService:StartPlacing(itemName)
    if (PlacementService:IsPlacing()) then PlacementService:StopPlacing() end

    self.ItemPlaceBegan:Fire(itemName)

    local session = Placement.new(SalonObject, itemName)
    CurrentSession = session

    -- Init
    SalonObject.PrimaryPart.Grid.Transparency = 0.5

    _maid:GiveTask(session.Placed:Connect(function(worldPosition)
        if (self._PlaceLock) then return end
        
        NetworkService:Request("RequestItemPlace", itemName, worldPosition):Then(function(object)
            self.ItemPlaced:Fire(itemName, object)

            self:StopPlacing()
        end)
    end))

    _maid:GiveTask(session.Cancelled:Connect(function()
        self:StopPlacing()
    end))

    return session
end

function PlacementService:SetPlaceLock(state)
    self._PlaceLock = state
end

function PlacementService:StopPlacing()
    if (CurrentSession == nil) then return end

    CurrentSession:Destroy()
    CurrentSession = nil

    SalonObject.PrimaryPart.Grid.Transparency = 1
end

function PlacementService:IsPlacing()
    return (CurrentSession ~= nil)
end
    
function PlacementService:Init()
    NetworkService:Request("RequestSalon"):Then(function(salonObject)
        SalonObject = salonObject
    end)

    self.ItemPlaceBegan = SignalProvider:Get("ItemPlaceBegan")
    self.ItemPlaced = SignalProvider:Get("ItemPlaced")
    self._PlaceLock = false
end

return PlacementService