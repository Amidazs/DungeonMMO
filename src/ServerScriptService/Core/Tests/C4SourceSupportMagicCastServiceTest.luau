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
    EmberweaverConcentration = 1078,
    MoonweaverConcentration = 1078,
    NightweaverConcentration = 1078,
    DuskseerConcentration = 1078,
    DuskseerEmpower = 1059,
    DuskseerBloodRite = 1268,
    OrcMysticSoulShield = 1010,
    AshspeakerSoulShield = 1010,
    AshspeakerFlameChant = 1002,
    AshspeakerWarPower = 1003,
    AshspeakerFireChant = 1006,
    AshspeakerBattleChant = 1007,
    AshspeakerShieldingChant = 1009,
    AshspeakerLifeChant = 1229,
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
        or skill_id == "AshspeakerFlameChant"
        or skill_id == "AshspeakerFireChant"
        or skill_id == "AshspeakerBattleChant"
        or skill_id == "AshspeakerShieldingChant"
        or skill_id == "AshspeakerLifeChant"

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

--[[
Preflights one fake TARGET_PARTY support cast.

Args:
    _self (any): Fake executor receiver.
    _caster (any): Expected caster.
    source_radius (number): Reviewed party support radius.

Returns:
    (boolean, string?): Configurable support target state.
]]
function FakeExecutor.can_party_support_skill(
    _self: any,
    _caster: any,
    source_radius: number
): (boolean, string?)
    last_range = source_radius

    if not party_ready then
        return false, "C4LivePartySupportNoEligibleTargets"
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

--[[
Applies one fake TARGET_PARTY timed buff.

Args:
    _self (any): Fake executor receiver.
    _caster (any): Expected caster.
    skill_id (string): Reviewed chant.
    _rank (number): Creative rank.

Returns:
    (any?, string?): Fake party-buff evidence.
]]
function FakeExecutor.party_buff_skill(
    _self: any,
    _caster: any,
    skill_id: string,
    _rank: number
): (any?, string?)
    last_execution = skill_id

    return {
        Applied = true,
        AffectedPlayers = 2,
        DurationSeconds = 1200,
    }, nil
end

--[[
Applies one fake TARGET_PARTY regeneration buff.

Args:
    _self (any): Fake executor receiver.
    _caster (any): Expected caster.
    skill_id (string): Reviewed Life Chant.
    _rank (number): Creative rank.

Returns:
    (any?, string?): Fake party-HoT evidence.
]]
function FakeExecutor.party_regen_skill(
    _self: any,
    _caster: any,
    skill_id: string,
    _rank: number
): (any?, string?)
    last_execution = skill_id

    return {
        Applied = true,
        Scheduled = true,
        AffectedPlayers = 2,
        HealPerTick = 12,
        TickCount = 15,
        TickSeconds = 1,
        DurationSeconds = 15,
    }, nil
end

--[[
Applies the currently supported TARGET_ALLY self subset.

Args:
    _self (any): Fake executor receiver.
    _caster (any): Expected caster.
    skill_id (string): Reviewed War Power.
    _rank (number): Creative rank.

Returns:
    (any?, string?): Fake self-subset ally-buff evidence.
]]
function FakeExecutor.ally_buff_skill_self(
    _self: any,
    _caster: any,
    skill_id: string,
    _rank: number
): (any?, string?)
    last_execution = skill_id

    return {
        Applied = true,
        AffectedPlayers = 1,
        ClanAllianceTargetsPending = true,
        DurationSeconds = 1200,
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

    for index, skill_id in ipairs({
        "EmberweaverConcentration",
        "MoonweaverConcentration",
        "NightweaverConcentration",
        "DuskseerConcentration",
    }) do
        local concentration_start = assert(bridge:begin_cast(
            caster,
            target,
            skill_id,
            220 + index
        ))
        check(
            concentration_start.SourceSkillId == 1078
                and concentration_start.SourceRank == 1
                and last_range == 400,
            skill_id .. " binds exact Concentration source identity"
        )

        local concentrated = assert(bridge:launch_if_ready(
            caster,
            concentration_start.CastId,
            230 + index
        ))
        check(
            concentrated.Applied
                and concentrated.Application.DurationSeconds == 1200
                and last_execution == skill_id
                and last_range == 900,
            skill_id .. " reaches timed target-buff authority"
        )
    end

    for index, skill_id in ipairs({
        "DuskseerEmpower",
        "DuskseerBloodRite",
    }) do
        local buff_start = assert(bridge:begin_cast(
            caster,
            target,
            skill_id,
            250 + index
        ))
        check(
            buff_start.SourceSkillId == SOURCE_IDS[skill_id]
                and buff_start.SourceRank == 1
                and last_range == 400,
            skill_id .. " binds exact Duskseer support source identity"
        )

        local buffed_result = assert(bridge:launch_if_ready(
            caster,
            buff_start.CastId,
            260 + index
        ))
        check(
            buffed_result.Applied
                and buffed_result.Application.DurationSeconds == 1200
                and last_execution == skill_id
                and last_range == 900,
            skill_id .. " reaches timed target-buff authority"
        )
    end

    for index, skill_id in ipairs({
        "OrcMysticSoulShield",
        "AshspeakerSoulShield",
    }) do
        local shield_start = assert(bridge:begin_cast(
            caster,
            target,
            skill_id,
            280 + index
        ))
        check(
            shield_start.SourceSkillId == 1010
                and shield_start.SourceRank == 1
                and last_range == 400,
            skill_id .. " binds exact Soul Shield source identity"
        )

        local shielded = assert(bridge:launch_if_ready(
            caster,
            shield_start.CastId,
            290 + index
        ))
        check(
            shielded.Applied
                and shielded.Application.DurationSeconds == 1200
                and last_execution == skill_id
                and last_range == 900,
            skill_id .. " reaches timed target-buff authority"
        )
    end

    for index, skill_id in ipairs({
        "AshspeakerFlameChant",
        "AshspeakerFireChant",
        "AshspeakerBattleChant",
        "AshspeakerShieldingChant",
    }) do
        local chant_start = assert(bridge:begin_cast(
            caster,
            nil,
            skill_id,
            300 + index
        ))
        check(
            chant_start.SourceSkillId == SOURCE_IDS[skill_id]
                and chant_start.PartyRosterServerSide
                and not chant_start.TargetBoundServerSide
                and last_range == 1000,
            skill_id .. " preflights exact TARGET_PARTY radius"
        )

        local chanted = assert(bridge:launch_if_ready(
            caster,
            chant_start.CastId,
            310 + index
        ))
        check(
            chanted.Applied
                and chanted.Application.AffectedPlayers == 2
                and chanted.Application.DurationSeconds == 1200
                and last_execution == skill_id
                and last_range == 1000,
            skill_id .. " reaches server-owned party-buff authority"
        )
    end

    local war_power_start = assert(bridge:begin_cast(
        caster,
        nil,
        "AshspeakerWarPower",
        320
    ))
    check(
        war_power_start.SourceSkillId == 1003
            and not war_power_start.TargetBoundServerSide
            and not war_power_start.PartyRosterServerSide,
        "War Power ignores client target and uses the exact ally-safe subset"
    )

    local war_power = assert(bridge:launch_if_ready(
        caster,
        war_power_start.CastId,
        322
    ))
    check(
        war_power.Applied
            and war_power.Application.AffectedPlayers == 1
            and war_power.Application.ClanAllianceTargetsPending
            and war_power.Application.DurationSeconds == 1200
            and last_execution == "AshspeakerWarPower",
        "War Power applies only the supported caster subset"
    )

    local life_start = assert(bridge:begin_cast(
        caster,
        nil,
        "AshspeakerLifeChant",
        330
    ))
    check(
        life_start.SourceSkillId == 1229
            and life_start.PartyRosterServerSide
            and not life_start.TargetBoundServerSide
            and last_range == 1000,
        "Life Chant binds no client target and uses source party radius"
    )

    local life = assert(bridge:launch_if_ready(
        caster,
        life_start.CastId,
        332
    ))
    check(
        life.Applied
            and life.Application.Scheduled
            and life.Application.AffectedPlayers == 2
            and life.Application.HealPerTick == 12
            and life.Application.TickCount == 15
            and life.Application.TickSeconds == 1
            and life.Application.DurationSeconds == 15
            and last_execution == "AshspeakerLifeChant",
        "Life Chant reaches exact party HealOverTime authority"
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
        capability.ReviewedSkillCount == 53
            and capability.TargetHeal
            and capability.TargetRecharge
            and capability.TargetBuff
            and capability.PartyHeal
            and capability.PartyBuff
            and capability.PartyRegen
            and capability.AllyBuffSelfSubset
            and capability.ClanAllianceAllyTargetsPending
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
