--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Dungeon = ServerScriptService:WaitForChild("Dungeon")
local module = Dungeon:FindFirstChild("EncounterService")
if not module then
    error("[Encounter Service Tests] RED: EncounterService is missing.")
end
local EncounterService = require(module)
local MarauderCaptainFactory = require(Dungeon:WaitForChild("MarauderCaptainFactory"))

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Encounter Service Tests] " .. message, 2)
    end
end

local reward_calls = {}
local fake_rewards: any = {}
function fake_rewards:grant_monster_reward(member_user_ids: {number}, reward: any, transaction_id: string): any
    table.insert(reward_calls, {
        members = table.clone(member_user_ids),
        reward = reward,
        transaction_id = transaction_id,
    })
    return {ok = true, member_results = {}}
end

local enemy_a = Instance.new("Model")
enemy_a.Name = "Room1MarauderA"
enemy_a:SetAttribute("DungeonEnemyId", "R1A")
enemy_a:SetAttribute("DungeonLifeIndex", 1)
enemy_a:SetAttribute("DungeonRewardXP", 10)
enemy_a:SetAttribute("DungeonRewardGoldMin", 3)
enemy_a:SetAttribute("DungeonRewardGoldMax", 6)
local enemy_b = enemy_a:Clone()
enemy_b.Name = "Room1MarauderB"
enemy_b:SetAttribute("DungeonEnemyId", "R1B")

local encounters = EncounterService.new(fake_rewards, "session-encounter")
local started = encounters:start("CombatRoom1", {101, 102}, {enemy_a, enemy_b})
check(started.ok == true, "Encounter must start with members and enemies.")
check(encounters:is_clear("CombatRoom1") == false, "Encounter cannot start clear while enemies remain.")
check(#encounters:get_eligible_members("CombatRoom1") == 2, "Both active connected participants must be eligible initially.")

encounters:mark_member_mode(102, "Spectating")
local eligible = encounters:get_eligible_members("CombatRoom1")
check(#eligible == 1 and eligible[1] == 101, "Spectating member must be removed from monster rewards.")
encounters:mark_member_connected(101, false)
check(#encounters:get_eligible_members("CombatRoom1") == 0, "Disconnected member must be removed from monster rewards.")
encounters:mark_member_connected(101, true)

local first = encounters:on_enemy_died(enemy_a)
check(first.ok == true and first.cleared == false, "First enemy death must not clear a two-enemy encounter.")
check(#reward_calls == 1 and #reward_calls[1].members == 1 and reward_calls[1].members[1] == 101, "Only active participant must receive monster reward.")
check(reward_calls[1].transaction_id == "session-encounter:R1A:Life1", "Enemy transaction ID must be session/enemy/life scoped.")

local duplicate = encounters:on_enemy_died(enemy_a)
check(duplicate.already_processed == true, "Same enemy life must be processed only once.")
check(#reward_calls == 1, "Duplicate death must not call RewardService again.")

-- A party wipe only discards current enemy handles. Previously paid
-- monster lives retain identical transaction IDs when the room restarts.
local cancelled = encounters:cancel_active("CombatRoom1")
check(cancelled.ok == true,
    "Wipe must retire an uncleared encounter without completing it.")
check(encounters:get_current_id() == nil,
    "The old encounter must stop owning combat after wipe.")
check(not encounters:cancel_active("CombatRoom1").ok,
    "Repeated wipe callbacks must not cancel an already retired fight.")
local enemy_a_retry = enemy_a:Clone()
local enemy_b_retry = enemy_b:Clone()
check(encounters:start("CombatRoom1", {101}, {
    enemy_a_retry, enemy_b_retry,
}).ok, "Wiped encounter must be startable again with fresh models.")
check(encounters:on_enemy_died(enemy_a_retry).ok,
    "A previously rewarded enemy must be valid in the retry.")
check(reward_calls[2].transaction_id == reward_calls[1].transaction_id,
    "Retry must use the original monster reward transaction ID.")

local second = encounters:on_enemy_died(enemy_b_retry)
check(second.ok == true and second.cleared == true, "Final registered enemy death must clear encounter.")
check(encounters:is_clear("CombatRoom1") == true, "Encounter must report clear after all registered enemies die.")

local boss = MarauderCaptainFactory.create({
    Parent = workspace,
    SpawnCFrame = CFrame.new(0, 1000, 0),
    EncounterId = "MarauderCaptain",
    RewardXP = 40,
    RewardGoldMin = 15,
    RewardGoldMax = 25,
    BestiaryCreatureId = "marauder_captain",
})
local boss_encounters = EncounterService.new(fake_rewards, "session-boss")
check(boss_encounters:start("MarauderCaptain", {101}, {boss}).ok == true, "Boss encounter must start.")
local boss_result = boss_encounters:on_enemy_died(boss)
check(boss_result.ok == true and boss_result.cleared == true, "Captain death must clear its encounter.")
local boss_reward = reward_calls[#reward_calls].reward
check(boss_reward.XP == 40 and boss_reward.GoldMin == 15 and boss_reward.GoldMax == 25, "Captain reward values must reach RewardService.")
check(boss_reward.BestiaryCreatureId == "marauder_captain", "Captain bestiary identity must reach RewardService.")
boss:Destroy()

print(string.format("[Encounter Service Tests] PASS: %d assertions.", assertions))
