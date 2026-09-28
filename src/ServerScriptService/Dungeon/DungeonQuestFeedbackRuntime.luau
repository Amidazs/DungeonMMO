--!strict
-- Lightweight world-space feedback for accepted Dungeon Adventure mechanics.

local Runtime = {}

local UPDATE_SECONDS = 0.25

--[[
Creates or returns one world-space quest feedback label.

Args:
    anchor (BasePart): Physical quest object that owns the label.

Returns:
    TextLabel: Label whose text and visibility may be refreshed.
]]
local function ensure_label(anchor: BasePart): TextLabel
    local existing = anchor:FindFirstChild("QuestFeedback")
    if existing and existing:IsA("BillboardGui") then
        local label = existing:FindFirstChild("Text")
        if label and label:IsA("TextLabel") then
            return label
        end
        existing:Destroy()
    elseif existing then
        existing:Destroy()
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "QuestFeedback"
    billboard.Size = UDim2.fromOffset(300, 68)
    billboard.StudsOffset = Vector3.new(0, 4.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = false
    billboard.Parent = anchor

    local label = Instance.new("TextLabel")
    label.Name = "Text"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 0.2
    label.TextScaled = true
    label.TextWrapped = true
    label.Parent = billboard

    return label
end

--[[
Updates one feedback label and its containing billboard.

Args:
    label (TextLabel): World-space feedback text.
    text (string): Player-facing status text.
    visible (boolean): Whether the feedback should be shown.

Returns:
    nil: Mutates only replaceable presentation.
]]
local function set_label(
    label: TextLabel,
    text: string,
    visible: boolean
)
    label.Text = text

    local billboard = label.Parent
    if billboard and billboard:IsA("BillboardGui") then
        billboard.Enabled = visible
    end
end

--[[
Returns the current authoritative encounter state.

Args:
    session (any): Current Dungeon session.
    encounter_id (string): Stable encounter identifier.

Returns:
    string?: Persisted encounter state.
]]
local function encounter_state(
    session: any,
    encounter_id: string
): string?
    local runtime = session
        and session.InstanceState
        and session.InstanceState.EncounterRuntime
    local states = runtime and runtime.EncounterStates
    local value = type(states) == "table"
        and states[encounter_id]
        or nil

    return if type(value) == "string"
        then value
        else nil
end

--[[
Returns whether one encounter is authoritatively cleared.

Args:
    session (any): Current Dungeon session.
    encounter_id (string): Stable encounter identifier.

Returns:
    boolean: True only for persisted Cleared state.
]]
local function encounter_cleared(
    session: any,
    encounter_id: string
): boolean
    return encounter_state(session, encounter_id) == "Cleared"
end

--[[
Returns one persisted instance-state table.

Args:
    session (any): Current Dungeon session.
    collection_name (string): InstanceState collection key.
    item_id (string): Stable state entry identifier.

Returns:
    any?: Persisted state entry when available.
]]
local function saved_state(
    session: any,
    collection_name: string,
    item_id: string
): any?
    local instance_state = session and session.InstanceState
    local collection = instance_state
        and instance_state[collection_name]

    return type(collection) == "table"
        and collection[item_id]
        or nil
end

--[[
Attaches tutorial feedback to the Temple hidden-panel mechanic.

Args:
    root (Instance): Current Temple environment root.
    get_session (() -> any): Current session callback.

Returns:
    (() -> nil)?: Refresh callback when the physical objects exist.
]]
local function hidden_room_feedback(
    root: Instance,
    get_session: () -> any
): (() -> nil)?
    local panel = root:FindFirstChild("HiddenPanel", true)
    if not panel or not panel:IsA("BasePart") then
        return nil
    end

    local label = ensure_label(panel)

    return function()
        local session = get_session()
        local interactions = session
            and session.InstanceState
            and session.InstanceState.QuestInteractions
        local opened = type(interactions) == "table"
            and interactions.TempleHiddenPanel == true
        local room_one_clear = encounter_cleared(
            session,
            "CombatRoom1"
        )

        if opened then
            set_label(
                label,
                "Hidden passage revealed",
                true
            )
        elseif room_one_clear then
            set_label(
                label,
                "Faded Stone Panel\n"
                    .. "Activate to reveal a hidden passage",
                true
            )
        else
            set_label(label, "", false)
        end
    end
end

--[[
Attaches progress feedback to the Temple resonance puzzle.

Args:
    root (Instance): Current Temple environment root.
    get_session (() -> any): Current session callback.

Returns:
    (() -> nil)?: Refresh callback when the physical puzzle exists.
]]
local function puzzle_feedback(
    root: Instance,
    get_session: () -> any
): (() -> nil)?
    local puzzle = root:FindFirstChild(
        "ResonancePuzzle",
        true
    )
    if not puzzle then
        return nil
    end

    local anchor = puzzle:FindFirstChild("Moon")
    if not anchor or not anchor:IsA("BasePart") then
        return nil
    end

    local label = ensure_label(anchor)
    local sequence = {"Moon", "Root", "Flame"}

    return function()
        local session = get_session()
        local room_one_clear = encounter_cleared(
            session,
            "CombatRoom1"
        )
        local room_two_clear = encounter_cleared(
            session,
            "CombatRoom2"
        )
        local state = saved_state(
            session,
            "PuzzleStates",
            "TempleResonanceLock"
        )

        if type(state) == "table"
            and state.Completed == true
        then
            set_label(
                label,
                "Resonant Seal restored",
                true
            )
            return
        end

        if room_two_clear then
            local next_index = type(state) == "table"
                and tonumber(state.NextIndex)
                or 1
            next_index = math.clamp(
                math.floor(next_index or 1),
                1,
                #sequence
            )
            set_label(
                label,
                "Resonant Seal\n"
                    .. "Order: Moon → Root → Flame\n"
                    .. "Next: "
                    .. sequence[next_index],
                true
            )
        elseif room_one_clear then
            set_label(
                label,
                "A Resonance Shard can be recovered here\n"
                    .. "Secure Room 2 before attuning the runes",
                true
            )
        else
            set_label(label, "", false)
        end
    end
end

--[[
Attaches state feedback to the Temple defend/survive ward.

Args:
    root (Instance): Current Temple environment root.
    get_session (() -> any): Current session callback.

Returns:
    (() -> nil)?: Refresh callback when the ward exists.
]]
local function defense_feedback(
    root: Instance,
    get_session: () -> any
): (() -> nil)?
    local ward = root:FindFirstChild(
        "ResonanceDefenseWard",
        true
    )
    if not ward or not ward:IsA("BasePart") then
        return nil
    end

    local label = ensure_label(ward)

    return function()
        local session = get_session()
        local room_one_clear = encounter_cleared(
            session,
            "CombatRoom1"
        )
        local state = saved_state(
            session,
            "DefenseStates",
            "TempleResonanceWard"
        )

        if type(state) == "table"
            and state.Completed == true
        then
            set_label(
                label,
                "Resonance Ward stabilised",
                true
            )
        elseif type(state) == "table"
            and state.Started == true
        then
            local unheld = tonumber(
                state.UnheldSeconds
            ) or 0

            if unheld > 0 then
                set_label(
                    label,
                    string.format(
                        "RETURN TO THE WARD\n"
                            .. "Grace remaining: %.1fs",
                        math.max(0, 3 - unheld)
                    ),
                    true
                )
            else
                set_label(
                    label,
                    "HOLD THE RESONANCE WARD\n"
                        .. "Stay within 18 studs",
                    true
                )
            end
        elseif room_one_clear then
            local failures = type(state) == "table"
                and tonumber(state.FailureCount)
                or 0
            local prefix = if (failures or 0) > 0
                then "Ward reset — activate again"
                else "Resonance Ward ready"
            set_label(
                label,
                prefix .. "\nDefend while Room 2 is secured",
                true
            )
        else
            set_label(label, "", false)
        end
    end
end

--[[
Attaches state feedback to the Lost Surveyor escort.

Args:
    root (Instance): Current Mine environment root.
    get_session (() -> any): Current session callback.

Returns:
    (() -> nil)?: Refresh callback when the escort actor exists.
]]
local function escort_feedback(
    root: Instance,
    get_session: () -> any
): (() -> nil)?
    local actor = root:FindFirstChild(
        "LostSurveyor",
        true
    )
    if not actor or not actor:IsA("BasePart") then
        return nil
    end

    local label = ensure_label(actor)

    return function()
        local session = get_session()
        local state = saved_state(
            session,
            "EscortStates",
            "MineSurveyor"
        )

        if type(state) ~= "table"
            or state.Started ~= true
        then
            set_label(
                label,
                "Lost Surveyor\nTalk to begin escort",
                true
            )
        elseif state.Completed == true then
            set_label(
                label,
                "Surveyor safe",
                true
            )
        elseif state.Phase == "WaitingForRoom2" then
            set_label(
                label,
                "Surveyor waiting\nSecure Room 2",
                true
            )
        elseif state.Phase == "ToFinish" then
            set_label(
                label,
                "Route clear\nStay nearby to reach safety",
                true
            )
        else
            set_label(
                label,
                "Escort active\nStay nearby",
                true
            )
        end
    end
end

--[[
Finds the current replaceable Dungeon presentation root.

Args:
    workspace_root (Instance): Workspace-like root.
    dungeon_id (string): Current server-owned Dungeon ID.

Returns:
    Instance?: Synthetic or placeholder root for quest presentation.
]]
local function presentation_root(
    workspace_root: Instance,
    dungeon_id: string
): Instance?
    if dungeon_id == "TestDungeon" then
        return workspace_root:FindFirstChild(
            "DungeonMMOSyntheticTemple"
        )
            or workspace_root:FindFirstChild(
                "DungeonMMOPlaceholderPhysicalContent"
            )
    elseif dungeon_id == "AbandonedMine" then
        return workspace_root:FindFirstChild(
            "DungeonMMOSyntheticMine"
        )
    end

    return nil
end

--[[
Binds visible feedback to already accepted Dungeon quest mechanics.

Args:
    config (any): Dungeon ID, difficulty, Workspace and session callback.

Returns:
    any: Binding result with the number of active feedback surfaces.
]]
function Runtime.attach(config: any): any
    assert(type(config) == "table")
    assert(type(config.get_session) == "function")

    if config.difficulty_id ~= "Depth1" then
        return {
            ok = true,
            bound = false,
            feedback_count = 0,
        }
    end

    local root = presentation_root(
        config.workspace,
        config.dungeon_id
    )
    if not root then
        return {
            ok = true,
            bound = false,
            feedback_count = 0,
        }
    end

    local refreshers = {}

    local candidates = if config.dungeon_id == "TestDungeon"
        then {
            hidden_room_feedback(root, config.get_session),
            puzzle_feedback(root, config.get_session),
            defense_feedback(root, config.get_session),
        }
        else {
            escort_feedback(root, config.get_session),
        }

    for _, refresher in ipairs(candidates) do
        if refresher then
            table.insert(refreshers, refresher)
        end
    end

    for _, refresh in ipairs(refreshers) do
        refresh()
    end

    task.spawn(function()
        while true do
            local session = config.get_session()
            if not session or session.State ~= "Active" then
                break
            end

            for _, refresh in ipairs(refreshers) do
                refresh()
            end

            task.wait(UPDATE_SECONDS)
        end
    end)

    return {
        ok = true,
        bound = #refreshers > 0,
        feedback_count = #refreshers,
    }
end

return table.freeze(Runtime)
