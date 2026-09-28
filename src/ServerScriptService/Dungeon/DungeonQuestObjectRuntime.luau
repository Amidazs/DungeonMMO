--!strict
-- Physical binding for trusted dungeon quest interactions and collectibles.

local Players = game:GetService("Players")

local Runtime = {}

local INTERACTION_ID = "TempleHiddenPanel"
local COLLECTIBLE_ID = "TempleHiddenWardFragment"

--[[
Computes server-side distance from a player to a physical object's bounds.

Args:
    player (Player): Server-resolved interacting player.
    target (BasePart): Trusted physical interaction object.

Returns:
    number: Distance to object bounds, or infinity when unavailable.
]]
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

--[[
Creates or returns one server-owned ProximityPrompt.

Args:
    parent (BasePart): Trusted physical prompt host.
    name (string): Stable prompt instance name.
    action_text (string): Player-facing interaction verb.
    object_text (string): Player-facing object label.

Returns:
    ProximityPrompt: Existing or newly created server prompt.
]]
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
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = false
    prompt.HoldDuration = 0.45
    prompt.Parent = parent
    return prompt
end

--[[
Returns whether the tutorial hidden-room mechanism is already active.

Args:
    session (any): Current authoritative dungeon session.

Returns:
    boolean: True when the panel activation is persisted for this run.
]]
local function hidden_room_open(session: any): boolean
    local interactions = session
        and session.InstanceState
        and session.InstanceState.QuestInteractions

    return type(interactions) == "table"
        and interactions[INTERACTION_ID] == true
end

--[[
Applies persisted hidden-room state to replaceable physical content.

Args:
    door (BasePart): Server-controlled hidden-room door.
    relic (BasePart): Personal quest collectible presentation.
    panel_prompt (ProximityPrompt): Hidden-panel interaction prompt.
    relic_prompt (ProximityPrompt): Collectible interaction prompt.
    session (any): Current authoritative dungeon session.

Returns:
    nil: Mutates only replaceable physical presentation.
]]
local function sync_presentation(
    door: BasePart,
    relic: BasePart,
    panel_prompt: ProximityPrompt,
    relic_prompt: ProximityPrompt,
    session: any
)
    local opened = hidden_room_open(session)

    door.CanCollide = not opened
    door.CanTouch = not opened
    door.Transparency = if opened then 1 else 0

    relic.Transparency = if opened then 0 else 1
    panel_prompt.Enabled = not opened
    relic_prompt.Enabled = opened
end

--[[
Binds the Temple Depth-1 hidden-room tutorial to trusted quest authority.

Args:
    config (any): Runtime dependencies and current-session accessors.

Returns:
    any: Binding result; non-Temple or authored replacements may opt out.
]]
function Runtime.attach(config: any): any
    assert(type(config) == "table")
    assert(config.quest_objects ~= nil)
    assert(type(config.get_session) == "function")
    assert(type(config.get_session_id) == "function")

    if config.dungeon_id ~= "TestDungeon"
        or config.difficulty_id ~= "Depth1"
    then
        return {
            ok = true,
            bound = false,
            reason = "QuestObjectTutorialNotApplicable",
        }
    end

    local root = config.workspace:FindFirstChild(
        "DungeonMMOPlaceholderPhysicalContent"
    )
        or config.workspace:FindFirstChild(
            "DungeonMMOSyntheticTemple"
        )

    if not root then
        return {
            ok = true,
            bound = false,
            reason = "QuestObjectPresentationNotPresent",
        }
    end

    local panel = root:FindFirstChild("HiddenPanel", true)
    local door = root:FindFirstChild("HiddenDoor", true)
    local relic = root:FindFirstChild("HiddenWardFragment", true)

    if not panel or not panel:IsA("BasePart")
        or not door or not door:IsA("BasePart")
        or not relic or not relic:IsA("BasePart")
    then
        return {
            ok = false,
            reason = "QuestObjectPresentationInvalid",
        }
    end

    local panel_prompt = ensure_prompt(
        panel,
        "HiddenPanelPrompt",
        "Activate",
        "Faded Stone Panel"
    )
    local relic_prompt = ensure_prompt(
        relic,
        "HiddenWardFragmentPrompt",
        "Collect",
        "Hidden Ward Fragment"
    )

    sync_presentation(
        door,
        relic,
        panel_prompt,
        relic_prompt,
        config.get_session()
    )

    panel_prompt.Triggered:Connect(function(player: Player)
        if Players:GetPlayerByUserId(player.UserId) ~= player then
            return
        end

        local session_id = config.get_session_id()
        if type(session_id) ~= "string" then
            return
        end

        local activated = config.quest_objects:activate(
            session_id,
            player.UserId,
            INTERACTION_ID,
            distance_to_part(player, panel)
        )
        if activated.ok ~= true then
            return
        end

        sync_presentation(
            door,
            relic,
            panel_prompt,
            relic_prompt,
            config.get_session()
        )
    end)

    relic_prompt.Triggered:Connect(function(player: Player)
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
            distance_to_part(player, relic)
        )
        if collected.ok == true
            and type(config.on_profile_changed) == "function"
        then
            config.on_profile_changed(player)
        end
    end)

    return {
        ok = true,
        bound = true,
    }
end

return table.freeze(Runtime)
