-- Button
-- MrAsync
-- 12/10/2020

local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local TweenService = game:GetService("TweenService")

local SoundProvider = require("SoundProvider")
local Config = require("ButtonConfig")
local BasicPane = require("BasicPane")

local Button = setmetatable({}, BasicPane)
Button.ClassName = 'Button'
Button.__index = Button

--// Constructor
function Button.new(guiButton)
    local self = setmetatable(BasicPane.new(guiButton), Button)
    
    -- Assertions
    if (not guiButton:IsA("ImageButton") and not guiButton:IsA("TextButton")) then
        return warn(string.format("Invalid button: %s.  Expected ImageButton or TextButton!", guiButton.ClassName))
    end

    -- Derive button from container
    self.Button = self.Gui
    self.CanHover = true
    self.Enabled = true

    self.MouseEnter = self.Button.MouseEnter
    self.MouseLeave = self.Button.MouseLeave
    self.MouseButton1Click = self.Button.MouseButton1Click

    -- Cache original color
    if (self.Button:IsA("ImageButton")) then
        self._OriginalColor = self.Button.ImageColor3
    elseif (self.Button:IsA("TextButton")) then
        self._OriginalColor = self.Button.TextColor3
    end

    self.MouseButton1Click:Connect(function()
        SoundProvider:PlaySound("UIButtonClick")

        return self:_Button1Click()
    end)

    -- Mouse enter effect
    self.MouseEnter:Connect(function()
        if (not self.CanHover) then return end
        self.Hovering = true

        return self:_MouseEnter()
    end)

    -- Mouse leave effect
    self.MouseLeave:Connect(function()
        self.Hovering = false

        return self:_MouseLeave()
    end)

    return self
end

function Button:SetButton1Click(callback)
    self._Button1Click = callback
end

--// Sets the callback function ran when MouseEnter is fired
function Button:SetMouseEnter(callback)
    self._MouseEnter = callback
end

--// Sets the callback function ran when MouseLeave is fired
function Button:SetMouseLeave(callback)
    self._MouseLeave = callback
end

--// Method that is called when MouseButton1Click is firedß
function Button:_Button1Click() end

--// Method that is called when MouseEnter is fired
function Button:_MouseEnter()
    local tweenData = {TextColor3 = Config.TextHoverColor}
    if (self.Button:IsA("ImageButton")) then
        local baseColor = self.Button.ImageColor3
        local hoverColor = Color3.fromRGB(
            math.clamp((baseColor.R * 255) - Config.ImageHoverShade, 0, 255),
            math.clamp((baseColor.G * 255) - Config.ImageHoverShade, 0, 255),
            math.clamp((baseColor.B * 255) - Config.ImageHoverShade, 0, 255)
        )
        
        tweenData = {ImageColor3 = hoverColor}
    end
    
    TweenService:Create(self.Button, Config.ColorTweenInfo, tweenData):Play()
end

--// Method that is called when MouseEnter is fired
function Button:_MouseLeave()
    -- Assign property based on type of gui
    local tweenInfo = {TextColor3 = self._OriginalColor}
    if (self.Button:IsA("ImageButton")) then
        tweenInfo = {ImageColor3 = self._OriginalColor}
    end

    TweenService:Create(self.Button, Config.ColorTweenInfo, tweenInfo):Play()
end

function Button:Destroy()
    self._maid:Destroy()
end

return Button