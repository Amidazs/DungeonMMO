--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local CompletionService = require(
    ServerScriptService
        :WaitForChild("Dungeon")
        :WaitForChild("CompletionService")
)

local assertions = 0

local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Completion Quest Bridge Tests] " .. message, 2)
    end
end

local session = {
    State = "Complete",
    DungeonId = "TestDungeon",
    CompletionRecipients = {5401},
    CompletionRewardsCommitted = false,
}

local sessions = {}

function sessions:get(session_id: string): any
    if session_id == "quest-bridge-session" then
        return session
    end
    return nil
end

function sessions:mark_completion_rewards_committed(
    _session_id: string,
    member_results: any
): any
    session.CompletionRewardsCommitted = true
    session.CompletionRewardSummary = member_results
    return {ok = true}
end

local rewards = {}

function rewards:grant_completion(...: any): any
    return {ok = true, gold_granted = 1}
end

local profiles = {
    saves = 0,
}

function profiles:save(_user_id: number, _reason: string): (boolean, string?)
    self.saves += 1
    return true, nil
end

local quest_events = {}

local quests = {}

function quests:record_event(user_id: number, event: any): any
    table.insert(quest_events, {
        UserId = user_id,
        Event = event,
    })
    return {ok = true}
end

local completion = CompletionService.new(
    sessions,
    rewards,
    profiles,
    {Gold = 1},
    nil,
    quests
)

local first = completion:commit("quest-bridge-session")
check(first.ok == true, "Completion with QuestService must succeed.")
check(#quest_events == 1, "Exactly one quest event must be emitted.")
check(
    quest_events[1].UserId == 5401,
    "Quest event must target the rewarded completion recipient."
)
check(
    quest_events[1].Event.EventId
        == "quest-bridge-session:DungeonClear",
    "Quest event must use a stable session-scoped EventId."
)
check(
    quest_events[1].Event.Type == "DungeonClear"
        and quest_events[1].Event.TargetId == "TestDungeon"
        and quest_events[1].Event.Amount == 1,
    "Quest event must describe the authoritative dungeon completion."
)
check(profiles.saves == 1, "Quest progress must use the existing completion save barrier.")

local second = completion:commit("quest-bridge-session")
check(
    second.ok == true and second.already_applied == true,
    "Committed completion retry must remain idempotent."
)
check(
    #quest_events == 1,
    "Already-committed completion must not emit another quest event."
)

print(string.format(
    "[Completion Quest Bridge Tests] PASS: %d assertions.",
    assertions
))
