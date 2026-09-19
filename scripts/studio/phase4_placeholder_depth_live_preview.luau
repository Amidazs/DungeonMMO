--!strict
-- TEMP-only Dungeon Studio RunScript. Set Workspace attributes before this
-- runner to choose TestDungeon/AbandonedMine and Depth2/3/4.
assert(game.PlaceId==0 and game.GameId==0,
    "Refusing published place: placeholder depth Play test is TEMP-only")
local W=game:GetService("Workspace")
local SSS=game:GetService("ServerScriptService")
local RS=game:GetService("ReplicatedStorage")
local STS=game:GetService("StudioTestService")
local id=W:GetAttribute("DungeonMMOPlaceholderPreviewDungeonId")
if id~="TestDungeon" and id~="AbandonedMine" then id="TestDungeon" end
local difficulty=W:GetAttribute("DungeonMMOStudioDifficultyId")
if difficulty~="Depth2" and difficulty~="Depth3"
    and difficulty~="Depth4" then difficulty="Depth2" end
W:SetAttribute("DungeonMMOStudioDungeonId",id)
W:SetAttribute("DungeonMMOStudioDifficultyId",difficulty)
W:SetAttribute("DungeonMMOEnvironmentMode","Synthetic")
W:SetAttribute("DungeonMMOPlaceholderPhysicalContentEnabled",true)
W:SetAttribute("DungeonMMOPlaceholderPlayableEnabled",true)
W:SetAttribute("DungeonMMOPlaceholderOptionalPlayEnabled",false)
-- Existing in-place editor regression scripts assert Depth2-4 are
-- unregistered in the default game. They are exercised on normal builds,
-- not inside this deliberately opted-in temporary depth sandbox.
for _,group in ipairs({SSS.Core.Tests,SSS.Dungeon.Tests}) do
    for _,child in ipairs(group:GetDescendants()) do
        if child:IsA("Script") then child.Enabled=false end
    end
end

local source=Instance.new("Script")
source.Name="Phase4PlayableDepth_TEMP"
source.Source=[=[
local Players=game:GetService("Players")
local W=game:GetService("Workspace")
local SSS=game:GetService("ServerScriptService")
local RS=game:GetService("ReplicatedStorage")
local STS=game:GetService("StudioTestService")
local CS=game:GetService("CollectionService")
local function wait_for(fn,what,seconds)
    local deadline=os.clock()+seconds
    repeat
        local v=fn()
        if v then return v end
        task.wait(0.1)
    until os.clock()>=deadline
    error("[Phase4 Playable Depth] TIMEOUT "..what)
end
local function run()
    local id=W:GetAttribute("DungeonMMOStudioDungeonId")
    local difficulty=W:GetAttribute("DungeonMMOStudioDifficultyId")
    local count=tonumber(string.match(difficulty,"^Depth([234])$"))+2
    assert(game.PlaceId==0 and game.GameId==0)
    local defs=require(RS.Core.Shared.DungeonDefinitions)
    assert(defs.get("TestDungeon").OptionalBossRuntimeEnabled==false)
    assert(defs.get("AbandonedMine").OptionalBossRuntimeEnabled==false)
    local difficulty_def=require(RS.Core.Shared.DungeonDifficultyDefinitions)
        .get(id,difficulty)
    assert(difficulty_def.RuntimeReleaseEnabled==false,
        "TEMP preview must never lift higher-depth release lock")
    wait_for(function()
        return W:GetAttribute("DungeonMMODungeonEnvironmentReady")==true
    end,"environment ready",35)
    assert(W:GetAttribute("DungeonMMOResolvedDungeonId")==id)
    assert(W:GetAttribute("DungeonMMOResolvedLayoutId")==difficulty)
    local geometry=wait_for(function()
        return W:FindFirstChild("DungeonMMOPlaceholderPhysicalContent")
    end,"placeholder geometry",16)
    local group=geometry:FindFirstChild(
        difficulty.."_UNREGISTERED_PREVIEW")
    assert(group and group:GetAttribute(
        "DungeonMMOPhysicalLayoutRegistered")==false,
        "physical preview must not claim released")
    local parent=W:FindFirstChild("DungeonMMOEnvironmentAnchors")
    assert(parent,"generated anchor folder missing")
    local prefix=if id=="TestDungeon" then "Temple" else "Mine"
    local room_count=0
    for index=1,count do
        local room_id=prefix.."_"..difficulty.."_Room"..index.."_"
        local trigger=parent:FindFirstChild(room_id.."Trigger")
        local checkpoint=parent:FindFirstChild(room_id.."Checkpoint")
        assert(trigger and trigger.CanTouch and checkpoint,
            room_id.." physical binding missing or not active")
        room_count+=1
    end
    local player=wait_for(function()return Players:GetPlayers()[1] end,
        "Studio player",28)
    local root=wait_for(function()
        return player.Character
            and player.Character:FindFirstChild("HumanoidRootPart")
    end,"character",25)
    wait_for(function()
        return W:FindFirstChild("DungeonGameplayRuntime")
            and player.Character and player.Character.Parent
    end,"Dungeon runtime and character",30)
    local first=parent:FindFirstChild(
        prefix.."_"..difficulty.."_Room1_Trigger")
    local humanoid=root.Parent:FindFirstChildOfClass("Humanoid")
    assert(humanoid and humanoid.Health>0,"player must be alive")
    -- Normal live Humanoid movement: no player CFrame relocation.
    humanoid:MoveTo(first.Position+Vector3.new(0,0,-2))
    wait_for(function()
        local container=W:FindFirstChild("DungeonGameplayRuntime")
        local enemies=container
            and container:FindFirstChild("DungeonEnemies")
        return enemies and #enemies:GetChildren()>=2
    end,"first encounter physical trigger and enemy spawn",17)
    print("[Phase4 Playable Depth] FIRST_ENCOUNTER_SPAWN_PASS "
        ..id.." "..difficulty)
    print("[Phase4 Playable Depth] PASS "..id.." "..difficulty
        .." rooms="..room_count.." first encounter active; release locked")
end
task.spawn(function()
    local ok,err=pcall(run)
    if not ok then warn("[Phase4 Playable Depth] FAIL "..tostring(err)) end
    STS:EndTest(if ok then "PASS" else "FAIL "..tostring(err))
end)
task.delay(105,function()STS:EndTest("FAIL global timeout")end)
]=]
source.Parent=SSS
print("[Phase4 Playable Depth] START "..id.." "..difficulty)
local ok,result=pcall(function()
    return STS:ExecutePlayModeAsync("PlayableDepth_TEMP_"..id.."_"..difficulty)
end)
source:Destroy()
assert(ok and result=="PASS",
    "Play-mode placeholder dungeon failed: "..tostring(result))
print("[Phase4 Playable Depth] VERIFIED_PLAY_MODE_PASS "..id.." "..difficulty)
