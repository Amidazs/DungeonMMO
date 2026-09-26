--!strict
-- Pinned Chronicle 4 NPC combat records for current Dungeon archetypes.

local Derived = require(script.Parent.C4DerivedStatReference)

local C4NpcSourceReference = {}

local SOURCE_COMMIT =
    "07f8536384e799f128d44198dd7ab23519660eea"

local SOURCE_ROOT =
    "https://github.com/Neco-spain/"
    .. "l2jadmins_C4-Scions-of-Destiny/blob/"
    .. SOURCE_COMMIT

local SOURCES = table.freeze({
    NpcSql = SOURCE_ROOT
        .. "/L2jAdmins_Data/sql/game/npc.sql",
    NpcSkillsSql = SOURCE_ROOT
        .. "/L2jAdmins_Data/sql/game/npc_skills.sql",
    NpcData = SOURCE_ROOT
        .. "/L2jAdmins_Core/src/l2j/gameserver/data/NpcData.java",
    Character = SOURCE_ROOT
        .. "/L2jAdmins_Core/src/l2j/gameserver/model/actor/"
        .. "L2Character.java",
})

local SOURCE_ROWS = table.freeze({
    Marauder = table.freeze({
        SourceNpcId = 325,
        SourceRaceSkillId = 4295,
        SourceNpcRace = "NONE",
        Level = 5,
        AttackRange = 40,
        BaseMaxHealth = 80.17319,
        BaseMaxMana = 77,
        BaseHealthRegen = 3.16,
        BaseManaRegen = 0.91,
        STR = 40,
        CON = 43,
        DEX = 30,
        INT = 21,
        WIT = 20,
        MEN = 10,
        BasePhysicalAttack = 12.34006,
        BasePhysicalDefence = 51.60553,
        BaseMagicalAttack = 8.42666,
        BaseMagicalDefence = 37.76269,
        BasePhysicalAttackSpeed = 253,
        BaseMagicalAttackSpeed = 333,
        BaseWalkSpeed = 40,
        BaseRunSpeed = 110,
        BasePhysicalCriticalRate = 38,
        BaseMagicalCriticalRate = 8,
    }),
    Wolf = table.freeze({
        SourceNpcId = 525,
        SourceRaceSkillId = 4293,
        SourceNpcRace = "ANIMAL",
        Level = 4,
        AttackRange = 40,
        BaseMaxHealth = 68.20985,
        BaseMaxMana = 68,
        BaseHealthRegen = 3.16,
        BaseManaRegen = 0.91,
        STR = 40,
        CON = 43,
        DEX = 30,
        INT = 21,
        WIT = 20,
        MEN = 10,
        BasePhysicalAttack = 11.24892,
        BasePhysicalDefence = 49.73343,
        BaseMagicalAttack = 7.68155,
        BaseMagicalDefence = 36.39277,
        BasePhysicalAttackSpeed = 253,
        BaseMagicalAttackSpeed = 333,
        BaseWalkSpeed = 24,
        BaseRunSpeed = 110,
        BasePhysicalCriticalRate = 38,
        BaseMagicalCriticalRate = 8,
    }),
})

--[[
Rounds a positive source value like Java Math.round.

Args:
    value (number): Positive source-derived value.

Returns:
    number: Nearest integer with .5 rounded upward.
]]
local function java_round(value: number): number
    return math.floor(value + 0.5)
end

--[[
Returns one required exact source primary-stat bonus.

Args:
    stat_name (string): C4 primary stat name.
    value (number): Source primary-stat integer.

Returns:
    number: Pinned two-decimal source bonus.
]]
local function source_bonus(
    stat_name: string,
    value: number
): number
    return assert(Derived.stat_bonus(stat_name, value))
end

--[[
Builds the final C4 combat candidate for one pinned NPC source row.

This mirrors the common L2Character calculator functions that the reviewed C4
server installs on ordinary NPCs. Raid/pet special cases are deliberately not
used by these two standard Dungeon mappings.

Args:
    row (any): Immutable pinned NPC SQL/source row.

Returns:
    any: Frozen final source combat-stat candidate.
]]
local function final_stats(row: any): any
    local level_modifier = assert(
        Derived.level_modifier(row.Level)
    )
    local str_bonus = source_bonus("STR", row.STR)
    local con_bonus = source_bonus("CON", row.CON)
    local dex_bonus = source_bonus("DEX", row.DEX)
    local int_bonus = source_bonus("INT", row.INT)
    local wit_bonus = source_bonus("WIT", row.WIT)
    local men_bonus = source_bonus("MEN", row.MEN)

    return table.freeze({
        PHYSICAL_ATTACK = math.floor(
            row.BasePhysicalAttack
                * str_bonus
                * level_modifier
        ),
        PHYSICAL_DEFENCE = math.floor(
            row.BasePhysicalDefence * level_modifier
        ),
        MAGICAL_ATTACK = math.floor(
            row.BaseMagicalAttack
                * level_modifier
                * level_modifier
                * int_bonus
                * int_bonus
        ),
        MAGICAL_DEFENCE = math.floor(
            row.BaseMagicalDefence
                * source_bonus("MEN", 10)
                * level_modifier
        ),
        PHYSICAL_ATTACK_SPEED = java_round(
            row.BasePhysicalAttackSpeed * dex_bonus
        ),
        MAGICAL_ATTACK_SPEED = math.floor(
            row.BaseMagicalAttackSpeed * wit_bonus
        ),
        RUN_SPEED = math.floor(
            row.BaseRunSpeed * level_modifier
        ),
        WALK_SPEED = row.BaseWalkSpeed,
        ACCURACY_COMBAT = java_round(
            math.sqrt(row.DEX) * 6 + row.Level
        ),
        EVASION_RATE = java_round(
            math.sqrt(row.DEX) * 6 + row.Level
        ),
        CRITICAL_RATE = math.floor(
            row.BasePhysicalCriticalRate
                * dex_bonus
                * 10
        ),
        MAGICAL_CRITICAL_RATE = row.BaseMagicalCriticalRate,
        PHYSICAL_CRITICAL_POWER = 1,
        PHYSICAL_CRITICAL_POWER_ADD = 0,
        FIRE_VULN = 1,
        WIND_VULN = 1,
        WATER_VULN = 1,
        EARTH_VULN = 1,
        HOLY_VULN = 1,
        DARK_VULN = 1,
        BLEED_VULN = 1,
        POISON_VULN = 1,
        BOW_WPN_VULN = 1,
        BLUNT_WPN_VULN = 1,
        DAGGER_WPN_VULN = 1,
        POLE_WPN_VULN = 1,
        SWORD_WPN_VULN = 1,
        MAX_HP = math.floor(row.BaseMaxHealth * con_bonus),
        MAX_MP = math.floor(row.BaseMaxMana * men_bonus),
        MAX_CP = 0,
    })
end

--[[
Builds one detached source-ready NPC combat boundary.

Source NPC names are intentionally absent. Creative Dungeon archetype IDs
remain the only player-facing identity; source IDs are internal provenance.

Args:
    archetype_id (string): Creative Dungeon enemy archetype.

Returns:
    (any?, string?): Frozen source combat boundary or fail-closed reason.
]]
function C4NpcSourceReference.get(
    archetype_id: string
): (any?, string?)
    local row = SOURCE_ROWS[archetype_id]
    if not row then
        return nil, "UnreviewedC4NpcArchetype"
    end

    local stats = final_stats(row)
    local con_bonus = source_bonus("CON", row.CON)
    local dex_bonus = source_bonus("DEX", row.DEX)
    local wit_bonus = source_bonus("WIT", row.WIT)
    local men_bonus = source_bonus("MEN", row.MEN)
    local str_bonus = source_bonus("STR", row.STR)

    return table.freeze({
        SourceTargetKind = "Npc",
        CreativeArchetypeId = archetype_id,
        SourceNpcId = row.SourceNpcId,
        SourceNpcRace = row.SourceNpcRace,
        SourceRaceSkillId = row.SourceRaceSkillId,
        Level = row.Level,
        SourceCommit = SOURCE_COMMIT,
        SourceCombatPrerequisitesReady = true,
        SourceStatCandidateReady = true,
        SourceStatCandidate = stats,
        SourceConBonus = con_bonus,
        SourceDexBonus = dex_bonus,
        SourceWitBonus = wit_bonus,
        SourceMenBonus = men_bonus,
        SourceStrBonus = str_bonus,
        SourceAttackRange = row.AttackRange,
        SourceBaseHealthRegen = row.BaseHealthRegen,
        SourceBaseManaRegen = row.BaseManaRegen,
        SourceBaseShieldDefence = 0,
        SourceBaseShieldRate = 0,
        PlayerFacingSourceNameExposed = false,
    }), nil
end

--[[
Returns current creative NPC archetypes with reviewed source records.

Args:
    None.

Returns:
    {string}: New ordered list of supported creative archetype IDs.
]]
function C4NpcSourceReference.supported_archetypes(): {string}
    return {
        "Marauder",
        "Wolf",
    }
end

--[[
Returns pinned source provenance for audit/documentation.

Args:
    None.

Returns:
    any: Source commit and source-file URLs.
]]
function C4NpcSourceReference.sources(): any
    return {
        SourceCommit = SOURCE_COMMIT,
        SourceUrls = SOURCES,
    }
end

return table.freeze(C4NpcSourceReference)
