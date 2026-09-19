--!strict
-- RunScript on an unpublished TEMP local dungeon .rbxl.
-- Override DungeonMMOStudioDungeonId in this script to preview Mine instead.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Placeholder Play preview must not target published Roblox places.")
local W = game:GetService("Workspace")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local id = W:GetAttribute("DungeonMMOPlaceholderPreviewDungeonId")
if id ~= "TestDungeon" and id ~= "AbandonedMine" then
    id = "TestDungeon"
end
W:SetAttribute("DungeonMMOStudioDungeonId", id)
W:SetAttribute("DungeonMMOEnvironmentMode", "Synthetic")
W:SetAttribute("DungeonMMOPlaceholderPhysicalContentEnabled", true)
local driver = Instance.new("Script")
driver.Name = "Phase4PlaceholderLivePreview_TEMP"
driver.Source = [=[
local W=game:GetService("Workspace")
local SSS=game:GetService("ServerScriptService")
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local STS=game:GetService("StudioTestService")
local function wait_for(predicate, label, seconds)
    local deadline=os.clock()+seconds
    repeat
        local v=predicate()
        if v then return v end
        task.wait(0.1)
    until os.clock()>deadline
    error("[Phase4 Placeholder Live] TIMEOUT "..label)
end
local function run()
    local id=W:GetAttribute("DungeonMMOStudioDungeonId")
    assert(id=="TestDungeon" or id=="AbandonedMine",
        "Unexpected preview dungeon")
    local definition=require(RS.Core.Shared.DungeonDefinitions)
    assert(definition.get("TestDungeon").OptionalBossRuntimeEnabled==false)
    assert(definition.get("AbandonedMine").OptionalBossRuntimeEnabled==false)
    wait_for(function()
        return W:GetAttribute("DungeonMMODungeonEnvironmentReady")==true
    end,"layout/bootstrap",28)
    assert(W:GetAttribute("DungeonMMOResolvedLayoutId")=="Depth1",
        "Placeholder preview must not unlock higher depths")
    local model=wait_for(function()
        return W:FindFirstChild("DungeonMMOPlaceholderPhysicalContent")
    end,"physical placeholder models",18)
    assert(model:GetAttribute("DungeonMMODungeonId")==id)
    assert(model:FindFirstChild("EventArena") and
        model:FindFirstChild("SecretArena") and
        model:FindFirstChild("Depth4_UNREGISTERED_PREVIEW"),
        "Expected optional and higher-depth blockout not generated")
    local parent=W:FindFirstChild("DungeonMMOEnvironmentAnchors")
    assert(parent~=nil,"Physical anchor folder missing")
    local prefix=if id=="TestDungeon" then "Temple" else "Mine"
    for _,kind in ipairs({"Event","Secret"}) do
        local trigger=parent:FindFirstChild(prefix.."_"..kind.."_Trigger")
        assert(trigger and trigger:GetAttribute("AnchorId")
            ==prefix.."."..kind..".Trigger"
            and not trigger.CanTouch and not trigger.CanCollide,
            kind.." placeholder trigger must remain inactive")
    end
    local room1=parent:FindFirstChild(prefix.."_Room1_Trigger")
    assert(room1 and room1.CanTouch,
        "Regular Depth1 trigger should still activate")
    local player=wait_for(function()
        return Players:GetPlayers()[1]
    end,"player spawned",30)
    wait_for(function()
        return player.Character and
            player.Character:FindFirstChild("HumanoidRootPart")
    end,"live player character",22)
    print("[Phase4 Placeholder Live] PASS "..id
        .." normal Depth1 active; optional+high-depth blockouts present"
        .." but gameplay locked.")
end
task.spawn(function()
    local ok,err=pcall(run)
    if not ok then warn("[Phase4 Placeholder Live] FAIL "..tostring(err)) end
    STS:EndTest(if ok then "PASS" else "FAIL "..tostring(err))
end)
task.delay(95,function() STS:EndTest("FAIL global timeout") end)
]=]
driver.Parent = SSS
print("[Phase4 Placeholder Live] START " .. id)
local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("Phase4Placeholder_TEMP_" .. id)
end)
driver:Destroy()
assert(ok and result == "PASS",
    "TEMP placeholder Play failed: " .. tostring(result))
print("[Phase4 Placeholder Live] VERIFIED_PLAY_MODE_PASS " .. id)
