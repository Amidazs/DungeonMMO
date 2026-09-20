--!strict
-- Roblox Studio Command Bar, EDIT mode, existing authored TEST Lobby only.
-- Back up the CURRENT cloud place with File > Save to File before running.
-- Makes no changes to profiles, DataStores, map models, portals or scripts.
local PLACE_ID = 134132328219009
local UNIVERSE_ID = 10765241947
local RunService = game:GetService("RunService")
assert(game.PlaceId == PLACE_ID and game.GameId == UNIVERSE_ID,
    "Wrong Roblox place: open the existing TEST Lobby cloud place.")
assert(not RunService:IsRunning(),
    "Stop Play mode: this permanent anchor must be placed in Studio EDIT mode.")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local CS = game:GetService("CollectionService")
local shared = RS:WaitForChild("Core"):WaitForChild("Shared")
local defs = require(shared:WaitForChild("EnvironmentAnchorDefinitions"))
local factory = require(SSS:WaitForChild("Core")
    :WaitForChild("Environment"):WaitForChild("EnvironmentAnchorFactory"))
local resolver = require(SSS.Core.Environment.EnvironmentAnchorResolver)

local found = {}
for _, tagged in ipairs(CS:GetTagged(defs.TAG)) do
    if tagged:IsDescendantOf(workspace)
        and tagged:GetAttribute(defs.ENVIRONMENT_ATTRIBUTE) == "Base" then
        local id = tagged:GetAttribute(defs.ANCHOR_ATTRIBUTE)
        if type(id) == "string" then
            found[id] = found[id] or {}
            table.insert(found[id], tagged)
        end
    end
end

local missing, duplicates = {}, {}
for _, id in ipairs(defs.BASE.Required) do
    local matches = found[id] or {}
    if #matches == 0 then
        table.insert(missing, id)
    elseif #matches ~= 1 then
        table.insert(duplicates, id .. " (" .. #matches .. ")")
    end
end
print("[TEST Lobby Repair] Missing required Base anchors: "
    .. (#missing == 0 and "none" or table.concat(missing, ", ")))
assert(#duplicates == 0, "Duplicate required Base anchors: "
    .. table.concat(duplicates, ", "))
if #missing == 0 then
    print("[TEST Lobby Repair] No required anchors missing; nothing created.")
else
    assert(#missing == 1 and missing[1] == "Base.Trainer.Rogue",
        "More/different anchors are missing; inspect the authored map before repair.")

    -- An authored Rogue NPC is preferable; otherwise use an invisible
    -- temporary interaction point beside the EXISTING training-area anchor.
    local trainers = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("BasePart"))
            and (obj.Name == "RogueTrainer"
                or obj.Name == "Rogue Trainer"
                or obj.Name == "RogueTrainerNPC")
            and not (obj.Parent and (
                obj.Parent.Name == "RogueTrainer"
                or obj.Parent.Name == "Rogue Trainer"
                or obj.Parent.Name == "RogueTrainerNPC"))
        then
            table.insert(trainers, obj)
        end
    end
    assert(#trainers <= 1, "Multiple Rogue trainer objects; choose a location manually.")
    local position
    if #trainers == 1 then
        local obj = trainers[1]
        local pivot = if obj:IsA("Model") then obj:GetPivot() else obj.CFrame
        position = pivot * CFrame.new(0, 1, -3)
        print("[TEST Lobby Repair] Rogue NPC found: " .. obj:GetFullName())
    else
        local training = found["Base.TrainingArea"]
        assert(training and #training == 1
            and training[1]:IsA("BasePart"),
            "No Rogue NPC or unique TrainingArea anchor to place a safe marker.")
        position = training[1].CFrame * CFrame.new(6, 0, 0)
        warn("[TEST Lobby Repair] No named Rogue NPC; placing temporary invisible "
            .. "Rogue trainer marker beside existing training area. "
            .. "Reposition it later if desired.")
    end

    local part = factory.create(workspace, "Base",
        "Base.Trainer.Rogue", position, Vector3.new(3, 5, 3), "Trainer")
    assert(part and part:IsDescendantOf(workspace),
        "Rogue anchor factory did not create the part")
    print("[TEST Lobby Repair] Created: " .. part:GetFullName())
end

local result = resolver.resolve(workspace, defs.BASE)
assert(result.ok, "[TEST Lobby Repair] Still invalid: "
    .. tostring(result.reason) .. ":" .. tostring(result.anchor_id))
print("[TEST Lobby Repair] ALL_REQUIRED_BASE_ANCHORS_VALID")
local combat = RS:FindFirstChild("Combat")
local combat_shared = combat and combat:FindFirstChild("Shared")
if not (combat_shared and combat_shared:FindFirstChild("SkillDefinitions")) then
    warn("[TEST Lobby Repair] Combat.Shared.SkillDefinitions is missing; "
        .. "sync the updated test-lobby-sync.project.json before publishing.")
else
    print("[TEST Lobby Repair] COMBAT_SKILL_DEFINITIONS_PRESENT")
end
print("[TEST Lobby Repair] Edit-mode anchor repair done. "
    .. "Play-test this CURRENT CLOUD lobby, then publish the existing place "
    .. "only after the backup and race/class confirmation checks.")
