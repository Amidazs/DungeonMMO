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
Validates one server-owned cast owner without accepting client identity data.

Args:
    player (any): Player instance or isolated server test owner.

Returns:
    boolean: True when a numeric integral UserId is available.
]]
local function valid_owner(player: any): boolean
    if type(player) ~= "table"
        and typeof(player) ~= "Instance"
    then
        return false
    end

    return type(player.UserId) == "number"
        and player.UserId % 1 == 0
end

--[[
Checks that a pending receipt still matches the currently owned source rank.

Args:
    record (any): Private cast-start receipt.
    current (any): Newly resolved authoritative source cast contract.

Returns:
    boolean: True only when skill/rank and launch cost are unchanged.
]]
local function same_authority(record: any, current: any): boolean
    return current.CreativeRank == record.CreativeRank
        and current.SourceSkillId == record.SourceSkillId
        and current.SourceRank == record.SourceRank
        and current.SourceMpConsume == record.SourceMpConsume
end

--[[
Creates detached cast-start evidence from one private pending record.

Args:
    record (any): Private cast-start transaction.

Returns:
    any: Non-mutable diagnostic/start evidence.
]]
local function begin_evidence(record: any): any
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
    }
end

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
Creates and stores one pending receipt after the source initial MP spend.

Args:
    player (any): Valid server-owned cast owner.
    creative_skill_id (string): Selected creative skill.
    contract (any): Authenticated current source cast contract.

Returns:
    any: Private pending record now owned by this lifecycle.
]]
function C4SourceCastResourceService:_start_record(
    player: any,
    creative_skill_id: string,
    contract: any
): any
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
    return record
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
    if not valid_owner(player) then
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

    return begin_evidence(self:_start_record(
        player,
        creative_skill_id,
        contract
    )), nil
end

--[[
Builds detached successful launch evidence after the ongoing MP spend.

Args:
    record (any): Private cast-start receipt.
    launch_spent (number): Actual launch-time MP removed.

Returns:
    any: Source-only completed-cast evidence.
]]
local function commit_evidence(
    record: any,
    launch_spent: number
): any
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
    }
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
    if not same_authority(record, current) then
        return nil, "C4SourceCastAuthorityChanged"
    end

    local launch_spent = self._mana.finish_split_spend(
        player,
        record.SourceMpConsume
    )
    return commit_evidence(record, launch_spent), nil
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
