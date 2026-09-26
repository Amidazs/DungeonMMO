--!strict
-- Cross-service Human Wizard staged cast integration.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared
local ProfileSchema = require(Shared.ProfileSchema)
local QuestStages = require(Shared.C4OriginalFirstTransferQuestStages)

local Services = ServerScriptService.Core.Services
local CastContract = require(
    Services.C4SourceCastContractService
)
local CastResources = require(
    Services.C4SourceCastResourceService
)
local CastTiming = require(
    Services.C4SourceCastTimingService
)
local CastScheduler = require(
    Services.C4SourceCastSchedulerService
)
local DirectMagic = require(
    Services.C4SourceDirectMagicCastService
)
local PeriodicMagic = require(
    Services.C4SourcePeriodicMagicCastService
)
local Runtime = require(
    Services.ProgressionRuntimeState
)

local USER_ID = 938197
local player = {
    UserId = USER_ID,
}
local enemy = {
    Name = "TEMP_StagedWizardEnemy",
}
local checks = 0
local mana_current = 200
local source_active = true
local last_preflight_range = nil
local magic_calls = 0
local area_magic_calls = 0
local drain_magic_calls = 0
local sleep_calls = 0
local last_area_radius = nil
local status_calls = 0

local FakeResources = {}

--[[
Reports disposable source-resource participation.

Args:
    subject (any): Candidate cast owner.

Returns:
    boolean: True only for the staged integration owner while enabled.
]]
function FakeResources.is_active(subject: any): boolean
    return subject == player and source_active
end

local FakeMana = {}

--[[
Applies total-affordability plus source initial MP spend.

Args:
    subject (any): Expected staged cast owner.
    initial_amount (number): Exact source initial MP.
    completion_amount (number): Exact source launch MP.

Returns:
    boolean: True when total MP is affordable and initial MP is spent.
]]
function FakeMana.try_begin_split_spend(
    subject: any,
    initial_amount: number,
    completion_amount: number
): boolean
    if subject ~= player
        or mana_current < initial_amount + completion_amount
    then
        return false
    end

    mana_current -= initial_amount
    return true
end

--[[
Applies one source launch-time MP spend.

Args:
    subject (any): Expected staged cast owner.
    completion_amount (number): Exact source launch MP.

Returns:
    number: Actual MP removed.
]]
function FakeMana.finish_split_spend(
    subject: any,
    completion_amount: number
): number
    if subject ~= player then
        return 0
    end

    local before = mana_current
    mana_current = math.max(0, before - completion_amount)
    return before - mana_current
end

local FakeShots = {}

--[[
Returns neutral read-only magical shot state.

Args:
    user_id (number): Expected source-ready owner.

Returns:
    any: Uncharged source shot snapshot.
]]
function FakeShots:snapshot(user_id: number): any
    assert(user_id == USER_ID)
    return {
        Spiritshot = false,
        BlessedSpiritshot = false,
    }
end

--[[
Returns the staged authenticated source stat boundary.

Args:
    user_id (number): Expected source-ready owner.

Returns:
    (any?, string?): Exact timing stats required by the source planner.
]]
local function boundary_provider(
    user_id: number
): (any?, string?)
    if user_id ~= USER_ID then
        return nil, "OriginalCharacterIdentityNotVerified"
    end

    return {
        ScopeId = "HumanWizard",
        SourceStatCandidateReady = true,
        SourceStatCandidate = {
            MAGICAL_ATTACK_SPEED = 333,
            MAGICAL_SKILL_REUSE = 0.75,
            SKILL_MASTERY = 0,
        },
    }, nil
end

local FakeExecutor = {}

--[[
Preflights one staged direct-magic target and records source range.

Args:
    subject (any): Expected cast owner.
    target (any): Expected private NPC target.
    source_range (number?): Reviewed source cast/effect range.

Returns:
    (boolean, string?): Target readiness.
]]
function FakeExecutor:can_magic_skill_npc(
    subject: any,
    target: any,
    source_range: number?
): (boolean, string?)
    if subject ~= player or target ~= enemy then
        return false, "InvalidC4LiveNpcTarget"
    end

    last_preflight_range = source_range
    return true, nil
end

--[[
Preflights one staged periodic-magic target and records source range.

Args:
    subject (any): Expected cast owner.
    target (any): Expected private NPC target.
    source_range (number?): Reviewed source cast/effect range.

Returns:
    (boolean, string?): Target readiness.
]]
function FakeExecutor:can_status_skill_npc(
    subject: any,
    target: any,
    source_range: number?
): (boolean, string?)
    return self:can_magic_skill_npc(
        subject,
        target,
        source_range
    )
end

--[[
Records one staged direct-MDAM executor handoff.

Args:
    subject (any): Expected cast owner.
    target (any): Expected private NPC target.
    creative_skill_id (string): Reviewed direct spell.
    creative_rank (number): Authenticated creative rank.
    sequence_id (number?): Trusted action sequence.

Returns:
    (any?, string?): Fake live executor evidence.
]]
function FakeExecutor:magic_skill_npc(
    subject: any,
    target: any,
    creative_skill_id: string,
    creative_rank: number,
    sequence_id: number?
): (any?, string?)
    assert(subject == player and target == enemy)
    assert(type(sequence_id) == "number")
    magic_calls += 1

    return {
        Kind = "C4LiveNpcMagicSkill",
        Applied = true,
        CreativeSkillId = creative_skill_id,
        CreativeRank = creative_rank,
    }, nil
end

--[[
Records one staged periodic-status executor handoff.

Args:
    subject (any): Expected cast owner.
    target (any): Expected private NPC target.
    creative_skill_id (string): Reviewed Venom Hex skill.
    creative_rank (number): Authenticated creative rank.
    sequence_id (number?): Trusted action sequence.

Returns:
    (any?, string?): Fake landed periodic-status evidence.
]]
function FakeExecutor:status_skill_npc(
    subject: any,
    target: any,
    creative_skill_id: string,
    creative_rank: number,
    sequence_id: number?
): (any?, string?)
    assert(subject == player and target == enemy)
    assert(creative_skill_id == "EmberweaverVenomHex")
    assert(creative_rank == 2)
    assert(type(sequence_id) == "number")
    status_calls += 1

    return {
        Kind = "C4LiveNpcPeriodicStatus",
        Applied = true,
        StatusApplied = true,
        Landed = true,
    }, nil
end

--[[
Provides a disposable combined direct-magic/slow executor path.

Args:
    _attacker (any): Disposable cast owner.
    _enemy (any): Disposable target.
    _skill_id (string): Creative skill identifier.
    _rank (number): Creative skill rank.
    _sequence_id (number?): Disposable sequence.

Returns:
    (any?, string?): Successful fake combined application.
]]
function FakeExecutor:magic_slow_skill_npc(
    _attacker: any,
    _enemy: any,
    _skill_id: string,
    _rank: number,
    _sequence_id: number?
): (any?, string?)
    return {
        Applied = true,
        SlowLanded = true,
        SlowApplied = true,
    }, nil
end

--[[
Records one staged TARGET_AREA magic executor handoff.

Args:
    subject (any): Expected cast owner.
    target (any): Expected private selected NPC target.
    creative_skill_id (string): Reviewed Ember Field skill.
    creative_rank (number): Authenticated creative rank.
    source_radius (number): Exact source skill radius.
    sequence_id (number?): Trusted action sequence.

Returns:
    (any?, string?): Fake live area executor evidence.
]]
function FakeExecutor:magic_area_skill_npc(
    subject: any,
    target: any,
    creative_skill_id: string,
    creative_rank: number,
    source_radius: number,
    sequence_id: number?
): (any?, string?)
    assert(subject == player and target == enemy)
    assert(creative_skill_id == "EmberweaverEmberField")
    assert(creative_rank == 3)
    assert(type(sequence_id) == "number")
    area_magic_calls += 1
    last_area_radius = source_radius

    return {
        Kind = "C4LiveNpcMagicArea",
        Applied = true,
        TargetCount = 2,
        SourceSkillRadius = source_radius,
    }, nil
end

--[[
Records one staged source magic-drain executor handoff.

Args:
    subject (any): Expected cast owner.
    target (any): Expected private selected NPC target.
    creative_skill_id (string): Reviewed Life Siphon skill.
    creative_rank (number): Authenticated creative rank.
    sequence_id (number?): Trusted action sequence.

Returns:
    (any?, string?): Fake live drain executor evidence.
]]
function FakeExecutor:magic_drain_skill_npc(
    subject: any,
    target: any,
    creative_skill_id: string,
    creative_rank: number,
    sequence_id: number?
): (any?, string?)
    assert(subject == player and target == enemy)
    assert(creative_skill_id == "EmberweaverLifeSiphon")
    assert(creative_rank == 4)
    assert(type(sequence_id) == "number")
    drain_magic_calls += 1

    return {
        Kind = "C4LiveNpcMagicDrain",
        Applied = true,
        HealthDamage = 40,
        EffectiveHeal = 16,
        AbsorbPart = 0.4,
        AbsorbAbs = 0,
    }, nil
end

--[[
Provides a minimal source Sleep executor contract.

Args:
    _attacker (any): Disposable cast owner.
    _enemy (any): Disposable target.
    _skill_id (string): Creative skill identifier.
    _rank (number): Creative skill rank.
    _sequence_id (number?): Disposable sequence.

Returns:
    (any?, string?): Successful fake Sleep application.
]]
function FakeExecutor:sleep_skill_npc(
    subject: any,
    target: any,
    creative_skill_id: string,
    creative_rank: number,
    sequence_id: number?
): (any?, string?)
    assert(subject == player and target == enemy)
    assert(creative_skill_id == "EmberweaverSlumberHex")
    assert(creative_rank == 6)
    assert(type(sequence_id) == "number")
    sleep_calls += 1

    return {
        Kind = "C4LiveNpcSleep",
        Applied = true,
        SleepApplied = true,
        Landed = true,
        DurationSeconds = 30,
        BreaksOnDamage = true,
    }, nil
end

--[[
Counts one cross-service staged-cast assertion.

Args:
    condition (boolean): Observed integration state.
    label (string): Failure description.

Returns:
    nil: Raises on failure and increments the assertion count.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Wizard Staged Integration] " .. label)
end

--[[
Adds one known purchased skill to a profile-shaped character.

Args:
    character (any): Mutable disposable character profile.
    skill_id (string): Creative skill identifier.
    rank (number): Purchased creative rank.

Returns:
    nil: Adds one server-owned progression skill record.
]]
local function own_skill(
    character: any,
    skill_id: string,
    rank: number
)
    character.Progression.Skills[skill_id] = {
        Known = true,
        StarterGranted = false,
        PurchasedRank = rank,
        Proficiency = 0,
    }
end

--[[
Builds the authentic level-30 Emberweaver identity used by this integration.

Args:
    None.

Returns:
    any: Profile-shaped first-transfer character owning staged cast families.
]]
local function wizard_character(): any
    local character =
        ProfileSchema.create_default(USER_ID).Characters.Slot1
    local quest = assert(QuestStages.get("HumanWizard"))
    local proofs = {}

    for _, proof_id in ipairs(quest.RequiredProofIds) do
        proofs[proof_id] = true
    end

    character.Level = 30
    character.Identity = {
        Version = 1,
        RaceId = "Human",
        BaseClassId = "Mage",
        ClassId = "Emberweaver",
        CreationStage = "Complete",
    }
    character.ClassAdvancement = {
        Version = 1,
        OriginalFirstTransferChoiceId = "HumanWizard",
        OriginalFirstTransferClassId = "Emberweaver",
        OriginalFirstTransferReceiptId =
            "TEMP_StagedWizardIntegration",
        OriginalFirstTransferQuest = {
            QuestId = quest.Id,
            BranchId = quest.BranchId,
            Step = #quest.Steps + 1,
            Count = 0,
            Ready = true,
            AppliedEvents = {},
            Proofs = proofs,
        },
    }

    own_skill(character, "EmberweaverEmberBolt", 6)
    own_skill(character, "EmberweaverFlameBurst", 6)
    own_skill(character, "EmberweaverFocusedBolt", 3)
    own_skill(character, "EmberweaverEmberField", 3)
    own_skill(character, "EmberweaverLifeSiphon", 4)
    own_skill(character, "EmberweaverSlumberHex", 6)
    own_skill(character, "EmberweaverVenomHex", 2)

    return character
end

--[[
Builds the real staged cast services around disposable authorities.

Args:
    None.

Returns:
    (any, any): Enabled direct and periodic bridges sharing one real scheduler.
]]
local function staged_services(): (any, any)
    local resources = CastResources.new({
        CastContract = CastContract,
        Resources = FakeResources,
        Mana = FakeMana,
    })
    local timing = CastTiming.new(FakeShots, {
        CastContract = CastContract,
        BoundaryProvider = boundary_provider,
    })
    local scheduler = CastScheduler.new(resources, timing)
    local direct = DirectMagic.new(scheduler, FakeExecutor)
    local periodic = PeriodicMagic.new(
        scheduler,
        FakeExecutor
    )

    direct:set_enabled(true)
    periodic:set_enabled(true)
    return direct, periodic
end

--[[
Checks Ember Bolt across real contract/timing/resource/scheduler services.

Args:
    direct (any): Enabled direct-MDAM bridge.

Returns:
    nil: Confirms exact MP, timing, range, reuse and executor handoff.
]]
local function check_ember_bolt(direct: any)
    local started = assert(direct:begin_cast(
        player,
        enemy,
        "EmberweaverEmberBolt",
        100
    ))
    check(
        started.SourceSkillId == 1220
            and started.SourceRank == 6
            and started.LaunchAt == 104
            and started.ReuseReadyAt == 104.5
            and started.SourceCastRange == 750
            and started.SourceEffectRange == 1250
            and last_preflight_range == 750
            and mana_current == 194,
        "Ember Bolt crosses exact source start contract"
    )

    local launched = assert(direct:launch_if_ready(
        player,
        started.CastId,
        104,
        1001
    ))
    check(
        launched.Applied
            and last_preflight_range == 1250
            and mana_current == 173
            and magic_calls == 1,
        "Ember Bolt commits launch MP then reaches executor once"
    )
end

--[[
Checks the two additional pure direct-MDAM families through real services.

Args:
    direct (any): Enabled direct-MDAM bridge.

Returns:
    nil: Confirms exact source ranks, timings, ranges and split-MP costs.
]]
local function check_other_direct_spells(direct: any)
    local cases = {
        {
            SkillId = "EmberweaverFlameBurst",
            StartAt = 110,
            LaunchAt = 111.5,
            ReuseAt = 111.875,
            SourceSkillId = 1172,
            SourceRank = 6,
            CastRange = 150,
            EffectRange = 650,
            StartMana = 167,
            EndMana = 146,
        },
        {
            SkillId = "EmberweaverFocusedBolt",
            StartAt = 120,
            LaunchAt = 122,
            ReuseAt = 122.25,
            SourceSkillId = 1274,
            SourceRank = 3,
            CastRange = 400,
            EffectRange = 900,
            StartMana = 143,
            EndMana = 132,
        },
    }

    for index, case in ipairs(cases) do
        local started = assert(direct:begin_cast(
            player,
            enemy,
            case.SkillId,
            case.StartAt
        ))
        check(
            started.SourceSkillId == case.SourceSkillId
                and started.SourceRank == case.SourceRank
                and started.LaunchAt == case.LaunchAt
                and started.ReuseReadyAt == case.ReuseAt
                and started.SourceCastRange == case.CastRange
                and started.SourceEffectRange == case.EffectRange
                and mana_current == case.StartMana,
            case.SkillId .. " starts with exact source plan"
        )

        assert(direct:launch_if_ready(
            player,
            started.CastId,
            case.LaunchAt,
            1010 + index
        ))
        check(
            last_preflight_range == case.EffectRange
                and mana_current == case.EndMana,
            case.SkillId .. " commits exact launch MP and effect range"
        )
    end
end

--[[
Checks Ember Field through the real source scheduler and TARGET_AREA path.

Args:
    direct (any): Enabled targeted-magic bridge.

Returns:
    nil: Confirms exact source rank, radius, timing, ranges and MP costs.
]]
local function check_ember_field(direct: any)
    local started = assert(direct:begin_cast(
        player,
        enemy,
        "EmberweaverEmberField",
        125
    ))
    check(
        started.SourceSkillId == 1181
            and started.SourceRank == 3
            and started.LaunchAt == 129
            and started.ReuseReadyAt == 136.25
            and started.SourceCastRange == 500
            and started.SourceEffectRange == 1000
            and last_preflight_range == 500
            and mana_current == 124,
        "Ember Field crosses exact source TARGET_AREA start contract"
    )

    local launched = assert(direct:launch_if_ready(
        player,
        started.CastId,
        129,
        1013
    ))
    check(
        launched.Applied
            and launched.Application.TargetCount == 2
            and last_preflight_range == 1000
            and last_area_radius == 200
            and area_magic_calls == 1
            and mana_current == 92,
        "Ember Field commits exact launch MP and source radius"
    )
end

--[[
Checks Life Siphon through the real source scheduler and drain path.

Args:
    direct (any): Enabled targeted-magic bridge.

Returns:
    nil: Confirms exact source rank, timing, ranges and split-MP costs.
]]
local function check_life_siphon(direct: any)
    local started = assert(direct:begin_cast(
        player,
        enemy,
        "EmberweaverLifeSiphon",
        140
    ))
    check(
        started.SourceSkillId == 1147
            and started.SourceRank == 6
            and started.LaunchAt == 144
            and started.ReuseReadyAt == 149
            and started.SourceCastRange == 600
            and started.SourceEffectRange == 1100
            and last_preflight_range == 600
            and mana_current == 85,
        "Life Siphon crosses exact source drain start contract"
    )

    local launched = assert(direct:launch_if_ready(
        player,
        started.CastId,
        144,
        1014
    ))
    check(
        launched.Applied
            and launched.Application.Kind == "C4LiveNpcMagicDrain"
            and launched.Application.AbsorbPart == 0.4
            and launched.Application.AbsorbAbs == 0
            and launched.Application.EffectiveHeal == 16
            and last_preflight_range == 1100
            and drain_magic_calls == 1
            and mana_current == 58,
        "Life Siphon commits exact MP and reaches source drain executor"
    )
end

--[[
Checks Slumber Hex through the real source scheduler and Sleep path.

Args:
    direct (any): Enabled targeted-magic bridge.

Returns:
    nil: Confirms exact source rank, timing, ranges and split-MP costs.
]]
local function check_slumber_hex(direct: any)
    local started = assert(direct:begin_cast(
        player,
        enemy,
        "EmberweaverSlumberHex",
        146
    ))
    check(
        started.SourceSkillId == 1069
            and started.SourceRank == 6
            and started.LaunchAt == 148.5
            and started.ReuseReadyAt == 150.5
            and started.SourceCastRange == 600
            and started.SourceEffectRange == 1100
            and last_preflight_range == 600
            and mana_current == 52,
        "Slumber Hex crosses exact source Sleep start contract"
    )

    local launched = assert(direct:launch_if_ready(
        player,
        started.CastId,
        148.5,
        1015
    ))
    check(
        launched.Applied
            and launched.Application.Kind == "C4LiveNpcSleep"
            and launched.Application.SleepApplied
            and launched.Application.DurationSeconds == 30
            and launched.Application.BreaksOnDamage
            and last_preflight_range == 1100
            and sleep_calls == 1
            and mana_current == 31,
        "Slumber Hex commits exact MP and reaches source Sleep executor"
    )
end

--[[
Checks Venom Hex through the same real source scheduler/resource pipeline.

Args:
    periodic (any): Enabled periodic-magic bridge.

Returns:
    nil: Confirms source Poison rank, timings, ranges and split-MP costs.
]]
local function check_venom_hex(periodic: any)
    local started = assert(periodic:begin_cast(
        player,
        enemy,
        "EmberweaverVenomHex",
        150
    ))
    check(
        started.SourceSkillId == 1168
            and started.SourceRank == 3
            and started.LaunchAt == 154
            and started.ReuseReadyAt == 159
            and started.SourceCastRange == 600
            and started.SourceEffectRange == 1100
            and last_preflight_range == 600
            and mana_current == 52,
        "Venom Hex crosses exact source start contract"
    )

    local resolved = assert(periodic:launch_if_ready(
        player,
        started.CastId,
        154,
        1020
    ))
    check(
        resolved.StatusResolved
            and resolved.Landed
            and last_preflight_range == 1100
            and mana_current == 31
            and status_calls == 1,
        "Venom Hex commits launch MP then reaches poison executor once"
    )
end

--[[
Checks the shared real scheduler prevents overlapping bridge families.

Args:
    direct (any): Enabled direct-MDAM bridge.
    periodic (any): Enabled periodic-magic bridge.

Returns:
    nil: Confirms one owner cannot overlap direct and periodic source casts.
]]
local function check_cross_family_overlap(
    direct: any,
    periodic: any
)
    local started = assert(direct:begin_cast(
        player,
        enemy,
        "EmberweaverEmberBolt",
        160
    ))

    local blocked, reason = periodic:begin_cast(
        player,
        enemy,
        "EmberweaverVenomHex",
        160.1
    )
    check(
        blocked == nil
            and reason == "C4SourceCastAlreadyScheduled"
            and mana_current == 25,
        "shared scheduler blocks cross-family overlap before second MP spend"
    )

    assert(direct:cancel_cast(player, started.CastId))
end

--[[
Runs the staged Human Wizard cross-service integration acceptance.

Args:
    None.

Returns:
    nil: Prints pending-Studio evidence after all cross-service assertions.
]]
local function main()
    Runtime.set_character(USER_ID, wizard_character())
    mana_current = 200
    source_active = true
    last_preflight_range = nil
    magic_calls = 0
    area_magic_calls = 0
    drain_magic_calls = 0
    sleep_calls = 0
    last_area_radius = nil
    status_calls = 0

    local direct, periodic = staged_services()

    check_ember_bolt(direct)
    check_other_direct_spells(direct)
    check_ember_field(direct)
    check_life_siphon(direct)
    check_slumber_hex(direct)
    mana_current = 58
    check_venom_hex(periodic)
    check_cross_family_overlap(direct, periodic)

    Runtime.clear_character(USER_ID)

    print((
        "[C4 Wizard Staged Integration] TEST_PASS_PENDING_STUDIO: "
        .. "%d assertions direct=3 area=1 drain=1 sleep=1 poison=1 ".. "shared_scheduler=true"
    ):format(checks))
end

main()
