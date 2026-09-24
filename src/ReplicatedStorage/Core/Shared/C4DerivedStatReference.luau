--!strict
-- Read-only Chronicle 4 derived-stat formulas for the current original
-- Human/Elf source templates. No live Roblox character uses this yet.
local Primary = require(script.Parent.C4PrimaryStatReference)

local C4DerivedStatReference = {}

local SOURCE_COMMIT =
    "07f8536384e799f128d44198dd7ab23519660eea"
local SOURCE_ROOT =
    "https://github.com/Neco-spain/"
    .. "l2jadmins_C4-Scions-of-Destiny/blob/"
    .. SOURCE_COMMIT

local SOURCES = table.freeze({
    StatBonus = SOURCE_ROOT
        .. "/L2jAdmins_Data/data/xml/stats/statBonus.xml",
    Character = SOURCE_ROOT
        .. "/L2jAdmins_Core/src/l2j/gameserver/model/actor/"
        .. "L2Character.java",
    PAtk = SOURCE_ROOT
        .. "/L2jAdmins_Core/src/l2j/gameserver/model/actor/manager/"
        .. "character/skills/funcs/formulas/FuncPAtkMod.java",
    PDef = SOURCE_ROOT
        .. "/L2jAdmins_Core/src/l2j/gameserver/model/actor/manager/"
        .. "character/skills/funcs/formulas/FuncPDefMod.java",
    MAtk = SOURCE_ROOT
        .. "/L2jAdmins_Core/src/l2j/gameserver/model/actor/manager/"
        .. "character/skills/funcs/formulas/FuncMAtkMod.java",
    MDef = SOURCE_ROOT
        .. "/L2jAdmins_Core/src/l2j/gameserver/model/actor/manager/"
        .. "character/skills/funcs/formulas/FuncMDefMod.java",
    PAtkSpeed = SOURCE_ROOT
        .. "/L2jAdmins_Core/src/l2j/gameserver/model/actor/manager/"
        .. "character/skills/funcs/formulas/FuncPAtkSpeed.java",
    MAtkSpeed = SOURCE_ROOT
        .. "/L2jAdmins_Core/src/l2j/gameserver/model/actor/manager/"
        .. "character/skills/funcs/formulas/FuncMAtkSpeed.java",
    MoveSpeed = SOURCE_ROOT
        .. "/L2jAdmins_Core/src/l2j/gameserver/model/actor/manager/"
        .. "character/skills/funcs/formulas/FuncMoveSpeed.java",
    Critical = SOURCE_ROOT
        .. "/L2jAdmins_Core/src/l2j/gameserver/model/actor/manager/"
        .. "character/skills/funcs/formulas/FuncAtkCritical.java",
    Accuracy = SOURCE_ROOT
        .. "/L2jAdmins_Core/src/l2j/gameserver/model/actor/manager/"
        .. "character/skills/funcs/formulas/FuncAtkAccuracy.java",
    Evasion = SOURCE_ROOT
        .. "/L2jAdmins_Core/src/l2j/gameserver/model/actor/manager/"
        .. "character/skills/funcs/formulas/FuncAtkEvasion.java",
})

local BONUS_FORMULAS = table.freeze({
    STR = table.freeze({Base = 1.036, Offset = -34.845}),
    INT = table.freeze({Base = 1.020, Offset = -31.375}),
    CON = table.freeze({Base = 1.030, Offset = -27.632}),
    MEN = table.freeze({Base = 1.010, Offset = 0.060}),
    DEX = table.freeze({Base = 1.009, Offset = -19.360}),
    WIT = table.freeze({Base = 1.050, Offset = -20.000}),
})

--[[
Rounds a positive source bonus exactly like the two-decimal XML table.

Args:
    value (number): Positive raw stat bonus formula result.

Returns:
    number: Source table precision to two decimal places.
]]
local function round_two(value: number): number
    return math.floor(value * 100 + 0.5) / 100
end

--[[
Imitates Java Math.round for the positive C4 combat values used here.

Args:
    value (number): Positive source-derived value.

Returns:
    number: Nearest integer, with .5 rounded upward.
]]
local function java_round(value: number): number
    return math.floor(value + 0.5)
end

--[[
Returns one exact two-decimal C4 primary-stat bonus table value.

The C4 datapack stores the rounded values and documents these source
formulae in statBonus.xml. Values outside its 0-99 table fail closed.

Args:
    stat_name (string): STR, INT, CON, MEN, DEX or WIT.
    stat_value (number): Integer source stat in the C4 table range.

Returns:
    number?: Exact two-decimal C4 table-equivalent bonus, or nil.
]]
function C4DerivedStatReference.stat_bonus(
    stat_name: string, stat_value: number
): number?
    local formula = BONUS_FORMULAS[stat_name]
    if not formula
        or type(stat_value) ~= "number"
        or stat_value ~= stat_value
        or stat_value % 1 ~= 0
        or stat_value < 0
        or stat_value > 99
    then
        return nil
    end
    return round_two(
        formula.Base ^ (stat_value + formula.Offset)
    )
end

--[[
Returns the exact C4 character level multiplier.

Args:
    level (number): Positive integer character level.

Returns:
    number?: (89 + level) / 100, or nil for an invalid level.
]]
function C4DerivedStatReference.level_modifier(
    level: number
): number?
    if type(level) ~= "number"
        or level ~= level
        or level % 1 ~= 0
        or level < 1
        or level > 80
    then
        return nil
    end
    return (89 + level) / 100
end

--[[
Computes naked, unbuffed C4 base combat stats for a supported class.

Equipment, mastery skills, buffs, dyes and target-specific modifiers are
deliberately excluded. Critical rate supports the C4 unarmed override.

Args:
    race_id (string): Historical Human or Elf race.
    class_id (string): Starter or current original first-transfer class.
    level (number): Valid level for that source class template.
    has_weapon (boolean): Whether a weapon bypasses unarmed crit=40.

Returns:
    (any?, string?): Derived source values or a fail-closed reason.
]]
function C4DerivedStatReference.get_naked_combat(
    race_id: string, class_id: string,
    level: number, has_weapon: boolean
): (any?, string?)
    local reference = Primary.get(race_id, class_id)
    local template = reference and reference.Template
    local vitals, vital_reason = Primary.get_level_vitals(
        race_id, class_id, level
    )
    if not template or not vitals then
        return nil, vital_reason or "UnreviewedClassOrLevel"
    end
    local level_mod = assert(
        C4DerivedStatReference.level_modifier(level)
    )
    local str_bonus = assert(C4DerivedStatReference.stat_bonus(
        "STR", template.STR
    ))
    local int_bonus = assert(C4DerivedStatReference.stat_bonus(
        "INT", template.INT
    ))
    local dex_bonus = assert(C4DerivedStatReference.stat_bonus(
        "DEX", template.DEX
    ))
    local wit_bonus = assert(C4DerivedStatReference.stat_bonus(
        "WIT", template.WIT
    ))
    local men_bonus = assert(C4DerivedStatReference.stat_bonus(
        "MEN", template.MEN
    ))

    local critical_rate = if has_weapon
        then math.floor(template.BaseCritRate * dex_bonus * 10)
        else 40

    return {
        Level = level,
        SourceClassId = template.SourceClassId,
        SourceClassName = template.SourceClassName,
        MaxHP = vitals.MaxHP,
        MaxMP = vitals.MaxMP,
        MaxCP = vitals.MaxCP,
        LevelModifier = level_mod,
        STRBonus = str_bonus,
        INTBonus = int_bonus,
        DEXBonus = dex_bonus,
        WITBonus = wit_bonus,
        MENBonus = men_bonus,
        NakedPAtk = math.floor(
            template.BasePAtk * str_bonus * level_mod
        ),
        NakedPDef = math.floor(
            template.BasePDef * level_mod
        ),
        NakedMAtk = math.floor(
            template.BaseMAtk
                * level_mod * level_mod
                * int_bonus * int_bonus
        ),
        NakedMDef = math.floor(
            template.BaseMDef * men_bonus * level_mod
        ),
        PhysicalAttackSpeed = java_round(
            template.BasePAtkSpd * dex_bonus
        ),
        MagicalAttackSpeed = math.floor(
            template.BaseMAtkSpd * wit_bonus
        ),
        RunSpeed = math.floor(
            template.BaseRunSpd * dex_bonus
        ),
        Accuracy = java_round(
            math.sqrt(template.DEX) * 6 + level
        ),
        Evasion = java_round(
            math.sqrt(template.DEX) * 6 + level
        ),
        PhysicalCriticalRate = critical_rate,
        WeaponCriticalFormulaApplied = has_weapon,
        EquipmentModifiersApplied = false,
        SkillModifiersApplied = false,
        SourceCommit = SOURCE_COMMIT,
    }, nil
end

--[[
Returns pinned C4 formula provenance for audit and documentation.

Args:
    None.

Returns:
    any: Read-only source commit and exact source file URLs.
]]
function C4DerivedStatReference.sources(): any
    return {
        SourceCommit = SOURCE_COMMIT,
        SourceUrls = SOURCES,
    }
end

return table.freeze(C4DerivedStatReference)
