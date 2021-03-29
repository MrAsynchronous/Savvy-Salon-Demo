-- NetworkService
-- MrAsync
-- 03/06/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local GetRemoteFunction = require("GetRemoteFunction")
local GetRemoteEvent = require("GetRemoteEvent")
local Promise = require("Promise")

local EndpointContainer = ReplicatedStorage:WaitForChild("RemoteFunctions")
local SignalContainer = ReplicatedStorage:WaitForChild("RemoteEvents")

local PublicToken

local NetworkService = {}
local EndpointSchema = {}
local SignalSchema = {}
   
--// Constructs and sends a network request
function NetworkService:Request(endpointName, ...)
    local data = {...}

    return Promise.new(function(resolve, reject)
        local endpointObject = EndpointSchema[endpointName]
        if (not endpointObject) then
            return reject(string.format("Invalid endpoint: %s", endpointName))
        end

        local ok, response = pcall(function()
            return endpointObject:InvokeServer(PublicToken, data)
        end)

        if (not ok) then
            return reject(response)
        else
            if (response.error) then
                return reject(response.error)
            else
                return resolve(response.data)
            end
        end
    end)
end

--// Sends a signal to the server with the given data
function NetworkService:SignalServer(signalName, data)
    local signalObject = SignalSchema[signalName]
    assert(signalObject, string.format("Invalid signal: %s", signalName))

    signalObject:FireServer(data)

    return
end

--// Returns OnClientEvent for signalName
function NetworkService:ObserveSignal(signalName)
    local signalObject = SignalSchema[signalName]
    assert(signalObject, string.format("Invalid signal: %s", signalName))

    return signalObject.OnClientEvent
end

function NetworkService:Init()
    EndpointSchema["FetchNetworkSchema"] = GetRemoteFunction("FetchNetworkSchema")
    EndpointSchema["FetchSessionToken"] = GetRemoteFunction("FetchSessionToken")

    --// We need to grab the public session token first, so the server can
    --// validate our future requests
    self:Request("FetchSessionToken"):Then(function(publicToken)
        PublicToken = publicToken
    end):Then(function()

        --// Send a request to fetch network schema, to map out the network interface
        --// so we can start scrambeling the names
        self:Request("FetchNetworkSchema"):Then(function(schema)
            for _, endpointName in pairs(schema.Endpoints) do
                EndpointSchema[endpointName] = GetRemoteFunction(endpointName)
            end
    
            for _, signalName in pairs(schema.Signals) do
                SignalSchema[signalName] = GetRemoteEvent(signalName)
            end
        end):Catch(function(err)
            
            error(string.format("Error fetching network schema: %s", tostring(err)))
    
        end):Finally(function()
            EndpointSchema["FetchNetworkSchema"] = nil
            EndpointSchema["FetchSessionToken"] = nil

            --// Begin scrambling the names of the endpoints and signals
            local lastUpdated = os.time()
            RunService.RenderStepped:Connect(function()
                if (os.time() - lastUpdated < 2) then return end
                lastUpdated = os.time()
    
                for _, endpoint in pairs(EndpointContainer:GetChildren()) do
                    endpoint.Name = HttpService:GenerateGUID(false)
                end
    
                for _, signal in pairs(SignalContainer:GetChildren()) do
                    signal.Name = HttpService:GenerateGUID(false)
                end
            end)
        end)

    end):Catch(function(err)
        error(string.format("Couldn't retrieve public token: %s", tostring(err)))
    end)
end

return NetworkService