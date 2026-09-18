--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Combat = ServerScriptService:WaitForChild("Combat")
local module = Combat:FindFirstChild("EnemyDamageMultiplierRules")
if not module then
    error(
        "[Enemy Damage Multiplier Rules Tests] RED: "
            .. "EnemyDamageMultiplierRules is missing."
    )
end

local Rules = require(module)
local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error("[Enemy Damage Multiplier Rules Tests] " .. message, 2)
    end
end

local enemy = Instance.new("Model")
check(
    Rules.get(enemy) == 1,
    "Missing multiplier attribute must default to exactly 1."
)

enemy:SetAttribute("DungeonDamageMultiplier", 1.35)
check(
    Rules.get(enemy) == 1.35,
    "Server-set multiplier attribute must be read."
)

enemy:SetAttribute("DungeonDamageMultiplier", -20)
check(
    Rules.get(enemy) == 0,
    "Negative multipliers must clamp to zero."
)

enemy:Destroy()

print(string.format(
    "[Enemy Damage Multiplier Rules Tests] PASS: %d assertions.",
    assertion_count
))
