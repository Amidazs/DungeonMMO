--!strict
-- Physical runtime for the server-owned Temple defend/survive objective.

local Players = game:GetService("Players")

local Runtime = {}

local DEFENSE_ID = "TempleResonanceWard"
local TICK_SECONDS = 0.25

local function active_member(
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

local function player_root(
    player: Player
): BasePart?
    local character = player.Character
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")
    local root = character
        and character:FindFirstChild("HumanoidRootPart")

    if not humanoid
        or humanoid.Health <= 0
        or not root
        or not root:IsA("BasePart")
    then
        return nil
    end

    return root
end

local function distance_to_part(
    player: Player,
    target: BasePart
): number
    local root = player_root(player)
    if not root then
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
    ward: BasePart
): ProximityPrompt
    local existing = ward:FindFirstChild("DefensePrompt")
    if existing and existing:IsA("ProximityPrompt") then
        return existing
    end

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "DefensePrompt"
    prompt.ActionText = "Defend"
    prompt.ObjectText = "Resonance Ward"
    prompt.HoldDuration = 0.35
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = false
    prompt.Parent = ward

    return prompt
end

local function holders_in_zone(
    session: any,
    ward: BasePart,
    radius: number
): {number}
    local holders = {}

    for _, user_id in ipairs(session.MemberUserIds or {}) do
        if active_member(session, user_id) then
            local player = Players:GetPlayerByUserId(user_id)
            local root = player and player_root(player)
            if root
                and (root.Position - ward.Position).Magnitude
                    <= radius
            then
                table.insert(holders, user_id)
            end
        end
    end

    return holders
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
        if player and active_member(session, user_id) then
            config.on_profile_changed(player)
        end
    end
end

local function prompt_should_enable(
    config: any,
    status: any
): boolean
    local session = config.get_session()
    if not session or session.State ~= "Active" then
        return false
    end

    return encounter_cleared(
        session,
        config.definition.StartAfterEncounterId
    )
        and not encounter_cleared(
            session,
            config.definition.FinishEncounterId
        )
        and status.started ~= true
        and status.completed ~= true
end

local function run_defense(
    config: any,
    ward: BasePart,
    prompt: ProximityPrompt
)
    prompt.Enabled = false

    while true do
        local session_id = config.get_session_id()
        local session = config.get_session()
        if type(session_id) ~= "string"
            or not session
            or session.State ~= "Active"
        then
            return
        end

        local status = config.defense_service:status(
            session_id,
            DEFENSE_ID
        )
        if not status.ok
            or status.completed
            or not status.started
        then
            prompt.Enabled = status.ok
                and prompt_should_enable(config, status)
            return
        end

        local holders = holders_in_zone(
            session,
            ward,
            config.definition.ZoneRadius
        )
        local ticked = config.defense_service:tick(
            session_id,
            DEFENSE_ID,
            TICK_SECONDS,
            holders
        )

        if not ticked.ok then
            return
        end
        if ticked.completed then
            prompt.Enabled = false
            notify_party(config, config.get_session())
            return
        end
        if ticked.reset then
            local reset_status = config.defense_service:status(
                session_id,
                DEFENSE_ID
            )
            prompt.Enabled = reset_status.ok
                and prompt_should_enable(
                    config,
                    reset_status
                )
            return
        end

        task.wait(TICK_SECONDS)
    end
end

local function sync_prompt_loop(
    config: any,
    prompt: ProximityPrompt
)
    while true do
        local session_id = config.get_session_id()
        local session = config.get_session()
        if type(session_id) ~= "string"
            or not session
            or session.State ~= "Active"
        then
            prompt.Enabled = false
            return
        end

        local status = config.defense_service:status(
            session_id,
            DEFENSE_ID
        )
        if status.ok and not status.started then
            prompt.Enabled = prompt_should_enable(
                config,
                status
            )
        end

        task.wait(TICK_SECONDS)
    end
end

--[[
Binds the Room-2 defend/survive ward to server-measured party positions.

Args:
    config (any): Runtime services, definition and session callbacks.

Returns:
    any: Binding result and physical ward when applicable.
]]
function Runtime.attach(config: any): any
    assert(type(config) == "table")
    assert(config.defense_service ~= nil)
    assert(config.definition ~= nil)
    assert(type(config.get_session) == "function")
    assert(type(config.get_session_id) == "function")

    if config.dungeon_id ~= config.definition.DungeonId
        or config.difficulty_id ~= config.definition.DifficultyId
    then
        return {
            ok = true,
            bound = false,
            reason = "DefenseNotApplicable",
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
            reason = "DefensePresentationNotPresent",
        }
    end

    local ward = root:FindFirstChild(
        "ResonanceDefenseWard",
        true
    )
    if not ward or not ward:IsA("BasePart") then
        return {
            ok = false,
            reason = "DefenseWardMissing",
        }
    end

    local prompt = ensure_prompt(ward)
    local running = false

    local initial = config.defense_service:status(
        config.get_session_id(),
        DEFENSE_ID
    )
    if initial.ok then
        prompt.Enabled = prompt_should_enable(
            config,
            initial
        )
        if initial.started and not initial.completed then
            running = true
            task.spawn(function()
                run_defense(config, ward, prompt)
                running = false
            end)
        end
    end

    prompt.Triggered:Connect(function(player: Player)
        if running
            or Players:GetPlayerByUserId(player.UserId) ~= player
        then
            return
        end

        local session_id = config.get_session_id()
        if type(session_id) ~= "string" then
            return
        end

        local started = config.defense_service:start(
            session_id,
            player.UserId,
            DEFENSE_ID,
            distance_to_part(player, ward)
        )
        if not started.ok or started.already_completed then
            return
        end

        running = true
        task.spawn(function()
            run_defense(config, ward, prompt)
            running = false
        end)
    end)

    task.spawn(function()
        sync_prompt_loop(config, prompt)
    end)

    return {
        ok = true,
        bound = true,
        ward = ward,
        prompt = prompt,
    }
end

return table.freeze(Runtime)
