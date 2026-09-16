--!strict
local TravelDestinationDefinitions = {}

local DEFINITIONS = table.freeze({
    Market = table.freeze({
        Id = "Market",
        Name = "Market",
        AnchorId = "Base.Travel.Market",
        SortOrder = 1,
    }),
    Dwarves = table.freeze({
        Id = "Dwarves",
        Name = "Dwarven Area",
        AnchorId = "Base.Travel.Dwarves",
        SortOrder = 2,
    }),
    Portals = table.freeze({
        Id = "Portals",
        Name = "Dungeon Portals",
        AnchorId = "Base.Travel.Portals",
        SortOrder = 3,
    }),
    Orcs = table.freeze({
        Id = "Orcs",
        Name = "Orc Area",
        AnchorId = "Base.Travel.Orcs",
        SortOrder = 4,
    }),
})

TravelDestinationDefinitions.ORDER = table.freeze({
    "Market",
    "Dwarves",
    "Portals",
    "Orcs",
})

function TravelDestinationDefinitions.get(destination_id: string): any?
    return DEFINITIONS[destination_id]
end

function TravelDestinationDefinitions.all(): any
    return DEFINITIONS
end

return table.freeze(TravelDestinationDefinitions)
