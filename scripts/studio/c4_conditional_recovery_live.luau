--!strict
-- Genuine seated Fighter Stamina regeneration in unpublished Dungeon Play.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 real recovery test requires an unpublished Studio place")

local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")

local driver = Instance.new("Script")
driver.Name = "TEMP_C4RecoveryLive"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")

local Schema = require(RS.Core.Shared.ProfileSchema)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)
local Stamina = require(SSS.Combat.StaminaService)

--[[
Waits for a real Play character/seat condition with a fixed time bound.

Args:
    predicate (function): Condition returning a truthy observation.
    label (string): Diagnostic if the condition does not arrive.

Returns:
    any: First truthy observation within eight seconds.
]]
local function wait_for(predicate, label)
    local deadline = os.clock() + 8
    repeat
        local value = predicate()
        if value then
            return value
        end
        task.wait(0.05)
    until os.clock() >= deadline
    error("[C4 Recovery Live] TIMEOUT " .. label)
end

--[[
Creates an actual server-owned level-five Human Fighter progression.

Args:
    user_id (number): Authenticated disposable Studio player ID.

Returns:
    any: Mutable selected character without a learned recovery rank.
]]
local function make_fighter(user_id)
    local character = Schema.create_default(user_id).Characters.Slot1
    character.Identity.RaceId = "Human"
    character.Identity.BaseClassId = "Fighter"
    character.Identity.ClassId = "Fighter"
    character.Identity.CreationStage = "Complete"
    character.Level = 5
    return character
end

--[[
Measures actual server Heartbeat regeneration after one Stamina spend.

Args:
    player (Player): Real live resource owner.
    amount (number): Authoritative fixed Stamina spend.

Returns:
    number: Real Stamina restored in the identical sample window.
]]
local function sample_regeneration(player, amount)
    Stamina.reset_player(player)
    Stamina.set_regen_paused(player, false)
    assert(Stamina.try_spend(player, amount, 0),
        "Recovery sample could not spend actual server Stamina")
    local before = Stamina.get(player)
    task.wait(1)
    local gained = Stamina.get(player) - before
    assert(gained > 0,
        "Server Heartbeat did not restore spent Stamina")
    return gained
end

--[[
Tests purchased recovery by changing only real saved-rank snapshot
while leaving the same legitimate seated Humanoid and server resource.

Args:
    player (Player): Real disposable live client character.

Returns:
    nil: Verifies real seated status, bonus and faster resource ticks.
]]
local function check_live_recovery(player)
    local model = wait_for(function()
        return player.Character and player.Character:FindFirstChild(
            "HumanoidRootPart"
        ) and player.Character
    end, "real player character")
    local humanoid = assert(model:FindFirstChildOfClass("Humanoid"))
    local root = assert(model:FindFirstChild("HumanoidRootPart"))
    local seat = Instance.new("Seat")
    seat.Name = "TEMP_C4RecoverySeat"
    seat.Anchored = true
    seat.Size = Vector3.new(4, 1, 4)
    seat.CFrame = root.CFrame * CFrame.new(0, -2.75, 0)
    seat.Parent = workspace
    seat:Sit(humanoid)
    wait_for(function()
        return humanoid.Sit and humanoid.SeatPart == seat
    end, "authenticated seated Humanoid")

    local character = make_fighter(player.UserId)
    Runtime.set_character(player.UserId, character)
    assert(Stamina.get_regen_multiplier(player) == 1,
        "Untrained seated Fighter was granted recovery")
    local baseline = sample_regeneration(player, 40)
    character.Progression.Skills.FighterRestingRecovery = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    Runtime.set_character(player.UserId, character)
    assert(math.abs(
        Stamina.get_regen_multiplier(player) - 1.15
    ) < 0.0001, "Real seated Fighter lost bought recovery bonus")
    local trained = sample_regeneration(player, 40)
    assert(trained > baseline * 1.05,
        "Bought recovery failed to increase actual Stamina ticks")
    print("[C4 Recovery Live] REAL_SEATED_STAMINA_PASS")
    seat:Destroy()
end

--[[
Runs the isolated live Studio player test without cloud/PROD state.

Args:
    None.

Returns:
    nil: Ends the current unpublished Play test on success.
]]
local function main()
    local player = Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
    check_live_recovery(player)
end

task.spawn(function()
    local ok, reason = pcall(main)
    if not ok then
        warn("[C4 Recovery Live] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(30, function()
    STS:EndTest("FAIL seated Stamina sample timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("TEMP_C4RecoveryLive")
end)
driver:Destroy()
assert(ok and result == "PASS",
    "C4 live Stamina recovery failed: " .. tostring(result))
print("[C4 Recovery Live] VERIFIED_PLAY_MODE_PASS")
