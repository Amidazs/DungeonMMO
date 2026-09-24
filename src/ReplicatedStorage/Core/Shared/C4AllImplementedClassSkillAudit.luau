--!strict
-- Enumerate ALL implemented skill ranks by race/class, including legacy.
-- A recorded rank is not proof of matched source costs or combat maths.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared
local Classes = require(Shared.ClassProgressionDefinitions)
local Progression = require(Shared.SkillProgressionDefinitions)
local Combat = require(RS.Combat.Shared.SkillDefinitions)
local Examples = require(Shared.C4CrossClassSkillSamples)
local WardenSource = require(Shared.C4SkillEffectReference)

local Audit = {}
local CAP = 30

local SCOPES = table.freeze({
    {Id = "HumanFighter", Race = "Human", Base = "Fighter"},
    {Id = "ElvenFighter", Race = "Elf", Base = "Fighter"},
    {Id = "HumanMystic", Race = "Human", Base = "Mage"},
    {Id = "ElvenMystic", Race = "Elf", Base = "Mage"},
    {Id = "HumanRogue", Race = "Human", Base = "Fighter",
        Career = "Ashenblade"},
    {Id = "ElvenScout", Race = "Elf", Base = "Fighter",
        Career = "GreenwardScout"},
    {Id = "HumanWarrior", Race = "Human", Base = "Fighter",
        Career = "Ironvow"},
    {Id = "HumanKnight", Race = "Human", Base = "Fighter",
        Career = "Oathguard"},
    {Id = "ElvenKnight", Race = "Elf", Base = "Fighter",
        Career = "GreenwardWarden"},
    {Id = "LegacyHumanRanger", Race = "Human", Base = "Ranger",
        Legacy = true},
    {Id = "LegacyElvenRanger", Race = "Elf", Base = "Ranger",
        Legacy = true},
    {Id = "LegacyHumanRogue", Race = "Human", Base = "Rogue",
        Legacy = true},
    {Id = "LegacyElvenRogue", Race = "Elf", Base = "Rogue",
        Legacy = true},
})

local FIELDS = table.freeze({
    "SOURCE_POWER", "BASE_DAMAGE", "TOTAL_HEAL", "HEAL_AMOUNT",
    "MANA_COST", "STAMINA_COST", "COOLDOWN_SECONDS",
    "BUFF_MAGNITUDE", "BUFF_SECONDS", "TAUNT_BONUS_THREAT",
    "THREAT_REDUCTION_FRACTION", "STAGGER_SECONDS",
    "LIFE_DRAIN_FRACTION", "POISON_TICK_DAMAGE",
    "POISON_TICK_COUNT", "MAX_TARGETS", "CURE_POISON_TIER",
    "CURE_BLEED_TIER",
})

local PASSIVES = table.freeze({
    "DamageBonusPerRank", "PhysicalReductionPerRank",
    "MagicReductionPerRank", "PhysicalAttackPerRank",
    "MagicAttackPerRank", "PhysicalDefensePerRank",
    "MagicDefensePerRank", "ShieldDefensePerRank",
    "CriticalChancePerRank", "CriticalDamagePerRank",
    "EvasionPerRank", "SpeedPerRank", "HealthBonusPerRank",
    "SourcePhysicalAttackByRank",
})

--[[
Checks race and earned-original-career gates for one player context.

Args:
    skill (any): Actual skill progression and restrictions.
    scope (any): Authoritative supported class/race audit context.

Returns:
    boolean: Whether this registered skill belongs to that context.
]]
local function eligible(skill: any, scope: any): boolean
    for _, field in ipairs({"AllowedRaces", "AllowedBaseClasses"}) do
        local choices = skill[field]
        local wanted = if field == "AllowedRaces"
            then scope.Race else scope.Base
        if choices then
            local matches = false
            for _, choice in ipairs(choices) do
                if choice == wanted then matches = true end
            end
            if not matches then return false end
        end
    end
    local transfers = skill.AllowedFirstTransferClasses
    if transfers and scope.Base == "Fighter" then
        for _, career in ipairs(transfers) do
            if career == scope.Career then return true end
        end
        return false
    end
    return true
end

--[[
Aggregates inherited base and uniquely named career teachable skills.

Args:
    scope (any): One actual playable race, base and optional career.

Returns:
    {string}: Deduplicated actual registered ability identifiers.
]]
local function owned_ids(scope: any): {string}
    local names = {}
    local base = assert(Classes.get(scope.Base))
    local function add(class_data: any)
        for _, key in ipairs({"StarterSkills", "TeachableSkills"}) do
            for _, id in ipairs(class_data[key] or {}) do
                names[id] = true
            end
        end
    end
    add(base)
    if scope.Career then add(assert(Classes.get(scope.Career))) end
    local result = {}
    for id in pairs(names) do table.insert(result, id) end
    table.sort(result)
    return result
end

--[[
Reads original reference data when an individually verified row exists.

Args:
    scope (any): Original class path and race.
    skill_id (string): Actual named runtime skill ID.
    rank (number): Purchased runtime rank.

Returns:
    any?: Exact original sample or existing 24-row Warden source record.
]]
local function reference_for(
    scope: any, skill_id: string, rank: number
): any?
    local example = Examples.get(scope.Id)
    if example and example.SkillId == skill_id
        and example.Rank == rank
    then
        return {
            Power = example.Power, Mp = example.Mp,
            C4Rank = example.C4Rank, SourceUrl = example.SourceUrl,
        }
    end
    if scope.Id == "ElvenKnight" then
        local source = WardenSource.get(skill_id)
        if source and source.SourcePower[rank] then
            return {
                Power = source.SourcePower[rank],
                Mp = source.SourceMp[rank],
                C4Rank = rank + source.SourceRankOffset,
                SourceUrl = "https://l2hub.info/c4/classes/elven_knight",
            }
        end
    end
    return nil
end

--[[
Captures resolved combat magnitudes and authored passive statistics.

Args:
    skill (any): Actual progression rank metadata.
    skill_id (string): Registered current named skill.
    rank (number): One actual teachable or starter rank.

Returns:
    any: Named live parameters, never guessed original C4 values.
]]
local function runtime_values(
    skill: any, skill_id: string, rank: number
): any
    local combat = Combat.get_for_rank(skill_id, rank)
    local result = {}
    if combat then
        for _, field in ipairs(FIELDS) do
            if combat[field] ~= nil then
                result[field] = combat[field]
            end
        end
    end
    for _, field in ipairs(PASSIVES) do
        local value = skill[field]
        if value ~= nil then
            result[field] = if type(value) == "number"
                then value * rank else value[rank]
        end
    end
    return result
end

--[[
Records EVERY level-capped rank of one actual base or career class.

Args:
    scope (any): Race-specific starter, first-transfer or legacy route.

Returns:
    any: Full live rank ledger with explicit unverified source coverage.
]]
local function inspect_scope(scope: any): any
    local rows = {}
    local samples = 0
    local missing = {}
    local reviewed = {}
    for _, id in ipairs(owned_ids(scope)) do
        local skill = Progression.get(id)
        if not skill then
            table.insert(missing, id)
        elseif eligible(skill, scope) then
            for rank, level in pairs(skill.RankLevels or {}) do
                if level <= CAP then
                    local source = reference_for(scope, id, rank)
                    if source then
                        samples += 1
                        reviewed[id] = true
                    end
                    table.insert(rows, {
                        Class = scope.Id, SkillId = id, Rank = rank,
                        Level = level, Kind = skill.Kind,
                        Source = source,
                        Runtime = runtime_values(skill, id, rank),
                        -- Full authored tables remain accessible for
                        -- fields beyond the compact numeric summary.
                        ProgressionDefinition = skill,
                        CombatDefinition =
                            Combat.get_for_rank(id, rank),
                        SourceManaNumberMatches = if source
                            then (Combat.get_for_rank(id, rank)
                                or {}).MANA_COST == source.Mp
                            else nil,
                        ExactC4MechanicsCertified = false,
                    })
                end
            end
        end
    end
    table.sort(rows, function(a, b)
        if a.SkillId == b.SkillId then return a.Rank < b.Rank end
        return a.SkillId < b.SkillId
    end)
    local families = {}
    for _, row in ipairs(rows) do families[row.SkillId] = true end
    local family_count = 0
    for _ in pairs(families) do family_count += 1 end
    return {
        Id = scope.Id, Race = scope.Race, Base = scope.Base,
        Career = scope.Career, Legacy = scope.Legacy == true,
        HasDirectC4Path = scope.Legacy ~= true,
        SkillFamilies = family_count, RankRows = #rows,
        SourceRowsReviewed = samples,
        RankRowsWithoutExactSource = #rows - samples,
        SourceMatchedFamilies = reviewed,
        MissingProgressionSkills = missing,
        Rows = rows, ExactC4MechanicsCertified = false,
    }
end

--[[
Builds a reproducible whole-current-catalogue rank and effect ledger.

Args:
    None.

Returns:
    any: All 13 race-class scopes with every registered rank through 30.
]]
function Audit.report(): any
    local scopes = {}
    local total = 0
    local sampled = 0
    local mismatched_mp = 0
    for _, scope in ipairs(SCOPES) do
        local entry = inspect_scope(scope)
        table.insert(scopes, entry)
        total += entry.RankRows
        sampled += entry.SourceRowsReviewed
        for _, row in ipairs(entry.Rows) do
            if row.Source
                and row.SourceManaNumberMatches == false
            then
                mismatched_mp += 1
            end
        end
    end
    return {
        LevelCap = CAP, ClassScopes = #scopes,
        RanksExamined = total, SourceRowsReviewed = sampled,
        ReviewedRowsWithDifferentMp = mismatched_mp,
        OtherRankRowsNotSourceVerified = total - sampled,
        Classes = scopes, ExactC4MechanicalParityCertified = false,
    }
end

return table.freeze(Audit)
