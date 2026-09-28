--!strict
-- Local-only tutorial route with fluid player-relative floor guidance.

local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Guide = {}
Guide.__index = Guide

local FOLDER_NAME = "DungeonMMOTutorialGroundGuide"

local MARKER_WIDTH = 0.34
local MARKER_LENGTH = 1.05
local MARKER_HEIGHT = 0.05
local MARKER_SPACING = 2.75
local MARKER_LEAD_DISTANCE = 1.25

local ARROW_SPACING = 12
local ARROW_LEAD_DISTANCE = 4.5

local ROUTE_SAMPLE_SPACING = 1.25
local FLOOR_LIFT = 0.09
local PLAYER_FLOOR_OFFSET = 3
local PATH_REFRESH_SECONDS = 0.35
local TARGET_REFRESH_DISTANCE = 1
local REROUTE_DISTANCE = 7

local PROGRESS_SMOOTH_SPEED = 18
local FADE_SMOOTH_SPEED = 12
local VISIBLE_TRANSPARENCY = 0.28
local HIDDEN_TRANSPARENCY = 1

local HUE_SPEED = 0.025
local HUE_SPREAD = 0.06

--[[
Creates one reusable client-only visual part.

Args:
    parent (Instance): Folder receiving the visual.
    name (string): Stable visual name.
    size (Vector3): Visual dimensions.

Returns:
    Part: Hidden non-colliding Neon part ready for pooling.
]]
local function create_visual_part(
    parent: Instance,
    name: string,
    size: Vector3
): Part
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = CFrame.new(0, -1000, 0)
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    part.Material = Enum.Material.Neon
    part.Transparency = HIDDEN_TRANSPARENCY
    part.Parent = parent
    return part
end

--[[
Returns the current local character root when available.

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
Projects one route position onto real collidable floor geometry.

Args:
    position (Vector3): Route-space position.
    character (Model?): Character to exclude from the ray.
    folder (Folder): Guide folder to exclude.

Returns:
    Vector3: Floor-adjusted route position.
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
Computes a walkable path from the player to the current tutorial target.

Args:
    start_position (Vector3): Current player position.
    target_position (Vector3): Static tutorial destination.

Returns:
    {PathWaypoint}?: Complete path when pathfinding succeeds.
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
Builds dense floor-conforming samples from pathfinding waypoints.

Dense samples let visuals move every frame without running floor raycasts
every frame or bridging several studs of uneven terrain.

Args:
    waypoints ({PathWaypoint}): Structural pathfinding route.
    character (Model?): Character excluded from floor projection.
    folder (Folder): Guide folder excluded from floor projection.

Returns:
    {Vector3}: Dense floor-conforming route positions.
]]
local function build_route_samples(
    waypoints: {PathWaypoint},
    character: Model?,
    folder: Folder
): {Vector3}
    local samples = {}

    for index = 1, #waypoints - 1 do
        local start_position = waypoints[index].Position
        local end_position = waypoints[index + 1].Position
        local length = (end_position - start_position).Magnitude
        local steps = math.max(
            1,
            math.ceil(length / ROUTE_SAMPLE_SPACING)
        )
        local first_step = if index == 1 then 0 else 1

        for step = first_step, steps do
            local alpha = step / steps
            local raw_position = start_position:Lerp(
                end_position,
                alpha
            )
            table.insert(
                samples,
                floor_position(
                    raw_position,
                    character,
                    folder
                )
            )
        end
    end

    return samples
end

--[[
Builds cumulative route distances for efficient progress sampling.

Args:
    positions ({Vector3}): Ordered dense route positions.

Returns:
    {number}: Cumulative distance at each route position.
    number: Total route length.
]]
local function build_route_distances(
    positions: {Vector3}
): ({number}, number)
    local distances = {0}
    local total = 0

    for index = 2, #positions do
        total += (
            positions[index] - positions[index - 1]
        ).Magnitude
        table.insert(distances, total)
    end

    return distances, total
end

--[[
Returns the closest route progress and distance from one world point.

Args:
    point (Vector3): Player floor position.
    positions ({Vector3}): Dense route positions.
    distances ({number}): Cumulative route distances.

Returns:
    number: Distance along the route at the closest point.
    number: Distance from the player to that route point.
]]
local function closest_route_progress(
    point: Vector3,
    positions: {Vector3},
    distances: {number}
): (number, number)
    local best_progress = 0
    local best_distance = math.huge

    for index = 1, #positions - 1 do
        local start_position = positions[index]
        local end_position = positions[index + 1]
        local segment = end_position - start_position
        local length_squared = segment:Dot(segment)

        if length_squared > 0.001 then
            local alpha = math.clamp(
                (point - start_position):Dot(segment)
                    / length_squared,
                0,
                1
            )
            local closest = start_position + segment * alpha
            local distance = (point - closest).Magnitude

            if distance < best_distance then
                local segment_length = segment.Magnitude
                best_distance = distance
                best_progress = distances[index]
                    + segment_length * alpha
            end
        end
    end

    return best_progress, best_distance
end

--[[
Finds the dense route segment containing one distance value.

Args:
    distances ({number}): Cumulative route distances.
    route_distance (number): Distance along the route.

Returns:
    number: Segment start index.
]]
local function route_segment_index(
    distances: {number},
    route_distance: number
): number
    local low = 1
    local high = math.max(1, #distances - 1)

    while low < high do
        local mid = math.floor((low + high + 1) / 2)

        if distances[mid] <= route_distance then
            low = mid
        else
            high = mid - 1
        end
    end

    return math.min(low, #distances - 1)
end

--[[
Samples a position and forward direction at one route distance.

Args:
    positions ({Vector3}): Dense route positions.
    distances ({number}): Cumulative route distances.
    total_length (number): Total route length.
    route_distance (number): Requested distance along the route.

Returns:
    Vector3: Interpolated floor position.
    Vector3: Forward direction along the route.
]]
local function sample_route(
    positions: {Vector3},
    distances: {number},
    total_length: number,
    route_distance: number
): (Vector3, Vector3)
    local clamped = math.clamp(
        route_distance,
        0,
        total_length
    )
    local index = route_segment_index(
        distances,
        clamped
    )

    local start_position = positions[index]
    local end_position = positions[index + 1]
    local start_distance = distances[index]
    local end_distance = distances[index + 1]
    local segment_length = math.max(
        end_distance - start_distance,
        0.001
    )
    local alpha = math.clamp(
        (clamped - start_distance) / segment_length,
        0,
        1
    )

    local position = start_position:Lerp(
        end_position,
        alpha
    )
    local direction = end_position - start_position

    return position, direction
end

--[[
Returns a frame-rate-independent smoothing alpha.

Args:
    speed (number): Exponential smoothing speed.
    delta_time (number): Seconds since the previous frame.

Returns:
    number: Interpolation alpha in the range 0-1.
]]
local function smoothing_alpha(
    speed: number,
    delta_time: number
): number
    return 1 - math.exp(
        -speed * math.max(delta_time, 0)
    )
end

--[[
Creates one pooled three-piece floor arrow.

Args:
    parent (Instance): Guide folder receiving arrow pieces.
    index (number): Stable arrow pool index.

Returns:
    any: Arrow pool entry containing shaft and wings.
]]
local function create_arrow_entry(
    parent: Instance,
    index: number
): any
    return {
        Shaft = create_visual_part(
            parent,
            "ArrowShaft" .. tostring(index),
            Vector3.new(0.3, MARKER_HEIGHT, 1.55)
        ),
        Left = create_visual_part(
            parent,
            "ArrowWing" .. tostring(index) .. "_Left",
            Vector3.new(0.26, MARKER_HEIGHT, 1.05)
        ),
        Right = create_visual_part(
            parent,
            "ArrowWing" .. tostring(index) .. "_Right",
            Vector3.new(0.26, MARKER_HEIGHT, 1.05)
        ),
    }
end

--[[
Returns target transforms for one pooled floor arrow.

Args:
    position (Vector3): Arrow centre.
    direction (Vector3): Route-forward direction.

Returns:
    CFrame?: Shaft target transform.
    CFrame?: Left-wing target transform.
    CFrame?: Right-wing target transform.
]]
local function arrow_cframes(
    position: Vector3,
    direction: Vector3
): (CFrame?, CFrame?, CFrame?)
    local flat_direction = Vector3.new(
        direction.X,
        0,
        direction.Z
    )

    if flat_direction.Magnitude < 0.1 then
        return nil, nil, nil
    end

    local facing = CFrame.lookAt(
        position,
        position + flat_direction
    )
    local tip = facing * CFrame.new(0, 0, -0.75)

    local left = tip
        * CFrame.Angles(0, math.rad(-38), 0)
        * CFrame.new(0, 0, 0.36)
    local right = tip
        * CFrame.Angles(0, math.rad(38), 0)
        * CFrame.new(0, 0, 0.36)

    return facing, left, right
end

--[[
Moves and fades one pooled part toward its current visual target.

Args:
    part (BasePart): Pooled visual part.
    target_cframe (CFrame?): Desired transform when visible.
    visible (boolean): Whether the part should currently be visible.
    delta_time (number): Frame delta used for smoothing.

Returns:
    nil: Updates the local visual part in place.
]]
local function update_visual_part(
    part: BasePart,
    target_cframe: CFrame?,
    visible: boolean,
    delta_time: number
)
    local fade_alpha = smoothing_alpha(
        FADE_SMOOTH_SPEED,
        delta_time
    )

    if visible and target_cframe then
        part.CFrame = target_cframe
        part.Transparency += (
            VISIBLE_TRANSPARENCY - part.Transparency
        ) * fade_alpha
    else
        part.Transparency += (
            HIDDEN_TRANSPARENCY - part.Transparency
        ) * fade_alpha
    end
end

--[[
Ensures enough pooled marker parts exist for the current visible route.

Args:
    self (any): Tutorial guide instance.
    count (number): Required marker count.

Returns:
    nil: Expands the marker pool only when necessary.
]]
function Guide:_ensure_marker_pool(count: number)
    while #self._marker_pool < count do
        local index = #self._marker_pool + 1
        local marker = create_visual_part(
            self._folder,
            "TrailMarker" .. tostring(index),
            Vector3.new(
                MARKER_WIDTH,
                MARKER_HEIGHT,
                MARKER_LENGTH
            )
        )

        table.insert(self._marker_pool, marker)
        table.insert(self._visual_parts, marker)
    end
end

--[[
Ensures enough pooled arrow entries exist for the current visible route.

Args:
    self (any): Tutorial guide instance.
    count (number): Required arrow count.

Returns:
    nil: Expands the arrow pool only when necessary.
]]
function Guide:_ensure_arrow_pool(count: number)
    while #self._arrow_pool < count do
        local index = #self._arrow_pool + 1
        local entry = create_arrow_entry(
            self._folder,
            index
        )

        table.insert(self._arrow_pool, entry)
        table.insert(self._visual_parts, entry.Shaft)
        table.insert(self._visual_parts, entry.Left)
        table.insert(self._visual_parts, entry.Right)
    end
end

--[[
Hides all pooled visuals without destroying them.

Args:
    self (any): Tutorial guide instance.
    immediate (boolean): Whether to hide without a fade.

Returns:
    nil: Preserves pool instances for later reuse.
]]
function Guide:_hide_visuals(immediate: boolean)
    for _, part in ipairs(self._visual_parts) do
        if immediate then
            part.Transparency = HIDDEN_TRANSPARENCY
        else
            update_visual_part(
                part,
                nil,
                false,
                1 / 60
            )
        end
    end
end

--[[
Replaces the structural route while keeping visual instances pooled.

Args:
    self (any): Tutorial guide instance.
    waypoints ({PathWaypoint}): Newly calculated structural route.

Returns:
    nil: Stores a dense floor-conforming route for fluid sampling.
]]
function Guide:_set_route(waypoints: {PathWaypoint})
    local positions = build_route_samples(
        waypoints,
        self._player.Character,
        self._folder
    )

    if #positions < 2 then
        return
    end

    local distances, total_length =
        build_route_distances(positions)

    self._path_positions = positions
    self._path_distances = distances
    self._path_length = total_length
    self._route_deviation = 0
    self._display_progress = nil
end

--[[
Clears structural route state while preserving pooled visual instances.

Args:
    self (any): Tutorial guide instance.

Returns:
    nil: Resets route data and hides current visuals.
]]
function Guide:_clear_route()
    self._path_positions = {}
    self._path_distances = {}
    self._path_length = 0
    self._route_deviation = math.huge
    self._display_progress = nil
    self:_hide_visuals(true)
end

--[[
Updates pooled trail markers from the player's live route progress.

Args:
    self (any): Tutorial guide instance.
    progress (number): Player distance along the route.
    delta_time (number): Frame delta.

Returns:
    nil: Smoothly advances markers from the moving source.
]]
function Guide:_update_markers(
    progress: number,
    delta_time: number
)
    local start_distance = math.min(
        progress + MARKER_LEAD_DISTANCE,
        self._path_length
    )
    local remaining = math.max(
        self._path_length - start_distance,
        0
    )
    local count = if remaining > 0.1
        then math.floor(remaining / MARKER_SPACING) + 1
        else 0

    self:_ensure_marker_pool(count)

    for index, marker in ipairs(self._marker_pool) do
        if index <= count then
            local route_distance = math.min(
                start_distance
                    + (index - 1) * MARKER_SPACING,
                self._path_length
            )
            local position, direction = sample_route(
                self._path_positions,
                self._path_distances,
                self._path_length,
                route_distance
            )
            local flat_direction = Vector3.new(
                direction.X,
                0,
                direction.Z
            )

            local target_cframe = if flat_direction.Magnitude >= 0.1
                then CFrame.lookAt(
                    position,
                    position + flat_direction
                )
                else marker.CFrame

            update_visual_part(
                marker,
                target_cframe,
                true,
                delta_time
            )
        else
            update_visual_part(
                marker,
                nil,
                false,
                delta_time
            )
        end
    end
end

--[[
Updates pooled directional arrows from the player's live route progress.

Args:
    self (any): Tutorial guide instance.
    progress (number): Player distance along the route.
    delta_time (number): Frame delta.

Returns:
    nil: Smoothly advances arrows without recreating instances.
]]
function Guide:_update_arrows(
    progress: number,
    delta_time: number
)
    local start_distance = math.min(
        progress + ARROW_LEAD_DISTANCE,
        self._path_length
    )
    local remaining = math.max(
        self._path_length - start_distance,
        0
    )
    local count = if remaining > 0.75
        then math.floor(remaining / ARROW_SPACING) + 1
        else 0

    self:_ensure_arrow_pool(count)

    for index, entry in ipairs(self._arrow_pool) do
        if index <= count then
            local route_distance = math.min(
                start_distance
                    + (index - 1) * ARROW_SPACING,
                self._path_length
            )
            local position, direction = sample_route(
                self._path_positions,
                self._path_distances,
                self._path_length,
                route_distance
            )
            local shaft, left, right = arrow_cframes(
                position,
                direction
            )
            local visible = shaft ~= nil

            update_visual_part(
                entry.Shaft,
                shaft,
                visible,
                delta_time
            )
            update_visual_part(
                entry.Left,
                left,
                visible,
                delta_time
            )
            update_visual_part(
                entry.Right,
                right,
                visible,
                delta_time
            )
        else
            update_visual_part(
                entry.Shaft,
                nil,
                false,
                delta_time
            )
            update_visual_part(
                entry.Left,
                nil,
                false,
                delta_time
            )
            update_visual_part(
                entry.Right,
                nil,
                false,
                delta_time
            )
        end
    end
end

--[[
Updates the subtle iridescent colour flow across visible pooled parts.

Args:
    self (any): Tutorial guide instance.

Returns:
    nil: Changes colour only; geometry remains stable.
]]
function Guide:_update_colors()
    local base_hue = (
        os.clock() * HUE_SPEED
    ) % 1
    local visual_count = math.max(
        #self._visual_parts,
        1
    )

    for index, part in ipairs(self._visual_parts) do
        if part.Parent and part.Transparency < 0.99 then
            local hue = (
                base_hue
                + index / visual_count * HUE_SPREAD
            ) % 1

            part.Color = Color3.fromHSV(
                hue,
                0.62,
                1
            )
        end
    end
end

--[[
Updates player-relative guide visuals on the client render loop.

Args:
    self (any): Tutorial guide instance.
    delta_time (number): Frame delta.

Returns:
    nil: Advances the visible route source fluently with the player.
]]
function Guide:_update_visuals(delta_time: number)
    local root = character_root(self._player)

    if not self._target
        or not root
        or #self._path_positions < 2
    then
        self:_hide_visuals(false)
        return
    end

    local player_floor = root.Position - Vector3.new(
        0,
        PLAYER_FLOOR_OFFSET,
        0
    )
    local progress, deviation = closest_route_progress(
        player_floor,
        self._path_positions,
        self._path_distances
    )

    self._route_deviation = deviation

    if self._display_progress == nil then
        self._display_progress = progress
    else
        local progress_alpha = smoothing_alpha(
            PROGRESS_SMOOTH_SPEED,
            delta_time
        )
        self._display_progress += (
            progress - self._display_progress
        ) * progress_alpha
    end

    local display_progress = self._display_progress
        or progress

    self:_update_markers(display_progress, delta_time)
    self:_update_arrows(display_progress, delta_time)
    self:_update_colors()
end

--[[
Refreshes structural pathfinding only when the corridor truly changes.

Normal forward movement does not rebuild the route. The live render loop
advances the source smoothly along the existing corridor.

Args:
    self (any): Tutorial guide instance.

Returns:
    nil: Recalculates only for target changes, respawn or route deviation.
]]
function Guide:_refresh()
    local target = self._target
    local root = character_root(self._player)

    if not target or not root or not target.Parent then
        self:_clear_route()
        return
    end

    local target_position = target.Position
    local target_moved = self._last_target_position == nil
        or (
            target_position - self._last_target_position
        ).Magnitude >= TARGET_REFRESH_DISTANCE
    local character_changed =
        self._path_character ~= self._player.Character
    local needs_route = #self._path_positions < 2
    local off_route =
        self._route_deviation >= REROUTE_DISTANCE

    if not target_moved
        and not character_changed
        and not needs_route
        and not off_route
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
        self:_set_route(waypoints)
    elseif needs_route then
        self._last_target_position = nil
        self._path_character = nil
        self:_clear_route()
    end
end

--[[
Sets the active destination for the tutorial guide.

Args:
    target (BasePart?): Physical tutorial destination.

Returns:
    nil: Rebuilds structural route state for a new destination.
]]
function Guide:set_target(target: BasePart?)
    if self._target == target and target ~= nil then
        return
    end

    self._target = target
    self._last_target_position = nil
    self._path_character = nil
    self:_clear_route()

    if target then
        self:_refresh()
    end
end

--[[
Clears the active tutorial destination.

Args:
    None.

Returns:
    nil: Hides pooled visuals and clears route state.
]]
function Guide:clear()
    self:set_target(nil)
end

--[[
Destroys the local guide and disconnects its render update.

Args:
    None.

Returns:
    nil: Releases all local presentation resources.
]]
function Guide:destroy()
    self._alive = false

    if self._render_connection then
        self._render_connection:Disconnect()
        self._render_connection = nil
    end

    self._folder:Destroy()
end

--[[
Creates a fluid tutorial path guide for one local player.

Args:
    player (Player): Local player whose position advances the route source.

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
        _marker_pool = {},
        _arrow_pool = {},
        _path_positions = {},
        _path_distances = {},
        _path_length = 0,
        _last_target_position = nil,
        _path_character = nil,
        _route_deviation = math.huge,
        _display_progress = nil,
        _render_connection = nil,
        _alive = true,
    }, Guide)

    task.spawn(function()
        while self._alive do
            self:_refresh()
            task.wait(PATH_REFRESH_SECONDS)
        end
    end)

    self._render_connection = RunService.PreRender:Connect(
        function(delta_time: number)
            if self._alive then
                self:_update_visuals(delta_time)
            end
        end
    )

    return self
end

return Guide
