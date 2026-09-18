--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Dungeon = ServerScriptService:WaitForChild("Dungeon")
local MarauderFactory = require(
    Dungeon:WaitForChild("DungeonMarauderFactory")
)
local CaptainFactory = require(
    Dungeon:WaitForChild("MarauderCaptainFactory")
)

local assertion_count = 0
local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error(
            "[Dungeon Enemy Difficulty Scaling Tests] " .. message,
            2
        )
    end
end

local holder = Instance.new("Folder")

local marauder = MarauderFactory.create({
    Parent = holder,
    Name = "ScaledMarauder",
    SpawnCFrame = CFrame.new(),
    BaseMaxHealth = 40,
    HealthMultiplier = 1.5,
    DamageMultiplier = 1.2,
})
local marauder_humanoid =
    assert(marauder:FindFirstChildOfClass("Humanoid"))
check(
    marauder_humanoid.MaxHealth == 60,
    "Ordinary enemy health multiplier must apply once."
)
check(
    marauder:GetAttribute("DungeonDamageMultiplier") == 1.2,
    "Ordinary enemy must carry server-set damage multiplier."
)

local captain = CaptainFactory.create({
    Parent = holder,
    SpawnCFrame = CFrame.new(),
    HealthMultiplier = 1.5,
    DamageMultiplier = 1.2,
    BossRole = "MiniBoss",
})
local captain_humanoid =
    assert(captain:FindFirstChildOfClass("Humanoid"))
check(
    captain_humanoid.MaxHealth == 180,
    "Boss health multiplier must apply once."
)
check(
    captain:GetAttribute("DungeonDamageMultiplier") == 1.2,
    "Boss must carry server-set damage multiplier."
)
check(
    captain:GetAttribute("DungeonBossRole") == "MiniBoss",
    "Boss role context must be stored without duplicating boss class."
)

holder:Destroy()

print(string.format(
    "[Dungeon Enemy Difficulty Scaling Tests] PASS: %d assertions.",
    assertion_count
))
