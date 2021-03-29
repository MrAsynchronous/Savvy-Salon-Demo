-- NetworkService
-- MrAsync
-- 03/06/2021

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local GetRemoteFunction = require("GetRemoteFunction")
local GetRemoteEvent = require("GetRemoteEvent")
local PlayerProvider = require("PlayerProvider")
local Config = require("NetworkConfig")

local NetworkService = {}
local Signals = {}

--// Registers endpoint and sets up listeners
function NetworkService:RegisterEndpoint(endpointName, callback)
    local endpointObject = GetRemoteFunction(endpointName)

    endpointObject.OnServerInvoke = function(player, publicToken, data)
        if (RunService:IsStudio()) then
            print(string.format("%s calling endpoint %s", player.Name, endpointName))
        end

        local ok, response = pcall(function()
            local rawResponse = {}
            
            local playerManager = PlayerProvider(player)
            if (not playerManager) then
                return {
                    error = "Player manager not found!"
                }
            end

            -- Validate token
            -- FetchSessionToken is the exception, because you can't validate a token without a token
            if (endpointName ~= "FetchSessionToken") then
                local privateToken = NetworkService:PublicToPrivateToken(publicToken)

                if (privateToken ~= playerManager._PrivateToken) then
                    return error("Session token mismatch!")
                end
            end

            -- Call callback and cache response
            callback(playerManager, table.unpack(data)):Then(function(res)
                rawResponse.data = (res ~= nil and res or true)
            end):Catch(function(err)
                if (type(err) == "table" and err.error ~= nil) then
                    rawResponse = err
                else
                    rawResponse.error = err
                end
            end):Wait()

            return rawResponse
        end)

        -- Check if pcall fails
        if (not ok) then
            return {
                error = response
            }
        else
            return response
        end

        return "404"
    end
end

--// Returns a new session token
function NetworkService:GetSessionToken()
    local privateToken = HttpService:GenerateGUID(false)
    local publicToken = NetworkService:_Cypher(privateToken, 5)

    return {
        PrivateToken = privateToken,
        PublicToken = publicToken
    }
end

--// Converts public token to private token
function NetworkService:PublicToPrivateToken(privateToken)
    return NetworkService:_Cypher(privateToken, -5)
end

--// Fires the client event
function NetworkService:SignalClient(signalName, playerManager, ...)
    local signalObject = Signals[signalName]
    assert(signalObject, string.format("Invalid signal: %s", signalName))

    signalObject:FireClient(playerManager.Player, ...)
end

--// Basic caesar cypher
function NetworkService:_Cypher(text, key)
    return string.gsub(text, "%a", function(t)
        local base = (string.lower(t) == t and string.byte('a') or string.byte('A'))

        local r = string.byte(t) - base
        r += key
        r = r % 26
        r += base

        return string.char(r)
    end)
end

function NetworkService:Init()
    for _, signal in pairs(Config.Signals) do
        Signals[signal] = GetRemoteEvent(signal)
    end

    for endpointName, callback in pairs(Config.Endpoints) do
        NetworkService:RegisterEndpoint(endpointName, callback)
    end
end

return NetworkService