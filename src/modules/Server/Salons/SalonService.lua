-- SalonService
-- MrAsync
-- 03/27/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local Workspace = game:GetService("Workspace")

local Salon = require("Salon")

local SalonContainer = Workspace:FindFirstChild("Salons")

local SalonService = {}
local Salons = {}    

function SalonService:LoanSalonToPlayer(player)
    local salonObject = SalonService:GetEmptySalon()
    local salonData = Salons[salonObject]

    local salon = Salon.new(player, salonObject)
    salonData.Owner = player.Player
    salonData.Object = salon

    return salon
end

function SalonService:ReturnSalon(player)
    local salonObject = SalonService:GetSalonFromPlayer(player)
    
    local salonData = Salons[salonObject.Object]
    salonData.Owner = nil
    salonData.Object = nil
    
    salonObject:Destroy()
end

function SalonService:GetSalonFromPlayer(player)
    for _, salonData in pairs(Salons) do
        if (salonData.Owner == player) then
            return salonData.Object
        end
    end

    return nil
end

function SalonService:GetEmptySalon()
    for salonObject, salonData in pairs(Salons) do
        if (salonData.Owner == nil) then
            return salonObject
        end
    end

    return nil
end

function SalonService:Init()
    for _, salon in pairs(SalonContainer:GetChildren()) do
        Salons[salon] = {
            Owner = nil,
            Object = nil
        }
    end
end

return SalonService