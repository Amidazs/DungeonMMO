--!strict
-- Nightweaver reuse acceptance for reviewed source-cast bridge families.

local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService.Core.Services

local DirectMagic = require(Services.C4SourceDirectMagicCastService)
local PeriodicMagic = require(Services.C4SourcePeriodicMagicCastService)
local CompanionMagic = require(Services.C4SourceCompanionCastService)
local CorpseMagic = require(Services.C4SourceCorpseMagicCastService)
local SelfMagic = require(Services.C4SourceSelfMagicCastService)

local OWNER = table.freeze({UserId = 938239})
local TARGET = table.freeze({Name = "TEMP_NightweaverTarget"})
local CORPSE = table.freeze({Name = "TEMP_NightweaverCorpse"})

local PLANS = table.freeze({
    NightweaverFlameBurst = {
        CreativeRank = 6, SourceSkillId = 1172, SourceRank = 6,
        CastRange = 150, EffectRange = 650,
    },
    NightweaverGaleBolt = {
        CreativeRank = 6, SourceSkillId = 1178, SourceRank = 6,
        CastRange = 750, EffectRange = 1250,
    },
    NightweaverEmberField = {
        CreativeRank = 3, SourceSkillId = 1181, SourceRank = 3,
        CastRange = 500, EffectRange = 1000,
    },
    NightweaverFrostLance = {
        CreativeRank = 2, SourceSkillId = 1184, SourceRank = 6,
        CastRange = 600, EffectRange = 1100,
    },
    NightweaverShadowSpark = {
        CreativeRank = 2, SourceSkillId = 1266, SourceRank = 2,
        CastRange = 750, EffectRange = 1250,
    },
    NightweaverUmbralSiphon = {
        CreativeRank = 4, SourceSkillId = 1147, SourceRank = 6,
        CastRange = 600, EffectRange = 1100,
    },
    NightweaverSlumberHex = {
        CreativeRank = 6, SourceSkillId = 1069, SourceRank = 6,
        CastRange = 600, EffectRange = 1100,
    },
    NightweaverVenomHex = {
        CreativeRank = 2, SourceSkillId = 1168, SourceRank = 3,
        CastRange = 600, EffectRange = 1100,
    },
    NightweaverVenomCloud = {
        CreativeRank = 1, SourceSkillId = 1167, SourceRank = 1,
        CastRange = 500, EffectRange = 1000,
    },
    NightweaverShadowCompanion = {
        CreativeRank = 3, SourceSkillId = 1128, SourceRank = 3,
    },
    NightweaverSilhouetteCompanion = {
        CreativeRank = 3, SourceSkillId = 1228, SourceRank = 3,
    },
    NightweaverServitorHeal = {
        CreativeRank = 9, SourceSkillId = 1127, SourceRank = 9,
    },
    NightweaverServitorRecharge = {
        CreativeRank = 4, SourceSkillId = 1126, SourceRank = 4,
    },
    NightweaverCorpseSiphon = {
        CreativeRank = 1, SourceSkillId = 1151, SourceRank = 1,
        CastRange = 400, EffectRange = 900,
    },
    NightweaverBloodToMana = {
        CreativeRank = 1, SourceSkillId = 1157, SourceRank = 1,
    },
    NightweaverVenomRend = {
        CreativeRank = 2, SourceSkillId = 1224, SourceRank = 2,
        CastRange = 750, EffectRange = 1250,
    },
})

local checks = 0
local next_cast_id = 200
local pending_by_owner = {}
local companion_active = false
local last_execution = nil

local FakeScheduler = {}

--[[
Begins one deterministic Nightweaver source schedule.

Args:
    owner (any): Expected server-owned caster.
    skill_id (string): Reviewed Nightweaver skill.
    supplied_now (number?): Deterministic start time.

Returns:
    (any?, string?): Source-shaped start evidence.
]]
function FakeScheduler:begin_cast(
    owner: any,
    skill_id: string,
    supplied_now: number?
): (any?, string?)
    local plan = PLANS[skill_id]
    if owner ~= OWNER or not plan then
        return nil, "NightweaverTestPlanUnavailable"
    end

    next_cast_id += 1
    local now = supplied_now or 100
    pending_by_owner[owner] = {
        CastId = next_cast_id,
        SkillId = skill_id,
    }

    return {
        CastId = next_cast_id,
        CreativeSkillId = skill_id,
        CreativeRank = plan.CreativeRank,
        SourceSkillId = plan.SourceSkillId,
        SourceRank = plan.SourceRank,
        SourceCastRange = plan.CastRange,
        SourceEffectRange = plan.EffectRange,
        StartedAt = now,
        InterruptAt = now + 1,
        LaunchAt = now + 2,
        FinalizerAt = now + 2.1,
        ReuseReadyAt = now + 6,
    }, nil
end

--[[
Cancels one deterministic test schedule.

Args:
    owner (any): Expected server-owned caster.
    cast_id (number): Private cast receipt.

Returns:
    (boolean, string?): Cancellation result.
]]
function FakeScheduler:cancel_cast(
    owner: any,
    cast_id: number
): (boolean, string?)
    local pending = pending_by_owner[owner]
    if not pending or pending.CastId ~= cast_id then
        return false, "NightweaverTestReceiptInvalid"
    end

    pending_by_owner[owner] = nil
    return true, nil
end

--[[
Launches one deterministic source schedule.

Args:
    owner (any): Expected server-owned caster.
    cast_id (number): Private cast receipt.
    _supplied_now (number?): Deterministic launch time.

Returns:
    (any?, string?): Source-effect-ready launch evidence.
]]
function FakeScheduler:launch_if_ready(
    owner: any,
    cast_id: number,
    _supplied_now: number?
): (any?, string?)
    local pending = pending_by_owner[owner]
    if not pending or pending.CastId ~= cast_id then
        return nil, "NightweaverTestReceiptInvalid"
    end

    pending_by_owner[owner] = nil
    local plan = assert(PLANS[pending.SkillId])
    return {
        CastId = cast_id,
        CreativeSkillId = pending.SkillId,
        CreativeRank = plan.CreativeRank,
        SourceSkillId = plan.SourceSkillId,
        SourceRank = plan.SourceRank,
        SourceCastRange = plan.CastRange,
        SourceEffectRange = plan.EffectRange,
        ReadyForSourceEffectExecution = true,
    }, nil
end

--[[
Clears one owner's deterministic scheduler state.

Args:
    owner (any): Departing test owner.

Returns:
    nil: Clears private fake state.
]]
function FakeScheduler:clear_owner(owner: any)
    pending_by_owner[owner] = nil
end

local FakeExecutor = {}

--[[
Accepts one reviewed living NPC target.

Args:
    owner (any): Expected caster.
    target (any): Expected target.
    _source_range (number?): Reviewed source range.

Returns:
    (boolean, string?): Target readiness.
]]
function FakeExecutor:can_magic_skill_npc(
    owner: any,
    target: any,
    _source_range: number?
): (boolean, string?)
    return owner == OWNER and target == TARGET, nil
end

--[[
Accepts one reviewed periodic-status NPC target.

Args:
    owner (any): Expected caster.
    target (any): Expected target.
    source_range (number?): Reviewed source range.

Returns:
    (boolean, string?): Target readiness.
]]
function FakeExecutor:can_status_skill_npc(
    owner: any,
    target: any,
    source_range: number?
): (boolean, string?)
    return self:can_magic_skill_npc(owner, target, source_range)
end

--[[
Accepts one reviewed NPC corpse.

Args:
    owner (any): Expected caster.
    corpse (any): Expected corpse.
    _source_range (number?): Reviewed source range.

Returns:
    (boolean, string?): Corpse readiness.
]]
function FakeExecutor:can_corpse_skill_npc(
    owner: any,
    corpse: any,
    _source_range: number?
): (boolean, string?)
    return owner == OWNER and corpse == CORPSE, nil
end

--[[
Accepts the unused undead-only preflight dependency.

Args:
    owner (any): Expected caster.
    target (any): Expected target.
    source_range (number?): Reviewed source range.

Returns:
    (boolean, string?): Target readiness.
]]
function FakeExecutor:can_undead_magic_skill_npc(
    owner: any,
    target: any,
    source_range: number?
): (boolean, string?)
    return self:can_magic_skill_npc(owner, target, source_range)
end

--[[
Returns one generic successful source application.

Args:
    skill_id (string): Executed creative skill.
    kind (string): Expected executor family.

Returns:
    any: Minimal live application evidence.
]]
local function applied(skill_id: string, kind: string): any
    last_execution = {
        SkillId = skill_id,
        Kind = kind,
    }
    return {
        Applied = true,
        Landed = true,
        StatusApplied = true,
        LandedCount = 1,
        TargetCount = 1,
    }
end

--[[
Installs one direct-magic executor method.

Args:
    method_name (string): Executor method name.
    kind (string): Expected family marker.

Returns:
    nil: Adds a deterministic fake method.
]]
local function install_direct_method(
    method_name: string,
    kind: string
)
    FakeExecutor[method_name] = function(
        _self: any,
        _owner: any,
        _target: any,
        skill_id: string,
        _rank: number,
        ...: any
    ): (any?, string?)
        return applied(skill_id, kind), nil
    end
end

install_direct_method("magic_skill_npc", "Direct")
install_direct_method("magic_slow_skill_npc", "Slow")
install_direct_method("magic_area_skill_npc", "Area")
install_direct_method("magic_drain_skill_npc", "Drain")
install_direct_method("sleep_skill_npc", "Sleep")
install_direct_method("elemental_vulnerability_skill_npc", "Elemental")
install_direct_method(
    "poison_vulnerability_skill_npc",
    "PoisonVulnerability"
)
install_direct_method("physical_attack_weakening_skill_npc", "Weakening")
install_direct_method(
    "physical_attack_rate_weakening_skill_npc",
    "RateWeakening"
)
install_direct_method("magic_undead_skill_npc", "Undead")
install_direct_method("root_skill_npc", "Root")

--[[
Executes one fake single-target periodic status.

Args:
    _owner (any): Expected caster.
    _target (any): Expected target.
    skill_id (string): Reviewed poison skill.
    _rank (number): Creative rank.
    _sequence_id (number?): Trusted sequence.

Returns:
    (any?, string?): Successful poison evidence.
]]
function FakeExecutor:status_skill_npc(
    _owner: any,
    _target: any,
    skill_id: string,
    _rank: number,
    _sequence_id: number?
): (any?, string?)
    return applied(skill_id, "Poison"), nil
end

--[[
Executes one fake target-area periodic status.

Args:
    _owner (any): Expected caster.
    _target (any): Selected target.
    skill_id (string): Reviewed poison-cloud skill.
    _rank (number): Creative rank.
    _radius (number): Reviewed source radius.
    _sequence_id (number?): Trusted sequence.

Returns:
    (any?, string?): Successful area-poison evidence.
]]
function FakeExecutor:status_area_skill_npc(
    _owner: any,
    _target: any,
    skill_id: string,
    _rank: number,
    _radius: number,
    _sequence_id: number?
): (any?, string?)
    return applied(skill_id, "PoisonArea"), nil
end

--[[
Executes one fake corpse drain.

Args:
    _owner (any): Expected caster.
    _corpse (any): Expected corpse.
    skill_id (string): Reviewed corpse skill.
    _rank (number): Creative rank.
    _sequence_id (number?): Trusted sequence.

Returns:
    (any?, string?): Successful corpse-drain evidence.
]]
function FakeExecutor:corpse_drain_skill_npc(
    _owner: any,
    _corpse: any,
    skill_id: string,
    _rank: number,
    _sequence_id: number?
): (any?, string?)
    return applied(skill_id, "CorpseDrain"), nil
end

--[[
Executes one fake HP-to-MP self skill.

Args:
    _owner (any): Expected caster.
    skill_id (string): Reviewed self skill.
    _rank (number): Creative rank.
    _sequence_id (number?): Trusted sequence.

Returns:
    (any?, string?): Successful mana-heal evidence.
]]
function FakeExecutor:mana_heal_self(
    _owner: any,
    skill_id: string,
    _rank: number,
    _sequence_id: number?
): (any?, string?)
    return applied(skill_id, "ManaHeal"), nil
end

--[[
Provides the unused self-heal dependency.

Args:
    _owner (any): Expected caster.
    skill_id (string): Reviewed self skill.
    _rank (number): Creative rank.

Returns:
    (any?, string?): Successful heal evidence.
]]
function FakeExecutor:heal_skill(
    _owner: any,
    skill_id: string,
    _rank: number
): (any?, string?)
    return applied(skill_id, "Heal"), nil
end

local FakeCompanions = {}

--[[
Reports current fake companion state.

Args:
    _owner (any): Expected owner.

Returns:
    any: Detached active-state snapshot.
]]
function FakeCompanions:snapshot(_owner: any): any
    return {Active = companion_active}
end

--[[
Checks whether a fake companion can be targeted.

Args:
    _owner (any): Expected owner.

Returns:
    (boolean, string?): Companion readiness.
]]
function FakeCompanions:can_target_owned(
    _owner: any
): (boolean, string?)
    if companion_active then
        return true, nil
    end
    return false, "C4OwnedCompanionUnavailable"
end

--[[
Executes one fake companion summon.

Args:
    _owner (any): Expected owner.
    skill_id (string): Reviewed summon.
    _rank (number): Creative rank.
    _role (string): Creative companion role.

Returns:
    (any?, string?): Successful summon evidence.
]]
function FakeCompanions:summon(
    _owner: any,
    skill_id: string,
    _rank: number,
    _role: string
): (any?, string?)
    companion_active = true
    return applied(skill_id, "Summon"), nil
end

--[[
Executes one fake companion heal.

Args:
    _owner (any): Expected owner.
    skill_id (string): Reviewed pet heal.
    _rank (number): Creative rank.

Returns:
    (any?, string?): Successful pet-heal evidence.
]]
function FakeCompanions:heal_owned(
    _owner: any,
    skill_id: string,
    _rank: number
): (any?, string?)
    return applied(skill_id, "ServitorHeal"), nil
end

--[[
Executes one fake companion recharge.

Args:
    _owner (any): Expected owner.
    skill_id (string): Reviewed pet recharge.
    _rank (number): Creative rank.

Returns:
    (any?, string?): Successful recharge evidence.
]]
function FakeCompanions:recharge_owned(
    _owner: any,
    skill_id: string,
    _rank: number
): (any?, string?)
    return applied(skill_id, "ServitorRecharge"), nil
end

--[[
Counts one Nightweaver bridge assertion.

Args:
    valid (boolean): Expected routing contract.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Nightweaver Cast Routing] " .. label)
end

--[[
Runs all reviewed Nightweaver direct-magic bridge families.

Args:
    None.

Returns:
    nil: Confirms seven direct/control families launch successfully.
]]
local function check_direct_magic()
    local skills = {
        "NightweaverFlameBurst",
        "NightweaverGaleBolt",
        "NightweaverEmberField",
        "NightweaverFrostLance",
        "NightweaverShadowSpark",
        "NightweaverUmbralSiphon",
        "NightweaverSlumberHex",
        "NightweaverVenomRend",
    }

    for index, skill_id in ipairs(skills) do
        local bridge = DirectMagic.new(FakeScheduler, FakeExecutor)
        bridge:set_enabled(true)
        local started = assert(bridge:begin_cast(
            OWNER, TARGET, skill_id, 100 + index
        ))
        local result = assert(bridge:launch_if_ready(
            OWNER, started.CastId, 110 + index, index
        ))
        check(
            result.Applied
                and result.SourceSkillId
                    == PLANS[skill_id].SourceSkillId
                and last_execution.SkillId == skill_id,
            skill_id .. " reaches reviewed direct executor"
        )
    end
end

--[[
Runs both Nightweaver periodic poison families.

Args:
    None.

Returns:
    nil: Confirms targeted and target-area poison routing.
]]
local function check_periodic_magic()
    for index, skill_id in ipairs({
        "NightweaverVenomHex",
        "NightweaverVenomCloud",
    }) do
        local bridge = PeriodicMagic.new(
            FakeScheduler,
            FakeExecutor
        )
        bridge:set_enabled(true)
        local started = assert(bridge:begin_cast(
            OWNER, TARGET, skill_id, 200 + index
        ))
        local result = assert(bridge:launch_if_ready(
            OWNER, started.CastId, 210 + index, 20 + index
        ))
        check(
            result.StatusResolved
                and result.StatusApplied
                and last_execution.SkillId == skill_id,
            skill_id .. " reaches periodic status executor"
        )
    end
end

--[[
Runs Nightweaver summon and servitor-support families.

Args:
    None.

Returns:
    nil: Confirms both summon identities and pet support routes.
]]
local function check_companion_magic()
    for index, skill_id in ipairs({
        "NightweaverShadowCompanion",
        "NightweaverSilhouetteCompanion",
    }) do
        companion_active = false
        local bridge = CompanionMagic.new(
            FakeScheduler,
            FakeCompanions
        )
        bridge:set_enabled(true)
        local started = assert(bridge:begin_cast(
            OWNER, skill_id, 300 + index
        ))
        local result = assert(bridge:launch_if_ready(
            OWNER, started.CastId, 310 + index
        ))
        check(
            result.Applied and last_execution.SkillId == skill_id,
            skill_id .. " reaches companion summon authority"
        )
    end

    companion_active = true
    for index, skill_id in ipairs({
        "NightweaverServitorHeal",
        "NightweaverServitorRecharge",
    }) do
        local bridge = CompanionMagic.new(
            FakeScheduler,
            FakeCompanions
        )
        bridge:set_enabled(true)
        local started = assert(bridge:begin_cast(
            OWNER, skill_id, 320 + index
        ))
        local result = assert(bridge:launch_if_ready(
            OWNER, started.CastId, 330 + index
        ))
        check(
            result.Applied and last_execution.SkillId == skill_id,
            skill_id .. " reaches owned companion authority"
        )
    end
end

--[[
Runs corpse-drain and self mana-conversion routes.

Args:
    None.

Returns:
    nil: Confirms remaining reviewed utility families.
]]
local function check_utility_magic()
    local corpse_bridge = CorpseMagic.new(
        FakeScheduler,
        FakeExecutor
    )
    corpse_bridge:set_enabled(true)
    local corpse_start = assert(corpse_bridge:begin_cast(
        OWNER, CORPSE, "NightweaverCorpseSiphon", 400
    ))
    local corpse_result = assert(corpse_bridge:launch_if_ready(
        OWNER, corpse_start.CastId, 402, 41
    ))
    check(
        corpse_result.Applied
            and last_execution.SkillId
                == "NightweaverCorpseSiphon",
        "Nightweaver Corpse Siphon reaches corpse authority"
    )

    local self_bridge = SelfMagic.new(FakeScheduler, FakeExecutor)
    self_bridge:set_enabled(true)
    local self_start = assert(self_bridge:begin_cast(
        OWNER, "NightweaverBloodToMana", 410
    ))
    local self_result = assert(self_bridge:launch_if_ready(
        OWNER, self_start.CastId, 412, 42
    ))
    check(
        self_result.Applied
            and last_execution.SkillId
                == "NightweaverBloodToMana",
        "Nightweaver Blood to Mana reaches self authority"
    )
end

--[[
Runs the Nightweaver reviewed bridge-reuse checkpoint.

Args:
    None.

Returns:
    nil: Prints exact reviewed active-family routing coverage.
]]
local function main()
    check_direct_magic()
    check_periodic_magic()
    check_companion_magic()
    check_utility_magic()

    check(
        checks == 16,
        "all sixteen reviewed non-support active families are exercised"
    )

    print((
        "[C4 Nightweaver Cast Routing] PASS: %d assertions "
            .. "reviewed_active_families=16 venom_rend=live"
    ):format(checks))
end

main()
