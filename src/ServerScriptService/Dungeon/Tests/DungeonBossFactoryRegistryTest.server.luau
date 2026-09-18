--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Dungeon = ServerScriptService:WaitForChild("Dungeon")
local module = Dungeon:FindFirstChild(
    "DungeonBossFactoryRegistry"
)
if not module then
    error(
        "[Dungeon Boss Factory Registry Tests] RED: "
            .. "DungeonBossFactoryRegistry is missing."
    )
end

local Registry = require(module)
local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error(
            "[Dungeon Boss Factory Registry Tests] "
                .. message,
            2
        )
    end
end

local registry = Registry.new()
local factory_a = {
    create = function(_options: any): Model
        return Instance.new("Model")
    end,
}
local factory_b = {
    create = function(_options: any): Model
        return Instance.new("Model")
    end,
}

check(
    registry:register("BossA", factory_a).ok == true,
    "BossA factory must register."
)
check(
    registry:register("BossA", factory_a).reason
        == "BossFactoryAlreadyRegistered",
    "Duplicate boss factory registration must fail."
)
check(
    registry:register("", factory_a).reason
        == "InvalidBossFactory",
    "Blank boss IDs must fail."
)
check(
    registry:register("BossB", {}).reason
        == "InvalidBossFactory",
    "Factory without create must fail."
)
check(
    registry:get("BossA") == factory_a,
    "Registered BossA factory must resolve."
)
check(
    registry:get("Missing") == nil,
    "Unknown boss factory must fail closed."
)
check(
    registry:register("BossB", factory_b).ok == true,
    "Independent boss IDs must register."
)
check(
    registry:get("BossB") == factory_b,
    "BossB factory must resolve independently."
)

print(string.format(
    "[Dungeon Boss Factory Registry Tests] PASS: %d assertions.",
    assertion_count
))
