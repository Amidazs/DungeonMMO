--!strict
-- Server-only Roblox world resolver for Dwarf Spoil/Sweep source skills.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local WorldScale = require(
    ReplicatedStorage.Core.Shared.C4WorldScaleReference
)
local NpcBoundaries = require(
    ServerScriptService.Core.Services.C4NpcSourceBoundaryService
)

local C4DwarfSalvageWorldResolver = {}
C4DwarfSalvageWorldResolver.__index =
    C4DwarfSalvageWorldResolver

local ENCOUNTER_ATTRIBUTE = "DungeonEncounterId"

--[[
Returns a living server-owned character model for one salvage caster.

Args:
    owner (any): Player or player-like server object.

Returns:
    Model?: Current living caster character.
]]
local function owner_model(owner: any): Model?
    local model = owner and owner.Character

    if typeof(model) ~= "Instance"
        or not model:IsA("Model")
        or not model:IsDescendantOf(Workspace)
    then
        return nil
    end

    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return nil
    end

    return model
end

--[[
Returns the authoritative root part used for C4 world-distance checks.

Args:
    model (Model): Server-owned character or NPC model.

Returns:
    BasePart?: Humanoid root when available.
]]
local function root_part(model: Model): BasePart?
    local root = model:FindFirstChild("HumanoidRootPart")
    return if root and root:IsA("BasePart")
        then root
        else nil
end

--[[
Approximates the source engine's horizontal collision radius from the root.

C4 cast movement adds both actors' collision radii to castRange before the
inside-radius check. Roblox has no directly equivalent per-template value, so
the authoritative HumanoidRootPart horizontal half-extent is used.

Args:
    root (BasePart): Server-owned HumanoidRootPart.

Returns:
    number: Horizontal collision radius in Roblox studs.
]]
local function collision_radius_studs(root: BasePart): number
    return math.max(root.Size.X, root.Size.Z) * 0.5
end

--[[
Returns horizontal X/Z separation in Roblox studs.

Args:
    left (BasePart): First authoritative root.
    right (BasePart): Second authoritative root.

Returns:
    number: Planar root separation in studs.
]]
local function horizontal_distance(
    left: BasePart,
    right: BasePart
): number
    local offset = left.Position - right.Position
    return Vector2.new(offset.X, offset.Z).Magnitude
end

--[[
Returns the nearest ancestor humanoid model for an overlap-query part.

Args:
    instance (Instance): Workspace descendant returned by the query.

Returns:
    Model?: Owning humanoid model, otherwise nil.
]]
local function humanoid_model(instance: Instance): Model?
    local current: Instance? = instance

    while current and current ~= Workspace do
        if current:IsA("Model")
            and current:FindFirstChildOfClass("Humanoid")
        then
            return current
        end
        current = current.Parent
    end

    return nil
end

--[[
Creates the Dwarf salvage world resolver.

Args:
    source_units_per_stud_provider (() -> number?)?: Optional current runtime
        scale provider. Defaults to the reviewed launch mapping.

Returns:
    any: Server-only spatial target authority.
]]
function C4DwarfSalvageWorldResolver.new(
    source_units_per_stud_provider: (() -> number?)?
): any
    local provider = source_units_per_stud_provider
        or function(): number
            return WorldScale.source_units_per_stud()
        end

    assert(
        type(provider) == "function",
        "Dwarf salvage world resolver requires scale provider"
    )

    return setmetatable({
        _source_units_per_stud_provider = provider,
    }, C4DwarfSalvageWorldResolver)
end

--[[
Resolves the current positive source-units-per-stud scale.

Args:
    self (any): Resolver instance.

Returns:
    (number?, string?): Current scale or stable denial reason.
]]
function C4DwarfSalvageWorldResolver:_scale(): (number?, string?)
    local scale = self._source_units_per_stud_provider()

    if type(scale) ~= "number"
        or scale ~= scale
        or scale <= 0
        or scale >= math.huge
    then
        return nil, "C4SalvageSpatialScaleUnconfigured"
    end

    return scale, nil
end

--[[
Checks one living or dead source-reviewed Dungeon NPC cast target.

The source C4 AI adds caster and target collision radii to castRange. This
resolver mirrors that contract with HumanoidRootPart horizontal half-extents
before comparing planar distance.

Args:
    owner (any): Server-owned salvage caster.
    target (any): Living NPC or spoiled corpse target.
    source_range (number): Exact source castRange.

Returns:
    (boolean, string?): Eligibility or strict denial reason.
]]
function C4DwarfSalvageWorldResolver:validate_target(
    owner: any,
    target: any,
    source_range: number
): (boolean, string?)
    if type(source_range) ~= "number"
        or source_range ~= source_range
        or source_range < 0
        or source_range >= math.huge
    then
        return false, "InvalidC4SalvageSourceRange"
    end

    local caster = owner_model(owner)
    if not caster then
        return false, "C4SalvageCasterUnavailable"
    end
    if typeof(target) ~= "Instance" or not target:IsA("Model") then
        return false, "C4SalvageTargetUnavailable"
    end

    local humanoid = target:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return false, "C4SalvageTargetUnavailable"
    end

    local boundary, boundary_reason = if humanoid.Health > 0
        then NpcBoundaries.for_model(target)
        else NpcBoundaries.for_corpse_model(target)
    if not boundary then
        return false, boundary_reason
            or "C4SalvageTargetSourceBoundaryUnavailable"
    end

    local caster_root = root_part(caster)
    local target_root = root_part(target)
    if not caster_root or not target_root then
        return false, "C4SalvageRootUnavailable"
    end

    local scale, scale_reason = self:_scale()
    if not scale then
        return false, scale_reason
    end

    local collision_source = (
        collision_radius_studs(caster_root)
        + collision_radius_studs(target_root)
    ) * scale
    local distance_source =
        horizontal_distance(caster_root, target_root) * scale

    if distance_source > source_range + collision_source then
        return false, "C4SalvageTargetOutOfRange"
    end

    return true, nil
end

--[[
Collects source-reviewed same-encounter living NPCs for Spoil Festival.

TARGET_AREA remains caster-centred, matching the accepted C4 source executor.
The selected primary is always first; other NPCs must share its server-owned
Dungeon encounter and fall inside skillRadius after world-scale conversion.

Args:
    owner (any): Server-owned salvage caster.
    primary (any): Selected living source-reviewed NPC.
    source_radius (number): Exact source skillRadius.

Returns:
    ({Model}?, string?): Ordered Festival targets or denial reason.
]]
function C4DwarfSalvageWorldResolver:area_targets(
    owner: any,
    primary: any,
    source_radius: number
): ({Model}?, string?)
    if type(source_radius) ~= "number"
        or source_radius ~= source_radius
        or source_radius <= 0
        or source_radius >= math.huge
    then
        return nil, "InvalidC4SalvageSourceRadius"
    end

    local caster = owner_model(owner)
    if not caster then
        return nil, "C4SalvageCasterUnavailable"
    end
    if typeof(primary) ~= "Instance"
        or not primary:IsA("Model")
    then
        return nil, "C4SalvageTargetUnavailable"
    end

    local reviewed_primary, primary_reason =
        NpcBoundaries.for_model(primary)
    if not reviewed_primary then
        return nil, primary_reason
            or "C4SalvageTargetSourceBoundaryUnavailable"
    end

    local caster_root = root_part(caster)
    if not caster_root then
        return nil, "C4SalvageRootUnavailable"
    end

    local encounter_id = primary:GetAttribute(ENCOUNTER_ATTRIBUTE)
    if type(encounter_id) ~= "string" or encounter_id == "" then
        return nil, "C4SalvageEncounterUnavailable"
    end

    local scale, scale_reason = self:_scale()
    if not scale then
        return nil, scale_reason
    end
    local radius_studs = source_radius / scale

    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {caster}
    params.RespectCanCollide = false

    local targets: {Model} = {primary}
    local seen: {[Model]: boolean} = {
        [primary] = true,
    }

    for _, part in ipairs(Workspace:GetPartBoundsInRadius(
        caster_root.Position,
        radius_studs,
        params
    )) do
        local candidate = humanoid_model(part)
        if not candidate or seen[candidate] then
            continue
        end
        seen[candidate] = true

        if candidate:GetAttribute(ENCOUNTER_ATTRIBUTE)
            ~= encounter_id
        then
            continue
        end

        local boundary = NpcBoundaries.for_model(candidate)
        if boundary then
            table.insert(targets, candidate)
        end
    end

    return targets, nil
end

--[[
Returns detached resolver capability evidence.

Args:
    self (any): Resolver instance.

Returns:
    any: Current world-scale and safety guarantees.
]]
function C4DwarfSalvageWorldResolver:capability(): any
    local scale = self:_scale()

    return {
        Available = true,
        SourceUnitsPerStud = scale,
        SpatialScaleConfigured = scale ~= nil,
        CollisionRadiusAdjustedCastRange = true,
        HorizontalCastRange = true,
        CasterCentredFestivalArea = true,
        SameEncounterFestivalTargets = true,
        SourceNpcBoundaryRequired = true,
        ClientAuthority = false,
    }
end

return C4DwarfSalvageWorldResolver
