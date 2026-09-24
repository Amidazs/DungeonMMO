--!strict
-- Historical six-stat source baseline for all currently authored C4 paths.
-- This read-only reference is not yet the live Roblox stat provider.
local FirstTransfers = require(
    script.Parent.OriginalFirstTransferDefinitions
)

local C4PrimaryStatReference = {}

local PRIMARY_NAMES = table.freeze({
    "STR", "DEX", "CON", "INT", "WIT", "MEN",
})

-- Period C4 Fighter class pages plus archived Human/Elf racial baselines.
-- Classic's later published table corroborates these values, but is not
-- used as evidence for C4-specific level-by-level HP, MP or CP growth.
local SOURCE_URLS = table.freeze({
    HumanFighter = "https://l2hub.info/c4/classes/fighter",
    HumanMystic = "https://linedia.ru/wiki/Human",
    ElvenFighter = "https://linedia.ru/wiki/Elven_Fighter_%28C4%29",
    ElvenMystic = "https://linedia.ru/wiki/Elf",
})

local BASE = table.freeze({
    HumanFighter = table.freeze({
        STR = 40, DEX = 30, CON = 43,
        INT = 21, WIT = 11, MEN = 25,
    }),
    HumanMystic = table.freeze({
        STR = 22, DEX = 21, CON = 27,
        INT = 41, WIT = 20, MEN = 39,
    }),
    ElvenFighter = table.freeze({
        STR = 36, DEX = 35, CON = 36,
        INT = 23, WIT = 14, MEN = 26,
    }),
    ElvenMystic = table.freeze({
        STR = 21, DEX = 24, CON = 25,
        INT = 37, WIT = 23, MEN = 40,
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

--[[
Returns a separate editable snapshot of verified six-stat source values.

Args:
    baseline (any): Immutable source stat record.

Returns:
    any: New table whose mutation cannot alter historical reference.
]]
local function copy_stats(baseline: any): any
    local result = {}
    for _, stat_name in ipairs(PRIMARY_NAMES) do
        result[stat_name] = baseline[stat_name]
    end
    return result
end

--[[
Resolves a supported C4 starting class or independent first transfer.

Args:
    race_id (string): Saved Human or Elf race.
    class_id (string): Base class or original first-transfer class ID.

Returns:
    string?: Four-way starting class key or nil for unreviewed classes.
]]
local function resolve_scope(
    race_id: string, class_id: string
): string?
    local starters = STARTERS[race_id]
    if not starters then
        return nil
    end
    local original = starters[class_id]
    if original then
        return original
    end
    local career = FirstTransfers.for_class(class_id)
    if not career or career.RaceId ~= race_id then
        return nil
    end
    return starters[career.BaseClassId]
end

--[[
Returns the historical six-stat baseline for an existing C4 class.

First-transfer classes inherit their race's Fighter baseline. A
legacy custom Ranger or Rogue does not silently masquerade as C4.

Args:
    race_id (string): Saved Human or Elf race.
    class_id (string): Saved starter or original first-transfer ID.

Returns:
    any?: Independent reference record; nil for unsupported identity.
]]
function C4PrimaryStatReference.get(
    race_id: string, class_id: string
): any?
    local scope = resolve_scope(race_id, class_id)
    if not scope then
        return nil
    end
    return {
        ScopeId = scope,
        SourceUrl = SOURCE_URLS[scope],
        Stats = copy_stats(BASE[scope]),
        LevelGrowthVerified = false,
        LiveCombatIntegrated = false,
    }
end

--[[
Checks the server-owned character's original first-transfer receipt.

Args:
    character (any): Saved current character and source-quest award.

Returns:
    any?: Genuine starter/first-transfer baseline, not a forged label.
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
Refuses to present unsourced HP, MP or CP values as historical C4 data.

Args:
    race_id (string): Historical starting race.
    class_id (string): Exact historical class at current level.
    level (number): Positive integer source progression level.

Returns:
    (nil, string): Explicit unverified-source reason; no fake maxima.
]]
function C4PrimaryStatReference.get_level_vitals(
    race_id: string, class_id: string, level: number
): (nil, string)
    if type(level) ~= "number"
        or level ~= level or level % 1 ~= 0
        or level < 1 or level > 30
        or not resolve_scope(race_id, class_id)
    then
        return nil, "UnreviewedClassOrLevel"
    end
    return nil, "C4ClassLevelHpMpCpSourceUnverified"
end

--[[
Reports coverage without equating four baselines to nine full stat paths.

Args:
    None.

Returns:
    any: Nine resolved paths; zero verified per-level HP/MP/CP tables.
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
        local found = C4PrimaryStatReference.get(path[1], path[2])
        assert(found ~= nil, "Original first transfer has no stat source")
        table.insert(result, {
            RaceId = path[1], ClassId = path[2],
            SourceScope = found.ScopeId,
        })
    end
    return {
        PathCount = #result,
        VerifiedPrimaryStatBaselines = 4,
        VerifiedLevelGrowthTables = 0,
        LiveCombatIntegrated = false,
        Paths = result,
    }
end

return table.freeze(C4PrimaryStatReference)
