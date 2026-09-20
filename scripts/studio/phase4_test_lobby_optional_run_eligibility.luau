--!strict
-- TEMP unpublished DataModel only. Simulates the exact allowlisted TEST
-- Lobby and TEST Dungeon separately; never changes cloud releases/DataStores.
assert(game.GameId == 0 and game.PlaceId == 0,
    "Optional run origin regression must run in an unpublished local place")
local RS=game:GetService("ReplicatedStorage")
local SSS=game:GetService("ServerScriptService")
local W=game:GetService("Workspace")
local shared=RS.Core.Shared
local release_script=shared.DungeonTestPlaceholderRelease
local original=release_script.Source
local lobby_original="return game.GameId == UNIVERSE_ID and game.PlaceId == TEST_BASE_ID"
local dungeon_original="return game.GameId == UNIVERSE_ID and game.PlaceId == TEST_DUNGEON_ID"
assert(string.find(original,"10765241947",1,true)
    and string.find(original,"134132328219009",1,true)
    and string.find(original,"117293035754309",1,true),
    "TEST universe/lobby/dungeon release identifiers changed")
local function once(source: string, before: string, after: string): string
    local start=assert(string.find(source,before,1,true),
        "TEST release source unexpectedly changed: "..before)
    assert(not string.find(source,before,start+#before,true),
        "Duplicate TEST release predicate")
    return string.sub(source,1,start-1)..after
        ..string.sub(source,start+#before)
end
local mock=once(original,lobby_original,[=[
return (game.GameId == UNIVERSE_ID and game.PlaceId == TEST_BASE_ID)
    or (game.GameId == 0 and game.PlaceId == 0
        and game:GetService("Workspace"):GetAttribute(
            "Phase4TEMPOptionalOrigin") == "Lobby")
]=])
mock=once(mock,dungeon_original,[=[
return (game.GameId == UNIVERSE_ID and game.PlaceId == TEST_DUNGEON_ID)
    or (game.GameId == 0 and game.PlaceId == 0
        and game:GetService("Workspace"):GetAttribute(
            "Phase4TEMPOptionalOrigin") == "Dungeon")
]=])
release_script.Source=mock
local release=require(release_script)
local director=require(SSS.Core.Services.DungeonInstanceDirector)
local definition=require(shared.DungeonDefinitions)
local catalog=require(shared.DungeonRuntimeContentCatalog)
local policy=require(SSS.Dungeon.DungeonOptionalBossPolicy)
local content=require(SSS.Dungeon.DungeonOptionalBossContent)
local now=os.time()
local function verify(origin: string, enabled: boolean)
    W:SetAttribute("Phase4TEMPOptionalOrigin",origin)
    assert(release.is_test_lobby() == (origin=="Lobby")
        and release.is_test_dungeon() == (origin=="Dungeon")
        and release.is_test_temple_context()==enabled,
        "TEST allowlist origin simulation mismatch")
    local opts=director.runtime_options()
    local run=director.resolve("TestDungeon",
        "phase4-test-optional-origin-"..origin,now,opts,"Depth1")
    assert(definition.get("TestDungeon").OptionalBossRuntimeEnabled==enabled,
        "Unexpected TEST optional boss release for "..origin)
    assert(run.OptionalBossEventActive==enabled
        and run.OptionalBossSecretUnlocked==enabled
        and run.OptionalBossEnabled==enabled,
        "Run created from "..origin.." has incorrect optional eligibility")
    if enabled then
        assert(opts.optional_boss_secret_chance_basis_points==10000
            and opts.optional_boss_event_start <= now
            and opts.optional_boss_event_end > now,
            "TEST Event/Secret practice options missing at "..origin)
        -- The Base creates the frozen run before teleport. Physical boss
        -- slots and encounter executors exist only in the Dungeon place.
        if origin == "Dungeon" then
            local layout=assert(catalog.get_layout("TestDungeon","Depth1"))
            local evaluated=policy.evaluate(
                {OptionalEncounters=content.for_difficulty("TestDungeon","Depth1")},
                "Depth1",layout.Slots,true,run)
        local count=if type(evaluated.encounters)=="table"
            then #evaluated.encounters else -1
        print("[Phase4 Optional Origin] POLICY "..origin
            .." ok="..tostring(evaluated.ok)
            .." count="..tostring(count)
            .." reason="..tostring(evaluated.reason)
            .." event="..tostring(run.OptionalBossEventActive)
            .." secret="..tostring(run.OptionalBossSecretUnlocked)
            .." eventSlot="..tostring(layout.Slots.EventArena~=nil)
            .." secretSlot="..tostring(layout.Slots.SecretArena~=nil))
        assert(evaluated.ok and count==2,
            "Event/Secret boss omitted from "..origin.." frozen plan: "
            ..tostring(evaluated.reason).." count="..count)
        end
        print("[Phase4 Optional Origin] "..string.upper(origin)
            .."_EVENT_AND_SECRET_FROZEN_AT_ENTRY_PASS")
    else
        assert(opts.optional_boss_secret_chance_basis_points==nil
            and opts.optional_boss_event_start==nil
            and opts.optional_boss_event_end==nil,
            "Practice overrides leaked outside the two TEST places")
        print("[Phase4 Optional Origin] OUTSIDE_TEST_PLACE_NOT_ENABLED_PASS")
    end
    local mine=director.resolve("AbandonedMine",
        "phase4-mine-origin-"..origin,now,opts,"Depth1")
    assert(not mine.OptionalBossEnabled,
        "Unreleased Mine optional bosses enabled from "..origin)
    local depth2=director.resolve("TestDungeon",
        "phase4-test-depth2-origin-"..origin,now,opts,"Depth2")
    if enabled then
        local released=definition.get("TestDungeon")
        assert(released and mine and depth2,
            "TEST context guards did not resolve")
        -- Depth2+ optional physical encounters remain release-locked
        -- by Dungeon runtime policy; TEST window is not a depth unlock.
    end
end
verify("Outside",false)
verify("Lobby",true)
verify("Dungeon",true)
W:SetAttribute("Phase4TEMPOptionalOrigin",nil)
print("[Phase4 Optional Origin] ALL_CONTEXTS_PASS")
