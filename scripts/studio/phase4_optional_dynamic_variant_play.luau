--!strict
-- Unpublished alternate Event/Secret boss Play-mode test at Depth2/4.
-- Only the loaded TEMP DataModel selects seed 7 to exercise both alternates.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Never run the optional depth fixture in a published Roblox place.")
local W = game:GetService("Workspace")
local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local STS = game:GetService("StudioTestService")

local dungeon_id = W:GetAttribute("DungeonMMOPlaceholderPreviewDungeonId")
if dungeon_id ~= "TestDungeon" and dungeon_id ~= "AbandonedMine" then
    dungeon_id = "TestDungeon"
end
local difficulty = W:GetAttribute("DungeonMMOStudioDifficultyId")
if difficulty ~= "Depth2" and difficulty ~= "Depth3"
    and difficulty ~= "Depth4" then
    difficulty = "Depth2"
end
W:SetAttribute("DungeonMMOStudioDungeonId", dungeon_id)
W:SetAttribute("DungeonMMOStudioDifficultyId", difficulty)
W:SetAttribute("DungeonMMOEnvironmentMode", "Synthetic")
W:SetAttribute("DungeonMMOPlaceholderPhysicalContentEnabled", true)
W:SetAttribute("DungeonMMOPlaceholderPlayableEnabled", true)
W:SetAttribute("DungeonMMOPlaceholderOptionalPlayEnabled", true)

-- Disable only unit scripts whose release-lock assertions are incompatible
-- with the deliberately enabled ephemeral dungeon selected for this test.
for _, group in ipairs({SSS.Core.Tests, SSS.Dungeon.Tests}) do
    for _, script in ipairs(group:GetDescendants()) do
        if script:IsA("Script") then
            script.Enabled = false
        end
    end
end

local definitions = RS.Core.Shared.DungeonDefinitions
local definition_source = definitions.Source
local lock = "OptionalBossRuntimeEnabled = false,"
local first = assert(string.find(definition_source, lock, 1, true))
local second = assert(string.find(
    definition_source, lock, first + #lock, true))
assert(not string.find(definition_source, lock, second + #lock, true),
    "Expected exactly the Temple and Mine rollout locks.")
local selected = if dungeon_id == "TestDungeon" then first else second
definitions.Source = string.sub(definition_source, 1, selected - 1)
    .. "OptionalBossRuntimeEnabled = true, -- TEMP local Play-mode only"
    .. string.sub(definition_source, selected + #lock)

local runtime_script = SSS.Dungeon.DungeonRuntime
local source = runtime_script.Source
local original = 'local runtime = RuntimeServices.new("Dungeon")'
local position = assert(string.find(source, original, 1, true))
assert(not string.find(source, original, position + #original, true))
runtime_script.Source = string.sub(source, 1, position - 1)
    .. original .. '\n_G.Phase4DepthOptionalPhysicalRuntime = runtime'
    .. string.sub(source, position + #original)

-- Opt in only inside the disposable local test and use seed 7 to choose
-- both alternate Event and Secret identities deterministically.
SSS:SetAttribute("DungeonMMOOptionalBossVariantsEnabled", true)
local director = SSS.Core.Services.DungeonInstanceDirector
local original_seed = '        dungeon_id, now, seed, options, enabled, difficulty_id\n    )'
local chosen_seed = '        dungeon_id, now, 7, options, enabled, difficulty_id\n    )'
local director_source = director.Source
local match_start = assert(string.find(
    director_source, original_seed, 1, true))
assert(not string.find(director_source, original_seed,
    match_start + #original_seed, true),
    "TEMP seed override must occur at exactly one issuance call")
director.Source = string.sub(director_source, 1, match_start - 1)
    .. chosen_seed
    .. string.sub(director_source, match_start + #original_seed)
SSS:SetAttribute("DungeonMMOOptionalBossEventStartUnix", os.time() - 60)
SSS:SetAttribute("DungeonMMOOptionalBossEventEndUnix", os.time() + 1200)
SSS:SetAttribute("DungeonMMOOptionalBossSecretChanceBasisPoints", 10000)

local driver = Instance.new("Script")
driver.Name = "Phase4DepthOptionalPhysical_TEMP"
driver.Source = [=[
local Players = game:GetService("Players")
local SSS = game:GetService("ServerScriptService")
local W = game:GetService("Workspace")
local STS = game:GetService("StudioTestService")
local Tags = game:GetService("CollectionService")
local Dungeon = SSS:WaitForChild("Dungeon")
local Gates = require(Dungeon.DungeonOptionalEntranceGates)

local function check(condition, message)
    assert(condition, "[Depth Optional Physical] " .. message)
end

local function until_value(predicate, label, timeout)
    local deadline = os.clock() + timeout
    repeat
        local value = predicate()
        if value then return value end
        task.wait(0.12)
    until os.clock() >= deadline
    error("[Depth Optional Physical] TIMEOUT " .. label)
end

local function anchor(identifier)
    return until_value(function()
        for _, object in ipairs(Tags:GetTagged(
            "DungeonMMOEnvironmentAnchor"
        )) do
            if object:GetAttribute("AnchorId") == identifier then
                return object
            end
        end
    end, identifier, 15)
end

local function run()
    local dungeon_id = W:GetAttribute("DungeonMMOStudioDungeonId")
    local difficulty_id = W:GetAttribute("DungeonMMOStudioDifficultyId")
    local prefix = if dungeon_id == "TestDungeon" then "Temple" else "Mine"
    local depth = assert(tonumber(difficulty_id:match("^Depth([234])$")))
    local base = assert(require(
        game:GetService("ReplicatedStorage").Core.Shared
            .DungeonDifficultyDefinitions
    ).get(dungeon_id, difficulty_id))
    check(not base.RuntimeReleaseEnabled,
        "global high-depth rollout must remain locked")
    local player = until_value(function()
        return Players:GetPlayers()[1]
    end, "real Studio player", 30)
    local runtime = until_value(function()
        return _G.Phase4DepthOptionalPhysicalRuntime
    end, "Dungeon runtime", 25)
    local session = until_value(function()
        local current = runtime.SessionService:get_for_user(player.UserId)
        if current and current.InstanceState
            and current.InstanceState.EncounterPlan
        then return current end
    end, "admitted optional depth session", 35)
    check(session.Difficulty.Id == difficulty_id,
        "run must retain its selected higher difficulty")
    check(session.InstanceState.OptionalBossEventActive
        and session.InstanceState.OptionalBossSecretUnlocked,
        "test-only server entry must issue both optional bosses")
    local VariantCatalog = require(
        game:GetService("ReplicatedStorage").Core.Shared
            .DungeonOptionalBossVariantCatalog)
    local chosen_event = assert(VariantCatalog.get(dungeon_id, "Event", 2))
    local chosen_secret = assert(VariantCatalog.get(dungeon_id, "Secret", 2))
    check(session.InstanceState.OptionalBossEventId == chosen_event.Id
        and session.InstanceState.OptionalBossSecretUnlocks[
            chosen_secret.Id] == true,
        "seed 7 must freeze exactly the two alternate boss variants")
    local plan = session.InstanceState.EncounterPlan
    check(#plan == #base.EncounterSequence + 2,
        "two optionals must extend, not replace, the depth room plan")
    local slots = {}
    for _, encounter in ipairs(plan) do
        table.insert(slots, encounter.RoomSlotId)
    end
    check(slots[1] == "Room1" and slots[2] == "EventArena"
        and slots[#slots - 1] == "SecretArena"
        and slots[#slots] == "Room" .. (depth + 2),
        "both optional arenas must be ordered by this depth's run plan")
    check(slots[#slots - 2] == "Room" .. (depth + 1),
        "Secret must follow the last required room before final")
    check(plan[2].BossId == chosen_event.BossId
        and plan[#plan - 1].BossId == chosen_secret.BossId,
        "frozen plan must bind both alternate implemented boss factories")
    print("[Depth Optional Variant] ALTERNATE_PLAN "
        .. chosen_event.Id .. "/" .. chosen_secret.Id
        .. " slots=" .. table.concat(slots, ","))

    local character = until_value(function()
        local model = player.Character
        return model and model:FindFirstChild("HumanoidRootPart")
            and model:FindFirstChildOfClass("Humanoid") and model
    end, "player character", 25)
    local root = character.HumanoidRootPart
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    -- Only assisted enemy defeats/survival; the route is traversed by MoveTo.
    humanoid.MaxHealth = 100000
    humanoid.Health = 100000
    humanoid.WalkSpeed = 27
    local enemies = until_value(function()
        local holder = W:FindFirstChild("DungeonGameplayRuntime")
        return holder and holder:FindFirstChild("DungeonEnemies")
    end, "enemy container", 18)

    local physical_root = assert(
        W:FindFirstChild("DungeonMMOPlaceholderPhysicalContent"))
    check(physical_root:GetAttribute("DungeonMMOPlaceholderActiveDifficulty")
        == difficulty_id and physical_root:GetAttribute(
            "DungeonMMOPlaceholderOptionalDepthRoutes") == true,
        "only the selected higher-depth side bridges are playable")
    local group = assert(physical_root:FindFirstChild(
        difficulty_id .. "_TEMP_PLAYABLE"))
    local old_event = assert(physical_root.EventBridge.EntranceGate)
    local old_secret = assert(physical_root.SecretBridge.EntranceGate)
    local gates = {
        EventArena = assert(Gates.get(physical_root, "EventArena")),
        SecretArena = assert(Gates.get(physical_root, "SecretArena")),
    }
    check(old_event.CanCollide and old_secret.CanCollide
        and gates.EventArena.CanCollide and gates.SecretArena.CanCollide,
        "all optional routes must initially be closed")

    local function state_of(encounter_id)
        local current = runtime.SessionService:get(session.SessionId)
        local snapshot = current and current.InstanceState
            and current.InstanceState.EncounterRuntime
        return snapshot and snapshot.EncounterStates[encounter_id]
    end

    local function walk_to(destination, label)
        humanoid:MoveTo(destination)
        until_value(function()
            check(humanoid.Health > 0 and root.Position.Y > -10,
                label .. " player died or fell off walkable floor")
            return (root.Position - destination).Magnitude <= 7
        end, "walk " .. label, 11)
    end

    local center_x = if dungeon_id == "TestDungeon" then 780 else 1760
    center_x += (depth - 2) * 240
    local function cross_side(kind, from_main)
        local room_index = if kind == "Event" then 1 else depth + 1
        local z = 80 - (room_index - 1) * 90
        local gate = gates[kind .. "Arena"]
        check(not gate.CanCollide and old_event.CanCollide
            and old_secret.CanCollide,
            kind .. " gate must be open while unused Depth1 gates stay shut")
        local waypoints = if from_main
            then {0, 25, 42, 62, 82, 104}
            else {82, 62, 42, 25, 0}
        for _, dx in ipairs(waypoints) do
            walk_to(Vector3.new(center_x + dx, root.Position.Y, z),
                kind .. (if from_main then " entrance" else " return")
                    .. " " .. tostring(dx))
        end
        print("[Depth Optional Physical] WALKED_" .. kind
            .. (if from_main then "_BRIDGE_IN" else "_BRIDGE_OUT"))
    end

    local required_index = 0
    for _, encounter in ipairs(plan) do
        local kind = encounter.Kind
        local optional = kind == "EventBoss" or kind == "SecretBoss"
        local stage = if kind == "EventBoss" then "Event"
            elseif kind == "SecretBoss" then "Secret" else nil
        local slot_id = encounter.RoomSlotId
        local trigger_id
        if stage then
            trigger_id = prefix .. "." .. difficulty_id .. "."
                .. stage .. ".Trigger"
            if stage == "Event" then
                check(gates.EventArena.CanCollide == false
                    and gates.SecretArena.CanCollide == true,
                    "Room1 opens only Event; Secret is still sealed")
            else
                check(not gates.SecretArena.CanCollide,
                    "last required predecessor opens Secret")
            end
            cross_side(stage, true)
        else
            required_index += 1
            trigger_id = prefix .. "." .. difficulty_id .. ".Room"
                .. required_index .. ".Trigger"
        end
        check(state_of(encounter.Id) == "Pending",
            slot_id .. " must be pending before entering its physical room")
        local trigger = anchor(trigger_id)
        if stage then
            walk_to(trigger.Position + Vector3.new(0, 0, -2),
                stage .. " boss trigger")
        else
            walk_to(trigger.Position + Vector3.new(0, 0, -2),
                "Room" .. required_index .. " trigger")
        end
        until_value(function()
            return state_of(encounter.Id) == "Active"
        end, slot_id .. " server encounter activated", 10)
        local spawned = until_value(function()
            local living = {}
            for _, model in ipairs(enemies:GetChildren()) do
                if model:IsA("Model") then
                    local hp = model:FindFirstChildOfClass("Humanoid")
                    if hp and hp.Health > 0 then
                        table.insert(living, model)
                    end
                end
            end
            return if #living > 0 then living else nil
        end, slot_id .. " enemy/boss spawn", 12)
        if encounter.ExecutorId == "Boss" then
            check(#spawned == 1, slot_id .. " must spawn one boss")
            check(spawned[1]:GetAttribute("BossId") == encounter.BossId,
                slot_id .. " boss identity must match frozen run plan")
            print("[Depth Optional Physical] BOSS " .. encounter.BossId
                .. " room=" .. slot_id)
        end
        for _, model in ipairs(spawned) do
            model:FindFirstChildOfClass("Humanoid").Health = 0
        end
        until_value(function()
            return state_of(encounter.Id) == "Cleared"
        end, slot_id .. " server completion", 15)
        print("[Depth Optional Physical] CLEARED " .. slot_id)
        if stage then
            local character = assert(runtime.ProfileService:get_character(
                player.UserId, 1))
            local history = character.RewardHistory.Monster or {}
            local wanted = encounter.BossId .. ":" .. encounter.Id
            local key, before_count = nil, 0
            for transaction in pairs(history) do
                before_count += 1
                if string.find(transaction, wanted, 1, true) then
                    key = transaction
                end
            end
            check(key ~= nil,
                "alternate boss must grant its own encounter-scoped reward")
            local replay = runtime.RewardService:grant_monster_reward(
                {player.UserId},
                {XP = 40, GoldMin = 0, GoldMax = 0,
                    BossId = encounter.BossId}, key)
            check(replay.ok and replay.already_applied,
                "repeated alternate boss reward must not apply twice")
            local after_count = 0
            for _ in pairs(
                assert(runtime.ProfileService:get_character(
                    player.UserId, 1)).RewardHistory.Monster or {}
            ) do
                after_count += 1
            end
            check(after_count == before_count,
                "reward replay must preserve player monster history")
            print("[Depth Optional Variant] REWARD_REPLAY_PASS "
                .. stage .. " " .. encounter.BossId
                .. " encounter=" .. encounter.Id)
            cross_side(stage, false)
        end
    end
    local completed = until_value(function()
        local current = runtime.SessionService:get(session.SessionId)
        return current and current.State == "Complete" and current
    end, "completed full optional dungeon route", 20)
    check(completed.InstanceState.EncounterRuntime.EncounterStates[
        plan[#plan].Id] == "Cleared",
        "final required boss must remain cleared after side rooms")
    print("[Depth Optional Variant] ALTERNATE_PLAY_PASS "
        .. dungeon_id .. " " .. difficulty_id
        .. " Event=" .. chosen_event.BossId
        .. " Secret=" .. chosen_secret.BossId
        .. " rooms=" .. tostring(#plan))
end

task.spawn(function()
    local ok, reason = pcall(run)
    if not ok then
        warn("[Depth Optional Physical] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(240, function()
    STS:EndTest("FAIL global timeout")
end)
]=]
driver.Parent = SSS
print("[Depth Optional Physical] START " .. dungeon_id .. " " .. difficulty)
local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync(
        "OptionalDepth_TEMP_" .. dungeon_id .. "_" .. difficulty
    )
end)
driver:Destroy()
assert(ok and result == "PASS",
    "Optional depth physical Play-mode failed: " .. tostring(result))
print("[Depth Optional Variant] VERIFIED_ALTERNATE_PLAY_PASS "
    .. dungeon_id .. " " .. difficulty)
