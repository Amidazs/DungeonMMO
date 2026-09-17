--!strict
local SecondaryClassDefinitions = {}

local DEFINITIONS = table.freeze({
    HumanArcanist = table.freeze({
        Id = "HumanArcanist",
        DisplayName = "Arcanist",
        RaceId = "Human",
        BaseClassId = "Mage",
        QuestId = "MageAdvancementTrial",
    }),

    ElfSpellweaver = table.freeze({
        Id = "ElfSpellweaver",
        DisplayName = "Spellweaver",
        RaceId = "Elf",
        BaseClassId = "Mage",
        QuestId = "MageAdvancementTrial",
    }),
})

local BY_PATH = table.freeze({
    Human = table.freeze({
        Mage = DEFINITIONS.HumanArcanist,
    }),
    Elf = table.freeze({
        Mage = DEFINITIONS.ElfSpellweaver,
    }),
})

function SecondaryClassDefinitions.get(class_id: string): any?
    return DEFINITIONS[class_id]
end

function SecondaryClassDefinitions.resolve(
    race_id: string,
    base_class_id: string
): any?
    local race = BY_PATH[race_id]
    if not race then
        return nil
    end

    return race[base_class_id]
end

return table.freeze(SecondaryClassDefinitions)
