-- NetworkConfig
-- MrAsync
-- 03/06/2021


local require = require(game:GetService('ReplicatedStorage'):WaitForChild('Nevermore'))

local Table = require('Table')

return Table.readonly({
    Signals = {
        "PlayerDataReplicator"
    },

    Endpoints = {
        -- Required
        FetchDataSchema = require("FetchDataSchema"),
        FetchSessionToken = require("FetchSessionToken"),
        FetchNetworkSchema = require("FetchNetworkSchema"),

        -- Salon
        RequestSalon = require("RequestSalon"),

        -- Placement
        RequestItemPlace = require("RequestItemPlace")
    }
})