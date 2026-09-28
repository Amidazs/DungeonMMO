--!strict
-- Reward-path coverage for foundation and advanced profession blueprints.

local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Core = ServerScriptService.Core
local Adapters = Core.Adapters
local Services = Core.Services

local ProfileAdapter = require(Adapters.InMemoryProfileAdapter)
local Profiles = require(Services.ProfileService)
local Inventory = require(Services.InventoryService)
local Progression = require(Services.ProgressionService)
local Rewards = require(Services.RewardService)

local SUCCESS_ID = 966101
local MISS_ID = 966102
local FOUNDATION_ID = "blacksmith_iron_guard_blueprint"
local ADVANCED_ID = "blacksmith_masterwork_batch_blueprint"

local checks = 0

local success_rng: any = {}

--[[
Returns the lower bound so rare chance and weighted rolls succeed.

Args:
    minimum (number?): Optional lower bound.
    maximum (number?): Optional upper bound.

Returns:
    number: Lower bound, or zero when omitted.
]]
function success_rng:NextNumber(
    minimum: number?,
    _maximum: number?
): number
    return minimum or 0
end

--[[
Returns the lower integer bound for deterministic Gold rolls.

Args:
    minimum (number): Inclusive lower bound.
    maximum (number): Inclusive upper bound.

Returns:
    number: Lower bound.
]]
function success_rng:NextInteger(
    minimum: number,
    _maximum: number
): number
    return minimum
end

local fail_rng: any = {}

--[[
Returns the upper bound so optional chance checks miss.

Args:
    minimum (number?): Optional lower bound.
    maximum (number?): Optional upper bound.

Returns:
    number: Upper bound, or one when omitted.
]]
function fail_rng:NextNumber(
    _minimum: number?,
    maximum: number?
): number
    return maximum or 1
end

--[[
Returns the lower integer bound for unrelated reward rolls.

Args:
    minimum (number): Inclusive lower bound.
    maximum (number): Inclusive upper bound.

Returns:
    number: Lower bound.
]]
function fail_rng:NextInteger(
    minimum: number,
    _maximum: number
): number
    return minimum
end

--[[
Counts one profession-blueprint reward assertion.

Args:
    condition (boolean): Expected reward or inventory result.
    label (string): Failure context.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[Profession Blueprint Reward] " .. label)
end

--[[
Returns one item quantity for a loaded character.

Args:
    profiles (any): Loaded profile service.
    user_id (number): Inventory owner.
    item_id (string): Registered blueprint identifier.

Returns:
    number: Current inventory quantity.
]]
local function quantity(
    profiles: any,
    user_id: number,
    item_id: string
): number
    return Inventory.count_item(
        assert(profiles:get_character(user_id, 1)),
        item_id
    )
end

--[[
Creates a reward service with one deterministic RNG.

Args:
    profiles (any): Loaded profile service.
    rng (any): Deterministic random provider.
    timestamp (number): Stable test clock value.

Returns:
    any: Server-authoritative reward service.
]]
local function make_rewards(
    profiles: any,
    rng: any,
    timestamp: number
): any
    return Rewards.new(
        profiles,
        Progression.new(profiles),
        Inventory.new(profiles),
        nil,
        rng,
        function(): number
            return timestamp
        end
    )
end

--[[
Runs boss, completion, replay and failed blueprint reward checks.

Args:
    None.

Returns:
    nil: Prints a stable pass marker after all routes succeed.
]]
local function main()
    Workspace:SetAttribute(
        "TEST_BlockProfessionBlueprintDrop",
        nil
    )
    Workspace:SetAttribute(
        "TEST_ForceProfessionBlueprintDrop",
        nil
    )

    local profiles = Profiles.new(ProfileAdapter.new())
    check(profiles:load(SUCCESS_ID), "success profile loads")
    check(profiles:load(MISS_ID), "miss profile loads")

    local rewards = make_rewards(
        profiles,
        success_rng,
        8100
    )

    local depth_one = rewards:grant_monster_reward(
        {SUCCESS_ID},
        {
            XP = 1,
            GoldMin = 0,
            GoldMax = 0,
            BossId = "MarauderCaptain",
        },
        "profession-blueprint-depth1"
    )
    check(depth_one.ok == true, "Depth-one boss reward succeeds")
    check(
        depth_one.member_results[tostring(SUCCESS_ID)]
            .profession_blueprint_item_id == FOUNDATION_ID,
        "Depth-one boss grants a foundation blueprint"
    )

    local higher_depth = rewards:grant_monster_reward(
        {SUCCESS_ID},
        {
            XP = 1,
            GoldMin = 0,
            GoldMax = 0,
            BossId = "TempleDepth2Boss",
        },
        "profession-blueprint-depth2"
    )
    check(
        higher_depth.ok == true
            and higher_depth.member_results[
                tostring(SUCCESS_ID)
            ].profession_blueprint_item_id == ADVANCED_ID,
        "higher-depth boss grants an advanced blueprint"
    )

    local completion = rewards:grant_completion(
        "profession-blueprint-completion",
        1,
        SUCCESS_ID,
        {
            Gold = 0,
            LootTable = {
                {
                    Weight = 1,
                    Kind = "Nothing",
                },
            },
        },
        success_rng,
        "TestDungeon"
    )
    check(
        completion.ok == true
            and completion.profession_blueprint_item_id
                == FOUNDATION_ID,
        "normal dungeon completion grants foundation blueprint"
    )
    check(
        quantity(profiles, SUCCESS_ID, FOUNDATION_ID) == 2
            and quantity(
                profiles,
                SUCCESS_ID,
                ADVANCED_ID
            ) == 1,
        "boss and completion rewards stack independently"
    )

    local replay = rewards:grant_monster_reward(
        {SUCCESS_ID},
        {
            XP = 1,
            GoldMin = 0,
            GoldMax = 0,
            BossId = "TempleDepth2Boss",
        },
        "profession-blueprint-depth2"
    )
    check(
        replay.ok == true and replay.already_applied == true,
        "boss transaction replays idempotently"
    )
    check(
        quantity(profiles, SUCCESS_ID, ADVANCED_ID) == 1,
        "boss replay cannot duplicate advanced blueprint"
    )

    local completion_replay = rewards:grant_completion(
        "profession-blueprint-completion",
        1,
        SUCCESS_ID,
        {
            Gold = 0,
            LootTable = {
                {
                    Weight = 1,
                    Kind = "Nothing",
                },
            },
        },
        success_rng,
        "TestDungeon"
    )
    check(
        completion_replay.ok == true
            and completion_replay.already_applied == true,
        "completion transaction replays idempotently"
    )
    check(
        quantity(profiles, SUCCESS_ID, FOUNDATION_ID) == 2,
        "completion replay cannot duplicate blueprint"
    )

    local miss_rewards = make_rewards(
        profiles,
        fail_rng,
        8101
    )
    local boss_miss = miss_rewards:grant_monster_reward(
        {MISS_ID},
        {
            XP = 1,
            GoldMin = 0,
            GoldMax = 0,
            BossId = "TempleDepth2Boss",
        },
        "profession-blueprint-boss-miss"
    )
    check(
        boss_miss.ok == true
            and boss_miss.member_results[
                tostring(MISS_ID)
            ].profession_blueprint_item_id == nil,
        "failed boss chance grants no blueprint"
    )

    local completion_miss = miss_rewards:grant_completion(
        "profession-blueprint-completion-miss",
        1,
        MISS_ID,
        {
            Gold = 0,
            LootTable = {
                {
                    Weight = 1,
                    Kind = "Nothing",
                },
            },
        },
        fail_rng,
        "AbandonedMine"
    )
    check(
        completion_miss.ok == true
            and completion_miss.profession_blueprint_item_id
                == nil,
        "failed completion chance grants no blueprint"
    )
    check(
        quantity(profiles, MISS_ID, FOUNDATION_ID) == 0
            and quantity(
                profiles,
                MISS_ID,
                ADVANCED_ID
            ) == 0,
        "failed rolls leave blueprint inventory empty"
    )

    print(
        ("[Profession Blueprint Reward] PASS: %d assertions")
            :format(checks)
    )
end

main()
