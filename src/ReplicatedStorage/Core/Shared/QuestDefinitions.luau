--!strict
local DungeonDefinitions = require(script.Parent.DungeonDefinitions)
local CharacterIdentityRules = require(script.Parent.CharacterIdentityRules)
local SkillUnlockRules = require(script.Parent.SkillUnlockRules)

local QuestDefinitions = {}

local ADVENTURE_RACES = table.freeze({
    "Human",
    "Elf",
    "DarkElf",
})

local DEFINITIONS = table.freeze({
    FighterAdvancementTrial = table.freeze({
        Id = "FighterAdvancementTrial",
        DisplayName = "Trial of the Vanguard",
        Kind = "ClassAdvancement",
        MinimumLevel = 20,
        SkillPrerequisites = table.freeze({
            table.freeze({
                SkillId = "ShieldBash", Rank = 3, Proficiency = 400,
            }),
            table.freeze({
                SkillId = "Mend", Rank = 3, Proficiency = 300,
            }),
        }),
        AllowedRaces = table.freeze({"Human", "Elf"}),
        AllowedBaseClasses = table.freeze({"Fighter"}),
        Objectives = table.freeze({
            table.freeze({
                Id = "ClearTemple",
                Type = "DungeonClear",
                TargetId = DungeonDefinitions.TEST_DUNGEON.Id,
                Required = 1,
            }),
        }),
    }),

    RangerAdvancementTrial = table.freeze({
        Id = "RangerAdvancementTrial",
        DisplayName = "Trial of the Far Path",
        Kind = "ClassAdvancement",
        MinimumLevel = 20,
        SkillPrerequisites = table.freeze({
            table.freeze({
                SkillId = "PiercingShot", Rank = 3, Proficiency = 300,
            }),
            table.freeze({
                SkillId = "CripplingShot", Rank = 3, Proficiency = 300,
            }),
        }),
        AllowedRaces = table.freeze({"Human", "Elf"}),
        AllowedBaseClasses = table.freeze({"Ranger"}),
        Objectives = table.freeze({
            table.freeze({
                Id = "ClearAbandonedMine",
                Type = "DungeonClear",
                TargetId = DungeonDefinitions.ABANDONED_MINE.Id,
                Required = 1,
            }),
        }),
    }),

    MageAdvancementTrial = table.freeze({
        Id = "MageAdvancementTrial",
        DisplayName = "Mage Advancement Trial",
        Kind = "ClassAdvancement",
        MinimumLevel = 20,
        SkillPrerequisites = table.freeze({
            table.freeze({
                SkillId = "WindStrike", Rank = 3, Proficiency = 300,
            }),
            table.freeze({
                SkillId = "ArcaneWard", Rank = 3, Proficiency = 300,
            }),
        }),
        AllowedRaces = table.freeze({"Human", "Elf"}),
        AllowedBaseClasses = table.freeze({"Mage"}),
        Objectives = table.freeze({
            table.freeze({
                Id = "ClearTemple",
                Type = "DungeonClear",
                TargetId = DungeonDefinitions.TEST_DUNGEON.Id,
                Required = 1,
            }),
        }),
    }),

    WorldrootRelic = table.freeze({
        Id = "WorldrootRelic",
        DisplayName = "A Relic Beneath the World Tree",
        Kind = "Adventure",
        MinimumLevel = 1,
        AllowedRaces = ADVENTURE_RACES,
        AllowedBaseClasses = table.freeze({
            "Fighter", "Mage", "Ranger", "Rogue",
        }),
        Objectives = table.freeze({
            table.freeze({
                Id = "ClearTemple",
                Type = "DungeonClear",
                TargetId = DungeonDefinitions.TEST_DUNGEON.Id,
                Required = 1,
            }),
        }),
        Reward = table.freeze({
            Gold = 25,
            ItemId = "worldroot_relic",
            Quantity = 1,
        }),
    }),

    ForestWolfBounty = table.freeze({
        Id = "ForestWolfBounty",
        DisplayName = "Wolves at the Worldroot",
        Kind = "Adventure",
        MinimumLevel = 1,
        PrerequisiteQuestId = "WorldrootRelic",
        AllowedRaces = ADVENTURE_RACES,
        AllowedBaseClasses = table.freeze({
            "Fighter", "Mage", "Ranger", "Rogue",
        }),
        Objectives = table.freeze({
            table.freeze({
                Id = "DefeatForestWolves",
                Type = "EnemyDefeat",
                TargetId = "forest_wolf",
                Required = 2,
            }),
        }),
        Reward = table.freeze({
            Gold = 40,
        }),
    }),

    MarauderCaptainBounty = table.freeze({
        Id = "MarauderCaptainBounty",
        DisplayName = "The Captain's Price",
        Kind = "Adventure",
        MinimumLevel = 5,
        PrerequisiteQuestId = "WorldrootRelic",
        AllowedRaces = ADVENTURE_RACES,
        AllowedBaseClasses = table.freeze({
            "Fighter", "Mage", "Ranger", "Rogue",
        }),
        Objectives = table.freeze({
            table.freeze({
                Id = "DefeatMarauderCaptain",
                Type = "EnemyDefeat",
                TargetId = "marauder_captain",
                Required = 1,
            }),
        }),
        Reward = table.freeze({
            Gold = 60,
        }),
    }),

    HiddenWardDiscovery = table.freeze({
        Id = "HiddenWardDiscovery",
        DisplayName = "Whispers Behind the Stone",
        Kind = "Adventure",
        MinimumLevel = 6,
        PrerequisiteQuestId = "WorldrootRelic",
        AllowedRaces = ADVENTURE_RACES,
        AllowedBaseClasses = table.freeze({
            "Fighter", "Mage", "Ranger", "Rogue",
        }),
        Objectives = table.freeze({
            table.freeze({
                Id = "ActivateHiddenPanel",
                Type = "WorldInteraction",
                TargetId = "TestDungeon:HiddenPanel:Room2",
                Required = 1,
            }),
            table.freeze({
                Id = "CollectHiddenWardFragment",
                Type = "ItemCollected",
                TargetId = "hidden_ward_fragment",
                Required = 1,
            }),
        }),
        TurnInItems = table.freeze({
            table.freeze({
                ItemId = "hidden_ward_fragment",
                Quantity = 1,
            }),
        }),
        Reward = table.freeze({
            Gold = 50,
            Items = table.freeze({
                table.freeze({
                    ItemId = "warding_essence",
                    Quantity = 1,
                }),
            }),
        }),
    }),

    RuinSurvey = table.freeze({
        Id = "RuinSurvey",
        DisplayName = "Survey the Broken Ways",
        Kind = "Adventure",
        MinimumLevel = 8,
        PrerequisiteQuestId = "MineEchoes",
        AllowedRaces = ADVENTURE_RACES,
        AllowedBaseClasses = table.freeze({
            "Fighter", "Mage", "Ranger", "Rogue",
        }),
        Objectives = table.freeze({
            table.freeze({
                Id = "ReachTempleInnerApproach",
                Type = "CheckpointReached",
                TargetId =
                    "TestDungeon:EncounterStart:CombatRoom2",
                Required = 1,
            }),
            table.freeze({
                Id = "ReachMineLowerWorks",
                Type = "CheckpointReached",
                TargetId =
                    "AbandonedMine:EncounterStart:CombatRoom2",
                Required = 1,
            }),
        }),
        Reward = table.freeze({
            Gold = 60,
            Items = table.freeze({
                table.freeze({
                    ItemId = "deep_iron_bar",
                    Quantity = 1,
                }),
                table.freeze({
                    ItemId = "moonpetal_extract",
                    Quantity = 1,
                }),
                table.freeze({
                    ItemId = "reinforced_leather",
                    Quantity = 1,
                }),
                table.freeze({
                    ItemId = "resonant_rune",
                    Quantity = 1,
                }),
            }),
        }),
    }),

    CorruptedForemanBounty = table.freeze({
        Id = "CorruptedForemanBounty",
        DisplayName = "The Foreman's Reckoning",
        Kind = "Adventure",
        MinimumLevel = 10,
        PrerequisiteQuestId = "MineEchoes",
        AllowedRaces = ADVENTURE_RACES,
        AllowedBaseClasses = table.freeze({
            "Fighter", "Mage", "Ranger", "Rogue",
        }),
        Objectives = table.freeze({
            table.freeze({
                Id = "DefeatCorruptedForeman",
                Type = "EnemyDefeat",
                TargetId = "corrupted_foreman",
                Required = 1,
            }),
        }),
        Reward = table.freeze({
            Gold = 80,
        }),
    }),

    FractureTrail = table.freeze({
        Id = "FractureTrail",
        DisplayName = "Follow the Fracture",
        Kind = "Adventure",
        MinimumLevel = 12,
        PrerequisiteQuestId = "RuinSurvey",
        AllowedRaces = ADVENTURE_RACES,
        AllowedBaseClasses = table.freeze({
            "Fighter", "Mage", "Ranger", "Rogue",
        }),
        Objectives = table.freeze({
            table.freeze({
                Id = "TraceTempleFracture",
                Type = "CheckpointReached",
                TargetId =
                    "TestDungeon:EncounterStart:CombatRoom2",
                Required = 1,
            }),
            table.freeze({
                Id = "PurgeMineSource",
                Type = "DungeonClear",
                TargetId = DungeonDefinitions.ABANDONED_MINE.Id,
                Required = 1,
            }),
        }),
        Reward = table.freeze({
            Gold = 90,
            Items = table.freeze({
                table.freeze({
                    ItemId = "warding_essence",
                    Quantity = 2,
                }),
            }),
        }),
    }),

    MineEchoes = table.freeze({
        Id = "MineEchoes",
        DisplayName = "Echoes from the Abandoned Mine",
        Kind = "Adventure",
        MinimumLevel = 1,
        PrerequisiteQuestId = "WorldrootRelic",
        AllowedRaces = ADVENTURE_RACES,
        AllowedBaseClasses = table.freeze({
            "Fighter", "Mage", "Ranger", "Rogue",
        }),
        Objectives = table.freeze({
            table.freeze({
                Id = "ClearAbandonedMine",
                Type = "DungeonClear",
                TargetId = DungeonDefinitions.ABANDONED_MINE.Id,
                Required = 1,
            }),
        }),
        Reward = table.freeze({
            Gold = 50,
            ItemId = "iron_ore",
            Quantity = 5,
        }),
    }),

    DungeonBossHunt = table.freeze({
        Id = "DungeonBossHunt",
        DisplayName = "Break the Chain",
        Kind = "Adventure",
        MinimumLevel = 15,
        PrerequisiteQuestId = "MineEchoes",
        AllowedRaces = ADVENTURE_RACES,
        AllowedBaseClasses = table.freeze({
            "Fighter", "Mage", "Ranger", "Rogue",
        }),
        Objectives = table.freeze({
            table.freeze({
                Id = "DefeatMarauderCaptain",
                Type = "EnemyDefeat",
                TargetId = "marauder_captain",
                Required = 1,
            }),
            table.freeze({
                Id = "DefeatCorruptedForeman",
                Type = "EnemyDefeat",
                TargetId = "corrupted_foreman",
                Required = 1,
            }),
        }),
        Reward = table.freeze({
            Gold = 120,
        }),
    }),

    ExpeditionProvisioning = table.freeze({
        Id = "ExpeditionProvisioning",
        DisplayName = "Provisions for the Next Expedition",
        Kind = "Adventure",
        MinimumLevel = 1,
        PrerequisiteQuestId = "MineEchoes",
        AllowedRaces = ADVENTURE_RACES,
        AllowedBaseClasses = table.freeze({
            "Fighter", "Mage", "Ranger", "Rogue",
        }),
        Objectives = table.freeze({
            table.freeze({
                Id = "ClearTemple",
                Type = "DungeonClear",
                TargetId = DungeonDefinitions.TEST_DUNGEON.Id,
                Required = 1,
            }),
            table.freeze({
                Id = "ClearAbandonedMine",
                Type = "DungeonClear",
                TargetId = DungeonDefinitions.ABANDONED_MINE.Id,
                Required = 1,
            }),
        }),
        Reward = table.freeze({
            Gold = 75,
            Items = table.freeze({
                table.freeze({
                    ItemId = "deep_iron_ore",
                    Quantity = 2,
                }),
                table.freeze({
                    ItemId = "moonpetal",
                    Quantity = 2,
                }),
                table.freeze({
                    ItemId = "thick_hide",
                    Quantity = 2,
                }),
            }),
        }),
    }),

    RogueAdvancementTrial = table.freeze({
        Id = "RogueAdvancementTrial",
        DisplayName = "Rogue Advancement Trial",
        Kind = "ClassAdvancement",
        MinimumLevel = 20,
        SkillPrerequisites = table.freeze({
            table.freeze({
                SkillId = "QuickStrike", Rank = 3, Proficiency = 300,
            }),
            table.freeze({
                SkillId = "Backstab", Rank = 3, Proficiency = 400,
            }),
        }),
        AllowedRaces = table.freeze({"Human", "Elf"}),
        AllowedBaseClasses = table.freeze({"Rogue"}),
        Objectives = table.freeze({
            table.freeze({
                Id = "ClearAbandonedMine",
                Type = "DungeonClear",
                TargetId = DungeonDefinitions.ABANDONED_MINE.Id,
                Required = 1,
            }),
        }),
    }),
})

local function list_contains(values: any, expected: string): boolean
    if type(values) ~= "table" then
        return false
    end

    for _, value in ipairs(values) do
        if value == expected then
            return true
        end
    end

    return false
end

function QuestDefinitions.get(quest_id: string): any?
    return DEFINITIONS[quest_id]
end

-- Returns available non-advancement quest definitions in story order.
--
-- Args:
--   None.
-- Returns:
--   {any}: Frozen quest catalogue for server-authorized board snapshots.
function QuestDefinitions.adventures(): {any}
    return table.freeze({
        DEFINITIONS.WorldrootRelic,
        DEFINITIONS.ForestWolfBounty,
        DEFINITIONS.MarauderCaptainBounty,
        DEFINITIONS.HiddenWardDiscovery,
        DEFINITIONS.MineEchoes,
        DEFINITIONS.RuinSurvey,
        DEFINITIONS.CorruptedForemanBounty,
        DEFINITIONS.FractureTrail,
        DEFINITIONS.DungeonBossHunt,
        DEFINITIONS.ExpeditionProvisioning,
    })
end

function QuestDefinitions.is_character_eligible(
    character: any,
    definition: any
): boolean
    if type(character) ~= "table"
        or type(definition) ~= "table"
        or not CharacterIdentityRules.is_complete(character)
    then
        return false
    end

    local identity = character.Identity
    local race_id = identity.RaceId
    local base_class_id = identity.BaseClassId
    local level = tonumber(character.Level) or 0

    return (
        type(race_id) == "string"
        and type(base_class_id) == "string"
        and level >= (tonumber(definition.MinimumLevel) or 1)
        and list_contains(definition.AllowedRaces, race_id)
        and list_contains(definition.AllowedBaseClasses, base_class_id)
        and (
            definition.Kind ~= "ClassAdvancement"
            or select(1, SkillUnlockRules.can_start_trial(
                character, definition
            ))
        )
        and (
            definition.PrerequisiteQuestId == nil
            or (
                type(character.Quests) == "table"
                and type(character.Quests.Completed) == "table"
                and character.Quests.Completed[
                    definition.PrerequisiteQuestId
                ] == true
            )
        )
    )
end

function QuestDefinitions.objective_matches(
    objective: any,
    event: any
): boolean
    if type(objective) ~= "table" or type(event) ~= "table" then
        return false
    end

    if objective.Type ~= event.Type then
        return false
    end

    if type(objective.TargetId) == "string"
        and objective.TargetId ~= event.TargetId
    then
        return false
    end

    return true
end

return table.freeze(QuestDefinitions)
