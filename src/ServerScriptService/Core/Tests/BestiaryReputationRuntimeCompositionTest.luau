--!strict
-- FOCUSED_EDIT_ONLY_RUNTIME_COMPOSITION_TEST
local RunService = game:GetService("RunService")

if RunService:IsRunning() then
    print(
        "[Bestiary Reputation Runtime Composition Tests] SKIP: runtime composition regression "
            .. "runs in focused Edit mode"
    )
    return
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService
    :WaitForChild("Core")
    :WaitForChild("Services")

local RuntimeServices = require(
    Services:WaitForChild("RuntimeServices")
)

local assertions = 0

local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error(
            "[Bestiary Reputation Runtime Composition Tests] " .. message,
            2
        )
    end
end

local base = RuntimeServices.new("Base")
check(base.BestiaryService ~= nil, "Base must compose BestiaryService.")
check(base.ReputationService ~= nil, "Base must compose ReputationService.")

local dungeon = RuntimeServices.new("Dungeon")
check(dungeon.BestiaryService ~= nil, "Dungeon must compose BestiaryService.")
check(
    dungeon.ReputationService ~= nil,
    "Dungeon must compose ReputationService."
)

local core = ReplicatedStorage:WaitForChild("Core")
local remotes = core:FindFirstChild("Remotes")

if remotes then
    for _, forbidden in ipairs({
        "BestiaryKillRequest",
        "SetBestiaryProgress",
        "ReputationAwardRequest",
        "SetReputation",
    }) do
        check(
            remotes:FindFirstChild(forbidden) == nil,
            "Client mutation remote must not exist: " .. forbidden
        )
    end
end

print(string.format(
    "[Bestiary Reputation Runtime Composition Tests] PASS: %d assertions.",
    assertions
))