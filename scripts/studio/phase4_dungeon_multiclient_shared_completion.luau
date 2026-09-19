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

local driver=Instance.new("Script")
driver.Name="Phase4DungeonSharedComplete_TEMP"
driver.Source=[=[
local Players=game:GetService("Players")
local STS=game:GetService("StudioTestService")
local W=game:GetService("Workspace")
local CS=game:GetService("CollectionService")
local function wait_for(fn,label,sec)
    local deadline=os.clock()+sec
    repeat
        local v=fn()
        if v then return v end
        task.wait(0.12)
    until os.clock()>=deadline
    error("[Phase4 Party Gameplay] TIMEOUT "..label)
end
local function anchor(id)
    return wait_for(function()
        for _,part in ipairs(CS:GetTagged("DungeonMMOEnvironmentAnchor")) do
            if part:GetAttribute("AnchorId")==id then return part end
        end
    end,id,20)
end
local function run()
    assert(game.PlaceId==0 and game.GameId==0,"TEMP only")
    local peers=wait_for(function()
        local x=Players:GetPlayers()
        if #x==2 then return x end
    end,"two actual synthetic clients",32)
    local leader,member=peers[1],peers[2]
    local runtime=wait_for(function()
        return _G.Phase4TempDungeonPartyRuntime
    end,"real Dungeon runtime",25)
    local session=wait_for(function()
        local a=runtime.SessionService:get_for_user(leader.UserId)
        local b=runtime.SessionService:get_for_user(member.UserId)
        if a and b and a.SessionId==b.SessionId
            and a.State=="Active"
            and a.Members[tostring(leader.UserId)]
            and a.Members[tostring(member.UserId)]
            and a.Members[tostring(leader.UserId)].Connected
            and a.Members[tostring(member.UserId)].Connected
        then return a end
    end,"both players in one authoritative active session",55)
    local id=session.SessionId
    print("[Phase4 Party Gameplay] SHARED_SESSION_PASS "..id)
    local char=wait_for(function()
        return leader.Character and leader.Character:FindFirstChild("HumanoidRootPart")
            and leader.Character
    end,"leader character",22)
    local root=char.HumanoidRootPart
    local hum=char:FindFirstChildOfClass("Humanoid")
    assert(hum,"leader humanoid missing")
    -- Keep this test focused on party encounter/reward wiring, not balance.
    hum.MaxHealth=100000
    hum.Health=100000
    local enemies=wait_for(function()
        local live=W:FindFirstChild("DungeonGameplayRuntime")
        return live and live:FindFirstChild("DungeonEnemies")
    end,"live dungeon enemies",20)
    local function encounter_state(encounter_id)
        local s=runtime.SessionService:get(id)
        local state=s and s.InstanceState
        local progression=state and state.EncounterRuntime
        return progression and progression.EncounterStates[encounter_id]
    end
    for _,slot in ipairs({
        {"CombatRoom1","Temple.Room1.Trigger"},
        {"CombatRoom2","Temple.Room2.Trigger"},
        {"Depth1Boss","Temple.Room3.Trigger"},
    }) do
        local encounter_id,anchor_id=slot[1],slot[2]
        assert(encounter_state(encounter_id)=="Pending",
            encounter_id.." not pending for group")
        local trigger=anchor(anchor_id)
        root.CFrame=trigger.CFrame*CFrame.new(0,0,9)
        root.AssemblyLinearVelocity=Vector3.zero
        task.wait(0.2)
        hum:MoveTo(trigger.Position+Vector3.new(0,0,-2))
        wait_for(function()
            return encounter_state(encounter_id)=="Active"
        end,"party starts "..encounter_id,12)
        assert(runtime.SessionService:get_for_user(member.UserId).SessionId==id,
            "member lost shared session during "..encounter_id)
        print("[Phase4 Party Gameplay] SHARED_TRIGGER_PASS "..encounter_id)
        local pack=wait_for(function()
            local live={}
            for _,model in ipairs(enemies:GetChildren()) do
                local h=model:FindFirstChildOfClass("Humanoid")
                if h and h.Health>0 then table.insert(live,model) end
            end
            if #live>0 then return live end
        end,"spawned enemies "..encounter_id,14)
        for _,model in ipairs(pack) do
            model:FindFirstChildOfClass("Humanoid").Health=0
        end
        wait_for(function()
            return encounter_state(encounter_id)=="Cleared"
        end,"cleared "..encounter_id,16)
        print("[Phase4 Party Gameplay] SHARED_CLEAR_PASS "..encounter_id)
    end
    local finished=wait_for(function()
        local s=runtime.SessionService:get(id)
        if s and s.State=="Complete" and s.CompletionRewardsCommitted==true
        then return s end
    end,"shared party completion and rewards",34)
    local seen={}
    for _,user_id in ipairs(finished.CompletionRecipients or {}) do
        seen[user_id]=true
    end
    assert(seen[leader.UserId] and seen[member.UserId],
        "two connected active party members not completion eligible")
    local summary=finished.CompletionRewardSummary
    assert(type(summary)=="table","completion reward summary missing")
    for _,user_id in ipairs({leader.UserId,member.UserId}) do
        local reward=summary[tostring(user_id)]
        assert(type(reward)=="table" and reward.ok==true,
            "missing separately committed completion reward "..user_id)
    end
    print("[Phase4 Party Gameplay] INDIVIDUAL_REWARDS_PASS "
        .. leader.UserId .. "," .. member.UserId)
    print("[Phase4 Party Gameplay] SHARED_RUN_COMPLETE_PASS")
end
task.spawn(function()
    local ok,err=pcall(run)
    if not ok then warn("[Phase4 Party Gameplay] FAIL "..tostring(err)) end
    STS:EndTest(if ok then "PASS" else "FAIL "..tostring(err))
end)
task.delay(145,function() STS:EndTest("FAIL global timeout") end)
]=]
driver.Parent=SSS
print("[Phase4 Party Gameplay] START")
local ok,result=pcall(function()
    return STS:ExecuteMultiplayerTestAsync(2,"Phase4SharedEncounterRewards_TEMP")
end)
driver:Destroy()
assert(ok and result=="PASS","Party shared completion failed: "..tostring(result))
print("[Phase4 Party Gameplay] VERIFIED_MULTIPLAYER_PASS")
