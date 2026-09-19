--!strict
-- Use RunScript ONLY with an unpublished TEMP local .rbxl made by Rojo.
-- Creates a persistent Studio blockout scene; it does not publish to Roblox.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Refusing to create/save placeholders in a published Roblox place.")
local W = game:GetService("Workspace")
local Dungeon = game:GetService("ServerScriptService"):WaitForChild("Dungeon")
local id = W:GetAttribute("DungeonMMOPlaceholderPreviewDungeonId")
if id ~= "TestDungeon" and id ~= "AbandonedMine" then
    id = "TestDungeon"
end
local main = require(Dungeon:WaitForChild(
    if id == "TestDungeon"
        then "TempleSyntheticEnvironment"
        else "AbandonedMineSyntheticEnvironment"
))
local physical = require(Dungeon:WaitForChild(
    "DungeonPlaceholderPhysicalContent"
))
assert(not W:FindFirstChild("DungeonMMOPlaceholderPhysicalContent"),
    "TEMP blockout already exists; refusing duplicate geometry.")
main.create(W)
local root = physical.create(W, id)
assert(root:FindFirstChild("EventArena") and root:FindFirstChild("SecretArena"),
    "Optional blockout geometry missing")
local camera = W.CurrentCamera
if camera then
    camera.CameraType = Enum.CameraType.Scriptable
    local center = Vector3.new(if id == "TestDungeon" then 500 else 950,
        0, -125)
    camera.CFrame = CFrame.lookAt(
        center + Vector3.new(0, 350, 260), center)
end
W:SetAttribute("DungeonMMOPlaceholderPhysicalContentEnabled", false)
print("[Phase4 Placeholder Save] CREATED " .. id
    .. " (nonpublished, code-only blockout).")
-- This is a local SavePlace operation on the TEMP .rbxl passed to --localPlaceFile.
-- It must not be interpreted as a Roblox Publish operation.
local saved, error_message = pcall(function() game:SavePlace() end)
if not saved then
    warn("[Phase4 Placeholder Save] LOCAL_SAVE_UNSUPPORTED "
        .. tostring(error_message))
else
    print("[Phase4 Placeholder Save] SAVED_LOCAL_PREVIEW " .. id)
end
