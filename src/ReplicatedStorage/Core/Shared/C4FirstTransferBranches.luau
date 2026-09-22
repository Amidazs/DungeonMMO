--!strict
-- Chronicle 4 first-transfer choices for DungeonMMO's supported races.
-- A source class is NOT equivalent to the game's existing specialist
-- names merely because their combat role or title resembles one another.
local C4FirstTransferBranches = {}

local MINIMUM_TRANSFER_LEVEL = 20
local SOURCE_URL = "https://l2hub.info/c4/classes"
local QUEST_URL = "https://l2hub.info/c4/quests/1st-class"

local BRANCHES = table.freeze({
    Human = table.freeze({
        Fighter = table.freeze({
            table.freeze({
                SourceClass = "Warrior",
                SourceBaseClass = "Human Fighter",
                SourceRace = "Human",
                SourceTransferLevel = MINIMUM_TRANSFER_LEVEL,
                SourceIndexUrl = SOURCE_URL,
                SourceQuestUrl = QUEST_URL,
                GameplayStatus = "NotImplemented",
            }),
            table.freeze({
                SourceClass = "Human Knight",
                SourceBaseClass = "Human Fighter",
                SourceRace = "Human",
                SourceTransferLevel = MINIMUM_TRANSFER_LEVEL,
                SourceIndexUrl = SOURCE_URL,
                SourceQuestUrl = QUEST_URL,
                GameplayStatus = "NotImplemented",
            }),
            table.freeze({
                SourceClass = "Rogue",
                SourceBaseClass = "Human Fighter",
                SourceRace = "Human",
                SourceTransferLevel = MINIMUM_TRANSFER_LEVEL,
                SourceIndexUrl = SOURCE_URL,
                SourceQuestUrl = QUEST_URL,
                GameplayStatus = "Partial",
                SourceSkillInventory = "C4ScoutSkillInventory",
            }),
        }),
        Mage = table.freeze({
            table.freeze({
                SourceClass = "Wizard",
                SourceBaseClass = "Human Mystic",
                SourceRace = "Human",
                SourceTransferLevel = MINIMUM_TRANSFER_LEVEL,
                SourceIndexUrl = SOURCE_URL,
                SourceQuestUrl = QUEST_URL,
                GameplayStatus = "NotImplemented",
            }),
            table.freeze({
                SourceClass = "Cleric",
                SourceBaseClass = "Human Mystic",
                SourceRace = "Human",
                SourceTransferLevel = MINIMUM_TRANSFER_LEVEL,
                SourceIndexUrl = SOURCE_URL,
                SourceQuestUrl = QUEST_URL,
                GameplayStatus = "NotImplemented",
            }),
        }),
    }),
    Elf = table.freeze({
        Fighter = table.freeze({
            table.freeze({
                SourceClass = "Elven Knight",
                SourceBaseClass = "Elven Fighter",
                SourceRace = "Elf",
                SourceTransferLevel = MINIMUM_TRANSFER_LEVEL,
                SourceIndexUrl = SOURCE_URL,
                SourceQuestUrl = QUEST_URL,
                GameplayStatus = "NotImplemented",
            }),
            table.freeze({
                SourceClass = "Elven Scout",
                SourceBaseClass = "Elven Fighter",
                SourceRace = "Elf",
                SourceTransferLevel = MINIMUM_TRANSFER_LEVEL,
                SourceIndexUrl = SOURCE_URL,
                SourceQuestUrl = QUEST_URL,
                GameplayStatus = "Partial",
                SourceSkillInventory = "C4ScoutSkillInventory",
            }),
        }),
        Mage = table.freeze({
            table.freeze({
                SourceClass = "Elven Wizard",
                SourceBaseClass = "Elven Mystic",
                SourceRace = "Elf",
                SourceTransferLevel = MINIMUM_TRANSFER_LEVEL,
                SourceIndexUrl = SOURCE_URL,
                SourceQuestUrl = QUEST_URL,
                GameplayStatus = "NotImplemented",
            }),
            table.freeze({
                SourceClass = "Elven Oracle",
                SourceBaseClass = "Elven Mystic",
                SourceRace = "Elf",
                SourceTransferLevel = MINIMUM_TRANSFER_LEVEL,
                SourceIndexUrl = SOURCE_URL,
                SourceQuestUrl = QUEST_URL,
                GameplayStatus = "NotImplemented",
            }),
        }),
    }),
})

--[[
Returns the actual C4 first-transfer choices for one supported race
and original starting class without merging distinct C4 career paths.

Args:
    race_id (string): Supported Human or Elf.
    base_class_id (string): Fighter or Mage starting class.

Returns:
    any?: Frozen ordered C4 first-transfer paths, or nil if unknown.
]]
function C4FirstTransferBranches.get(
    race_id: string,
    base_class_id: string
): any?
    local race = BRANCHES[race_id]
    return if race then race[base_class_id] else nil
end

--[[
Returns whether a source C4 first-transfer path has actually reached
complete functional skill coverage in DungeonMMO. An absent inventory
or only partially mapped Scout ranks must not silently pass.

Args:
    branch (any): Sourced first-transfer metadata from this registry.

Returns:
    boolean: True only for an explicitly completed gameplay branch.
]]
function C4FirstTransferBranches.is_complete(branch: any): boolean
    return type(branch) == "table"
        and branch.GameplayStatus == "Complete"
end

return table.freeze(C4FirstTransferBranches)
