--!strict
-- Exact C4 Combat Point source rules and isolated server runtime regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared

local SourceRules = require(Shared.C4CombatPointSourceRules)
local CombatPoints = require(
    ServerScriptService.Core.Services.C4CombatPointRuntime
)

local SOURCE_COMMIT =
    "07f8536384e799f128d44198dd7ab23519660eea"
local checks = 0

--[[
Counts one Combat Point source/runtime assertion.

Args:
    valid (boolean): Expected exact source or server-runtime condition.
    label (string): Diagnostic description for a failed assertion.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Combat Points] " .. label)
end

--[[
Compares two finite source values with a small arithmetic tolerance.

Args:
    actual (number): Calculated C4 source value.
    expected (number): Independently derived expected value.

Returns:
    boolean: True when floating-point representation is equivalent.
]]
local function nearly_equal(
    actual: number,
    expected: number
): boolean
    return math.abs(actual - expected) < 0.000001
end

--[[
Builds a disposable server-owned CP resource owner.

Args:
    user_id (number): Stable test owner identifier.

Returns:
    any: Table-shaped owner with replaceable Character identity.
]]
local function owner_fixture(user_id: number): any
    return {
        UserId = user_id,
        Character = {
            Parent = true,
        },
    }
end

--[[
Builds the minimum certified source boundary accepted by the CP runtime.

Args:
    max_cp (number): Source-stat candidate maximum CP.

Returns:
    any: Detached migration-boundary-shaped source record.
]]
local function certified_boundary(max_cp: number): any
    return {
        SourceCommit = SOURCE_COMMIT,
        ExactBaseVitalsCertified = true,
        SourceStatCandidateReady = true,
        SourceStatCandidate = {
            MAX_CP = max_cp,
        },
        CutoverPrerequisitesReady = true,
    }
end

--[[
Checks exact pinned C4 CP regeneration arithmetic and movement modifiers.

Args:
    None.

Returns:
    nil: Confirms the three-second source tick and all movement bands.
]]
local function check_source_regeneration()
    local walking = assert(SourceRules.regen_per_tick(
        "Human",
        "Fighter",
        30,
        "Walking"
    ))
    local expected = (1.5 + 2) * 1.19 * 1.58

    check(
        nearly_equal(walking, expected),
        "Human Fighter level-30 walking CP tick matches source formula"
    )

    local sitting = assert(SourceRules.regen_per_tick(
        "Human",
        "Fighter",
        30,
        "Sitting"
    ))
    local standing = assert(SourceRules.regen_per_tick(
        "Human",
        "Fighter",
        30,
        "Standing"
    ))
    local running = assert(SourceRules.regen_per_tick(
        "Human",
        "Fighter",
        30,
        "Running"
    ))

    check(
        nearly_equal(sitting, walking * 1.5)
            and nearly_equal(standing, walking * 1.1)
            and nearly_equal(running, walking * 0.7),
        "C4 sitting/standing/running CP multipliers are exact"
    )

    local level_ten = assert(SourceRules.regen_per_tick(
        "Human",
        "Fighter",
        10,
        "Walking"
    ))
    check(
        nearly_equal(level_ten, (1.5 + 0.5) * 0.99 * 1.58),
        "levels one through ten use the source half-point regen add"
    )

    local _, invalid_reason = SourceRules.regen_per_tick(
        "Human",
        "Fighter",
        30,
        "Flying"
    )
    check(
        invalid_reason == "InvalidOriginalCPMovementState",
        "unknown movement state fails closed"
    )

    local metadata = SourceRules.metadata()
    check(
        metadata.RegenPeriodSeconds == 3
            and metadata.CpRegenMultiplier == 1
            and metadata.PlayableAttackerOnly
            and metadata.NpcDamageBypassesCP
            and metadata.SourceCommit == SOURCE_COMMIT,
        "source timing, default rate and provenance are pinned"
    )
end

--[[
Checks exact C4 playable-attacker CP absorption semantics.

Args:
    None.

Returns:
    nil: Confirms CP-first PvP damage and NPC bypass.
]]
local function check_source_damage()
    local covered = assert(SourceRules.resolve_damage(
        50,
        30,
        true
    ))
    check(
        covered.CurrentCP == 20
            and covered.CPAbsorbed == 30
            and covered.HealthDamage == 0,
        "playable damage consumes CP before HP"
    )

    local overflow = assert(SourceRules.resolve_damage(
        20,
        50,
        true
    ))
    check(
        overflow.CurrentCP == 0
            and overflow.CPAbsorbed == 20
            and overflow.HealthDamage == 30,
        "playable damage overflow reaches HP after CP is exhausted"
    )

    local npc = assert(SourceRules.resolve_damage(
        50,
        30,
        false
    ))
    check(
        npc.CurrentCP == 50
            and npc.CPAbsorbed == 0
            and npc.HealthDamage == 30,
        "non-playable damage bypasses CP exactly like C4 PcStatus"
    )
end

--[[
Checks the isolated server CP lifecycle without enabling production combat.

Args:
    None.

Returns:
    nil: Confirms certified configuration, damage, restore and invalidation.
]]
local function check_runtime_lifecycle()
    local owner = owner_fixture(991001)

    local unconfigured = assert(CombatPoints.resolve_damage(
        owner,
        25,
        true
    ))
    check(
        not unconfigured.Configured
            and unconfigured.HealthDamage == 25
            and unconfigured.CPAbsorbed == 0,
        "installing the runtime alone cannot alter existing damage"
    )

    local bad_ok, bad_reason = CombatPoints.configure_from_boundary(
        owner,
        {
            SourceCommit = SOURCE_COMMIT,
            SourceStatCandidate = {MAX_CP = 418},
        },
        true
    )
    check(
        not bad_ok
            and bad_reason == "UncertifiedCombatPointSourceBoundary",
        "arbitrary incomplete max-CP input cannot configure the runtime"
    )

    local configured, configure_reason =
        CombatPoints.configure_from_boundary(
            owner,
            certified_boundary(418),
            true
        )
    check(
        configured and configure_reason == nil,
        "certified source boundary configures current/max CP"
    )

    local initial = CombatPoints.snapshot(owner)
    check(
        initial.Configured
            and initial.CurrentCP == 418
            and initial.MaxCP == 418
            and initial.CharacterBound
            and initial.Authoritative
            and initial.PvPOnly,
        "configured CP starts full and remains server-owned"
    )

    local playable = assert(CombatPoints.resolve_damage(
        owner,
        100,
        true
    ))
    check(
        playable.CurrentCP == 318
            and playable.CPAbsorbed == 100
            and playable.HealthDamage == 0,
        "configured playable damage mutates authoritative current CP"
    )

    local npc = assert(CombatPoints.resolve_damage(
        owner,
        50,
        false
    ))
    check(
        npc.CurrentCP == 318
            and npc.CPAbsorbed == 0
            and npc.HealthDamage == 50,
        "configured CP still does not absorb NPC dungeon damage"
    )

    local restored = assert(CombatPoints.restore(owner, 500))
    check(
        restored == 418
            and CombatPoints.snapshot(owner).CurrentCP == 418,
        "CP regeneration clamps at certified source maximum"
    )

    assert(CombatPoints.resolve_damage(owner, 200, true))
    local preserved = assert(CombatPoints.configure_from_boundary(
        owner,
        certified_boundary(300),
        false
    ))
    check(
        preserved
            and CombatPoints.snapshot(owner).CurrentCP == 218
            and CombatPoints.snapshot(owner).MaxCP == 300,
        "non-refill reconfiguration preserves and clamps current CP"
    )

    owner.Character = {
        Parent = true,
    }
    local replaced = CombatPoints.snapshot(owner)
    check(
        not replaced.Configured
            and replaced.CurrentCP == 0
            and replaced.MaxCP == 0,
        "character replacement invalidates stale CP state"
    )

    CombatPoints.clear(owner)
end

--[[
Checks the runtime capability advertised to the migration boundary.

Args:
    None.

Returns:
    nil: Confirms authority while live configuration remains disabled.
]]
local function check_capability()
    local capability = CombatPoints.capability()

    check(
        capability.Authoritative
            and capability.RuntimeAvailable
            and capability.CharacterBound
            and capability.SourceMaxCPConfigurable
            and capability.PlayableAttackerOnly
            and capability.NpcDamageBypassesCP
            and capability.RegenPeriodSeconds == 3
            and capability.LifecycleClearSupported
            and capability.LiveConfiguredByDefault == false
            and capability.SourceCommit == SOURCE_COMMIT,
        "CP runtime capability satisfies the fail-closed migration contract"
    )
end

--[[
Runs C4 Combat Point source and isolated-runtime acceptance.

Args:
    None.

Returns:
    nil: Prints a bounded non-live success marker.
]]
local function main()
    check_source_regeneration()
    check_source_damage()
    check_runtime_lifecycle()
    check_capability()

    print((
        "[C4 Combat Points] SOURCE_ONLY_PASS: %d assertions "
        .. "pvp_cp=true npc_bypass=true live_cutover=false"
    ):format(checks))
end

main()
