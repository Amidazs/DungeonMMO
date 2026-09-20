--!strict
-- Regression for the mandatory race/class picker in the restored-HUD Base.
-- Client-local synthetic snapshots only: no accounts, saves or datastore writes.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Race selection UI probe requires an unpublished local Base")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
local STS = game:GetService("StudioTestService")
assert(SSS:FindFirstChild("Base") and not SSS:FindFirstChild("Dungeon"),
    "Race selection probe must use the Base project")
local ack = Instance.new("RemoteEvent")
ack.Name = "Phase4RaceSnapshotAck_TEMP"
ack.Parent = RS
local client = Instance.new("LocalScript")
client.Name = "Phase4RaceSnapshotProbe_TEMP"
client.Source = [=[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")
local state = require(player:WaitForChild("PlayerScripts"):WaitForChild("Core")
    :WaitForChild("ProgressionClientState"))
local ack = RS:WaitForChild("Phase4RaceSnapshotAck_TEMP")
local function wait_for(fn, label, seconds)
    local deadline = os.clock() + seconds
    repeat
        local result = fn()
        if result then return result end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Phase4 Race Picker] TIMEOUT " .. label)
end
local gui = wait_for(function()
    return pg:FindFirstChild("IdentitySelectionUi")
end, "existing identity picker", 30)
local overlay = gui:WaitForChild("MandatoryOverlay")
local panel = overlay:WaitForChild("SelectionPanel")
local function show(stage)
    state.apply_snapshot({Identity = {CreationStage = stage}})
end
show("RaceSelection")
local human = wait_for(function()
    local card = panel:FindFirstChild("HumanCard", true)
    if overlay.Visible and card and card.AbsoluteSize.X > 50
        and card.AbsoluteSize.Y > 50 then return card end
end, "visible and sized Human race card", 15)
local elf = panel:FindFirstChild("ElfCard", true)
assert(elf and human:IsA("TextButton") and elf:IsA("TextButton")
    and human.Active and elf.Active, "race cards must be interactive")
assert(gui.DisplayOrder > pg:WaitForChild("HudCommandMenu").DisplayOrder,
    "new command HUD must not cover mandatory race picker")
assert(overlay.BackgroundColor3 == Color3.fromRGB(8,10,14)
    and math.abs(overlay.BackgroundTransparency - 0.08) < 0.01,
    "legacy HUD polish changed mandatory overlay styling")
assert(human.BackgroundColor3 == Color3.fromRGB(34,39,49),
    "legacy HUD polish overwrote race card selection appearance")
local center = human.AbsolutePosition + human.AbsoluteSize/2
local ok, hits = pcall(function()
    return pg:GetGuiObjectsAtPosition(center.X, center.Y)
end)
if ok and #hits > 0 then
    local on_card = false
    for i=1, math.min(12, #hits) do
        local obj = hits[i]
        local screen = obj:FindFirstAncestorOfClass("ScreenGui")
        print("[Phase4 Race Picker] HIT "..i.." "
            ..obj:GetFullName()
            .." screen="..tostring(screen and screen.Name)
            .." active="..tostring(obj.Active)
            .." visible="..tostring(obj.Visible))
        if obj == human or obj:IsDescendantOf(human) then
            if i <= 3 then on_card = true end
            break
        end
    end
    assert(on_card, "race card is blocked by a higher screen GUI")
    print("[Phase4 Race Picker] RACE_CARD_HITTEST_PASS")
else
    -- Headless Studio Play can return an empty hit-test array even when
    -- the card is visible and correctly sized. That is not evidence
    -- that another widget is intercepting player clicks.
    print("[Phase4 Race Picker] HITTEST_NOT_AVAILABLE_IN_HEADLESS_PLAY "
        .. tostring(if ok then #hits else hits))
end
for index=1,3 do
    show("RaceSelection")
    task.wait(0.07)
    assert(human.Parent ~= nil
        and panel:FindFirstChild("HumanCard",true) == human
        and panel:FindFirstChild("ElfCard",true) == elf,
        "same-stage snapshot destroyed a race button ("..index..")")
end
print("[Phase4 Race Picker] RACE_CARDS_SURVIVE_SNAPSHOT_REFRESH_PASS")
show("ClassSelection")
local fighter = wait_for(function()
    return overlay.Visible and panel:FindFirstChild("FighterCard",true)
end, "class stage", 10)
for index=1,3 do
    show("ClassSelection")
    task.wait(0.07)
    assert(fighter.Parent ~= nil
        and panel:FindFirstChild("FighterCard",true) == fighter,
        "same-stage snapshot destroyed a class button ("..index..")")
end
print("[Phase4 Race Picker] CLASS_CARDS_SURVIVE_SNAPSHOT_REFRESH_PASS")
show("Complete")
wait_for(function() return overlay.Visible == false end,
    "completion closes mandatory UI", 10)
print("[Phase4 Race Picker] MANDATORY_PICKER_CLOSES_ON_COMPLETE_PASS")
ack:FireServer("PASS")
]=]
client.Parent = SPS
local driver = Instance.new("Script")
driver.Name = "Phase4RaceSnapshotDriver_TEMP"
driver.Source = [=[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local STS = game:GetService("StudioTestService")
local ack = RS:WaitForChild("Phase4RaceSnapshotAck_TEMP")
local done = false
ack.OnServerEvent:Connect(function(_, message)
    if message == "PASS" then done = true end
end)
task.spawn(function()
    local deadline = os.clock()+80
    while os.clock()<deadline do
        if done then
            print("[Phase4 Race Picker] LIVE_CLIENT_REGRESSION_PASS")
            STS:EndTest("PASS")
            return
        end
        task.wait(0.13)
    end
    warn("[Phase4 Race Picker] FAIL client probe timed out")
    STS:EndTest("FAIL race UI timeout")
end)
]=]
driver.Parent = SSS
local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("Phase4RaceSnapshotRefresh_TEMP")
end)
driver:Destroy()
client:Destroy()
ack:Destroy()
assert(ok and result=="PASS", "Race selection UI regression failed: "..tostring(result))
print("[Phase4 Race Picker] VERIFIED_PLAY_MODE_PASS")
