--!strict
-- Replaceable Base quest-giver presentation definitions.

local Definitions = {}

local GIVERS = table.freeze({
    WorldrootKeeper = table.freeze({
        Id = "WorldrootKeeper",
        Speaker = "Worldroot Keeper",
        QuestIds = table.freeze({
            "WorldrootRelic",
        }),
        Offset = CFrame.new(-18, 3, 6),
    }),
    Huntmaster = table.freeze({
        Id = "Huntmaster",
        Speaker = "Huntmaster",
        QuestIds = table.freeze({
            "ForestWolfBounty",
        }),
        Offset = CFrame.new(-9, 3, 12),
    }),
    VillageCaptain = table.freeze({
        Id = "VillageCaptain",
        Speaker = "Village Captain",
        QuestIds = table.freeze({
            "MarauderCaptainBounty",
            "DungeonBossHunt",
        }),
        Offset = CFrame.new(0, 3, 14),
    }),
    TempleArchivist = table.freeze({
        Id = "TempleArchivist",
        Speaker = "Temple Archivist",
        QuestIds = table.freeze({
            "HiddenWardDiscovery",
            "TempleResonancePuzzle",
            "FractureTrail",
            "TempleWardDefense",
        }),
        Offset = CFrame.new(10, 3, 12),
    }),
    MineWarden = table.freeze({
        Id = "MineWarden",
        Speaker = "Mine Warden",
        QuestIds = table.freeze({
            "MineEchoes",
            "CorruptedForemanBounty",
        }),
        Offset = CFrame.new(18, 3, 6),
    }),
    ExpeditionPathfinder = table.freeze({
        Id = "ExpeditionPathfinder",
        Speaker = "Expedition Pathfinder",
        QuestIds = table.freeze({
            "RuinSurvey",
        }),
        Offset = CFrame.new(18, 3, -6),
    }),
    SurveyCorps = table.freeze({
        Id = "SurveyCorps",
        Speaker = "Survey Corps",
        QuestIds = table.freeze({
            "MineSurveyorEscort",
        }),
        Offset = CFrame.new(9, 3, -12),
    }),
    ExpeditionQuartermaster = table.freeze({
        Id = "ExpeditionQuartermaster",
        Speaker = "Expedition Quartermaster",
        QuestIds = table.freeze({
            "ExpeditionProvisioning",
        }),
        Offset = CFrame.new(-10, 3, -12),
    }),
})

local ORDER = table.freeze({
    GIVERS.WorldrootKeeper,
    GIVERS.Huntmaster,
    GIVERS.VillageCaptain,
    GIVERS.TempleArchivist,
    GIVERS.MineWarden,
    GIVERS.ExpeditionPathfinder,
    GIVERS.SurveyCorps,
    GIVERS.ExpeditionQuartermaster,
})

--[[
Returns one quest-giver presentation definition.

Args:
    giver_id (string): Stable quest-giver role identifier.

Returns:
    any?: Frozen quest-giver definition when known.
]]
function Definitions.get(giver_id: string): any?
    return GIVERS[giver_id]
end

--[[
Lists quest-giver definitions in stable presentation order.

Args:
    None.

Returns:
    {any}: Frozen ordered quest-giver definitions.
]]
function Definitions.all(): {any}
    return ORDER
end

return table.freeze(Definitions)
