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
local Synthetic = require(
    script.Parent:WaitForChild("TempleSyntheticEnvironment")
)
local CandidateProfile = require(
    script.Parent:WaitForChild("TempleCandidateAnchorProfile")
)

local READY_ATTRIBUTE = "DungeonMMOTempleEnvironmentReady"
local ERROR_ATTRIBUTE = "DungeonMMOTempleEnvironmentError"
local MODE_ATTRIBUTE = "DungeonMMOEnvironmentMode"

Workspace:SetAttribute(READY_ATTRIBUTE, false)
Workspace:SetAttribute(ERROR_ATTRIBUTE, nil)

local function fail(reason: string): never
    Workspace:SetAttribute(ERROR_ATTRIBUTE, reason)
    Workspace:SetAttribute(READY_ATTRIBUTE, false)
    error("[Temple Environment] " .. reason)
end

local function find_unique_named(root: Instance, name: string): Instance?
    local found: Instance? = nil

    if root.Name == name then
        found = root
    end

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

local function create_candidate_anchors()
    local landmark = find_unique_named(
        Workspace,
        CandidateProfile.RequiredLandmark
    )
    if not landmark then
        fail(
            "CandidateLandmarkMissing:"
                .. CandidateProfile.RequiredLandmark
        )
    end

    for _, entry in ipairs(CandidateProfile.Entries) do
        local anchor = Factory.create(
            Workspace,
            CandidateProfile.EnvironmentId,
            entry.AnchorId,
            entry.CFrame,
            entry.Size,
            entry.Role
        )
        anchor.CanTouch = entry.CanTouch == true
        anchor.CanCollide = entry.CanCollide == true
    end
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

local resolved = Resolver.resolve(Workspace, Definitions.TEMPLE)
if not resolved.ok then
    fail(
        tostring(resolved.reason)
            .. ":"
            .. tostring(resolved.anchor_id or "")
    )
end

for _, anchor_id in ipairs({
    "Temple.Room1.Trigger",
    "Temple.Room2.Trigger",
    "Temple.Room3.Trigger",
}) do
    local trigger = resolved.by_id[anchor_id]
    trigger.CanTouch = true
    trigger.CanCollide = false
    trigger.Transparency = 1
end

for _, anchor_id in ipairs({
    "Temple.Room1.ExitBarrier",
    "Temple.Room2.ExitBarrier",
}) do
    local barrier = resolved.by_id[anchor_id]
    if barrier then
        barrier.CanCollide = true
        barrier.CanTouch = false
        barrier.Transparency = 1
    end
end

if mode == "Candidate" then
    local ids = {}
    for anchor_id in pairs(resolved.by_id) do
        table.insert(ids, anchor_id)
    end
    table.sort(ids)

    for _, anchor_id in ipairs(ids) do
        print(string.format(
            "[Temple Environment Candidate] %s -> %s",
            anchor_id,
            tostring(resolved.by_id[anchor_id].Position)
        ))
    end

    for group_name, group in pairs(resolved.groups) do
        print(string.format(
            "[Temple Environment Candidate] %s -> %d anchors",
            group_name,
            #group
        ))
    end

    print(string.format(
        "[Temple Environment Candidate] RESOLVED %d exact anchors.",
        #ids
    ))
end

Workspace:SetAttribute(
    "DungeonMMOResolvedEnvironmentMode",
    mode
)
Workspace:SetAttribute(READY_ATTRIBUTE, true)
print("[Temple Environment] Ready in " .. mode .. " mode.")
