--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Core = ServerScriptService:WaitForChild("Core")
local Adapters = Core:WaitForChild("Adapters")
local Services = Core:WaitForChild("Services")
local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")

local InMemoryProfileAdapter = require(Adapters:WaitForChild("InMemoryProfileAdapter"))
local InMemoryEntityAdapter = require(Adapters:WaitForChild("InMemoryEntityAdapter"))
local InMemoryMapAdapter = require(Adapters:WaitForChild("InMemoryMapAdapter"))
local ProfileService = require(Services:WaitForChild("ProfileService"))
local ProfileMigration = require(Services:WaitForChild("ProfileMigration"))
local InventoryService = require(Services:WaitForChild("InventoryService"))
local ProgressionService = require(Services:WaitForChild("ProgressionService"))
local RewardService = require(Services:WaitForChild("RewardService"))
local MarketService = require(Services:WaitForChild("MarketService"))
local GuildService = require(Services:WaitForChild("GuildService"))
local DungeonSessionService = require(Services:WaitForChild("DungeonSessionService"))
local RaceChangeService = require(Services:WaitForChild("RaceChangeService"))
local ProfileSchema = require(Shared:WaitForChild("ProfileSchema"))
local DungeonDefinitions = require(Shared:WaitForChild("DungeonDefinitions"))

local function check(value: boolean, message: string)
    if not value then error("[Phase 3 Systems Stress] " .. message, 2) end
end
-- 250 real load/mutate/save/release/reload profile cycles.
local profile_adapter = InMemoryProfileAdapter.new()
local profile_service = ProfileService.new(profile_adapter)
for index = 1, 250 do
    local user_id = 10000 + index
    check(profile_service:load(user_id) ~= nil, "Profile load failed at cycle " .. index)
    check(profile_service:mutate(user_id, function(profile: any)
        profile.Characters.Slot1.Gold = index
    end), "Profile mutation failed at cycle " .. index)
    check(profile_service:save(user_id, "StressSave") == true,
        "Profile save failed at cycle " .. index)
    check(profile_service:release(user_id, "StressRelease") == true,
        "Profile release failed at cycle " .. index)
    check(profile_service:load(user_id) ~= nil,
        "Profile reload failed at cycle " .. index)
    local reloaded = assert(profile_service:get_profile(user_id))
    check(
        reloaded.SchemaVersion == ProfileSchema.VERSION
            and reloaded.Characters.Slot1.Gold == index,
        "Reloaded profile invariant failed at cycle " .. index
    )
    local migrated = ProfileMigration.migrate(reloaded)
    check(
        migrated.SchemaVersion == ProfileSchema.VERSION,
        "Reloaded profile must remain on the current schema at cycle "
            .. index
    )
    check(profile_service:release(user_id, "StressFinalRelease") == true,
        "Final release failed at cycle " .. index)
end
-- 1,000 market operations = 500 create + 500 cancel operations.
local market_profiles = ProfileService.new(InMemoryProfileAdapter.new())
local market_seller = 20001
check(market_profiles:load(market_seller) ~= nil, "Market seller profile load failed.")
local market_inventory = InventoryService.new(market_profiles)
check(market_inventory:add_item(market_seller, "iron_bar", 500).ok,
    "Market stress inventory seed failed.")
local market_entities = InMemoryEntityAdapter.new()
local listing_counter = 0
local market_now = 100000
local market = MarketService.new(
    market_entities,
    market_profiles,
    function() return market_now end,
    function()
        listing_counter += 1
        return "stress-listing-" .. tostring(listing_counter)
    end
)
local last_listing_id = ""
local last_cancel_tx = ""
for index = 1, 500 do
    local create_tx = "stress-create-" .. tostring(index)
    local created = market:create_listing(
        market_seller, "iron_bar", 1, 10 + (index % 100), create_tx
    )
    check(created.ok == true, "Market create failed at pair " .. index)
    local listing_id = assert(created.listing.ListingId)
    local cancel_tx = "stress-cancel-" .. tostring(index)
    local cancelled = market:cancel(market_seller, listing_id, cancel_tx)
    check(cancelled.ok == true, "Market cancel failed at pair " .. index)
    last_listing_id = listing_id
    last_cancel_tx = cancel_tx
    market_now += 1
end
local seller_after_market = assert(market_profiles:get_character(market_seller, 1))
check(InventoryService.count_item(seller_after_market, "iron_bar") == 500,
    "Market create/cancel workload must conserve exact item count.")
check(seller_after_market.Gold == 0,
    "Market create/cancel workload must not alter seller Gold.")
check(#(seller_after_market.Market.ActiveListingIds or {}) == 0,
    "Market create/cancel workload must leave zero active listings.")
-- 1,000 duplicate replay attempts: 500 market + 500 reward replays.
for index = 1, 500 do
    local replay = market:cancel(market_seller, last_listing_id, last_cancel_tx)
    check(replay.ok == true and replay.already_applied == true,
        "Market replay failed at attempt " .. index)
end
check(InventoryService.count_item(assert(market_profiles:get_character(market_seller, 1)), "iron_bar") == 500,
    "Market replay workload must not duplicate returned items.")

local reward_user = 20002
check(market_profiles:load(reward_user) ~= nil, "Reward replay profile load failed.")
local reward_progression = ProgressionService.new(market_profiles)
local reward_inventory = InventoryService.new(market_profiles)
local stress_rewards = RewardService.new(
    market_profiles,
    reward_progression,
    reward_inventory,
    nil,
    Random.new(77),
    function() return 200000 end
)
local initial_reward = stress_rewards:grant_completion(
    "stress-reward-session",
    1,
    reward_user,
    {Gold = 11, LootTable = {{Kind="Nothing", Weight=1}}},
    Random.new(5),
    nil
)
check(initial_reward.ok == true and initial_reward.already_applied == false,
    "Initial reward replay fixture must apply once.")
for index = 1, 500 do
    local replay = stress_rewards:grant_completion(
        "stress-reward-session",
        1,
        reward_user,
        {Gold = 11, LootTable = {{Kind="Nothing", Weight=1}}},
        Random.new(5),
        nil
    )
    check(replay.ok == true and replay.already_applied == true,
        "Reward replay failed at attempt " .. index)
end
check(assert(market_profiles:get_character(reward_user, 1)).Gold == 11,
    "Reward replay workload must grant Gold exactly once.")
-- 250 guild operations = 50 fixtures x create/invite/accept/role/progression.
local guild_entities = InMemoryEntityAdapter.new()
local guild_counter = 0
local guilds = GuildService.new(
    guild_entities,
    function() return 300000 end,
    function()
        guild_counter += 1
        return "stress-guild-" .. tostring(guild_counter)
    end
)
local guild_operations = 0
for index = 1, 50 do
    local leader = 30000 + index * 2
    local member = leader + 1
    local created = guilds:create_guild(
        leader, 1, "Stress Guild " .. tostring(index), "g-create-" .. tostring(index)
    )
    guild_operations += 1
    check(created.ok == true, "Guild create failed at fixture " .. index)
    local guild_id = assert(created.guild.GuildId)
    check(guilds:create_invite(leader, member, "g-invite-" .. tostring(index)).ok,
        "Guild invite failed at fixture " .. index)
    guild_operations += 1
    check(guilds:accept_invite(member, guild_id, "g-accept-" .. tostring(index)).ok,
        "Guild accept failed at fixture " .. index)
    guild_operations += 1
    check(guilds:set_role(leader, member, "Officer", "g-role-" .. tostring(index)).ok,
        "Guild role operation failed at fixture " .. index)
    guild_operations += 1
    check(guilds:award_dungeon_clear({leader, member}, "g-clear-" .. tostring(index)).ok,
        "Guild progression operation failed at fixture " .. index)
    guild_operations += 1

    local guild = assert(guilds:get_guild(guild_id))
    local leaders = 0
    for _, row in pairs(guild.Members) do
        if row.Role == "Leader" then leaders += 1 end
    end
    check(leaders == 1 and guild.XP >= 0 and guild.Gold >= 0 and guild.Level == 1,
        "Guild invariant failed at fixture " .. index)
    check(guilds:get_membership(leader, 1) ~= nil and guilds:get_membership(member, 1) ~= nil,
        "Guild membership pointer invariant failed at fixture " .. index)
end
check(guild_operations == 250, "Guild workload operation count must equal 250.")
-- 100 deterministic session/reconnect contract cycles.
for index = 1, 100 do
    local session_now = 400000 + index
    local map = InMemoryMapAdapter.new(function() return session_now end)
    local sessions = DungeonSessionService.new(map, function() return session_now end)
    local user_id = 40000 + index
    local created, create_error = sessions:create(
        DungeonDefinitions.TEST_DUNGEON.Id,
        {user_id},
        0,
        "stress-code-" .. tostring(index)
    )
    check(created ~= nil, "Session create failed at cycle " .. index .. ": " .. tostring(create_error))
    local modifier_id = assert(created).Modifier.Id
    local rotation_key = created.Modifier.RotationKey
    local loaded = assert(sessions:get(created.SessionId))
    check(loaded.Modifier.Id == modifier_id and loaded.Modifier.RotationKey == rotation_key,
        "Session modifier changed on initial reload at cycle " .. index)
    local connected = sessions:mark_connected(created.SessionId, user_id)
    check(connected.ok == true, "Session connect failed at cycle " .. index)
    local reloaded = assert(sessions:get(created.SessionId))
    check(reloaded.Modifier.Id == modifier_id and reloaded.Modifier.RotationKey == rotation_key,
        "Session modifier changed after reconnect mutation at cycle " .. index)
    local failed = sessions:mark_failed(created.SessionId, "StressComplete")
    check(failed.ok == true and failed.session.State == "Failed",
        "Session terminal transition failed at cycle " .. index)
end

-- 100 full Human -> Elf -> Human Race Change round trips.
local race_profiles = ProfileService.new(InMemoryProfileAdapter.new())
local race_user = 50001
check(race_profiles:load(race_user) ~= nil, "Race stress profile load failed.")
check(race_profiles:mutate(race_user, function(profile: any)
    local c = profile.Characters.Slot1
    c.Identity = {
        Version=1, RaceId="Human", BaseClassId="Fighter",
        ClassId="Fighter", CreationStage="Complete",
    }
    c.Progression.Attributes = {Strength=5,Dexterity=4,Vitality=6,Intellect=5,Spirit=5}
    c.Progression.SkillPointEntitlement = 10
end), "Race stress fixture mutation failed.")
local race_inventory = InventoryService.new(race_profiles)
check(race_inventory:add_item(race_user, "arc_slash_book", 1).ok,
    "Race stress book seed failed.")
local race_service = RaceChangeService.new(race_profiles, "TEST", function() return 500000 end)
local entitlement_before = assert(race_profiles:get_character(race_user, 1)).Progression.SkillPointEntitlement
local books_before = InventoryService.count_item(assert(race_profiles:get_character(race_user, 1)), "arc_slash_book")
for index = 1, 100 do
    local to_elf = race_service:preview(race_user, "Elf")
    check(to_elf.ok == true, "Elf preview failed at round trip " .. index)
    local elf_result = race_service:apply(
        race_user, "Elf", to_elf.Hash, "stress-race-elf-" .. tostring(index)
    )
    check(elf_result.ok == true, "Elf apply failed at round trip " .. index)

    local to_human = race_service:preview(race_user, "Human")
    check(to_human.ok == true, "Human preview failed at round trip " .. index)
    local human_result = race_service:apply(
        race_user, "Human", to_human.Hash, "stress-race-human-" .. tostring(index)
    )
    check(human_result.ok == true, "Human apply failed at round trip " .. index)
end

local race_final = assert(race_profiles:get_character(race_user, 1))
check(race_final.Identity.RaceId == "Human",
    "Race round trips must finish on Human.")
check(race_final.Progression.SkillPointEntitlement == entitlement_before,
    "Race round trips must never increase lifetime SP entitlement.")
check(InventoryService.count_item(race_final, "arc_slash_book") == books_before,
    "Race round trips must never manufacture or refund Skill Books.")
check(type(race_final.RaceChange.ArchivedByRace.Human) == "table"
        and type(race_final.RaceChange.ArchivedByRace.Elf) == "table",
    "Race round trips must retain stable per-race archives.")
check(
    ProfileMigration.migrate(
        race_profiles:get_profile(race_user)
    ).SchemaVersion == ProfileSchema.VERSION,
    "Final Race Change profile must remain on the current schema."
)

print("[Phase 3 Systems Stress] PASS: profiles=250 market=1000 replay=1000 guild=250 sessions=100 race_roundtrips=100")
