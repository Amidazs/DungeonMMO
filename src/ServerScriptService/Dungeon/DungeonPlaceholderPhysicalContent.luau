--!strict
-- Blockout geometry only. Every visible part belongs to a replaceable Model.
-- Never registers dungeon layouts or switches on optional/higher-depth rollout.
local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")
local AnchorFactory = require(
    ServerScriptService:WaitForChild("Core"):WaitForChild("Environment")
        :WaitForChild("EnvironmentAnchorFactory")
)

local Placeholder = {}
local ROOT_NAME = "DungeonMMOPlaceholderPhysicalContent"

local THEMES = {
    TestDungeon = {
        Prefix = "Temple", X = 250, PreviewX = 780,
        Floor = Color3.fromRGB(104, 101, 117),
        Wall = Color3.fromRGB(67, 65, 82),
        Accent = Color3.fromRGB(150, 117, 224),
        Material = Enum.Material.Slate,
    },
    AbandonedMine = {
        Prefix = "Mine", X = 450, PreviewX = 1760,
        Floor = Color3.fromRGB(91, 75, 58),
        Wall = Color3.fromRGB(61, 50, 46),
        Accent = Color3.fromRGB(83, 207, 203),
        Material = Enum.Material.Rock,
    },
}

local function part(
    parent: Instance, name: string, size: Vector3, position: Vector3,
    color: Color3, material: Enum.Material, transparency: number?
): Part
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.Position = position
    p.Color = color
    p.Material = material
    p.Transparency = transparency or 0
    p.CastShadow = true
    p:SetAttribute("DungeonMMOPlaceholderPart", true)
    p.Parent = parent
    return p
end

local function room_model(parent: Instance, name: string, theme: any): Model
    local model = Instance.new("Model")
    model.Name = name
    model:SetAttribute("DungeonMMOPlaceholder", true)
    model:SetAttribute("DungeonMMOReplaceAsOneModel", true)
    model:SetAttribute("DungeonMMOPlaceholderDungeonId",
        if theme.Prefix == "Temple" then "TestDungeon" else "AbandonedMine")
    model.Parent = parent
    return model
end

local function roof_and_walls(
    model: Model, theme: any, x: number, z: number,
    width: number, length: number, entry_z: number?
)
    local floor_y = -0.5
    part(model, "Floor", Vector3.new(width, 1, length),
        Vector3.new(x, floor_y, z), theme.Floor, theme.Material)
    -- Roof is semi-transparent to make the temporary blockout easy to inspect.
    part(model, "Roof_PLACEHOLDER", Vector3.new(width + 2, 2, length + 2),
        Vector3.new(x, 22, z), theme.Wall, theme.Material, 0.3)
    part(model, "EastWall", Vector3.new(2, 21, length),
        Vector3.new(x + width / 2, 10.5, z), theme.Wall, theme.Material)
    part(model, "SouthWall", Vector3.new(width, 21, 2),
        Vector3.new(x, 10.5, z - length / 2), theme.Wall, theme.Material)

    local west_x = x - width / 2
    local lower, upper = z - length / 2, z + length / 2
    if entry_z then
        -- Keep a 20-stud opening to the side corridor; do not block the route.
        local bottom_end = math.min(upper, entry_z - 10)
        if bottom_end - lower > 1 then
            part(model, "WestWallLower",
                Vector3.new(2, 21, bottom_end - lower),
                Vector3.new(west_x, 10.5, (lower + bottom_end) / 2),
                theme.Wall, theme.Material)
        end
        local top_start = math.max(lower, entry_z + 10)
        if upper - top_start > 1 then
            part(model, "WestWallUpper",
                Vector3.new(2, 21, upper - top_start),
                Vector3.new(west_x, 10.5, (upper + top_start) / 2),
                theme.Wall, theme.Material)
        end
        -- The Secret bridge reaches the room at its north-west corner.
        -- Split the north wall instead of sealing that entrance.
        if entry_z >= upper - 10 then
            part(model, "NorthWallWithEntry",
                Vector3.new(width - 20, 21, 2),
                Vector3.new(x + 10, 10.5, upper),
                theme.Wall, theme.Material)
        else
            part(model, "NorthWall", Vector3.new(width, 21, 2),
                Vector3.new(x, 10.5, upper),
                theme.Wall, theme.Material)
        end
    else
        part(model, "WestWall", Vector3.new(2, 21, length),
            Vector3.new(west_x, 10.5, z), theme.Wall, theme.Material)
        part(model, "NorthWall", Vector3.new(width, 21, 2),
            Vector3.new(x, 10.5, upper), theme.Wall, theme.Material)
    end
end

local function bridge(
    root: Instance, theme: any, name: string,
    x: number, z: number, length_x: number, width_z: number
): Model
    local model = room_model(root, name, theme)
    part(model, "WalkableFloor", Vector3.new(length_x, 1, width_z),
        Vector3.new(x, -0.5, z), theme.Floor, theme.Material)
    for _, side in ipairs({-1, 1}) do
        part(model, if side == -1 then "LeftRail" else "RightRail",
            Vector3.new(length_x, 3, 1),
            Vector3.new(x, 1.5, z + side * (width_z / 2 - 0.5)),
            theme.Accent, Enum.Material.Slate, 0.1)
    end
    return model
end

local function anchor(
    parent: Instance, prefix: string, id: string,
    position: Vector3, role: string
)
    -- Existing authored anchors win: fail instead of silently replacing them.
    for _, existing in ipairs(CollectionService:GetTagged(
        "DungeonMMOEnvironmentAnchor"
    )) do
        if existing:GetAttribute("EnvironmentAnchorId") == id
            or existing:GetAttribute("AnchorId") == id
        then
            error("PlaceholderAnchorAlreadyAuthored: " .. id)
        end
    end
    local size = if role == "EncounterTrigger"
        then Vector3.new(60, 6, 5) else Vector3.new(6, 2, 6)
    local created = AnchorFactory.create(
        parent, prefix, id, CFrame.new(position), size, role
    )
    -- Optional triggers are *not* activated by creating placeholder rooms.
    created.CanTouch = false
end

local function optional_room(
    root: Instance, parent: Instance, theme: any, name: string,
    z: number, entry_z: number, length: number,
    checkpoint_z: number, trigger_z: number, boss_z: number
)
    local x = theme.X + 105
    local room = room_model(root, name, theme)
    roof_and_walls(room, theme, x, z, 80, length, entry_z)
    room:SetAttribute("DungeonMMOPlaceholderRoomSlotId", name)
    part(room, "BossPedestal", Vector3.new(16, 1, 16),
        Vector3.new(x, 0.5, boss_z), theme.Accent, Enum.Material.Slate)
    for index = 1, 4 do
        local offset_x = if index % 2 == 0 then 26 else -26
        local offset_z = if index <= 2 then -20 else 20
        part(room, "Column_" .. index, Vector3.new(5, 15, 5),
            Vector3.new(x + offset_x, 7.5, z + offset_z),
            theme.Wall, theme.Material)
    end
    local pre = theme.Prefix .. "." ..
        (if name == "EventArena" then "Event" else "Secret")
    anchor(parent, theme.Prefix, pre .. ".Checkpoint",
        Vector3.new(x, 1, checkpoint_z), "Checkpoint")
    anchor(parent, theme.Prefix, pre .. ".Trigger",
        Vector3.new(x, 3, trigger_z), "EncounterTrigger")
    anchor(parent, theme.Prefix, pre .. ".BossSpawn",
        Vector3.new(x, 2, boss_z), "BossSpawn")
end

local function build_optional(root: Instance, parent: Instance, theme: any)
    optional_room(root, parent, theme, "EventArena",
        -54, -45, 90, -30, -38, -80)
    bridge(root, theme, "EventBridge",
        theme.X + 51, -45, 38, 20)
    optional_room(root, parent, theme, "SecretArena",
        -215, -165, 100, -185, -190, -255)
    bridge(root, theme, "SecretBridge",
        theme.X + 51, -165, 38, 40)
end

-- Depth2/3/4 blockout is a LOOK-AND-REPLACE preview only. Deliberately no
-- gameplay anchors or physical layout registration: depth gates stay locked.
local function build_depth_previews(root: Instance, theme: any)
    for depth = 2, 4 do
        local group = Instance.new("Folder")
        group.Name = "Depth" .. depth .. "_UNREGISTERED_PREVIEW"
        group:SetAttribute("DungeonMMOPlaceholderDepth", "Depth" .. depth)
        group:SetAttribute("DungeonMMOPhysicalLayoutRegistered", false)
        group.Parent = root
        local center_x = theme.PreviewX + (depth - 2) * 240
        local count = depth + 2 -- 4, 5, 6 encounter rooms.
        for index = 1, count do
            local z = 80 - (index - 1) * 90
            local room = room_model(group, "Room" .. index, theme)
            -- Deliberately leave the north and south route open for walking.
            part(room, "Floor", Vector3.new(64, 1, 64),
                Vector3.new(center_x, -0.5, z), theme.Floor, theme.Material)
            part(room, "Roof_PLACEHOLDER", Vector3.new(66, 2, 66),
                Vector3.new(center_x, 22, z), theme.Wall,
                theme.Material, 0.3)
            for _, side in ipairs({-1, 1}) do
                part(room, if side == -1 then "WestWall" else "EastWall",
                    Vector3.new(2, 21, 64),
                    Vector3.new(center_x + side * 32, 10.5, z),
                    theme.Wall, theme.Material)
            end
            room:SetAttribute("DungeonMMOPreviewRole",
                if index == count then "FinalBoss"
                else if depth == 4 and (index == 2
                    or index == 4 or index == 5)
                then "MiniBoss" else "Combat")
            if index == count or room:GetAttribute(
                "DungeonMMOPreviewRole") == "MiniBoss"
            then
                part(room, "BossPedestal", Vector3.new(16, 1, 16),
                    Vector3.new(center_x, 0.5, z), theme.Accent,
                    Enum.Material.Slate)
            end
            if index > 1 then
                bridge(group, theme, "Bridge_" .. (index - 1),
                    center_x, z + 45, 16, 30)
            end
        end
    end
end

-- Does not mutate the environment catalogue or production release flags.
-- Intended to run only in an explicit, unpublished Studio preview/build.
function Placeholder.create(parent: Instance, dungeon_id: string): any
    local theme = THEMES[dungeon_id]
    assert(theme, "UnknownPlaceholderDungeon")
    local old = parent:FindFirstChild(ROOT_NAME)
    assert(not old, "PlaceholderContentAlreadyPresent")
    local root = Instance.new("Folder")
    root.Name = ROOT_NAME
    root:SetAttribute("DungeonMMOPlaceholder", true)
    root:SetAttribute("DungeonMMOReplaceWithAuthoredModels", true)
    root:SetAttribute("DungeonMMODungeonId", dungeon_id)
    root.Parent = parent
    build_optional(root, parent, theme)
    build_depth_previews(root, theme)
    return root
end

return table.freeze(Placeholder)
