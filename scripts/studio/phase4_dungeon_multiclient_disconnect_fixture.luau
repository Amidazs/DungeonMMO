--!strict
-- TEMP unregistered local Dungeon place; verifies real Studio multiplayer
-- PlayerRemoving persists the departing dungeon party member's connection flag.
-- Deliberately does not impersonate an existing Roblox UserId or publish.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Dungeon multiplayer test requires an unpublished TEMP local place.")
local SSS=game:GetService("ServerScriptService")
local RS=game:GetService("ReplicatedStorage")
local SPS=game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
local STS=game:GetService("StudioTestService")
local dungeon=SSS:WaitForChild("Dungeon")

local function replace_once(source: LuaSourceContainer, old: string, new: string)
    local text=source.Source
    local at=assert(string.find(text,old,1,true), "TEMP source anchor absent: "..source.Name)
    assert(not string.find(text,old,at+#old,true), "TEMP source anchor duplicated: "..source.Name)
    source.Source=string.sub(text,1,at-1)..new..string.sub(text,at+#old)
end
replace_once(dungeon.DungeonRuntime,
    'local runtime = RuntimeServices.new("Dungeon")',
    'local runtime = RuntimeServices.new("Dungeon")\n'
        .. '_G.Phase4TempDungeonPartyRuntime = runtime')
-- Force two synthetic Studio clients into the same TEST-ONLY session; no
-- production admission/party service source is changed in the repository.
replace_once(dungeon.DungeonRuntime,
    '    if RunService:IsStudio() then\n'
        .. '        local studio = StudioSessionFactory.create_for_players(\n'
        .. '            {player},',
    '    if RunService:IsStudio() then\n'
        .. '        while #Players:GetPlayers() < 2 do task.wait(0.1) end\n'
        .. '        local studio = StudioSessionFactory.create_for_players(\n'
        .. '            Players:GetPlayers(),')

local client=Instance.new("LocalScript")
client.Name="Phase4DungeonPartyLeave_TEMP"
client.Source=[=[
local Players=game:GetService("Players")
local STS=game:GetService("StudioTestService")
local me=Players.LocalPlayer
local function maybe_leave()
    if me:GetAttribute("Phase4DungeonLeave") ~= true then return end
    assert(STS:CanLeaveTest(), "client cannot leave this Studio test")
    print("[Phase4 Dungeon Real Leave] CLIENT_REQUEST " .. me.UserId)
    STS:LeaveTest()
end
me:GetAttributeChangedSignal("Phase4DungeonLeave"):Connect(maybe_leave)
maybe_leave()
]=]
client.Parent=SPS

local server=Instance.new("Script")
server.Name="Phase4DungeonPartyDisconnect_TEMP"
server.Source=[=[
local Players=game:GetService("Players")
local STS=game:GetService("StudioTestService")
local RS=game:GetService("ReplicatedStorage")
local SSS=game:GetService("ServerScriptService")
local function until_value(predicate, reason, seconds)
    local deadline=os.clock()+seconds
    repeat
        local value=predicate()
        if value then return value end
        task.wait(0.1)
    until os.clock()>deadline
    error("[Phase4 Dungeon Real Leave] TIMEOUT "..reason)
end
local function run()
    assert(game.PlaceId==0 and game.GameId==0,
        "fixture must remain unpublished")
    local definitions=require(RS.Core.Shared.DungeonDefinitions)
    for _, id in ipairs({"TestDungeon","AbandonedMine"}) do
        assert(definitions.get(id).OptionalBossRuntimeEnabled==false,
            "optional boss rollout must stay off "..id)
    end
    local members=until_value(function()
        local list=Players:GetPlayers()
        if #list==2 then return list end
    end,"two clients",35)
    local departing, remaining=members[1],members[2]
    assert(departing.UserId~=remaining.UserId,"distinct Studio user IDs required")
    local runtime=until_value(function()
        return _G.Phase4TempDungeonPartyRuntime
    end,"actual Dungeon runtime",25)
    local session=until_value(function()
        local s=runtime.SessionService:get_for_user(departing.UserId)
        if s and s.State=="Active"
            and s.Members[tostring(departing.UserId)]
            and s.Members[tostring(departing.UserId)].Connected
            and s.Members[tostring(remaining.UserId)]
            and s.Members[tostring(remaining.UserId)].Connected
        then return s end
    end,"both admitted into same authoritative session",45)
    local id=session.SessionId
    local saved_checkpoint=session.Checkpoint.Id
    local plan=session.InstanceState.EncounterPlan
    assert(type(plan)=="table" and #plan>=3,"dungeon plan missing")
    print("[Phase4 Dungeon Real Leave] ADMITTED_TWO_REAL_CLIENTS "..id)
    departing:SetAttribute("Phase4DungeonLeave",true)
    until_value(function()
        return Players:GetPlayerByUserId(departing.UserId)==nil
    end,"client actually leaves multiplayer test",25)
    local after=until_value(function()
        local s=runtime.SessionService:get(id)
        if s and s.Members[tostring(departing.UserId)]
            and s.Members[tostring(departing.UserId)].Connected==false
        then return s end
    end,"DungeonRuntime PlayerRemoving saved disconnection",18)
    assert(after.State=="Active","remaining party member must keep run active")
    assert(after.Members[tostring(remaining.UserId)].Connected==true,
        "remaining party member must stay connected")
    assert(after.Checkpoint.Id==saved_checkpoint,
        "actual client leave must not reset party checkpoint")
    assert(after.InstanceState.EncounterPlan[1].Id==plan[1].Id,
        "actual client leave must preserve frozen encounter plan")
    print("[Phase4 Dungeon Real Leave] SAVED_MEMBER_DISCONNECT_PASS")
    print("[Phase4 Dungeon Real Leave] PEER_SESSION_AND_PLAN_PRESERVED")
    print("[Phase4 Dungeon Real Leave] SAME_USER_REJOIN_NOT_TESTED")
end
task.spawn(function()
    local ok,reason=pcall(run)
    if not ok then warn("[Phase4 Dungeon Real Leave] FAIL "..tostring(reason)) end
    STS:EndTest(if ok then "PASS" else "FAIL "..tostring(reason))
end)
task.delay(120,function() STS:EndTest("FAIL global timeout") end)
]=]
server.Parent=SSS
print("[Phase4 Dungeon Real Leave] START")
local ok,result=pcall(function()
    return STS:ExecuteMultiplayerTestAsync(2,"DungeonRealLeave_TEMP")
end)
server:Destroy()
client:Destroy()
assert(ok and result=="PASS", "Dungeon real-leave test failed: "..tostring(result))
print("[Phase4 Dungeon Real Leave] MULTIPLAYER_SAVED_DISCONNECT_PASS")
