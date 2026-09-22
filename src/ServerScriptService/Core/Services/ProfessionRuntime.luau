--!strict
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local ProfessionRecipes = require(Shared:WaitForChild("ProfessionRecipes"))
local CorpseSkinningRuntime = require(
    script.Parent:WaitForChild("CorpseSkinningRuntime")
)
local DungeonModifierDefinitions = require(
    Shared:WaitForChild("DungeonModifierDefinitions")
)

local ProfessionRuntime = {}

local ENVIRONMENT_ANCHOR_TAG = "DungeonMMOEnvironmentAnchor"
local STATION_RANGE = 18
local MIN_DUNGEON_RESOURCE_SPACING = 18

local function floor_probe(offset: Vector3): any
    return table.freeze({
        Mode = "Floor",
        Offset = offset,
        Distance = 28,
    })
end

local function wall_probe(
    offset: Vector3,
    direction: Vector3
): any
    return table.freeze({
        Mode = "Wall",
        Offset = offset,
        Direction = direction,
        Distance = 24,
    })
end

local NODE_DEFINITIONS = table.freeze({
    Base = table.freeze({
        table.freeze({
            Id = "Base.IronOutcrop",
            Name = "Iron Outcrop",
            ProfessionId = "Mining",
            ItemId = "iron_ore",
            Quantity = 1,
            XP = 8,
            AnchorId = "Base.Profession.BlacksmithingPlaceholder",
            Offset = CFrame.new(8, -3, -6),
            ActionText = "Mine",
            VisualKind = "Ore",
            EmbedDepth = 0.45,
        }),
        table.freeze({
            Id = "Base.SilverleafPatch",
            Name = "Silverleaf Patch",
            ProfessionId = "Herbalism",
            ItemId = "silverleaf",
            Quantity = 1,
            XP = 8,
            AnchorId = "Base.Profession.AlchemyPlaceholder",
            Offset = CFrame.new(8, -3, -5),
            ActionText = "Gather",
            VisualKind = "Herb",
            EmbedDepth = 0.12,
        }),
        -- Placeholder hide cache until creature harvesting is authored.
        -- Gather claims still use the existing server-owned node path.
        table.freeze({
            Id = "Base.RawHideCache",
            Name = "Raw Hide Cache",
            ProfessionId = "Skinning",
            ItemId = "raw_hide",
            Quantity = 1,
            XP = 8,
            AnchorId = "Base.Profession.BlacksmithingPlaceholder",
            Offset = CFrame.new(17, -3, -5),
            ActionText = "Collect Hide",
            VisualKind = "Hide",
            EmbedDepth = 0.12,
        }),
    }),
    Dungeon = table.freeze({
        table.freeze({
            Id = "Temple.RichIronVein",
            Name = "Rich Iron Vein",
            ProfessionId = "Mining",
            ItemId = "iron_ore",
            Quantity = 2,
            XP = 12,
            AnchorId = "Temple.Room1.Checkpoint",
            PlacementGroup = "Temple.Room1",
            MinSpacing = MIN_DUNGEON_RESOURCE_SPACING,
            ActionText = "Mine",
            VisualKind = "Ore",
            EmbedDepth = 0.65,
            Probes = table.freeze({
                floor_probe(Vector3.new(-13, 10, -13)),
                floor_probe(Vector3.new(-15, 10, -9)),
                floor_probe(Vector3.new(-11, 10, -16)),
            }),
        }),
        table.freeze({
            Id = "Temple.RichIronVein.02",
            Name = "Wall Iron Vein",
            FallbackOffset = CFrame.new(12, -3, -12),
            ProfessionId = "Mining",
            ItemId = "iron_ore",
            Quantity = 2,
            XP = 12,
            AnchorId = "Temple.Room1.Checkpoint",
            PlacementGroup = "Temple.Room1",
            MinSpacing = MIN_DUNGEON_RESOURCE_SPACING,
            ActionText = "Mine",
            VisualKind = "Ore",
            EmbedDepth = 0.8,
            Probes = table.freeze({
                wall_probe(
                    Vector3.new(-15, 3, 9),
                    Vector3.new(-1, 0, 0)
                ),
                floor_probe(Vector3.new(-13, 10, 10)),
                wall_probe(
                    Vector3.new(-14, 3, 5),
                    Vector3.new(-1, 0, 0)
                ),
            }),
        }),
        table.freeze({
            Id = "Temple.Room1.Silverleaf",
            Name = "Temple Silverleaf",
            FallbackOffset = CFrame.new(0, -3, 12),
            ProfessionId = "Herbalism",
            ItemId = "silverleaf",
            Quantity = 1,
            XP = 10,
            AnchorId = "Temple.Room1.Checkpoint",
            PlacementGroup = "Temple.Room1",
            MinSpacing = MIN_DUNGEON_RESOURCE_SPACING,
            ActionText = "Gather",
            VisualKind = "Herb",
            EmbedDepth = 0.16,
            Probes = table.freeze({
                floor_probe(Vector3.new(13, 10, 12)),
                floor_probe(Vector3.new(15, 10, 8)),
                floor_probe(Vector3.new(11, 10, 15)),
            }),
        }),
        table.freeze({
            Id = "Temple.AncientSilverleaf",
            Name = "Ancient Silverleaf",
            ProfessionId = "Herbalism",
            ItemId = "silverleaf",
            Quantity = 2,
            XP = 12,
            AnchorId = "Temple.Room2.Checkpoint",
            PlacementGroup = "Temple.Room2",
            MinSpacing = MIN_DUNGEON_RESOURCE_SPACING,
            ActionText = "Gather",
            VisualKind = "Herb",
            EmbedDepth = 0.16,
            Probes = table.freeze({
                floor_probe(Vector3.new(14, 10, -13)),
                floor_probe(Vector3.new(12, 10, -16)),
                floor_probe(Vector3.new(16, 10, -9)),
            }),
        }),
        table.freeze({
            Id = "Temple.AncientSilverleaf.02",
            Name = "Silverleaf Cluster",
            FallbackOffset = CFrame.new(-12, -3, -12),
            ProfessionId = "Herbalism",
            ItemId = "silverleaf",
            Quantity = 1,
            XP = 10,
            AnchorId = "Temple.Room2.Checkpoint",
            PlacementGroup = "Temple.Room2",
            MinSpacing = MIN_DUNGEON_RESOURCE_SPACING,
            ActionText = "Gather",
            VisualKind = "Herb",
            EmbedDepth = 0.16,
            Probes = table.freeze({
                floor_probe(Vector3.new(-14, 10, 12)),
                floor_probe(Vector3.new(-16, 10, 8)),
                floor_probe(Vector3.new(-11, 10, 15)),
            }),
        }),
        table.freeze({
            Id = "Temple.Room2.IronVein",
            Name = "Temple Iron Vein",
            FallbackOffset = CFrame.new(0, -3, 12),
            ProfessionId = "Mining",
            ItemId = "iron_ore",
            Quantity = 1,
            XP = 10,
            AnchorId = "Temple.Room2.Checkpoint",
            PlacementGroup = "Temple.Room2",
            MinSpacing = MIN_DUNGEON_RESOURCE_SPACING,
            ActionText = "Mine",
            VisualKind = "Ore",
            EmbedDepth = 0.8,
            Probes = table.freeze({
                wall_probe(
                    Vector3.new(15, 3, 10),
                    Vector3.new(1, 0, 0)
                ),
                floor_probe(Vector3.new(14, 10, 10)),
                wall_probe(
                    Vector3.new(14, 3, 6),
                    Vector3.new(1, 0, 0)
                ),
            }),
        }),
    }),
})

local STATION_ANCHORS = table.freeze({
    Blacksmithing = "Base.Profession.BlacksmithingPlaceholder",
    Alchemy = "Base.Profession.AlchemyPlaceholder",
    -- Distinct temporary station roots near existing authored Base anchors.
    -- No new Base anchor, mesh or shop NPC is required for backend testing.
    Leatherworking = "Base.Profession.BlacksmithingPlaceholder",
    Enchanting = "Base.Profession.AlchemyPlaceholder",
})

local STATION_PLACEHOLDER_OFFSETS = table.freeze({
    Leatherworking = CFrame.new(10, 0, -6),
    Enchanting = CFrame.new(-10, 0, -6),
})

local function make_part(
    parent: Instance,
    name: string,
    size: Vector3,
    cframe: CFrame,
    color: Color3,
    material: Enum.Material
): Part
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Color = color
    part.Material = material
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    -- Resource presentation must never become a later node's raycast surface.
    part.CanQuery = false
    part.CastShadow = true
    part.Parent = parent
    return part
end

local function add_prompt(
    parent: Instance,
    name: string,
    action_text: string,
    object_text: string,
    hold_duration: number
): ProximityPrompt
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = name
    prompt.ActionText = action_text
    prompt.ObjectText = object_text
    prompt.HoldDuration = hold_duration
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = parent
    return prompt
end

local function mark_node_model(model: Model, node: any)
    model:SetAttribute("ProfessionNodeId", node.Id)
    model:SetAttribute("ProfessionId", node.ProfessionId)
    model:SetAttribute("GatherItemId", node.ItemId)
end

local function create_ore(parent: Instance, node: any, cframe: CFrame): BasePart
    local model = Instance.new("Model")
    model.Name = node.Id
    mark_node_model(model, node)
    model.Parent = parent

    local root = make_part(
        model,
        "PromptRoot",
        Vector3.new(3.8, 2.2, 3.4),
        cframe * CFrame.new(0, 1.1, 0),
        Color3.fromRGB(92, 68, 46),
        Enum.Material.Slate
    )
    root.Shape = Enum.PartType.Ball

    local left = make_part(
        model,
        "IronNoduleA",
        Vector3.new(1.5, 1.2, 1.4),
        cframe * CFrame.new(-1.4, 1.0, -0.5),
        Color3.fromRGB(105, 79, 51),
        Enum.Material.Metal
    )
    left.Shape = Enum.PartType.Ball

    local right = make_part(
        model,
        "IronNoduleB",
        Vector3.new(1.2, 1.5, 1.2),
        cframe * CFrame.new(1.3, 1.2, 0.3),
        Color3.fromRGB(122, 86, 51),
        Enum.Material.Metal
    )
    right.Shape = Enum.PartType.Ball

    return root
end

local function create_herb(parent: Instance, node: any, cframe: CFrame): BasePart
    local model = Instance.new("Model")
    model.Name = node.Id
    mark_node_model(model, node)
    model.Parent = parent

    local root = make_part(
        model,
        "PromptRoot",
        Vector3.new(2.4, 0.35, 2.4),
        cframe * CFrame.new(0, 0.18, 0),
        Color3.fromRGB(55, 92, 46),
        Enum.Material.Grass
    )
    root.Transparency = 0.35

    for index = 1, 6 do
        local angle = (index / 6) * math.pi * 2
        local radius = 0.55 + ((index % 2) * 0.25)
        local leaf = make_part(
            model,
            "Silverleaf" .. tostring(index),
            Vector3.new(0.28, 1.6, 0.55),
            cframe
                * CFrame.new(
                    math.cos(angle) * radius,
                    0.85,
                    math.sin(angle) * radius
                )
                * CFrame.Angles(0, -angle, math.rad(25)),
            Color3.fromRGB(126, 164, 120),
            Enum.Material.Grass
        )
        leaf.Shape = Enum.PartType.Block
    end

    return root
end

local function create_hide_cache(
    parent: Instance, node: any, cframe: CFrame
): BasePart
    local model = Instance.new("Model")
    model.Name = node.Id
    mark_node_model(model, node)
    model.Parent = parent
    local prompt_root = make_part(
        model, "PromptRoot", Vector3.new(3, 0.45, 2.5),
        cframe * CFrame.new(0, 0.23, 0),
        Color3.fromRGB(128, 82, 54), Enum.Material.Fabric
    )
    -- Deliberately plain temporary source, not a skinnable creature.
    make_part(
        model, "HideFold", Vector3.new(2.2, 0.3, 1.7),
        cframe * CFrame.new(0, 0.55, 0),
        Color3.fromRGB(151, 105, 66), Enum.Material.Fabric
    )
    return prompt_root
end

local function create_alchemy_station(parent: Instance, anchor: BasePart)
    local model = Instance.new("Model")
    model.Name = "AlchemyStationPresentation"
    model.Parent = parent

    make_part(
        model,
        "Workbench",
        Vector3.new(5, 0.5, 2.6),
        anchor.CFrame * CFrame.new(0, -2.2, 0),
        Color3.fromRGB(91, 57, 32),
        Enum.Material.WoodPlanks
    )
    make_part(
        model,
        "Cauldron",
        Vector3.new(2.2, 1.2, 2.2),
        anchor.CFrame * CFrame.new(0, -1.35, 0),
        Color3.fromRGB(56, 62, 58),
        Enum.Material.Metal
    )
    local liquid = make_part(
        model,
        "Mixture",
        Vector3.new(1.65, 0.15, 1.65),
        anchor.CFrame * CFrame.new(0, -0.75, 0),
        Color3.fromRGB(90, 156, 106),
        Enum.Material.Neon
    )
    liquid.Shape = Enum.PartType.Cylinder
    liquid.CFrame = liquid.CFrame * CFrame.Angles(0, 0, math.rad(90))
end

local function projected_tangent(normal: Vector3, preferred: Vector3): Vector3
    local tangent = preferred - normal * preferred:Dot(normal)
    if tangent.Magnitude < 0.05 then
        tangent = Vector3.new(1, 0, 0) - normal * normal.X
    end
    if tangent.Magnitude < 0.05 then
        tangent = Vector3.new(0, 0, -1) - normal * -normal.Z
    end
    return tangent.Unit
end

local function production_raycast_params(runtime_root: Instance?): RaycastParams
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude

    local excluded: {Instance} = {}
    if runtime_root then
        table.insert(excluded, runtime_root)
    end

    for _, tagged in ipairs(CollectionService:GetTagged(ENVIRONMENT_ANCHOR_TAG)) do
        table.insert(excluded, tagged)
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            table.insert(excluded, player.Character)
        end
    end

    params.FilterDescendantsInstances = excluded
    params.IgnoreWater = false
    return params
end

local function test_raycast_params(include_root: Instance): RaycastParams
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = {include_root}
    params.IgnoreWater = false
    return params
end

function ProfessionRuntime.node_definitions(context: string): {any}
    local source = NODE_DEFINITIONS[context]
    local result = {}
    if source then
        for _, node in ipairs(source) do
            table.insert(result, node)
        end
    end
    return result
end

function ProfessionRuntime.is_position_spaced(
    position: Vector3,
    occupied_positions: {Vector3}?,
    minimum_spacing: number?
): boolean
    local spacing = math.max(0, tonumber(minimum_spacing) or 0)
    if spacing <= 0 or not occupied_positions then
        return true
    end

    for _, occupied in ipairs(occupied_positions) do
        if (position - occupied).Magnitude < spacing then
            return false
        end
    end

    return true
end

-- Resolves a candidate dungeon resource against real world geometry. A node
-- only spawns after a successful raycast, so it cannot float in empty space.
-- The result is moved slightly into the hit surface to guarantee embedding.
function ProfessionRuntime.resolve_surface_placement(
    anchor: BasePart,
    node: any,
    runtime_root: Instance?,
    include_root_for_test: Instance?,
    occupied_positions: {Vector3}?,
    minimum_spacing: number?
): (CFrame?, string?)
    if type(node) ~= "table" or type(node.Probes) ~= "table" then
        if type(node) == "table" and typeof(node.Offset) == "CFrame" then
            return anchor.CFrame * node.Offset, "AuthoredOffset"
        end
        return nil, nil
    end

    local params = if include_root_for_test
        then test_raycast_params(include_root_for_test)
        else production_raycast_params(runtime_root)

    for _, probe in ipairs(node.Probes) do
        local offset = if typeof(probe.Offset) == "Vector3"
            then probe.Offset
            else Vector3.zero
        local origin = anchor.CFrame:PointToWorldSpace(offset)
        local distance = math.max(1, tonumber(probe.Distance) or 24)
        local direction: Vector3?

        if probe.Mode == "Floor" then
            direction = Vector3.new(0, -distance, 0)
        elseif probe.Mode == "Wall" and typeof(probe.Direction) == "Vector3" then
            if probe.Direction.Magnitude > 0 then
                direction = anchor.CFrame:VectorToWorldSpace(
                    probe.Direction.Unit
                ) * distance
            end
        end

        if direction then
            local hit = workspace:Raycast(origin, direction, params)
            if hit then
                local normal = hit.Normal.Unit
                local embed_depth = math.max(
                    0.05,
                    tonumber(node.EmbedDepth) or 0.25
                )
                local position = hit.Position - normal * embed_depth
                local tangent = projected_tangent(
                    normal,
                    anchor.CFrame.LookVector
                )
                if ProfessionRuntime.is_position_spaced(
                    position,
                    occupied_positions,
                    minimum_spacing
                ) then
                    return CFrame.lookAt(
                        position,
                        position + tangent,
                        normal
                    ), tostring(probe.Mode)
                end
            end
        end
    end

    if typeof(node.FallbackOffset) == "CFrame" then
        local fallback = anchor.CFrame * node.FallbackOffset
        if ProfessionRuntime.is_position_spaced(
            fallback.Position,
            occupied_positions,
            minimum_spacing
        ) then
            return fallback, "AuthoredFallback"
        end
    end

    return nil, nil
end

function ProfessionRuntime.within_station_range(
    player: Player,
    anchor: BasePart,
    max_distance: number?
): boolean
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or not root:IsA("BasePart") then
        return false
    end
    return (root.Position - anchor.Position).Magnitude <= (max_distance or STATION_RANGE)
end

-- A unique ticket prevents an old, interrupted request from releasing
-- the new request lock when that same UserId reconnects on this server.
-- The ProfessionService remains the authority for inventory mutations.
function ProfessionRuntime.new_craft_request_guard(): any
    local active: {[number]: number} = {}
    local next_ticket = 0
    local guard = {}

    -- Args:
    --   user_id: number; authoritative account ID.
    -- Returns:
    --   (boolean, number?): whether acquired and the unique request ticket.
    function guard:try_begin(user_id: number): (boolean, number?)
        if active[user_id] ~= nil then
            return false, nil
        end
        next_ticket += 1
        active[user_id] = next_ticket
        return true, next_ticket
    end

    -- Args:
    --   user_id: number; owner of the original request.
    --   ticket: number?; optional ticket for conditional cleanup.
    -- Returns:
    --   boolean: true only when the matching lock was released.
    function guard:finish(user_id: number, ticket: number?): boolean
        if ticket ~= nil and active[user_id] ~= ticket then
            return false
        end
        local was_active = active[user_id] ~= nil
        active[user_id] = nil
        return was_active
    end

    -- Args:
    --   user_id: number; account owning the in-flight request.
    --   ticket: number; the ticket returned when that request acquired.
    -- Returns:
    --   boolean: whether the exact request remains current.
    function guard:is_current(user_id: number, ticket: number): boolean
        return active[user_id] == ticket
    end

    -- Args:
    --   user_id: number; authoritative account ID.
    -- Returns:
    --   boolean: whether that user currently owns a request lock.
    function guard:is_active(user_id: number): boolean
        return active[user_id] ~= nil
    end

    return guard
end

function ProfessionRuntime.attach(config: any): any
    local context = assert(config.context, "ProfessionRuntime context required")
    local environment = assert(config.environment, "ProfessionRuntime environment required")
    local professions = assert(config.professions, "ProfessionRuntime service required")
    local remotes = assert(config.remotes, "ProfessionRuntime remotes required")
    local on_profile_changed = config.on_profile_changed
    local sessions = config.sessions
    local get_session_id = config.get_session_id

    local snapshot_remote = remotes:WaitForChild("ProfessionSnapshot") :: RemoteEvent
    local station_open_remote = remotes:WaitForChild("ProfessionStationOpen") :: RemoteEvent
    local craft_request_remote = remotes:WaitForChild("ProfessionCraftRequest") :: RemoteEvent
    local action_result_remote = remotes:WaitForChild("ProfessionActionResult") :: RemoteEvent

    local existing = workspace:FindFirstChild("ProfessionRuntime")
    if existing then
        existing:Destroy()
    end

    local root_folder = Instance.new("Folder")
    root_folder.Name = "ProfessionRuntime"
    root_folder.Parent = workspace

    -- Base gathering is personal for the current Base visit. Dungeon claims
    -- are stored on the authoritative dungeon session so reconnects preserve
    -- exactly which nodes this player already gathered during that run.
    local base_claims: {[number]: {[string]: boolean}} = {}
    local station_anchors: {[string]: BasePart} = {}
    local occupied_positions_by_group: {[string]: {Vector3}} = {}
    local craft_request_guard = ProfessionRuntime.new_craft_request_guard()

    local function current_session_id(): string?
        if type(get_session_id) ~= "function" then
            return nil
        end
        local value = get_session_id()
        return if type(value) == "string" and value ~= "" then value else nil
    end

    local function current_gather_bonus(): number
        if context ~= "Dungeon" or not sessions then
            return 0
        end
        local session_id = current_session_id()
        local session = session_id and sessions:get(session_id) or nil
        local modifier_id = session and session.Modifier and session.Modifier.Id
        local modifier = if type(modifier_id) == "string"
            then DungeonModifierDefinitions.get(modifier_id)
            else nil
        return math.max(
            0,
            math.floor(tonumber(modifier and modifier.GatherYieldBonus) or 0)
        )
    end

    local function claimed_node_ids(player: Player): {string}
        local ids = {}

        if context == "Dungeon" then
            local session_id = current_session_id()
            if session_id and sessions then
                local result = sessions:get_claimed_resource_nodes(
                    session_id,
                    player.UserId
                )
                if result and result.ok == true and type(result.node_ids) == "table" then
                    for _, node_id in ipairs(result.node_ids) do
                        if type(node_id) == "string" then
                            table.insert(ids, node_id)
                        end
                    end
                end
            end
        else
            local claims = base_claims[player.UserId]
            if claims then
                for node_id, claimed in pairs(claims) do
                    if claimed == true then
                        table.insert(ids, node_id)
                    end
                end
            end
        end

        table.sort(ids)
        return ids
    end

    local function build_snapshot(player: Player): any
        local payload = professions:build_snapshot(player.UserId)
        payload.ClaimedNodeIds = claimed_node_ids(player)
        return payload
    end

    local function send_snapshot(player: Player)
        snapshot_remote:FireClient(player, build_snapshot(player))
    end

    local function finish_action(player: Player, action: string, result: any)
        action_result_remote:FireClient(player, {
            action = action,
            ok = result and result.ok == true,
            reason = result and result.reason or nil,
            profession_id = result and result.profession_id or nil,
            node_id = result and result.node_id or nil,
            item_id = result and (result.item_id or result.output_item_id) or nil,
            quantity = result and (result.quantity or result.output_quantity) or nil,
            xp = result and result.xp or nil,
            level_before = result and result.level_before or nil,
            level_after = result and result.level_after or nil,
            minigame_id = result and result.minigame_id or nil,
            minigame_score = result and result.minigame_score or nil,
        })

        if result and result.ok == true then
            send_snapshot(player)
            if type(on_profile_changed) == "function" then
                on_profile_changed(player)
            end
        end
    end

    local function claim_node(player: Player, node_id: string): any
        if context == "Dungeon" then
            local session_id = current_session_id()
            if not session_id or not sessions then
                return {ok = false, reason = "DungeonSessionNotReady"}
            end
            return sessions:claim_resource_node_once(
                session_id,
                player.UserId,
                node_id
            )
        end

        local claims = base_claims[player.UserId]
        if not claims then
            claims = {}
            base_claims[player.UserId] = claims
        end
        if claims[node_id] == true then
            return {ok = false, reason = "ResourceAlreadyGathered"}
        end
        claims[node_id] = true
        return {ok = true}
    end

    local function release_node_claim(player: Player, node_id: string)
        if context == "Dungeon" then
            local session_id = current_session_id()
            if session_id and sessions then
                sessions:release_resource_node_claim(
                    session_id,
                    player.UserId,
                    node_id
                )
            end
            return
        end

        local claims = base_claims[player.UserId]
        if claims then
            claims[node_id] = nil
        end
    end

    for _, node in ipairs(NODE_DEFINITIONS[context] or {}) do
        local anchor = environment:get(node.AnchorId)
        assert(anchor, "Profession node anchor missing: " .. tostring(node.AnchorId))

        local placement_group = if type(node.PlacementGroup) == "string"
            then node.PlacementGroup
            else node.AnchorId
        local occupied_positions = occupied_positions_by_group[placement_group]
        if not occupied_positions then
            occupied_positions = {}
            occupied_positions_by_group[placement_group] = occupied_positions
        end

        local minimum_spacing = if context == "Dungeon"
            then tonumber(node.MinSpacing) or MIN_DUNGEON_RESOURCE_SPACING
            else 0

        local cframe, placement_mode = ProfessionRuntime.resolve_surface_placement(
            anchor,
            node,
            root_folder,
            nil,
            occupied_positions,
            minimum_spacing
        )

        if not cframe then
            warn(
                "[Profession Runtime] Skipping resource without valid surface: "
                    .. tostring(node.Id)
            )
            continue
        end

        table.insert(occupied_positions, cframe.Position)

        local prompt_root = if node.VisualKind == "Ore"
            then create_ore(root_folder, node, cframe)
            elseif node.VisualKind == "Hide"
            then create_hide_cache(root_folder, node, cframe)
            else create_herb(root_folder, node, cframe)
        local model = prompt_root.Parent
        if model and model:IsA("Model") then
            model:SetAttribute("PlacementMode", placement_mode)
        end

        local prompt = add_prompt(
            prompt_root,
            "ProfessionGatherPrompt",
            node.ActionText,
            node.Name,
            if node.ProfessionId == "Mining" then 0.8 else 0.5
        )

        prompt.Triggered:Connect(function(player: Player)
            local claimed = claim_node(player, node.Id)
            if not claimed or claimed.ok ~= true then
                local reason = claimed and claimed.reason or "ResourceAlreadyGathered"
                if reason == "ResourceAlreadyClaimed" then
                    reason = "ResourceAlreadyGathered"
                end
                finish_action(player, "Gather", {
                    ok = false,
                    reason = reason,
                    node_id = node.Id,
                    profession_id = node.ProfessionId,
                })
                return
            end

            local result = professions:gather(
                player.UserId,
                node,
                current_gather_bonus()
            )
            result.node_id = node.Id

            if result.ok ~= true then
                -- Session claim is only a concurrency guard until the profile
                -- mutation succeeds. Roll it back if the grant fails.
                release_node_claim(player, node.Id)
            end

            finish_action(player, "Gather", result)
        end)
    end

    if context == "Base" then
        for station_id, anchor_id in pairs(STATION_ANCHORS) do
            local anchor = environment:get(anchor_id)
            assert(anchor, "Profession station anchor missing: " .. anchor_id)

            local prompt_anchor = anchor
            local offset = STATION_PLACEHOLDER_OFFSETS[station_id]
            if offset then
                -- Keep new prompts and range checks independent of the
                -- original Blacksmithing/Alchemy stations.
                prompt_anchor = make_part(
                    root_folder, station_id .. "StationPlaceholder",
                    Vector3.new(3, 2, 3), anchor.CFrame * offset,
                    Color3.fromRGB(95, 83, 66), Enum.Material.WoodPlanks
                )
            end
            station_anchors[station_id] = prompt_anchor

            if station_id == "Alchemy" then
                create_alchemy_station(root_folder, anchor)
            end

            local prompt = add_prompt(
                prompt_anchor,
                "ProfessionStationPrompt",
                "Craft",
                station_id,
                0.15
            )
            prompt.Triggered:Connect(function(player: Player)
                local payload = build_snapshot(player)
                payload.StationId = station_id
                station_open_remote:FireClient(player, payload)
            end)
        end

        craft_request_remote.OnServerEvent:Connect(function(player: Player, recipe_id: any)
            if type(recipe_id) ~= "string" then
                finish_action(player, "Craft", {ok = false, reason = "InvalidRecipeRequest"})
                return
            end

            local recipe = ProfessionRecipes.get(recipe_id)
            if not recipe then
                finish_action(player, "Craft", {ok = false, reason = "UnknownRecipe"})
                return
            end

            local anchor = station_anchors[recipe.StationId]
            if not anchor or not ProfessionRuntime.within_station_range(player, anchor, STATION_RANGE) then
                finish_action(player, "Craft", {ok = false, reason = "NotAtRequiredStation"})
                return
            end

            local acquired, ticket = craft_request_guard:try_begin(
                player.UserId)
            if not acquired then
                finish_action(player, "Craft", {
                    ok = false,
                    reason = "CraftRequestInProgress",
                })
                return
            end
            assert(ticket ~= nil, "Acquired craft must have a ticket")

            local completed_ok, result = pcall(function()
                local prepared = professions:prepare_craft(
                    player.UserId, recipe_id)
                if not prepared.ok then
                    return prepared
                end

                -- A yielding preparation may resume after PlayerRemoving
                -- and a same-account reconnect. Never commit that old
                -- request into the newly loaded character profile.
                if not craft_request_guard:is_current(
                    player.UserId, ticket)
                    or Players:GetPlayerByUserId(player.UserId) ~= player
                then
                    return {ok = false, reason = "CraftRequestCancelled"}
                end

                -- Client minigame-success arguments are never accepted.
                local outcome = professions.foundation_success_outcome(
                    prepared.minigame_id
                )
                return professions:complete_craft(
                    player.UserId, recipe_id, outcome)
            end)
            local still_current = craft_request_guard:is_current(
                player.UserId, ticket)
                and Players:GetPlayerByUserId(player.UserId) == player
            craft_request_guard:finish(player.UserId, ticket)
            if not still_current then
                return
            end

            if not completed_ok then
                warn("[Profession Runtime] Craft request failed: "
                    .. tostring(result))
                finish_action(player, "Craft", {
                    ok = false,
                    reason = "CraftRequestFailed",
                })
                return
            end
            finish_action(player, "Craft", result)
        end)
    end

    snapshot_remote.OnServerEvent:Connect(function(player: Player, action: any)
        if action == "Request" then
            send_snapshot(player)
        elseif type(action) == "table"
            and action.Action == "ChooseProfession"
        then
            -- A shared choice remote is safe in both Base and Dungeon.
            -- The service validates the real profile and refuses any
            -- attempt to overwrite an occupied profession slot.
            local result = professions:choose_profession(
                player.UserId, action.ProfessionId
            )
            finish_action(player, "ChooseProfession", result)
        end
    end)

    Players.PlayerRemoving:Connect(function(player: Player)
        base_claims[player.UserId] = nil
        craft_request_guard:finish(player.UserId)
    end)

    -- Existing Marauders are not beast-tagged; only explicitly registered,
    -- defeated and looted animal corpses receive an interactive skin prompt.
    CorpseSkinningRuntime.attach({
        root = root_folder,
        professions = professions,
        action_result = function(player: Player, result: any)
            finish_action(player, "Gather", result)
        end,
    })

    return {
        Root = root_folder,
        Context = context,
        StationAnchors = station_anchors,
    }
end

return table.freeze(ProfessionRuntime)
