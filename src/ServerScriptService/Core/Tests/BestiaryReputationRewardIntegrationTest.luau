--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Core = ServerScriptService:WaitForChild("Core")
local Adapters = Core:WaitForChild("Adapters")
local Services = Core:WaitForChild("Services")

local InMemoryProfileAdapter = require(Adapters:WaitForChild("InMemoryProfileAdapter"))
local ProfileService = require(Services:WaitForChild("ProfileService"))
local ProgressionService = require(Services:WaitForChild("ProgressionService"))
local InventoryService = require(Services:WaitForChild("InventoryService"))
local RewardService = require(Services:WaitForChild("RewardService"))

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Bestiary Reputation Reward Integration Tests] " .. message, 2)
    end
end

local rng: any = {}
function rng:NextNumber(_minimum: number?, _maximum: number?): number
    return 0
end
function rng:NextInteger(minimum: number, _maximum: number): number
    return minimum
end

local adapter = InMemoryProfileAdapter.new()
local profiles = ProfileService.new(adapter)
local user_id = 9401
assert(profiles:load(user_id))

local rewards = RewardService.new(
    profiles,
    ProgressionService.new(profiles),
    InventoryService.new(profiles),
    nil,
    rng,
    function()
        return 7000
    end
)

local first = rewards:grant_monster_reward(
    {user_id},
    {
        XP = 10,
        GoldMin = 3,
        GoldMax = 3,
        BestiaryCreatureId = "marauder",
    },
    "Bestiary:session-a:marauder-1"
)
check(first.ok == true, "First tracked monster reward must succeed.")

local character = assert(profiles:get_character(user_id, 1))
check(character.XP == 10, "First tracked reward must grant XP.")
check(character.Gold == 3, "First tracked reward must grant Gold.")
check(character.Bestiary.Entries.marauder.Kills == 1, "First reward must record one Marauder kill.")
check(
    character.Bestiary.Entries.marauder.Milestones.first_defeat == true,
    "First reward must unlock first_defeat."
)
check(
    character.Reputation.Factions.Scholars.Points == 5,
    "First bestiary milestone must award Scholars reputation."
)

local first_member = assert(first.member_results[tostring(user_id)])
check(
    first_member.bestiary_creature_id == "marauder",
    "Member result must expose tracked creature ID."
)
check(
    first_member.bestiary_kill_count == 1,
    "Member result must expose bestiary kill count."
)
check(
    #first_member.reputation_awards == 1,
    "Member result must expose one reputation award."
)

local replay = rewards:grant_monster_reward(
    {user_id},
    {
        XP = 10,
        GoldMin = 3,
        GoldMax = 3,
        BestiaryCreatureId = "marauder",
    },
    "Bestiary:session-a:marauder-1"
)
check(replay.ok == true and replay.already_applied == true, "Runtime replay must be idempotent.")

character = assert(profiles:get_character(user_id, 1))
check(character.XP == 10, "Runtime replay must not duplicate XP.")
check(character.Gold == 3, "Runtime replay must not duplicate Gold.")
check(character.Bestiary.Entries.marauder.Kills == 1, "Runtime replay must not duplicate bestiary kills.")
check(character.Reputation.Factions.Scholars.Points == 5, "Runtime replay must not duplicate reputation.")

assert(profiles:save(user_id, "BestiaryReload"))
assert(profiles:release(user_id, "BestiaryReload"))
assert(profiles:load(user_id))

local reloaded_rewards = RewardService.new(
    profiles,
    ProgressionService.new(profiles),
    InventoryService.new(profiles),
    nil,
    rng,
    function()
        return 7001
    end
)

local persisted_replay = reloaded_rewards:grant_monster_reward(
    {user_id},
    {
        XP = 10,
        GoldMin = 3,
        GoldMax = 3,
        BestiaryCreatureId = "marauder",
    },
    "Bestiary:session-a:marauder-1"
)
check(
    persisted_replay.ok == true and persisted_replay.already_applied == true,
    "Persisted replay must be idempotent."
)

character = assert(profiles:get_character(user_id, 1))
check(character.Bestiary.Entries.marauder.Kills == 1, "Persisted replay must not duplicate kill count.")
check(character.Reputation.Factions.Scholars.Points == 5, "Persisted replay must not duplicate reputation.")

local ordinary = reloaded_rewards:grant_monster_reward(
    {user_id},
    {
        XP = 7,
        GoldMin = 2,
        GoldMax = 2,
    },
    "Bestiary:session-a:ordinary"
)
check(ordinary.ok == true, "Ordinary reward without bestiary ID must still succeed.")

character = assert(profiles:get_character(user_id, 1))
check(character.XP == 17, "Ordinary reward must still grant XP.")
check(character.Gold == 5, "Ordinary reward must still grant Gold.")
check(character.Bestiary.Entries.marauder.Kills == 1, "Ordinary reward must not alter bestiary.")
check(character.Reputation.Factions.Scholars.Points == 5, "Ordinary reward must not alter reputation.")

local unknown = reloaded_rewards:grant_monster_reward(
    {user_id},
    {
        XP = 1,
        GoldMin = 0,
        GoldMax = 0,
        BestiaryCreatureId = "undefined_creature",
    },
    "Bestiary:session-a:unknown"
)
check(unknown.ok == true, "Unknown bestiary creature must not block normal reward.")
character = assert(profiles:get_character(user_id, 1))
check(character.Bestiary.Entries.undefined_creature == nil, "Unknown creature must not create state.")

local invalid = reloaded_rewards:grant_monster_reward(
    {user_id},
    {
        XP = 1,
        GoldMin = 0,
        GoldMax = 0,
        BestiaryCreatureId = 123,
    },
    "Bestiary:session-a:invalid"
)
check(
    invalid.ok == false and invalid.reason == "InvalidMonsterReward",
    "Non-string bestiary creature ID must reject."
)

print(string.format(
    "[Bestiary Reputation Reward Integration Tests] PASS: %d assertions.",
    assertions
))