--!strict
-- Exact original five-race Chronicle 4 FIRST transfer catalogue.
-- This metadata does not enable unsupported playable races or quests.
-- It must never equate a legacy DungeonMMO specialist with a C4 class.
local C4FirstTransferBranches = {}

local TRANSFER_LEVEL = 20
local QUEST_START_LEVEL = 18
local SOURCE_URL = "https://www.lineage2.com/en-us/news/" ..
    "lineage-ii-classic-launch-patch-notes"
local QUEST_URL = "https://legacy-lineage2.com/Knowledge/quest2.html"

local RACE_ORDER = table.freeze({
    "Human", "Elf", "DarkElf", "Orc", "Dwarf",
})

local BRANCHES = table.freeze({
    Human = table.freeze({
        Fighter = table.freeze({
            table.freeze({
                Id = "HumanWarrior",
                SourceClass = "Warrior",
                SourceBaseClass = "Human Fighter",
                SourceRace = "Human",
                SourceQuestName = "Path to a Warrior",
                SourceQuestStartLevel = QUEST_START_LEVEL,
                SourceTransferLevel = TRANSFER_LEVEL,
                SourceIndexUrl = SOURCE_URL,
                SourceQuestUrl = QUEST_URL,
                GameplayStatus = "NotImplemented",
                SourceSkillInventory = "C4ElvenWizardLevel30Sources",
            }),
            table.freeze({
                Id = "HumanKnight",
                SourceClass = "Human Knight",
                SourceBaseClass = "Human Fighter",
                SourceRace = "Human",
                SourceQuestName = "Path to a Knight",
                SourceQuestStartLevel = QUEST_START_LEVEL,
                SourceTransferLevel = TRANSFER_LEVEL,
                SourceIndexUrl = SOURCE_URL,
                SourceQuestUrl = QUEST_URL,
                GameplayStatus = "NotImplemented",
            }),
            table.freeze({
                Id = "HumanRogue",
                SourceClass = "Rogue",
                SourceBaseClass = "Human Fighter",
                SourceRace = "Human",
                SourceQuestName = "Path to a Rogue",
                SourceQuestStartLevel = QUEST_START_LEVEL,
                SourceTransferLevel = TRANSFER_LEVEL,
                SourceIndexUrl = SOURCE_URL,
                SourceQuestUrl = QUEST_URL,
                GameplayStatus = "Partial",
                SourceSkillInventory = "C4ScoutSkillInventory",
            }),
        }),
        Mage = table.freeze({
            table.freeze({
                Id = "HumanWizard",
                SourceClass = "Human Wizard",
                SourceBaseClass = "Human Mystic",
                SourceRace = "Human",
                SourceQuestName = "Path to a Wizard",
                SourceQuestStartLevel = QUEST_START_LEVEL,
                SourceTransferLevel = TRANSFER_LEVEL,
                SourceIndexUrl = SOURCE_URL,
                SourceQuestUrl = QUEST_URL,
                GameplayStatus = "Partial",
                SourceSkillInventory = "C4HumanWizardLevel30Sources",
            }),
            table.freeze({
                Id = "HumanCleric",
                SourceClass = "Cleric",
                SourceBaseClass = "Human Mystic",
                SourceRace = "Human",
                SourceQuestName = "Path to a Cleric",
                SourceQuestStartLevel = QUEST_START_LEVEL,
                SourceTransferLevel = TRANSFER_LEVEL,
                SourceIndexUrl = SOURCE_URL,
                SourceQuestUrl = QUEST_URL,
                GameplayStatus = "Partial",
                SourceSkillInventory = "C4HumanClericLevel30Sources",
            }),
        }),
    }),
    Elf = table.freeze({
        Fighter = table.freeze({
            table.freeze({
                Id = "ElvenKnight",
                SourceClass = "Elven Knight",
                SourceBaseClass = "Elven Fighter",
                SourceRace = "Elf",
                SourceQuestName = "Path to an Elven Knight",
                SourceQuestStartLevel = QUEST_START_LEVEL,
                SourceTransferLevel = TRANSFER_LEVEL,
                SourceIndexUrl = SOURCE_URL,
                SourceQuestUrl = QUEST_URL,
                GameplayStatus = "NotImplemented",
            }),
            table.freeze({
                Id = "ElvenScout",
                SourceClass = "Elven Scout",
                SourceBaseClass = "Elven Fighter",
                SourceRace = "Elf",
                SourceQuestName = "Path to an Elven Scout",
                SourceQuestStartLevel = QUEST_START_LEVEL,
                SourceTransferLevel = TRANSFER_LEVEL,
                SourceIndexUrl = SOURCE_URL,
                SourceQuestUrl = QUEST_URL,
                GameplayStatus = "Partial",
                SourceSkillInventory = "C4ScoutSkillInventory",
            }),
        }),
        Mage = table.freeze({
            table.freeze({
                Id = "ElvenWizard",
                SourceClass = "Elven Wizard",
                SourceBaseClass = "Elven Mystic",
                SourceRace = "Elf",
                SourceQuestName = "Path to an Elven Wizard",
                SourceQuestStartLevel = QUEST_START_LEVEL,
                SourceTransferLevel = TRANSFER_LEVEL,
                SourceIndexUrl = SOURCE_URL,
                SourceQuestUrl = QUEST_URL,
                GameplayStatus = "NotImplemented",
            }),
            table.freeze({
                Id = "ElvenOracle",
                SourceClass = "Elven Oracle",
                SourceBaseClass = "Elven Mystic",
                SourceRace = "Elf",
                SourceQuestName = "Path to an Oracle",
                SourceQuestStartLevel = QUEST_START_LEVEL,
                SourceTransferLevel = TRANSFER_LEVEL,
                SourceIndexUrl = SOURCE_URL,
                SourceQuestUrl = QUEST_URL,
                GameplayStatus = "NotImplemented",
            }),
        }),
    }),
    DarkElf = table.freeze({
        Fighter = table.freeze({
            table.freeze({
                Id = "PalusKnight",
                SourceClass = "Palus Knight",
                SourceBaseClass = "Dark Fighter",
                SourceRace = "DarkElf",
                SourceQuestName = "Path to a Palus Knight",
                SourceQuestStartLevel = QUEST_START_LEVEL,
                SourceTransferLevel = TRANSFER_LEVEL,
                SourceIndexUrl = SOURCE_URL,
                SourceQuestUrl = QUEST_URL,
                GameplayStatus = "NotImplemented",
            }),
            table.freeze({
                Id = "DarkElfAssassin",
                SourceClass = "Assassin",
                SourceBaseClass = "Dark Fighter",
                SourceRace = "DarkElf",
                SourceQuestName = "Path to an Assassin",
                SourceQuestStartLevel = QUEST_START_LEVEL,
                SourceTransferLevel = TRANSFER_LEVEL,
                SourceIndexUrl = SOURCE_URL,
                SourceQuestUrl = QUEST_URL,
                GameplayStatus = "NotImplemented",
            }),
        }),
        Mage = table.freeze({
            table.freeze({
                Id = "DarkWizard",
                SourceClass = "Dark Wizard",
                SourceBaseClass = "Dark Mystic",
                SourceRace = "DarkElf",
                SourceQuestName = "Path to a Dark Wizard",
                SourceQuestStartLevel = QUEST_START_LEVEL,
                SourceTransferLevel = TRANSFER_LEVEL,
                SourceIndexUrl = SOURCE_URL,
                SourceQuestUrl = QUEST_URL,
                GameplayStatus = "NotImplemented",
            }),
            table.freeze({
                Id = "ShillienOracle",
                SourceClass = "Shillien Oracle",
                SourceBaseClass = "Dark Mystic",
                SourceRace = "DarkElf",
                SourceQuestName = "Path to a Shillien Oracle",
                SourceQuestStartLevel = QUEST_START_LEVEL,
                SourceTransferLevel = TRANSFER_LEVEL,
                SourceIndexUrl = SOURCE_URL,
                SourceQuestUrl = QUEST_URL,
                GameplayStatus = "NotImplemented",
            }),
        }),
    }),
    Orc = table.freeze({
        Fighter = table.freeze({
            table.freeze({
                Id = "OrcRaider",
                SourceClass = "Orc Raider",
                SourceBaseClass = "Orc Fighter",
                SourceRace = "Orc",
                SourceQuestName = "Path to an Orc Raider",
                SourceQuestStartLevel = QUEST_START_LEVEL,
                SourceTransferLevel = TRANSFER_LEVEL,
                SourceIndexUrl = SOURCE_URL,
                SourceQuestUrl = QUEST_URL,
                GameplayStatus = "NotImplemented",
            }),
            table.freeze({
                Id = "OrcMonk",
                SourceClass = "Orc Monk",
                SourceBaseClass = "Orc Fighter",
                SourceRace = "Orc",
                SourceQuestName = "Path to an Orc Monk",
                SourceQuestStartLevel = QUEST_START_LEVEL,
                SourceTransferLevel = TRANSFER_LEVEL,
                SourceIndexUrl = SOURCE_URL,
                SourceQuestUrl = QUEST_URL,
                GameplayStatus = "NotImplemented",
            }),
        }),
        Mage = table.freeze({
            table.freeze({
                Id = "OrcShaman",
                SourceClass = "Orc Shaman",
                SourceBaseClass = "Orc Mystic",
                SourceRace = "Orc",
                SourceQuestName = "Path to an Orc Shaman",
                SourceQuestStartLevel = QUEST_START_LEVEL,
                SourceTransferLevel = TRANSFER_LEVEL,
                SourceIndexUrl = SOURCE_URL,
                SourceQuestUrl = QUEST_URL,
                GameplayStatus = "NotImplemented",
            }),
        }),
    }),
    Dwarf = table.freeze({
        Fighter = table.freeze({
            table.freeze({
                Id = "DwarfArtisan",
                SourceClass = "Artisan",
                SourceBaseClass = "Dwarven Fighter",
                SourceRace = "Dwarf",
                SourceQuestName = "Path to an Artisan",
                SourceQuestStartLevel = QUEST_START_LEVEL,
                SourceTransferLevel = TRANSFER_LEVEL,
                SourceIndexUrl = SOURCE_URL,
                SourceQuestUrl = QUEST_URL,
                GameplayStatus = "NotImplemented",
            }),
            table.freeze({
                Id = "DwarfScavenger",
                SourceClass = "Scavenger",
                SourceBaseClass = "Dwarven Fighter",
                SourceRace = "Dwarf",
                SourceQuestName = "Path to a Scavenger",
                SourceQuestStartLevel = QUEST_START_LEVEL,
                SourceTransferLevel = TRANSFER_LEVEL,
                SourceIndexUrl = SOURCE_URL,
                SourceQuestUrl = QUEST_URL,
                GameplayStatus = "NotImplemented",
            }),
        }),
    }),
})

--[[
Lists the five historically available original C4 races in source order.

Args:
    None.

Returns:
    {string}: Stable source race identifiers; not a playable-race toggle.
]]
function C4FirstTransferBranches.races(): {string}
    return RACE_ORDER
end

--[[
Returns the distinct exact first-transfer choices for a source family.

Args:
    race_id (string): Original C4 race, possibly not playable yet.
    base_class_id (string): Fighter or Mage source starting family.

Returns:
    any?: Frozen source options, nil if this family does not exist.
]]
function C4FirstTransferBranches.get(
    race_id: string, base_class_id: string
): any?
    local race = BRANCHES[race_id]
    return if race then race[base_class_id] else nil
end

--[[
Resolves one explicit C4 first-transfer choice, never a default role.

Args:
    race_id (string): Original race selected by the character.
    base_class_id (string): Original source starting class family.
    source_class_id (string): Stable requested original class identity.

Returns:
    any?: Exact matching branch, or nil for a forged/wrong-race choice.
]]
function C4FirstTransferBranches.find(
    race_id: string, base_class_id: string, source_class_id: string
): any?
    local options = C4FirstTransferBranches.get(
        race_id, base_class_id
    )
    for _, branch in ipairs(options or {}) do
        if branch.Id == source_class_id then
            return branch
        end
    end
    return nil
end

--[[
Reports whether a first-transfer branch is genuinely playable.

Args:
    branch (any): Server-registered original C4 class metadata.

Returns:
    boolean: True only after its quest and skill tree are implemented.
]]
function C4FirstTransferBranches.is_complete(branch: any): boolean
    return type(branch) == "table"
        and branch.GameplayStatus == "Complete"
end

return table.freeze(C4FirstTransferBranches)
