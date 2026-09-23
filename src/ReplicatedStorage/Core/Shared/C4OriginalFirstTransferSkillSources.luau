--!strict
-- Exact original Chronicle 4 level-20 skill/source-rank starts for
-- Human Warrior and Human Knight. Not yet playable DungeonMMO skills.
-- Preserve individual C4 ranks: "Heavy Armor Mastery 1/2/3" are
-- three distinct purchases, not one generic class passive toggle.
local Sources = {}

local function skill(name: string, rank: number, kind: string): any
    return table.freeze({
        Name = name, SourceRank = rank, Kind = kind,
        SourceLevel = 20, DungeonSkillId = nil,
        GameplayStatus = "NotImplemented",
    })
end

local SOURCE = table.freeze({
    HumanWarrior = table.freeze({
        ClassId = "HumanWarrior",
        SourceUrl = "https://l2hub.info/c4/classes/warrior",
        SourceChronicle = "C4",
        Coverage = "Level20Only",
        Level20 = table.freeze({
            skill("Expertise D", 1, "Passive"),
            skill("Create Common Item", 2, "Passive"),
            skill("Sword Blunt Mastery", 1, "Passive"),
            skill("Polearm Mastery", 1, "Passive"),
            skill("Light Armor Mastery", 1, "Passive"),
            skill("Light Armor Mastery", 2, "Passive"),
            skill("Heavy Armor Mastery", 1, "Passive"),
            skill("Heavy Armor Mastery", 2, "Passive"),
            skill("Power Smash", 1, "Active"),
            skill("Vicious Stance", 1, "Toggle"),
            skill("Boost HP", 1, "Passive"),
            skill("War Cry", 1, "Active"),
        }),
    }),
    HumanKnight = table.freeze({
        ClassId = "HumanKnight",
        SourceUrl = "https://l2hub.info/c4/classes/knight",
        SourceChronicle = "C4",
        Coverage = "Level20Only",
        Level20 = table.freeze({
            skill("Expertise D", 1, "Passive"),
            skill("Create Common Item", 2, "Passive"),
            skill("Sword Blunt Mastery", 1, "Passive"),
            skill("Heavy Armor Mastery", 1, "Passive"),
            skill("Heavy Armor Mastery", 2, "Passive"),
            skill("Heavy Armor Mastery", 3, "Passive"),
            skill("Magic Resistance", 1, "Passive"),
            skill("Magic Resistance", 2, "Passive"),
            skill("Drain Health", 1, "Active"),
            skill("Drain Health", 2, "Active"),
            skill("Shield Stun", 1, "Active"),
            skill("Shield Stun", 2, "Active"),
            skill("Shield Stun", 3, "Active"),
            skill("Shield Mastery", 1, "Passive"),
            skill("Majesty", 1, "Active"),
            skill("Ultimate Defense", 1, "Active"),
        }),
    }),
})

--[[
Retrieves exact C4 source ranks, not loose thematic skills or earned ranks.

Args:
    original_class_id (string): Source first-transfer class (not role).

Returns:
    any?: Level-20 source records or nil until separately inventoried.
]]
function Sources.get(original_class_id: string): any?
    return SOURCE[original_class_id]
end

return table.freeze(Sources)
