--!strict
-- Scheduled Dawnkeeper friendly-support cast bridge regression.

local ServerScriptService = game:GetService("ServerScriptService")

local SupportMagic = require(
    ServerScriptService.Core.Services.C4SourceSupportMagicCastService
)

local checks = 0
local next_cast_id = 20
local pending_skill = nil
local last_range = nil
local party_ready = true
local last_execution = nil

local caster = {
    UserId = 710001,
}

local target = {
    UserId = 710002,
}

local SOURCE_IDS = table.freeze({
    DawnkeeperHealingLight = 1011,
    DawnkeeperBattleMend = 1015,
    DawnkeeperGroupMend = 1027,
    DawnkeeperRevive = 1016,
    DawnkeeperMindWard = 1035,
})

local FakeScheduler = {}

--[[
Begins one deterministic support source schedule.

Args:
    _self (any): Fake scheduler receiver.
    _owner (any): Expected caster.
    skill_id (string): Reviewed creative support skill.
    supplied_now (number?): Deterministic start time.

Returns:
    (any?, string?): Fake scheduler start evidence.
]]
function FakeScheduler.begin_cast(
    _self: any,
    _owner: any,
    skill_id: string,
    supplied_now: number?
): (any?, string?)
    next_cast_id += 1
    pending_skill = skill_id
    local now = supplied_now or 100
    local party = skill_id == "DawnkeeperGroupMend"

    return {
        CastId = next_cast_id,
        CreativeSkillId = skill_id,
        CreativeRank = 1,
        SourceSkillId = SOURCE_IDS[skill_id],
        SourceRank = 1,
        StartedAt = now,
        InterruptAt = now + 1,
        LaunchAt = now + 2,
        FinalizerAt = now + 2,
        ReuseReadyAt = now + 8,
        SourceCastRange = if party then nil else (
            if skill_id == "DawnkeeperHealingLight"
                or skill_id == "DawnkeeperBattleMend"
            then 600
            else 400
        ),
        SourceEffectRange = if party then nil else (
            if skill_id == "DawnkeeperHealingLight"
                or skill_id == "DawnkeeperBattleMend"
            then 1100
            else 900
        ),
    }, nil
end

--[[
Cancels one fake pending source schedule.

Args:
    _self (any): Fake scheduler receiver.
    _owner (any): Disposable owner.
    _cast_id (number): Disposable receipt.

Returns:
    (boolean, string?): Successful cancellation.
]]
function FakeScheduler.cancel_cast(
    _self: any,
    _owner: any,
    _cast_id: number
): (boolean, string?)
    pending_skill = nil
    return true, nil
end

--[[
Launches one deterministic ready source schedule.

Args:
    _self (any): Fake scheduler receiver.
    _owner (any): Disposable owner.
    cast_id (number): Private cast receipt.
    _supplied_now (number?): Deterministic launch time.

Returns:
    (any?, string?): Fake source launch evidence.
]]
function FakeScheduler.launch_if_ready(
    _self: any,
    _owner: any,
    cast_id: number,
    _supplied_now: number?
): (any?, string?)
    local skill_id = assert(pending_skill)
    pending_skill = nil

    return {
        CastId = cast_id,
        CreativeSkillId = skill_id,
        CreativeRank = 1,
        SourceSkillId = SOURCE_IDS[skill_id],
        SourceRank = 1,
        ReadyForSourceEffectExecution = true,
    }, nil
end

--[[
Clears fake scheduler state.

Args:
    _self (any): Fake scheduler receiver.
    _owner (any): Disposable owner.

Returns:
    nil: Clears only test state.
]]
function FakeScheduler.clear_owner(
    _self: any,
    _owner: any
)
    pending_skill = nil
end

local FakeExecutor = {}

--[[
Preflights one fake friendly player target.

Args:
    _self (any): Fake executor receiver.
    _caster (any): Expected caster.
    _target (any): Expected friendly target.
    source_range (number?): Reviewed source range.

Returns:
    (boolean, string?): Always-ready target state.
]]
function FakeExecutor.can_support_skill_player(
    _self: any,
    _caster: any,
    _target: any,
    source_range: number?
): (boolean, string?)
    last_range = source_range
    return true, nil
end

--[[
Preflights one fake party heal.

Args:
    _self (any): Fake executor receiver.
    _caster (any): Expected caster.
    source_radius (number): Reviewed party radius.

Returns:
    (boolean, string?): Configurable party target state.
]]
function FakeExecutor.can_party_heal_skill(
    _self: any,
    _caster: any,
    source_radius: number
): (boolean, string?)
    last_range = source_radius
    if not party_ready then
        return false, "C4LivePartyHealNoEligibleTargets"
    end
    return true, nil
end

function FakeExecutor.can_resurrection_skill_player(
    _self: any,
    _caster: any,
    _target: any,
    source_range: number
): (boolean, string?)
    last_range = source_range
    return true, nil
end

--[[
Applies one fake targeted heal.

Args:
    _self (any): Fake executor receiver.
    _caster (any): Expected caster.
    _target (any): Expected target.
    skill_id (string): Reviewed heal.
    _rank (number): Creative rank.

Returns:
    (any?, string?): Fake heal evidence.
]]
function FakeExecutor.heal_skill_target(
    _self: any,
    _caster: any,
    _target: any,
    skill_id: string,
    _rank: number
): (any?, string?)
    last_execution = skill_id
    return {
        Applied = true,
        EffectiveHeal = 42,
    }, nil
end

--[[
Applies one fake targeted support buff.

Args:
    _self (any): Fake executor receiver.
    _caster (any): Expected caster.
    _target (any): Expected target.
    skill_id (string): Reviewed buff.
    _rank (number): Creative rank.

Returns:
    (any?, string?): Fake buff evidence.
]]
function FakeExecutor.mana_recharge_skill_target(
    _self: any,
    _caster: any,
    _target: any,
    skill_id: string,
    _rank: number
): (any?, string?)
    last_execution = skill_id
    return {
        Applied = true,
        EffectiveRecharge = 52,
    }, nil
end

function FakeExecutor.support_buff_skill_target(
    _self: any,
    _caster: any,
    _target: any,
    skill_id: string,
    _rank: number
): (any?, string?)
    last_execution = skill_id
    return {
        Applied = true,
        DurationSeconds = 1200,
    }, nil
end

--[[
Applies one fake party heal.

Args:
    _self (any): Fake executor receiver.
    _caster (any): Expected caster.
    skill_id (string): Reviewed party heal.
    _rank (number): Creative rank.

Returns:
    (any?, string?): Fake party-heal evidence.
]]
function FakeExecutor.party_heal_skill(
    _self: any,
    _caster: any,
    skill_id: string,
    _rank: number
): (any?, string?)
    last_execution = skill_id
    return {
        Applied = true,
        AffectedPlayers = 2,
        EffectiveHeal = 80,
    }, nil
end

function FakeExecutor.resurrection_skill_player(
    _self: any,
    _caster: any,
    _target: any,
    skill_id: string,
    _rank: number
): (any?, string?)
    last_execution = skill_id
    return {
        Applied = true,
        OfferCreated = true,
        RequiresTargetAcceptance = true,
        RestoreExperiencePower = 20,
    }, nil
end

--[[
Counts one support-bridge assertion.

Args:
    condition (boolean): Observed bridge state.
    label (string): Failure description.

Returns:
    nil: Raises on failure and increments the assertion count.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Support Magic Cast] " .. label)
end

--[[
Runs targeted heal, buff and party-heal bridge acceptance.

Args:
    None.

Returns:
    nil: Prints green focused regression evidence.
]]
local function main()
    local bridge = SupportMagic.new(
        FakeScheduler,
        FakeExecutor
    )

    local disabled, disabled_reason = bridge:begin_cast(
        caster,
        target,
        "DawnkeeperHealingLight",
        100
    )
    check(
        disabled == nil
            and disabled_reason == "C4SupportMagicCastDisabled",
        "support bridge starts disabled"
    )

    bridge:set_enabled(true)

    local heal_start = assert(bridge:begin_cast(
        caster,
        target,
        "DawnkeeperHealingLight",
        100
    ))
    check(
        heal_start.SourceSkillId == 1011
            and last_range == 600,
        "Healing Light preflights exact source cast range"
    )

    local healed = assert(bridge:launch_if_ready(
        caster,
        heal_start.CastId,
        102
    ))
    check(
        healed.Applied
            and healed.Application.EffectiveHeal == 42
            and last_execution == "DawnkeeperHealingLight"
            and last_range == 1100,
        "Healing Light revalidates effect range and reaches target heal"
    )

    local buff_start = assert(bridge:begin_cast(
        caster,
        target,
        "DawnkeeperMindWard",
        200
    ))
    local buffed = assert(bridge:launch_if_ready(
        caster,
        buff_start.CastId,
        202
    ))
    check(
        buffed.Applied
            and buffed.Application.DurationSeconds == 1200
            and last_execution == "DawnkeeperMindWard"
            and last_range == 900,
        "Mind Ward reaches timed support authority at exact effect range"
    )

    local party_start = assert(bridge:begin_cast(
        caster,
        nil,
        "DawnkeeperGroupMend",
        300
    ))
    check(
        party_start.SourceSkillId == 1027
            and party_start.PartyRosterServerSide
            and last_range == 1000,
        "Group Mend binds no client target and uses source party radius"
    )

    local party_heal = assert(bridge:launch_if_ready(
        caster,
        party_start.CastId,
        302
    ))
    check(
        party_heal.Applied
            and party_heal.Application.AffectedPlayers == 2
            and last_execution == "DawnkeeperGroupMend",
        "Group Mend reaches server-owned party heal authority"
    )

    local revive_start = assert(bridge:begin_cast(
        caster,
        target,
        "DawnkeeperRevive",
        350
    ))
    check(
        revive_start.SourceSkillId == 1016
            and revive_start.TargetBoundServerSide
            and last_range == 400,
        "Revive captures one dead server target at exact cast range"
    )

    local offered = assert(bridge:launch_if_ready(
        caster,
        revive_start.CastId,
        352
    ))
    check(
        offered.Applied
            and offered.Application.OfferCreated
            and offered.Application.RequiresTargetAcceptance
            and offered.Application.RestoreExperiencePower == 20
            and last_execution == "DawnkeeperRevive"
            and last_range == 900,
        "Revive creates a confirmation offer after effect-range recheck"
    )

    party_ready = false
    local rejected, rejected_reason = bridge:begin_cast(
        caster,
        nil,
        "DawnkeeperGroupMend",
        400
    )
    check(
        rejected == nil
            and rejected_reason
                == "C4LivePartyHealNoEligibleTargets",
        "Group Mend rejects empty party-heal work before MP spend"
    )

    local capability = bridge:capability()
    check(
        capability.ReviewedSkillCount == 15
            and capability.TargetHeal
            and capability.TargetBuff
            and capability.PartyHeal
            and capability.ResurrectionOffer
            and capability.ResurrectionTargetAcceptance
            and capability.ServerTargetAuthority
            and capability.ServerPartyRosterAuthority,
        "support bridge advertises all reviewed non-resurrection families"
    )

    print((
        "[C4 Support Magic Cast] PASS: %d assertions"
    ):format(checks))
end

main()
