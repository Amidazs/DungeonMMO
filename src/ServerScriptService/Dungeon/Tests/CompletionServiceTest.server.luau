--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Dungeon = ServerScriptService:WaitForChild("Dungeon")
local module = Dungeon:FindFirstChild("CompletionService")
if not module then error("[Completion Service Tests] RED: CompletionService is missing.") end
local CompletionService = require(module)

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then error("[Completion Service Tests] " .. message, 2) end
end

local session: any = {SessionId = "s1", State = "Complete", CompletionRecipients = {101, 102}, CompletionRewardsCommitted = false}
local fake_sessions: any = {}
function fake_sessions:get(_id: string) return session end
function fake_sessions:mark_completion_rewards_committed(_id: string, summary: any)
    session.CompletionRewardsCommitted = true
    session.CompletionRewardSummary = summary
    return {ok = true, session = session}
end
local reward_calls = {}
local fake_rewards: any = {}
function fake_rewards:grant_completion(session_id: string, slot: number, user_id: number, _definition: any)
    table.insert(reward_calls, user_id)
    return {ok = true, already_applied = false, transaction_id = session_id .. ":" .. tostring(slot), gold_granted = 50, item_id = if user_id == 101 then "marauder_sword" else nil}
end
local saves = {}
local fail_user: number? = nil
local book_calls = {}
local fake_skills: any = {}
function fake_skills:grant_arc_slash_first_clear(user_id: number, transaction_id: string)
    table.insert(book_calls, {user_id = user_id, transaction_id = transaction_id})
    return {ok = true, already_applied = false, item_id = "arc_slash_book_bound"}
end
local fake_profiles: any = {}
function fake_profiles:save(user_id: number, _reason: string)
    table.insert(saves, user_id)
    if fail_user == user_id then return false, "ForcedSaveFailure" end
    return true, nil
end

local guild_calls = 0
local fake_guilds: any = {}
function fake_guilds:award_dungeon_clear(user_ids: {number}, transaction_id: string): any
    guild_calls += 1
    assert(#user_ids == 2 and transaction_id == "s1:GuildClear")
    return {ok = true, awards = {}}
end

local service = CompletionService.new(
    fake_sessions,
    fake_rewards,
    fake_profiles,
    {Gold = 50, LootTable = {}},
    fake_skills,
    nil,
    fake_guilds
)
local result = service:commit("s1")
check(result.ok == true, "Completion commit must succeed for valid locked recipients.")
check(#reward_calls == 2 and reward_calls[1] == 101 and reward_calls[2] == 102, "Only snapshot recipients may receive completion rewards.")
check(#saves == 2, "Every rewarded profile must cross the save barrier before return opens.")
check(session.CompletionRewardsCommitted == true, "Session must record completion rewards committed only after saves succeed.")
check(result.member_results["101"].gold_granted == 50, "Completion result must expose per-member Gold.")
check(#book_calls == 0, "Completion must not issue a guaranteed Arc Slash book grant.")
check(guild_calls == 1, "Completion must invoke guild progression once.")

local before = #reward_calls
local repeated = service:commit("s1")
check(repeated.ok == true and repeated.already_applied == true, "Repeated commit must reuse committed session result.")
check(#reward_calls == before, "Repeated commit must not issue new reward grants.")
check(#book_calls == 0, "Repeated committed session must not issue guaranteed Arc Slash book grants.")
check(guild_calls == 1, "Repeated committed session must not replay guild progression.")

session = {SessionId = "s2", State = "Complete", CompletionRecipients = {101, 102}, CompletionRewardsCommitted = false}
reward_calls = {}
book_calls = {}
saves = {}
fail_user = 102
local failed = service:commit("s2")
check(failed.ok == false and failed.reason == "ProfileSaveFailed", "Save failure must block completion opening.")
check(session.CompletionRewardsCommitted ~= true, "Save failure must not mark rewards committed.")
check(guild_calls == 1, "Save failure must not award guild progression before the save barrier.")
print(string.format("[Completion Service Tests] PASS: %d assertions.", assertions))
