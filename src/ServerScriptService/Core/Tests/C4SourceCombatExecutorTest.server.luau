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

local NPC_BOUNDARY = {
    SourceTargetKind = "Npc",
    SourceNpcId = 525,
    SourceNpcRace = "ANIMAL",
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

    local executor = ExecutorModule.new({
        CombatProvider = FakeCombat,
        ResourceAuthority = FakeResources,
        NpcBoundaryProvider = function(target: Model): any
            assert(target == enemy)
            return NPC_BOUNDARY, nil
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

    print((
        "[C4 Source Combat Executor] LIVE_EXECUTOR_PASS: %d assertions "
            .. "default_off=true live_fixture=true npc=true"
    ):format(checks))
end

main()
