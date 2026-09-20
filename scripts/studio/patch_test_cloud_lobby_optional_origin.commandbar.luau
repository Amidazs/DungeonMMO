--!strict
-- TEST Lobby only: repair Event/Secret run eligibility issued BEFORE teleport.
-- Back up the CURRENT authored cloud Lobby with File > Save to File first.
-- Studio Command Bar, EDIT mode only. Changes exactly one ModuleScript's
-- Source; no Workspace, geometry, portals, player profiles or DataStores.
local RunService = game:GetService("RunService")
assert(game.PlaceId == 134132328219009 and game.GameId == 10765241947,
    "Open the EXISTING cloud TEST Lobby, not the Dungeon or a local file.")
assert(not RunService:IsRunning(),
    "Stop Play mode before applying a persistent TEST Lobby source patch.")

local SSS = game:GetService("ServerScriptService")
local shared = game:GetService("ReplicatedStorage")
    :WaitForChild("Core"):WaitForChild("Shared")
local release = require(shared:WaitForChild("DungeonTestPlaceholderRelease"))
assert(type(release.is_test_lobby) == "function"
    and type(release.is_test_temple_context) == "function"
    and release.is_test_lobby() == true,
    "TEST Lobby release helper is missing or not the expected place.")

local node = SSS:WaitForChild("Core"):WaitForChild("Services")
    :WaitForChild("DungeonInstanceDirector")
assert(node:IsA("ModuleScript"),
    "Expected the existing DungeonInstanceDirector ModuleScript.")
local source = node.Source
local before = "local test_dungeon = TestRelease.is_test_dungeon()"
local after = "local test_temple = TestRelease.is_test_temple_context()"
local old_option = "if test_dungeon"
local new_option = "if test_temple"

local function count_plain(text: string, fragment: string): number
    local total = 0
    local at = 1
    while true do
        local first = string.find(text, fragment, at, true)
        if not first then return total end
        total += 1
        at = first + #fragment
    end
end

if count_plain(source, after) == 1
    and count_plain(source, new_option) == 3
    and count_plain(source, before) == 0
    and count_plain(source, old_option) == 0
then
    print("[TEST Optional Hotfix] ALREADY_APPLIED; no changes.")
else
    assert(count_plain(source, before) == 1
        and count_plain(source, old_option) == 3
        and count_plain(source, after) == 0
        and count_plain(source, new_option) == 0,
        "Unexpected DungeonInstanceDirector version; NO changes. "
        .."Inspect the existing cloud source before applying any hotfix.")

    -- Preserve every other byte of the existing cloud module's source.
    local first = assert(string.find(source, before, 1, true))
    local patched = string.sub(source, 1, first - 1)
        .. after .. string.sub(source, first + #before)
    local changed, count = string.gsub(patched, old_option, new_option)
    assert(count == 3
        and count_plain(changed, before) == 0
        and count_plain(changed, old_option) == 0
        and count_plain(changed, after) == 1
        and count_plain(changed, new_option) == 3,
        "Unexpected patch result; NO changes.")
    node.Source = changed
    assert(node.Source == changed,
        "Studio did not persist the one-module source edit.")
    print("[TEST Optional Hotfix] PATCH_APPLIED; exactly one TEST Lobby "
        .."ModuleScript updated, with the three option branches.")
end
print("[TEST Optional Hotfix] No published server changed yet. "
    .."Play-test in Studio, then publish this SAME existing TEST Lobby "
    .."after verifying the current-cloud backup and exact place target. "
    .."Create a NEW dungeon run after publishing.")
