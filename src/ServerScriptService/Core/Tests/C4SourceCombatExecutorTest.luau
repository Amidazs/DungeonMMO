--!strict
-- Isolated live-executor gating/resource mutation regression.

local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local ExecutorModule = require(
    ServerScriptService.Core.Services.C4SourceCombatExecutor
)

local ATTACKER_ID = 958181
local DEFENDER_ID = 958182

local checks = 0
local combat_enabled = true
local resources_enabled = true
local attacker_active = true
local defender_active = true
local combat_mode = "Hit"
local last_spatial = nil
local npc_events = {}
local delayed_callbacks = {}
local status_mode = "Bleed"

local NPC_BOUNDARY = {
    SourceTargetKind = "Npc",
    SourceNpcId = 525,
    SourceNpcRace = "ANIMAL",
}
local NPC_BOUNDARY_SECONDARY = {
    SourceTargetKind = "Npc",
    SourceNpcId = 325,
    SourceNpcRace = "NONE",
}

local FakeCombat = {}
local FakeResources = {}

--[[
Counts one live-executor assertion.

Args:
    valid (boolean): Expected executor state.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Source Combat Executor] " .. label)
end

--[[
Reports the disposable source-calculation gate.

Args:
    None.

Returns:
    boolean: Current fake calculation-gate state.
]]
function FakeCombat.is_enabled(): boolean
    return combat_enabled
end

--[[
Returns one disposable source normal-attack result.

Args:
    attacker_user_id (number): Expected fixture attacker.
    defender_user_id (number): Expected fixture defender.
    spatial_context (any): Executor-derived server spatial context.

Returns:
    (any?, string?): Fake accepted calculation result.
]]
function FakeCombat.normal_attack(
    attacker_user_id: number,
    defender_target: any,
    spatial_context: any
): (any?, string?)
    assert(attacker_user_id == ATTACKER_ID)
    assert(
        defender_target == DEFENDER_ID
            or defender_target == NPC_BOUNDARY
    )
    last_spatial = spatial_context

    if combat_mode == "Miss" then
        return {
            Kind = "NormalAttack",
            Hit = false,
            Miss = true,
            Amount = 0,
        }, nil
    end

    return {
        Kind = "NormalAttack",
        Hit = true,
        Miss = false,
        Amount = 10,
    }, nil
end

--[[
Returns one disposable source PDAM result.

Args:
    attacker_user_id (number): Expected fixture attacker.
    defender_user_id (number): Expected fixture defender.
    creative_skill_id (string): Expected fixture skill ID.
    creative_rank (number): Expected fixture rank.
    spatial_context (any): Executor-derived spatial context.

Returns:
    (any?, string?): Fake accepted PDAM result.
]]
function FakeCombat.physical_skill(
    attacker_user_id: number,
    defender_target: any,
    creative_skill_id: string,
    creative_rank: number,
    spatial_context: any
): (any?, string?)
    assert(attacker_user_id == ATTACKER_ID)
    assert(
        defender_target == DEFENDER_ID
            or defender_target == NPC_BOUNDARY
    )
    assert(creative_skill_id == "IronCleave")
    assert(creative_rank == 1)
    last_spatial = spatial_context

    return {
        Kind = "PhysicalDamage",
        Amount = 12,
    }, nil
end

--[[
Returns one disposable source MDAM result.

Args:
    attacker_user_id (number): Expected fixture attacker.
    defender_user_id (number): Expected fixture defender.
    creative_skill_id (string): Expected fixture skill ID.
    creative_rank (number): Expected fixture rank.

Returns:
    (any?, string?): Fake accepted MDAM result.
]]
function FakeCombat.magic_skill(
    attacker_user_id: number,
    defender_target: any,
    creative_skill_id: string,
    creative_rank: number
): (any?, string?)
    assert(attacker_user_id == ATTACKER_ID)
    assert(
        defender_target == DEFENDER_ID
            or defender_target == NPC_BOUNDARY
    )
    assert(creative_skill_id == "WindStrike")
    assert(creative_rank == 1)

    return {
        Kind = "MagicDamage",
        Amount = 8,
    }, nil
end

--[[
Returns one disposable source TARGET_AREA MDAM result.

Args:
    attacker_user_id (number): Expected fixture attacker.
    defender_targets ({any}): Reviewed ordered NPC boundaries.
    creative_skill_id (string): Expected area skill identifier.
    creative_rank (number): Expected purchased rank.

Returns:
    (any?, string?): Fake multi-target source result.
]]
function FakeCombat.magic_area_skill(
    attacker_user_id: number,
    defender_targets: {any},
    creative_skill_id: string,
    creative_rank: number
): (any?, string?)
    assert(attacker_user_id == ATTACKER_ID)
    assert(creative_skill_id == "EmberweaverEmberField")
    assert(creative_rank == 3)
    assert(#defender_targets == 2)
    assert(defender_targets[1] == NPC_BOUNDARY)
    assert(defender_targets[2] == NPC_BOUNDARY_SECONDARY)

    return {
        Kind = "MagicAreaDamage",
        Results = {
            {Kind = "MagicDamage", Amount = 7},
            {Kind = "MagicDamage", Amount = 9},
        },
        TargetCount = 2,
        SourceSkillId = 1181,
        SourceRank = 3,
        SourceSkillRadius = 200,
        Spiritshot = true,
        BlessedSpiritshot = false,
    }, nil
end

--[[
Returns one disposable source DRAIN result.

Args:
    attacker_user_id (number): Expected fixture attacker.
    defender_target (any): Expected reviewed NPC boundary.
    creative_skill_id (string): Expected drain skill identifier.
    creative_rank (number): Expected purchased rank.

Returns:
    (any?, string?): Fake source drain result.
]]
function FakeCombat.drain_skill(
    attacker_user_id: number,
    defender_target: any,
    creative_skill_id: string,
    creative_rank: number
): (any?, string?)
    assert(attacker_user_id == ATTACKER_ID)
    assert(defender_target == NPC_BOUNDARY)
    assert(creative_skill_id == "EmberweaverLifeSiphon")
    assert(creative_rank == 4)

    return {
        Kind = "MagicDrain",
        Amount = 40,
        AbsorbPart = 0.4,
        AbsorbAbs = 0,
        Spiritshot = true,
        BlessedSpiritshot = false,
        SourceSkillId = 1147,
        SourceRank = 6,
    }, nil
end

--[[
Returns one disposable source Sleep result.

Args:
    attacker_user_id (number): Expected fixture attacker.
    defender_target (any): Expected reviewed NPC boundary.
    creative_skill_id (string): Expected Sleep skill identifier.
    creative_rank (number): Expected purchased rank.

Returns:
    (any?, string?): Fake source Sleep result.
]]
function FakeCombat.sleep_skill(
    attacker_user_id: number,
    defender_target: any,
    creative_skill_id: string,
    creative_rank: number
): (any?, string?)
    assert(attacker_user_id == ATTACKER_ID)
    assert(defender_target == NPC_BOUNDARY)
    assert(creative_skill_id == "EmberweaverSlumberHex")
    assert(creative_rank == 6)

    return {
        Kind = "SleepControl",
        Landed = true,
        Rate = 80,
        Roll = 0,
        DurationSeconds = 30,
        BreaksOnDamage = true,
        StopsMovement = true,
        StopsAttacks = true,
        StopsCasting = true,
        SourceSkillId = 1069,
        SourceRank = 6,
    }, nil
end

--[[
Returns one disposable source elemental-vulnerability result.

Args:
    attacker_user_id (number): Expected fixture attacker.
    defender_target (any): Expected reviewed NPC boundary.
    creative_skill_id (string): Expected Scorch Mark identifier.
    creative_rank (number): Expected purchased rank.

Returns:
    (any?, string?): Fake source vulnerability result.
]]
function FakeCombat.elemental_vulnerability_skill(
    attacker_user_id: number,
    defender_target: any,
    creative_skill_id: string,
    creative_rank: number
): (any?, string?)
    assert(attacker_user_id == ATTACKER_ID)
    assert(defender_target == NPC_BOUNDARY)
    assert(creative_skill_id == "EmberweaverScorchMark")
    assert(creative_rank == 2)

    return {
        Kind = "ElementalVulnerability",
        Landed = true,
        Rate = 80,
        Roll = 0,
        VulnerabilityStat = "FIRE_VULN",
        VulnerabilityMultiplier = 1.25,
        DurationSeconds = 15,
        SourceSkillId = 1083,
        SourceRank = 2,
    }, nil
end

--[[
Returns one disposable source physical-attack weakening result.

Args:
    attacker_user_id (number): Expected fixture attacker.
    defender_target (any): Expected reviewed NPC boundary.
    creative_skill_id (string): Expected Withering Hex identifier.
    creative_rank (number): Expected purchased rank.

Returns:
    (any?, string?): Fake source physical-attack weakening result.
]]
function FakeCombat.physical_attack_weakening_skill(
    attacker_user_id: number,
    defender_target: any,
    creative_skill_id: string,
    creative_rank: number
): (any?, string?)
    assert(attacker_user_id == ATTACKER_ID)
    assert(defender_target == NPC_BOUNDARY)
    assert(creative_skill_id == "EmberweaverWitheringHex")
    assert(creative_rank == 3)

    return {
        Kind = "PhysicalAttackWeakening",
        Landed = true,
        Rate = 80,
        Roll = 0,
        PhysicalAttackMultiplier = 0.8,
        PowerReductionFraction = 0.2,
        DurationSeconds = 15,
        SourceSkillId = 1164,
        SourceRank = 4,
    }, nil
end

--[[
Returns one disposable source self-heal result.

Args:
    caster_user_id (number): Expected fixture caster.
    creative_skill_id (string): Expected fixture heal ID.
    creative_rank (number): Expected fixture rank.

Returns:
    (any?, string?): Fake accepted HEAL result.
]]
function FakeCombat.heal_skill(
    caster_user_id: number,
    creative_skill_id: string,
    creative_rank: number
): (any?, string?)
    assert(caster_user_id == ATTACKER_ID)
    assert(creative_skill_id == "MageHeal")
    assert(creative_rank == 1)

    return {
        Kind = "Heal",
        Amount = 15,
    }, nil
end

--[[
Returns one disposable source periodic-status result.

Args:
    attacker_user_id (number): Expected fixture attacker.
    defender_target (any): Expected fixture NPC boundary.
    creative_skill_id (string): Expected creative status identifier.
    creative_rank (number): Expected purchased rank.

Returns:
    (any?, string?): Fake source DEBUFF application result.
]]
function FakeCombat.status_skill(
    attacker_user_id: number,
    defender_target: any,
    creative_skill_id: string,
    creative_rank: number
): (any?, string?)
    assert(attacker_user_id == ATTACKER_ID)
    assert(defender_target == NPC_BOUNDARY)
    assert(creative_rank == 1)

    if status_mode == "Resisted" then
        return {
            Kind = "PeriodicStatus",
            Landed = false,
            Rate = 50,
            Roll = 50,
            EffectType = "BLEED",
            SourceSkillId = 96,
            SourceRank = 1,
            TickDamage = 13,
            TickCount = 4,
            TickSeconds = 5,
        }, nil
    end

    if creative_skill_id == "MysticPoisonCurse" then
        return {
            Kind = "PeriodicStatus",
            Landed = true,
            Rate = 72,
            Roll = 0,
            EffectType = "POISON",
            SourceSkillId = 1168,
            SourceRank = 1,
            TickDamage = 8,
            TickCount = 10,
            TickSeconds = 3,
        }, nil
    end

    assert(creative_skill_id == "WayfinderWound")
    return {
        Kind = "PeriodicStatus",
        Landed = true,
        Rate = 99,
        Roll = 0,
        EffectType = "BLEED",
        SourceSkillId = 96,
        SourceRank = 1,
        TickDamage = 13,
        TickCount = 4,
        TickSeconds = 5,
    }, nil
end

--[[
Reports the disposable source-resource global gate.

Args:
    None.

Returns:
    boolean: Current fake resource-gate state.
]]
function FakeResources.is_enabled(): boolean
    return resources_enabled
end

--[[
Reports whether one fixture participant is source-cut-over.

Args:
    player (any): Disposable player-like fixture.

Returns:
    boolean: Current participant cutover state.
]]
function FakeResources.is_active(player: any): boolean
    if player.UserId == ATTACKER_ID then
        return attacker_active
    end
    if player.UserId == DEFENDER_ID then
        return defender_active
    end
    return false
end

--[[
Routes disposable playable damage through three points of fake CP.

Args:
    defender (any): Expected fixture defender.
    damage (number): Accepted source damage.
    attacker_is_playable (boolean): Must remain true for PvP.

Returns:
    (number, number): HP remainder and fake CP absorption.
]]
function FakeResources.resolve_player_damage(
    defender: any,
    damage: number,
    attacker_is_playable: boolean
): (number, number)
    assert(defender.UserId == DEFENDER_ID)
    assert(attacker_is_playable)

    local absorbed = math.min(damage, 3)
    return damage - absorbed, absorbed
end

--[[
Builds one player-like fixture with a real Model, root and Humanoid.

Args:
    user_id (number): Fixture UserId.
    position (Vector3): Root world position.

Returns:
    any: Player-like table accepted by the isolated executor.
]]
local function fixture_player(
    user_id: number,
    position: Vector3
): any
    local character = Instance.new("Model")
    character.Name = "TEMP_C4ExecutorCharacter"

    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Anchored = true
    root.CFrame = CFrame.new(position)
    root.Parent = character

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    humanoid.Parent = character

    return {
        UserId = user_id,
        Character = character,
    }
end

--[[
Builds one disposable server NPC with a real root and Humanoid.

Args:
    position (Vector3): NPC root world position.

Returns:
    Model: Workspace-owned disposable NPC target.
]]
local function fixture_npc(position: Vector3): Model
    local enemy = Instance.new("Model")
    enemy.Name = "TEMP_C4ExecutorNpc"

    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Anchored = true
    root.CFrame = CFrame.new(position)
    root.Parent = enemy

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    humanoid.Parent = enemy

    enemy.Parent = Workspace
    return enemy
end

--[[
Runs disabled-gate, spatial-authority, CP and HP executor regressions.

Args:
    None.

Returns:
    nil: Prints isolated live-executor acceptance evidence.
]]
local function main()
    local attacker = fixture_player(
        ATTACKER_ID,
        Vector3.new(0, 2, -10)
    )
    local defender = fixture_player(
        DEFENDER_ID,
        Vector3.new(0, 0, 0)
    )
    local enemy = fixture_npc(Vector3.new(0, 0, 0))
    local secondary = fixture_npc(Vector3.new(0, 2, -6))
    local outsider = fixture_npc(Vector3.new(0, 2, -5))
    enemy:SetAttribute("DungeonEncounterId", "TEMP_Area")
    secondary:SetAttribute("DungeonEncounterId", "TEMP_Area")
    outsider:SetAttribute("DungeonEncounterId", "TEMP_Other")

    local executor = ExecutorModule.new({
        CombatProvider = FakeCombat,
        ResourceAuthority = FakeResources,
        NpcBoundaryProvider = function(target: Model): any
            if target == enemy then
                return NPC_BOUNDARY, nil
            end
            if target == secondary then
                return NPC_BOUNDARY_SECONDARY, nil
            end
            if target == outsider then
                return NPC_BOUNDARY_SECONDARY, nil
            end
            error("unexpected NPC boundary target")
        end,
        NpcDamageObserver = function(
            context: any,
            damage: number,
            lethal: boolean
        )
            table.insert(npc_events, {
                Context = context,
                Damage = damage,
                Lethal = lethal,
            })
        end,
        DelayProvider = function(
            seconds: number,
            callback: () -> ()
        )
            table.insert(delayed_callbacks, {
                Seconds = seconds,
                Callback = callback,
            })
        end,
    })

    local capability = executor:capability()
    check(
        not executor:is_enabled()
            and capability.DefaultEnabled == false
            and capability.ServerSpatialContext
            and capability.PlayableDamageRoutesThroughCP
            and capability.NormalAttackLiveApplication
            and capability.PhysicalSkillLiveApplication
            and capability.MagicSkillLiveApplication
            and capability.SelfHealLiveApplication
            and capability.NpcBoundaryProviderConfigured
            and capability.NpcDamageObserverConfigured
            and capability.NpcNormalAttackLiveApplication
            and capability.NpcPhysicalSkillLiveApplication
            and capability.NpcMagicSkillLiveApplication
            and capability.NpcMagicAreaLiveApplication
            and capability.NpcMagicAreaCasterRadiusSourceSemantics
            and capability.NpcMagicAreaSingleShotSnapshot
            and capability.NpcMagicDrainLiveApplication
            and capability.NpcMagicDrainUsesAppliedHealthDamage
            and capability.NpcSleepLiveApplication
            and capability.NpcSleepBreaksOnDirectDamage
            and capability.NpcSleepAuthorityConfigured
            and capability.NpcElementalVulnerabilityLiveApplication
            and capability.NpcElementalVulnerabilityBoundaryDecoration
            and capability.NpcElementalVulnerabilityAuthorityConfigured
            and capability.NpcPhysicalAttackWeakeningLiveApplication
            and capability.NpcPhysicalAttackWeakeningUsesOutgoingDamageRules
            and capability.NpcPhysicalAttackWeakeningLeavesAttackRateNeutral
            and capability.NpcPhysicalAttackWeakeningAuthorityConfigured
            and capability.NpcMagicSkillReadOnlyPreflight
            and capability.NpcStatusSkillReadOnlyPreflight
            and capability.NpcSourceRangePreflight
            and capability.NpcPeriodicStatusLiveApplication
            and capability.NpcPeriodicStatusNonlethal
            and capability.NpcPeriodicStatusRefreshBySourceSkill
            and capability.NpcDamageBypassesCombatPoints
            and capability.NpcDamageCallbackPreservation
            and not capability.ClientDamageAuthority,
        "live executor starts disabled with server-only authority"
    )

    local premature, premature_reason =
        executor:set_enabled(true)
    check(
        not premature
            and premature_reason
                == "C4LiveSpatialRulesUnconfigured",
        "live gate refuses to enable before spatial rules"
    )

    executor:configure_spatial_rules(
        25,
        function(): boolean
            return true
        end
    )
    local enabled = executor:set_enabled(true)
    check(enabled, "explicitly configured live executor can enable")

    combat_enabled = false
    local no_combat, no_combat_reason =
        executor:normal_attack(attacker, defender)
    check(
        no_combat == nil
            and no_combat_reason
                == "C4SourceCombatCalculationDisabled",
        "executor requires the independent source calculation gate"
    )
    combat_enabled = true

    defender_active = false
    local no_cutover, no_cutover_reason =
        executor:normal_attack(attacker, defender)
    check(
        no_cutover == nil
            and no_cutover_reason
                == "C4LiveCombatParticipantNotCutOver",
        "executor requires per-player source resource cutover"
    )
    defender_active = true

    local npc_preflight, npc_preflight_reason =
        executor:can_magic_skill_npc(
            attacker,
            enemy,
            750
        )
    local status_preflight, status_preflight_reason =
        executor:can_status_skill_npc(
            attacker,
            enemy,
            600
        )
    local out_of_range, out_of_range_reason =
        executor:can_magic_skill_npc(
            attacker,
            enemy,
            200
        )
    local preflight_humanoid =
        enemy:FindFirstChildOfClass("Humanoid")
    check(
        npc_preflight
            and npc_preflight_reason == nil
            and status_preflight
            and status_preflight_reason == nil
            and not out_of_range
            and out_of_range_reason
                == "C4SourceCastTargetOutOfRange"
            and preflight_humanoid ~= nil
            and preflight_humanoid.Health == 100
            and #npc_events == 0,
        "NPC source range preflight validates without world mutation"
    )

    combat_mode = "Miss"
    local miss = assert(executor:normal_attack(
        attacker,
        defender
    ))
    local defender_humanoid =
        defender.Character:FindFirstChildOfClass("Humanoid")
    check(
        miss.Miss
            and not miss.Applied
            and defender_humanoid ~= nil
            and defender_humanoid.Health == 100,
        "source miss never mutates CP or HP"
    )

    combat_mode = "Hit"
    local hit = assert(executor:normal_attack(
        attacker,
        defender
    ))
    check(
        hit.Hit
            and hit.Applied
            and hit.RawDamage == 10
            and hit.CPAbsorbed == 3
            and hit.HealthDamage == 7
            and hit.HealthBefore == 100
            and hit.HealthAfter == 93,
        "source hit routes playable damage through CP before HP"
    )

    check(
        last_spatial ~= nil
            and last_spatial.AttackerPosition
                == Vector3.new(0, 2, -10)
            and last_spatial.DefenderCFrame
                == CFrame.new(0, 0, 0)
            and last_spatial.HeightDeltaSourceUnits == 50
            and last_spatial.IsNight,
        "executor derives transforms and explicit elevation scale server-side"
    )

    local physical = assert(executor:physical_skill(
        attacker,
        defender,
        "IronCleave",
        1
    ))
    check(
        physical.Kind == "C4LivePhysicalSkill"
            and physical.RawDamage == 12
            and physical.CPAbsorbed == 3
            and physical.HealthDamage == 9
            and physical.HealthBefore == 93
            and physical.HealthAfter == 84,
        "live PDAM routes accepted source damage through CP before HP"
    )

    local magic = assert(executor:magic_skill(
        attacker,
        defender,
        "WindStrike",
        1
    ))
    check(
        magic.Kind == "C4LiveMagicSkill"
            and magic.RawDamage == 8
            and magic.CPAbsorbed == 3
            and magic.HealthDamage == 5
            and magic.HealthBefore == 84
            and magic.HealthAfter == 79,
        "live MDAM routes accepted source damage through CP before HP"
    )

    local attacker_humanoid =
        attacker.Character:FindFirstChildOfClass("Humanoid")
    assert(attacker_humanoid)
    attacker_humanoid.Health = 70

    local heal = assert(executor:heal_skill(
        attacker,
        "MageHeal",
        1
    ))
    check(
        heal.Kind == "C4LiveHealSkill"
            and heal.RawHeal == 15
            and heal.EffectiveHeal == 15
            and heal.HealthBefore == 70
            and heal.HealthAfter == 85,
        "live HEAL applies accepted source healing to server Humanoid"
    )

    combat_mode = "Hit"
    local npc_normal = assert(executor:normal_attack_npc(
        attacker,
        enemy,
        201
    ))
    check(
        npc_normal.Hit
            and npc_normal.Applied
            and npc_normal.RawDamage == 10
            and npc_normal.CPAbsorbed == 0
            and npc_normal.HealthDamage == 10
            and npc_normal.HealthAfter == 90,
        "live NPC normal attack applies source damage without CP"
    )

    local npc_physical = assert(executor:physical_skill_npc(
        attacker,
        enemy,
        "IronCleave",
        1,
        202
    ))
    check(
        npc_physical.Kind == "C4LiveNpcPhysicalSkill"
            and npc_physical.RawDamage == 12
            and npc_physical.CPAbsorbed == 0
            and npc_physical.HealthAfter == 78,
        "live NPC PDAM applies accepted source damage directly to HP"
    )

    local npc_magic = assert(executor:magic_skill_npc(
        attacker,
        enemy,
        "WindStrike",
        1,
        203
    ))
    check(
        npc_magic.Kind == "C4LiveNpcMagicSkill"
            and npc_magic.RawDamage == 8
            and npc_magic.CPAbsorbed == 0
            and npc_magic.HealthAfter == 70,
        "live NPC MDAM applies accepted source damage directly to HP"
    )

    check(
        #npc_events == 3
            and npc_events[1].Context.source_kind == "Melee"
            and npc_events[1].Context.C4SourceResolved == true
            and npc_events[1].Context.sequence_id == 201
            and npc_events[2].Context.source_kind == "Skill"
            and npc_events[2].Context.source_id == "IronCleave"
            and npc_events[3].Context.source_kind == "MagicSkill"
            and npc_events[3].Context.source_id == "WindStrike"
            and npc_events[3].Damage == 8
            and not npc_events[3].Lethal,
        "NPC source damage emits existing trusted bookkeeping context"
    )

    table.clear(npc_events)
    local scorch = assert(
        executor:elemental_vulnerability_skill_npc(
            attacker,
            enemy,
            "EmberweaverScorchMark",
            2,
            2055
        )
    )
    check(
        scorch.Kind == "C4LiveNpcElementalVulnerability"
            and scorch.Applied
            and scorch.VulnerabilityApplied
            and scorch.Landed
            and scorch.VulnerabilityStat == "FIRE_VULN"
            and scorch.VulnerabilityMultiplier == 1.25
            and scorch.DurationSeconds == 15
            and enemy:GetAttribute("C4FIRE_VULNMultiplier")
                == 1.25
            and type(
                enemy:GetAttribute("C4FIRE_VULNEndsAt")
            ) == "number"
            and #npc_events == 0,
        "landed source fire vulnerability applies without dealing damage"
    )

    table.clear(npc_events)
    local weakness = assert(
        executor:physical_attack_weakening_skill_npc(
            attacker,
            enemy,
            "EmberweaverWitheringHex",
            3,
            2056
        )
    )
    check(
        weakness.Kind == "C4LiveNpcPhysicalAttackWeakening"
            and weakness.Applied
            and weakness.WeakeningApplied
            and weakness.Landed
            and weakness.PhysicalAttackMultiplier == 0.8
            and weakness.PowerReductionFraction == 0.2
            and weakness.DurationSeconds == 15
            and enemy:GetAttribute("C4PowerWeakening") == 0.2
            and enemy:GetAttribute("C4RateWeakening") == 0
            and #npc_events == 0,
        "landed source attack weakness reduces power without damage or rate"
    )

    local sleep_humanoid =
        enemy:FindFirstChildOfClass("Humanoid")
    assert(sleep_humanoid)
    table.clear(npc_events)

    local sleep = assert(executor:sleep_skill_npc(
        attacker,
        enemy,
        "EmberweaverSlumberHex",
        6,
        206
    ))
    check(
        sleep.Kind == "C4LiveNpcSleep"
            and sleep.Applied
            and sleep.SleepApplied
            and sleep.Landed
            and sleep.DurationSeconds == 30
            and sleep.BreaksOnDamage
            and enemy:GetAttribute("C4Sleeping") == true
            and type(enemy:GetAttribute("C4SleepEndsAt")) == "number"
            and #npc_events == 0,
        "landed source Sleep suppresses NPC without dealing damage"
    )

    local wake_hit = assert(executor:magic_skill_npc(
        attacker,
        enemy,
        "WindStrike",
        1,
        207
    ))
    check(
        wake_hit.HealthDamage == 8
            and enemy:GetAttribute("C4Sleeping") == false
            and enemy:GetAttribute("C4SleepEndsAt") == 0
            and #npc_events == 1
            and npc_events[1].Context.sequence_id == 207,
        "normal direct source damage wakes Sleep before applying HP loss"
    )

    sleep_humanoid.Health = 70
    table.clear(npc_events)

    table.clear(npc_events)
    local secondary_humanoid =
        secondary:FindFirstChildOfClass("Humanoid")
    local outsider_humanoid =
        outsider:FindFirstChildOfClass("Humanoid")
    assert(secondary_humanoid and outsider_humanoid)

    local area = assert(executor:magic_area_skill_npc(
        attacker,
        enemy,
        "EmberweaverEmberField",
        3,
        200,
        204
    ))
    check(
        area.Kind == "C4LiveNpcMagicArea"
            and area.Applied
            and area.TargetCount == 2
            and area.TotalHealthDamage == 16
            and area.SourceSkillRadius == 200
            and area.Spiritshot
            and enemy:FindFirstChildOfClass("Humanoid").Health == 63
            and secondary_humanoid.Health == 91
            and outsider_humanoid.Health == 100,
        "TARGET_AREA keeps primary and hits same-encounter caster-radius NPCs"
    )
    check(
        #npc_events == 2
            and npc_events[1].Context.source_kind == "MagicArea"
            and npc_events[2].Context.source_kind == "MagicArea"
            and npc_events[1].Context.sequence_id == 204
            and npc_events[2].Context.sequence_id == 204,
        "area source damage preserves per-target bookkeeping callbacks"
    )

    local drain_target_humanoid =
        enemy:FindFirstChildOfClass("Humanoid")
    local drain_caster_humanoid =
        attacker.Character:FindFirstChildOfClass("Humanoid")
    assert(drain_target_humanoid and drain_caster_humanoid)

    drain_target_humanoid.Health = 50
    drain_caster_humanoid.Health = 90
    table.clear(npc_events)

    local drain = assert(executor:magic_drain_skill_npc(
        attacker,
        enemy,
        "EmberweaverLifeSiphon",
        4,
        205
    ))
    check(
        drain.Kind == "C4LiveNpcMagicDrain"
            and drain.RawDamage == 40
            and drain.HealthDamage == 40
            and drain.DrainableHealthDamage == 40
            and drain.RequestedHeal == 16
            and drain.EffectiveHeal == 10
            and drain.CasterHealthBefore == 90
            and drain.CasterHealthAfter == 100
            and not drain.Lethal,
        "source drain heals from HP damage and caps at caster MaxHealth"
    )
    check(
        #npc_events == 1
            and npc_events[1].Context.source_kind == "MagicDrain"
            and npc_events[1].Context.source_id
                == "EmberweaverLifeSiphon"
            and npc_events[1].Context.sequence_id == 205
            and npc_events[1].Damage == 40
            and not npc_events[1].Lethal,
        "source drain preserves trusted NPC damage bookkeeping"
    )

    local enemy_humanoid =
        enemy:FindFirstChildOfClass("Humanoid")
    assert(enemy_humanoid)
    enemy_humanoid.Health = 20
    table.clear(delayed_callbacks)
    table.clear(npc_events)

    status_mode = "Bleed"
    local bleed = assert(executor:status_skill_npc(
        attacker,
        enemy,
        "WayfinderWound",
        1,
        301
    ))
    check(
        bleed.StatusApplied
            and bleed.Landed
            and bleed.SourceKind == "StatusPhysical"
            and bleed.SourceSkillId == 96
            and bleed.TickDamage == 13
            and bleed.TickCount == 4
            and bleed.TickSeconds == 5
            and #delayed_callbacks == 1
            and delayed_callbacks[1].Seconds == 5,
        "source Bleed schedules the exact reviewed periodic plan"
    )

    for _ = 1, 4 do
        local queued = table.remove(delayed_callbacks, 1)
        assert(queued)
        queued.Callback()
    end
    check(
        enemy_humanoid.Health == 1
            and #npc_events == 2
            and npc_events[1].Damage == 13
            and npc_events[2].Damage == 6
            and npc_events[1].Context.source_kind
                == "StatusPhysical"
            and npc_events[1].Context.C4PeriodicStatus == true
            and not npc_events[1].Lethal
            and not npc_events[2].Lethal
            and #delayed_callbacks == 0,
        "source Bleed ticks are nonlethal and preserve damage callbacks"
    )

    enemy_humanoid.Health = 100
    table.clear(delayed_callbacks)
    table.clear(npc_events)
    status_mode = "Poison"

    local poison = assert(executor:status_skill_npc(
        attacker,
        enemy,
        "MysticPoisonCurse",
        1,
        302
    ))
    check(
        poison.StatusApplied
            and poison.SourceKind == "StatusMagic"
            and poison.SourceSkillId == 1168
            and poison.TickDamage == 8
            and poison.TickCount == 10
            and poison.TickSeconds == 3
            and #delayed_callbacks == 1,
        "source Poison schedules the exact reviewed periodic plan"
    )

    local poison_tick = table.remove(delayed_callbacks, 1)
    assert(poison_tick)
    poison_tick.Callback()
    check(
        enemy_humanoid.Health == 92
            and #npc_events == 1
            and npc_events[1].Context.source_kind == "StatusMagic"
            and npc_events[1].Context.C4SourceSkillId == 1168
            and npc_events[1].Context.C4SourceCastSequenceId == 302,
        "source Poison tick keeps original cast attribution"
    )

    table.clear(delayed_callbacks)
    status_mode = "Resisted"
    local resisted = assert(executor:status_skill_npc(
        attacker,
        enemy,
        "WayfinderWound",
        1,
        303
    ))
    check(
        not resisted.StatusApplied
            and not resisted.Landed
            and not resisted.Scheduled
            and #delayed_callbacks == 0,
        "resisted source DEBUFF schedules no periodic damage"
    )
    status_mode = "Bleed"

    local self_attack, self_reason =
        executor:normal_attack(attacker, attacker)
    check(
        self_attack == nil
            and self_reason == "InvalidC4LiveCombatParticipants",
        "executor rejects self-target source attacks"
    )

    local disabled = executor:set_enabled(false)
    check(
        disabled and not executor:is_enabled(),
        "live executor gate is reversible"
    )

    attacker.Character:Destroy()
    defender.Character:Destroy()
    enemy:Destroy()
    secondary:Destroy()
    outsider:Destroy()

    print((
        "[C4 Source Combat Executor] LIVE_EXECUTOR_PASS: %d assertions "
            .. "default_off=true live_fixture=true npc=true"
    ):format(checks))
end

main()
