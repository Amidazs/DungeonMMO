--!strict
-- Read-only inspection of one unpublished built TEST release composition.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Do not run composition inspection in a published Roblox place")
local SSS=game:GetService("ServerScriptService")
local RS=game:GetService("ReplicatedStorage")
local env=SSS:GetAttribute("DungeonMMOEnvironment")
assert(env=="TEST",
    "TEST publish composition lacks explicit TEST DataStore namespace")
assert(SSS:FindFirstChild("Core")
    and RS:FindFirstChild("Core"),
    "Published gameplay source composition missing")
local release=require(RS.Core.Shared.DungeonTestPlaceholderRelease)
assert(release.is_test_dungeon()==false
    and release.is_test_lobby()==false,
    "Unpublished local build must not masquerade as the live TEST place")
local is_dungeon=SSS:FindFirstChild("Dungeon")~=nil
local is_base=SSS:FindFirstChild("Base")~=nil
assert(is_dungeon~=is_base,
    "Published build must contain exactly one gameplay server root")
if is_dungeon then
    assert(SSS:GetAttribute("DungeonMMODungeonPlaceId")==nil,
        "Dungeon project incorrectly configured as starting Base")
    assert(SSS.Dungeon:FindFirstChild("DungeonEnvironmentBootstrap"),
        "Published dungeon missing environment bootstrap")
    assert(SSS.Dungeon:FindFirstChild("DungeonPlaceholderPhysicalContent"),
        "Published dungeon missing live placeholder builder")
    print("[Phase4 TEST Composition] DUNGEON_ENVIRONMENT_TEST_PASS")
else
    assert(SSS:GetAttribute("DungeonMMODungeonPlaceId")==117293035754309,
        "Published Base teleport target must remain TEST Dungeon")
    print("[Phase4 TEST Composition] BASE_ENV_AND_DESTINATION_PASS")
end
for _,root in ipairs({SSS.Core,SSS:FindFirstChild("Dungeon"),
    SSS:FindFirstChild("Base")}) do
    if root then
        assert(root:FindFirstChild("Tests")==nil,
            "Release candidate includes test-only server modules")
    end
end
print("[Phase4 TEST Composition] NO_TEST_SCRIPT_LEAK_PASS")
