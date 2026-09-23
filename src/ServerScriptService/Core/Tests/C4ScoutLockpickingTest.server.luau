--!strict
-- Five bought original C4 Lockpicking ranks for both source classes.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared
local Source = require(Shared.SkillProgressionDefinitions)
local Rules = require(Shared.SkillUnlockRules)
local Trainers = require(Shared.TrainerCatalogues)
local Schema = require(Shared.ProfileSchema)
local Inventory = require(SSS.Core.Services.InventoryService)
local Adapter = require(SSS.Core.Adapters.InMemoryProfileAdapter)
local Profiles = require(SSS.Core.Services.ProfileService)
local Locks = require(SSS.Dungeon.ScoutLockpickingService)

local LEVELS = {20, 24, 28, 32, 36}
local checks = 0

--[[
Records one original source rank or genuine profile/inventory invariant.

Args:
    condition (boolean): Required C4 ability or loot fact.
    description (string): Precise failure diagnostic.

Returns:
    nil: Counts a successful server assertion or raises.
]]
local function check(condition: boolean, description: string)
    checks += 1
    assert(condition, "[C4 Scout Lockpicking] " .. description)
end

--[[
Creates one detached class character for exact trainer/rank gates.

Args:
    user_id (number): Isolated profile identity.
    race_id (string): Human or Elf original C4 source.
    class_id (string): Actual Rogue or Ranger branch.

Returns:
    any: Character with appropriate class, race, and source level.
]]
local function character_for(
    user_id: number, race_id: string, class_id: string
): any
    local character = Schema.create_default(user_id).Characters.Slot1
    character.Identity.RaceId = race_id
    character.Identity.BaseClassId = class_id
    character.Identity.ClassId = class_id
    character.Identity.CreationStage = "Complete"
    character.Level = 20
    return character
end

--[[
Checks that each of five ranks needs its correct preceding paid rank.

Args:
    user_id (number): Isolated source character identifier.
    race_id (string): Original source race.
    class_id (string): Ranger or Rogue original analogue.

Returns:
    nil: Verifies actual learn/purchase levels and wrong-class denial.
]]
local function check_source(
    user_id: number, race_id: string, class_id: string
)
    local definition = assert(Source.get("ScoutLockpicking"))
    local character = character_for(user_id, race_id, class_id)
    check(definition.MaxRank == 5
        and definition.Kind == "Passive"
        and definition.WorldLockpickingEnabled == true,
        "All source ranks must be real, learned world interactions")
    check(Trainers.can_offer(
        class_id .. "Trainer", character, definition.Id
    ).ok, "Authentic class trainer must offer bought lockpicking")
    for rank, level in ipairs(LEVELS) do
        check(definition.RankLevels[rank] == level,
            "One bought rank must appear in each original source bracket")
        character.Level = level - 1
        check(not Rules.can_train(character, definition, rank),
            "Rank was available before its original C4 source level")
        character.Level = level
        local can_train = Rules.can_train(character, definition, rank)
        check(can_train, "Correctly earned next rank is unexpectedly gated")
        character.Progression.Skills.ScoutLockpicking = {
            Known = true,
            PurchasedRank = rank,
            Proficiency = 0,
        }
    end
    character.Identity.BaseClassId = "Mage"
    character.Identity.ClassId = "Mage"
    check(not Rules.can_show(character, definition),
        "An unqualified Mage cannot learn the Scout world skill")
end

--[[
Verifies server-authored physical locks and exactly-once profile loot.

Args:
    None.

Returns:
    nil: Rejects bad world registration and duplicate reward grants.
]]
local function check_real_reward_ledger()
    local profiles = Profiles.new(Adapter.new())
    local owner = 99731
    check(profiles:load(owner), "Isolated reward profile loads")
    local part = Instance.new("Part")
    part.Anchored = true
    part.Parent = workspace
    local locks = Locks.new({}, profiles, "C4LockFixtureRun", "TestDungeon")
    local registered = locks:register({
        Id = "C4LockFixtureCache",
        Rank = 1, CheckpointSequence = 1,
        Part = part, RewardItemId = "captain_emblem",
        RewardQuantity = 1,
    })
    check(registered.ok and registered.prompt.Parent == part,
        "Physical world lock needs a genuine server-owned prompt")
    check(not locks:register({
        Id = "C4LockFixtureCache", Rank = 1, CheckpointSequence = 1,
        Part = part, RewardItemId = "captain_emblem",
        RewardQuantity = 1,
    }).ok, "Duplicate physical lock definitions must be refused")
    check(not locks:register({
        Id = "ForgedRewardCache", Rank = 1, CheckpointSequence = 1,
        Part = part, RewardItemId = "private_bank_contents",
        RewardQuantity = 1,
    }).ok, "Unknown/private loot cannot become a server reward")
    local lock = locks._locks.C4LockFixtureCache
    local first = locks:_award(owner, lock)
    check(first.ok, "First genuine server reward must commit")
    local second = locks:_award(owner, lock)
    check(not second.ok and second.reason == "LockAlreadyClaimed",
        "A repeated lock grant must never duplicate its inventory loot")
    local character = assert(profiles:get_character(owner, 1))
    check(Inventory.count_item(character, "captain_emblem") == 1,
        "One opened cache grants exactly one legitimate reward")
    local reloaded = Locks.new(
        {}, profiles, "C4LockFixtureRun", "TestDungeon"
    )
    check(not reloaded:_award(owner, lock).ok,
        "Recreated server service cannot replay persisted loot")
    local new_session = Locks.new(
        {}, profiles, "DifferentValidRun", "TestDungeon"
    )
    check(new_session:_award(owner, lock).ok,
        "A truly different dungeon run may award its own cache once")
    character = assert(profiles:get_character(owner, 1))
    check(Inventory.count_item(character, "captain_emblem") == 2,
        "The new dungeon's reward does not erase old inventory")
    part:Destroy()
end

--[[
Executes only original skill/rank and persistent one-time loot contracts.

Args:
    None.

Returns:
    nil: Prints the exact isolated real-source assertion total.
]]
local function main()
    check_source(99721, "Human", "Rogue")
    check_source(99722, "Elf", "Ranger")
    check_source(99723, "Human", "Ranger")
    check_source(99724, "Elf", "Rogue")
    check_real_reward_ledger()
    print(("[C4 Scout Lockpicking] PASS: %d assertions")
        :format(checks))
end

main()
