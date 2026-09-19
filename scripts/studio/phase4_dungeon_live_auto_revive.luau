--!strict
-- Actual Humanoid death and first automatic free revive in unpublished
-- TEMP Dungeon Play. The fixture kills the character to trigger the path;
-- ordinary boss combat balancing is evaluated separately.
assert(game.PlaceId == 0 and game.GameId == 0,"Unpublished TEMP place only")
local SSS=game:GetService("ServerScriptService")
local STS=game:GetService("StudioTestService")
local runtime_script=SSS.Dungeon.DungeonRuntime
local old='local runtime = RuntimeServices.new("Dungeon")'
local source=runtime_script.Source
local i=assert(string.find(source,old,1,true),"TEMP death runtime anchor missing")
assert(not string.find(source,old,i+#old,true),"TEMP runtime hook duplicated")
runtime_script.Source=string.sub(source,1,i-1)..old
    ..'\n_G.Phase4TempDeathRuntime=runtime'
    ..string.sub(source,i+#old)
local driver=Instance.new("Script")
driver.Name="Phase4DungeonLiveRevive_TEMP"
driver.Source=[=[
local Players=game:GetService("Players")
local STS=game:GetService("StudioTestService")
local function wait_for(fn,label,seconds)
    local deadline=os.clock()+seconds
    repeat
        local value=fn()
        if value then return value end
        task.wait(0.12)
    until os.clock()>=deadline
    error("[Phase4 Live Revive] TIMEOUT "..label)
end
local function run()
    assert(game.PlaceId==0 and game.GameId==0,"TEMP place only")
    local p=wait_for(function()return Players:GetPlayers()[1] end,"player",25)
    local rt=wait_for(function()return _G.Phase4TempDeathRuntime end,"runtime",30)
    local s=wait_for(function()
        local x=rt.SessionService:get_for_user(p.UserId)
        if x and x.State=="Active" and x.Members[tostring(p.UserId)]
            and x.Members[tostring(p.UserId)].Mode=="Active"
        then return x end
    end,"active dungeon session",40)
    local id=s.SessionId
    local checkpoint=s.Checkpoint.Id
    local original=wait_for(function()
        local ch=p.Character
        if ch and ch:FindFirstChildOfClass("Humanoid")
            and ch:FindFirstChild("HumanoidRootPart")
        then return ch end
    end,"character",25)
    local hum=original:FindFirstChildOfClass("Humanoid")
    assert(hum.Health>0,"player starts alive")
    assert(s.Members[tostring(p.UserId)].FreeReviveUsed~=true,
        "free revive must be unused initially")
    hum.Health=0
    local reviving=wait_for(function()
        local x=rt.SessionService:get(id)
        local m=x and x.Members[tostring(p.UserId)]
        if m and m.FreeReviveUsed==true and m.Mode=="Reviving" then return x end
    end,"authentic death -> Reviving transition",14)
    assert(reviving.State=="Active","run must remain active during revival")
    print("[Phase4 Live Revive] FIRST_DEATH_CONSUMED_FREE_REVIVE_PASS")
    local revived=wait_for(function()
        local ch=p.Character
        local h=ch and ch:FindFirstChildOfClass("Humanoid")
        local x=rt.SessionService:get(id)
        local m=x and x.Members[tostring(p.UserId)]
        if ch and ch~=original and h and h.Health>0
            and m and m.Mode=="Active" and m.FreeReviveUsed==true
        then return ch end
    end,"live fresh character and saved active state",19)
    local after=rt.SessionService:get(id)
    assert(after.Checkpoint.Id==checkpoint,
        "automatic revive must not reset checkpoint")
    print("[Phase4 Live Revive] CHARACTER_REPLACED_AT_CHECKPOINT_PASS")
    task.wait(1)
    local second_humanoid=revived:FindFirstChildOfClass("Humanoid")
    assert(second_humanoid and second_humanoid.Health>0,
        "revived character missing living humanoid")
    second_humanoid.Health=0
    local dead_again=wait_for(function()
        local x=rt.SessionService:get(id)
        local m=x and x.Members[tostring(p.UserId)]
        if m and m.FreeReviveUsed==true
            and (m.Mode=="Dead" or m.Mode=="Spectating")
        then return x end
    end,"second death consumes no extra free revive",13)
    task.wait(3.7)
    local last=rt.SessionService:get(id)
    local member=last and last.Members[tostring(p.UserId)]
    assert(member and member.FreeReviveUsed==true
        and member.Mode~="Reviving" and member.Mode~="Active",
        "second death incorrectly auto-revived")
    print("[Phase4 Live Revive] SECOND_DEATH_NO_FREE_REVIVE_PASS")
end
task.spawn(function()
    local ok,err=pcall(run)
    if not ok then warn("[Phase4 Live Revive] FAIL "..tostring(err)) end
    STS:EndTest(if ok then "PASS" else "FAIL "..tostring(err))
end)
task.delay(95,function()STS:EndTest("FAIL global timeout")end)
]=]
driver.Parent=SSS
local ok,result=pcall(function()
    return STS:ExecutePlayModeAsync("Phase4AutoFreeRevive_TEMP")
end)
driver:Destroy()
assert(ok and result=="PASS","live revive proof failed: "..tostring(result))
print("[Phase4 Live Revive] VERIFIED_PLAY_MODE_PASS")
