--!strict
-- Focused physical acceptance for optional Temple side-room bypass.
-- Run only against a disposable unpublished local Dungeon place.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Fixture cannot run against a published place."
)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StudioTestService = game:GetService("StudioTestService")
local Workspace = game:GetService("Workspace")

local dungeon = ServerScriptService:WaitForChild("Dungeon")
local shared = ReplicatedStorage.Core.Shared

--[[
Replaces one exact source fragment in a disposable Studio DataModel.

Args:
    source (LuaSourceContainer): Script or module to patch locally.
    old (string): Exact source fragment that must occur once.
    new (string): Replacement source fragment.

Returns:
    nil: Mutates only the loaded unpublished Studio copy.
]]
local function replace_once(
    source: LuaSourceContainer,
    old: string,
    new: string
)
    local value = source.Source
    local index = string.find(value, old, 1, true)

    assert(
        index
            and not string.find(
                value,
                old,
                index + #old,
                true
            ),
        "TEMP fixture source anchor missing or duplicated: "
            .. source.Name
    )

    source.Source = string.sub(value, 1, index - 1)
        .. new
        .. string.sub(value, index + #old)
end

for _, group in ipairs({
    ServerScriptService.Core.Tests,
    dungeon.Tests,
}) do
    for _, child in ipairs(group:GetDescendants()) do
        if child:IsA("Script") then
            child.Enabled = false
        end
    end
end

local definitions = shared.DungeonDefinitions
local source = definitions.Source
local lock_text = "OptionalBossRuntimeEnabled = false,"
local first_lock = assert(
    string.find(source, lock_text, 1, true),
    "Temple optional rollout flag was not found."
)

assert(
    string.find(
        source,
        lock_text,
        first_lock + #lock_text,
        true
    ),
    "Mine rollout flag must remain untouched."
)

definitions.Source = string.sub(source, 1, first_lock - 1)
    .. "OptionalBossRuntimeEnabled = true, -- TEMP fixture only"
    .. string.sub(source, first_lock + #lock_text)

replace_once(
    dungeon.DungeonRuntime,
    'local runtime = RuntimeServices.new("Dungeon")',
    'local runtime = RuntimeServices.new("Dungeon")\n'
        .. '_G.DungeonMMOTempFixtureRuntime = runtime'
)

ServerScriptService:SetAttribute(
    "DungeonMMOOptionalBossEventStartUnix",
    os.time() - 60
)
ServerScriptService:SetAttribute(
    "DungeonMMOOptionalBossEventEndUnix",
    os.time() + 600
)
ServerScriptService:SetAttribute(
    "DungeonMMOOptionalBossSecretChanceBasisPoints",
    10000
)

Workspace:SetAttribute("DungeonMMOStudioDungeonId", "TestDungeon")
Workspace:SetAttribute("DungeonMMOEnvironmentMode", "Synthetic")
Workspace:SetAttribute(
    "DungeonMMOPlaceholderPhysicalContentEnabled",
    true
)
Workspace:SetAttribute(
    "DungeonMMOPlaceholderPlayableEnabled",
    true
)
Workspace:SetAttribute(
    "DungeonMMOPlaceholderOptionalPlayEnabled",
    true
)

local driver = Instance.new("Script")
driver.Name = "OptionalBypassToRequired_TEMP"
driver.Source = [=[
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local StudioTestService = game:GetService("StudioTestService")
local Workspace = game:GetService("Workspace")

--[[
Raises a focused acceptance error when a condition is false.

Args:
    condition (boolean): Expected condition.
    message (string): Failure context.

Returns:
    nil: Raises on failure.
]]
local function must(condition: boolean, message: string)
    assert(
        condition,
        "[Optional Bypass TEMP] " .. message
    )
end

--[[
Waits for one runtime condition with a bounded timeout.

Args:
    predicate (() -> any): Condition function.
    label (string): Timeout description.
    seconds (number): Maximum wait duration.

Returns:
    any: First truthy predicate result.
]]
local function wait_until(
    predicate: () -> any,
    label: string,
    seconds: number
): any
    local deadline = os.clock() + seconds

    repeat
        local value = predicate()
        if value then
            return value
        end
        task.wait(0.1)
    until os.clock() >= deadline

    error(
        "[Optional Bypass TEMP] Timed out: " .. label
    )
end

--[[
Finds one tagged synthetic dungeon environment anchor.

Args:
    anchor_id (string): Stable environment anchor identifier.

Returns:
    BasePart: Matching physical anchor.
]]
local function anchor(anchor_id: string): BasePart
    return wait_until(function()
        for _, part in ipairs(
            CollectionService:GetTagged(
                "DungeonMMOEnvironmentAnchor"
            )
        ) do
            if part:IsA("BasePart")
                and part:GetAttribute("AnchorId") == anchor_id
            then
                return part
            end
        end

        return nil
    end, anchor_id, 15)
end

--[[
Returns the authoritative encounter state for one encounter.

Args:
    runtime (any): Shared runtime service container.
    session_id (string): Active dungeon session.
    encounter_id (string): Materialized encounter identifier.

Returns:
    string?: Current persisted encounter state.
]]
local function encounter_state(
    runtime: any,
    session_id: string,
    encounter_id: string
): string?
    local current = runtime.SessionService:get(session_id)
    local instance_state = current and current.InstanceState
    local encounter_runtime =
        instance_state and instance_state.EncounterRuntime
    local states =
        encounter_runtime and encounter_runtime.EncounterStates

    return states and states[encounter_id] or nil
end

--[[
Returns every living dungeon enemy.

Args:
    enemies (Folder): Runtime enemy container.

Returns:
    {Model}: Living enemy models.
]]
local function living_enemies(enemies: Folder): {Model}
    local result = {}

    for _, model in ipairs(enemies:GetChildren()) do
        if model:IsA("Model") then
            local humanoid =
                model:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                table.insert(result, model)
            end
        end
    end

    return result
end

--[[
Physically enters a required room, waits for activation, then clears it.

Args:
    root (BasePart): Player root used for physical movement.
    humanoid (Humanoid): Player movement controller.
    enemies (Folder): Dungeon enemy container.
    runtime (any): Shared runtime service container.
    session_id (string): Active session identifier.
    room_anchor_id (string): Required-room trigger anchor.
    encounter_id (string): Required encounter identifier.

Returns:
    nil: Leaves the required encounter cleared.
]]
local function enter_and_clear_required(
    root: BasePart,
    humanoid: Humanoid,
    enemies: Folder,
    runtime: any,
    session_id: string,
    room_anchor_id: string,
    encounter_id: string
)
    local trigger = anchor(room_anchor_id)

    root.CFrame = trigger.CFrame * CFrame.new(0, 0, 9)
    root.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.2)
    humanoid:MoveTo(
        trigger.Position + Vector3.new(0, 0, -2)
    )

    wait_until(function()
        return encounter_state(
            runtime,
            session_id,
            encounter_id
        ) == "Active"
    end, encounter_id .. " activation", 9)

    local spawned = wait_until(function()
        local models = living_enemies(enemies)
        return if #models > 0 then models else nil
    end, encounter_id .. " enemies", 9)

    for _, model in ipairs(spawned) do
        local enemy_humanoid =
            model:FindFirstChildOfClass("Humanoid")
        if enemy_humanoid then
            enemy_humanoid.Health = 0
        end
    end

    wait_until(function()
        return encounter_state(
            runtime,
            session_id,
            encounter_id
        ) == "Cleared"
    end, encounter_id .. " clear", 12)
end

--[[
Runs the physical optional-bypass acceptance path.

Args:
    None.

Returns:
    nil: Ends the Studio test with PASS or raises a focused failure.
]]
local function run()
    local player = wait_until(function()
        return Players:GetPlayers()[1]
    end, "player", 22)

    local runtime = wait_until(function()
        return _G.DungeonMMOTempFixtureRuntime
    end, "runtime", 20)

    local session = wait_until(function()
        local candidate =
            runtime.SessionService:get_for_user(player.UserId)

        return candidate
            and candidate.InstanceState
            and candidate.InstanceState.EncounterPlan
            and candidate
            or nil
    end, "session encounter plan", 25)

    must(
        session.InstanceState.OptionalBossEventActive == true,
        "timed Event side room must be present"
    )
    must(
        session.InstanceState.OptionalBossSecretUnlocked == true,
        "Secret side room must be present"
    )

    local event_id = nil
    local secret_id = nil
    local sequence = {}

    for _, encounter in ipairs(
        session.InstanceState.EncounterPlan
    ) do
        table.insert(sequence, encounter.RoomSlotId)

        if encounter.Kind == "EventBoss"
            or encounter.Kind == "EventCombat"
        then
            event_id = encounter.Id
            must(
                encounter.CompletionRequired == false,
                "Event side encounter must be optional"
            )
        elseif encounter.Kind == "SecretBoss" then
            secret_id = encounter.Id
            must(
                encounter.CompletionRequired == false,
                "Secret side encounter must be optional"
            )
        end
    end

    must(event_id ~= nil, "Event encounter missing")
    must(secret_id ~= nil, "Secret encounter missing")
    must(
        table.concat(sequence, ",")
            == "Room1,EventArena,Room2,SecretArena,Room3",
        "unexpected materialized encounter order"
    )

    local character = wait_until(function()
        local current = player.Character
        local root_part =
            current and current:FindFirstChild("HumanoidRootPart")

        return current and root_part and current or nil
    end, "player character", 20)

    local root =
        character:FindFirstChild("HumanoidRootPart") :: BasePart
    local humanoid =
        character:FindFirstChildOfClass("Humanoid") :: Humanoid

    must(humanoid ~= nil, "player humanoid missing")
    humanoid.MaxHealth = 100000
    humanoid.Health = 100000

    local enemies = wait_until(function()
        local gameplay =
            Workspace:FindFirstChild("DungeonGameplayRuntime")
        local folder =
            gameplay and gameplay:FindFirstChild("DungeonEnemies")

        return if folder and folder:IsA("Folder")
            then folder
            else nil
    end, "enemy container", 15)

    local session_id = session.SessionId

    enter_and_clear_required(
        root,
        humanoid,
        enemies,
        runtime,
        session_id,
        "Temple.Room1.Trigger",
        "CombatRoom1"
    )

    must(
        encounter_state(runtime, session_id, event_id) == "Pending",
        "Event side encounter must remain pending after Room 1"
    )

    local room2_trigger = anchor("Temple.Room2.Trigger")
    root.CFrame =
        room2_trigger.CFrame * CFrame.new(0, 0, 9)
    root.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.2)
    humanoid:MoveTo(
        room2_trigger.Position + Vector3.new(0, 0, -2)
    )

    wait_until(function()
        return encounter_state(
            runtime,
            session_id,
            event_id
        ) == "Skipped"
            and encounter_state(
                runtime,
                session_id,
                "CombatRoom2"
            ) == "Active"
    end, "Room 2 starts while Event is skipped", 9)

    print(
        "[Optional Bypass TEMP] ROOM2_STARTED_EVENT_SKIPPED"
    )

    local room2_enemies = wait_until(function()
        local models = living_enemies(enemies)
        return if #models > 0 then models else nil
    end, "Room 2 enemies", 9)

    for _, model in ipairs(room2_enemies) do
        local enemy_humanoid =
            model:FindFirstChildOfClass("Humanoid")
        if enemy_humanoid then
            enemy_humanoid.Health = 0
        end
    end

    wait_until(function()
        return encounter_state(
            runtime,
            session_id,
            "CombatRoom2"
        ) == "Cleared"
    end, "Room 2 clear", 12)

    must(
        encounter_state(runtime, session_id, secret_id) == "Pending",
        "Secret side encounter must remain pending after Room 2"
    )

    local final_trigger = anchor("Temple.Room3.Trigger")
    root.CFrame =
        final_trigger.CFrame * CFrame.new(0, 0, 9)
    root.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.2)
    humanoid:MoveTo(
        final_trigger.Position + Vector3.new(0, 0, -2)
    )

    wait_until(function()
        return encounter_state(
            runtime,
            session_id,
            secret_id
        ) == "Skipped"
            and encounter_state(
                runtime,
                session_id,
                "Depth1Boss"
            ) == "Active"
    end, "final room starts while Secret is skipped", 9)

    print(
        "[Optional Bypass TEMP] FINAL_STARTED_SECRET_SKIPPED"
    )

    local final_enemies = wait_until(function()
        local models = living_enemies(enemies)
        return if #models > 0 then models else nil
    end, "final boss", 9)

    for _, model in ipairs(final_enemies) do
        local enemy_humanoid =
            model:FindFirstChildOfClass("Humanoid")
        if enemy_humanoid then
            enemy_humanoid.Health = 0
        end
    end

    local completed = wait_until(function()
        local current =
            runtime.SessionService:get(session_id)
        return current and current.State == "Complete"
            and current
            or nil
    end, "dungeon completion", 15)

    must(
        completed.InstanceState
            .EncounterRuntime
            .EncounterStates[event_id] == "Skipped",
        "Event skip must remain persisted"
    )
    must(
        completed.InstanceState
            .EncounterRuntime
            .EncounterStates[secret_id] == "Skipped",
        "Secret skip must remain persisted"
    )

    local discoveries =
        completed.InstanceState.OptionalBossSecretDiscoveries
    must(
        not discoveries
            or discoveries.TempleHiddenSanctum ~= true,
        "Skipped Secret must not count as discovered"
    )

    print(
        "[Optional Bypass TEMP] PASS required route ignores side rooms"
    )
end

local ok, err = pcall(run)

if ok then
    StudioTestService:EndTest("PASS")
else
    warn("[Optional Bypass TEMP] FAIL " .. tostring(err))
    StudioTestService:EndTest("FAIL " .. tostring(err))
end
]=]

driver.Parent = ServerScriptService

print("[Optional Bypass TEMP] START_PLAY")

local ok, result = pcall(function()
    return StudioTestService:ExecutePlayModeAsync(
        "OptionalBypassToRequired_TEMP"
    )
end)

driver:Destroy()

assert(
    ok,
    "TEMP optional-bypass Play failed: " .. tostring(result)
)
assert(
    result == "PASS",
    "TEMP optional-bypass proof failed: " .. tostring(result)
)

print("[Optional Bypass TEMP] PLAY_MODE_PASS")
