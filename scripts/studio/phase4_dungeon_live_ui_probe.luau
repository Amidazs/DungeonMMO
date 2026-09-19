--!strict
-- TEMP unpublished local Dungeon UI probe. The server sends synthetic
-- UI state packets through existing remotes; no economy grants are made.
assert(game.PlaceId == 0 and game.GameId == 0, "Unpublished TEMP place only.")
local RS=game:GetService("ReplicatedStorage")
local SSS=game:GetService("ServerScriptService")
local SPS=game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
local STS=game:GetService("StudioTestService")
local ack=Instance.new("RemoteEvent")
ack.Name="Phase4UiAck_TEMP"
ack.Parent=RS
local client=Instance.new("LocalScript")
client.Name="Phase4DungeonUiSmoke_TEMP"
client.Source=[=[
local RS=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")
local me=Players.LocalPlayer
local ack=RS:WaitForChild("Phase4UiAck_TEMP")
local function until_value(fn,label,sec)
    local deadline=os.clock()+sec
    repeat
        local value=fn()
        if value then return value end
        task.wait(0.1)
    until os.clock()>deadline
    error("[Phase4 UI Probe] TIMEOUT "..label)
end
local gui=until_value(function()
    local player_gui=me:FindFirstChildOfClass("PlayerGui")
    return player_gui and player_gui:FindFirstChild("DungeonUi")
end,"real client DungeonUi",28)
assert(gui:IsA("ScreenGui") and gui.Enabled,
    "Dungeon UI missing or disabled")
local function label(text)
    for _,item in ipairs(gui:GetDescendants()) do
        if item:IsA("TextLabel") and item.Text==text then
            return item
        end
    end
end
assert(label("DUNGEON COMPLETE"),"completion screen missing")
local boss_name=label("Marauder Captain")
assert(boss_name and boss_name.Parent and boss_name.Parent:IsA("Frame"),
    "boss health widget missing")
local boss_frame=boss_name.Parent
local objective=until_value(function()
    for _,item in ipairs(gui:GetDescendants()) do
        if item:IsA("TextLabel") and item.Text=="Dungeon loading..." then
            return item
        end
    end
end,"initial objective",10)
ack:FireServer("READY")
until_value(function()
    return objective.Text=="Defeat the Eclipse Keeper"
        and boss_frame.Visible
        and boss_name.Text=="Eclipse Keeper"
end,"boss objective and health UI",15)
local boss_back=boss_frame:FindFirstChildOfClass("Frame")
local fill=boss_back and boss_back:FindFirstChildOfClass("Frame")
assert(fill and math.abs(fill.Size.X.Scale-0.5)<0.02,
    "boss 30/60 health bar is not half full")
print("[Phase4 UI Probe] BOSS_WIDGET_PASS")
ack:FireServer("BOSS_PASS")
until_value(function()
    return boss_frame.Visible==false
        and objective.Text=="Dungeon complete"
        and label("DUNGEON COMPLETE").Parent.Visible
        and label("Completion Gold: +73")~=nil
end,"completion reward and result screen",15)
print("[Phase4 UI Probe] COMPLETION_REWARD_WIDGET_PASS")
ack:FireServer("COMPLETE_PASS")
until_value(function()
    local title=label("DEFEATED")
    return title and title.Parent.Visible
        and boss_frame.Visible==false
end,"revive panel",15)
local free_button=nil
for _,item in ipairs(gui:GetDescendants()) do
    if item:IsA("TextButton") and item.Text=="Free Revive" then
        free_button=item
        break
    end
end
assert(free_button and free_button.Active,
    "available free revive button not interactive")
print("[Phase4 UI Probe] REVIVE_WIDGET_PASS")
ack:FireServer("REVIVE_PASS")
]=]
client.Parent=SPS
local server=Instance.new("Script")
server.Name="Phase4DungeonUiDriver_TEMP"
server.Source=[=[
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local STS=game:GetService("StudioTestService")
local ack=RS:WaitForChild("Phase4UiAck_TEMP")
local state=RS.Core.Remotes:WaitForChild("DungeonStateChanged")
local revive=RS.Core.Remotes:WaitForChild("ReviveStateChanged")
local function until_ack(player,expected,sec)
    local completed=false
    local conn=ack.OnServerEvent:Connect(function(who,what)
        if who==player and what==expected then completed=true end
    end)
    local deadline=os.clock()+sec
    repeat
        if completed then break end
        task.wait(0.1)
    until os.clock()>deadline
    conn:Disconnect()
    assert(completed,"[Phase4 UI Probe] TIMEOUT acknowledgement "..expected)
end
local function run()
    assert(game.PlaceId==0 and game.GameId==0,
        "UI state probe must never run on published place")
    local player=Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
    until_ack(player,"READY",35)
    state:FireClient(player,{
        state="Boss",objective="Defeat the Eclipse Keeper",
        boss_name="Eclipse Keeper",boss_health=30,boss_max_health=60
    })
    until_ack(player,"BOSS_PASS",15)
    state:FireClient(player,{
        state="Complete",objective="Dungeon complete",
        completion_eligible=true,
        completion={gold_granted=73,item_id="PlaceholderShard"}
    })
    until_ack(player,"COMPLETE_PASS",15)
    revive:FireClient(player,{
        member_mode="Dead",free_available=true,
        server_time=os.time(),wipe_ends_at=os.time()+30
    })
    until_ack(player,"REVIVE_PASS",15)
    print("[Phase4 UI Probe] LIVE_CLIENT_UI_STATE_PASS")
end
task.spawn(function()
    local ok,err=pcall(run)
    if not ok then warn("[Phase4 UI Probe] FAIL "..tostring(err)) end
    STS:EndTest(if ok then "PASS" else "FAIL "..tostring(err))
end)
task.delay(100,function() STS:EndTest("FAIL global timeout") end)
]=]
server.Parent=SSS
local ok,result=pcall(function()
    return STS:ExecutePlayModeAsync("Phase4DungeonUiState_TEMP")
end)
server:Destroy()
client:Destroy()
ack:Destroy()
assert(ok and result=="PASS","Dungeon UI live probe failed: "..tostring(result))
print("[Phase4 UI Probe] VERIFIED_PLAY_MODE_PASS")
