--!strict
-- Pinned C4 NPC source-record and server-boundary regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Reference = require(
    ReplicatedStorage.Core.Shared.C4NpcSourceReference
)
local BoundaryService = require(
    ServerScriptService.Core.Services.C4NpcSourceBoundaryService
)

local checks = 0

--[[
Counts one NPC source-boundary assertion.

Args:
    valid (boolean): Expected source-boundary condition.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 NPC Source Boundary] " .. label)
end

--[[
Creates one disposable living server enemy for boundary checks.

Args:
    archetype_id (string?): Optional server archetype attribute.

Returns:
    Model: Workspace-owned model with a living Humanoid.
]]
local function enemy_fixture(archetype_id: string?): Model
    local enemy = Instance.new("Model")
    enemy.Name = "TEMP_C4NpcSourceEnemy"

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    humanoid.Parent = enemy

    if archetype_id then
        enemy:SetAttribute(
            "DungeonEnemyArchetypeId",
            archetype_id
        )
    end

    enemy.Parent = Workspace
    return enemy
end

--[[
Checks the pinned standard Marauder source record and derived stats.

Args:
    None.

Returns:
    nil: Confirms exact source ID, race and derived combat values.
]]
local function check_marauder()
    local boundary = assert(Reference.get("Marauder"))
    local stats = boundary.SourceStatCandidate

    check(
        boundary.SourceNpcId == 325
            and boundary.Level == 5
            and boundary.SourceNpcRace == "NONE"
            and boundary.SourceRaceSkillId == 4295
            and boundary.SourceWitBonus == 1
            and boundary.PlayerFacingSourceNameExposed == false,
        "creative Marauder keeps internal pinned source identity only"
    )
    check(
        stats.MAX_HP == 126
            and stats.MAX_MP == 85
            and stats.MAX_CP == 0,
        "Marauder source HP/MP/CP match C4 calculator output"
    )
    check(
        stats.PHYSICAL_ATTACK == 13
            and stats.PHYSICAL_DEFENCE == 48
            and stats.MAGICAL_ATTACK == 4
            and stats.MAGICAL_DEFENCE == 39,
        "Marauder source attack and defence stats are exact"
    )
    check(
        stats.ACCURACY_COMBAT == 38
            and stats.EVASION_RATE == 38
            and stats.CRITICAL_RATE == 418
            and stats.MAGICAL_CRITICAL_RATE == 8,
        "Marauder source accuracy/evasion/critical stats are exact"
    )
end

--[[
Checks the pinned standard Wolf source record and C4 animal race.

Args:
    None.

Returns:
    nil: Confirms exact source ID, race and derived combat values.
]]
local function check_wolf()
    local boundary = assert(Reference.get("Wolf"))
    local stats = boundary.SourceStatCandidate

    check(
        boundary.SourceNpcId == 525
            and boundary.Level == 4
            and boundary.SourceNpcRace == "ANIMAL"
            and boundary.SourceRaceSkillId == 4293
            and boundary.SourceWitBonus == 1,
        "creative Wolf maps to the reviewed C4 animal source record"
    )
    check(
        stats.MAX_HP == 107
            and stats.MAX_MP == 75
            and stats.PHYSICAL_ATTACK == 12
            and stats.PHYSICAL_DEFENCE == 46,
        "Wolf source physical/resource stats are exact"
    )
    check(
        stats.MAGICAL_ATTACK == 4
            and stats.MAGICAL_DEFENCE == 37
            and stats.RUN_SPEED == 102
            and stats.WALK_SPEED == 24,
        "Wolf source magic and movement stats are exact"
    )
    check(
        stats.ACCURACY_COMBAT == 37
            and stats.EVASION_RATE == 37
            and stats.CRITICAL_RATE == 418,
        "Wolf source accuracy/evasion/critical stats are exact"
    )
end

--[[
Checks server Model identity is required for a live NPC boundary.

Args:
    None.

Returns:
    nil: Confirms supported, missing, unsupported and dead paths.
]]
local function check_server_boundary()
    local enemy = enemy_fixture("Wolf")
    local boundary = assert(
        BoundaryService.for_model(enemy)
    )

    check(
        boundary.CreativeArchetypeId == "Wolf"
            and boundary.SourceTargetKind == "Npc"
            and boundary.SourceCombatPrerequisitesReady,
        "live enemy archetype resolves only through server boundary service"
    )

    local missing = enemy_fixture(nil)
    local missing_boundary, missing_reason =
        BoundaryService.for_model(missing)
    check(
        missing_boundary == nil
            and missing_reason
                == "C4NpcSourceArchetypeUnavailable",
        "enemy without server archetype fails closed"
    )

    local unknown = enemy_fixture("UnreviewedEnemy")
    local unknown_boundary, unknown_reason =
        BoundaryService.for_model(unknown)
    check(
        unknown_boundary == nil
            and unknown_reason == "UnreviewedC4NpcArchetype",
        "unreviewed creative enemy fails closed"
    )

    local humanoid =
        enemy:FindFirstChildOfClass("Humanoid")
    assert(humanoid)
    humanoid.Health = 0

    local dead_boundary, dead_reason =
        BoundaryService.for_model(enemy)
    check(
        dead_boundary == nil
            and dead_reason == "C4NpcSourceOwnerUnavailable",
        "dead enemy cannot mint a new live source boundary"
    )

    enemy:Destroy()
    missing:Destroy()
    unknown:Destroy()
end

--[[
Runs C4 NPC source-boundary acceptance.

Args:
    None.

Returns:
    nil: Prints bounded source-only NPC evidence.
]]
local function main()
    check_marauder()
    check_wolf()
    check_server_boundary()

    local capability = BoundaryService.capability()
    check(
        capability.ServerModelOwned
            and capability.DisplayNameUsedForMapping == false
            and capability.ClientStatsAccepted == false
            and #capability.SupportedArchetypes == 2,
        "NPC boundary exposes server-only mapping capability"
    )

    print((
        "[C4 NPC Source Boundary] SOURCE_NPC_PASS: %d assertions "
            .. "marauder=true wolf=true server_owned=true"
    ):format(checks))
end

main()
