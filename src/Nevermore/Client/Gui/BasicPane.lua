--- Base UI object with visibility and a maid
-- @classmod BasicPane
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local Signal = require("Signal")
local Maid = require("Maid")

local BasicPane = {}
BasicPane.__index = BasicPane
BasicPane.ClassName = "BasicPane"

---
-- @param[opt] gui
function BasicPane.new(gui)
	local self = setmetatable({}, BasicPane)

	self._maid = Maid.new()
	self.Maid = self._maid

	self._visible = false

	self.VisibleChanged = Signal.new() -- :Fire(isVisible, doNotAnimate, maid)
	self._maid:GiveTask(self.VisibleChanged)

	self._components = {}

	if gui then
		self._gui = gui
		self.Gui = gui
		self._maid:GiveTask(gui)
	end

	return self
end

function BasicPane:GetComponent(name)
	return self._components[name]
end

function BasicPane:RemoveComponent(name)
	self._components[name] = nil
end

function BasicPane:RegisterComponent(name, object)
	self._components[name] = object
end

function BasicPane:RegisterComponents(components)
	for name, object in pairs(components) do
		self:RegisterComponent(name, object)
	end
end

function BasicPane:SetVisible(isVisible, doNotAnimate)
	assert(type(isVisible) == "boolean")

	if self._visible ~= isVisible then
		self._visible = isVisible

		local maid = Maid.new()
		self._maid._paneVisibleMaid = maid
		self.VisibleChanged:Fire(self._visible, doNotAnimate, maid)
	end
end

function BasicPane:Show(doNotAnimate)
	self:SetVisible(true, doNotAnimate)
end

function BasicPane:Hide(doNotAnimate)
	self:SetVisible(false, doNotAnimate)
end

function BasicPane:Toggle(doNotAnimate)
	self:SetVisible(not self._visible, doNotAnimate)
end

function BasicPane:IsVisible()
	return self._visible
end

function BasicPane:Destroy()
	self._maid:DoCleaning()
	self._maid = nil
	setmetatable(self, nil)
end

return BasicPane