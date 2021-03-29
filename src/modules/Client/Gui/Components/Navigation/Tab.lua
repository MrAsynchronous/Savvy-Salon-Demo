-- Tab
-- MrAsync
-- 12/10/2020

local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local TweenService = game:GetService("TweenService")

local BasicPane = require('BasicPane')
local Config = require("TabConfig")
local Signal = require("Signal")

local Tab = setmetatable({}, BasicPane)
Tab.ClassName = 'Tab'
Tab.__index = Tab

--// Constructor
function Tab.new(container, buttonHash)
    local self = setmetatable(BasicPane.new(container), Tab)

    self.Buttons = buttonHash
    self.Line = container:FindFirstChild("Line")
    
    self.TabChanged = Signal.new()

    -- Initialize buttons
    for _, buttonData in pairs(self.Buttons) do
        local buttonObject = buttonData.Button
        local frame = buttonData.Frame

        -- Listen to button1Click to change menu
        buttonObject.MouseButton1Click:Connect(function()
            TweenService:Create(self.Line, Config.LineTweenInfo, {Position = Config.LineOffset(buttonObject.Gui)}):Play()
            
            frame.Visible = true
            
            -- Hide the other menues
            for _, otherButtonData in pairs(self.Buttons) do
                if (otherButtonData.Frame == frame) then continue end
                otherButtonData.Frame.Visible = false
            end

            -- Fire events
            self.TabChanged:Fire(buttonObject.Gui.Name)
        end)
    end

    return self
end

function Tab:Destroy()
    self._maid:Destroy()
end

return Tab