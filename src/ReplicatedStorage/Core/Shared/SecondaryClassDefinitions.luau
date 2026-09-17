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

    HumanRogueDuelist = table.freeze({
        Id = "HumanRogueDuelist",
        DisplayName = "Duelist",
        RaceId = "Human",
        BaseClassId = "Rogue",
        QuestId = "RogueAdvancementTrial",
        TeachableSkills = table.freeze({
            "DuelistAmbush",
            "DuelistDeadlyBlow",
            "DuelistExposeWeakness",
            "DuelistRush",
            "DuelistCriticalMastery",
        }),
    }),

    ElfRogueWindstalker = table.freeze({
        Id = "ElfRogueWindstalker",
        DisplayName = "Windstalker",
        RaceId = "Elf",
        BaseClassId = "Rogue",
        QuestId = "RogueAdvancementTrial",
        TeachableSkills = table.freeze({
            "WindstalkerFlurry",
            "WindstalkerSlipstream",
            "WindstalkerBlur",
            "WindstalkerQuickstep",
            "WindstalkerEvasionMastery",
        }),
    }),
})

local BY_PATH = table.freeze({
    Human = table.freeze({
        Mage = DEFINITIONS.HumanArcanist,
        Rogue = DEFINITIONS.HumanRogueDuelist,
    }),
    Elf = table.freeze({
        Mage = DEFINITIONS.ElfSpellweaver,
        Rogue = DEFINITIONS.ElfRogueWindstalker,
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

function SecondaryClassDefinitions.can_teach(
    class_id: string,
    skill_id: string
): boolean
    local definition = DEFINITIONS[class_id]
    if not definition or type(definition.TeachableSkills) ~= "table" then
        return false
    end

    for _, allowed_skill in ipairs(definition.TeachableSkills) do
        if allowed_skill == skill_id then
            return true
        end
    end

    return false
end

return table.freeze(SecondaryClassDefinitions)
