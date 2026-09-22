--!strict
-- First-tier Chronicle 4 Human/Elf base-class source rank families.
-- These source facts do not imply DungeonMMO implementation parity.
local C4BaseSkillInventory = {}

local SOURCES = table.freeze({
    Human = table.freeze({
        Fighter = table.freeze({
            SourceUrl = "https://l2hub.info/c4/classes/fighter",
            Levels = table.freeze({
                [1] = table.freeze({
                    NewbieProtection = 1,
                    RecipeReading = 1,
                }),
                [5] = table.freeze({
                    CommonItemCreation = 1,
                    PhysicalAttackMastery = 1,
                    ArmorMastery = 1,
                    SwordBluntStrike = 3,
                    BowShot = 3,
                    DaggerStrike = 3,
                    SittingRecovery = 1,
                }),
                [10] = table.freeze({
                    PhysicalAttackMastery = 1,
                    ArmorMastery = 2,
                    SwordBluntStrike = 3,
                    BowShot = 3,
                    DaggerStrike = 3,
                }),
                [15] = table.freeze({
                    PhysicalAttackMastery = 1,
                    ArmorMastery = 2,
                    SwordBluntStrike = 3,
                    BowShot = 3,
                    DaggerStrike = 3,
                }),
            }),
        }),
        Mage = table.freeze({
            SourceUrl = "https://l2hub.info/c4/classes/mage",
            Levels = table.freeze({
                [1] = table.freeze({
                    NewbieProtection = 1,
                    RobeCasting = 1,
                    RobeAttackSpeed = 1,
                    RobeManaRecovery = 1,
                    RecipeReading = 1,
                    WindAttack = 1,
                    Heal = 1,
                }),
                [5] = table.freeze({
                    CommonItemCreation = 1,
                }),
                [7] = table.freeze({
                    PhysicalMagicAttackMastery = 1,
                    ArmorMastery = 1,
                    MagicDefenseMastery = 2,
                    WindAttack = 2,
                    IceSlow = 2,
                    Heal = 3,
                    AttackBuff = 1,
                    DefenseBuff = 1,
                    CurePoison = 1,
                    PoisonCurse = 1,
                }),
                [14] = table.freeze({
                    PhysicalMagicAttackMastery = 1,
                    ArmorMastery = 2,
                    MagicDefenseMastery = 2,
                    WindAttack = 2,
                    IceSlow = 2,
                    Heal = 3,
                    LifeDrain = 2,
                    BattleHeal = 3,
                    PartyHeal = 3,
                    PhysicalAttackDebuff = 1,
                }),
            }),
        }),
    }),
    Elf = table.freeze({
        Fighter = table.freeze({
            SourceUrl = "https://l2hub.info/c4/classes/elven_fighter",
            Levels = table.freeze({
                [1] = table.freeze({
                    NewbieProtection = 1,
                    RecipeReading = 1,
                }),
                [5] = table.freeze({
                    CommonItemCreation = 1,
                    PhysicalAttackMastery = 1,
                    ArmorMastery = 1,
                    SwordBluntStrike = 3,
                    BowShot = 3,
                    DaggerStrike = 3,
                    DefenseBuff = 1,
                }),
                [10] = table.freeze({
                    PhysicalAttackMastery = 1,
                    ArmorMastery = 2,
                    SwordBluntStrike = 3,
                    BowShot = 3,
                    DaggerStrike = 3,
                    AttackBuff = 1,
                }),
                [15] = table.freeze({
                    PhysicalAttackMastery = 1,
                    ArmorMastery = 2,
                    SwordBluntStrike = 3,
                    BowShot = 3,
                    DaggerStrike = 3,
                    Regeneration = 3,
                }),
            }),
        }),
        Mage = table.freeze({
            SourceUrl = "https://l2hub.info/c4/classes/elven_mage",
            Levels = table.freeze({
                [1] = table.freeze({
                    NewbieProtection = 1,
                    RobeCasting = 1,
                    RobeAttackSpeed = 1,
                    RobeManaRecovery = 1,
                    RecipeReading = 1,
                    WindAttack = 1,
                    Heal = 1,
                }),
                [5] = table.freeze({
                    CommonItemCreation = 1,
                }),
                [7] = table.freeze({
                    PhysicalMagicAttackMastery = 1,
                    ArmorMastery = 1,
                    MagicDefenseMastery = 2,
                    WindAttack = 2,
                    IceSlow = 2,
                    Heal = 3,
                    AttackBuff = 1,
                    DefenseBuff = 1,
                    CurePoison = 1,
                }),
                [14] = table.freeze({
                    PhysicalMagicAttackMastery = 1,
                    ArmorMastery = 2,
                    MagicDefenseMastery = 2,
                    WindAttack = 2,
                    IceSlow = 2,
                    Heal = 3,
                    BattleHeal = 3,
                    PartyHeal = 3,
                    PhysicalAttackDebuff = 1,
                    AttackSpeedDebuff = 1,
                }),
            }),
        }),
    }),
})

--[[
Looks up the complete sourced first-tier rank inventory for one base class.

Args:
    race_id (string): C4 Human or Elf source race.
    class_id (string): C4 Fighter or Mage starting class.

Returns:
    any?: Source URL and per-level skill-rank family counts, if mapped.
]]
function C4BaseSkillInventory.get(
    race_id: string,
    class_id: string
): any?
    local race = SOURCES[race_id]
    return if race then race[class_id] else nil
end

--[[
Counts raw source ranks per purchase level without asserting game parity.

Args:
    race_id (string): Human or Elf.
    class_id (string): Source starting class.

Returns:
    any?: Frozen source counts by level and total, if available.
]]
function C4BaseSkillInventory.count(
    race_id: string,
    class_id: string
): any?
    local source = C4BaseSkillInventory.get(race_id, class_id)
    if not source then
        return nil
    end
    local levels = {}
    local total = 0
    for level, categories in pairs(source.Levels) do
        local count = 0
        for _, rank_count in pairs(categories) do
            count += rank_count
        end
        levels[level] = count
        total += count
    end
    return table.freeze({Levels = table.freeze(levels), Total = total})
end

return table.freeze(C4BaseSkillInventory)
