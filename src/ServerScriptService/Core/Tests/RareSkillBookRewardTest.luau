--!strict
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
        error("[Rare Skill Book Reward Tests] " .. message, 2)
    end
end

local success_rng: any = {}
function success_rng:NextNumber(minimum: number, _maximum: number): number
    return minimum
end
function success_rng:NextInteger(minimum: number, _maximum: number): number
    return minimum
end

local fail_rng: any = {}
function fail_rng:NextNumber(_minimum: number, maximum: number): number
    return maximum
end
function fail_rng:NextInteger(minimum: number, _maximum: number): number
    return minimum
end

local function count(character: any): number
    return InventoryService.count_item(character, "arc_slash_book")
end

local profiles = ProfileService.new(InMemoryProfileAdapter.new())
assert(profiles:load(9701))
assert(profiles:load(9702))
assert(profiles:load(9703))

-- Make 9702 explicitly Mage to prove drops are not class-filtered.
assert(profiles:mutate(9702, function(profile: any)
    profile.Characters.Slot1.Identity = {
        Version = 1,
        RaceId = "Human",
        BaseClassId = "Mage",
        ClassId = "Mage",
        CreationStage = "Complete",
    }
end))

local success = RewardService.new(
    profiles,
    ProgressionService.new(profiles),
    InventoryService.new(profiles),
    nil,
    success_rng,
    function()
        return 7000
    end
)

local boss = success:grant_monster_reward(
    {9701, 9702},
    {XP = 1, GoldMin = 0, GoldMax = 0, BossId = "MarauderCaptain"},
    "rare-book-boss-1"
)
check(boss.ok == true, "boss reward must succeed.")
check(
    boss.member_results["9701"].skill_book_item_id == "arc_slash_book",
    "first member must receive personal boss book."
)
check(
    boss.member_results["9702"].skill_book_item_id == "arc_slash_book",
    "off-class Mage must receive personal boss book."
)
check(count(assert(profiles:get_character(9701, 1))) == 1, "first member inventory must contain one book.")
check(count(assert(profiles:get_character(9702, 1))) == 1, "Mage inventory must contain one book.")

local replay = success:grant_monster_reward(
    {9701, 9702},
    {XP = 1, GoldMin = 0, GoldMax = 0, BossId = "MarauderCaptain"},
    "rare-book-boss-1"
)
check(replay.ok == true and replay.already_applied == true, "same boss transaction must replay.")
check(count(assert(profiles:get_character(9701, 1))) == 1, "replay must not duplicate the book.")

assert(profiles:mutate(9701, function(profile: any)
    profile.Characters.Slot1.Progression.Skills.ArcSlash = {
        Known = true,
        StarterGranted = false,
        PurchasedRank = 1,
        Proficiency = 0,
    }
end))

local duplicate = success:grant_monster_reward(
    {9701},
    {XP = 1, GoldMin = 0, GoldMax = 0, BossId = "CorruptedForeman"},
    "rare-book-boss-2"
)
check(duplicate.ok == true, "second boss transaction must succeed.")
check(
    count(assert(profiles:get_character(9701, 1))) == 2,
    "already-known skill must not remove duplicate book drops."
)

local completion = success:grant_completion(
    "rare-book-completion-1",
    1,
    9701,
    {Gold = 0, LootTable = {{Weight = 1, Kind = "Nothing"}}},
    success_rng,
    "AbandonedMine"
)
check(
    completion.ok == true and completion.skill_book_item_id == "arc_slash_book",
    "completion bonus roll must grant Arc Slash book."
)
check(
    count(assert(profiles:get_character(9701, 1))) == 3,
    "completion book must stack independently of ordinary loot."
)

local completion_replay = success:grant_completion(
    "rare-book-completion-1",
    1,
    9701,
    {Gold = 0, LootTable = {{Weight = 1, Kind = "Nothing"}}},
    success_rng,
    "AbandonedMine"
)
check(completion_replay.already_applied == true, "completion replay must use stored result.")
check(count(assert(profiles:get_character(9701, 1))) == 3, "completion replay must not duplicate book.")

local failure = RewardService.new(
    profiles,
    ProgressionService.new(profiles),
    InventoryService.new(profiles),
    nil,
    fail_rng,
    function()
        return 7001
    end
)

local failed_boss = failure:grant_monster_reward(
    {9703},
    {XP = 1, GoldMin = 0, GoldMax = 0, BossId = "MarauderCaptain"},
    "rare-book-boss-fail"
)
check(
    failed_boss.ok == true
        and failed_boss.member_results["9703"].skill_book_item_id == nil,
    "failed boss roll must grant no book."
)

local failed_completion = failure:grant_completion(
    "rare-book-completion-fail",
    1,
    9703,
    {Gold = 0, LootTable = {{Weight = 1, Kind = "Nothing"}}},
    fail_rng,
    "TestDungeon"
)
check(
    failed_completion.ok == true and failed_completion.skill_book_item_id == nil,
    "failed completion roll must grant no book."
)
check(count(assert(profiles:get_character(9703, 1))) == 0, "failed rolls must leave inventory unchanged.")

print(string.format("[Rare Skill Book Reward Tests] PASS: %d assertions.", assertions))
