--!strict
-- Read-only inspection of a local build from test-lobby-sync.project.json.
-- This is NOT a standalone place to publish over the authored TEST Lobby.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Lobby sync inspection must run in an unpublished local place")
local SSS=game:GetService("ServerScriptService")
local RS=game:GetService("ReplicatedStorage")
assert(SSS:FindFirstChild("Base") and not SSS:FindFirstChild("Dungeon"),
    "Lobby sync must carry Base server code, never Dungeon")
assert(SSS:FindFirstChild("Core") and RS:FindFirstChild("Core"),
    "Lobby sync missing shared services")
local release=require(RS.Core.Shared.DungeonTestPlaceholderRelease)
assert(not release.is_test_lobby() and not release.is_test_dungeon(),
    "Local sync build must not impersonate either published place")
assert(SSS:GetAttribute("DungeonMMOEnvironment")==nil
    and SSS:GetAttribute("DungeonMMODungeonPlaceId")==nil,
    "Lobby sync project must preserve, not overwrite, cloud attributes")
for _,root in ipairs({SSS.Core,SSS.Base}) do
    local tests=root:FindFirstChild("Tests")
    if tests then assert(#tests:GetDescendants()==0,
        "Lobby sync still includes test scripts under "..root.Name) end
end
print("[Phase4 TEST Lobby Sync] BASE_CORE_AND_RELEASE_CODE_PASS")
print("[Phase4 TEST Lobby Sync] NO_TEST_SCRIPTS_PASS")
print("[Phase4 TEST Lobby Sync] CLOUD_ATTRIBUTES_DEFERRED_TO_EXISTING_STUDIO_PLACE")
print("[Phase4 TEST Lobby Sync] SYNC_ONLY_NEVER_STANDALONE_OVERWRITE_PASS")
