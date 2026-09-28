--!strict
-- Fluid client-only tutorial guidance with a looping objective-ward flow.

local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Guide = {}
Guide.__index = Guide

local FOLDER_NAME = "DungeonMMOTutorialGroundGuide"

local MARKER_WIDTH = 0.3
local MARKER_LENGTH = 0.3
local MARKER_HEIGHT = 0.045
local MARKER_SPACING = 3
local MARKER_TRANSPARENCY = 0.82

local ARROW_SPACING = 7.5
local ARROW_SPEED = 6.5
local ARROW_TRANSPARENCY = 0.16
local ARROW_START_GAP = 1.25
local ARROW_EDGE_FADE_DISTANCE = 4

local FLOOR_LIFT = 0.09
local PLAYER_FLOOR_OFFSET = 3
local ROUTE_SAMPLE_SPACING = 0.8
local LEAD_SAMPLE_SPACING = 0.8
local JOIN_AHEAD_DISTANCE = 3.5

local PATH_REFRESH_SECONDS = 0.35
local TARGET_REFRESH_DISTANCE = 1
local REROUTE_DISTANCE = 14
local REROUTE_COOLDOWN = 0.45
local JOIN_SMOOTH_SPEED = 12
local ROUTE_BLEND_SPEED = 3.2

local FADE_SMOOTH_SPEED = 14
local HIDDEN_TRANSPARENCY = 1
local HUE_SPEED = 0.025
local MARKER_HUE_OFFSET = 0.035

local MAX_MARKERS = 32
local MAX_ARROWS = 14

--[[
Creates one pooled local visual part.

Args:
    parent (Instance): Folder receiving the part.
    name (string): Stable visual name.
    size (Vector3): Part dimensions.

Returns:
    Part: Hidden, non-colliding Neon visual.
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
Returns the local player's current HumanoidRootPart.

Args:
    player (Player): Local player.

Returns:
    BasePart?: Current root part when available.
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
Returns a frame-rate-independent exponential smoothing alpha.

Args:
    speed (number): Smoothing response speed.
    delta_time (number): Seconds since the previous update.

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
Projects one visual position onto real collidable floor geometry.

Args:
    position (Vector3): World position to project.
    character (Model?): Character excluded from raycasts.
    folder (Folder): Guide visuals excluded from raycasts.

Returns:
    Vector3: Position resting just above collidable floor.
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
        position + Vector3.new(0, 7, 0),
        Vector3.new(0, -22, 0),
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
Computes a structural pathfinding corridor to the tutorial target.

Args:
    start_position (Vector3): Current player position.
    target_position (Vector3): Tutorial target position.

Returns:
    {PathWaypoint}?: Successful pathfinding waypoints.
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
Builds cumulative distances for ordered route positions.

Args:
    positions ({Vector3}): Ordered route positions.

Returns:
    {number}: Cumulative distance at each position.
    number: Total route length.
]]
local function build_distances(
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
Creates one route-data table from ordered positions.

Args:
    positions ({Vector3}): Ordered floor-conforming positions.

Returns:
    any: Route with Positions, Distances and Length fields.
]]
local function create_route(
    positions: {Vector3}
): any
    if #positions < 2 then
        return nil
    end

    local distances, total_length =
        build_distances(positions)

    return {
        Positions = positions,
        Distances = distances,
        Length = total_length,
    }
end

--[[
Converts structural path waypoints into a dense floor-conforming route.

Args:
    waypoints ({PathWaypoint}): Successful pathfinding route.
    character (Model?): Character excluded from floor projection.
    folder (Folder): Guide folder excluded from floor projection.

Returns:
    any: Dense structural route data.
]]
local function build_structural_route(
    waypoints: {PathWaypoint},
    character: Model?,
    folder: Folder
): any
    local positions = {}

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
                positions,
                floor_position(
                    raw_position,
                    character,
                    folder
                )
            )
        end
    end

    return create_route(positions)
end

--[[
Finds the route segment containing one distance value.

Args:
    route (any): Route-data table.
    route_distance (number): Requested distance along the route.

Returns:
    number: Segment start index.
]]
local function route_segment_index(
    route: any,
    route_distance: number
): number
    local distances = route.Distances
    local low = 1
    local high = math.max(1, #distances - 1)

    while low < high do
        local middle = math.floor((low + high + 1) / 2)

        if distances[middle] <= route_distance then
            low = middle
        else
            high = middle - 1
        end
    end

    return math.min(low, #distances - 1)
end

--[[
Samples a route position and forward direction at one route distance.

Args:
    route (any): Route-data table.
    route_distance (number): Distance along the route.

Returns:
    Vector3: Interpolated route position.
    Vector3: Forward route direction.
]]
local function sample_route(
    route: any,
    route_distance: number
): (Vector3, Vector3)
    local clamped = math.clamp(
        route_distance,
        0,
        route.Length
    )
    local index = route_segment_index(
        route,
        clamped
    )

    local start_position = route.Positions[index]
    local end_position = route.Positions[index + 1]
    local start_distance = route.Distances[index]
    local end_distance = route.Distances[index + 1]
    local segment_length = math.max(
        end_distance - start_distance,
        0.001
    )
    local alpha = math.clamp(
        (clamped - start_distance) / segment_length,
        0,
        1
    )

    return start_position:Lerp(
        end_position,
        alpha
    ), end_position - start_position
end

--[[
Finds the closest progress along a route to one world point.

Args:
    point (Vector3): World point to compare.
    route (any): Route-data table.

Returns:
    number: Closest distance along the route.
    number: World distance to that closest point.
]]
local function closest_route_progress(
    point: Vector3,
    route: any
): (number, number)
    local best_progress = 0
    local best_distance = math.huge

    for index = 1, #route.Positions - 1 do
        local start_position = route.Positions[index]
        local end_position = route.Positions[index + 1]
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
                best_distance = distance
                best_progress = route.Distances[index]
                    + segment.Magnitude * alpha
            end
        end
    end

    return best_progress, best_distance
end

--[[
Appends a floor-conforming lead-in from the player to the route join.

Args:
    positions ({Vector3}): Destination position array.
    start_position (Vector3): Current player floor position.
    end_position (Vector3): Current structural-route join.
    character (Model?): Character excluded from floor projection.
    folder (Folder): Guide folder excluded from floor projection.

Returns:
    nil: Appends dense lead-in positions in place.
]]
local function append_lead_positions(
    positions: {Vector3},
    start_position: Vector3,
    end_position: Vector3,
    character: Model?,
    folder: Folder
)
    local length = (end_position - start_position).Magnitude
    local steps = math.max(
        1,
        math.ceil(length / LEAD_SAMPLE_SPACING)
    )

    for step = 0, steps - 1 do
        local alpha = step / steps
        local raw_position = start_position:Lerp(
            end_position,
            alpha
        )

        table.insert(
            positions,
            floor_position(
                raw_position,
                character,
                folder
            )
        )
    end
end

--[[
Appends the structural route tail after a join distance.

Args:
    positions ({Vector3}): Destination position array.
    route (any): Structural route.
    join_distance (number): Distance along structural route to join.

Returns:
    nil: Appends the route tail in place.
]]
local function append_route_tail(
    positions: {Vector3},
    route: any,
    join_distance: number
)
    local join_position = sample_route(
        route,
        join_distance
    )
    table.insert(positions, join_position)

    for index, distance in ipairs(route.Distances) do
        if distance > join_distance + 0.05 then
            table.insert(
                positions,
                route.Positions[index]
            )
        end
    end
end

--[[
Builds the live route whose source is always the current player position.

Args:
    player_floor (Vector3): Current player floor position.
    structural_route (any): Stable pathfinding corridor.
    join_progress (number): Smoothed route join progress.
    character (Model?): Character excluded from floor projection.
    folder (Folder): Guide folder excluded from floor projection.

Returns:
    any: Live player-to-target route data.
]]
local function build_live_route(
    player_floor: Vector3,
    structural_route: any,
    join_progress: number,
    character: Model?,
    folder: Folder
): any
    local join_distance = math.min(
        join_progress + JOIN_AHEAD_DISTANCE,
        structural_route.Length
    )
    local join_position = sample_route(
        structural_route,
        join_distance
    )
    local positions = {}

    append_lead_positions(
        positions,
        player_floor,
        join_position,
        character,
        folder
    )
    append_route_tail(
        positions,
        structural_route,
        join_distance
    )

    return create_route(positions)
end

--[[
Creates one pooled three-piece directional arrow.

Args:
    parent (Instance): Guide folder.
    index (number): Stable pool index.

Returns:
    any: Arrow entry with Shaft, Left and Right parts.
]]
local function create_arrow_entry(
    parent: Instance,
    index: number
): any
    return {
        Shaft = create_visual_part(
            parent,
            "FlowArrowShaft" .. tostring(index),
            Vector3.new(0.32, MARKER_HEIGHT, 1.65)
        ),
        Left = create_visual_part(
            parent,
            "FlowArrowLeft" .. tostring(index),
            Vector3.new(0.28, MARKER_HEIGHT, 1.08)
        ),
        Right = create_visual_part(
            parent,
            "FlowArrowRight" .. tostring(index),
            Vector3.new(0.28, MARKER_HEIGHT, 1.08)
        ),
    }
end

--[[
Returns the three transforms for one floor arrow.

Args:
    position (Vector3): Arrow centre.
    direction (Vector3): Route-forward direction.

Returns:
    CFrame?: Shaft transform.
    CFrame?: Left-wing transform.
    CFrame?: Right-wing transform.
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
    local tip = facing * CFrame.new(0, 0, -0.78)

    return facing,
        tip
            * CFrame.Angles(0, math.rad(-38), 0)
            * CFrame.new(0, 0, 0.36),
        tip
            * CFrame.Angles(0, math.rad(38), 0)
            * CFrame.new(0, 0, 0.36)
end

--[[
Moves one pooled visual to a target or fades it out.

Args:
    part (BasePart): Pooled visual part.
    target_cframe (CFrame?): Visible target transform.
    visible_transparency (number): Transparency while visible.
    delta_time (number): Render-frame delta.

Returns:
    nil: Updates the visual in place without recreating it.
]]
local function update_part(
    part: BasePart,
    target_cframe: CFrame?,
    visible_transparency: number,
    delta_time: number
)
    local fade_alpha = smoothing_alpha(
        FADE_SMOOTH_SPEED,
        delta_time
    )

    if target_cframe then
        part.CFrame = target_cframe
        part.Transparency += (
            visible_transparency - part.Transparency
        ) * fade_alpha
    else
        part.Transparency += (
            HIDDEN_TRANSPARENCY - part.Transparency
        ) * fade_alpha
    end
end

--[[
Blends a sample between old and new live routes during rerouting.

Args:
    old_route (any?): Previous live route.
    new_route (any): Current live route.
    new_distance (number): Distance along the current live route.
    blend (number): Route transition amount from 0-1.

Returns:
    Vector3: Blended position.
    Vector3: Blended forward direction.
]]
local function blended_sample(
    old_route: any?,
    new_route: any,
    new_distance: number,
    blend: number
): (Vector3, Vector3)
    local new_position, new_direction = sample_route(
        new_route,
        new_distance
    )

    if not old_route or blend >= 0.999 then
        return new_position, new_direction
    end

    local ratio = if new_route.Length > 0.001
        then new_distance / new_route.Length
        else 0
    local old_distance = math.clamp(
        ratio,
        0,
        1
    ) * old_route.Length
    local old_position, old_direction = sample_route(
        old_route,
        old_distance
    )

    return old_position:Lerp(
        new_position,
        blend
    ), old_direction:Lerp(
        new_direction,
        blend
    )
end

--[[
Ensures the reusable marker pool can cover the current route.

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
Ensures the reusable arrow pool can cover the current route.

Args:
    self (any): Tutorial guide instance.
    count (number): Required arrow count.

Returns:
    nil: Expands the arrow pool only when necessary.
]]
function Guide:_ensure_arrow_pool(count: number)
    while #self._arrow_pool < count do
        local index = #self._arrow_pool + 1
        local arrow = create_arrow_entry(
            self._folder,
            index
        )

        table.insert(self._arrow_pool, arrow)
        table.insert(self._visual_parts, arrow.Shaft)
        table.insert(self._visual_parts, arrow.Left)
        table.insert(self._visual_parts, arrow.Right)
    end
end

--[[
Hides all pooled guide visuals without destroying them.

Args:
    self (any): Tutorial guide instance.
    immediate (boolean): Whether to hide instantly.

Returns:
    nil: Preserves every pool instance for later reuse.
]]
function Guide:_hide_visuals(immediate: boolean)
    for _, part in ipairs(self._visual_parts) do
        if immediate then
            part.Transparency = HIDDEN_TRANSPARENCY
        else
            update_part(
                part,
                nil,
                MARKER_TRANSPARENCY,
                1 / 60
            )
        end
    end
end

--[[
Installs a new structural corridor and starts a soft route transition.

Args:
    self (any): Tutorial guide instance.
    route (any): Newly calculated structural route.

Returns:
    nil: Updates structural route state without touching visual instances.
]]
function Guide:_install_route(route: any)
    if self._structural_route then
        self._previous_structural_route =
            self._structural_route
        self._route_blend = 0
    else
        self._previous_structural_route = nil
        self._route_blend = 1
    end

    self._structural_route = route
    self._join_progress = nil
    self._last_reroute_time = os.clock()

    self:_ensure_marker_pool(MAX_MARKERS)
    self:_ensure_arrow_pool(MAX_ARROWS)
end

--[[
Clears structural route state and hides visuals.

Args:
    self (any): Tutorial guide instance.

Returns:
    nil: Resets route state while retaining visual pools.
]]
function Guide:_clear_route()
    self._structural_route = nil
    self._previous_structural_route = nil
    self._join_progress = nil
    self._route_deviation = math.huge
    self._route_blend = 1
    self:_hide_visuals(true)
end

--[[
Updates the smoothed join point between the moving player and route corridor.

Args:
    self (any): Tutorial guide instance.
    player_floor (Vector3): Current player floor position.
    delta_time (number): Render-frame delta.

Returns:
    number: Smoothed join progress.
]]
function Guide:_update_join_progress(
    player_floor: Vector3,
    delta_time: number
): number
    local progress, deviation = closest_route_progress(
        player_floor,
        self._structural_route
    )
    self._route_deviation = deviation

    if self._join_progress == nil then
        self._join_progress = progress
        return progress
    end

    local alpha = smoothing_alpha(
        JOIN_SMOOTH_SPEED,
        delta_time
    )
    self._join_progress += (
        progress - self._join_progress
    ) * alpha

    return self._join_progress
end

--[[
Builds live current and previous routes from the moving player source.

Args:
    self (any): Tutorial guide instance.
    player_floor (Vector3): Current player floor position.
    join_progress (number): Current smoothed join progress.

Returns:
    any: Current live route.
    any?: Previous live route used only during route blending.
]]
function Guide:_build_live_routes(
    player_floor: Vector3,
    join_progress: number
): (any, any?)
    local character = self._player.Character
    local current = build_live_route(
        player_floor,
        self._structural_route,
        join_progress,
        character,
        self._folder
    )
    local previous = nil

    if self._previous_structural_route
        and self._route_blend < 0.999
    then
        local previous_progress = closest_route_progress(
            player_floor,
            self._previous_structural_route
        )
        previous = build_live_route(
            player_floor,
            self._previous_structural_route,
            previous_progress,
            character,
            self._folder
        )
    end

    return current, previous
end

--[[
Updates the faint route underlay from the moving player source.

Args:
    self (any): Tutorial guide instance.
    current_route (any): Current live route.
    previous_route (any?): Previous live route during rerouting.
    delta_time (number): Render-frame delta.

Returns:
    nil: Reuses pooled marker parts.
]]
function Guide:_update_markers(
    current_route: any,
    previous_route: any?,
    delta_time: number
)
    local count = math.min(
        MAX_MARKERS,
        math.floor(
            current_route.Length / MARKER_SPACING
        )
    )
    self:_ensure_marker_pool(count)

    for index, marker in ipairs(self._marker_pool) do
        if index <= count then
            local distance = index * MARKER_SPACING
            local position, direction = blended_sample(
                previous_route,
                current_route,
                distance,
                self._route_blend
            )
            position = floor_position(
                position,
                self._player.Character,
                self._folder
            )

            local target = CFrame.new(position)
                * CFrame.Angles(
                    0,
                    math.rad(45),
                    0
                )

            update_part(
                marker,
                target,
                MARKER_TRANSPARENCY,
                delta_time
            )
        else
            update_part(
                marker,
                nil,
                MARKER_TRANSPARENCY,
                delta_time
            )
        end
    end
end

--[[
Updates looping arrows that constantly travel toward the objective.

The flow phase is independent of player progress. Moving sideways or away from
the target changes the live route shape, but never reverses or resets the flow.

Args:
    self (any): Tutorial guide instance.
    current_route (any): Current live route.
    previous_route (any?): Previous live route during rerouting.
    delta_time (number): Render-frame delta.

Returns:
    nil: Reuses arrow instances while advancing their flow phase.
]]
function Guide:_update_flow_arrows(
    current_route: any,
    previous_route: any?,
    delta_time: number
)
    self._flow_phase = (
        self._flow_phase + ARROW_SPEED * delta_time
    ) % ARROW_SPACING

    local useful_length = math.max(
        current_route.Length - ARROW_START_GAP,
        0
    )
    local count = math.min(
        MAX_ARROWS,
        math.ceil(
            useful_length / ARROW_SPACING
        ) + 1
    )
    self:_ensure_arrow_pool(count)

    for index, arrow in ipairs(self._arrow_pool) do
        local distance = ARROW_START_GAP
            + self._flow_phase
            + (index - 1) * ARROW_SPACING
        local visible = index <= count
            and distance <= current_route.Length

        if visible then
            local position, direction = blended_sample(
                previous_route,
                current_route,
                distance,
                self._route_blend
            )
            position = floor_position(
                position,
                self._player.Character,
                self._folder
            )

            local shaft, left, right = arrow_cframes(
                position,
                direction
            )
            local source_fade = math.clamp(
                (
                    distance - ARROW_START_GAP
                ) / ARROW_EDGE_FADE_DISTANCE,
                0,
                1
            )
            local target_fade = math.clamp(
                (
                    current_route.Length - distance
                ) / ARROW_EDGE_FADE_DISTANCE,
                0,
                1
            )
            local visibility = math.min(
                source_fade,
                target_fade
            )
            local transparency = 1
                - visibility
                    * (1 - ARROW_TRANSPARENCY)

            update_part(
                arrow.Shaft,
                shaft,
                transparency,
                delta_time
            )
            update_part(
                arrow.Left,
                left,
                transparency,
                delta_time
            )
            update_part(
                arrow.Right,
                right,
                transparency,
                delta_time
            )
        else
            update_part(
                arrow.Shaft,
                nil,
                ARROW_TRANSPARENCY,
                delta_time
            )
            update_part(
                arrow.Left,
                nil,
                ARROW_TRANSPARENCY,
                delta_time
            )
            update_part(
                arrow.Right,
                nil,
                ARROW_TRANSPARENCY,
                delta_time
            )
        end
    end
end

--[[
Updates the subtle iridescent colour phase across visible guide parts.

Args:
    self (any): Tutorial guide instance.

Returns:
    nil: Changes colour without moving or recreating geometry.
]]
function Guide:_update_colors()
    local base_hue = (
        os.clock() * HUE_SPEED
    ) % 1

    for _, part in ipairs(self._visual_parts) do
        if part.Transparency < 0.99 then
            local is_marker = string.find(
                part.Name,
                "TrailMarker",
                1,
                true
            ) ~= nil
            local hue = (
                base_hue
                + if is_marker
                    then MARKER_HUE_OFFSET
                    else 0
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
Updates the client-only visual route before each rendered frame.

Args:
    self (any): Tutorial guide instance.
    delta_time (number): Render-frame delta.

Returns:
    nil: Moves the live source and advances the looping objective-ward flow.
]]
function Guide:_update_visuals(delta_time: number)
    local root = character_root(self._player)

    if not root or not self._structural_route then
        self:_hide_visuals(false)
        return
    end

    local player_floor = floor_position(
        root.Position - Vector3.new(
            0,
            PLAYER_FLOOR_OFFSET,
            0
        ),
        self._player.Character,
        self._folder
    )
    local join_progress = self:_update_join_progress(
        player_floor,
        delta_time
    )
    local current_route, previous_route =
        self:_build_live_routes(
            player_floor,
            join_progress
        )

    if not current_route then
        self:_hide_visuals(false)
        return
    end

    if self._route_blend < 1 then
        self._route_blend = math.min(
            1,
            self._route_blend
                + ROUTE_BLEND_SPEED * delta_time
        )

        if self._route_blend >= 1 then
            self._previous_structural_route = nil
        end
    end

    self:_update_markers(
        current_route,
        previous_route,
        delta_time
    )
    self:_update_flow_arrows(
        current_route,
        previous_route,
        delta_time
    )
    self:_update_colors()
end

--[[
Recalculates the structural path only when genuinely necessary.

Normal forward, sideways and backward movement is handled by the live source
and does not itself rebuild the route until route deviation becomes material.

Args:
    self (any): Tutorial guide instance.

Returns:
    nil: Installs a new structural route only when required.
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
    local needs_route = self._structural_route == nil
    local reroute_due = self._route_deviation
        >= REROUTE_DISTANCE
        and os.clock() - self._last_reroute_time
            >= REROUTE_COOLDOWN

    if not target_moved
        and not character_changed
        and not needs_route
        and not reroute_due
    then
        return
    end

    local waypoints = compute_path(
        root.Position,
        target_position
    )
    if not waypoints then
        if needs_route then
            self:_clear_route()
        end
        return
    end

    local route = build_structural_route(
        waypoints,
        self._player.Character,
        self._folder
    )
    if not route then
        return
    end

    self._last_target_position = target_position
    self._path_character = self._player.Character
    self:_install_route(route)
end

--[[
Sets the active tutorial destination.

Args:
    target (BasePart?): Physical tutorial target.

Returns:
    nil: Starts a fresh route when the objective changes.
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
    nil: Hides the guide while retaining pooled visual instances.
]]
function Guide:clear()
    self:set_target(nil)
end

--[[
Destroys the local guide and disconnects render updates.

Args:
    None.

Returns:
    nil: Releases all presentation resources.
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
Creates a looping player-relative tutorial guide.

Args:
    player (Player): Local player whose position forms the live route source.

Returns:
    any: New tutorial guide instance.
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
        _structural_route = nil,
        _previous_structural_route = nil,
        _last_target_position = nil,
        _path_character = nil,
        _join_progress = nil,
        _route_deviation = math.huge,
        _route_blend = 1,
        _last_reroute_time = -math.huge,
        _flow_phase = 0,
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
