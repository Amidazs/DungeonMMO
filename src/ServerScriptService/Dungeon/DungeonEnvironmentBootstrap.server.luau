--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")
local DungeonDefinitions = require(
    Shared:WaitForChild("DungeonDefinitions")
)
local DungeonDifficultyDefinitions = require(
    Shared:WaitForChild("DungeonDifficultyDefinitions")
)
local EnvironmentAnchorDefinitions = require(
    Shared:WaitForChild("EnvironmentAnchorDefinitions")
)

local Environment = ServerScriptService
    :WaitForChild("Core")
    :WaitForChild("Environment")
local EnvironmentRuntimeMode = require(
    Environment:WaitForChild("EnvironmentRuntimeMode")
)
local EnvironmentAnchorFactory = require(
    Environment:WaitForChild("EnvironmentAnchorFactory")
)
local EnvironmentAnchorResolver = require(
    Environment:WaitForChild("EnvironmentAnchorResolver")
)

local Dungeon = script.Parent
local TempleSyntheticEnvironment = require(
    Dungeon:WaitForChild("TempleSyntheticEnvironment")
)
local AbandonedMineSyntheticEnvironment = require(
    Dungeon:WaitForChild("AbandonedMineSyntheticEnvironment")
)
local DungeonPlaceholderPhysicalContent = require(
    Dungeon:WaitForChild("DungeonPlaceholderPhysicalContent")
)
local DungeonRuntimeSelection = require(
    Dungeon:WaitForChild("DungeonRuntimeSelection")
)
local DungeonRoomLayoutDefinitions = require(
    Dungeon:WaitForChild("DungeonRoomLayoutDefinitions")
)
local DungeonEnvironmentLayoutActivation = require(
    Dungeon:WaitForChild("DungeonEnvironmentLayoutActivation")
)
local DungeonLayoutEnvironmentContract = require(
    Dungeon:WaitForChild("DungeonLayoutEnvironmentContract")
)

local selection = DungeonRuntimeSelection.resolve_selection(
    Players,
    Workspace,
    RunService,
    DungeonDefinitions,
    DungeonDifficultyDefinitions,
    DungeonRoomLayoutDefinitions,
    15
)
assert(
    selection.ok == true,
    "Dungeon runtime selection failed: "
        .. tostring(selection.reason)
)

local dungeon_id = selection.DungeonId
local difficulty_id = selection.DifficultyId
local layout_id = selection.LayoutId

local mode, mode_error = EnvironmentRuntimeMode.resolve(
    RunService:IsStudio(),
    Workspace:GetAttribute("DungeonMMOEnvironmentMode")
)
assert(mode ~= nil, mode_error)

Workspace:SetAttribute(
    "DungeonMMODungeonEnvironmentReady",
    false
)
Workspace:SetAttribute(
    "DungeonMMODungeonEnvironmentError",
    nil
)

if mode == "Synthetic" then
    EnvironmentAnchorFactory.clear_generated(Workspace)
    if dungeon_id == DungeonDefinitions.TEST_DUNGEON.Id then
        TempleSyntheticEnvironment.create(Workspace)
    else
        AbandonedMineSyntheticEnvironment.create(Workspace)
    end
end

-- Authorable blockout geometry is an explicit Studio-only opt-in.
-- It creates physical preview parts and optional anchor points without
-- registering encounter bindings or bypassing either production release lock.
if mode == "Synthetic"
    and RunService:IsStudio()
    and Workspace:GetAttribute(
        "DungeonMMOPlaceholderPhysicalContentEnabled"
    ) == true
then
    DungeonPlaceholderPhysicalContent.create(Workspace, dungeon_id)
end

if mode == "Candidate"
    and dungeon_id ~= DungeonDefinitions.TEST_DUNGEON.Id
then
    error("MineCandidateEnvironmentNotAuthoredYet")
end

local layout = DungeonRoomLayoutDefinitions.get(
    dungeon_id,
    layout_id
)
assert(
    layout ~= nil,
    "Selected dungeon layout disappeared after selection."
)

local environment_base =
    if dungeon_id == DungeonDefinitions.TEST_DUNGEON.Id
        then EnvironmentAnchorDefinitions.TEMPLE_RUNTIME_BASE
        else EnvironmentAnchorDefinitions
            .ABANDONED_MINE_RUNTIME_BASE

local contract_result =
    DungeonLayoutEnvironmentContract.build(
        environment_base,
        layout
    )
assert(
    contract_result.ok == true,
    "Dungeon environment contract failed: "
        .. tostring(contract_result.reason)
)

local resolved_environment = EnvironmentAnchorResolver.resolve(
    Workspace,
    contract_result.Contract
)
assert(
    resolved_environment.ok,
    tostring(resolved_environment.reason)
        .. ":"
        .. tostring(resolved_environment.anchor_id)
)

local activated = DungeonEnvironmentLayoutActivation.apply(
    layout,
    resolved_environment
)
assert(
    activated.ok == true,
    "Dungeon layout activation failed: "
        .. tostring(activated.reason)
        .. ":"
        .. tostring(activated.AnchorId)
)

Workspace:SetAttribute(
    "DungeonMMOResolvedDungeonId",
    dungeon_id
)
Workspace:SetAttribute(
    "DungeonMMOResolvedDifficultyId",
    difficulty_id
)
Workspace:SetAttribute(
    "DungeonMMOResolvedLayoutId",
    layout_id
)
Workspace:SetAttribute(
    "DungeonMMOResolvedEnvironmentMode",
    mode
)
Workspace:SetAttribute(
    "DungeonMMODungeonEnvironmentReady",
    true
)

if dungeon_id == DungeonDefinitions.TEST_DUNGEON.Id then
    Workspace:SetAttribute(
        "DungeonMMOTempleEnvironmentReady",
        true
    )
end

print(
    "[Dungeon Environment] "
        .. dungeon_id
        .. " / "
        .. difficulty_id
        .. " / "
        .. layout_id
        .. " ready in "
        .. mode
        .. " mode."
)
