--!strict
-- RunScript in Edit mode on a Rojo-built unpublished TEMP Dungeon place.
-- Checks isolated physical blockouts without opting in the live game or
-- registering missing Depth2-Depth4 layout bindings.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Physical placeholder smoke may only run on unpublished TEMP places.")
local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Tags = game:GetService("CollectionService")
local Builder = require(SSS:WaitForChild("Dungeon")
    :WaitForChild("DungeonPlaceholderPhysicalContent"))
local Definitions = require(RS.Core.Shared.DungeonDefinitions)
local checks = 0
local function check(ok: boolean, reason: string)
    checks += 1
    assert(ok, "[Phase4 Placeholder] " .. reason)
end
local container = Instance.new("Folder")
container.Name = "Phase4PhysicalBlockoutPreview"
container.Parent = Workspace
local expected = {
    TestDungeon = {"Temple", 250, 780},
    AbandonedMine = {"Mine", 450, 1760},
}
local summary = {}
for _, id in ipairs({"TestDungeon", "AbandonedMine"}) do
    local config = expected[id]
    local folder = Instance.new("Folder")
    folder.Name = id
    folder.Parent = container
    local geometry = Builder.create(folder, id)
    check(geometry.Name == "DungeonMMOPlaceholderPhysicalContent"
        and geometry:GetAttribute("DungeonMMOReplaceWithAuthoredModels") == true,
        id .. " replaceable geometry root")
    check(Definitions.get(id).OptionalBossRuntimeEnabled == false,
        id .. " optional runtime must remain release-locked")
    local bridges = 0
    local visible = 0
    for _, item in ipairs(geometry:GetDescendants()) do
        if item:IsA("BasePart") then
            visible += 1
            check(item.Anchored and item.CanCollide and
                item:GetAttribute("DungeonMMOPlaceholderPart") == true,
                id .. " placeholder must be a solid anchored replaceable part")
        end
    end
    for _, name in ipairs({"EventArena", "SecretArena"}) do
        local room = geometry:FindFirstChild(name)
        check(room ~= nil and room:IsA("Model"),
            id .. " missing " .. name)
        check(room:GetAttribute("DungeonMMOReplaceAsOneModel") == true,
            id .. " " .. name .. " not individually replaceable")
        check(room:FindFirstChild("Floor") ~= nil
            and room:FindFirstChild("Roof_PLACEHOLDER") ~= nil
            and room:FindFirstChild("BossPedestal") ~= nil,
            id .. " " .. name .. " needs floor, roof and boss pedestal")
    end
    for _, name in ipairs({"EventBridge", "SecretBridge"}) do
        local bridge = geometry:FindFirstChild(name)
        check(bridge ~= nil and bridge:IsA("Model")
            and bridge:FindFirstChild("WalkableFloor") ~= nil,
            id .. " " .. name .. " missing walkable corridor")
        bridges += 1
    end
    for depth = 2, 4 do
        local group = geometry:FindFirstChild(
            "Depth" .. depth .. "_UNREGISTERED_PREVIEW")
        check(group ~= nil
            and group:GetAttribute("DungeonMMOPhysicalLayoutRegistered") == false,
            id .. " Depth" .. depth .. " must be preview-only")
        local rooms = 0
        for _, room in ipairs(group:GetChildren()) do
            if room:IsA("Model") and string.match(room.Name, "^Room%d+$") then
                rooms += 1
                check(room:FindFirstChild("Floor") ~= nil
                    and room:FindFirstChild("Roof_PLACEHOLDER") ~= nil,
                    "Depth preview room must have a roof and floor")
            end
        end
        check(rooms == depth + 2, id .. " Depth" .. depth
            .. " expected " .. (depth + 2) .. " physical rooms")
        for index = 1, rooms - 1 do
            local bridge = group:FindFirstChild("Bridge_" .. index)
            check(bridge ~= nil and bridge:IsA("Model"),
                id .. " depth " .. depth .. " missing corridor " .. index)
            local floor = bridge:FindFirstChild("WalkableFloor")
            local rail = bridge:FindFirstChild("LeftRail")
            check(floor ~= nil and floor.Size.Z == 30
                and rail ~= nil and rail.Size.Z == 30
                and rail.Size.X == 1,
                id .. " depth " .. depth
                    .. " corridor rails must run ALONG its Z-axis path")
        end
    end
    local anchors = folder:FindFirstChild("DungeonMMOEnvironmentAnchors")
    check(anchors ~= nil and #anchors:GetChildren() == 6,
        id .. " must have six distinct optional physical anchors")
    for _, anchor in ipairs(anchors:GetChildren()) do
        check(Tags:HasTag(anchor, "DungeonMMOEnvironmentAnchor")
            and anchor.CanTouch == false
            and anchor.CanCollide == false,
            id .. " unused optional anchor must not enable gameplay")
    end
    -- Validate that all key walkable locations have terrain underneath.
    local function walkable(x: number, z: number)
        local cast = Workspace:Raycast(Vector3.new(x, 12, z),
            Vector3.new(0, -22, 0))
        return cast ~= nil and cast.Instance:IsA("BasePart")
            and (cast.Instance.Name == "Floor"
                or cast.Instance.Name == "WalkableFloor"
                or cast.Instance.Name == "BossPedestal")
    end
    local base_x = config[2]
    for _, z in ipairs({-45, -165}) do
        for _, dx in ipairs({35, 51, 67, 85, 105}) do
            check(walkable(base_x + dx, z),
                id .. " disconnected walkable optional bridge/floor "
                    .. dx .. ":" .. z)
        end
    end
    summary[id] = visible
    print("[Phase4 Placeholder] " .. id .. " rooms/bridges=" .. bridges
        .. " visible_parts=" .. visible .. " optional_anchors=6")
end
print("[Phase4 Placeholder] PASS " .. checks
    .. " checks; both dungeons, Depth2-4 previews, rollout OFF.")
