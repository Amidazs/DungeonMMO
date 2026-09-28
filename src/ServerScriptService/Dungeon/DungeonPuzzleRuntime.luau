--!strict
-- Physical presentation for the server-owned Temple resonance puzzle.

local Players = game:GetService("Players")

local Runtime = {}

local PUZZLE_ID = "TempleResonanceLock"
local COLLECTIBLE_ID = "TempleResonanceShard"

local function distance_to_part(
    player: Player,
    target: BasePart
): number
    local character = player.Character
    local root = character
        and character:FindFirstChild("HumanoidRootPart")

    if not root or not root:IsA("BasePart") then
        return math.huge
    end

    local local_position = target.CFrame:PointToObjectSpace(
        root.Position
    )
    local half = target.Size * 0.5
    local dx = math.max(math.abs(local_position.X) - half.X, 0)
    local dy = math.max(math.abs(local_position.Y) - half.Y, 0)
    local dz = math.max(math.abs(local_position.Z) - half.Z, 0)

    return Vector3.new(dx, dy, dz).Magnitude
end

local function ensure_prompt(
    parent: BasePart,
    name: string,
    action_text: string,
    object_text: string
): ProximityPrompt
    local existing = parent:FindFirstChild(name)
    if existing and existing:IsA("ProximityPrompt") then
        return existing
    end

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = name
    prompt.ActionText = action_text
    prompt.ObjectText = object_text
    prompt.HoldDuration = 0.35
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = false
    prompt.Parent = parent

    return prompt
end

local function encounter_cleared(
    session: any,
    encounter_id: string
): boolean
    local runtime = session
        and session.InstanceState
        and session.InstanceState.EncounterRuntime
    local states = runtime and runtime.EncounterStates

    return type(states) == "table"
        and states[encounter_id] == "Cleared"
end

local function puzzle_completed(
    session: any
): boolean
    local states = session
        and session.InstanceState
        and session.InstanceState.PuzzleStates
    local state = type(states) == "table"
        and states[PUZZLE_ID]
        or nil

    return type(state) == "table"
        and state.Completed == true
end

local function member_active(
    session: any,
    user_id: number
): boolean
    local member = session
        and session.Members
        and session.Members[tostring(user_id)]

    return type(member) == "table"
        and member.Connected == true
        and member.Mode == "Active"
        and member.Abandoned ~= true
end

local function notify_party(
    config: any,
    session: any
)
    if type(config.on_profile_changed) ~= "function" then
        return
    end

    for _, user_id in ipairs(session.MemberUserIds or {}) do
        local player = Players:GetPlayerByUserId(user_id)
        if player and member_active(session, user_id) then
            config.on_profile_changed(player)
        end
    end
end

local function sync_prompts(
    config: any,
    shard_prompt: ProximityPrompt,
    rune_prompts: {ProximityPrompt}
)
    local session = config.get_session()
    local active = session and session.State == "Active"

    shard_prompt.Enabled = active == true
        and encounter_cleared(session, "CombatRoom1")

    local runes_enabled = active == true
        and encounter_cleared(
            session,
            config.definition.PrerequisiteEncounterId
        )
        and not puzzle_completed(session)

    for _, prompt in ipairs(rune_prompts) do
        prompt.Enabled = runes_enabled
    end
end

local function bind_shard_prompt(
    config: any,
    shard: BasePart,
    prompt: ProximityPrompt
)
    prompt.Triggered:Connect(function(player: Player)
        if Players:GetPlayerByUserId(player.UserId) ~= player then
            return
        end

        local session_id = config.get_session_id()
        if type(session_id) ~= "string" then
            return
        end

        local collected = config.quest_objects:collect(
            session_id,
            player.UserId,
            COLLECTIBLE_ID,
            distance_to_part(player, shard)
        )
        if collected.ok
            and type(config.on_profile_changed) == "function"
        then
            config.on_profile_changed(player)
        end
    end)
end

local function bind_rune_prompt(
    config: any,
    rune: BasePart,
    prompt: ProximityPrompt,
    rune_id: string,
    rune_prompts: {ProximityPrompt}
)
    prompt.Triggered:Connect(function(player: Player)
        if Players:GetPlayerByUserId(player.UserId) ~= player then
            return
        end

        local session_id = config.get_session_id()
        if type(session_id) ~= "string" then
            return
        end

        local pressed = config.puzzle_service:press(
            session_id,
            player.UserId,
            PUZZLE_ID,
            rune_id,
            distance_to_part(player, rune)
        )
        if not pressed.ok then
            return
        end

        sync_prompts(
            config,
            config.shard_prompt,
            rune_prompts
        )

        if pressed.completed == true then
            notify_party(config, config.get_session())
        end
    end)
end

function Runtime.attach(config: any): any
    assert(type(config) == "table")
    assert(config.quest_objects ~= nil)
    assert(config.puzzle_service ~= nil)
    assert(config.definition ~= nil)
    assert(type(config.get_session) == "function")
    assert(type(config.get_session_id) == "function")

    if config.dungeon_id ~= config.definition.DungeonId
        or config.difficulty_id ~= config.definition.DifficultyId
    then
        return {
            ok = true,
            bound = false,
            reason = "PuzzleNotApplicable",
        }
    end

    local root = config.workspace:FindFirstChild(
        "DungeonMMOSyntheticTemple"
    )
        or config.workspace:FindFirstChild(
            "DungeonMMOPlaceholderPhysicalContent"
        )
    if not root then
        return {
            ok = true,
            bound = false,
            reason = "PuzzlePresentationNotPresent",
        }
    end

    local puzzle = root:FindFirstChild("ResonancePuzzle", true)
    if not puzzle then
        return {
            ok = false,
            reason = "PuzzlePresentationInvalid",
        }
    end

    local shard = puzzle:FindFirstChild("TempleResonanceShard")
    if not shard or not shard:IsA("BasePart") then
        return {
            ok = false,
            reason = "PuzzleShardMissing",
        }
    end

    local shard_prompt = ensure_prompt(
        shard,
        "ResonanceShardPrompt",
        "Collect",
        "Temple Resonance Shard"
    )
    config.shard_prompt = shard_prompt

    local rune_prompts = {}
    for _, rune_id in ipairs(config.definition.Sequence) do
        local rune = puzzle:FindFirstChild(rune_id)
        if not rune or not rune:IsA("BasePart") then
            return {
                ok = false,
                reason = "PuzzleRuneMissing:" .. rune_id,
            }
        end

        local prompt = ensure_prompt(
            rune,
            rune_id .. "Prompt",
            "Attune",
            rune_id
        )
        table.insert(rune_prompts, prompt)
        bind_rune_prompt(
            config,
            rune,
            prompt,
            rune_id,
            rune_prompts
        )
    end

    bind_shard_prompt(config, shard, shard_prompt)
    sync_prompts(config, shard_prompt, rune_prompts)

    task.spawn(function()
        while true do
            local session = config.get_session()
            if not session or session.State ~= "Active" then
                break
            end

            sync_prompts(
                config,
                shard_prompt,
                rune_prompts
            )
            task.wait(0.25)
        end
    end)

    return {
        ok = true,
        bound = true,
        shard = shard,
        rune_prompts = rune_prompts,
    }
end

return table.freeze(Runtime)
