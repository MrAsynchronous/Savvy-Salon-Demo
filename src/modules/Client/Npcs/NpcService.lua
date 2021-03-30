-- NpcService
-- MrAsync
-- 03/30/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local SoundService = game:GetService("SoundService")

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

                npcObject:MoveToPoint(childCFrame.Position + (child.Name == "SecretaryDesk" and childCFrame.LookVector * 5 or Vector3.new(0, 0, 0)))

                if (child.Name ~= "SecretaryDesk") then
                    npcObject.Character:SetPrimaryPartCFrame(child.Seat.CFrame + Vector3.new(0, 1.5, 0))
                    npcObject.Character.PrimaryPart.Anchored = true

                    npcObject:RunAnimation("2506281703")

                    if (child.Name == "CuttingStation") then
                        npcObject.Character.Head.CutParticle.Enabled = true

                        delay(2.5, function()
                            npcObject.Character.Before:Destroy()
                            npcObject.Character.After.Transparency = 0
                        end)

                        delay(5, function()
                            npcObject.Character.Head.CutParticle.Enabled = false
                            npcObject.Character.PrimaryPart.Anchored = false

                            npcObject:MoveToPoint(self.Salon.NpcExitPoint.Position)
                            npcObject:Destroy()
                        end)
                    elseif (child.Name == "ShampooStation") then
                        child.Bubbles.Emitter.Enabled = true
                        child.Water.Emitter.Enabled = true
                        SoundService.Water:Play()

                        delay(5, function()
                            child.Bubbles.Emitter.Enabled = false
                            child.Water.Emitter.Enabled = false
                            SoundService.Water:Stop()
                        end)
                    end
                end
            end)
        end))
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

        --vnpcObject.Character.PrimaryPart.Anchored = false
        npcObject.Prompt.Enabled = false
        npcObject.StateLock = true
        npcObject.State += 1

        -- Go to waiting chair
        if (npcObject.State == 2) then
            local waitingChairPoint = self.WaitingChair.PrimaryPart.Position
            npcObject:MoveToPoint(waitingChairPoint)

            npcObject.Character:SetPrimaryPartCFrame(self.WaitingChair.Seat.CFrame + Vector3.new(0, 1.5, 0))
        elseif (npcObject.State == 3) then
            local shampooStationPoint = self.ShampooStation.PrimaryPart.Position
            npcObject:MoveToPoint(shampooStationPoint)

            self.ShampooStation.Bubbles.Emitter.Enabled = true
            self.ShampooStation.Water.Emitter.Enabled = true
            SoundService.Water:Play()

            npcObject.Character:SetPrimaryPartCFrame(self.ShampooStation.Seat.CFrame + Vector3.new(0, 1.5, 0))
        elseif (npcObject.State == 4) then
            local cuttingStationPoint = self.CuttingStation.PrimaryPart.Position
            npcObject:MoveToPoint(cuttingStationPoint)

            npcObject.Character.Head.CutParticle.Enabled = true

            delay(2.5, function()
                npcObject.Character.Before:Destroy()
                npcObject.Character.After.Transparency = 0
            end)

            npcObject.Character:SetPrimaryPartCFrame(self.CuttingStation.Seat.CFrame + Vector3.new(0, 1.5, 0))
        end

        npcObject.Character.PrimaryPart.Anchored = true
        npcObject:RunAnimation("2506281703")

        local timer = npcObject.Character.Head.Timer
        timer.Enabled = true
        timer.Container.Label.Text = 5

        spawn(function()
            for i = 5, 1, -1 do
                timer.Container.Label.Text = i

                wait(1)
            end

            timer.Enabled = false
        end)

        delay(5, function()
            if (npcObject.State == 3) then
                self.ShampooStation.Bubbles.Emitter.Enabled = false
                self.ShampooStation.Water.Emitter.Enabled = false
                SoundService.Water:Stop()
            elseif (npcObject.State >= 4) then
                npcObject.Character.Head.CutParticle.Enabled = false
                --npcObject.Character.PrimaryPart.Anchored = false

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