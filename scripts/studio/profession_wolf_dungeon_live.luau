--!strict
-- TEMP unpublished Dungeon test: opt in wolves for Temple Room1 only.
-- The authored default dungeon still spawns the original Marauders.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Wolf dungeon fixture requires an unpublished local Studio place")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local STS = game:GetService("StudioTestService")
local W = game:GetService("Workspace")

-- Args:
--   script_object: LuaSourceContainer; disposable source to instrument.
--   old_text: string; exact unique source fragment.
--   new_text: string; temporary replacement source fragment.
-- Returns:
--   nil: validates and applies only one substitution in local Studio.
local function replace_once(script_object, old_text, new_text)
    local source = script_object.Source
    local position = assert(string.find(source, old_text, 1, true),
        "Dungeon wolf test source anchor missing: " .. script_object.Name)
    assert(not string.find(source, old_text,
        position + #old_text, true), "Source anchor is ambiguous")
    script_object.Source = string.sub(source, 1, position - 1)
        .. new_text .. string.sub(source, position + #old_text)
end

-- Only the TEMP Studio content catalogue receives the alternate wolf pack.
local catalog = RS.Core.Shared.DungeonRuntimeContentCatalog
replace_once(catalog,
    'pack_entry(\n                    "Marauders",\n'
        .. '                    "Marauder",\n'
        .. '                    2,\n'
        .. '                    "Room1_Marauder_",\n'
        .. '                    100\n'
        .. '                ),',
    'pack_entry(\n                    "Beasts",\n'
        .. '                    "Wolf",\n'
        .. '                    2,\n'
        .. '                    "Room1_Wolf_",\n'
        .. '                    100\n'
        .. '                ),')
replace_once(SSS.Dungeon.DungeonRuntime,
    'local runtime = RuntimeServices.new("Dungeon")',
    'local runtime = RuntimeServices.new("Dungeon")\n'
        .. '_G.TempWolfDungeonRuntime = runtime')

W:SetAttribute("DungeonMMOStudioDungeonId", "TestDungeon")
W:SetAttribute("DungeonMMOEnvironmentMode", "Synthetic")
W:SetAttribute("DungeonMMOPlaceholderPhysicalContentEnabled", true)
W:SetAttribute("DungeonMMOPlaceholderPlayableEnabled", true)

-- Disable only autorun unit-test scripts incompatible with intentional
-- disposable pack override. The normal Dungeon runtime stays enabled.
for _, group in ipairs({SSS.Core.Tests, SSS.Dungeon.Tests}) do
    for _, test in ipairs(group:GetDescendants()) do
        if test:IsA("Script") then
            test.Enabled = false
        end
    end
end

local channel = Instance.new("RemoteEvent")
channel.Name = "WolfDungeonPlayChannel_TEMP"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "WolfDungeonPlayClient_TEMP"
client.Source = [==[
local RS = game:GetService("ReplicatedStorage")
local channel = RS:WaitForChild("WolfDungeonPlayChannel_TEMP")
local results = RS.Core.Remotes:WaitForChild("ProfessionActionResult")
local visible_prompts = {}
game:GetService("ProximityPromptService").PromptShown:Connect(
    function(prompt)
        visible_prompts[prompt] = true
    end)

results.OnClientEvent:Connect(function(payload)
    if type(payload) == "table" and payload.action == "Gather" then
        channel:FireServer("Result", payload)
    end
end)

-- Args: command (string), asks the real client to activate the skin prompt.
-- Returns: nil; reports whether the action was possible and held.
local function handle(command)
    if command ~= "Skin" then return end
    local enemies = workspace.DungeonGameplayRuntime.DungeonEnemies
    local wolf = enemies:WaitForChild("Room1_Wolf_1", 15)
    assert(wolf, "wolf corpse was not replicated")
    local prompt = wolf.HumanoidRootPart:WaitForChild(
        "BeastSkinningPrompt", 12)
    assert(prompt, "wolf corpse prompt was not replicated")
    if not prompt.Enabled then
        channel:FireServer("Depleted")
        return
    end

    local camera = workspace.CurrentCamera
    if camera then
        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = CFrame.lookAt(
            prompt.Parent.Position + Vector3.new(0, 3, 8),
            prompt.Parent.Position
        )
    end
    local deadline = os.clock() + 5
    while not visible_prompts[prompt] and os.clock() < deadline do
        task.wait(0.1)
    end
    channel:FireServer("PromptVisible", visible_prompts[prompt] == true)
    prompt:InputHoldBegin()
    task.wait(0.8)
    prompt:InputHoldEnd()
end
channel.OnClientEvent:Connect(handle)
channel:FireServer("Ready")
]==]
client.Parent = SPS

local driver = Instance.new("Script")
driver.Name = "WolfDungeonPlayDriver_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local W = game:GetService("Workspace")
local Tags = game:GetService("CollectionService")
local channel = RS:WaitForChild("WolfDungeonPlayChannel_TEMP")

local ready_user_id = nil
local results = {}
local prompt_visible = false
local depleted = false

channel.OnServerEvent:Connect(function(player, kind, value)
    if kind == "Ready" then
        ready_user_id = player.UserId
    elseif player.UserId ~= ready_user_id then
        return
    elseif kind == "Result" then
        table.insert(results, value)
    elseif kind == "PromptVisible" then
        prompt_visible = value == true
    elseif kind == "Depleted" then
        depleted = true
    end
end)

-- Args:
--   predicate: () -> any; condition that eventually becomes truthy.
--   label: string; diagnostic name of the missing result.
--   seconds: number; timeout.
-- Returns:
--   any: the first truthy value returned by the predicate.
local function wait_for(predicate, label, seconds)
    local deadline = os.clock() + seconds
    repeat
        local value = predicate()
        if value then return value end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Wolf Dungeon Live] TIMEOUT " .. label)
end

-- Args:
--   identifier: string; the real registered dungeon anchor ID.
-- Returns:
--   BasePart: the actual server-owned dungeon room trigger.
local function anchor(identifier)
    return wait_for(function()
        for _, object in ipairs(Tags:GetTagged(
            "DungeonMMOEnvironmentAnchor")
        ) do
            if object:GetAttribute("AnchorId") == identifier then
                return object
            end
        end
    end, identifier, 15)
end

-- Args: None.
-- Returns: nil; verifies the real encounter and a real client skin grant.
local function run()
    local player = wait_for(function()
        return Players:GetPlayers()[1]
    end, "Studio player", 30)
    wait_for(function()
        return ready_user_id == player.UserId
    end, "client listener", 30)
    local runtime = wait_for(function()
        return _G.TempWolfDungeonRuntime
    end, "Dungeon services", 30)
    local session = wait_for(function()
        local current = runtime.SessionService:get_for_user(player.UserId)
        return current and current.InstanceState
            and current.InstanceState.EncounterPlan and current
    end, "admitted Dungeon encounter plan", 40)
    local encounter_id = "CombatRoom1"
    local enemies = wait_for(function()
        local folder = W:FindFirstChild("DungeonGameplayRuntime")
        return folder and folder:FindFirstChild("DungeonEnemies")
    end, "Dungeon enemies folder", 20)
    local character = wait_for(function()
        return player.Character
            and player.Character:FindFirstChild("HumanoidRootPart")
            and player.Character
    end, "player character", 25)
    local root = character.HumanoidRootPart
    local humanoid = assert(character:FindFirstChildOfClass("Humanoid"))
    humanoid.MaxHealth = 100000
    humanoid.Health = 100000

    -- Assisted trigger entry and enemy defeats validate the encounter
    -- lifecycle, not player combat skill or animal balancing.
    task.wait(5)
    local trigger = anchor("Temple.Room1.Trigger")
    root.CFrame = trigger.CFrame * CFrame.new(0, 0, 9)
    root.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.25)
    humanoid:MoveTo(trigger.Position + Vector3.new(0, 0, -2))

    local function encounter_state()
        local current = runtime.SessionService:get(session.SessionId)
        local state = current and current.InstanceState
            and current.InstanceState.EncounterRuntime
        return state and state.EncounterStates[encounter_id]
    end
    wait_for(function()
        return encounter_state() == "Active"
    end, "Room1 physical trigger activation", 12)

    local wolves = wait_for(function()
        local matches = {}
        for _, enemy in ipairs(enemies:GetChildren()) do
            if enemy:IsA("Model")
                and enemy.Name:find("Room1_Wolf_", 1, true)
            then
                table.insert(matches, enemy)
            end
        end
        return if #matches == 2 then matches else nil
    end, "two real encounter wolves", 12)
    for _, wolf in ipairs(wolves) do
        assert(wolf:GetAttribute("CreatureSpeciesId") == "forest_wolf"
            and wolf:GetAttribute("CreatureFamily") == "Beast"
            and Tags:HasTag(wolf, "DungeonMMOSkinnableBeast"),
            "the combat-pack executor did not use the animal factory")
        assert(wolf.Humanoid.Health > 0
            and not wolf.HumanoidRootPart:FindFirstChild(
                "BeastSkinningPrompt"),
            "living wolf exposed Skinning")
        wolf.Humanoid.Health = 0
    end
    wait_for(function()
        return encounter_state() == "Cleared"
    end, "real encounter rewards and Room1 clear", 16)
    local wolf = wait_for(function()
        local model = enemies:FindFirstChild("Room1_Wolf_1")
        if model and model:GetAttribute("LootComplete") == true
            and model.HumanoidRootPart:FindFirstChild(
                "BeastSkinningPrompt")
        then return model end
    end, "retained looted wolf corpse and skin prompt", 12)
    assert(wolf:GetAttribute("DungeonEnemyRetired") == true,
        "defeated wolf did not pass normal Dungeon enemy cleanup")
    print("[Wolf Dungeon Live] ENCOUNTER_LOOT_CORPSE_PASS")

    root.Anchored = true
    root.CFrame = wolf.HumanoidRootPart.CFrame * CFrame.new(0, 3, 4)
    task.wait(0.4)
    channel:FireClient(player, "Skin")
    local result = wait_for(function()
        return table.remove(results, 1)
    end, "client hide grant after real encounter", 14)
    assert(prompt_visible and result.ok == true
        and result.item_id == "raw_hide" and result.quantity == 1,
        "real encounter corpse did not grant one hide via client prompt")
    assert(wolf:GetAttribute("SkinningClaimed") == true,
        "one-time corpse claim did not persist")
    channel:FireClient(player, "Skin")
    wait_for(function()
        return depleted
    end, "second client skin prompt correctly disabled", 8)
    assert(#results == 0,
        "same real wolf corpse granted hide more than once")
    print("[Wolf Dungeon Live] CLIENT_ONCE_ONLY_HIDE_PASS")
end

task.spawn(function()
    local ok, reason = pcall(run)
    if not ok then
        warn("[Wolf Dungeon Live] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(150, function()
    STS:EndTest("FAIL fixture global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("WolfDungeonLiveFixture_TEMP")
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and result == "PASS",
    "Dungeon wolf live fixture failed: " .. tostring(result))
print("[Wolf Dungeon Live] VERIFIED_PLAY_MODE_PASS")
