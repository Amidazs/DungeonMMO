--!strict
-- Disabled source dispatch bridge regression.

local ServerScriptService = game:GetService("ServerScriptService")

local Adapter = require(
    ServerScriptService.Core.Services.C4CombatDispatchAdapter
)

local checks = 0
local executor_enabled = false
local installed_observer = nil
local calls = {}

local FakeExecutor = {}

--[[
Counts one dispatch-adapter assertion.

Args:
    valid (boolean): Expected bridge condition.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Combat Dispatch] " .. label)
end

--[[
Reports the disposable executor gate.

Args:
    None.

Returns:
    boolean: Current fake executor state.
]]
function FakeExecutor:is_enabled(): boolean
    return executor_enabled
end

--[[
Receives the trusted post-damage observer from the adapter.

Args:
    observer (any?): Pending or current callback.

Returns:
    nil: Stores the callback for bridge-order assertions.
]]
function FakeExecutor:set_npc_damage_observer(observer: any?)
    installed_observer = observer
end

--[[
Records one fake ordinary NPC source attack.

Args:
    attacker (any): Fixture attacker.
    target (Model): Fixture NPC.
    sequence_id (number?): Server action sequence.

Returns:
    (any?, string?): Successful disposable source result.
]]
function FakeExecutor:normal_attack_npc(
    attacker: any,
    target: Model,
    sequence_id: number?
): (any?, string?)
    table.insert(calls, {
        Kind = "Normal",
        UserId = attacker.UserId,
        Target = target,
        SequenceId = sequence_id,
    })
    return {
        Applied = true,
        Miss = false,
        HealthDamage = 10,
    }, nil
end

--[[
Records one fake physical NPC source skill.

Args:
    attacker (any): Fixture attacker.
    target (Model): Fixture NPC.
    skill_id (string): Server-selected skill.
    rank (number): Server-resolved rank.
    sequence_id (number?): Server action sequence.

Returns:
    (any?, string?): Successful disposable source result.
]]
function FakeExecutor:physical_skill_npc(
    attacker: any,
    target: Model,
    skill_id: string,
    rank: number,
    sequence_id: number?
): (any?, string?)
    table.insert(calls, {
        Kind = "Physical",
        UserId = attacker.UserId,
        Target = target,
        SkillId = skill_id,
        Rank = rank,
        SequenceId = sequence_id,
    })
    return {
        Applied = true,
        HealthDamage = 12,
    }, nil
end

--[[
Records one fake magical NPC source skill.

Args:
    attacker (any): Fixture attacker.
    target (Model): Fixture NPC.
    skill_id (string): Server-selected skill.
    rank (number): Server-resolved rank.
    sequence_id (number?): Server action sequence.

Returns:
    (any?, string?): Successful disposable source result.
]]
function FakeExecutor:magic_skill_npc(
    attacker: any,
    target: Model,
    skill_id: string,
    rank: number,
    sequence_id: number?
): (any?, string?)
    table.insert(calls, {
        Kind = "Magic",
        UserId = attacker.UserId,
        Target = target,
        SkillId = skill_id,
        Rank = rank,
        SequenceId = sequence_id,
    })
    return {
        Applied = true,
        HealthDamage = 8,
    }, nil
end

--[[
Builds one trusted DamageService-shaped player-to-NPC context.

Args:
    target (Model): Fixture NPC.
    source_kind (string): Existing server damage category.
    source_id (string): Existing server source identifier.
    sequence_id (number): Existing server action sequence.

Returns:
    any: Disposable trusted damage context.
]]
local function damage_context(
    target: Model,
    source_kind: string,
    source_id: string,
    sequence_id: number
): any
    return {
        attacker = {
            UserId = 979181,
        },
        target = target,
        source_kind = source_kind,
        source_id = source_id,
        attack_id = source_id,
        sequence_id = sequence_id,
    }
end

--[[
Runs disabled fallback, gate ordering and source action dispatch checks.

Args:
    None.

Returns:
    nil: Prints bounded dispatch acceptance evidence.
]]
local function main()
    Adapter.set_enabled(false)
    Adapter.bind_executor(nil)
    Adapter.set_npc_damage_observer(nil)
    Adapter.set_activation_audit_provider_for_test(nil)
    Adapter.set_skill_rank_provider_for_test(function(
        _user_id: number,
        skill_id: string
    ): number
        if skill_id == "IronCleave"
            or skill_id == "WindStrike"
            or skill_id == "RangerSkill"
        then
            return 1
        end
        return 0
    end)

    local target = Instance.new("Model")
    target.Name = "TEMP_C4DispatchNpc"

    local disabled = Adapter.try_damage(
        damage_context(target, "Melee", "PrototypeWeapon", 1)
    )
    check(
        disabled.Handled == false,
        "disabled adapter leaves current DamageService path unchanged"
    )

    local premature, premature_reason =
        Adapter.set_enabled(true)
    check(
        not premature
            and premature_reason == "C4CombatExecutorUnavailable",
        "dispatch cannot enable before an executor is bound"
    )

    local observer = function(
        _context: any,
        _damage: number,
        _lethal: boolean
    )
    end
    Adapter.set_npc_damage_observer(observer)
    Adapter.bind_executor(FakeExecutor)
    check(
        installed_observer == observer,
        "pending damage observer survives executor bind order"
    )

    local executor_off, executor_off_reason =
        Adapter.set_enabled(true)
    check(
        not executor_off
            and executor_off_reason == "C4LiveCombatExecutorDisabled",
        "dispatch cannot enable before live executor gate"
    )

    executor_enabled = true
    local audit_blocked, audit_blocked_reason =
        Adapter.set_enabled(true)
    check(
        not audit_blocked
            and audit_blocked_reason
                == "C4CombatDispatchAuditBlockingFamilies",
        "production dispatch cannot enable while audited blockers remain"
    )

    Adapter.set_activation_audit_provider_for_test(
        function(): boolean
            return true
        end
    )
    local enabled = Adapter.set_enabled(true)
    check(
        enabled and Adapter.is_enabled(),
        "test-ready dispatch gate enables only after audit readiness"
    )

    local normal = Adapter.try_damage(
        damage_context(target, "Melee", "PrototypeWeapon", 11)
    )
    check(
        normal.Handled
            and normal.AppliedDamage == 10
            and calls[#calls].Kind == "Normal"
            and calls[#calls].SequenceId == 11,
        "existing melee context routes to source normal attack"
    )

    local physical = Adapter.try_damage(
        damage_context(target, "Skill", "IronCleave", 12)
    )
    check(
        physical.Handled
            and physical.AppliedDamage == 12
            and calls[#calls].Kind == "Physical"
            and calls[#calls].SkillId == "IronCleave"
            and calls[#calls].Rank == 1,
        "existing physical skill context resolves rank server-side"
    )

    local magic = Adapter.try_damage(
        damage_context(target, "MagicSkill", "WindStrike", 13)
    )
    check(
        magic.Handled
            and magic.AppliedDamage == 8
            and calls[#calls].Kind == "Magic"
            and calls[#calls].SkillId == "WindStrike",
        "existing magic skill context routes to source MDAM"
    )

    local ranged_basic = Adapter.try_damage(
        damage_context(
            target,
            "RangedPhysical",
            "PrototypeLongbow",
            14
        )
    )
    check(
        ranged_basic.Handled
            and ranged_basic.AppliedDamage == 10
            and calls[#calls].Kind == "Normal",
        "unranked ranged physical context uses source normal attack"
    )

    local ranged_skill = Adapter.try_damage(
        damage_context(target, "RangedPhysical", "RangerSkill", 15)
    )
    check(
        ranged_skill.Handled
            and ranged_skill.AppliedDamage == 12
            and calls[#calls].Kind == "Physical"
            and calls[#calls].SkillId == "RangerSkill",
        "ranked ranged physical context uses source PDAM"
    )

    local ranger_area = Adapter.try_damage(
        damage_context(target, "RangerArea", "Volley", 16)
    )
    check(
        ranger_area.Handled
            and ranger_area.AppliedDamage == 0
            and ranger_area.Reason
                == "C4RangerAreaSourceMappingPending",
        "reviewed Ranger area damage fails closed while source mapping waits"
    )

    local magic_basic = Adapter.try_damage(
        damage_context(target, "MagicBasic", "SpiritOrb", 17)
    )
    check(
        magic_basic.Handled
            and magic_basic.AppliedDamage == 0
            and magic_basic.Reason
                == "C4MagicBasicSourceMappingPending",
        "reviewed magical basic damage fails closed while mapping waits"
    )

    local physical_status = Adapter.try_damage(
        damage_context(
            target,
            "StatusPhysical",
            "WayfinderWound",
            18
        )
    )
    check(
        physical_status.Handled
            and physical_status.AppliedDamage == 0
            and physical_status.Reason
                == "C4PhysicalPeriodicStatusPending",
        "reviewed physical status ticks fail closed in source mode"
    )

    local magic_status = Adapter.try_damage(
        damage_context(
            target,
            "StatusMagic",
            "MysticPoisonCurse",
            19
        )
    )
    check(
        magic_status.Handled
            and magic_status.AppliedDamage == 0
            and magic_status.Reason
                == "C4MagicPeriodicStatusPending",
        "reviewed magical status ticks fail closed in source mode"
    )

    local unaudited = Adapter.try_damage(
        damage_context(target, "UnknownFamily", "Unknown", 20)
    )
    check(
        unaudited.Handled
            and unaudited.AppliedDamage == 0
            and unaudited.Reason
                == "C4SourceDamageFamilyUnaudited",
        "unreviewed player damage can never fall back while source is enabled"
    )

    local capability = Adapter.capability()
    check(
        capability.DefaultEnabled == false
            and capability.ExecutorBound
            and capability.DisabledFallsBackToCurrentCombat
            and capability.EnabledSourceFailureFallsClosed
            and not capability.ActivationAuditReady
            and #capability.ActivationBlockers == 4
            and capability.RangerAreaActivationBlocked
            and capability.MagicBasicActivationBlocked
            and capability.PeriodicStatusActivationBlocked
            and not capability.ClientDamageAuthority,
        "dispatch capability exposes the remaining activation blockers"
    )

    Adapter.set_enabled(false)
    Adapter.bind_executor(nil)
    Adapter.set_npc_damage_observer(nil)
    Adapter.set_skill_rank_provider_for_test(nil)
    Adapter.set_activation_audit_provider_for_test(nil)
    executor_enabled = false
    table.clear(calls)
    target:Destroy()

    print((
        "[C4 Combat Dispatch] DISPATCH_PASS: %d assertions "
            .. "default_off=true fail_closed=true"
    ):format(checks))
end

main()
