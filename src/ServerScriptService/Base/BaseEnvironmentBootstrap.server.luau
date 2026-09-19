--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Definitions = require(
    ReplicatedStorage
        :WaitForChild("Core")
        :WaitForChild("Shared")
        :WaitForChild("EnvironmentAnchorDefinitions")
)
local BankConfig = require(
    ReplicatedStorage
        :WaitForChild("Core")
        :WaitForChild("Shared")
        :WaitForChild("BankConfig")
)

local TravelConfig = require(
    ReplicatedStorage
        :WaitForChild("Core")
        :WaitForChild("Shared")
        :WaitForChild("TravelConfig")
)

local Environment = ServerScriptService
    :WaitForChild("Core")
    :WaitForChild("Environment")
local RuntimeMode = require(
    Environment:WaitForChild("EnvironmentRuntimeMode")
)
local Factory = require(
    Environment:WaitForChild("EnvironmentAnchorFactory")
)
local Resolver = require(
    Environment:WaitForChild("EnvironmentAnchorResolver")
)
local CandidateAnchorPlacement = require(
    Environment:WaitForChild("CandidateAnchorPlacement")
)
local Synthetic = require(
    script.Parent:WaitForChild("BaseSyntheticEnvironment")
)
local CandidateProfile = require(
    script.Parent:WaitForChild("BaseCandidateAnchorProfile")
)
local TravelCandidateLandmarkResolver = require(
    script.Parent:WaitForChild("TravelCandidateLandmarkResolver")
)

local READY_ATTRIBUTE = "DungeonMMOBaseEnvironmentReady"
local ERROR_ATTRIBUTE = "DungeonMMOBaseEnvironmentError"
local MODE_ATTRIBUTE = "DungeonMMOEnvironmentMode"

Workspace:SetAttribute(READY_ATTRIBUTE, false)
Workspace:SetAttribute(ERROR_ATTRIBUTE, nil)

--[[
Raises a Base bootstrap failure with a consistent error prefix.

Args:
    reason (string): Failure detail to include in the error.

Returns:
    never: This helper always raises an error.
]]
local function fail(reason: string): never
    Workspace:SetAttribute(ERROR_ATTRIBUTE, reason)
    Workspace:SetAttribute(READY_ATTRIBUTE, false)
    error("[Base Environment] " .. reason)
end

--[[
Finds exactly one descendant with a requested name.

Args:
    root (Instance): Root instance to search.
    name (string): Descendant name to find.

Returns:
    Instance?: Unique matching descendant, or nil when none exists.
]]
local function find_unique_named(
    root: Instance,
    name: string
): Instance?
    local found: Instance? = nil
    for _, instance in ipairs(root:GetDescendants()) do
        if instance.Name == name then
            if found then
                return nil
            end
            found = instance
        end
    end
    return found
end

--[[
Returns a world pivot for supported environment instances.

Args:
    instance (Instance): Model or BasePart to inspect.

Returns:
    CFrame?: World pivot when the instance supports one.
]]
local function pivot_of(instance: Instance): CFrame?
    if instance:IsA("BasePart") then
        return instance.CFrame
    elseif instance:IsA("Model") then
        return instance:GetPivot()
    end
    return nil
end

--[[
Creates semantic Base anchors from the configured candidate environment.

Args:
    None.

Returns:
    any: Resolved candidate-anchor result used by bootstrap.
]]
local function create_candidate_anchors()
    for _, entry in ipairs(CandidateProfile.Entries) do
        local selected: any = nil
        local selected_cframe: CFrame? = nil

        if type(entry.DynamicRule) == "table" then
            local dynamic =
                TravelCandidateLandmarkResolver.resolve(
                    Workspace,
                    entry.DynamicRule
                )

            if not dynamic.ok or not dynamic.instance then
                local details = ""
                if type(dynamic.matches) == "table"
                    and #dynamic.matches > 0
                then
                    details = ":" .. table.concat(
                        dynamic.matches,
                        "|"
                    )
                end

                fail(
                    tostring(
                        dynamic.reason
                            or "CandidateLandmarkMissing"
                    )
                        .. ":"
                        .. tostring(entry.AnchorId)
                        .. details
                )
            end

            selected = entry.DynamicSelector
                or {Offset = CFrame.new()}

            selected_cframe =
                CandidateAnchorPlacement.resolve(
                    dynamic.instance,
                    selected
                )
        else
            for _, selector in ipairs(entry.Selectors) do
                local landmark = find_unique_named(
                    Workspace,
                    selector.Name
                )
                local placement = landmark
                    and CandidateAnchorPlacement.resolve(
                        landmark,
                        selector
                    )

                if landmark and placement then
                    selected = selector
                    selected_cframe = placement
                    break
                end
            end
        end

        if not selected or not selected_cframe then
            fail(
                "CandidateLandmarkMissing:"
                    .. tostring(entry.AnchorId)
            )
        end

        Factory.create(
            Workspace,
            CandidateProfile.EnvironmentId,
            entry.AnchorId,
            selected_cframe,
            entry.Size,
            entry.Role
        )
    end
end

--[[
Creates or reuses a ProximityPrompt on a Base anchor.

Args:
    anchor (BasePart): Anchor that owns the prompt.
    name (string): Prompt instance name.
    action_text (string): Player-facing action verb.
    object_text (string): Player-facing object name.

Returns:
    ProximityPrompt: Existing or newly created prompt.
]]
local function ensure_prompt(
    anchor: BasePart,
    name: string,
    action_text: string,
    object_text: string
): ProximityPrompt
    local existing = anchor:FindFirstChild(name)
    if existing and existing:IsA("ProximityPrompt") then
        return existing
    end

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = name
    prompt.ActionText = action_text
    prompt.ObjectText = object_text
    prompt.HoldDuration = 0.15
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = anchor
    return prompt
end

--[[
Creates a world-space label when an anchor does not have one.

Args:
    anchor (BasePart): Anchor that owns the label.
    text (string): Player-facing label text.

Returns:
    None.
]]
local function ensure_label(
    anchor: BasePart,
    text: string
)
    local existing = anchor:FindFirstChild("EnvironmentAnchorLabel")
    if existing then
        return
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EnvironmentAnchorLabel"
    billboard.Size = UDim2.fromOffset(230, 46)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = anchor

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 0.3
    label.TextScaled = true
    label.TextWrapped = true
    label.Text = text
    label.Parent = billboard
end

local requested = Workspace:GetAttribute(MODE_ATTRIBUTE)
local mode, mode_error = RuntimeMode.resolve(
    RunService:IsStudio(),
    requested
)
if not mode then
    fail(tostring(mode_error))
end

if mode == "Synthetic" then
    Factory.clear_generated(Workspace)
    Synthetic.create(Workspace)
elseif mode == "Candidate" then
    Factory.clear_generated(Workspace)
    create_candidate_anchors()
end

local resolved = Resolver.resolve(Workspace, Definitions.BASE)
if not resolved.ok then
    fail(
        tostring(resolved.reason)
            .. ":"
            .. tostring(resolved.anchor_id or "")
    )
end

local trainer_data = {
    ["Base.Trainer.Fighter"] = {"FighterTrainer", "Fighter Trainer"},
    ["Base.Trainer.Mage"] = {"MageTrainer", "Mage Trainer"},
    ["Base.Trainer.Ranger"] = {"RangerTrainer", "Ranger Trainer"},
    ["Base.Trainer.Rogue"] = {"RogueTrainer", "Rogue Trainer"},
}

for anchor_id, data in pairs(trainer_data) do
    local anchor = resolved.by_id[anchor_id]
    anchor:SetAttribute("TrainerId", data[1])
    ensure_prompt(
        anchor,
        "ProgressionTrainerPrompt",
        "Train",
        data[2]
    )
    ensure_label(anchor, data[2])
end

local equipment = resolved.by_id["Base.Service.Equipment"]
ensure_prompt(
    equipment,
    "EquipmentManagerPrompt",
    "Manage",
    "Equipment"
)
ensure_label(equipment, "EQUIPMENT")

local bank = resolved.by_id["Base.Service.Bank"]
local bank_prompt = ensure_prompt(
    bank,
    "BankPrompt",
    "Open",
    "Bank"
)
bank_prompt.MaxActivationDistance = BankConfig.ACCESS_DISTANCE
ensure_label(bank, "BANK")

local travel_service = resolved.by_id["Base.Service.Travel"]
local travel_prompt = ensure_prompt(
    travel_service,
    "TravelPrompt",
    "Travel",
    "Travel Gem"
)
travel_prompt.KeyboardKeyCode = Enum.KeyCode.E
travel_prompt.HoldDuration = TravelConfig.HOLD_DURATION
travel_prompt.MaxActivationDistance = TravelConfig.ACCESS_DISTANCE
ensure_label(travel_service, "TRAVEL GEM")


local board = resolved.by_id["Base.DungeonBoard"]
ensure_prompt(
    board,
    "DungeonBoardPrompt",
    "Inspect",
    "Temple Dungeon Board"
)
ensure_label(board, "TEMPLE DUNGEON")

local portal = resolved.by_id["Base.TemplePortal"]
portal:SetAttribute("DungeonId", "TestDungeon")
ensure_prompt(
    portal,
    "DungeonEntryPrompt",
    if RunService:IsStudio()
        then "Test Temple"
        else "Enter Temple",
    "Temple Dungeon"
)
ensure_label(portal, "TEMPLE")

local market = resolved.by_id["Base.Travel.Market"]
local market_prompt = ensure_prompt(
    market,
    "AuctionHousePrompt",
    "Browse",
    "Auction House"
)
market_prompt.KeyboardKeyCode = Enum.KeyCode.E
market_prompt.MaxActivationDistance = 12
ensure_label(market, "AUCTION HOUSE")

local progression = resolved.by_id["Base.Service.Progression"]
ensure_label(progression, "PROGRESSION")

for anchor_id, text in pairs({
    ["Base.Profession.BlacksmithingPlaceholder"] = "BLACKSMITHING",
    ["Base.Profession.AlchemyPlaceholder"] = "ALCHEMY",
    ["Base.TrainingArea"] = "TRAINING AREA",
}) do
    ensure_label(resolved.by_id[anchor_id], text)
end

if mode == "Candidate" then
    local ids = {}
    for anchor_id in pairs(resolved.by_id) do
        table.insert(ids, anchor_id)
    end
    table.sort(ids)
    for _, anchor_id in ipairs(ids) do
        print(string.format(
            "[Base Environment Candidate] %s -> %s",
            anchor_id,
            tostring(resolved.by_id[anchor_id].Position)
        ))
    end
    print(string.format(
        "[Base Environment Candidate] RESOLVED %d anchors.",
        #ids
    ))
end

Workspace:SetAttribute(
    "DungeonMMOResolvedEnvironmentMode",
    mode
)
Workspace:SetAttribute(READY_ATTRIBUTE, true)
print("[Base Environment] Ready in " .. mode .. " mode.")
