--!strict
-- Server-owned source cast contract for authenticated creative active skills.

local ServerScriptService = game:GetService("ServerScriptService")

local Effects = require(
    game:GetService("ReplicatedStorage").Core.Shared.C4SkillEffectSource
)
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
    (number?, string?): Valid finite value or an invalid-field reason.
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
    (number?, string?): Valid value or a strict missing/invalid reason.
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
Resolves the server-owned creative rank to its exact active source effect.

Args:
    user_id (number): Authenticated runtime character owner.
    creative_skill_id (string): Server-selected creative skill identifier.

Returns:
    (any?, any?, number?, string?): Source link, effect, creative rank, reason.
]]
local function resolve_source_effect(
    user_id: number,
    creative_skill_id: string
): (any?, any?, number?, string?)
    local creative_rank = Runtime.get_skill_rank(
        user_id,
        creative_skill_id
    )
    if creative_rank <= 0 then
        return nil, nil, nil, "CreativeCastSkillRankNotOwned"
    end

    local source, source_reason =
        Runtime.resolve_c4_active_source_effect(
            user_id,
            creative_skill_id,
            creative_rank
        )
    if not source then
        return nil, nil, nil, source_reason
    end

    local effect = Effects.get_rank(source.SkillId, source.Rank)
    if not effect or type(effect.Sets) ~= "table" then
        return nil, nil, nil, "OriginalCastEffectUnavailable"
    end

    return source, effect, creative_rank, nil
end

--[[
Extracts validated source MP, timing and range values from one source effect.

Args:
    sets (any): Exact source effect Set table.

Returns:
    (any?, string?): Validated detached source fields or denial reason.
]]
local function source_fields(sets: any): (any?, string?)
    local required = {}
    for _, field_name in ipairs({
        "mpInitialConsume",
        "mpConsume",
        "hitTime",
        "reuseDelay",
    }) do
        local value, reason = required_nonnegative(
            sets,
            field_name
        )
        if value == nil then
            return nil, reason
        end
        required[field_name] = value
    end

    local optional = {}
    for _, field_name in ipairs({
        "coolTime",
        "castRange",
        "effectRange",
    }) do
        local value, reason = optional_nonnegative(
            sets[field_name],
            field_name
        )
        if reason then
            return nil, reason
        end
        optional[field_name] = value
    end

    return {
        InitialMp = required.mpInitialConsume,
        OngoingMp = required.mpConsume,
        HitTimeMs = required.hitTime,
        ReuseDelayMs = required.reuseDelay,
        CoolTimeMs = optional.coolTime,
        CastRange = optional.castRange,
        EffectRange = optional.effectRange,
    }, nil
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

    local source, effect, creative_rank, source_reason =
        resolve_source_effect(user_id, creative_skill_id)
    if not source or not effect or not creative_rank then
        return nil, source_reason
    end

    local sets = effect.Sets
    if sets.operateType ~= "ACTIVE"
        and sets.operateType ~= "TOGGLE"
    then
        return nil, "UnsupportedOriginalCastOperateType"
    end

    local fields, fields_reason = source_fields(sets)
    if not fields then
        return nil, fields_reason
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
        SourceMpInitialConsume = fields.InitialMp,
        SourceMpConsume = fields.OngoingMp,
        SourceMpTotal = fields.InitialMp + fields.OngoingMp,
        SourceHitTimeMs = fields.HitTimeMs,
        SourceCoolTimeMs = fields.CoolTimeMs,
        SourceReuseDelayMs = fields.ReuseDelayMs,
        SourceCastRange = fields.CastRange,
        SourceEffectRange = fields.EffectRange,
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
