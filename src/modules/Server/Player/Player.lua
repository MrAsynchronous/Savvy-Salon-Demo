--[[
    Player.lua
    MrAsync & Lxuca
    06/03/2021
--]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local require = require(ReplicatedStorage:WaitForChild('Nevermore'))

local NetworkService = require("NetworkService")
local ProfileService = require("ProfileService")
local SalonService = require("SalonService")
local PlayerConfig = require("PlayerConfig")
local BaseObject = require('BaseObject')
local Table = require("Table")

local ProfileStore = ProfileService.GetProfileStore(
    PlayerConfig.DataKey,
    PlayerConfig.DataSchema
)

local Player = setmetatable({}, BaseObject)
Player.__index = Player

--// Constructor
function Player.new(player)
    local self = setmetatable(BaseObject.new(), Player)

    self.Profile = ProfileStore:LoadProfileAsync(
        ("Player_%d"):format(player.UserId),
        "ForceLoad"
    )

    if (self.Profile == nil) then
        return player:Kick("Your data failed to load. Please try rejoining, if the issue persists contact a developer.")
    end

    self.Player = player
    self._JoinTime = os.time()

    -- Create network tokens
    local tokens = NetworkService:GetSessionToken()
    self._PublicToken = tokens.PublicToken
    self._PrivateToken = tokens.PrivateToken

    -- Update data schema
    self.Profile:Reconcile()
    self:_ForwardProperties()

    -- Other init
    self.Salon = SalonService:LoanSalonToPlayer(self)

    return self
end

--// Returns players salon
function Player:GetSalon()
    return self.Salon
end

--// Get's data associated with the given key
--// Returns data schema if key is nil
function Player:GetData(key)
    if (key == nil) then
        return Table.deepCopy(self.Profile.Data)
    else
        return Table.deepCopy(self.Profile.Data)[key]
    end
end

--// Overwrites player data
function Player:SetData(key, data)
    assert(self.Profile.Data[key] ~= nil, string.format("Invalid DataKey %s", key))
    assert(
        type(self.Profile.Data[key]) == type(data),
        string.format("Type mismatch expected %s got %s", type(self.Profile.Data[key]), type(data))
    )

    self.Profile.Data[key] = data

    NetworkService:SignalClient("PlayerDataReplicator", self, {
        Key = key,
        Value = data
    })

    return data
end

--// Overwrites the players data while passing
--// the current value as the argument
function Player:UpdateData(key, callback)
    local success, data = pcall(callback, self:GetData(key))

    if (not success) then
        warn(string.format("Failed to update data: %s", tostring(data)))

        return false
    end

    self:SetData(key, data)

    return true
end

--// Forwards certain properties and events to class
function Player:_ForwardProperties()
    for _, property in pairs(PlayerConfig.InstanceApiSchema) do
        self[property] = self.Player[property]
    end
end

--// Destructor
function Player:Destroy()
    self:UpdateData("_Visits", function(visits)
        return visits + 1
    end)

    self:UpdateData("_Playtime", function(playtime)
        return playtime + (os.time() - self._JoinTime)
    end)

    self.Profile:Release()
end

return Player