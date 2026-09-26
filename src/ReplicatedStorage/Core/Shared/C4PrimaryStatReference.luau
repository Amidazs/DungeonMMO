--!strict
-- Exact Chronicle 4 class-template reference for the currently authored
-- Human/Elf starter and first-transfer paths. This remains read-only
-- until the whole live combat/profile migration is deliberately enabled.
local FirstTransfers = require(
    script.Parent.OriginalFirstTransferDefinitions
)

local C4PrimaryStatReference = {}

local SOURCE_COMMIT =
    "07f8536384e799f128d44198dd7ab23519660eea"
local SOURCE_ROOT =
    "https://github.com/Neco-spain/"
    .. "l2jadmins_C4-Scions-of-Destiny/blob/"
    .. SOURCE_COMMIT

local SOURCE_URLS = table.freeze({
    ClassTemplates = SOURCE_ROOT
        .. "/L2jAdmins_Data/data/xml/stats/charTemplates.xml",
    StatBonus = SOURCE_ROOT
        .. "/L2jAdmins_Data/data/xml/stats/statBonus.xml",
    MaxHpAdd = SOURCE_ROOT
        .. "/L2jAdmins_Core/src/l2j/gameserver/model/actor/manager/"
        .. "character/skills/funcs/formulas/FuncMaxHpAdd.java",
    MaxHpMul = SOURCE_ROOT
        .. "/L2jAdmins_Core/src/l2j/gameserver/model/actor/manager/"
        .. "character/skills/funcs/formulas/FuncMaxHpMul.java",
    MaxMpAdd = SOURCE_ROOT
        .. "/L2jAdmins_Core/src/l2j/gameserver/model/actor/manager/"
        .. "character/skills/funcs/formulas/FuncMaxMpAdd.java",
    MaxMpMul = SOURCE_ROOT
        .. "/L2jAdmins_Core/src/l2j/gameserver/model/actor/manager/"
        .. "character/skills/funcs/formulas/FuncMaxMpMul.java",
    MaxCpAdd = SOURCE_ROOT
        .. "/L2jAdmins_Core/src/l2j/gameserver/model/actor/manager/"
        .. "character/skills/funcs/formulas/FuncMaxCpAdd.java",
    MaxCpMul = SOURCE_ROOT
        .. "/L2jAdmins_Core/src/l2j/gameserver/model/actor/manager/"
        .. "character/skills/funcs/formulas/FuncMaxCpMul.java",
})

local TEMPLATES = table.freeze({
    HumanFighter = table.freeze({
        SourceClassId = 0,
        SourceClassName = "HUMAN_FIGHTER",
        ClassBaseLevel = 1,
        STR = 40, DEX = 30, CON = 43,
        INT = 21, WIT = 11, MEN = 25,
        BasePAtk = 4, BasePDef = 80, BasePAtkSpd = 300,
        BaseMAtk = 6, BaseMDef = 41, BaseMAtkSpd = 333,
        BaseEvasion = 33, BaseCritRate = 44,
        BaseAccuracy = 33, BaseRunSpd = 115,
        BaseHpRegen = 1.5, BaseMpRegen = 0.9,
        HpBase = 80, HpAdd = 11.83, HpMod = 0.37,
        MpBase = 30, MpAdd = 5.46, MpMod = 0.14,
        CpBase = 32, CpAdd = 4.73, CpMod = 0.22,
        ConBonus = 1.58, MenBonus = 1.28,
    }),
    HumanMystic = table.freeze({
        SourceClassId = 10,
        SourceClassName = "HUMAN_MAGE",
        ClassBaseLevel = 1,
        STR = 22, DEX = 21, CON = 27,
        INT = 41, WIT = 20, MEN = 39,
        BasePAtk = 3, BasePDef = 54, BasePAtkSpd = 300,
        BaseMAtk = 6, BaseMDef = 41, BaseMAtkSpd = 333,
        BaseEvasion = 28, BaseCritRate = 40,
        BaseAccuracy = 28, BaseRunSpd = 120,
        BaseHpRegen = 1.5, BaseMpRegen = 0.9,
        HpBase = 101, HpAdd = 15.57, HpMod = 0.37,
        MpBase = 40, MpAdd = 7.38, MpMod = 0.14,
        CpBase = 50.5, CpAdd = 7.84, CpMod = 0.22,
        ConBonus = 0.98, MenBonus = 1.48,
    }),
    HumanWizard = table.freeze({
        SourceClassId = 11,
        SourceClassName = "WIZARD",
        ClassBaseLevel = 20,
        STR = 22, DEX = 21, CON = 27,
        INT = 41, WIT = 20, MEN = 39,
        BasePAtk = 3, BasePDef = 54, BasePAtkSpd = 300,
        BaseMAtk = 6, BaseMDef = 41, BaseMAtkSpd = 333,
        BaseEvasion = 28, BaseCritRate = 40,
        BaseAccuracy = 28, BaseRunSpd = 120,
        BaseHpRegen = 1.5, BaseMpRegen = 0.9,
        HpBase = 424, HpAdd = 27.60, HpMod = 0.37,
        MpBase = 192, MpAdd = 13.30, MpMod = 0.14,
        CpBase = 212, CpAdd = 13.85, CpMod = 0.22,
        ConBonus = 0.98, MenBonus = 1.48,
    }),
    HumanCleric = table.freeze({
        SourceClassId = 15,
        SourceClassName = "CLERIC",
        ClassBaseLevel = 20,
        STR = 22, DEX = 21, CON = 27,
        INT = 41, WIT = 20, MEN = 39,
        BasePAtk = 3, BasePDef = 54, BasePAtkSpd = 300,
        BaseMAtk = 6, BaseMDef = 41, BaseMAtkSpd = 333,
        BaseEvasion = 28, BaseCritRate = 40,
        BaseAccuracy = 28, BaseRunSpd = 120,
        BaseHpRegen = 1.5, BaseMpRegen = 0.9,
        HpBase = 424, HpAdd = 34.20, HpMod = 0.37,
        MpBase = 192, MpAdd = 13.30, MpMod = 0.14,
        CpBase = 212, CpAdd = 17.15, CpMod = 0.22,
        ConBonus = 0.98, MenBonus = 1.48,
    }),
    ElvenFighter = table.freeze({
        SourceClassId = 18,
        SourceClassName = "ELF_FIGHTER",
        ClassBaseLevel = 1,
        STR = 36, DEX = 35, CON = 36,
        INT = 23, WIT = 14, MEN = 26,
        BasePAtk = 4, BasePDef = 80, BasePAtkSpd = 300,
        BaseMAtk = 6, BaseMDef = 41, BaseMAtkSpd = 333,
        BaseEvasion = 36, BaseCritRate = 46,
        BaseAccuracy = 36, BaseRunSpd = 125,
        BaseHpRegen = 1.5, BaseMpRegen = 0.9,
        HpBase = 89, HpAdd = 12.74, HpMod = 0.37,
        MpBase = 30, MpAdd = 5.46, MpMod = 0.14,
        CpBase = 35.6, CpAdd = 5.00, CpMod = 0.22,
        ConBonus = 1.28, MenBonus = 1.30,
    }),
    ElvenMystic = table.freeze({
        SourceClassId = 25,
        SourceClassName = "ELF_MAGE",
        ClassBaseLevel = 1,
        STR = 21, DEX = 24, CON = 25,
        INT = 37, WIT = 23, MEN = 40,
        BasePAtk = 3, BasePDef = 54, BasePAtkSpd = 300,
        BaseMAtk = 6, BaseMDef = 41, BaseMAtkSpd = 333,
        BaseEvasion = 30, BaseCritRate = 41,
        BaseAccuracy = 30, BaseRunSpd = 122,
        BaseHpRegen = 1.5, BaseMpRegen = 0.9,
        HpBase = 104, HpAdd = 15.57, HpMod = 0.37,
        MpBase = 40, MpAdd = 7.38, MpMod = 0.14,
        CpBase = 52, CpAdd = 7.84, CpMod = 0.22,
        ConBonus = 0.93, MenBonus = 1.49,
    }),
    HumanWarrior = table.freeze({
        SourceClassId = 1,
        SourceClassName = "WARRIOR",
        ClassBaseLevel = 20,
        STR = 40, DEX = 30, CON = 43,
        INT = 21, WIT = 11, MEN = 25,
        BasePAtk = 4, BasePDef = 80, BasePAtkSpd = 300,
        BaseMAtk = 6, BaseMDef = 41, BaseMAtkSpd = 333,
        BaseEvasion = 33, BaseCritRate = 44,
        BaseAccuracy = 33, BaseRunSpd = 115,
        BaseHpRegen = 1.5, BaseMpRegen = 0.9,
        HpBase = 327, HpAdd = 33.00, HpMod = 0.37,
        MpBase = 144, MpAdd = 9.90, MpMod = 0.14,
        CpBase = 261.6, CpAdd = 26.40, CpMod = 0.22,
        ConBonus = 1.58, MenBonus = 1.28,
    }),
    HumanKnight = table.freeze({
        SourceClassId = 4,
        SourceClassName = "KNIGHT",
        ClassBaseLevel = 20,
        STR = 40, DEX = 30, CON = 43,
        INT = 21, WIT = 11, MEN = 25,
        BasePAtk = 4, BasePDef = 80, BasePAtkSpd = 300,
        BaseMAtk = 6, BaseMDef = 41, BaseMAtkSpd = 333,
        BaseEvasion = 33, BaseCritRate = 44,
        BaseAccuracy = 33, BaseRunSpd = 115,
        BaseHpRegen = 1.5, BaseMpRegen = 0.9,
        HpBase = 327, HpAdd = 29.70, HpMod = 0.37,
        MpBase = 144, MpAdd = 9.90, MpMod = 0.14,
        CpBase = 196.2, CpAdd = 17.82, CpMod = 0.22,
        ConBonus = 1.58, MenBonus = 1.28,
    }),
    HumanRogue = table.freeze({
        SourceClassId = 7,
        SourceClassName = "ROGUE",
        ClassBaseLevel = 20,
        STR = 40, DEX = 30, CON = 43,
        INT = 21, WIT = 11, MEN = 25,
        BasePAtk = 4, BasePDef = 80, BasePAtkSpd = 300,
        BaseMAtk = 6, BaseMDef = 41, BaseMAtkSpd = 333,
        BaseEvasion = 33, BaseCritRate = 44,
        BaseAccuracy = 33, BaseRunSpd = 115,
        BaseHpRegen = 1.5, BaseMpRegen = 0.9,
        HpBase = 327, HpAdd = 27.50, HpMod = 0.37,
        MpBase = 144, MpAdd = 9.90, MpMod = 0.14,
        CpBase = 130.8, CpAdd = 11.00, CpMod = 0.22,
        ConBonus = 1.58, MenBonus = 1.28,
    }),
    ElvenKnight = table.freeze({
        SourceClassId = 19,
        SourceClassName = "ELF_KNIGHT",
        ClassBaseLevel = 20,
        STR = 36, DEX = 35, CON = 36,
        INT = 23, WIT = 14, MEN = 26,
        BasePAtk = 4, BasePDef = 80, BasePAtkSpd = 300,
        BaseMAtk = 6, BaseMDef = 41, BaseMAtkSpd = 333,
        BaseEvasion = 36, BaseCritRate = 46,
        BaseAccuracy = 36, BaseRunSpd = 125,
        BaseHpRegen = 1.5, BaseMpRegen = 0.9,
        HpBase = 355, HpAdd = 33.00, HpMod = 0.37,
        MpBase = 144, MpAdd = 9.90, MpMod = 0.14,
        CpBase = 177.5, CpAdd = 16.50, CpMod = 0.22,
        ConBonus = 1.28, MenBonus = 1.30,
    }),
    ElvenScout = table.freeze({
        SourceClassId = 22,
        SourceClassName = "SCOUT",
        ClassBaseLevel = 20,
        STR = 36, DEX = 35, CON = 36,
        INT = 23, WIT = 14, MEN = 26,
        BasePAtk = 4, BasePDef = 80, BasePAtkSpd = 300,
        BaseMAtk = 6, BaseMDef = 41, BaseMAtkSpd = 333,
        BaseEvasion = 36, BaseCritRate = 46,
        BaseAccuracy = 36, BaseRunSpd = 125,
        BaseHpRegen = 1.5, BaseMpRegen = 0.9,
        HpBase = 355, HpAdd = 30.80, HpMod = 0.37,
        MpBase = 144, MpAdd = 9.90, MpMod = 0.14,
        CpBase = 142, CpAdd = 12.32, CpMod = 0.22,
        ConBonus = 1.28, MenBonus = 1.30,
    }),
})

local STARTERS = table.freeze({
    Human = table.freeze({
        Fighter = "HumanFighter",
        Mage = "HumanMystic",
    }),
    Elf = table.freeze({
        Fighter = "ElvenFighter",
        Mage = "ElvenMystic",
    }),
})

local FIRST_TRANSFERS = table.freeze({
    Ironvow = "HumanWarrior",
    Oathguard = "HumanKnight",
    Ashenblade = "HumanRogue",
    Emberweaver = "HumanWizard",
    Dawnkeeper = "HumanCleric",
    GreenwardWarden = "ElvenKnight",
    GreenwardScout = "ElvenScout",
})

local PRIMARY_NAMES = table.freeze({
    "STR", "DEX", "CON", "INT", "WIT", "MEN",
})

--[[
Finds the exact C4 source template for one supported saved class identity.

Args:
    race_id (string): Saved Human or Elf race.
    class_id (string): Starter or independently named first transfer.

Returns:
    string?: C4 source-template key, or nil for unsupported identity.
]]
local function resolve_template_key(
    race_id: string, class_id: string
): string?
    local starters = STARTERS[race_id]
    if starters and starters[class_id] then
        return starters[class_id]
    end
    local source_key = FIRST_TRANSFERS[class_id]
    local career = FirstTransfers.for_class(class_id)
    if not source_key or not career or career.RaceId ~= race_id then
        return nil
    end
    return source_key
end

--[[
Copies a C4 source template so callers cannot mutate historical data.

Args:
    source (any): Immutable exact class-template record.

Returns:
    any: Independently editable template snapshot.
]]
local function copy_template(source: any): any
    local result = {}
    for key, value in pairs(source) do
        result[key] = value
    end
    return result
end

--[[
Copies only the six C4 primary character statistics.

Args:
    template (any): Exact source class template.

Returns:
    any: STR/DEX/CON/INT/WIT/MEN snapshot.
]]
local function copy_primary_stats(template: any): any
    local result = {}
    for _, name in ipairs(PRIMARY_NAMES) do
        result[name] = template[name]
    end
    return result
end

--[[
Calculates source class growth before CON or MEN multiplication.

This is the exact positive-level arithmetic used by the C4
FuncMaxHpAdd/FuncMaxMpAdd/FuncMaxCpAdd implementations.

Args:
    base_value (number): Class template base HP, MP or CP.
    add_value (number): Per-level additive source coefficient.
    mod_value (number): Per-level increasing source coefficient.
    level_delta (number): Character level minus class base level.

Returns:
    number: Source pre-primary-stat maximum resource value.
]]
local function source_growth(
    base_value: number, add_value: number,
    mod_value: number, level_delta: number
): number
    local level_mod = mod_value * level_delta
    local maximum = (add_value + level_mod) * level_delta
    local minimum = (add_value * level_delta) + level_mod
    return base_value + (maximum + minimum) / 2
end

--[[
Returns the exact source template and six primary stats for one path.

Args:
    race_id (string): Historical Human or Elf identity.
    class_id (string): Starter or current first-transfer class ID.

Returns:
    any?: Copy of source metadata, template and six stats.
]]
function C4PrimaryStatReference.get(
    race_id: string, class_id: string
): any?
    local key = resolve_template_key(race_id, class_id)
    local template = key and TEMPLATES[key]
    if not template then
        return nil
    end
    return {
        ScopeId = key,
        SourceCommit = SOURCE_COMMIT,
        SourceUrls = SOURCE_URLS,
        Stats = copy_primary_stats(template),
        Template = copy_template(template),
        LevelGrowthVerified = true,
        LiveCombatIntegrated = false,
    }
end

--[[
Checks the server-owned character before exposing first-transfer source data.

Args:
    character (any): Actual current saved character.

Returns:
    any?: Exact starter or legitimately earned transfer reference.
]]
function C4PrimaryStatReference.for_character(
    character: any
): any?
    if type(character) ~= "table"
        or type(character.Identity) ~= "table"
    then
        return nil
    end
    local identity = character.Identity
    if identity.ClassId == identity.BaseClassId then
        return C4PrimaryStatReference.get(
            identity.RaceId, identity.ClassId
        )
    end
    local awarded = FirstTransfers.awarded(character)
    if not awarded or awarded.Id ~= identity.ClassId then
        return nil
    end
    return C4PrimaryStatReference.get(
        identity.RaceId, identity.ClassId
    )
end

--[[
Calculates exact C4 class-template HP/MP/CP for a supported level.

Positive Java numeric casts truncate these final resource values to
integers. Raw values are retained for exact formula inspection.

Args:
    race_id (string): Historical Human or Elf race.
    class_id (string): Exact starter or first-transfer class.
    level (number): Integer character level within initial 1-30 scope.

Returns:
    (any?, string?): Resource record, or fail-closed source reason.
]]
function C4PrimaryStatReference.get_level_vitals(
    race_id: string, class_id: string, level: number
): (any?, string?)
    local reference = C4PrimaryStatReference.get(race_id, class_id)
    local template = reference and reference.Template
    if not template
        or type(level) ~= "number"
        or level ~= level
        or level % 1 ~= 0
        or level < template.ClassBaseLevel
        or level > 30
    then
        return nil, "UnreviewedClassOrLevel"
    end
    local delta = level - template.ClassBaseLevel
    local raw_hp = source_growth(
        template.HpBase, template.HpAdd, template.HpMod, delta
    ) * template.ConBonus
    local raw_mp = source_growth(
        template.MpBase, template.MpAdd, template.MpMod, delta
    ) * template.MenBonus
    local raw_cp = source_growth(
        template.CpBase, template.CpAdd, template.CpMod, delta
    ) * template.ConBonus
    return {
        Level = level,
        SourceClassId = template.SourceClassId,
        SourceClassName = template.SourceClassName,
        ClassBaseLevel = template.ClassBaseLevel,
        RawMaxHP = raw_hp,
        RawMaxMP = raw_mp,
        RawMaxCP = raw_cp,
        MaxHP = math.floor(raw_hp),
        MaxMP = math.floor(raw_mp),
        MaxCP = math.floor(raw_cp),
        ConBonus = template.ConBonus,
        MenBonus = template.MenBonus,
        SourceCommit = SOURCE_COMMIT,
    }, nil
end

--[[
Reports exact source coverage without implying live stat integration.

Args:
    None.

Returns:
    any: All currently sourced original paths and migration status.
]]
function C4PrimaryStatReference.coverage(): any
    local paths = {
        {"Human", "Fighter"}, {"Human", "Mage"},
        {"Elf", "Fighter"}, {"Elf", "Mage"},
    }
    for _, career in ipairs(FirstTransfers.all()) do
        table.insert(paths, {career.RaceId, career.Id})
    end
    local result = {}
    for _, path in ipairs(paths) do
        local found = assert(C4PrimaryStatReference.get(
            path[1], path[2]
        ))
        table.insert(result, {
            RaceId = path[1],
            ClassId = path[2],
            SourceScope = found.ScopeId,
            SourceClassId = found.Template.SourceClassId,
            ClassBaseLevel = found.Template.ClassBaseLevel,
        })
    end
    return {
        PathCount = #result,
        VerifiedPrimaryStatTemplates = #result,
        VerifiedLevelGrowthTemplates = #result,
        VerifiedLevelCap = 30,
        SourceCommit = SOURCE_COMMIT,
        SourceUrls = SOURCE_URLS,
        LiveCombatIntegrated = false,
        Paths = result,
    }
end

return table.freeze(C4PrimaryStatReference)
