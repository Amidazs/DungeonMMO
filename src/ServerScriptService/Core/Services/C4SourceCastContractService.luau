--!strict
-- Server-owned source cast contract for authenticated creative active skills.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared
local Effects = require(Shared.C4SkillEffectSource)
local Runtime = require(
    ServerScriptService.Core.Services.ProgressionRuntimeState
)

local C4SourceCastContractService = {}

--[[
Validates one optional nonnegative source numeric field.

Args:
    value (any): Candidate source field value.
    field_name (string): Stable source key used in denial reasons.

Returns:
    (number?, string?): Valid finite value or a strict invalid-field reason.
]]
local function optional_nonnegative(
    value: any,
    field_name: string
): (number?, string?)
    if value == nil then
        return nil, nil
    end

    if type(value) ~= "number"
        or value ~= value
        or value < 0
        or value >= math.huge
    then
        return nil, "InvalidOriginalCastField:" .. field_name
    end

    return value, nil
end

--[[
Reads one mandatory nonnegative source numeric field.

Args:
    sets (any): Exact source effect Set table.
    field_name (string): Required source field key.

Returns:
    (number?, string?): Valid finite value or strict missing/invalid reason.
]]
local function required_nonnegative(
    sets: any,
    field_name: string
): (number?, string?)
    local value, reason = optional_nonnegative(
        sets[field_name],
        field_name
    )
    if reason then
        return nil, reason
    end
    if value == nil then
        return nil, "MissingOriginalCastField:" .. field_name
    end

    return value, nil
end

--[[
Resolves the currently purchased creative rank to one exact source cast plan.

The purchased rank is read from server-owned progression state. Callers cannot
supply or downgrade a rank. This service does not spend MP, start cooldowns or
convert source range/timing units into Roblox runtime values.

Args:
    user_id (number): Authenticated runtime character owner.
    creative_skill_id (string): Server-selected creative skill identifier.

Returns:
    (any?, string?): Detached exact source cast metadata or denial reason.
]]
function C4SourceCastContractService.resolve(
    user_id: number,
    creative_skill_id: string
): (any?, string?)
    if type(user_id) ~= "number"
        or user_id % 1 ~= 0
        or type(creative_skill_id) ~= "string"
        or creative_skill_id == ""
    then
        return nil, "InvalidOriginalCastRequest"
    end

    local creative_rank = Runtime.get_skill_rank(
        user_id,
        creative_skill_id
    )
    if creative_rank <= 0 then
        return nil, "CreativeCastSkillRankNotOwned"
    end

    local source, source_reason =
        Runtime.resolve_c4_active_source_effect(
            user_id,
            creative_skill_id,
            creative_rank
        )
    if not source then
        return nil, source_reason
    end

    local effect = Effects.get_rank(
        source.SkillId,
        source.Rank
    )
    if not effect or type(effect.Sets) ~= "table" then
        return nil, "OriginalCastEffectUnavailable"
    end

    local sets = effect.Sets
    if sets.operateType ~= "ACTIVE"
        and sets.operateType ~= "TOGGLE"
    then
        return nil, "UnsupportedOriginalCastOperateType"
    end

    local mp_initial, initial_reason =
        required_nonnegative(sets, "mpInitialConsume")
    if mp_initial == nil then
        return nil, initial_reason
    end

    local mp_consume, consume_reason =
        required_nonnegative(sets, "mpConsume")
    if mp_consume == nil then
        return nil, consume_reason
    end

    local hit_time, hit_reason =
        required_nonnegative(sets, "hitTime")
    if hit_time == nil then
        return nil, hit_reason
    end

    local reuse_delay, reuse_reason =
        required_nonnegative(sets, "reuseDelay")
    if reuse_delay == nil then
        return nil, reuse_reason
    end

    local cool_time, cool_reason =
        optional_nonnegative(sets.coolTime, "coolTime")
    if cool_reason then
        return nil, cool_reason
    end

    local cast_range, cast_reason =
        optional_nonnegative(sets.castRange, "castRange")
    if cast_reason then
        return nil, cast_reason
    end

    local effect_range, effect_range_reason =
        optional_nonnegative(sets.effectRange, "effectRange")
    if effect_range_reason then
        return nil, effect_range_reason
    end

    return table.freeze({
        CreativeSkillId = creative_skill_id,
        CreativeRank = creative_rank,
        SourceScopeId = source.ScopeId,
        SourceSkillId = source.SkillId,
        SourceRank = source.Rank,
        SourceOperateType = sets.operateType,
        SourceSkillType = sets.skillType,
        SourceTarget = sets.target,
        SourceIsMagic = sets.isMagic == true,
        SourceMpInitialConsume = mp_initial,
        SourceMpConsume = mp_consume,
        SourceMpTotal = mp_initial + mp_consume,
        SourceHitTimeMs = hit_time,
        SourceCoolTimeMs = cool_time,
        SourceReuseDelayMs = reuse_delay,
        SourceCastRange = cast_range,
        SourceEffectRange = effect_range,
        SourceOnly = true,
        LiveResourceSpendIntegrated = false,
        LiveTimingIntegrated = false,
        ClientAuthority = false,
    }), nil
end

--[[
Reports the server-only migration boundary for source cast metadata.

Args:
    None.

Returns:
    any: Capability flags that prevent source metadata from implying live use.
]]
function C4SourceCastContractService.capability(): any
    return {
        Available = true,
        ServerOwnedPurchasedRank = true,
        ExactSourceMpFields = true,
        ExactSourceTimingFields = true,
        ExactSourceRangeMetadata = true,
        LiveResourceSpendIntegrated = false,
        LiveTimingIntegrated = false,
        ClientAuthority = false,
    }
end

return table.freeze(C4SourceCastContractService)
