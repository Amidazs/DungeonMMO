--!strict
-- Physical Lost Surveyor escort presentation over server-owned escort state.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Runtime = {}

local ESCORT_ID = "MineSurveyor"

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

--[[
Computes server-side distance from a player to the escort actor.

Args:
    player (Player): Server-resolved dungeon member.
    actor (BasePart): Server-owned escort presentation.

Returns:
    number: Distance to actor bounds, or infinity when unavailable.
]]
local function distance_to_actor(
    player: Player,
    actor: BasePart
): number
    local character = player.Character
    local root = character
        and character:FindFirstChild("HumanoidRootPart")

    if not root or not root:IsA("BasePart") then
        return math.huge
    end

    return math.max(
        0,
        (root.Position - actor.Position).Magnitude
            - actor.Size.Magnitude * 0.25
    )
end

--[[
Returns whether at least one active party member is near the escort.

Args:
    session (any): Current authoritative dungeon session.
    actor (BasePart): Escort presentation.
    maximum_distance (number): Resume radius.

Returns:
    boolean: True when an active connected member is nearby.
]]
local function party_near(
    session: any,
    actor: BasePart,
    maximum_distance: number
): boolean
    for _, user_id in ipairs(session.MemberUserIds or {}) do
        if member_active(session, user_id) then
            local player = Players:GetPlayerByUserId(user_id)
            if player
                and distance_to_actor(player, actor)
                    <= maximum_distance
            then
                return true
            end
        end
    end

    return false
end

--[[
Waits safely until a party member returns to escort range.

Args:
    config (any): Runtime callbacks and escort definition.
    actor (BasePart): Escort presentation.

Returns:
    boolean: False only when the dungeon session stops being active.
]]
local function wait_for_party(
    config: any,
    actor: BasePart
): boolean
    while true do
        local session = config.get_session()
        if not session or session.State ~= "Active" then
            return false
        end

        if party_near(
            session,
            actor,
            config.definition.PartyResumeDistance
        ) then
            return true
        end

        task.wait(0.25)
    end
end

--[[
Returns whether one encounter is cleared in persisted runtime state.

Args:
    session (any): Current authoritative dungeon session.
    encounter_id (string): Required encounter identifier.

Returns:
    boolean: True only after the server records the encounter as cleared.
]]
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

--[[
Waits for the escort's protected room-clear pause to end.

Args:
    config (any): Runtime callbacks and escort definition.

Returns:
    boolean: False only when the dungeon session stops being active.
]]
local function wait_for_finish_encounter(config: any): boolean
    while true do
        local session = config.get_session()
        if not session or session.State ~= "Active" then
            return false
        end

        if encounter_cleared(
            session,
            config.definition.FinishAfterEncounterId
        ) then
            return true
        end

        task.wait(0.25)
    end
end

--[[
Moves the placeholder escort actor at a normal player-like running pace.

Args:
    actor (BasePart): Escort presentation to move.
    target (BasePart): Server-authored route marker.
    speed (number): Studs travelled per second.

Returns:
    nil: Yields until the deterministic server tween finishes.
]]
local function move_actor(
    actor: BasePart,
    target: BasePart,
    speed: number
)
    local distance = (
        actor.Position - target.Position
    ).Magnitude
    local duration = math.max(0.05, distance / speed)

    local tween = TweenService:Create(
        actor,
        TweenInfo.new(
            duration,
            Enum.EasingStyle.Linear
        ),
        {
            CFrame = target.CFrame,
        }
    )
    tween:Play()
    tween.Completed:Wait()
end

--[[
Creates the replaceable physical escort NPC.

Args:
    parent (Instance): Current Mine environment root.
    start_marker (BasePart): Server-authored initial location.

Returns:
    BasePart: Simple placeholder actor with no client authority.
]]
local function create_actor(
    parent: Instance,
    start_marker: BasePart
): BasePart
    local existing = parent:FindFirstChild("LostSurveyor")
    if existing and existing:IsA("BasePart") then
        existing:Destroy()
    end

    local actor = Instance.new("Part")
    actor.Name = "LostSurveyor"
    actor.Size = Vector3.new(3, 5, 3)
    actor.CFrame = start_marker.CFrame
    actor.Anchored = true
    actor.CanCollide = false
    actor.Material = Enum.Material.Wood
    actor.Color = Color3.fromRGB(145, 103, 60)
    actor:SetAttribute("DungeonMMOEscortId", ESCORT_ID)
    actor.Parent = parent

    return actor
end

--[[
Creates the server-owned prompt that begins the escort.

Args:
    actor (BasePart): Escort presentation.

Returns:
    ProximityPrompt: Start prompt.
]]
local function create_prompt(actor: BasePart): ProximityPrompt
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "EscortPrompt"
    prompt.ActionText = "Guide"
    prompt.ObjectText = "Lost Surveyor"
    prompt.HoldDuration = 0.35
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = false
    prompt.Parent = actor

    return prompt
end

--[[
Positions the actor from persisted escort phase after reconnect/reload.

Args:
    actor (BasePart): Escort presentation.
    markers (any): Server-authored route markers.
    status (any): Persisted escort lifecycle.

Returns:
    nil: Restores only presentation position.
]]
local function restore_position(
    actor: BasePart,
    markers: any,
    status: any
)
    if status.completed == true then
        actor.CFrame = markers.finish.CFrame
    elseif status.phase == "WaitingForRoom2"
        or status.phase == "ToFinish"
    then
        actor.CFrame = markers.wait.CFrame
    else
        actor.CFrame = markers.start.CFrame
    end
end

--[[
Sends updated profile snapshots to active party members.

Args:
    config (any): Runtime callbacks.
    session (any): Current authoritative dungeon session.

Returns:
    nil: Calls the existing profile update hook for connected members.
]]
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

--[[
Runs or resumes the safe-pause escort route.

Args:
    config (any): Escort service, definition and session callbacks.
    actor (BasePart): Escort presentation.
    prompt (ProximityPrompt): Start prompt.
    markers (any): Server-authored route markers.

Returns:
    nil: Stops when the escort completes or the session ends.
]]
local function run_route(
    config: any,
    actor: BasePart,
    prompt: ProximityPrompt,
    markers: any
)
    prompt.Enabled = false

    local status = config.escort_service:status(
        config.get_session_id(),
        ESCORT_ID
    )
    if not status.ok or status.completed then
        return
    end

    restore_position(actor, markers, status)

    if status.phase ~= "WaitingForRoom2"
        and status.phase ~= "ToFinish"
    then
        if not wait_for_party(config, actor) then
            return
        end

        move_actor(
            actor,
            markers.wait,
            config.definition.RunSpeed
        )
        config.escort_service:set_phase(
            config.get_session_id(),
            ESCORT_ID,
            "WaitingForRoom2"
        )
    end

    if not wait_for_finish_encounter(config) then
        return
    end

    config.escort_service:set_phase(
        config.get_session_id(),
        ESCORT_ID,
        "ToFinish"
    )

    if not wait_for_party(config, actor) then
        return
    end

    move_actor(
        actor,
        markers.finish,
        config.definition.RunSpeed
    )

    local completed = config.escort_service:complete(
        config.get_session_id(),
        ESCORT_ID
    )
    if completed.ok then
        notify_party(config, config.get_session())
    end
end

--[[
Binds the Lost Surveyor escort into the current synthetic Mine.

Args:
    config (any): Runtime dependencies and current-session accessors.

Returns:
    any: Binding result; other dungeons safely opt out.
]]
function Runtime.attach(config: any): any
    assert(type(config) == "table")
    assert(config.escort_service ~= nil)
    assert(config.definition ~= nil)
    assert(type(config.get_session) == "function")
    assert(type(config.get_session_id) == "function")

    if config.dungeon_id ~= config.definition.DungeonId
        or config.difficulty_id ~= config.definition.DifficultyId
    then
        return {
            ok = true,
            bound = false,
            reason = "EscortNotApplicable",
        }
    end

    local root = config.workspace:FindFirstChild(
        "DungeonMMOSyntheticMine"
    )
    if not root then
        return {
            ok = true,
            bound = false,
            reason = "EscortPresentationNotPresent",
        }
    end

    local start_marker = root:FindFirstChild("MineSurveyorStart")
    local wait_marker = root:FindFirstChild("MineSurveyorWait")
    local finish_marker = root:FindFirstChild("MineSurveyorFinish")

    if not start_marker or not start_marker:IsA("BasePart")
        or not wait_marker or not wait_marker:IsA("BasePart")
        or not finish_marker or not finish_marker:IsA("BasePart")
    then
        return {
            ok = false,
            reason = "EscortRouteInvalid",
        }
    end

    local markers = {
        start = start_marker,
        wait = wait_marker,
        finish = finish_marker,
    }
    local actor = create_actor(root, start_marker)
    local prompt = create_prompt(actor)
    local running = false

    local initial = config.escort_service:status(
        config.get_session_id(),
        ESCORT_ID
    )
    if initial.ok then
        restore_position(actor, markers, initial)
        prompt.Enabled = not initial.started

        if initial.started and not initial.completed then
            running = true
            task.spawn(function()
                run_route(config, actor, prompt, markers)
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

        local started = config.escort_service:start(
            config.get_session_id(),
            player.UserId,
            ESCORT_ID,
            distance_to_actor(player, actor)
        )
        if not started.ok then
            return
        end

        running = true
        task.spawn(function()
            run_route(config, actor, prompt, markers)
            running = false
        end)
    end)

    return {
        ok = true,
        bound = true,
        actor = actor,
    }
end

return table.freeze(Runtime)
