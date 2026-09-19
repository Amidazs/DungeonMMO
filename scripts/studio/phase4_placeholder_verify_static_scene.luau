--!strict
-- Verifies a generated EDITOR-ONLY .rbxlx preview, not a gameplay place.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Do not run the standalone blockout inspector against published Roblox.")
local W = game:GetService("Workspace")
local count = 0
for _, id in ipairs({"TestDungeon", "AbandonedMine"}) do
    local folder = W:FindFirstChild(id)
    assert(folder and folder:IsA("Folder"), id .. " scene folder missing")
    local scene = folder:FindFirstChild("DungeonMMOPlaceholderPhysicalContent")
    assert(scene and scene:IsA("Folder"),
        id .. " physical blockout folder missing")
    local prefix = if id == "TestDungeon" then "Temple" else "Mine"
    local x = if id == "TestDungeon" then 355 else 555
    for _, kind in ipairs({"EventArena", "SecretArena"}) do
        local room = scene:FindFirstChild(kind)
        assert(room and room:IsA("Model"),
            id .. " " .. kind .. " not an independently replaceable Model")
        assert(room:FindFirstChild("Floor")
            and room:FindFirstChild("Roof_PLACEHOLDER")
            and room:FindFirstChild("BossPedestal"),
            id .. " " .. kind .. " incomplete")
        assert(room.Floor.Anchored and room.Floor.CanCollide,
            id .. " room floor not solid")
    end
    local floor = scene.EventArena.Floor
    assert(math.abs(floor.Position.X - x) < 0.02
        and math.abs(floor.Position.Z + 54) < 0.02
        and floor.Size.X == 80 and floor.Size.Z == 90,
        id .. " event floor shifted in XML scene")
    assert(floor.Material ==
        (if id == "TestDungeon" then Enum.Material.Slate
            else Enum.Material.Rock),
        id .. " material lost during static serialization")
    for depth = 2, 4 do
        local group = scene:FindFirstChild(
            "Depth" .. depth .. "_UNREGISTERED_PREVIEW")
        assert(group, "Missing " .. id .. " higher-depth blockout")
        local n = 0
        for _, item in ipairs(group:GetChildren()) do
            if item:IsA("Model")
                and string.match(item.Name, "^Room%d+$")
            then
                n += 1
            end
        end
        assert(n == depth + 2, "Wrong room count in Depth" .. depth)
    end
    local anchors = folder:FindFirstChild("DungeonMMOEnvironmentAnchors")
    assert(anchors and anchors:FindFirstChild(
        prefix .. "_Event_Trigger"),
        id .. " reference anchor markers missing")
    assert(not anchors[prefix .. "_Event_Trigger"].CanTouch,
        "Static preview must not enable any optional encounter")
    print("[Phase4 Static Blockout] " .. id
        .. " optional rooms plus higher-depth models verified")
end
-- Count only our exported blockout scene geometry. Studio can insert
-- unrelated Workspace parts (e.g. default Baseplate) into an empty place.
for _, id in ipairs({"TestDungeon", "AbandonedMine"}) do
    local folder = W:FindFirstChild(id)
    assert(folder, id .. " scene folder missing during part count")
    for _, item in ipairs(folder:GetDescendants()) do
        if item:IsA("BasePart") then count += 1 end
    end
end
assert(count == 330,
    "Exported blockout physical part count differs from source: "
        .. tostring(count))
print("[Phase4 Static Blockout] PASS 330 editable parts; no live game scripts.")
