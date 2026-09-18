--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Dungeon = ServerScriptService:WaitForChild("Dungeon")
local module = Dungeon:FindFirstChild("DungeonEnemyFactoryRegistry")
if not module then
    error(
        "[Dungeon Enemy Factory Registry Tests] RED: "
            .. "DungeonEnemyFactoryRegistry is missing."
    )
end

local Registry = require(module)
local assertion_count = 0

-- Verifies one enemy-factory registry expectation.
local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error(
            "[Dungeon Enemy Factory Registry Tests] " .. message,
            2
        )
    end
end

local factory_a = {}
function factory_a.create(_options: any): Model
    return Instance.new("Model")
end

local factory_b = {}
function factory_b.create(_options: any): Model
    return Instance.new("Model")
end

local registry = Registry.new()

check(
    registry:register("Marauder", factory_a).ok == true,
    "Valid enemy factory must register."
)
check(
    registry:get("Marauder") == factory_a,
    "Registered enemy factory must resolve."
)
check(
    registry:is_registered("Marauder") == true,
    "Registered enemy factory must report present."
)
check(
    registry:register("Marauder", factory_b).reason
        == "EnemyFactoryAlreadyRegistered",
    "Duplicate enemy factory IDs must fail closed."
)
check(
    registry:register("", factory_b).reason
        == "InvalidEnemyFactory",
    "Empty enemy factory IDs must be rejected."
)

check(
    registry:register("Elite", {}).reason
        == "InvalidEnemyFactory",
    "Factories without create must be rejected."
)
check(
    registry:get("Unknown") == nil,
    "Unknown enemy factory IDs must not resolve."
)
check(
    registry:is_registered("Unknown") == false,
    "Unknown enemy factory IDs must report absent."
)

print(string.format(
    "[Dungeon Enemy Factory Registry Tests] PASS: %d assertions.",
    assertion_count
))
