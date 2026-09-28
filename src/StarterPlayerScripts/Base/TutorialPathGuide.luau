--!strict
-- Local-only walkable tutorial trail with iridescent floor guidance.

local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Guide = {}
Guide.__index = Guide

local FOLDER_NAME = "DungeonMMOTutorialGroundGuide"
local MARKER_WIDTH = 0.34
local MARKER_LENGTH = 1.05
local MARKER_HEIGHT = 0.05
local MARKER_SPACING = 3.25
local FLOOR_LIFT = 0.09
local ARROW_SPACING = 13
local PATH_REFRESH_SECONDS = 1
local TARGET_REFRESH_DISTANCE = 1
local HUE_SPEED = 0.025
local HUE_SPREAD = 0.06

--[[
Creates one client-only visual part used by the tutorial trail.

Args:
    parent (Instance): Folder receiving the guide part.
    name (string): Stable visual part name.
    size (Vector3): Part dimensions.
    cframe (CFrame): World-space transform.

Returns:
    Part: Non-colliding neon guide part.
]]
local function create_visual_part(
    parent: Instance,
    name: string,
    size: Vector3,
    cframe: CFrame
): Part
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    part.Material = Enum.Material.Neon
    part.Transparency = 0.28
    part.Parent = parent
    return part
end

--[[
Returns the current character root when available.

Args:
    player (Player): Local player.

Returns:
    BasePart?: Current HumanoidRootPart.
]]
local function character_root(player: Player): BasePart?
    local character = player.Character
    local root = character
        and character:FindFirstChild("HumanoidRootPart")

    return if root and root:IsA("BasePart")
        then root
        else nil
end

--[[
Projects one navigation waypoint onto visible floor geometry.

Args:
    position (Vector3): Navigation waypoint position.
    character (Model?): Character to exclude from the ray.
    folder (Folder): Guide folder to exclude.

Returns:
    Vector3: Floor-adjusted visual position.
]]
local function floor_position(
    position: Vector3,
    character: Model?,
    folder: Folder
): Vector3
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude

    local excluded: {Instance} = {folder}
    if character then
        table.insert(excluded, character)
    end
    params.FilterDescendantsInstances = excluded
    params.RespectCanCollide = true

    local result = Workspace:Raycast(
        position + Vector3.new(0, 6, 0),
        Vector3.new(0, -18, 0),
        params
    )

    if result then
        return result.Position + Vector3.new(
            0,
            FLOOR_LIFT,
            0
        )
    end

    return position + Vector3.new(0, FLOOR_LIFT, 0)
end

--[[
Creates a three-piece floor arrow pointing along a path.

Args:
    parent (Instance): Guide folder.
    position (Vector3): Arrow centre.
    direction_target (Vector3): Forward direction target.
    index (number): Stable visual index.

Returns:
    {BasePart}: Created arrow parts.
]]
local function create_arrow(
    parent: Instance,
    position: Vector3,
    direction_target: Vector3,
    index: number
): {BasePart}
    local flat_target = Vector3.new(
        direction_target.X,
        position.Y,
        direction_target.Z
    )
    if (flat_target - position).Magnitude < 0.1 then
        return {}
    end

    local facing = CFrame.lookAt(position, flat_target)
    local parts = {}

    table.insert(
        parts,
        create_visual_part(
            parent,
            "ArrowShaft" .. tostring(index),
            Vector3.new(0.3, MARKER_HEIGHT, 1.55),
            facing
        )
    )

    local tip = facing * CFrame.new(0, 0, -0.75)

    for _, angle in ipairs({-38, 38}) do
        table.insert(
            parts,
            create_visual_part(
                parent,
                "ArrowWing"
                    .. tostring(index)
                    .. "_"
                    .. tostring(angle),
                Vector3.new(0.26, MARKER_HEIGHT, 1.05),
                tip
                    * CFrame.Angles(
                        0,
                        math.rad(angle),
                        0
                    )
                    * CFrame.new(0, 0, 0.36)
            )
        )
    end

    return parts
end

--[[
Computes a walkable local-player path to the current tutorial target.

Args:
    start_position (Vector3): Player position.
    target_position (Vector3): Tutorial target position.

Returns:
    {PathWaypoint}?: Complete path waypoints when successful.
]]
local function compute_path(
    start_position: Vector3,
    target_position: Vector3
): {PathWaypoint}?
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentCanClimb = true,
        WaypointSpacing = 6,
    })

    local ok = pcall(function()
        path:ComputeAsync(
            start_position,
            target_position
        )
    end)

    if not ok or path.Status ~= Enum.PathStatus.Success then
        return nil
    end

    local waypoints = path:GetWaypoints()
    return if #waypoints >= 2
        then waypoints
        else nil
end

--[[
Clears all rendered trail geometry.

Args:
    self (any): Tutorial guide instance.

Returns:
    nil: Removes local visual parts only.
]]
function Guide:_clear_visuals()
    self._visual_parts = {}

    for _, child in ipairs(self._folder:GetChildren()) do
        child:Destroy()
    end
end

--[[
Renders the current walkable route as an iridescent ribbon and arrows.

Args:
    self (any): Tutorial guide instance.
    waypoints ({PathWaypoint}): Successful navigation path.

Returns:
    nil: Replaces local guide geometry.
]]
function Guide:_render(waypoints: {PathWaypoint})
    self:_clear_visuals()

    local character = self._player.Character
    local raw_positions = {}
    local floor_positions = {}

    for _, waypoint in ipairs(waypoints) do
        table.insert(raw_positions, waypoint.Position)
        table.insert(
            floor_positions,
            floor_position(
                waypoint.Position,
                character,
                self._folder
            )
        )
    end

    self._path_positions = floor_positions

    local distance_to_next_marker = 1.5
    local distance_to_next_arrow = 5
    local marker_index = 0
    local arrow_index = 0

    for index = 1, #raw_positions - 1 do
        local start_position = raw_positions[index]
        local end_position = raw_positions[index + 1]
        local delta = end_position - start_position
        local length = delta.Magnitude

        if length > 0.2 then
            local marker_distance = distance_to_next_marker

            while marker_distance <= length do
                marker_index += 1

                local alpha = marker_distance / length
                local raw_marker = start_position:Lerp(
                    end_position,
                    alpha
                )
                local marker_position = floor_position(
                    raw_marker,
                    character,
                    self._folder
                )
                local flat_target = Vector3.new(
                    end_position.X,
                    marker_position.Y,
                    end_position.Z
                )

                if (
                    flat_target - marker_position
                ).Magnitude >= 0.1
                then
                    local marker = create_visual_part(
                        self._folder,
                        "TrailMarker" .. tostring(marker_index),
                        Vector3.new(
                            MARKER_WIDTH,
                            MARKER_HEIGHT,
                            MARKER_LENGTH
                        ),
                        CFrame.lookAt(
                            marker_position,
                            flat_target
                        )
                    )
                    table.insert(self._visual_parts, marker)
                end

                marker_distance += MARKER_SPACING
            end

            distance_to_next_marker =
                marker_distance - length

            local arrow_distance = distance_to_next_arrow
            while arrow_distance <= length - 0.75 do
                arrow_index += 1

                local alpha = arrow_distance / length
                local raw_arrow = start_position:Lerp(
                    end_position,
                    alpha
                )
                local arrow_position = floor_position(
                    raw_arrow,
                    character,
                    self._folder
                )
                local arrow_parts = create_arrow(
                    self._folder,
                    arrow_position,
                    end_position,
                    arrow_index
                )

                for _, part in ipairs(arrow_parts) do
                    table.insert(self._visual_parts, part)
                end

                arrow_distance += ARROW_SPACING
            end

            distance_to_next_arrow =
                arrow_distance - length
        end
    end
end

--[[
Refreshes the path when player movement or timing requires it.

Args:
    self (any): Tutorial guide instance.

Returns:
    nil: Recomputes and rerenders only when a target is active.
]]
function Guide:_refresh()
    local target = self._target
    local root = character_root(self._player)

    if not target or not root or not target.Parent then
        self:_clear_visuals()
        return
    end

    local target_position = target.Position
    local target_moved = self._last_target_position == nil
        or (
            target_position - self._last_target_position
        ).Magnitude >= TARGET_REFRESH_DISTANCE
    local character_changed =
        self._path_character ~= self._player.Character
    local needs_retry = #self._visual_parts == 0
        or #self._path_positions < 2

    if not target_moved
        and not character_changed
        and not needs_retry
    then
        return
    end

    local waypoints = compute_path(
        root.Position,
        target_position
    )

    if waypoints then
        self._last_target_position = target_position
        self._path_character = self._player.Character
        self:_render(waypoints)
    elseif needs_retry then
        self._last_target_position = nil
        self._path_character = nil
        self._path_positions = {}
        self:_clear_visuals()
    end
end

--[[
Sets the active world target for the tutorial route.

Args:
    target (BasePart?): Physical destination root.

Returns:
    nil: Starts or clears navigation rendering.
]]
function Guide:set_target(target: BasePart?)
    self._target = target
    self._last_target_position = nil
    self._path_character = nil
    self._path_positions = {}
    self:_clear_visuals()

    if target then
        self:_refresh()
    else
        self:_clear_visuals()
    end
end

--[[
Clears the active tutorial route.

Args:
    None.

Returns:
    nil: Removes all guide geometry.
]]
function Guide:clear()
    self:set_target(nil)
end

--[[
Destroys the local guide and stops its update loops.

Args:
    None.

Returns:
    nil: Releases all local presentation resources.
]]
function Guide:destroy()
    self._alive = false
    self:_clear_visuals()
    self._folder:Destroy()
end

--[[
Creates a dynamic tutorial path guide for one local player.

Args:
    player (Player): Local player whose movement drives the route.

Returns:
    any: New guide instance.
]]
function Guide.new(player: Player): any
    local existing = Workspace:FindFirstChild(FOLDER_NAME)
    if existing then
        existing:Destroy()
    end

    local folder = Instance.new("Folder")
    folder.Name = FOLDER_NAME
    folder.Parent = Workspace

    local self = setmetatable({
        _player = player,
        _folder = folder,
        _target = nil,
        _visual_parts = {},
        _path_positions = {},
        _last_target_position = nil,
        _path_character = nil,
        _alive = true,
    }, Guide)

    task.spawn(function()
        while self._alive do
            self:_refresh()
            task.wait(PATH_REFRESH_SECONDS)
        end
    end)

    RunService.RenderStepped:Connect(function()
        if not self._alive then
            return
        end

        local base_hue = (
            os.clock() * HUE_SPEED
        ) % 1

        for index, part in ipairs(
            self._visual_parts
        ) do
            if part.Parent then
                local hue = (
                    base_hue
                    + index
                        / math.max(
                            #self._visual_parts,
                            1
                        )
                        * HUE_SPREAD
                ) % 1
                part.Color = Color3.fromHSV(
                    hue,
                    0.62,
                    1
                )
            end
        end
    end)

    return self
end

return Guide
