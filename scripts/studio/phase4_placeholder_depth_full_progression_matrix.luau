--!strict
-- All six TEMP Depth2/3/4 cases; based on the existing depth progression
-- fixture; every case uses its own isolated Studio Play-mode session.
-- Unpublished, TEMP-only full Depth2/3/4 progression using existing encounter
-- executors and real physical triggers; enemy defeats are test-assisted.
assert(game.PlaceId == 0 and game.GameId == 0, "TEMP local place only")
local W = game:GetService("Workspace")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local id = W:GetAttribute("DungeonMMOPlaceholderPreviewDungeonId")
if id ~= "TestDungeon" and id ~= "AbandonedMine" then id = "TestDungeon" end
local depth_id = W:GetAttribute("DungeonMMOStudioDifficultyId")
if depth_id ~= "Depth2" and depth_id ~= "Depth3"
    and depth_id ~= "Depth4" then depth_id = "Depth2" end
W:SetAttribute("DungeonMMOStudioDungeonId", id)
W:SetAttribute("DungeonMMOStudioDifficultyId", depth_id)
W:SetAttribute("DungeonMMOEnvironmentMode", "Synthetic")
W:SetAttribute("DungeonMMOPlaceholderPhysicalContentEnabled", true)
W:SetAttribute("DungeonMMOPlaceholderPlayableEnabled", true)
W:SetAttribute("DungeonMMOPlaceholderOptionalPlayEnabled", false)
-- The ordinary Studio regression suite verifies that higher depths are NOT
-- registered without this explicit fixture opt-in; run those suites separately.
for _, group in ipairs({SSS.Core.Tests, SSS.Dungeon.Tests}) do
    for _, child in ipairs(group:GetDescendants()) do
        if child:IsA("Script") then child.Enabled = false end
    end
end
local runtime_script = SSS.Dungeon.DungeonRuntime
local old = 'local runtime = RuntimeServices.new("Dungeon")'
local text = runtime_script.Source
local offset = assert(string.find(text,old,1,true),"TEMP runtime test hook missing")
assert(not string.find(text,old,offset+#old,true),"TEMP hook duplicated")
runtime_script.Source = string.sub(text,1,offset-1)..old
    ..'\n_G.Phase4DepthProgressionRuntime = runtime'
    ..string.sub(text,offset+#old)
local driver = Instance.new("Script")
driver.Name = "Phase4FullDepthProgression_TEMP"
driver.Source = [=[
local W=game:GetService("Workspace")
local SSS=game:GetService("ServerScriptService")
local RS=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")
local STS=game:GetService("StudioTestService")
local CS=game:GetService("CollectionService")
local function wait_for(predicate, label, seconds)
    local deadline=os.clock()+seconds
    repeat
        local value=predicate()
        if value then return value end
        task.wait(0.12)
    until os.clock()>=deadline
    error("[Phase4 Depth Full] TIMEOUT "..label)
end
local function run()
    local id=W:GetAttribute("DungeonMMOStudioDungeonId")
    local difficulty=W:GetAttribute("DungeonMMOStudioDifficultyId")
    local def=require(RS.Core.Shared.DungeonDefinitions)
    assert(def.get("TestDungeon").OptionalBossRuntimeEnabled == false)
    assert(def.get("AbandonedMine").OptionalBossRuntimeEnabled == false)
    local depth_def=require(RS.Core.Shared.DungeonDifficultyDefinitions)
        .get(id,difficulty)
    assert(depth_def and depth_def.RuntimeReleaseEnabled==false,
        "Unreleased Depth2-4 difficulty must stay locked")
    local plan=depth_def.EncounterSequence
    assert(#plan==tonumber(string.match(difficulty,"^Depth([234])$"))+2,
        "Selected difficulty must have exactly 4, 5 or 6 rooms")
    wait_for(function()
        return W:GetAttribute("DungeonMMODungeonEnvironmentReady")==true
    end,"environment bootstrap",30)
    assert(W:GetAttribute("DungeonMMOResolvedLayoutId")==difficulty)
    local player=wait_for(function()return Players:GetPlayers()[1] end,
        "Studio player",25)
    local runtime=wait_for(function()
        return _G.Phase4DepthProgressionRuntime
    end,"Dungeon runtime",20)
    local session=wait_for(function()
        local s=runtime.SessionService:get_for_user(player.UserId)
        return s and s.InstanceState and s.InstanceState.EncounterPlan and s
    end,"admitted session and frozen plan",30)
    assert(#session.InstanceState.EncounterPlan==#plan,
        "Optional encounters must not enter the release-locked depth plan")
    local root=wait_for(function()
        return player.Character
            and player.Character:FindFirstChild("HumanoidRootPart")
    end,"character",20)
    local hum=root.Parent:FindFirstChildOfClass("Humanoid")
    assert(hum and hum.Health>0,"live character missing")
    -- Assist survival so this harness isolates encounter/layout wiring, not
    -- normal damage balance; enemies are debug-defeated AFTER real spawns.
    hum.MaxHealth=100000
    hum.Health=100000
    hum.WalkSpeed=26
    local enemy_folder=wait_for(function()
        local f=W:FindFirstChild("DungeonGameplayRuntime")
        return f and f:FindFirstChild("DungeonEnemies")
    end,"Dungeon enemy container",18)
    local prefix=if id=="TestDungeon" then "Temple" else "Mine"
    local function physical(id)
        return wait_for(function()
            for _,anchor in ipairs(CS:GetTagged("DungeonMMOEnvironmentAnchor")) do
                if anchor:GetAttribute("AnchorId")==id then return anchor end
            end
        end,id,15)
    end
    local function state(encounter_id)
        local s=runtime.SessionService:get(session.SessionId)
        return s and s.InstanceState and s.InstanceState.EncounterRuntime
            and s.InstanceState.EncounterRuntime.EncounterStates[encounter_id]
    end
    local last_z=root.Position.Z
    for number,encounter in ipairs(plan) do
        local name=prefix.."."..difficulty..".Room"..number..".Trigger"
        local trigger=physical(name)
        assert(state(encounter.Id)=="Pending",
            encounter.Id.." not pending before walking")
        local destination=trigger.Position+Vector3.new(0,0,-2)
        hum:MoveTo(destination)
        wait_for(function()
            assert(hum.Health>0,"player died during temporary room traversal")
            assert(root.Position.Y > -15,"fell off the placeholder path")
            return state(encounter.Id)=="Active"
        end,encounter.Id.." physical trigger",17)
        assert(root.Position.Z <= last_z+8,
            "Encounter path moved backward rather than progressing")
        last_z=root.Position.Z
        local spawned=wait_for(function()
            local result={}
            for _,model in ipairs(enemy_folder:GetChildren()) do
                if model:IsA("Model") then
                    local h=model:FindFirstChildOfClass("Humanoid")
                    if h and h.Health>0 then table.insert(result,model) end
                end
            end
            return if #result>0 then result else nil
        end,encounter.Id.." enemy or boss spawn",12)
        if encounter.ExecutorId=="Boss" then
            assert(#spawned==1,encounter.Id.." expected one boss")
            local model=spawned[1]
            assert(model:GetAttribute("BossId")==encounter.BossId,
                encounter.Id.." spawned unexpected boss")
            if encounter.Kind=="MiniBoss" then
                assert(model:GetAttribute("DungeonBossRole")=="MiniBoss",
                    encounter.Id.." previous boss not designated MiniBoss")
            end
            print("[Phase4 Depth Full] BOSS "..id.." "..difficulty
                .." "..encounter.Id.." id="..encounter.BossId)
        end
        for _,model in ipairs(spawned) do
            model:FindFirstChildOfClass("Humanoid").Health=0
        end
        wait_for(function()
            return state(encounter.Id)=="Cleared"
        end,encounter.Id.." completion",13)
        print("[Phase4 Depth Full] CLEARED "..id.." "..difficulty
            .." "..encounter.Id.." room="..number.."/"..#plan)
    end
    local finished=wait_for(function()
        local s=runtime.SessionService:get(session.SessionId)
        return s and s.State=="Complete" and s
    end,"Dungeon completion",15)
    assert(finished.InstanceState.EncounterPlan
        and #finished.InstanceState.EncounterPlan==#plan)
    print("[Phase4 Depth Full] PASS "..id.." "..difficulty
        .." rooms="..#plan.." completed with assisted enemy defeats")
end
task.spawn(function()
    local ok,err=pcall(run)
    if not ok then warn("[Phase4 Depth Full] FAIL "..tostring(err)) end
    STS:EndTest(if ok then "PASS" else "FAIL "..tostring(err))
end)
task.delay(125,function()STS:EndTest("FAIL global timeout")end)
]=]
driver.Parent=SSS
-- Each Play-mode session uses an independent disposable server; all
-- six scenarios share only the edit-mode fixture, not run state or profiles.
local scenarios = {
    {"TestDungeon", "Depth2"},
    {"TestDungeon", "Depth3"},
    {"TestDungeon", "Depth4"},
    {"AbandonedMine", "Depth2"},
    {"AbandonedMine", "Depth3"},
    {"AbandonedMine", "Depth4"},
}
for _, scenario in ipairs(scenarios) do
    local dungeon_id, difficulty_id = scenario[1], scenario[2]
    W:SetAttribute("DungeonMMOPlaceholderPreviewDungeonId", dungeon_id)
    W:SetAttribute("DungeonMMOStudioDungeonId", dungeon_id)
    W:SetAttribute("DungeonMMOStudioDifficultyId", difficulty_id)
    print("[Phase4 Depth Matrix] START "..dungeon_id.." "..difficulty_id)
    local ok, result = pcall(function()
        return STS:ExecutePlayModeAsync(
            "DepthMatrix_TEMP_"..dungeon_id.."_"..difficulty_id
        )
    end)
    assert(ok and result == "PASS",
        "Physical depth matrix failed: "..dungeon_id.." "
            ..difficulty_id.." "..tostring(result))
    print("[Phase4 Depth Matrix] VERIFIED_PLAY_MODE_PASS "
        ..dungeon_id.." "..difficulty_id)
end
driver:Destroy()
print("[Phase4 Depth Matrix] PASS: 6 physical dungeon/depth scenarios.")
