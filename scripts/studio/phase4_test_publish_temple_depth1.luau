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
W:SetAttribute("DungeonMMOStudioDungeonId","TestDungeon")
W:SetAttribute("DungeonMMOStudioDifficultyId","Depth1")
local dungeon_runtime=SSS.Dungeon.DungeonRuntime
local source=dungeon_runtime.Source
local needle='local runtime = RuntimeServices.new("Dungeon")'
local pos=assert(string.find(source,needle,1,true),
    "Runtime service initialization source changed")
dungeon_runtime.Source=string.sub(source,1,pos-1)
    ..needle.."\\n_G.Phase4TEMPTestDungeonRuntime=runtime"
    ..string.sub(source,pos+#needle)
local driver=Instance.new("Script")
driver.Name="Phase4TestTempleDepth1Driver_TEMP"
driver.Source=[=[
local RS=game:GetService("ReplicatedStorage")
local W=game:GetService("Workspace")
local CS=game:GetService("CollectionService")
local Players=game:GetService("Players")
local STS=game:GetService("StudioTestService")
local function wait_for(fn,label,seconds)
    local deadline=os.clock()+seconds
    repeat
        local value=fn()
        if value then return value end
        task.wait(0.12)
    until os.clock()>=deadline
    error("[Phase4 TEST Depth1] TIMEOUT "..label)
end
local function anchor(id)
    return wait_for(function()
        for _,part in ipairs(CS:GetTagged("DungeonMMOEnvironmentAnchor")) do
            if part:GetAttribute("AnchorId")==id then return part end
        end
    end,id,24)
end
local function run()
    assert(game.PlaceId==0 and game.GameId==0,
        "Test fixture must remain unpublished")
    assert(require(RS.Core.Shared.DungeonTestPlaceholderRelease)
        .is_test_dungeon(),"TEST allowlist not simulated")
    wait_for(function()
        return W:GetAttribute("DungeonMMODungeonEnvironmentReady")==true
    end,"published-style Depth1 synthetic environment",38)
    assert(W:GetAttribute("DungeonMMOResolvedDifficultyId")=="Depth1"
        and W:GetAttribute("DungeonMMOResolvedEnvironmentMode")=="Synthetic",
        "TEST Depth1 environment selection incorrect")
    local geometry=W:FindFirstChild("DungeonMMOPlaceholderPhysicalContent")
    assert(geometry and geometry:FindFirstChild("EventArena")
        and geometry:FindFirstChild("SecretArena")
        and geometry:FindFirstChild("EventBridge")
        and geometry:FindFirstChild("SecretBridge"),
        "TEST Depth1 side-room geometry missing")
    for _,kind in ipairs({"Event","Secret"}) do
        anchor("Temple."..kind..".Trigger")
        anchor("Temple."..kind..".Checkpoint")
        anchor("Temple."..kind..".BossSpawn")
    end
    print("[Phase4 TEST Depth1] OPTIONAL_PHYSICAL_ROOMS_PASS")
    local p=wait_for(function()
        return Players:GetPlayers()[1]
    end,"real test player",25)
    wait_for(function()
        local ch=p.Character
        return ch and ch:FindFirstChild("HumanoidRootPart")
    end,"spawned test character",28)
    local services=wait_for(function()
        return _G.Phase4TEMPTestDungeonRuntime
    end,"Dungeon runtime services",30)
    local session=wait_for(function()
        local s=services.SessionService:get_for_user(p.UserId)
        if s and s.State=="Active" then return s end
    end,"active Temple session",35)
    local state=session.InstanceState
    assert(state and state.OptionalBossEnabled==true
        and state.OptionalBossEventActive==true
        and state.OptionalBossSecretUnlocked==true,
        "TEST Depth1 server did not issue Event and Secret eligibility")
    print("[Phase4 TEST Depth1] LIVE_SESSION_OPTIONAL_BOSSES_PASS")
    local layout=require(RS.Core.Shared.DungeonRuntimeContentCatalog)
        .get_layout("TestDungeon","Depth1")
    assert(layout and layout.Slots.EventArena
        and layout.Slots.SecretArena,"TEST layout missing optional slots")
    print("[Phase4 TEST Depth1] REAL_PLAYER_SPAWN_AND_LAYOUT_PASS")
end
task.spawn(function()
    local ok,err=pcall(run)
    if not ok then warn("[Phase4 TEST Depth1] FAIL "..tostring(err)) end
    STS:EndTest(if ok then "PASS" else "FAIL "..tostring(err))
end)
task.delay(95,function() STS:EndTest("FAIL global timeout") end)
]=]
driver.Parent=SSS
local ok,result=pcall(function()
    return STS:ExecutePlayModeAsync("Phase4TESTTempleDepth1_TEMP")
end)
driver:Destroy()
assert(ok and result=="PASS",
    "TEST Temple optional-room preview failed: "..tostring(result))
print("[Phase4 TEST Depth1] VERIFIED_PUBLISHED_STYLE_PASS")
