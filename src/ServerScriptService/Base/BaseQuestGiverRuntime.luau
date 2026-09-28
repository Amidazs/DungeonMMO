--!strict
-- Physical Base quest-giver placeholders bound to trusted Adventure state.

local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")

local QuestDefinitions = require(
    Shared:WaitForChild("QuestDefinitions")
)
local QuestGiverDefinitions = require(
    Shared:WaitForChild("QuestGiverDefinitions")
)

local Runtime = {}
Runtime.__index = Runtime

local FOLDER_NAME = "DungeonMMOQuestGivers"
local MIN_GIVER_DISTANCE = 30
local GROUND_RAY_HEIGHT = 70
local GROUND_RAY_DEPTH = 180
local MIN_GROUND_NORMAL_Y = 0.72
local MAX_GROUND_SURFACES = 12
local GROUND_STEP_EPSILON = 0.1
local PATH_TARGET_LIFT = 0.5
local APPROACH_HEIGHT = 6
local APPROACH_RAY_LIFT = 0.25
local SKIN_COLOR = Color3.fromRGB(196, 157, 119)

local SEARCH_RADII = table.freeze({
    0,
    12,
    24,
    36,
})

--[[
Creates or returns the generated quest-giver presentation folder.

Args:
    root (Instance): Workspace-like parent for generated placeholders.

Returns:
    Folder: Stable quest-giver presentation folder.
]]
local function ensure_folder(root: Instance): Folder
    local existing = root:FindFirstChild(FOLDER_NAME)
    if existing and existing:IsA("Folder") then
        return existing
    elseif existing then
        existing:Destroy()
    end

    local folder = Instance.new("Folder")
    folder.Name = FOLDER_NAME
    folder.Parent = root
    return folder
end

--[[
Adds a readable world-space label to one humanoid placeholder.

Args:
    head (BasePart): Humanoid head carrying the label.
    speaker (string): Player-facing role name.

Returns:
    nil: Creates the label when one is not already present.
]]
local function ensure_label(
    head: BasePart,
    speaker: string
)
    if head:FindFirstChild("QuestGiverLabel") then
        return
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "QuestGiverLabel"
    billboard.Size = UDim2.fromOffset(220, 44)
    billboard.StudsOffset = Vector3.new(0, 2.1, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 0.25
    label.TextScaled = true
    label.TextWrapped = true
    label.Text = speaker
    label.Parent = billboard
end

--[[
Creates or returns the interaction prompt for one quest giver.

Args:
    root_part (BasePart): Invisible humanoid interaction root.
    speaker (string): Player-facing role name.

Returns:
    ProximityPrompt: Stable talk prompt.
]]
local function ensure_prompt(
    root_part: BasePart,
    speaker: string
): ProximityPrompt
    local existing = root_part:FindFirstChild("QuestGiverPrompt")
    if existing and existing:IsA("ProximityPrompt") then
        return existing
    end

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "QuestGiverPrompt"
    prompt.ActionText = "Talk"
    prompt.ObjectText = speaker
    prompt.HoldDuration = 0.1
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = root_part
    return prompt
end

--[[
Creates one anchored decorative part for a placeholder NPC.

Args:
    model (Model): NPC model receiving the part.
    name (string): Stable part name.
    size (Vector3): Unscaled part size.
    color (Color3): Part color.
    base_cframe (CFrame): NPC floor/orientation transform.
    local_cframe (CFrame): Local unscaled transform.
    scale (number): NPC scale multiplier.
    shape (Enum.PartType?): Optional primitive shape.

Returns:
    BasePart: Created decorative body part.
]]
local function create_part(
    model: Model,
    name: string,
    size: Vector3,
    color: Color3,
    base_cframe: CFrame,
    local_cframe: CFrame,
    scale: number,
    shape: Enum.PartType?
): BasePart
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size * scale
    part.Color = color
    part.Material = Enum.Material.SmoothPlastic
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = true
    part.Shape = shape or Enum.PartType.Block

    local position = local_cframe.Position * scale
    local rotation = local_cframe - local_cframe.Position
    part.CFrame = base_cframe
        * CFrame.new(position)
        * rotation
    part.Parent = model
    return part
end

--[[
Adds simple role-specific silhouette details to one humanoid placeholder.

Args:
    model (Model): NPC receiving decorative role details.
    definition (any): Quest-giver appearance definition.
    base_cframe (CFrame): NPC floor/orientation transform.
    scale (number): NPC scale multiplier.

Returns:
    nil: Adds non-colliding placeholder accessories.
]]
local function add_role_details(
    model: Model,
    definition: any,
    base_cframe: CFrame,
    scale: number
)
    local accent = definition.AccentColor
    local clothing = definition.ClothingColor
    local style = definition.Style

    if style == "Keeper" then
        create_part(
            model,
            "Staff",
            Vector3.new(0.28, 5.5, 0.28),
            Color3.fromRGB(103, 73, 46),
            base_cframe,
            CFrame.new(2.0, 2.75, 0),
            scale,
            nil
        )
        create_part(
            model,
            "StaffGem",
            Vector3.new(0.65, 0.65, 0.65),
            accent,
            base_cframe,
            CFrame.new(2.0, 5.65, 0),
            scale,
            Enum.PartType.Ball
        )
    elseif style == "Hunter" then
        create_part(
            model,
            "Quiver",
            Vector3.new(1.0, 2.6, 0.55),
            clothing,
            base_cframe,
            CFrame.new(0.7, 3.6, 0.78)
                * CFrame.Angles(0, 0, math.rad(-18)),
            scale,
            nil
        )
    elseif style == "Captain" then
        for _, side in ipairs({-1, 1}) do
            create_part(
                model,
                "ShoulderGuard" .. tostring(side),
                Vector3.new(0.95, 0.45, 1.35),
                accent,
                base_cframe,
                CFrame.new(side * 1.5, 4.25, 0),
                scale,
                nil
            )
        end
    elseif style == "Archivist" then
        create_part(
            model,
            "Robe",
            Vector3.new(2.35, 2.7, 1.35),
            clothing,
            base_cframe,
            CFrame.new(0, 1.45, 0),
            scale,
            nil
        )
    elseif style == "Warden" then
        create_part(
            model,
            "Helmet",
            Vector3.new(2.05, 0.6, 2.05),
            accent,
            base_cframe,
            CFrame.new(0, 6.25, 0),
            scale,
            nil
        )
    elseif style == "Pathfinder" then
        create_part(
            model,
            "Backpack",
            Vector3.new(1.8, 2.3, 0.75),
            clothing,
            base_cframe,
            CFrame.new(0, 3.6, 0.88),
            scale,
            nil
        )
    elseif style == "Surveyor" then
        create_part(
            model,
            "SurveyPack",
            Vector3.new(1.7, 2.0, 0.7),
            accent,
            base_cframe,
            CFrame.new(0, 3.5, 0.88),
            scale,
            nil
        )
    elseif style == "Quartermaster" then
        create_part(
            model,
            "Apron",
            Vector3.new(1.65, 2.25, 0.18),
            accent,
            base_cframe,
            CFrame.new(0, 3.1, -0.68),
            scale,
            nil
        )
    end
end

--[[
Builds a recognizable humanoid placeholder rather than one solid block.

Args:
    folder (Folder): Generated quest-giver parent.
    ground_position (Vector3): Walkable floor point for the NPC.
    facing_target (Vector3): Point the NPC should face.
    source_anchor_id (string): Resolved semantic anchor identifier.
    definition (any): Quest-giver definition.
    path_waypoint_count (number): Validated path waypoint count.

Returns:
    Model: Created humanoid placeholder model.
    BasePart: Invisible interaction root.
]]
local function create_humanoid_giver(
    folder: Folder,
    ground_position: Vector3,
    facing_target: Vector3,
    source_anchor_id: string,
    definition: any,
    path_waypoint_count: number,
    walkable: boolean,
    approach_clear: boolean
): (Model, BasePart)
    local existing = folder:FindFirstChild(definition.Id)
    if existing then
        existing:Destroy()
    end

    local scale = tonumber(definition.Scale) or 1
    local look_target = Vector3.new(
        facing_target.X,
        ground_position.Y,
        facing_target.Z
    )
    if (look_target - ground_position).Magnitude < 0.5 then
        look_target = ground_position + Vector3.new(0, 0, -1)
    end

    local base_cframe = CFrame.lookAt(
        ground_position,
        look_target
    )

    local model = Instance.new("Model")
    model.Name = definition.Id
    model:SetAttribute(
        "DungeonMMOQuestGiverSourceAnchor",
        source_anchor_id
    )
    model:SetAttribute(
        "DungeonMMOQuestGiverId",
        definition.Id
    )
    model:SetAttribute(
        "DungeonMMOQuestSpeaker",
        definition.Speaker
    )
    model:SetAttribute(
        "DungeonMMOQuestGiverWalkable",
        walkable
    )
    model:SetAttribute(
        "DungeonMMOQuestGiverPathWaypoints",
        path_waypoint_count
    )
    model.Parent = folder

    local root_part = create_part(
        model,
        "HumanoidRootPart",
        Vector3.new(2, 2, 1),
        Color3.new(1, 1, 1),
        base_cframe,
        CFrame.new(0, 3, 0),
        scale,
        nil
    )
    root_part.Transparency = 1
    root_part.CanQuery = true
    model.PrimaryPart = root_part

    create_part(
        model,
        "Torso",
        Vector3.new(2.35, 2.5, 1.2),
        definition.ClothingColor,
        base_cframe,
        CFrame.new(0, 3.45, 0),
        scale,
        nil
    )

    local head = create_part(
        model,
        "Head",
        Vector3.new(1.85, 1.85, 1.85),
        SKIN_COLOR,
        base_cframe,
        CFrame.new(0, 5.65, 0),
        scale,
        Enum.PartType.Ball
    )

    for _, side in ipairs({-1, 1}) do
        create_part(
            model,
            "Arm" .. tostring(side),
            Vector3.new(0.75, 2.45, 0.75),
            SKIN_COLOR,
            base_cframe,
            CFrame.new(side * 1.55, 3.4, 0),
            scale,
            nil
        )
        create_part(
            model,
            "Leg" .. tostring(side),
            Vector3.new(0.95, 2.55, 0.95),
            definition.ClothingColor,
            base_cframe,
            CFrame.new(side * 0.62, 1.28, 0),
            scale,
            nil
        )
    end

    create_part(
        model,
        "Belt",
        Vector3.new(2.45, 0.32, 1.3),
        definition.AccentColor,
        base_cframe,
        CFrame.new(0, 2.55, 0),
        scale,
        nil
    )

    add_role_details(
        model,
        definition,
        base_cframe,
        scale
    )

    local humanoid = Instance.new("Humanoid")
    humanoid.Name = "Humanoid"
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    humanoid.HealthDisplayDistance = 0
    humanoid.NameDisplayDistance = 0
    humanoid.AutoRotate = false
    humanoid.Parent = model

    ensure_label(head, definition.Speaker)
    ensure_prompt(root_part, definition.Speaker)

    return model, root_part
end

--[[
Finds collidable floor candidates beneath a desired X/Z position.

The authored lobby contains decorative non-colliding meshes above its real
collision floor. Candidates are therefore restricted to collidable surfaces
and sorted by vertical proximity to the semantic anchor height.

Args:
    folder (Folder): Generated NPC folder to ignore.
    desired (Vector3): Desired world-space position.

Returns:
    {Vector3}: Nearest-height walkable-looking floor candidates.
]]
local function ground_candidates(
    folder: Folder,
    desired: Vector3
): {Vector3}
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {folder}
    params.IgnoreWater = false
    params.RespectCanCollide = true

    local top_y = desired.Y + GROUND_RAY_HEIGHT
    local bottom_y = top_y - GROUND_RAY_DEPTH
    local ray_y = top_y
    local candidates = {}

    for _ = 1, MAX_GROUND_SURFACES do
        local remaining_depth = ray_y - bottom_y
        if remaining_depth <= 0 then
            break
        end

        local result = Workspace:Raycast(
            Vector3.new(desired.X, ray_y, desired.Z),
            Vector3.new(0, -remaining_depth, 0),
            params
        )
        if not result then
            break
        end

        if result.Normal.Y >= MIN_GROUND_NORMAL_Y then
            table.insert(candidates, result.Position)
        end

        ray_y = result.Position.Y - GROUND_STEP_EPSILON
    end

    table.sort(candidates, function(a: Vector3, b: Vector3)
        return math.abs(a.Y - desired.Y)
            < math.abs(b.Y - desired.Y)
    end)

    return candidates
end

--[[
Checks precise vertical headroom above one candidate floor point.

Pathfinding already validates horizontal agent clearance using the configured
radius and height. A bounding-box overlap test is deliberately avoided here
because large irregular lobby collision meshes have bounding boxes that cover
open walkable space.

Args:
    folder (Folder): Generated NPC folder to ignore.
    ground_position (Vector3): Candidate floor point.

Returns:
    boolean: True when the candidate has clear vertical headroom.
]]
local function approach_space_clear(
    folder: Folder,
    ground_position: Vector3
): boolean
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {folder}
    params.RespectCanCollide = true

    local origin = ground_position + Vector3.new(
        0,
        APPROACH_RAY_LIFT,
        0
    )
    local result = Workspace:Raycast(
        origin,
        Vector3.new(
            0,
            APPROACH_HEIGHT - APPROACH_RAY_LIFT,
            0
        ),
        params
    )

    return result == nil
end

--[[
Validates Roblox navigation from the spawn area to one NPC position.

Args:
    start_position (Vector3): Player-spawn navigation origin.
    target_position (Vector3): Candidate NPC floor point.

Returns:
    boolean: True when Roblox computes a complete walkable path.
    number: Number of waypoints in the successful path.
]]
local function validate_path(
    start_position: Vector3,
    target_position: Vector3
): (boolean, number)
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentCanClimb = false,
        WaypointSpacing = 6,
    })

    local ok = pcall(function()
        path:ComputeAsync(
            start_position,
            target_position + Vector3.new(
                0,
                PATH_TARGET_LIFT,
                0
            )
        )
    end)

    if not ok or path.Status ~= Enum.PathStatus.Success then
        return false, 0
    end

    local waypoints = path:GetWaypoints()
    return #waypoints >= 2, #waypoints
end

--[[
Returns whether one candidate stays well clear of already placed givers.

Args:
    placed_positions ({Vector3}): Existing giver floor positions.
    candidate (Vector3): Candidate floor position.

Returns:
    boolean: True when the minimum giver spacing is preserved.
]]
local function giver_spacing_valid(
    placed_positions: {Vector3},
    candidate: Vector3
): boolean
    for _, position in ipairs(placed_positions) do
        if (position - candidate).Magnitude < MIN_GIVER_DISTANCE then
            return false
        end
    end

    return true
end

--[[
Builds deterministic search offsets around a desired role location.

Args:
    None.

Returns:
    {Vector3}: Horizontal offsets in nearest-first search order.
]]
local function placement_search_offsets(): {Vector3}
    local offsets = {}

    for _, radius in ipairs(SEARCH_RADII) do
        if radius == 0 then
            table.insert(offsets, Vector3.zero)
        else
            for angle = 0, 315, 45 do
                local radians = math.rad(angle)
                table.insert(
                    offsets,
                    Vector3.new(
                        math.cos(radians) * radius,
                        0,
                        math.sin(radians) * radius
                    )
                )
            end
        end
    end

    return offsets
end

--[[
Finds a spaced, obstacle-free and navigable NPC placement.

Args:
    folder (Folder): Generated NPC folder.
    spawn_position (Vector3): Player-spawn navigation origin.
    source_anchor (BasePart): Semantic role anchor.
    definition (any): Quest-giver definition.
    placed_positions ({Vector3}): Already accepted giver positions.

Returns:
    Vector3: Walkable NPC floor position.
    number: Successful path waypoint count.
]]
local function resolve_placement(
    folder: Folder,
    spawn_position: Vector3,
    source_anchor: BasePart,
    definition: any,
    placed_positions: {Vector3},
    require_walkable: boolean
): (Vector3, number, boolean, boolean)
    local desired = source_anchor.Position + definition.Offset

    for _, search_offset in ipairs(
        placement_search_offsets()
    ) do
        local candidate_position =
            desired + search_offset
        local grounds = ground_candidates(
            folder,
            candidate_position
        )

        for _, ground in ipairs(grounds) do
            if giver_spacing_valid(
                placed_positions,
                ground
            ) and approach_space_clear(folder, ground)
            then
                local walkable, waypoint_count = validate_path(
                    spawn_position,
                    ground
                )
                if walkable then
                    return ground, waypoint_count, true, true
                elseif not require_walkable then
                    return ground, 0, false, true
                end
            end
        end
    end

    if not require_walkable then
        local fallback = source_anchor.Position
            + definition.Offset
        return fallback, 0, false, false
    end

    error(
        "No walkable quest-giver placement for "
            .. tostring(definition.Id)
    )
end

--[[
Returns the preferred conversation for one giver and character state.

Args:
    definition (any): Quest-giver definition.
    character (any): Selected authoritative character.
    snapshot (any): Current QuestService snapshot.

Returns:
    string?: Selected quest identifier.
    string?: Start, Review, Claim or Complete mode.
]]
local function select_conversation(
    definition: any,
    character: any,
    snapshot: any
): (string?, string?)
    local active = type(snapshot.Active) == "table"
        and snapshot.Active
        or {}
    local completed = type(snapshot.Completed) == "table"
        and snapshot.Completed
        or {}

    for _, quest_id in ipairs(definition.QuestIds) do
        local state = active[quest_id]
        if type(state) == "table" and state.Ready == true then
            return quest_id, "Claim"
        end
    end

    for _, quest_id in ipairs(definition.QuestIds) do
        if type(active[quest_id]) == "table" then
            return quest_id, "Review"
        end
    end

    for _, quest_id in ipairs(definition.QuestIds) do
        local quest = QuestDefinitions.get(quest_id)
        if quest
            and completed[quest_id] ~= true
            and QuestDefinitions.is_character_eligible(
                character,
                quest
            )
        then
            return quest_id, "Start"
        end
    end

    for index = #definition.QuestIds, 1, -1 do
        local quest_id = definition.QuestIds[index]
        if completed[quest_id] == true then
            return quest_id, "Complete"
        end
    end

    return nil, nil
end

--[[
Opens the best server-selected conversation for one physical quest giver.

Args:
    player (Player): Authenticated interacting player.
    definition (any): Quest-giver presentation definition.
    anchor (BasePart): Physical giver used for contextual client distance.

Returns:
    nil: Sends only presentation state to the caller.
]]
function Runtime:open(
    player: Player,
    definition: any,
    anchor: BasePart
)
    if not self._is_ready(player) then
        return
    end

    local character = self._profiles:get_character(player.UserId)
    local snapshot = self._quests:build_snapshot(player.UserId)

    if not character or snapshot.ok ~= true then
        return
    end

    local quest_id, mode = select_conversation(
        definition,
        character,
        snapshot
    )
    if not quest_id or not mode then
        self._remote:FireClient(player, {
            ok = false,
            reason = "QuestGiverNoConversation",
            GiverId = definition.Id,
            Anchor = anchor,
        })
        return
    end

    self._remote:FireClient(player, {
        ok = true,
        QuestId = quest_id,
        Mode = mode,
        GiverId = definition.Id,
        Anchor = anchor,
    })
end

--[[
Creates physical quest givers and binds their trusted talk prompts.

Args:
    options (any): Workspace, environment, profile, quest, remote and
        readiness dependencies.

Returns:
    any: Runtime retained by prompt connections.
]]
function Runtime.attach(options: any): any
    assert(options.root ~= nil)
    assert(options.environment ~= nil)
    assert(options.profiles ~= nil)
    assert(options.quests ~= nil)
    assert(options.remote ~= nil)
    assert(type(options.is_ready) == "function")

    local spawn_anchor = assert(
        options.environment:get("Base.PlayerSpawn"),
        "Quest giver runtime requires Base.PlayerSpawn"
    )

    local self = setmetatable({
        _profiles = options.profiles,
        _quests = options.quests,
        _remote = options.remote,
        _is_ready = options.is_ready,
    }, Runtime)

    local folder = ensure_folder(options.root)
    local placed_positions = {}
    local environment_mode = options.root:GetAttribute(
        "DungeonMMOResolvedEnvironmentMode"
    )
    local require_walkable =
        environment_mode ~= "Synthetic"

    for _, definition in ipairs(
        QuestGiverDefinitions.all()
    ) do
        local source_anchor_id = definition.AnchorId
        local source_anchor =
            options.environment:get(source_anchor_id)

        if not source_anchor
            and type(definition.FallbackAnchorId) == "string"
        then
            source_anchor_id = definition.FallbackAnchorId
            source_anchor = options.environment:get(
                source_anchor_id
            )
        end

        assert(
            source_anchor ~= nil,
            "Quest giver anchor missing: "
                .. tostring(definition.AnchorId)
        )

        local ground_position,
            waypoint_count,
            walkable,
            approach_clear = resolve_placement(
                folder,
                spawn_anchor.Position,
                source_anchor,
                definition,
                placed_positions,
                require_walkable
            )

        local model, interaction_root =
            create_humanoid_giver(
                folder,
                ground_position,
                source_anchor.Position,
                source_anchor_id,
                definition,
                waypoint_count,
                walkable,
                approach_clear
            )

        table.insert(
            placed_positions,
            ground_position
        )

        local prompt = assert(
            interaction_root:FindFirstChild(
                "QuestGiverPrompt"
            )
        ) :: ProximityPrompt

        prompt.Triggered:Connect(function(player: Player)
            self:open(
                player,
                definition,
                interaction_root
            )
        end)

        model:SetAttribute(
            "DungeonMMOQuestGiverApproachClear",
            approach_clear
        )
    end

    return self
end

return table.freeze(Runtime)
