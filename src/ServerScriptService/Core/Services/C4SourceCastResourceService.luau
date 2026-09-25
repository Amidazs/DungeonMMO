--!strict
-- Disabled-by-default source split-MP lifecycle for authenticated C4 casts.

local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService.Core.Services

local DefaultCastContract = require(
    Services.C4SourceCastContractService
)
local C4SourceCastResourceService = {}
C4SourceCastResourceService.__index = C4SourceCastResourceService

--[[
Builds a source-cast resource lifecycle around explicit server dependencies.

Dependency injection keeps the transaction independently testable without
creating fake Players or widening any production client surface.

Args:
    options (any?): Optional CastContract, Resources and Mana authorities.

Returns:
    any: Isolated server-owned split-MP cast lifecycle.
]]
function C4SourceCastResourceService.new(options: any?): any
    local config = options or {}
    local cast_contract =
        config.CastContract or DefaultCastContract
    local resources = config.Resources
    local mana = config.Mana

    if not resources then
        resources = require(Services.C4ResourceCutoverService)
    end
    if not mana then
        mana = require(
            ServerScriptService.Combat.ManaService
        )
    end

    assert(
        type(cast_contract.resolve) == "function",
        "Source cast resource service requires cast-contract authority"
    )
    assert(
        type(resources.is_active) == "function",
        "Source cast resource service requires resource-cutover authority"
    )
    assert(
        type(mana.try_begin_split_spend) == "function"
            and type(mana.finish_split_spend) == "function",
        "Source cast resource service requires split-MP authority"
    )

    return setmetatable({
        _cast_contract = cast_contract,
        _resources = resources,
        _mana = mana,
        _active_by_owner = {},
        _next_cast_id = 0,
    }, C4SourceCastResourceService)
end

--[[
Clears one pending cast without refunding its source initial MP charge.

Chronicle 4 initial MP is already spent at cast start. Cancelling only prevents
the launch-time mpConsume amount from being applied.

Args:
    player (any): Server-owned cast owner.
    cast_id (number): Private cast receipt returned by begin_cast.

Returns:
    (boolean, string?): Cancellation result or stable receipt denial.
]]
function C4SourceCastResourceService:cancel_cast(
    player: any,
    cast_id: number
): (boolean, string?)
    local record = self._active_by_owner[player]

    if not record or record.CastId ~= cast_id then
        return false, "C4SourceCastReceiptInvalid"
    end

    self._active_by_owner[player] = nil
    return true, nil
end

--[[
Begins one exact source split-MP cast for a source-cutover participant.

The complete source cost must be affordable. Only mpInitialConsume is spent at
this phase. A player may have one pending source cast at a time.

Args:
    player (any): Server-owned cast owner with a numeric UserId.
    creative_skill_id (string): Server-selected currently owned creative skill.

Returns:
    (any?, string?): Private cast receipt/evidence or strict denial reason.
]]
function C4SourceCastResourceService:begin_cast(
    player: any,
    creative_skill_id: string
): (any?, string?)
    if type(player) ~= "table"
        and typeof(player) ~= "Instance"
    then
        return nil, "C4SourceCastOwnerInvalid"
    end
    if type(player.UserId) ~= "number"
        or player.UserId % 1 ~= 0
    then
        return nil, "C4SourceCastOwnerInvalid"
    end
    if self._active_by_owner[player] then
        return nil, "C4SourceCastAlreadyPending"
    end
    if self._resources.is_active(player) ~= true then
        return nil, "C4SourceCastResourceCutoverInactive"
    end

    local contract, contract_reason =
        self._cast_contract.resolve(
            player.UserId,
            creative_skill_id
        )
    if not contract then
        return nil, contract_reason
    end
    if contract.SourceOperateType ~= "ACTIVE" then
        return nil, "C4SourceCastOperateTypeUnsupported"
    end

    local spent = self._mana.try_begin_split_spend(
        player,
        contract.SourceMpInitialConsume,
        contract.SourceMpConsume
    )
    if not spent then
        return nil, "C4SourceCastManaInsufficient"
    end

    self._next_cast_id += 1
    local record = {
        CastId = self._next_cast_id,
        CreativeSkillId = creative_skill_id,
        CreativeRank = contract.CreativeRank,
        SourceSkillId = contract.SourceSkillId,
        SourceRank = contract.SourceRank,
        SourceMpInitialConsume =
            contract.SourceMpInitialConsume,
        SourceMpConsume = contract.SourceMpConsume,
    }
    self._active_by_owner[player] = record

    return {
        CastId = record.CastId,
        CreativeSkillId = record.CreativeSkillId,
        CreativeRank = record.CreativeRank,
        SourceSkillId = record.SourceSkillId,
        SourceRank = record.SourceRank,
        InitialMpSpent = record.SourceMpInitialConsume,
        LaunchMpPending = record.SourceMpConsume,
        SourceOnly = true,
        LiveDamageIntegrated = false,
    }, nil
end

--[[
Finishes one pending cast and applies only the source launch-time MP charge.

The current purchased/source rank is re-resolved before mutation. Losing the
class, skill or rank during a cast invalidates the receipt; initial MP remains
spent and no launch MP is charged.

Args:
    player (any): Server-owned cast owner.
    cast_id (number): Exact private receipt returned by begin_cast.

Returns:
    (any?, string?): Launch-spend evidence or strict denial reason.
]]
function C4SourceCastResourceService:commit_cast(
    player: any,
    cast_id: number
): (any?, string?)
    local record = self._active_by_owner[player]

    if not record or record.CastId ~= cast_id then
        return nil, "C4SourceCastReceiptInvalid"
    end

    self._active_by_owner[player] = nil

    if self._resources.is_active(player) ~= true then
        return nil, "C4SourceCastResourceCutoverInactive"
    end

    local current, current_reason =
        self._cast_contract.resolve(
            player.UserId,
            record.CreativeSkillId
        )
    if not current then
        return nil, current_reason
    end
    if current.CreativeRank ~= record.CreativeRank
        or current.SourceSkillId ~= record.SourceSkillId
        or current.SourceRank ~= record.SourceRank
        or current.SourceMpConsume ~= record.SourceMpConsume
    then
        return nil, "C4SourceCastAuthorityChanged"
    end

    local launch_spent = self._mana.finish_split_spend(
        player,
        record.SourceMpConsume
    )

    return {
        CastId = record.CastId,
        CreativeSkillId = record.CreativeSkillId,
        CreativeRank = record.CreativeRank,
        SourceSkillId = record.SourceSkillId,
        SourceRank = record.SourceRank,
        InitialMpSpent = record.SourceMpInitialConsume,
        LaunchMpRequested = record.SourceMpConsume,
        LaunchMpSpent = launch_spent,
        Completed = true,
        SourceOnly = true,
        LiveDamageIntegrated = false,
    }, nil
end

--[[
Clears pending private cast state for death, disconnect or cutover rollback.

Args:
    player (any): Server-owned cast owner being torn down.

Returns:
    nil: Removes only ephemeral cast state and never refunds source MP.
]]
function C4SourceCastResourceService:clear_owner(player: any)
    self._active_by_owner[player] = nil
end

--[[
Returns detached pending-cast evidence for diagnostics and tests.

Args:
    player (any): Server-owned cast owner.

Returns:
    any: Pending state without exposing a mutable internal record.
]]
function C4SourceCastResourceService:snapshot(player: any): any
    local record = self._active_by_owner[player]

    return {
        Pending = record ~= nil,
        CastId = if record then record.CastId else nil,
        CreativeSkillId = if record
            then record.CreativeSkillId else nil,
        SourceSkillId = if record then record.SourceSkillId else nil,
        SourceRank = if record then record.SourceRank else nil,
    }
end

--[[
Reports the deliberately source-only resource lifecycle boundary.

Args:
    None.

Returns:
    any: Capability flags for staged integration.
]]
function C4SourceCastResourceService.capability(): any
    return {
        Available = true,
        RequiresSourceResourceCutover = true,
        ServerOwnedPurchasedRank = true,
        TotalManaAffordabilityAtStart = true,
        InitialManaSpentAtCastStart = true,
        LaunchManaSpentAtCommit = true,
        InterruptedInitialManaNotRefunded = true,
        RevalidatesRankAtCommit = true,
        OnePendingCastPerOwner = true,
        LiveDamageIntegrated = false,
        ClientAuthority = false,
    }
end

return table.freeze(C4SourceCastResourceService)
