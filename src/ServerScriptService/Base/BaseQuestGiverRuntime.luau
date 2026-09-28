--!strict
-- Physical Base quest-giver placeholders bound to trusted Adventure state.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")

local QuestDefinitions = require(
    Shared:WaitForChild("QuestDefinitions")
)
local QuestGiverDefinitions = require(
    Shared:WaitForChild("QuestGiverDefinitions")
)

local Runtime = {}
Runtime.__index = Runtime

local FOLDER_NAME = "DungeonMMOQuestGivers"

--[[
Creates or returns the generated quest-giver presentation folder.

Args:
    root (Instance): Workspace-like parent for generated placeholders.

Returns:
    Folder: Stable quest-giver presentation folder.
]]
local function ensure_folder(root: Instance): Folder
    local existing = root:FindFirstChild(FOLDER_NAME)
    if existing and existing:IsA("Folder") then
        return existing
    elseif existing then
        existing:Destroy()
    end

    local folder = Instance.new("Folder")
    folder.Name = FOLDER_NAME
    folder.Parent = root
    return folder
end

--[[
Adds a readable world-space label to one placeholder giver.

Args:
    anchor (BasePart): Physical quest-giver placeholder.
    speaker (string): Player-facing role name.

Returns:
    nil: Creates the label when one is not already present.
]]
local function ensure_label(
    anchor: BasePart,
    speaker: string
)
    if anchor:FindFirstChild("QuestGiverLabel") then
        return
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "QuestGiverLabel"
    billboard.Size = UDim2.fromOffset(220, 44)
    billboard.StudsOffset = Vector3.new(0, 4.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = anchor

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 0.25
    label.TextScaled = true
    label.TextWrapped = true
    label.Text = speaker
    label.Parent = billboard
end

--[[
Creates or returns the interaction prompt for one quest giver.

Args:
    anchor (BasePart): Physical giver placeholder.
    speaker (string): Player-facing role name.

Returns:
    ProximityPrompt: Stable talk prompt.
]]
local function ensure_prompt(
    anchor: BasePart,
    speaker: string
): ProximityPrompt
    local existing = anchor:FindFirstChild("QuestGiverPrompt")
    if existing and existing:IsA("ProximityPrompt") then
        return existing
    end

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "QuestGiverPrompt"
    prompt.ActionText = "Talk"
    prompt.ObjectText = speaker
    prompt.HoldDuration = 0.1
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = anchor
    return prompt
end

--[[
Creates or refreshes one replaceable physical quest-giver placeholder.

Args:
    folder (Folder): Generated quest-giver parent.
    source_anchor (BasePart): Semantic hub anchor for this giver.
    definition (any): Quest-giver presentation definition.

Returns:
    BasePart: Physical giver anchor.
]]
local function create_giver(
    folder: Folder,
    source_anchor: BasePart,
    source_anchor_id: string,
    definition: any
): BasePart
    local existing = folder:FindFirstChild(definition.Id)
    if existing then
        existing:Destroy()
    end

    local anchor = Instance.new("Part")
    anchor.Name = definition.Id
    anchor.Size = Vector3.new(4, 6, 4)
    anchor.Anchored = true
    anchor.CanCollide = false
    anchor.Material = Enum.Material.Slate
    anchor.CFrame = source_anchor.CFrame * definition.Offset
    anchor:SetAttribute(
        "DungeonMMOQuestGiverSourceAnchor",
        source_anchor_id
    )
    anchor:SetAttribute(
        "DungeonMMOQuestGiverId",
        definition.Id
    )
    anchor:SetAttribute(
        "DungeonMMOQuestSpeaker",
        definition.Speaker
    )
    anchor.Parent = folder

    ensure_label(anchor, definition.Speaker)
    ensure_prompt(anchor, definition.Speaker)
    return anchor
end

--[[
Returns the preferred conversation for one giver and character state.

Args:
    definition (any): Quest-giver definition.
    character (any): Selected authoritative character.
    snapshot (any): Current QuestService snapshot.

Returns:
    string?: Selected quest identifier.
    string?: Start, Review, Claim or Complete mode.
]]
local function select_conversation(
    definition: any,
    character: any,
    snapshot: any
): (string?, string?)
    local active = type(snapshot.Active) == "table"
        and snapshot.Active
        or {}
    local completed = type(snapshot.Completed) == "table"
        and snapshot.Completed
        or {}

    for _, quest_id in ipairs(definition.QuestIds) do
        local state = active[quest_id]
        if type(state) == "table" and state.Ready == true then
            return quest_id, "Claim"
        end
    end

    for _, quest_id in ipairs(definition.QuestIds) do
        if type(active[quest_id]) == "table" then
            return quest_id, "Review"
        end
    end

    for _, quest_id in ipairs(definition.QuestIds) do
        local quest = QuestDefinitions.get(quest_id)
        if quest
            and completed[quest_id] ~= true
            and QuestDefinitions.is_character_eligible(
                character,
                quest
            )
        then
            return quest_id, "Start"
        end
    end

    for index = #definition.QuestIds, 1, -1 do
        local quest_id = definition.QuestIds[index]
        if completed[quest_id] == true then
            return quest_id, "Complete"
        end
    end

    return nil, nil
end

--[[
Opens the best server-selected conversation for one physical quest giver.

Args:
    player (Player): Authenticated interacting player.
    definition (any): Quest-giver presentation definition.
    anchor (BasePart): Physical giver used for contextual client distance.

Returns:
    nil: Sends only presentation state to the caller.
]]
function Runtime:open(
    player: Player,
    definition: any,
    anchor: BasePart
)
    if not self._is_ready(player) then
        return
    end

    local character = self._profiles:get_character(player.UserId)
    local snapshot = self._quests:build_snapshot(player.UserId)

    if not character or snapshot.ok ~= true then
        return
    end

    local quest_id, mode = select_conversation(
        definition,
        character,
        snapshot
    )
    if not quest_id or not mode then
        self._remote:FireClient(player, {
            ok = false,
            reason = "QuestGiverNoConversation",
            GiverId = definition.Id,
            Anchor = anchor,
        })
        return
    end

    self._remote:FireClient(player, {
        ok = true,
        QuestId = quest_id,
        Mode = mode,
        GiverId = definition.Id,
        Anchor = anchor,
    })
end

--[[
Creates physical quest givers and binds their trusted talk prompts.

Args:
    options (any): Workspace, environment, profile, quest, remote and
        readiness dependencies.

Returns:
    any: Runtime retained by prompt connections.
]]
function Runtime.attach(options: any): any
    assert(options.root ~= nil)
    assert(options.environment ~= nil)
    assert(options.profiles ~= nil)
    assert(options.quests ~= nil)
    assert(options.remote ~= nil)
    assert(type(options.is_ready) == "function")

    local self = setmetatable({
        _profiles = options.profiles,
        _quests = options.quests,
        _remote = options.remote,
        _is_ready = options.is_ready,
    }, Runtime)

    local folder = ensure_folder(options.root)

    for _, definition in ipairs(
        QuestGiverDefinitions.all()
    ) do
        local source_anchor_id = definition.AnchorId
        local source_anchor =
            options.environment:get(source_anchor_id)

        if not source_anchor
            and type(definition.FallbackAnchorId) == "string"
        then
            source_anchor_id = definition.FallbackAnchorId
            source_anchor = options.environment:get(
                source_anchor_id
            )
        end

        assert(
            source_anchor ~= nil,
            "Quest giver anchor missing: "
                .. tostring(definition.AnchorId)
        )
        local anchor = create_giver(
            folder,
            source_anchor,
            source_anchor_id,
            definition
        )
        local prompt = assert(
            anchor:FindFirstChild("QuestGiverPrompt")
        ) :: ProximityPrompt

        prompt.Triggered:Connect(function(player: Player)
            self:open(player, definition, anchor)
        end)
    end

    return self
end

return table.freeze(Runtime)
