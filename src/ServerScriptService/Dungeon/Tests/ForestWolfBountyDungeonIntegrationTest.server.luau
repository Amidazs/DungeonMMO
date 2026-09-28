--!strict
-- Real EncounterService -> QuestService Forest Wolf bounty integration.

local ServerScriptService = game:GetService("ServerScriptService")

local Core = ServerScriptService.Core
local Dungeon = ServerScriptService.Dungeon

local Adapter = require(Core.Adapters.InMemoryProfileAdapter)
local Profiles = require(Core.Services.ProfileService)
local Quests = require(Core.Services.QuestService)
local EncounterService = require(Dungeon.EncounterService)

local USER_ID = 968201
local checks = 0

--[[
Counts one bounty bridge assertion.

Args:
    condition (boolean): Expected server-owned integration result.
    label (string): Diagnostic failure context.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(
        condition,
        "[Forest Wolf Bounty Dungeon Integration] " .. label
    )
end

--[[
Creates one species-only Forest Wolf encounter model.

Args:
    enemy_id (string): Stable encounter enemy identifier.

Returns:
    Model: Disposable server-authored quest enemy.
]]
local function create_wolf(enemy_id: string): Model
    local wolf = Instance.new("Model")
    wolf.Name = enemy_id
    wolf:SetAttribute("DungeonEnemyId", enemy_id)
    wolf:SetAttribute("DungeonLifeIndex", 1)
    wolf:SetAttribute("DungeonRewardXP", 12)
    wolf:SetAttribute("DungeonRewardGoldMin", 4)
    wolf:SetAttribute("DungeonRewardGoldMax", 7)
    wolf:SetAttribute("CreatureSpeciesId", "forest_wolf")
    wolf:SetAttribute("BestiaryCreatureId", nil)
    return wolf
end

--[[
Installs one launch-valid Dark Elf with the bounty prerequisite completed.

Args:
    profiles (any): Loaded authoritative profile service.

Returns:
    nil: Mutates only the disposable in-memory character.
]]
local function install_character(profiles: any)
    check(
        profiles:mutate(USER_ID, function(profile: any)
            local character = profile.Characters.Slot1
            character.Level = 1
            character.Identity = {
                Version = 1,
                RaceId = "DarkElf",
                BaseClassId = "Fighter",
                ClassId = "Fighter",
                CreationStage = "Complete",
            }
            character.Quests.Completed.WorldrootRelic = true
        end),
        "launch-valid Dark Elf prerequisite state persists"
    )
end

--[[
Runs the real encounter-to-quest bounty flow.

Args:
    None.

Returns:
    nil: Prints a stable marker after reward and replay checks pass.
]]
local function main()
    local profiles = Profiles.new(Adapter.new())
    check(profiles:load(USER_ID), "profile loads")
    install_character(profiles)

    local quests = Quests.new(profiles)
    check(
        quests:start(USER_ID, "ForestWolfBounty").ok,
        "eligible player starts Forest Wolf bounty"
    )

    local reward_calls = 0
    local rewards = {}

    function rewards:grant_monster_reward(
        member_user_ids: {number},
        _reward: any,
        _transaction_id: string
    ): any
        reward_calls += 1
        check(
            #member_user_ids == 1
                and member_user_ids[1] == USER_ID,
            "encounter reward and quest credit share the active member"
        )
        return {ok = true, member_results = {}}
    end

    local first = create_wolf("BountyWolf1")
    local second = create_wolf("BountyWolf2")
    local encounters = EncounterService.new(
        rewards,
        "wolf-bounty-integration",
        nil,
        quests
    )

    check(
        encounters:start(
            "ForestWolfBountyPack",
            {USER_ID},
            {first, second}
        ).ok,
        "two-wolf encounter starts"
    )

    local first_death = encounters:on_enemy_died(first)
    check(
        first_death.ok == true
            and first_death.cleared == false,
        "first rewarded wolf progresses but does not clear pack"
    )
    check(
        quests:claim_reward(
            USER_ID,
            "ForestWolfBounty"
        ).reason == "QuestNotReady",
        "one real encounter wolf cannot complete two-kill bounty"
    )

    local second_death = encounters:on_enemy_died(second)
    check(
        second_death.ok == true
            and second_death.cleared == true,
        "second rewarded wolf clears pack and progresses quest"
    )

    local claim = quests:claim_reward(
        USER_ID,
        "ForestWolfBounty"
    )
    check(
        claim.ok == true
            and claim.gold_granted == 40
            and #claim.items_granted == 0,
        "real encounter deaths unlock exact Gold-only bounty reward"
    )
    check(
        profiles:get_character(USER_ID, 1).Gold == 40,
        "bounty Gold commits to authoritative character"
    )
    check(
        reward_calls == 2,
        "each wolf life receives exactly one monster reward transaction"
    )

    local duplicate = encounters:on_enemy_died(second)
    check(
        duplicate.ok == true
            and duplicate.already_processed == true
            and reward_calls == 2,
        "duplicate death callback cannot duplicate reward or quest credit"
    )
    check(
        quests:claim_reward(
            USER_ID,
            "ForestWolfBounty"
        ).reason == "QuestAlreadyCompleted",
        "completed bounty cannot pay twice"
    )

    first:Destroy()
    second:Destroy()

    print(
        ("[Forest Wolf Bounty Dungeon Integration] PASS: %d assertions")
            :format(checks)
    )
end

main()
