--!strict
-- Scheduled C4 self-magic bridge regression.

local ServerScriptService = game:GetService("ServerScriptService")

local SelfMagic = require(
    ServerScriptService.Core.Services.C4SourceSelfMagicCastService
)

local checks = 0
local next_cast_id = 70
local pending_skill = nil
local heal_calls = 0
local mana_calls = 0

local player = {
    UserId = 730091,
}

local SOURCE_BY_SKILL = {
    EmberweaverBloodToMana = {
        SourceSkillId = 1157,
        SourceRank = 4,
    },
    GreenwardScoutElementalHeal = {
        SourceSkillId = 58,
        SourceRank = 12,
    },
}

local FakeScheduler = {}

--[[
Begins one deterministic self-magic schedule.

Args:
    _owner (any): Disposable server-owned caster.
    skill_id (string): Reviewed creative skill.
    supplied_now (number?): Deterministic start time.

Returns:
    (any?, string?): Fake scheduler start evidence.
]]
function FakeScheduler:begin_cast(
    _owner: any,
    skill_id: string,
    supplied_now: number?
): (any?, string?)
    local source = assert(SOURCE_BY_SKILL[skill_id])
    local now = supplied_now or 100
    next_cast_id += 1
    pending_skill = skill_id

    return {
        CastId = next_cast_id,
        CreativeSkillId = skill_id,
        CreativeRank = if skill_id
            == "GreenwardScoutElementalHeal"
            then 9
            else 4,
        SourceSkillId = source.SourceSkillId,
        SourceRank = source.SourceRank,
        StartedAt = now,
        InterruptAt = now + 2.5,
        LaunchAt = now + 5,
        FinalizerAt = now + 5,
        ReuseReadyAt = now + 10,
        ReadyForSourceEffectExecution = false,
    }, nil
end

--[[
Cancels one deterministic self-magic schedule.

Args:
    _owner (any): Disposable owner.
    _cast_id (number): Disposable private receipt.

Returns:
    (boolean, string?): Successful cancellation.
]]
function FakeScheduler:cancel_cast(
    _owner: any,
    _cast_id: number
): (boolean, string?)
    pending_skill = nil
    return true, nil
end

--[[
Launches one deterministic self-magic schedule.

Args:
    _owner (any): Disposable owner.
    cast_id (number): Private cast receipt.
    _supplied_now (number?): Deterministic launch time.

Returns:
    (any?, string?): Ready source launch evidence.
]]
function FakeScheduler:launch_if_ready(
    _owner: any,
    cast_id: number,
    _supplied_now: number?
): (any?, string?)
    local skill_id = assert(pending_skill)
    local source = assert(SOURCE_BY_SKILL[skill_id])
    pending_skill = nil

    return {
        CastId = cast_id,
        CreativeSkillId = skill_id,
        CreativeRank = if skill_id
            == "GreenwardScoutElementalHeal"
            then 9
            else 4,
        SourceSkillId = source.SourceSkillId,
        SourceRank = source.SourceRank,
        ReadyForSourceEffectExecution = true,
    }, nil
end

--[[
Clears disposable scheduler state.

Args:
    _owner (any): Disposable owner.

Returns:
    nil: Clears only test state.
]]
function FakeScheduler:clear_owner(_owner: any)
    pending_skill = nil
end

local FakeExecutor = {}

--[[
Records one self-heal execution.

Args:
    subject (any): Expected cast owner.
    skill_id (string): Expected Scout self-heal.
    rank (number): Expected creative rank.

Returns:
    (any?, string?): Fake heal evidence.
]]
function FakeExecutor:heal_skill(
    subject: any,
    skill_id: string,
    rank: number
): (any?, string?)
    assert(subject == player)
    assert(skill_id == "GreenwardScoutElementalHeal")
    assert(rank == 9)
    heal_calls += 1

    return {
        Applied = true,
        Kind = "C4LiveHealSkill",
        EffectiveHeal = 157,
    }, nil
end

--[[
Records one Blood To Mana execution.

Args:
    subject (any): Expected cast owner.
    skill_id (string): Expected Wizard self-mana skill.
    rank (number): Expected creative rank.
    _sequence_id (number?): Disposable sequence.

Returns:
    (any?, string?): Fake mana-heal evidence.
]]
function FakeExecutor:mana_heal_self(
    subject: any,
    skill_id: string,
    rank: number,
    _sequence_id: number?
): (any?, string?)
    assert(subject == player)
    assert(skill_id == "EmberweaverBloodToMana")
    assert(rank == 4)
    mana_calls += 1

    return {
        Applied = true,
        Kind = "C4LiveManaHeal",
        HpConsumed = 28,
        ManaRestored = 22,
    }, nil
end

--[[
Counts one self-magic bridge assertion.

Args:
    condition (boolean): Observed bridge state.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch and counts the assertion.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Self Magic Cast] " .. label)
end

--[[
Runs reviewed self-magic routing and gate acceptance.

Args:
    None.

Returns:
    nil: Prints bounded green evidence.
]]
local function main()
    local bridge = SelfMagic.new(
        FakeScheduler,
        FakeExecutor
    )

    local blocked, blocked_reason = bridge:begin_cast(
        player,
        "GreenwardScoutElementalHeal",
        100
    )
    check(
        blocked == nil
            and blocked_reason == "C4SelfMagicCastDisabled",
        "self-magic bridge starts disabled"
    )

    bridge:set_enabled(true)

    local heal_start = assert(bridge:begin_cast(
        player,
        "GreenwardScoutElementalHeal",
        110
    ))
    check(
        heal_start.SourceSkillId == 58
            and heal_start.SourceRank == 12
            and heal_start.CreativeRank == 9,
        "Scout rank nine binds exact source Elemental Heal 58:12"
    )

    local heal = assert(bridge:launch_if_ready(
        player,
        heal_start.CastId,
        115,
        901
    ))
    check(
        heal.Applied
            and heal.Application.Kind == "C4LiveHealSkill"
            and heal.Application.EffectiveHeal == 157
            and heal_calls == 1
            and mana_calls == 0,
        "Scout self-heal reaches heal executor without mana-heal routing"
    )

    local mana_start = assert(bridge:begin_cast(
        player,
        "EmberweaverBloodToMana",
        200
    ))
    local mana = assert(bridge:launch_if_ready(
        player,
        mana_start.CastId,
        205,
        902
    ))
    check(
        mana.Applied
            and mana.Application.Kind == "C4LiveManaHeal"
            and mana_calls == 1
            and heal_calls == 1,
        "existing Blood To Mana route remains intact"
    )

    local capability = bridge:capability()
    check(
        capability.ReviewedBloodToMana
            and capability.ReviewedScoutElementalHeal
            and not capability.ClientAuthority,
        "capability advertises both reviewed self-magic families"
    )

    print((
        "[C4 Self Magic Cast] PASS: %d assertions"
    ):format(checks))
end

main()
