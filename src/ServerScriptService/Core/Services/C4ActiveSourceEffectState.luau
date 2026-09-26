--!strict
-- Server-only authoritative registry of currently active C4 source effects.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local SkillEffects = require(
    ReplicatedStorage.Core.Shared.C4SkillEffectSource
)
local ProgressionRuntimeState = require(
    ServerScriptService.Core.Services.ProgressionRuntimeState
)

local C4ActiveSourceEffectState = {}

local active_by_owner: {[any]: any} = setmetatable({}, {
    __mode = "k",
})

--[[
Returns whether an owner has the minimum server identity required here.

Production callers are Player instances. Tests may use a table-shaped owner so
the registry can be verified in unpublished server-only RunScript tests.

Args:
    owner (any): Server-owned Player or disposable test owner.

Returns:
    boolean: True when UserId and current Character are available.
]]
local function valid_owner(owner: any): boolean
    return owner ~= nil
        and type(owner.UserId) == "number"
        and owner.Character ~= nil
end

--[[
Returns or creates the private active-effect dictionary for one owner.

Args:
    owner (any): Server-owned Player or disposable test owner.

Returns:
    any: Mutable creative-skill keyed active state dictionary.
]]
local function state_for(owner: any): any
    local state = active_by_owner[owner]

    if state then
        return state
    end

    state = {}
    active_by_owner[owner] = state
    return state
end

--[[
Stores one resolved or unresolved server-observed active effect.

Args:
    owner (any): Valid server-owned effect owner.
    creative_skill_id (string): Server-selected creative skill ID.
    creative_rank (number): Server-selected purchased rank.
    source (any?): Reviewed C4 source row when resolution succeeded.
    reason (string?): Source-resolution reason when it did not.
    expires_at (number?): Server monotonic expiry for timed effects.

Returns:
    nil: Replaces only the same creative skill's prior observation.
]]
local function store_effect(
    owner: any,
    creative_skill_id: string,
    creative_rank: number,
    source: any?,
    reason: string?,
    expires_at: number?
)
    local record: any = {
        Character = owner.Character,
        CreativeSkillId = creative_skill_id,
        CreativeRank = creative_rank,
        ExpiresAt = expires_at,
        ResolutionReason = reason,
    }

    if source then
        record.SourceSkillId = source.SkillId
        record.SourceRank = source.Rank
        record.OperateType = source.OperateType
    end

    state_for(owner)[creative_skill_id] = record
end

--[[
Removes stale, respawned or expired observations from one owner.

Args:
    owner (any): Current server-owned Player or disposable test owner.
    state (any): Mutable active-effect dictionary for that owner.

Returns:
    nil: Leaves only observations still bound to the current character.
]]
local function purge_stale(owner: any, state: any)
    local now = os.clock()

    for creative_skill_id, record in pairs(state) do
        local expired = type(record.ExpiresAt) == "number"
            and record.ExpiresAt <= now

        if record.Character ~= owner.Character or expired then
            state[creative_skill_id] = nil
        end
    end
end

--[[
Registers one effect only after an existing server executor activates it.

Source IDs are never accepted from callers. They are resolved again from the
authoritative progression snapshot using the creative ID and server rank.

Args:
    owner (any): Server-owned Player or disposable test owner.
    creative_skill_id (string): Server-activated creative skill ID.
    creative_rank (number): Server-resolved purchased creative rank.

Returns:
    (boolean, string?): Success or a strict source-resolution reason.
]]
function C4ActiveSourceEffectState.activate(
    owner: any,
    creative_skill_id: string,
    creative_rank: number
): (boolean, string?)
    if not valid_owner(owner) then
        return false, "InvalidActiveEffectOwner"
    end

    local source, reason =
        ProgressionRuntimeState.resolve_c4_active_source_effect(
            owner.UserId,
            creative_skill_id,
            creative_rank
        )

    if not source then
        return false, reason
    end

    store_effect(
        owner,
        creative_skill_id,
        creative_rank,
        source,
        nil,
        nil
    )

    return true, nil
end

--[[
Observes one server-applied timed effect without changing live gameplay.

Unlike strict toggle activation, a timed live effect is retained even when its
creative rank has no reviewed C4 active mapping. That unresolved observation
keeps later source migration fail-closed instead of silently dropping a live
custom effect from the source-stat candidate.

Args:
    owner (any): Server-owned Player or disposable test owner.
    creative_skill_id (string): Server-applied creative skill ID.
    creative_rank (number): Server-selected purchased creative rank.
    duration_seconds (number): Server-owned live effect duration.

Returns:
    (boolean, string?): True when the live observation was recorded, plus the
        source-resolution reason when the effect is currently unmapped.
]]
function C4ActiveSourceEffectState.observe_timed(
    owner: any,
    creative_skill_id: string,
    creative_rank: number,
    duration_seconds: number
): (boolean, string?)
    if not valid_owner(owner) then
        return false, "InvalidActiveEffectOwner"
    end

    if type(creative_skill_id) ~= "string"
        or creative_skill_id == ""
        or type(creative_rank) ~= "number"
        or creative_rank % 1 ~= 0
        or creative_rank < 1
        or type(duration_seconds) ~= "number"
        or duration_seconds ~= duration_seconds
        or duration_seconds <= 0
        or duration_seconds > 3600
    then
        return false, "InvalidTimedActiveEffect"
    end

    local source, reason =
        ProgressionRuntimeState.resolve_c4_active_source_effect(
            owner.UserId,
            creative_skill_id,
            creative_rank
        )

    store_effect(
        owner,
        creative_skill_id,
        creative_rank,
        source,
        reason,
        os.clock() + duration_seconds
    )

    return true, reason
end

--[[
Observes one server-resolved timed C4 effect cast by another player.

This path is intentionally source-rank based because the target does not own
the caster's creative skill. The server executor must already have resolved the
source identity from the caster. This registry revalidates that rank and
operate type before it can influence the target's source-stat snapshot.

Args:
    owner (any): Server-owned target Player or disposable test owner.
    creative_skill_id (string): Stable DungeonMMO skill identity.
    creative_rank (number): Server-resolved caster creative rank.
    source_skill_id (number): Server-resolved C4 source skill ID.
    source_rank (number): Server-resolved C4 source rank.
    duration_seconds (number): Positive server-owned effect duration.

Returns:
    (boolean, string?): Success or strict source/effect validation reason.
]]
function C4ActiveSourceEffectState.observe_external_timed(
    owner: any,
    creative_skill_id: string,
    creative_rank: number,
    source_skill_id: number,
    source_rank: number,
    duration_seconds: number
): (boolean, string?)
    if not valid_owner(owner) then
        return false, "InvalidActiveEffectOwner"
    end
    if type(creative_skill_id) ~= "string"
        or creative_skill_id == ""
        or type(creative_rank) ~= "number"
        or creative_rank % 1 ~= 0
        or creative_rank < 1
        or type(source_skill_id) ~= "number"
        or source_skill_id % 1 ~= 0
        or source_skill_id < 1
        or type(source_rank) ~= "number"
        or source_rank % 1 ~= 0
        or source_rank < 1
        or type(duration_seconds) ~= "number"
        or duration_seconds ~= duration_seconds
        or duration_seconds <= 0
        or duration_seconds > 3600
    then
        return false, "InvalidExternalTimedActiveEffect"
    end

    local effect = SkillEffects.get_rank(
        source_skill_id,
        source_rank
    )
    if not effect then
        return false, "OriginalActiveEffectUnavailable"
    end

    local operate_type = effect.Sets.operateType
    if operate_type ~= "ACTIVE"
        and operate_type ~= "TOGGLE"
    then
        return false, "OriginalExternalEffectNotActive"
    end

    store_effect(
        owner,
        creative_skill_id,
        creative_rank,
        {
            SkillId = source_skill_id,
            Rank = source_rank,
            OperateType = operate_type,
        },
        nil,
        os.clock() + duration_seconds
    )

    return true, nil
end

--[[
Removes one creative effect from authoritative active state.

Args:
    owner (any): Server-owned Player or disposable test owner.
    creative_skill_id (string): Creative skill whose live effect ended.

Returns:
    nil: The effect can no longer appear in a source-effect snapshot.
]]
function C4ActiveSourceEffectState.deactivate(
    owner: any,
    creative_skill_id: string
)
    local state = active_by_owner[owner]
    if not state then
        return
    end

    state[creative_skill_id] = nil

    if next(state) == nil then
        active_by_owner[owner] = nil
    end
end

--[[
Clears every authoritative active source effect for an owner.

Args:
    owner (any): Server-owned Player or disposable test owner.

Returns:
    nil: Respawn/removal cleanup cannot leave stale source active state.
]]
function C4ActiveSourceEffectState.clear(owner: any)
    active_by_owner[owner] = nil
end

--[[
Returns a detached source-rank snapshot for effects that are still live.

A character-instance change invalidates the owner's entire prior snapshot.
Replicated attributes are never consulted, so clients cannot mint C4 effects.

Args:
    owner (any): Server-owned Player or disposable test owner.

Returns:
    any: Resolved source ranks, unresolved live effects and authority metadata.
]]
function C4ActiveSourceEffectState.snapshot(owner: any): any
    if not valid_owner(owner) then
        C4ActiveSourceEffectState.clear(owner)
        return {
            SourceRanks = {},
            UnresolvedEffects = {},
            ActiveCount = 0,
            ResolvedCount = 0,
            Ready = true,
            Authoritative = true,
        }
    end

    local state = active_by_owner[owner]
    if not state then
        return {
            SourceRanks = {},
            UnresolvedEffects = {},
            ActiveCount = 0,
            ResolvedCount = 0,
            Ready = true,
            Authoritative = true,
        }
    end

    purge_stale(owner, state)

    local by_source_skill = {}
    local unresolved = {}
    local active_count = 0

    for _, record in pairs(state) do
        active_count += 1

        if type(record.SourceSkillId) == "number"
            and type(record.SourceRank) == "number"
        then
            local current = by_source_skill[record.SourceSkillId]

            if not current
                or record.SourceRank > current.Rank
            then
                by_source_skill[record.SourceSkillId] = {
                    SkillId = record.SourceSkillId,
                    Rank = record.SourceRank,
                    CreativeSkillId = record.CreativeSkillId,
                    CreativeRank = record.CreativeRank,
                    OperateType = record.OperateType,
                }
            end
        else
            table.insert(unresolved, {
                CreativeSkillId = record.CreativeSkillId,
                CreativeRank = record.CreativeRank,
                Reason = record.ResolutionReason
                    or "CreativeSkillNotActiveSourceCandidate",
            })
        end
    end

    if next(state) == nil then
        active_by_owner[owner] = nil
    end

    local rows = {}
    for _, row in pairs(by_source_skill) do
        table.insert(rows, row)
    end

    table.sort(rows, function(left, right)
        if left.SkillId == right.SkillId then
            return left.Rank < right.Rank
        end
        return left.SkillId < right.SkillId
    end)
    table.sort(unresolved, function(left, right)
        return left.CreativeSkillId < right.CreativeSkillId
    end)

    return {
        SourceRanks = rows,
        UnresolvedEffects = unresolved,
        ActiveCount = active_count,
        ResolvedCount = #rows,
        Ready = #unresolved == 0,
        Authoritative = true,
    }
end

return table.freeze(C4ActiveSourceEffectState)
