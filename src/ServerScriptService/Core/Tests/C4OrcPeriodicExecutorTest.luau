--!strict
-- Focused live execution regression for Orc health and mana periodic effects.

local ServerScriptService = game:GetService("ServerScriptService")

local Executor = require(
    ServerScriptService.Core.Services.C4SourceCombatExecutor
)
local NpcMana = require(
    ServerScriptService.Core.Services.C4NpcManaService
)

local ATTACKER_ID = 959501
local checks = 0
local delayed = {}
local damage_events = {}

local FakeCombat = {}
local FakeResources = {}
local FakeVulnerability = {}

--[[
Counts one periodic-execution assertion.

Args:
    condition (boolean): Observed execution state.
    label (string): Failure diagnosis.

Returns:
    nil: Raises when the source contract is violated.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Orc Periodic Executor] " .. label)
end

--[[
Reports the isolated source-calculation gate.

Args:
    None.

Returns:
    boolean: Always enabled for this focused fixture.
]]
function FakeCombat.is_enabled(): boolean
    return true
end

--[[
Resolves one reviewed Orc periodic effect without client input.

Args:
    attacker_user_id (number): Expected fixture owner.
    _boundary (any): Reviewed NPC source boundary.
    creative_skill_id (string): Reviewed creative skill.
    creative_rank (number): Server-owned purchased rank.

Returns:
    (any?, string?): Exact periodic effect evidence.
]]
function FakeCombat.status_skill(
    attacker_user_id: number,
    _boundary: any,
    creative_skill_id: string,
    creative_rank: number
): (any?, string?)
    assert(attacker_user_id == ATTACKER_ID)

    if creative_skill_id == "OrcMysticChillFlame" then
        assert(creative_rank == 2)
        return {
            Kind = "PeriodicStatus",
            Landed = true,
            EffectType = "DMG_OVER_TIME",
            ResourceKind = "Health",
            SourceSkillId = 1100,
            SourceRank = 2,
            TickDamage = 30,
            TickCount = 15,
            TickSeconds = 1,
        }, nil
    end

    assert(creative_skill_id == "AshspeakerAuraSink")
    assert(creative_rank == 1)
    return {
        Kind = "PeriodicStatus",
        Landed = true,
        EffectType = "MANA_DMG_OVER_TIME",
        ResourceKind = "Mana",
        SourceSkillId = 1102,
        SourceRank = 1,
        TickDamage = 4,
        TickCount = 15,
        TickSeconds = 5,
    }, nil
end

--[[
Reports the isolated resource-cutover gate.

Args:
    None.

Returns:
    boolean: Always enabled for this fixture.
]]
function FakeResources.is_enabled(): boolean
    return true
end

--[[
Reports whether the fixture owner is source-cut-over.

Args:
    actor (any): Candidate player-like actor.

Returns:
    boolean: True only for the focused fixture owner.
]]
function FakeResources.is_active(actor: any): boolean
    return actor.UserId == ATTACKER_ID
end

--[[
Leaves the immutable source boundary unchanged.

Args:
    _enemy (any): Disposable NPC.
    boundary (any): Reviewed source boundary.

Returns:
    any: Same source boundary.
]]
function FakeVulnerability.decorate_boundary(
    _enemy: any,
    boundary: any
): any
    return boundary
end

--[[
Builds one disposable server NPC.

Args:
    health (number): Starting and maximum health.

Returns:
    Model: Disposable periodic target.
]]
local function fixture_npc(health: number): Model
    local npc = Instance.new("Model")
    npc.Name = "TEMP_OrcPeriodicTarget"

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = health
    humanoid.Health = health
    humanoid.Parent = npc

    return npc
end

--[[
Runs nonlethal health-DoT and authoritative mana-DoT acceptance.

Args:
    None.

Returns:
    nil: Prints bounded live periodic execution evidence.
]]
local function main()
    local attacker = {
        UserId = ATTACKER_ID,
    }
    local enemy = fixture_npc(25)
    local boundary = {
        SourceTargetKind = "Npc",
        SourceStatCandidate = {
            MAX_MP = 20,
        },
    }

    local executor = Executor.new({
        CombatProvider = FakeCombat,
        ResourceAuthority = FakeResources,
        NpcBoundaryProvider = function(target: Model): any
            assert(target == enemy)
            return boundary, nil
        end,
        ElementalVulnerabilityProvider = FakeVulnerability,
        NpcDamageObserver = function(
            context: any,
            damage: number,
            lethal: boolean
        )
            table.insert(damage_events, {
                Context = context,
                Damage = damage,
                Lethal = lethal,
            })
        end,
        DelayProvider = function(
            seconds: number,
            callback: () -> ()
        )
            table.insert(delayed, {
                Seconds = seconds,
                Callback = callback,
            })
        end,
    })
    executor:configure_spatial_rules(
        25,
        function(): boolean
            return false
        end
    )
    assert(executor:set_enabled(true))

    local chill = assert(executor:status_skill_npc(
        attacker,
        enemy,
        "OrcMysticChillFlame",
        2,
        701
    ))
    check(
        chill.StatusApplied
            and chill.ResourceKind == "Health"
            and chill.SourceSkillId == 1100
            and chill.TickDamage == 30
            and chill.TickCount == 15
            and chill.TickSeconds == 1
            and #delayed == 1,
        "Chill Flame schedules its exact reviewed health DoT"
    )

    local health_tick = table.remove(delayed, 1)
    assert(health_tick)
    health_tick.Callback()

    local humanoid = assert(
        enemy:FindFirstChildOfClass("Humanoid")
    )
    check(
        humanoid.Health == 1
            and #damage_events == 1
            and damage_events[1].Damage == 24
            and not damage_events[1].Lethal
            and damage_events[1].Context.C4PeriodicStatus == true
            and damage_events[1].Context.C4SourceSkillId == 1100,
        "health DoT remains nonlethal and preserves combat attribution"
    )

    table.clear(delayed)
    table.clear(damage_events)

    local sink = assert(executor:status_skill_npc(
        attacker,
        enemy,
        "AshspeakerAuraSink",
        1,
        702
    ))
    check(
        sink.StatusApplied
            and sink.ResourceKind == "Mana"
            and sink.SourceSkillId == 1102
            and sink.TickDamage == 4
            and sink.TickCount == 15
            and sink.TickSeconds == 5
            and #delayed == 1
            and NpcMana.get(enemy) == 0,
        "Aura Sink schedules without inventing eager mana mutation"
    )

    local mana_tick = table.remove(delayed, 1)
    assert(mana_tick)
    mana_tick.Callback()

    check(
        NpcMana.get_max(enemy) == 20
            and NpcMana.get(enemy) == 16
            and #damage_events == 0
            and #delayed == 1
            and delayed[1].Seconds == 5,
        "Aura Sink drains authoritative NPC MP without HP damage callbacks"
    )

    local capability = executor:capability()
    check(
        capability.NpcPeriodicHealthDotLiveApplication
            and capability.NpcPeriodicManaDotLiveApplication
            and capability.NpcPeriodicManaAuthorityConfigured,
        "executor reports both reviewed periodic resource authorities"
    )

    enemy:Destroy()

    print((
        "[C4 Orc Periodic Executor] PASS: %d assertions "
            .. "health_dot=true mana_dot=true"
    ):format(checks))
end

main()
