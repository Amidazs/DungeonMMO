--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Dungeon = ServerScriptService:WaitForChild("Dungeon")
local module = Dungeon:FindFirstChild("DungeonBossSpawnGuard")

if not module then
    error(
        "[Boss Spawn Guard Tests] RED: DungeonBossSpawnGuard is missing.",
        2
    )
end

local DungeonBossSpawnGuard = require(module)
local assertions = 0

local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Boss Spawn Guard Tests] " .. message, 2)
    end
end

local root = Instance.new("Folder")

check(
    DungeonBossSpawnGuard.claim(
        root,
        "session-a",
        "Depth1Boss"
    ) == true,
    "first claim for one encounter must succeed."
)
check(
    DungeonBossSpawnGuard.claim(
        root,
        "session-a",
        "Depth1Boss"
    ) == false,
    "repeat claim for the same encounter must be rejected."
)
check(
    DungeonBossSpawnGuard.claim(
        root,
        "session-a",
        "SecretBoss"
    ) == true,
    "a different boss encounter in the same session must succeed."
)
check(
    DungeonBossSpawnGuard.claim(
        root,
        "session-a",
        "EventBoss"
    ) == true,
    "event boss must not be blocked by an earlier boss claim."
)
check(
    DungeonBossSpawnGuard.release(
        root,
        "session-a",
        "SecretBoss"
    ) == true,
    "failed execution must be able to release its encounter claim."
)
check(
    DungeonBossSpawnGuard.claim(
        root,
        "session-a",
        "SecretBoss"
    ) == true,
    "released boss encounter must be retryable."
)
check(
    DungeonBossSpawnGuard.release(
        root,
        "session-b",
        "SecretBoss"
    ) == false,
    "another session must not release the current session claim."
)
check(
    DungeonBossSpawnGuard.claim(
        root,
        "session-b",
        "Depth1Boss"
    ) == true,
    "new session may replace a stale encounter claim."
)
check(
    DungeonBossSpawnGuard.claim(
        root,
        "session-b"
    ) == true,
    "legacy two-argument claim must remain supported."
)
check(
    DungeonBossSpawnGuard.claim(
        root,
        "session-b"
    ) == false,
    "legacy claim must remain idempotent."
)

root:Destroy()

print(string.format(
    "[Boss Spawn Guard Tests] PASS: %d assertions.",
    assertions
))
