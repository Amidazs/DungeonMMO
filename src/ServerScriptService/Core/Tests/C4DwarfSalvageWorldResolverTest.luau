--!strict
-- Dwarf Spoil/Sweep Roblox world geometry regression.

local ServerScriptService = game:GetService("ServerScriptService")

local Resolver = require(
    ServerScriptService.Core.Services.C4DwarfSalvageWorldResolver
)

local checks = 0
local ENCOUNTER_ID = "DwarfSalvageSpatialTest"

--[[
Counts one salvage-world assertion.

Args:
    valid (boolean): Expected world-authority condition.
    label (string): Diagnostic description for failure.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[Dwarf Salvage World] " .. label)
end

--[[
Creates one humanoid model with an authoritative root part.

Args:
    name (string): Disposable model name.
    position (Vector3): Root world position.
    alive (boolean): Whether the Humanoid starts alive.
    source_reviewed (boolean): Whether the NPC has a reviewed archetype.
    encounter_id (string?): Optional server encounter identifier.

Returns:
    Model: Disposable Workspace model.
]]
local function make_model(
    name: string,
    position: Vector3,
    alive: boolean,
    source_reviewed: boolean,
    encounter_id: string?
): Model
    local model = Instance.new("Model")
    model.Name = name

    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Size = Vector3.new(2, 2, 2)
    root.Anchored = true
    root.CanCollide = false
    root.CFrame = CFrame.new(position)
    root.Parent = model
    model.PrimaryPart = root

    local humanoid = Instance.new("Humanoid")
    humanoid.BreakJointsOnDeath = false
    humanoid.MaxHealth = 100
    humanoid.Health = if alive then 100 else 0
    humanoid.Parent = model

    if source_reviewed then
        model:SetAttribute(
            "DungeonEnemyArchetypeId",
            "Marauder"
        )
    end
    if encounter_id then
        model:SetAttribute(
            "DungeonEncounterId",
            encounter_id
        )
    end

    model.Parent = workspace
    return model
end

--[[
Runs collision-adjusted cast-range and Festival-area checks.

Args:
    None.

Returns:
    nil: Destroys fixtures and prints a stable pass marker.
]]
local function main()
    local owner_model = make_model(
        "TEMP_DwarfSalvageOwner",
        Vector3.new(0, 5, 0),
        true,
        false,
        nil
    )
    local owner = {
        UserId = 956270,
        Character = owner_model,
    }
    local resolver = Resolver.new()

    local close_enemy = make_model(
        "TEMP_CloseSpoilEnemy",
        Vector3.new(4.5, 5, 0),
        true,
        true,
        ENCOUNTER_ID
    )
    local close_ok = resolver:validate_target(
        owner,
        close_enemy,
        40
    )
    check(
        close_ok == true,
        "castRange 40 includes both root collision radii"
    )

    local far_enemy = make_model(
        "TEMP_FarSpoilEnemy",
        Vector3.new(5.2, 5, 0),
        true,
        true,
        ENCOUNTER_ID
    )
    local far_ok, far_reason = resolver:validate_target(
        owner,
        far_enemy,
        40
    )
    check(
        not far_ok
            and far_reason == "C4SalvageTargetOutOfRange",
        "Spoil rejects distance beyond castRange plus collisions"
    )

    local area_inside = make_model(
        "TEMP_FestivalInside",
        Vector3.new(10, 5, 0),
        true,
        true,
        ENCOUNTER_ID
    )
    local area_outside = make_model(
        "TEMP_FestivalOutside",
        Vector3.new(16, 5, 0),
        true,
        true,
        ENCOUNTER_ID
    )
    local other_encounter = make_model(
        "TEMP_FestivalOtherEncounter",
        Vector3.new(8, 5, 0),
        true,
        true,
        "OtherEncounter"
    )
    local unreviewed = make_model(
        "TEMP_FestivalUnreviewed",
        Vector3.new(7, 5, 0),
        true,
        false,
        ENCOUNTER_ID
    )

    local area_targets = assert(resolver:area_targets(
        owner,
        close_enemy,
        200
    ))
    local found = {}
    for _, target in ipairs(area_targets) do
        found[target] = true
    end

    check(
        area_targets[1] == close_enemy,
        "selected Festival primary remains first"
    )
    check(
        found[area_inside] == true,
        "same-encounter NPC inside 200 source radius is included"
    )
    check(
        found[area_outside] ~= true,
        "NPC beyond converted Festival radius is excluded"
    )
    check(
        found[other_encounter] ~= true,
        "different encounter NPC is excluded"
    )
    check(
        found[unreviewed] ~= true,
        "NPC without reviewed source boundary is excluded"
    )

    local corpse = make_model(
        "TEMP_SweepCorpse",
        Vector3.new(3.2, 5, 0),
        false,
        true,
        ENCOUNTER_ID
    )
    local corpse_ok = resolver:validate_target(
        owner,
        corpse,
        20
    )
    check(
        corpse_ok == true,
        "Sweep castRange 20 remains usable with collision radii"
    )

    local far_corpse = make_model(
        "TEMP_FarSweepCorpse",
        Vector3.new(3.6, 5, 0),
        false,
        true,
        ENCOUNTER_ID
    )
    local far_corpse_ok, far_corpse_reason =
        resolver:validate_target(
            owner,
            far_corpse,
            20
        )
    check(
        not far_corpse_ok
            and far_corpse_reason == "C4SalvageTargetOutOfRange",
        "Sweep still rejects corpse beyond collision-adjusted range"
    )

    local capability = resolver:capability()
    check(
        capability.SourceUnitsPerStud == 14
            and capability.CollisionRadiusAdjustedCastRange
            and capability.HorizontalCastRange
            and capability.CasterCentredFestivalArea
            and capability.SameEncounterFestivalTargets
            and capability.SourceNpcBoundaryRequired
            and not capability.ClientAuthority,
        "resolver reports reviewed spatial and authority contract"
    )

    for _, model in ipairs({
        close_enemy,
        far_enemy,
        area_inside,
        area_outside,
        other_encounter,
        unreviewed,
        corpse,
        far_corpse,
        owner_model,
    }) do
        model:Destroy()
    end

    print(
        ("[Dwarf Salvage World] PASS: %d assertions")
            :format(checks)
    )
end

main()
