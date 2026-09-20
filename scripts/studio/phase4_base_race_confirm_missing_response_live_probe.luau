--!strict
-- TEMP-only simulated dropped race confirmation. Do not send a race change
-- or mutate a player profile, live DataStore or published Roblox place.
assert(game.GameId == 0 and game.PlaceId == 0,
    "Race response timeout test must run in an unpublished local Base place")
local RS=game:GetService("ReplicatedStorage")
local SPS=game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
local SSS=game:GetService("ServerScriptService")
local STS=game:GetService("StudioTestService")
assert(SSS:FindFirstChild("Base") and not SSS:FindFirstChild("Dungeon"),
    "Race response timeout fixture must use Base place")
local original=SPS.Base.IdentitySelection
local source=original.Source
local call="    identity_selection:FireServer(kind, selection_id)"
assert(string.find(source,call,1,true),"Manual race request implementation changed")
assert(not string.find(source,call,string.find(source,call,1,true)+#call,true),
    "Unexpected duplicate manual race request")
local suppressed,count=string.gsub(source,
    "identity_selection:FireServer%(kind, selection_id%)",
    '    -- TEMP: suppress the race request; no profile write',1)
assert(count==1,"TEMP fixture did not suppress the race request")
original.Source=suppressed..[=[

-- TEMP: exercise the real manual confirmation code without synthetic clicks.
task.delay(4,function()
    if current_stage=="RaceSelection" and blocker.Visible then
        selected_race="Elf"
        send_manual_selection("Race","Elf")
        print("[Phase4 Race Timeout] MANUAL_REQUEST_SIMULATED_NO_SERVER_CALL")
    else
        warn("[Phase4 Race Timeout] FAIL initial stage "
            ..tostring(current_stage))
    end
end)
]=]
local ack=Instance.new("RemoteEvent")
ack.Name="Phase4RaceTimeoutAck_TEMP"
ack.Parent=RS
local client=Instance.new("LocalScript")
client.Name="Phase4RaceTimeoutClient_TEMP"
client.Source=[=[
local RS=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")
local ack=RS:WaitForChild("Phase4RaceTimeoutAck_TEMP")
local pg=Players.LocalPlayer:WaitForChild("PlayerGui")
local function wait_for(fn,label,sec)
    local end_at=os.clock()+sec
    repeat
        local val=fn()
        if val then return val end
        task.wait(0.1)
    until os.clock()>=end_at
    error("[Phase4 Race Timeout] FAIL "..label)
end
local gui=wait_for(function()
    return pg:FindFirstChild("IdentitySelectionUi")
end,"mandatory GUI absent",25)
local panel=gui:WaitForChild("MandatoryOverlay"):WaitForChild("SelectionPanel")
local confirm=panel:FindFirstChildOfClass("TextButton")
assert(confirm,"Confirm button missing")
local saving=wait_for(function()
    for _,v in ipairs(panel:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text=="Saving race choice..."
        then return v end
    end
end,"request was not made",17)
assert(confirm.Active==false, "button not disabled while request pending")
print("[Phase4 Race Timeout] REAL_REQUEST_PENDING_UI_PASS")
wait_for(function()
    return saving.Text=="No response from server. Press Confirm to retry."
        and confirm.Active==true and confirm.AutoButtonColor==true
end,"unanswered request did not offer a retry",19)
print("[Phase4 Race Timeout] RETRY_ENABLED_WITHOUT_PROFILE_WRITE_PASS")
ack:FireServer("PASS")
]=]
client.Parent=SPS
local server=Instance.new("Script")
server.Name="Phase4RaceTimeoutDriver_TEMP"
server.Source=[=[
local RS=game:GetService("ReplicatedStorage")
local STS=game:GetService("StudioTestService")
local ack=RS:WaitForChild("Phase4RaceTimeoutAck_TEMP")
local done=false
ack.OnServerEvent:Connect(function(_,value)
    if value=="PASS" then done=true end
end)
task.spawn(function()
    local deadline=os.clock()+45
    while os.clock()<deadline do
        if done then
            print("[Phase4 Race Timeout] LIVE_CLIENT_TIMEOUT_PASS")
            STS:EndTest("PASS")
            return
        end
        task.wait(0.2)
    end
    warn("[Phase4 Race Timeout] FAIL timeout")
    STS:EndTest("FAIL timeout")
end)
]=]
server.Parent=SSS
local ok,result=pcall(function()
    return STS:ExecutePlayModeAsync("Phase4RaceMissingAck_TEMP")
end)
server:Destroy()
client:Destroy()
ack:Destroy()
assert(ok and result=="PASS",
    "Race missing-response behavior failed: "..tostring(result))
print("[Phase4 Race Timeout] VERIFIED_PLAY_MODE_PASS")
