--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Core = ServerScriptService:WaitForChild("Core")
local Adapters = Core:WaitForChild("Adapters")
local Services = Core:WaitForChild("Services")
local Dungeon = ServerScriptService:WaitForChild("Dungeon")

local InMemoryProfileAdapter = require(
    Adapters:WaitForChild("InMemoryProfileAdapter")
)
local ProfileService = require(
    Services:WaitForChild("ProfileService")
)
local DungeonDifficultyProgressionService = require(
    Services:WaitForChild("DungeonDifficultyProgressionService")
)
local CompletionService = require(
    Dungeon:WaitForChild("CompletionService")
)

local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error(
            "[Dungeon Difficulty Completion Unlock Tests] "
                .. message,
            2
        )
    end
end
local adapter = InMemoryProfileAdapter.new()
local profiles = ProfileService.new(adapter)
local user_id = 8101
assert(profiles:load(user_id))

local progression =
    DungeonDifficultyProgressionService.new(profiles)

local session: any = {
    SessionId = "depth1-completion",
    DungeonId = "TestDungeon",
    Difficulty = {
        Id = "Depth1",
        Order = 1,
        Version = 1,
    },
    State = "Complete",
    CompletionRecipients = {user_id},
    CompletionRewardsCommitted = false,
}

local sessions: any = {}
function sessions:get(_session_id: string): any
    return session
end
function sessions:mark_completion_rewards_committed(
    _session_id: string,
    summary: any
): any
    session.CompletionRewardsCommitted = true
    session.CompletionRewardSummary = summary
    return {
        ok = true,
        session = session,
    }
end
local rewards: any = {}
function rewards:grant_completion(
    _session_id: string,
    _slot: number,
    _user_id: number,
    _definition: any
): any
    return {
        ok = true,
        already_applied = false,
        gold_granted = 50,
    }
end

local completion = CompletionService.new(
    sessions,
    rewards,
    profiles,
    {
        Gold = 50,
        LootTable = {},
    },
    nil,
    nil,
    nil,
    progression
)

check(
    progression:is_unlocked(
        user_id,
        "TestDungeon",
        "Depth2"
    ) == false,
    "Depth2 must begin locked."
)

local committed = completion:commit(session.SessionId)
check(
    committed.ok == true,
    "Depth1 completion commit must succeed."
)
check(
    progression:is_unlocked(
        user_id,
        "TestDungeon",
        "Depth2"
    ) == true,
    "Depth1 completion must unlock Depth2."
)
check(
    committed.member_results[tostring(user_id)]
        .difficulty_progress.completed_difficulty_id
        == "Depth1",
    "Completion result must expose the recorded clear."
)
check(
    committed.member_results[tostring(user_id)]
        .difficulty_progress.unlocked_next_id
        == "Depth2",
    "Completion result must expose the next unlocked depth."
)
check(
    session.CompletionRewardsCommitted == true,
    "Completion marker must only be written after unlock save."
)

assert(profiles:release(user_id, "DifficultyPersistenceTest"))
assert(profiles:load(user_id))

local reloaded_progression =
    DungeonDifficultyProgressionService.new(profiles)
check(
    reloaded_progression:is_unlocked(
        user_id,
        "TestDungeon",
        "Depth2"
    ) == true,
    "Depth unlock must survive profile release and reload."
)

local before = reloaded_progression:get_snapshot(user_id)
local repeated = completion:commit(session.SessionId)
check(
    repeated.ok == true
        and repeated.already_applied == true,
    "Committed completion retry must remain idempotent."
)
local after = reloaded_progression:get_snapshot(user_id)
check(
    before.progress.Dungeons.TestDungeon.HighestClearedOrder
        == after.progress.Dungeons.TestDungeon.HighestClearedOrder,
    "Committed retry must not advance difficulty progression again."
)

print(string.format(
    "[Dungeon Difficulty Completion Unlock Tests] PASS: %d assertions.",
    assertion_count
))
