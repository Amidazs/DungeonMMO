--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local Modifiers = require(Shared:WaitForChild("DungeonModifierDefinitions"))

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Dungeon Modifier Definitions Tests] " .. message, 2)
    end
end

local fortified = assert(Modifiers.get("Fortified"))
local rich = assert(Modifiers.get("RichDeposits"))
local bounty = assert(Modifiers.get("Bounty"))
check(fortified.EnemyHealthMultiplier == 1.20, "Fortified multiplier mismatch.")
check(rich.GatherYieldBonus == 1, "Rich Deposits bonus mismatch.")
check(bounty.MonsterGoldMultiplier == 1.10, "Bounty multiplier mismatch.")

local first = Modifiers.resolve("TestDungeon", "session-a", "2026-09-17")
local second = Modifiers.resolve("TestDungeon", "session-a", "2026-09-17")
check(first == second, "Modifier selection must be deterministic.")
check(Modifiers.get(first) ~= nil, "Resolved modifier must be defined.")
check(#Modifiers.all() == 3, "Phase 3 proof must expose exactly three modifiers.")

print(string.format("[Dungeon Modifier Definitions Tests] PASS: %d assertions.", assertions))
