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
        AnchorId = "Base.Service.Progression",
        Offset = Vector3.new(-38, 0, 24),
        Style = "Keeper",
        ClothingColor = Color3.fromRGB(72, 105, 69),
        AccentColor = Color3.fromRGB(196, 168, 88),
    }),
    Huntmaster = table.freeze({
        Id = "Huntmaster",
        Speaker = "Huntmaster",
        QuestIds = table.freeze({
            "ForestWolfBounty",
        }),
        AnchorId = "Base.Travel.Orcs",
        Offset = Vector3.new(18, 0, -14),
        Style = "Hunter",
        ClothingColor = Color3.fromRGB(91, 70, 48),
        AccentColor = Color3.fromRGB(86, 126, 72),
    }),
    VillageCaptain = table.freeze({
        Id = "VillageCaptain",
        Speaker = "Village Captain",
        QuestIds = table.freeze({
            "MarauderCaptainBounty",
            "DungeonBossHunt",
        }),
        AnchorId = "Base.Trainer.Fighter",
        Offset = Vector3.new(-26, 0, -22),
        Style = "Captain",
        ClothingColor = Color3.fromRGB(59, 75, 103),
        AccentColor = Color3.fromRGB(189, 157, 78),
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
        AnchorId = "Base.TemplePortal",
        Offset = Vector3.new(18, 0, -18),
        Style = "Archivist",
        ClothingColor = Color3.fromRGB(91, 68, 115),
        AccentColor = Color3.fromRGB(203, 171, 103),
    }),
    MineWarden = table.freeze({
        Id = "MineWarden",
        Speaker = "Mine Warden",
        QuestIds = table.freeze({
            "MineEchoes",
            "CorruptedForemanBounty",
        }),
        AnchorId = "Base.DwarfQuestHub",
        FallbackAnchorId = "Base.Travel.Dwarves",
        Offset = Vector3.new(-24, 0, -11),
        Style = "Warden",
        Scale = 0.84,
        ClothingColor = Color3.fromRGB(96, 73, 55),
        AccentColor = Color3.fromRGB(180, 112, 55),
    }),
    ExpeditionPathfinder = table.freeze({
        Id = "ExpeditionPathfinder",
        Speaker = "Expedition Pathfinder",
        QuestIds = table.freeze({
            "RuinSurvey",
        }),
        AnchorId = "Base.Travel.Portals",
        Offset = Vector3.new(-22, 0, 18),
        Style = "Pathfinder",
        ClothingColor = Color3.fromRGB(48, 104, 107),
        AccentColor = Color3.fromRGB(188, 169, 93),
    }),
    SurveyCorps = table.freeze({
        Id = "SurveyCorps",
        Speaker = "Survey Corps",
        QuestIds = table.freeze({
            "MineSurveyorEscort",
        }),
        AnchorId = "Base.Travel.Dwarves",
        Offset = Vector3.new(-19, 0, -46),
        Style = "Surveyor",
        ClothingColor = Color3.fromRGB(119, 100, 72),
        AccentColor = Color3.fromRGB(189, 129, 61),
    }),
    ExpeditionQuartermaster = table.freeze({
        Id = "ExpeditionQuartermaster",
        Speaker = "Expedition Quartermaster",
        QuestIds = table.freeze({
            "ExpeditionProvisioning",
        }),
        AnchorId = "Base.Travel.Market",
        Offset = Vector3.new(38, 0, -30),
        Style = "Quartermaster",
        ClothingColor = Color3.fromRGB(104, 58, 61),
        AccentColor = Color3.fromRGB(196, 159, 78),
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


--[[
Returns the quest giver responsible for one Adventure quest.

Args:
    quest_id (string): Stable Adventure quest identifier.

Returns:
    any?: Frozen giver definition when that quest has a physical giver.
]]
function Definitions.for_quest(quest_id: string): any?
    for _, definition in ipairs(ORDER) do
        for _, candidate_id in ipairs(definition.QuestIds) do
            if candidate_id == quest_id then
                return definition
            end
        end
    end

    return nil
end

return table.freeze(Definitions)
