--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Core = ServerScriptService:WaitForChild("Core")
local Adapters = Core:WaitForChild("Adapters")
local Services = Core:WaitForChild("Services")

local InMemoryEntityAdapter = require(Adapters:WaitForChild("InMemoryEntityAdapter"))
local InMemoryProfileAdapter = require(Adapters:WaitForChild("InMemoryProfileAdapter"))
local ProfileService = require(Services:WaitForChild("ProfileService"))
local ProgressionService = require(Services:WaitForChild("ProgressionService"))
local InventoryService = require(Services:WaitForChild("InventoryService"))
local RewardService = require(Services:WaitForChild("RewardService"))
local GuildService = require(Services:WaitForChild("GuildService"))
local MarketService = require(Services:WaitForChild("MarketService"))
local RaceChangeService = require(Services:WaitForChild("RaceChangeService"))
local EconomyAuditService = require(Services:WaitForChild("EconomyAuditService"))

local assertions = 0
local function check(value: boolean, message: string)
    assertions += 1
    if not value then error("[Economy Audit Integration Tests] " .. message, 2) end
end

local profiles = ProfileService.new(InMemoryProfileAdapter.new())
for _, user_id in ipairs({9001, 9002, 9003}) do assert(profiles:load(user_id)) end
local inventory = InventoryService.new(profiles)
local progression = ProgressionService.new(profiles)
local audit = EconomyAuditService.new(nil, function() return 5000 end)
-- Reward path: completion + monster rewards audit once.
local rewards = RewardService.new(
    profiles, progression, inventory, nil, Random.new(123), function() return 5000 end
)
rewards:set_audit_service(audit)
local completion = rewards:grant_completion(
    "audit-session", 1, 9001,
    {Gold = 20, LootTable = {{Kind="Nothing", Weight=1}}},
    Random.new(1), nil
)
check(completion.ok == true and completion.already_applied == false,
    "Completion reward fixture must apply.")
check(rewards:grant_completion(
    "audit-session", 1, 9001,
    {Gold = 20, LootTable = {{Kind="Nothing", Weight=1}}},
    Random.new(1), nil
).already_applied == true, "Completion replay must dedupe.")

local monster = rewards:grant_monster_reward(
    {9001},
    {XP=1, GoldMin=5, GoldMax=5},
    "audit-session:monster-1"
)
check(monster.ok == true and monster.already_applied == false,
    "Monster reward fixture must apply.")
check(rewards:grant_monster_reward(
    {9001}, {XP=1, GoldMin=5, GoldMax=5}, "audit-session:monster-1"
).already_applied == true, "Monster replay must dedupe.")

local reward_count = audit:count()
check(reward_count == 2,
    "Completion and monster paths must emit exactly two audit events.")
-- Guild path: dungeon reward + leader upgrade spend audit once.
local guild_entities = InMemoryEntityAdapter.new()
local guilds = GuildService.new(
    guild_entities,
    function() return 5000 end,
    function() return "audit-guild" end
)
guilds:set_audit_service(audit)
check(guilds:create_guild(9001, 1, "Audit Guild", "guild-create").ok,
    "Guild audit fixture must create guild.")
check(guilds:create_invite(9001, 9002, "guild-invite").ok,
    "Guild audit fixture must invite second member.")
check(guilds:accept_invite(9002, "audit-guild", "guild-accept").ok,
    "Guild audit fixture must accept second member.")
local clear = guilds:award_dungeon_clear({9001, 9002}, "guild-clear")
check(clear.ok == true, "Guild dungeon clear must apply.")
check(guilds:award_dungeon_clear({9001, 9002}, "guild-clear").ok == true,
    "Guild clear replay must return success.")

guild_entities:update("guild:audit-guild", function(guild: any)
    guild.XP = 1000
    guild.Gold = 2500
    return guild
end)
local upgraded = guilds:upgrade_guild(9001, "guild-upgrade")
check(upgraded.ok == true and upgraded.guild.Level == 2,
    "Leader upgrade fixture must apply.")
check(guilds:upgrade_guild(9001, "guild-upgrade").ok == true,
    "Leader upgrade replay must be harmless.")
check(audit:count() == reward_count + 2,
    "Guild reward and upgrade must add exactly two audit events.")
-- Market path: escrow, buyer, seller and tax audit once.
assert(inventory:add_item(9001, "iron_bar", 1).ok)
assert(profiles:mutate(9003, function(profile: any)
    profile.Characters.Slot1.Gold = 500
end))
local market_entities = InMemoryEntityAdapter.new()
local market = MarketService.new(
    market_entities,
    profiles,
    function() return 6000 end,
    function() return "audit-listing" end
)
market:set_audit_service(audit)
local listed = market:create_listing(9001, "iron_bar", 1, 100, "market-create")
check(listed.ok == true, "Market audit fixture must create listing.")
local bought = market:buy(9003, "audit-listing", "market-buy")
check(bought.ok == true, "Market audit fixture purchase must complete.")
local market_count = audit:count()
check(market_count == reward_count + 6,
    "Market create/buyer/seller/tax must add exactly four audit events.")
check(market:buy(9003, "audit-listing", "market-buy").already_applied == true,
    "Market purchase replay must return stored result.")
check(audit:count() == market_count,
    "Market replay must not duplicate audit events.")

-- Race Change path: apply audit once.
assert(profiles:mutate(9002, function(profile: any)
    local c = profile.Characters.Slot1
    c.Identity = {
        Version=1, RaceId="Human", BaseClassId="Fighter",
        ClassId="Fighter", CreationStage="Complete",
    }
    c.Progression.Attributes = {Strength=5,Dexterity=4,Vitality=6,Intellect=5,Spirit=5}
end))
local race_change = RaceChangeService.new(profiles, "TEST", function() return 7000 end)
race_change:set_audit_service(audit)
local preview = race_change:preview(9002, "Elf")
check(preview.ok == true, "Race Change audit fixture preview must succeed.")
local changed = race_change:apply(9002, "Elf", preview.Hash, "race-audit")
check(changed.ok == true, "Race Change audit fixture apply must succeed.")
local race_count = audit:count()
check(race_count == market_count + 1,
    "Race Change apply must add exactly one audit event.")
local race_replay = race_change:apply(9002, "Elf", preview.Hash, "race-audit")
check(race_replay.ok == true and race_replay.already_applied == true,
    "Race Change replay must return stored receipt.")
check(audit:count() == race_count,
    "Race Change replay must not duplicate audit event.")

-- Audit failure is diagnostic only; gameplay mutation remains exactly-once.
local failing_audit = {}
function failing_audit:record(_event: any): any
    error("audit sink unavailable")
end
local failure_rewards = RewardService.new(
    profiles, progression, inventory, nil, Random.new(9), function() return 8000 end
)
failure_rewards:set_audit_service(failing_audit)
local before_gold = assert(profiles:get_character(9003, 1)).Gold
local failure_apply = failure_rewards:grant_completion(
    "audit-failure-session", 1, 9003,
    {Gold = 7, LootTable = {{Kind="Nothing", Weight=1}}},
    Random.new(2), nil
)
check(failure_apply.ok == true,
    "Audit failure must not convert successful gameplay mutation into failure.")
check(assert(profiles:get_character(9003, 1)).Gold == before_gold + 7,
    "Gameplay mutation must apply once despite audit failure.")
local failure_replay = failure_rewards:grant_completion(
    "audit-failure-session", 1, 9003,
    {Gold = 7, LootTable = {{Kind="Nothing", Weight=1}}},
    Random.new(2), nil
)
check(failure_replay.ok == true and failure_replay.already_applied == true,
    "Gameplay replay must remain idempotent despite audit failure.")
check(assert(profiles:get_character(9003, 1)).Gold == before_gold + 7,
    "Audit failure replay must not duplicate Gold.")

print(string.format("[Economy Audit Integration Tests] PASS: %d assertions.", assertions))
