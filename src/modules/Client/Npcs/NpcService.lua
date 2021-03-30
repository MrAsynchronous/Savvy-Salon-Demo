-- NpcService
-- MrAsync
-- 03/30/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local NetworkService = require("NetworkService")
local Npc = require("Npc")

local Characters = {
    "Kyle",
    "Charlette",
    "Marc"
}

local NpcService = {}

function NpcService:StartLoop(placedObjects)
    -- Cache things
    for name, object in pairs(placedObjects) do
        self[name] = object
    end

    self:CreateNpc()
end

function NpcService:CreateNpc(isFirstNpc)
    local npcObject = Npc.new(
        self.Salon,
        Characters[math.random(1, 3)],
        CFrame.new(self.Salon.FirstNpc.Position, self.Salon.NatashaPoint.Position)
    )

    -- Disable prompt
    npcObject.Prompt.Enabled = false

    if (isFirstNpc) then
        npcObject._maid:GiveTask(self.Salon.Placements.ChildAdded:Connect(function(child)
            delay(0.5, function()
                local childCFrame = child.PrimaryPart.CFrame

                npcObject.Character.PrimaryPart.Anchored = false
                npcObject:MoveToPoint(childCFrame.Position + (child.Name == "SecretaryDesk" and childCFrame.LookVector * 5 or Vector3.new()))
                
                if (child.Name ~= "SecretaryDesk") then
                    npcObject.Character.Humanoid.Sit = true
                    npcObject.Character.PrimaryPart.Anchored = true
                elseif (child.Name == "CuttingStation") then
                    delay(5, function()
                        npcObject:MoveToPoint(self.Salon.NpcExitPoint.Position)
                        npcObject:Destroy()
                    end)
                end
            end)
        end))

        return npcObject
    else
        local deskCFrame = self.SecretaryDesk.PrimaryPart.CFrame
        npcObject:MoveToPoint(deskCFrame.Position + (deskCFrame.LookVector * 5))

        npcObject.Prompt.Enabled = true
    end

    --[[
        STATES:
            1: Idle (outside)
            2: Waiting (inside)
            3: Shampoo
            4: Cutting
    ]]
    
    npcObject._maid:GiveTask(npcObject.Prompt.Triggered:Connect(function()
        if (npcObject.StateLock) then return end

        -- Create new NP

        npcObject.Character.PrimaryPart.Anchored = false
        npcObject.Prompt.Enabled = false
        npcObject.StateLock = true
        npcObject.State += 1

        -- Go to waiting chair
        if (npcObject.State == 2) then
            local waitingChairPoint = self.WaitingChair.PrimaryPart.Position
            npcObject:MoveToPoint(waitingChairPoint)
        elseif (npcObject.State == 3) then
            local shampooStationPoint = self.ShampooStation.PrimaryPart.Position
            npcObject:MoveToPoint(shampooStationPoint)
        elseif (npcObject.State == 4) then
            local cuttingStationPoint = self.CuttingStation.PrimaryPart.Position
            npcObject:MoveToPoint(cuttingStationPoint)
        end

        npcObject.Character.Humanoid.Sit = true
        npcObject.Character.PrimaryPart.Anchored = true

        delay(0, function()
            if (npcObject.State > 4) then
                local exitPoint = self.Salon.NpcExitPoint.Position
                npcObject:MoveToPoint(exitPoint)

                npcObject:Destroy()

                self:CreateNpc()

                return
            end

            npcObject.StateLock = false
            npcObject.Prompt.Enabled = true
        end)
    end))

    return npcObject
end
    
function NpcService:Init()
    NetworkService:Request("RequestSalon"):Then(function(salon)
        self.Salon = salon
    end)
end

return NpcService