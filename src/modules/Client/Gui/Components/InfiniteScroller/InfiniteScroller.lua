-- InfiniteScroller
-- MrAsync
-- 02/24/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local TweenService = game:GetService("TweenService")

local Config = require("InfiniteScrollerConfig")
local BasicPane = require('BasicPane')
local Button = require("Button")
local Signal = require("Signal")
local Math = require("Math")

local InfiniteScroller = setmetatable({}, BasicPane)
InfiniteScroller.__index = InfiniteScroller

function InfiniteScroller.new(container, config)
    local self = setmetatable(BasicPane.new(container), InfiniteScroller)
    assert(config, "No config provided!")
    assert(config.ButtonLast, "No ButtonLast provided!")
    assert(config.ButtonNext, "No ButtonNext provided!")
    assert(config.CardSize, "No CardSize provided!")
    
    -- Parse arguments
    self._NextButton = config.ButtonNext
    self._LastButton = config.ButtonLast
    self._CardSize = config.CardSize
    self._Padding = (config.Padding or Config.Padding)

    self._SelectedCardSize = (config.SelectedCardSize or UDim2.fromScale(
        self._CardSize.X.Scale * 1.25,
        self._CardSize.Y.Scale * 1.25
    ))

    self._StartingPosition = Config.StartingPoint - UDim2.fromScale(
        self._CardSize.X.Scale + self._Padding,
        0
    )

    -- Vars
    self._Cards = {}
    self._SelectedCards = {}

    self.SelectionChanged = Signal.new()
    self._maid:GiveTask(self.SelectionChanged)

    -- Setup buttons
    local buttonNext = Button.new(self._NextButton)
    local buttonLast = Button.new(self._LastButton)

    buttonNext:SetButton1Click(function()
        self:_AdjustCards(1)
    end)

    buttonLast:SetButton1Click(function()
        self:_AdjustCards(-1)
    end)

    return self
end


function InfiniteScroller:AddChild(card)
    -- Space card out
    card.Position = self._StartingPosition + UDim2.fromScale(
        (#self._Cards * (self._CardSize.X.Scale + self._Padding)),
        0
    )

    -- Make the center card bigger
    if (#self._Cards == 1) then
        card.Size = self._SelectedCardSize
    end

    -- Insert card into stack
    table.insert(self._Cards, {
        Position = card.Position,
        Card = card
    })
end

function InfiniteScroller:RemoveChild(cardToRemove)
    for i, cardData in pairs(self._Cards) do
        if (cardData.Card == cardToRemove) then
            table.remove(self._Cards, i)

            break
        end
    end

    cardToRemove:Destroy()

    for i, cardData in pairs(self._Cards) do
        local newPosition = self._StartingPosition + UDim2.fromScale(
            ((i - 1) * (self._CardSize.X.Scale + self._Padding)),
            0
        )

        cardData.Position = newPosition
        cardData.Card.Position = newPosition
    end

    return
end

function InfiniteScroller:GetSelectedChild()
    return self._SelectedChild
end

function InfiniteScroller:_AdjustCards(direction)
    -- Create the infinite scrolling
    if (direction == -1) then
        local cardAData = self._Cards[1]
        
        local cardBData = table.remove(self._Cards, #self._Cards)
        local cardB = cardBData.Card
    
        -- Swap positions
        cardBData.Position = cardAData.Position - UDim2.fromScale(
            Math.round(self._CardSize.X.Scale + self._Padding, 0.01),
            0
        )
            
        cardB.Position = cardBData.Position

        -- Insert card at from
        table.insert(self._Cards, 1, cardBData)
    else
        local cardAData = table.remove(self._Cards, 1)

        -- Only remove the lowest card if it's off the screen
        if (cardAData.Position.X.Scale < 0) then
            local cardBData = self._Cards[#self._Cards]
            local cardA = cardAData.Card
        
            -- Swap positions
            cardAData.Position = cardBData.Position + UDim2.fromScale(
                Math.round(self._CardSize.X.Scale + self._Padding, 0.01),
                0
            )

            cardA.Position = cardAData.Position
    
            -- Insert back at the end of list
            table.insert(self._Cards, #self._Cards + 1, cardAData)
        else
            -- Re-insert it back into the front of the list
            table.insert(self._Cards, 1, cardAData)
        end
    end

    -- Iterate through all cards
    for _, cardData in pairs(self._Cards) do
        local currentPosition = cardData.Position
        local card = cardData.Card

        local size = self._CardSize
        local offset = size.X.Scale + self._Padding

        -- Construct a new UDim2 that moves the UI in the right direction
        cardData.Position = UDim2.fromScale(
            Math.round(currentPosition.X.Scale + (direction < 0 and offset or -offset), 0.01),
            currentPosition.Y.Scale
        )

        -- Check if the frame is centered
        if (cardData.Position.X.Scale > Config.CenterBounds.Min and cardData.Position.X.Scale < Config.CenterBounds.Max) then
            size = self._SelectedCardSize

            self._SelectedChild = card
            self.SelectionChanged:Fire(card)
        end

        -- Finally create and play the tween
        TweenService:Create(card, Config.CardTweenInfo, {
            Position = cardData.Position,
            Size = size
        }):Play()
    end
end


function InfiniteScroller:Destroy()
    self._maid:Destroy()
end

return InfiniteScroller