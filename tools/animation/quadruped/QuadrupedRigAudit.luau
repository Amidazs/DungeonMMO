--!strict
-- Read-only structural inventory of a prospective quadruped master rig.
-- This audit cannot measure skin weights, deformation, paw sliding,
-- anatomical quality, or Roblox Animator compatibility by itself.
local QuadrupedRigAudit = {}

local REQUIRED_ROLES = {
    "Root",
    "Pelvis",
    "Chest",
    "Neck",
    "Head",
    "FrontLeftUpper",
    "FrontLeftLower",
    "FrontLeftPaw",
    "FrontRightUpper",
    "FrontRightLower",
    "FrontRightPaw",
    "HindLeftUpper",
    "HindLeftLower",
    "HindLeftPaw",
    "HindRightUpper",
    "HindRightLower",
    "HindRightPaw",
}

-- Args:
--   root: Instance; ancestor to search.
--   name: string; exact descendant name (not an arbitrary path).
-- Returns:
--   Instance?, number: unique match if present, and total match count.
local function unique_descendant(
    root: Instance,
    name: string
): (Instance?, number)
    local match: Instance? = nil
    local count = 0
    for _, instance in root:GetDescendants() do
        if instance.Name == name then
            match = instance
            count += 1
        end
    end
    return if count == 1 then match else nil, count
end

-- Args:
--   instance: Instance; mapped role object.
-- Returns:
--   Vector3?: world-space role pivot when supported.
local function pivot_of(instance: Instance): Vector3?
    if instance:IsA("Motor6D") then
        local part = instance.Part0
        if part == nil then return nil end
        return (part.CFrame * instance.C0).Position
    end
    if instance:IsA("Attachment") then
        return instance.WorldPosition
    end
    if instance:IsA("BasePart") then
        return instance.Position
    end
    return nil
end

-- Args:
--   rig: Model; imported candidate, NOT a production combat entity.
--   names: {[string]: string}; exact rig-specific instance names
--     keyed by anatomical roles from REQUIRED_ROLES.
-- Returns:
--   {[string]: any}: diagnostic report. 'PassedStructuralGate' never
--   substitutes for visual deformation and real Studio motion tests.
function QuadrupedRigAudit.inspect(
    rig: Model,
    names: {[string]: string}
): {[string]: any}
    assert(rig:IsA("Model"), "Expected a candidate quadruped Model")
    local findings = {}
    local roles: {[string]: any} = {}
    local resolved: {[string]: Instance} = {}
    local allMotors, allBones, meshes = 0, 0, 0
    local animatedParts = 0
    local weldedParts = 0

    for _, instance in rig:GetDescendants() do
        if instance:IsA("Motor6D") then
            allMotors += 1
            if instance.Part0 and instance.Part1 then
                animatedParts += 1
            else
                table.insert(findings, "Disconnected motor: "
                    .. instance:GetFullName())
            end
        elseif instance:IsA("Bone") then
            allBones += 1
        elseif instance:IsA("MeshPart") then
            meshes += 1
        elseif instance:IsA("WeldConstraint") then
            weldedParts += 1
        end
    end

    for _, role in REQUIRED_ROLES do
        local name = names[role]
        if type(name) ~= "string" or name == "" then
            table.insert(findings, "Unmapped anatomical role: " .. role)
            continue
        end
        local instance, matches = unique_descendant(rig, name)
        if matches ~= 1 or instance == nil then
            table.insert(findings, string.format(
                "Role %s names %s (%d matches; expected 1)",
                role, name, matches
            ))
            continue
        end
        local valid = if role == "Root"
            then instance:IsA("BasePart")
            else instance:IsA("Motor6D")
                or instance:IsA("Bone")
                or instance:IsA("Attachment")
        if not valid then
            table.insert(findings, "Unsupported object type for "
                .. role .. ": " .. instance.ClassName)
            continue
        end
        local pivot = pivot_of(instance)
        if pivot == nil then
            table.insert(findings, "No world joint pivot for " .. role)
            continue
        end
        resolved[role] = instance
        roles[role] = {
            Name = instance.Name,
            ClassName = instance.ClassName,
            Position = {pivot.X, pivot.Y, pivot.Z},
        }
    end

    local fourPaws = {
        "FrontLeftPaw", "FrontRightPaw",
        "HindLeftPaw", "HindRightPaw",
    }
    local pawPositions = {}
    for _, role in fourPaws do
        if roles[role] ~= nil then
            table.insert(pawPositions, roles[role].Position[2])
        end
    end
    local pawRange: number? = nil
    if #pawPositions == 4 then
        local minimum = math.min(table.unpack(pawPositions))
        local maximum = math.max(table.unpack(pawPositions))
        pawRange = maximum - minimum
        -- This reports asymmetry but does not presume uneven paws
        -- are invalid for every pose or every animal species.
    end

    if allBones == 0 and animatedParts < 12 then
        table.insert(findings, "No complete four-leg animation rig: "
            .. "candidate may be a welded placeholder")
    end
    if allBones > 0 and meshes == 0 then
        table.insert(findings, "Bones exist without a MeshPart")
    end
    if #pawPositions < 4 then
        table.insert(findings, "Four independently mapped paws required")
    end

    local controller = rig:FindFirstChildWhichIsA(
        "Humanoid", true
    ) or rig:FindFirstChildWhichIsA("AnimationController", true)
    if controller == nil then
        table.insert(findings, "No Humanoid or AnimationController")
    elseif controller:FindFirstChildWhichIsA("Animator") == nil then
        table.insert(findings, "No Animator under animation controller")
    end

    return {
        Model = rig:GetFullName(),
        BoneCount = allBones,
        MotorCount = allMotors,
        ConnectedMotors = animatedParts,
        WeldCount = weldedParts,
        MeshPartCount = meshes,
        Roles = roles,
        PawHeightRange = pawRange,
        Findings = findings,
        PassedStructuralGate = #findings == 0,
        StillRequires = {
            "Visual skin weights and deformation",
            "Anatomical forward/rest axes and joint bend poles",
            "True foot-ground contact at idle and across a gait",
            "Actual Animator replay and round-trip editable backup",
            "Attack timing, impact, recovery and game-camera review",
        },
    }
end

return table.freeze(QuadrupedRigAudit)
