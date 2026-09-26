--!strict
-- Original C4 Scout self-heal source contract.
-- Exact source semantics now back the live Greenward Scout skill family.
local Shared = script.Parent

local Identity = require(Shared.CharacterIdentityRules)
local Primary = require(Shared.C4PrimaryStatReference)
local Tree = require(Shared.C4Level30SkillTreeSource)
local Effects = require(Shared.C4SkillEffectSource)
local RuntimeRules = require(Shared.C4SkillRuntimeRules)

local C4ScoutHealMigrationPlan = {}

local SOURCE_SKILL_ID = 58
local SOURCE_RANK_OFFSET = 3
local FIRST_SOURCE_RANK = 4
local LAST_SOURCE_RANK = 12
local MAX_CHARACTER_LEVEL = 30
local PLANNED_CREATIVE_ID = "GreenwardScoutElementalHeal"

--[[
Builds the nine independent Scout class ranks from the pinned C4 data.

This never uses the Warden's owned skill or the Scout's existing HoT.
Original power remains an original formula input, not a heal amount.

Args:
    None.

Returns:
    {[number]: any}: Original-rank-indexed, immutable source contracts.
]]
local function build_contracts(): {[number]: any}
    local contracts = {}
    local rows = Tree.find_skill("ElvenScout", SOURCE_SKILL_ID)
    assert(#rows == 9, "Expected nine original Scout heal ranks")
    for _, row in ipairs(rows) do
        local source_rank = row.SkillLevel
        local rank = source_rank - SOURCE_RANK_OFFSET
        local expected_level = if rank <= 3 then 20
            elseif rank <= 6 then 24 else 28
        assert(rank >= 1 and rank <= 9
            and row.MinLevel == expected_level,
            "Scout heal rank or learning level differs from C4")
        local source = assert(Effects.get_rank(
            SOURCE_SKILL_ID, source_rank
        ), "Missing pinned Scout self-heal source rank")
        local sets = source.Sets
        local heal = source.Effects[1]
        assert(sets.target == "TARGET_SELF"
            and sets.skillType == "HEAL"
            and sets.operateType == "ACTIVE"
            and heal and heal.name == "Heal"
            and type(heal.power) == "number",
            "Scout heal must be an original instant self-heal")
        assert(type(sets.mpInitialConsume) == "number"
            and type(sets.mpConsume) == "number"
            and type(sets.hitTime) == "number"
            and type(sets.reuseDelay) == "number",
            "Scout heal requires pinned MP and cast/reuse times")
        local mana = RuntimeRules.split_mana_cost(
            sets.mpInitialConsume,
            sets.mpConsume
        )
        contracts[source_rank] = table.freeze({
            PlannedCreativeId = PLANNED_CREATIVE_ID,
            PlannedCreativeRank = rank,
            SourceSkillId = SOURCE_SKILL_ID,
            SourceSkillRank = source_rank,
            SourceLearnLevel = row.MinLevel,
            SourceSP = row.SP,
            SourcePower = heal.power,
            SourceHealUncharged = RuntimeRules.instant_heal(
                heal.power,
                false,
                false
            ),
            SourceHealSpiritshot = RuntimeRules.instant_heal(
                heal.power,
                true,
                false
            ),
            SourceHealBlessedSpiritshot = RuntimeRules.instant_heal(
                heal.power,
                false,
                true
            ),
            SourceInitialMP = mana.InitialMP,
            SourceOngoingMP = mana.OngoingMP,
            SourceTotalMP = mana.TotalMP,
            SourceTarget = sets.target,
            SourceCastMs = sets.hitTime,
            SourceReuseMs = sets.reuseDelay,
            SourceSkillType = sets.skillType,
            SourceOnly = true,
            LiveLearnable = true,
            LiveCastable = true,
            ExactC4HealFormulaCertified = true,
            SplitMPTransactionCertified = true,
        })
    end
    for source_rank = FIRST_SOURCE_RANK, LAST_SOURCE_RANK do
        assert(contracts[source_rank] ~= nil,
            "Missing original Scout self-heal rank")
    end
    return table.freeze(contracts)
end

local CONTRACTS = build_contracts()

--[[
Returns one exact Scout source rank backing the live creative family.

Args:
    source_rank (number): Original Elemental Heal skill level 4-12.

Returns:
    any?: Immutable future Scout skill contract, or nil out of range.
]]
function C4ScoutHealMigrationPlan.get_rank(
    source_rank: number
): any?
    return CONTRACTS[source_rank]
end

--[[
Lists the Scout-only historical self-heal ranks at an owner's level.

The original class and mentor receipt must be valid. This describes
the exact source ranks now used by the separately purchased live skill.

Args:
    character (any): Authoritative complete Elf Scout character.

Returns:
    (any?, string?): Safe source-only plan or a denial reason.
]]
function C4ScoutHealMigrationPlan.for_character(
    character: any
): (any?, string?)
    if not Identity.is_complete(character) then
        return nil, "OriginalCharacterIdentityNotVerified"
    end
    local source = Primary.for_character(character)
    if not source or source.ScopeId ~= "ElvenScout" then
        return nil, "OriginalElvenScoutRequired"
    end
    local level = character.Level
    if type(level) ~= "number" or level ~= level
        or level % 1 ~= 0 or level < 20
        or level > MAX_CHARACTER_LEVEL
    then
        return nil, "UnreviewedScoutLevel"
    end
    local rows = {}
    for source_rank = FIRST_SOURCE_RANK, LAST_SOURCE_RANK do
        local contract = CONTRACTS[source_rank]
        if contract.SourceLearnLevel <= level then
            table.insert(rows, contract)
        end
    end
    return {
        ScopeId = source.ScopeId,
        CharacterLevel = level,
        PlannedCreativeId = PLANNED_CREATIVE_ID,
        SourceRankOffset = SOURCE_RANK_OFFSET,
        Rows = rows,
        SourceOnly = true,
        LiveLearnable = true,
        LiveCastable = true,
        ExactC4HealFormulaCertified = true,
        SplitMPTransactionCertified = true,
    }, nil
end

return table.freeze(C4ScoutHealMigrationPlan)
