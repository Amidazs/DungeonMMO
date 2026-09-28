--!strict
-- Real Marauder Captain factory -> EncounterService -> QuestService bounty.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared
local Core = ServerScriptService.Core
local Dungeon = ServerScriptService.Dungeon

local DungeonDefinitions = require(Shared.DungeonDefinitions)
local Adapter = require(Core.Adapters.InMemoryProfileAdapter)
local Profiles = require(Core.Services.ProfileService)
local Quests = require(Core.Services.QuestService)
local EncounterService = require(Dungeon.EncounterService)
local MarauderCaptainFactory = require(
    Dungeon.MarauderCaptainFactory
)

local USER_ID = 968301
local checks = 0

--[[
Counts one Captain bounty integration assertion.

Args:
    condition (boolean): Expected authoritative integration result.
    label (string): Diagnostic failure context.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(
        condition,
        "[Marauder Captain Bounty Dungeon Integration] "
            .. label
    )
end

--[[
Installs one launch-valid level-five Dark Elf with Worldroot completed.

Args:
    profiles (any): Loaded authoritative profile service.

Returns:
    nil: Mutates only the disposable in-memory character.
]]
local function install_character(profiles: any)
    check(
        profiles:mutate(USER_ID, function(profile: any)
            local character = profile.Characters.Slot1
            character.Level = 5
            character.Identity = {
                Version = 1,
                RaceId = "DarkElf",
                BaseClassId = "Fighter",
                ClassId = "Fighter",
                CreationStage = "Complete",
            }
            character.Quests.Completed.WorldrootRelic = true
        end),
        "level-five Dark Elf prerequisite state persists"
    )
end

--[[
Runs the real released Temple Captain bounty flow.

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
        quests:start(
            USER_ID,
            "MarauderCaptainBounty"
        ).ok,
        "level-five player starts Captain bounty"
    )

    local rewards = {}
    local reward_calls = 0

    function rewards:grant_monster_reward(
        member_user_ids: {number},
        _reward: any,
        _transaction_id: string
    ): any
        reward_calls += 1
        check(
            #member_user_ids == 1
                and member_user_ids[1] == USER_ID,
            "Captain reward and quest credit share active member"
        )
        return {
            ok = true,
            member_results = {},
        }
    end

    local holder = Instance.new("Folder")
    holder.Name = "TEMP_MarauderCaptainBounty"
    holder.Parent = workspace

    local reward =
        DungeonDefinitions.TEST_DUNGEON.MarauderCaptainReward
    local captain = MarauderCaptainFactory.create({
        Parent = holder,
        SpawnCFrame = CFrame.new(0, 2000, 0),
        EncounterId = "MarauderCaptainBounty",
        RewardXP = reward.XP,
        RewardGoldMin = reward.GoldMin,
        RewardGoldMax = reward.GoldMax,
        BestiaryCreatureId = reward.BestiaryCreatureId,
    })

    check(
        captain:GetAttribute("BossId") == "MarauderCaptain"
            and captain:GetAttribute("BestiaryCreatureId")
                == "marauder_captain",
        "released Captain factory exposes exact quest identity"
    )

    local encounters = EncounterService.new(
        rewards,
        "captain-bounty-integration",
        nil,
        quests
    )
    check(
        encounters:start(
            "MarauderCaptainBounty",
            {USER_ID},
            {captain}
        ).ok,
        "real Captain encounter starts"
    )

    local defeated = encounters:on_enemy_died(captain)
    check(
        defeated.ok == true
            and defeated.cleared == true,
        "rewarded Captain death clears encounter and progresses quest"
    )

    local claim = quests:claim_reward(
        USER_ID,
        "MarauderCaptainBounty"
    )
    check(
        claim.ok == true
            and claim.gold_granted == 60
            and #claim.items_granted == 0,
        "real Captain death unlocks exact Gold-only bounty reward"
    )
    check(
        profiles:get_character(USER_ID, 1).Gold == 60,
        "Captain bounty Gold commits to authoritative character"
    )
    check(
        reward_calls == 1,
        "Captain life receives exactly one monster reward transaction"
    )

    local duplicate = encounters:on_enemy_died(captain)
    check(
        duplicate.ok == true
            and duplicate.already_processed == true
            and reward_calls == 1,
        "duplicate Captain death cannot duplicate reward or quest credit"
    )
    check(
        quests:claim_reward(
            USER_ID,
            "MarauderCaptainBounty"
        ).reason == "QuestAlreadyCompleted",
        "completed Captain bounty cannot pay twice"
    )
    check(
        quests:start(USER_ID, "MineEchoes").ok,
        "optional Captain bounty does not block Mine Echoes"
    )

    holder:Destroy()

    print(
        ("[Marauder Captain Bounty Dungeon Integration] PASS: %d assertions")
            :format(checks)
    )
end

main()
