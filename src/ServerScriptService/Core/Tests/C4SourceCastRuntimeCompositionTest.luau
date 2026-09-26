--!strict
-- Dungeon source-cast runtime composition regression.

local ServerScriptService = game:GetService("ServerScriptService")

local Composition = require(
    ServerScriptService.Core.Services.C4SourceCastRuntimeComposition
)

local checks = 0
local removed_user_id = nil

local FakeShots = {}

--[[
Returns neutral source shot state for composition compatibility.

Args:
    _user_id (number): Disposable owner identifier.

Returns:
    any: Neutral source shot snapshot.
]]
function FakeShots:snapshot(_user_id: number): any
    return {
        Spiritshot = false,
        BlessedSpiritshot = false,
    }
end

--[[
Records source-shot teardown for one departing owner.

Args:
    user_id (number): Disposable owner identifier.

Returns:
    nil: Stores only the test teardown observation.
]]
function FakeShots:remove_player(user_id: number)
    removed_user_id = user_id
end

local FakeExecutor = {}

--[[
Reports one disposable direct-magic target as ready.

Args:
    _attacker (any): Disposable cast owner.
    _enemy (any): Disposable target.
    _source_range (number?): Reviewed source range.

Returns:
    (boolean, string?): Always-ready test result.
]]
function FakeExecutor:can_magic_skill_npc(
    _attacker: any,
    _enemy: any,
    _source_range: number?
): (boolean, string?)
    return true, nil
end

--[[
Reports one disposable status target as ready.

Args:
    _attacker (any): Disposable cast owner.
    _enemy (any): Disposable target.
    _source_range (number?): Reviewed source range.

Returns:
    (boolean, string?): Always-ready test result.
]]
function FakeExecutor:can_status_skill_npc(
    _attacker: any,
    _enemy: any,
    _source_range: number?
): (boolean, string?)
    return true, nil
end

--[[
Provides a minimal direct-magic executor contract.

Args:
    _attacker (any): Disposable cast owner.
    _enemy (any): Disposable target.
    _skill_id (string): Creative skill identifier.
    _rank (number): Creative skill rank.
    _sequence_id (number?): Disposable sequence.

Returns:
    (any?, string?): Successful test result.
]]
function FakeExecutor:magic_skill_npc(
    _attacker: any,
    _enemy: any,
    _skill_id: string,
    _rank: number,
    _sequence_id: number?
): (any?, string?)
    return {Applied = true}, nil
end

--[[
Provides a minimal combined magic/slow executor contract.

Args:
    _attacker (any): Disposable cast owner.
    _enemy (any): Disposable target.
    _skill_id (string): Creative skill identifier.
    _rank (number): Creative skill rank.
    _sequence_id (number?): Disposable sequence.

Returns:
    (any?, string?): Successful test result.
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
Provides a minimal TARGET_AREA magic executor contract.

Args:
    _attacker (any): Disposable cast owner.
    _enemy (any): Disposable selected target.
    _skill_id (string): Creative skill identifier.
    _rank (number): Creative skill rank.
    source_radius (number): Reviewed source area radius.
    _sequence_id (number?): Disposable sequence.

Returns:
    (any?, string?): Successful fake area application.
]]
function FakeExecutor:magic_area_skill_npc(
    _attacker: any,
    _enemy: any,
    _skill_id: string,
    _rank: number,
    source_radius: number,
    _sequence_id: number?
): (any?, string?)
    return {
        Applied = true,
        TargetCount = 1,
        SourceSkillRadius = source_radius,
    }, nil
end

--[[
Provides a minimal source magic-drain executor contract.

Args:
    _attacker (any): Disposable cast owner.
    _enemy (any): Disposable selected target.
    _skill_id (string): Creative skill identifier.
    _rank (number): Creative skill rank.
    _sequence_id (number?): Disposable sequence.

Returns:
    (any?, string?): Successful fake drain application.
]]
function FakeExecutor:magic_drain_skill_npc(
    _attacker: any,
    _enemy: any,
    _skill_id: string,
    _rank: number,
    _sequence_id: number?
): (any?, string?)
    return {
        Applied = true,
        HealthDamage = 10,
        EffectiveHeal = 4,
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
    _attacker: any,
    _enemy: any,
    _skill_id: string,
    _rank: number,
    _sequence_id: number?
): (any?, string?)
    return {
        Applied = true,
        SleepApplied = true,
        Landed = true,
        DurationSeconds = 30,
        BreaksOnDamage = true,
    }, nil
end

--[[
Provides a minimal source elemental-vulnerability executor contract.

Args:
    _attacker (any): Disposable cast owner.
    _enemy (any): Disposable target.
    _skill_id (string): Creative skill identifier.
    _rank (number): Creative skill rank.
    _sequence_id (number?): Disposable sequence.

Returns:
    (any?, string?): Successful fake vulnerability application.
]]
function FakeExecutor:elemental_vulnerability_skill_npc(
    _attacker: any,
    _enemy: any,
    _skill_id: string,
    _rank: number,
    _sequence_id: number?
): (any?, string?)
    return {
        Applied = true,
        VulnerabilityApplied = true,
        Landed = true,
        VulnerabilityStat = "FIRE_VULN",
        VulnerabilityMultiplier = 1.25,
        DurationSeconds = 15,
    }, nil
end

--[[
Provides a minimal source physical-attack weakening executor contract.

Args:
    _attacker (any): Disposable cast owner.
    _enemy (any): Disposable target.
    _skill_id (string): Creative skill identifier.
    _rank (number): Creative skill rank.
    _sequence_id (number?): Disposable sequence.

Returns:
    (any?, string?): Successful fake weakening application.
]]
function FakeExecutor:physical_attack_weakening_skill_npc(
    _attacker: any,
    _enemy: any,
    _skill_id: string,
    _rank: number,
    _sequence_id: number?
): (any?, string?)
    return {
        Applied = true,
        WeakeningApplied = true,
        Landed = true,
        PhysicalAttackMultiplier = 0.8,
        PowerReductionFraction = 0.2,
        DurationSeconds = 15,
    }, nil
end

--[[
Provides a minimal periodic-status executor contract.

Args:
    _attacker (any): Disposable cast owner.
    _enemy (any): Disposable target.
    _skill_id (string): Creative skill identifier.
    _rank (number): Creative skill rank.
    _sequence_id (number?): Disposable sequence.

Returns:
    (any?, string?): Successful test result.
]]
function FakeExecutor:status_skill_npc(
    _attacker: any,
    _enemy: any,
    _skill_id: string,
    _rank: number,
    _sequence_id: number?
): (any?, string?)
    return {
        Landed = true,
        StatusApplied = true,
    }, nil
end

--[[
Counts one source-cast composition assertion.

Args:
    condition (boolean): Observed composition state.
    label (string): Failure description.

Returns:
    nil: Raises on failure and increments the assertion count.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Cast Runtime Composition] " .. label)
end

--[[
Runs source-cast composition and teardown acceptance.

Args:
    None.

Returns:
    nil: Prints pending-Studio evidence after all checks pass.
]]
local function main()
    local runtime = Composition.new(
        FakeShots,
        FakeExecutor
    )
    local capability = runtime:capability()

    check(
        capability.Available
            and capability.SourceShotAuthority
            and capability.SourceCastResources
            and capability.SourceCastTiming
            and capability.SourceCastScheduler
            and capability.DirectMagicBridge
            and capability.PeriodicMagicBridge
            and not capability.DirectMagicDefaultEnabled
            and not capability.DirectMagicCurrentlyEnabled
            and not capability.PeriodicMagicDefaultEnabled
            and not capability.PeriodicMagicCurrentlyEnabled,
        "Dungeon cast composition keeps both staged bridges default-off"
    )

    check(
        not runtime.DirectMagic:is_enabled()
            and not runtime.PeriodicMagic:is_enabled(),
        "composed staged bridges remain disabled until trusted activation"
    )

    local owner = {
        UserId = 938198,
    }
    runtime:clear_owner(owner)
    check(
        removed_user_id == owner.UserId,
        "owner teardown clears source shot state through composition"
    )

    print((
        "[C4 Cast Runtime Composition] TEST_PASS_PENDING_STUDIO: "
        .. "%d assertions direct=false periodic=false cleanup=true"
    ):format(checks))
end

main()
