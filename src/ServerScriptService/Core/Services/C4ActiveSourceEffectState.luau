--!strict
-- Server-only authoritative registry of currently active C4 source effects.

local ServerScriptService = game:GetService("ServerScriptService")

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

    state_for(owner)[creative_skill_id] = {
        Character = owner.Character,
        CreativeSkillId = creative_skill_id,
        CreativeRank = creative_rank,
        SourceSkillId = source.SkillId,
        SourceRank = source.Rank,
        OperateType = source.OperateType,
    }

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
    any: Sorted detached Source SkillId/Rank rows and authority metadata.
]]
function C4ActiveSourceEffectState.snapshot(owner: any): any
    if not valid_owner(owner) then
        C4ActiveSourceEffectState.clear(owner)
        return {
            SourceRanks = {},
            ActiveCount = 0,
            Authoritative = true,
        }
    end

    local state = active_by_owner[owner]
    if not state then
        return {
            SourceRanks = {},
            ActiveCount = 0,
            Authoritative = true,
        }
    end

    local rows = {}

    for creative_skill_id, record in pairs(state) do
        if record.Character ~= owner.Character then
            state[creative_skill_id] = nil
        else
            table.insert(rows, {
                SkillId = record.SourceSkillId,
                Rank = record.SourceRank,
                CreativeSkillId = record.CreativeSkillId,
                CreativeRank = record.CreativeRank,
                OperateType = record.OperateType,
            })
        end
    end

    if next(state) == nil then
        active_by_owner[owner] = nil
    end

    table.sort(rows, function(left, right)
        if left.SkillId == right.SkillId then
            return left.Rank < right.Rank
        end
        return left.SkillId < right.SkillId
    end)

    return {
        SourceRanks = rows,
        ActiveCount = #rows,
        Authoritative = true,
    }
end

return table.freeze(C4ActiveSourceEffectState)
