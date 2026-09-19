--!strict
-- Unpublished TEST-ID simulation only. Never persists patched release logic.
assert(game.GameId == 0 and game.PlaceId == 0,
    "TEST release simulation must only run in an unpublished local place.")
local RS=game:GetService("ReplicatedStorage")
local SSS=game:GetService("ServerScriptService")
local W=game:GetService("Workspace")
local STS=game:GetService("StudioTestService")
local shared=RS.Core.Shared
local test_release=shared.DungeonTestPlaceholderRelease
local original=test_release.Source
local needle="return game.GameId == UNIVERSE_ID and game.PlaceId == TEST_DUNGEON_ID"
local at=assert(string.find(original,needle,1,true),
    "TEST place allowlist source changed; inspect before staging")
assert(string.find(original,"10765241947",1,true)
    and string.find(original,"117293035754309",1,true)
    and string.find(original,"134132328219009",1,true),
    "TEST release IDs differ from approved places")
assert(not string.find(original,needle,at+#needle,true),
    "Duplicate allowlist branch")
W:SetAttribute("DungeonMMOTEMPTestPublishedPlace",true)
test_release.Source=string.sub(original,1,at-1)..[=[
return (game.GameId == UNIVERSE_ID and game.PlaceId == TEST_DUNGEON_ID)
    or (game.GameId == 0 and game.PlaceId == 0
        and game:GetService("Workspace"):GetAttribute(
            "DungeonMMOTEMPTestPublishedPlace") == true)
]=]..string.sub(original,at+#needle)
-- Disable release-lock assertions only in this disposable TEMP DataModel.
-- Unmodified published composition does not serialize /Tests modules.
for _,root in ipairs({SSS.Core.Tests,SSS.Dungeon.Tests}) do
    for _,s in ipairs(root:GetDescendants()) do
        if s:IsA("Script") then s.Enabled=false end
    end
end
local release=require(test_release)
local definitions=require(shared.DungeonDefinitions)
local difficulties=require(shared.DungeonDifficultyDefinitions)
local catalog=require(shared.DungeonRuntimeContentCatalog)
local readiness=require(shared.DungeonRuntimeContentReadiness)
assert(release.is_test_dungeon(),"TEMP mock is not scoped to isolated place")
assert(definitions.get("TestDungeon").OptionalBossRuntimeEnabled==true,
    "TEST Temple optional release still locked")
assert(definitions.get("AbandonedMine").OptionalBossRuntimeEnabled==false,
    "Mine must remain unreleased")
for depth=1,4 do
    local id="Depth"..depth
    local difficulty=difficulties.get("TestDungeon",id)
    local layout=catalog.get_layout("TestDungeon",id)
    local result=readiness.analyze("TestDungeon",id)
    assert(difficulty and difficulty.RuntimeReleaseEnabled
        and layout and result.ok and result.Ready,
        "TEST Temple "..id.." not selectable/ready: "
        .. tostring(result and result.Issues and #result.Issues))
    local count=0
    for _ in pairs(layout.Slots) do count+=1 end
    local expected=if depth==1 then 5 else depth+2
    assert(count==expected,"TEST Temple "..id.." slot count")
    print("[Phase4 TEST Publish] REGISTERED "..id.." slots="..count)
end
assert(catalog.get_layout("AbandonedMine","Depth4")==nil
    and difficulties.get("AbandonedMine","Depth4").RuntimeReleaseEnabled==false,
    "Mine leaked into Temple-only TEST release")
local id= "Depth4"
W:SetAttribute("DungeonMMOStudioDungeonId","TestDungeon")
W:SetAttribute("DungeonMMOStudioDifficultyId",id)
local driver=Instance.new("Script")
driver.Name="Phase4TestReleaseDepth4Driver_TEMP"
driver.Source=[=[
local RS=game:GetService("ReplicatedStorage")
local W=game:GetService("Workspace")
local CS=game:GetService("CollectionService")
local Players=game:GetService("Players")
local STS=game:GetService("StudioTestService")
local function wait_for(fn,label,sec)
    local deadline=os.clock()+sec
    repeat
        local v=fn()
        if v then return v end
        task.wait(0.12)
    until os.clock()>deadline
    error("[Phase4 TEST Publish] TIMEOUT "..label)
end
local function anchor(id)
    return wait_for(function()
        for _,p in ipairs(CS:GetTagged("DungeonMMOEnvironmentAnchor")) do
            if p:GetAttribute("AnchorId")==id then return p end
        end
    end,id,30)
end
local function run()
    assert(game.GameId==0 and game.PlaceId==0,"TEMP place only")
    local release=require(RS.Core.Shared.DungeonTestPlaceholderRelease)
    assert(release.is_test_dungeon(),"TEST gate absent in TEMP Play")
    local ready=wait_for(function()
        return W:GetAttribute("DungeonMMODungeonEnvironmentReady")==true
    end,"published-style placeholder bootstrap",45)
    assert(ready and W:GetAttribute("DungeonMMOResolvedDifficultyId")=="Depth4"
        and W:GetAttribute("DungeonMMOResolvedEnvironmentMode")=="Synthetic",
        "TEST Depth4 did not select physical synthetic layout")
    local root=W:FindFirstChild("DungeonMMOPlaceholderPhysicalContent")
    assert(root and root:FindFirstChild("Depth4_UNREGISTERED_PREVIEW"),
        "TEST source-built Depth4 floors missing")
    anchor("Temple.Depth4.EntrySpawn")
    for n=1,6 do
        local base="Temple.Depth4.Room"..n.."."
        local checkpoint=anchor(base.."Checkpoint")
        local trigger=anchor(base.."Trigger")
        assert(checkpoint:IsA("BasePart") and trigger:IsA("BasePart"),
            "Depth4 checkpoint/trigger missing")
        if n==2 or n==4 or n==5 or n==6 then
            anchor(base.."BossSpawn")
        else
            for i=1,8 do anchor(base.."EnemySpawn."
                ..string.format("%02d",i)) end
        end
    end
    print("[Phase4 TEST Publish] LIVE_DEPTH4_PHYSICAL_BINDINGS_PASS")
    local p=wait_for(function()
        return Players:GetPlayers()[1]
    end,"TEST Play player",25)
    assert(p.Character and p.Character:FindFirstChild("HumanoidRootPart"),
        "TEST client character missing")
    local options=require(game:GetService("ServerScriptService").Core.Services.DungeonInstanceDirector).runtime_options()
    local snapshot=require(game:GetService("ServerScriptService").Core.Services.DungeonOptionalBossRunState).issue(
        "TestDungeon",os.time(),12,options,true)
    assert(snapshot.OptionalBossEventActive and snapshot.OptionalBossSecretUnlocked,
        "TEST Event/Secret practice eligibility not active")
    print("[Phase4 TEST Publish] SERVER_EVENT_SECRET_WINDOW_PASS")
end
task.spawn(function()
    local ok,err=pcall(run)
    if not ok then warn("[Phase4 TEST Publish] FAIL "..tostring(err)) end
    STS:EndTest(if ok then "PASS" else "FAIL "..tostring(err))
end)
task.delay(85,function()STS:EndTest("FAIL global timeout")end)
]=]
driver.Parent=SSS
print("[Phase4 TEST Publish] START unpublished published-ID simulation")
local ok,result=pcall(function()
    return STS:ExecutePlayModeAsync("Phase4TESTTempleDepth4_TEMP")
end)
driver:Destroy()
assert(ok and result=="PASS","TEST release TEMP simulation failed: "
    ..tostring(result))
print("[Phase4 TEST Publish] VERIFIED_DEPTH4_PUBLISHED_STYLE_PASS")
