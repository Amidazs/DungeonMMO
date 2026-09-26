--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")
local Core = ServerScriptService:WaitForChild("Core")
local Adapters = Core:WaitForChild("Adapters")
local Services = Core:WaitForChild("Services")

local module = Services:FindFirstChild(
    "DungeonDifficultyProgressionService"
)
if not module then
    error(
        "[Dungeon Difficulty Progression Tests] RED: "
            .. "DungeonDifficultyProgressionService is missing."
    )
end

local InMemoryProfileAdapter = require(
    Adapters:WaitForChild("InMemoryProfileAdapter")
)
local ProfileService = require(Services:WaitForChild("ProfileService"))
local ProgressionService = require(module)

local assertion_count = 0
-- Verifies one progression-service expectation.
local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error(
            "[Dungeon Difficulty Progression Tests] " .. message,
            2
        )
    end
end

local adapter = InMemoryProfileAdapter.new()
local profiles = ProfileService.new(adapter)
assert(profiles:load(9501))

local service = ProgressionService.new(profiles)

check(
    service:is_unlocked(9501, "TestDungeon", "Depth1") == true,
    "Depth1 must be unlocked by default."
)
check(
    service:is_unlocked(9501, "TestDungeon", "Depth2") == false,
    "Depth2 must start locked."
)

local depth1_entry = service:validate_entry(
    9501,
    "TestDungeon",
    "Depth1"
)
check(depth1_entry.ok == true, "Depth1 entry must validate.")

local readiness_calls = 0
local blocked_readiness: any = {}
function blocked_readiness.analyze(
    _dungeon_id: string,
    _difficulty_id: string
): any
    readiness_calls += 1
    return {
        ok = true,
        Ready = false,
    }
end

local blocked_service = ProgressionService.new(
    profiles,
    blocked_readiness
)
local blocked_entry = blocked_service:validate_entry(
    9501,
    "TestDungeon",
    "Depth1"
)
check(
    blocked_entry.reason == "DifficultyContentNotReady",
    "Entry must obey computed runtime-content readiness."
)
check(
    readiness_calls == 1,
    "Entry must consult runtime-content readiness exactly once."
)

local first_clear = service:record_clear(
    9501,
    "TestDungeon",
    "Depth1"
)
check(first_clear.ok == true, "Depth1 clear must record.")
check(
    first_clear.already_completed == false,
    "First Depth1 clear must be new."
)
check(
    first_clear.unlocked_next_id == "Depth2",
    "Depth1 clear must unlock Depth2."
)
check(
    service:is_unlocked(9501, "TestDungeon", "Depth2") == true,
    "Depth2 must be logically unlocked after Depth1."
)

local depth2_entry = service:validate_entry(
    9501,
    "TestDungeon",
    "Depth2"
)
check(
    depth2_entry.reason == "DifficultyContentNotReady",
    "Unlocked but unbuilt Depth2 must fail closed."
)
local repeated = service:record_clear(
    9501,
    "TestDungeon",
    "Depth1"
)
check(repeated.ok == true, "Repeated Depth1 clear must be safe.")
check(
    repeated.already_completed == true,
    "Repeated Depth1 clear must be idempotent."
)

local skipped = service:record_clear(
    9501,
    "TestDungeon",
    "Depth3"
)
check(
    skipped.reason == "PreviousDifficultyNotCleared",
    "Depth3 clear must not skip Depth2."
)

local second_clear = service:record_clear(
    9501,
    "TestDungeon",
    "Depth2"
)
check(second_clear.ok == true, "Unlocked Depth2 clear must record.")
check(
    second_clear.unlocked_next_id == "Depth3",
    "Depth2 clear must unlock Depth3."
)
check(
    service:is_unlocked(9501, "TestDungeon", "Depth3") == true,
    "Depth3 must unlock after Depth2 clear."
)

local unknown = service:record_clear(
    9501,
    "TestDungeon",
    "UnknownDepth"
)
check(
    unknown.reason == "UnknownDifficulty",
    "Unknown difficulty clears must be rejected."
)

local snapshot = service:get_snapshot(9501)
check(snapshot.ok == true, "Difficulty progress snapshot must succeed.")
snapshot.progress.Dungeons.TestDungeon.Completed.Depth4 = true

local fresh = service:get_snapshot(9501)
check(
    fresh.progress.Dungeons.TestDungeon.Completed.Depth4 ~= true,
    "Returned difficulty progress must be a deep clone."
)

print(string.format(
    "[Dungeon Difficulty Progression Tests] PASS: %d assertions.",
    assertion_count
))
