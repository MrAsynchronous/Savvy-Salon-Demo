-- DataService
-- MrAsync
-- 03/06/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local NetworkService = require("NetworkService")
local Signal = require("Signal")

local DataService = {}
local DataSchema = {}

--// Returns data associated with key
function DataService:Get(dataKey)
    local dataTable = DataSchema[dataKey]
    assert(dataTable, string.format("Invalid DataKey: %s", tostring(dataKey)))

    return dataTable.Value
end

--// Returns the signal associated with the dataKey
function DataService:GetUpdateSignal(dataKey)
    local dataTable = DataSchema[dataKey]
    assert(dataTable, string.format("Invalid DataKey: %s", tostring(dataKey)))

    return dataTable.Signal
end

function DataService:Init()
    NetworkService:Request("FetchDataSchema"):Then(function(playerData)
        for dataKey, value in pairs(playerData) do
            DataSchema[dataKey] = {
                Value = value,
                Signal = Signal.new()
            }
        end
    end)

    NetworkService:ObserveSignal("PlayerDataReplicator"):Connect(function(data)
        local dataTable = DataSchema[data.Key]

        dataTable.Signal:Fire(data.Value, dataTable.Value)
        dataTable.Value = data.Value

        print(string.format("%s changed to %s", data.Key, tostring(data.Value)))
    end)
end

return DataService