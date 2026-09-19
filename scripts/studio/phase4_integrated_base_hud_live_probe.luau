--!strict
-- Read-only UI existence and window-controller contract in unpublished Base Play.
-- This TEMP fixture does not publish or change accounts/persistent game data.
assert(game.PlaceId==0 and game.GameId==0,"Unpublished local Base only")
local RS=game:GetService("ReplicatedStorage")
local SSS=game:GetService("ServerScriptService")
local SPS=game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
local STS=game:GetService("StudioTestService")
local ack=Instance.new("RemoteEvent")
ack.Name="Phase4IntegratedBaseHudAck_TEMP"
ack.Parent=RS
local client=Instance.new("LocalScript")
client.Name="Phase4IntegratedBaseHudClient_TEMP"
client.Source=[=[
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local ack=RS:WaitForChild("Phase4IntegratedBaseHudAck_TEMP")
local gui=player:WaitForChild("PlayerGui")
local function wait_for(fn,label,seconds)
    local deadline=os.clock()+seconds
    repeat
        local value=fn()
        if value then return value end
        task.wait(0.13)
    until os.clock()>=deadline
    error("[Phase4 Base HUD] TIMEOUT "..label)
end
local function widget(name,child)
    return wait_for(function()
        local surface=gui:FindFirstChild(name)
        return surface and surface:FindFirstChild(child,true)
            and surface
    end,name.."/"..child,35)
end
local profile=widget("ProfileHud","PlayerPortrait")
assert(profile:FindFirstChild("StatusCard")
    and profile.StatusCard:FindFirstChild("PlayerPortrait",true),
    "upper-left framed profile card/portrait missing")
local hotbar=widget("CombatHotbarGui","Slot6")
local slots=hotbar:FindFirstChild("Slots",true)
assert(slots and slots:FindFirstChild("Slot1")
    and slots:FindFirstChild("Slot6"),
    "six-slot combat hotbar missing")
local menu=widget("HudCommandMenu","GuildCommand")
for _,name in ipairs({"Inventory","Skills","Guild"}) do
    assert(menu:FindFirstChild(name.."Command",true),
        "bottom-right "..name.." menu button missing")
end
local base=widget("BaseUi","DifficultyStrip")
assert(base:FindFirstChild("DungeonContext",true),
    "lobby dungeon selection / difficulty panel missing")
print("[Phase4 Base HUD] FRAMED_PLAYER_HOTBAR_MENU_AND_DUNGEON_ENTRY_PASS")
local inventory=widget("InventoryPanelUi","InventoryPanel")
local skills=widget("CharacterSkillsMenu","SkillsPanel")
local guild=widget("GuildPanel","GuildWindow")
local windows={
    Inventory=inventory.InventoryPanel,
    Skills=skills.SkillsPanel,
    Guild=guild.GuildWindow,
}
local controller=require(player:WaitForChild("PlayerScripts")
    :WaitForChild("Core"):WaitForChild("HudWindowController"))
for _,name in ipairs({"Inventory","Skills","Guild"}) do
    wait_for(function()
        controller.set_visible(name,true)
        return windows[name].Visible and controller.active()==name
    end,"window open "..name,18)
    for other,window in pairs(windows) do
        if other~=name then
            assert(not window.Visible,
                "menu windows overlapped "..name.." / "..other)
        end
    end
    print("[Phase4 Base HUD] CONTEXT_WINDOW_PASS "..name)
end
controller.set_visible("Guild",false)
assert(controller.active()==nil
    and not windows.Guild.Visible,
    "closing Guild did not release contextual window")
print("[Phase4 Base HUD] CONTEXTUAL_WINDOW_CLOSE_PASS")
ack:FireServer("PASS")
]=]
client.Parent=SPS
local server=Instance.new("Script")
server.Name="Phase4IntegratedBaseHudDriver_TEMP"
server.Source=[=[
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local STS=game:GetService("StudioTestService")
local ack=RS:WaitForChild("Phase4IntegratedBaseHudAck_TEMP")
local completed=false
ack.OnServerEvent:Connect(function(_,value)
    if value=="PASS" then completed=true end
end)
task.spawn(function()
    local deadline=os.clock()+93
    repeat
        if completed then
            print("[Phase4 Base HUD] LIVE_CLIENT_UI_PASS")
            STS:EndTest("PASS")
            return
        end
        task.wait(0.15)
    until os.clock()>=deadline
    warn("[Phase4 Base HUD] FAIL timeout waiting for client")
    STS:EndTest("FAIL timeout")
end)
]=]
server.Parent=SSS
local ok,result=pcall(function()
    return STS:ExecutePlayModeAsync("Phase4IntegratedBaseHud_TEMP")
end)
server:Destroy()
client:Destroy()
ack:Destroy()
assert(ok and result=="PASS","Integrated Base HUD Play failed: "
    ..tostring(result))
print("[Phase4 Base HUD] VERIFIED_PLAY_MODE_PASS")
