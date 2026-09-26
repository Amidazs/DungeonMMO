--!strict
-- Real first-tier Mystic robe and novice purchase/persistence contracts.
local SSS = game:GetService("ServerScriptService")
local Core = SSS.Core
local Profiles = require(Core.Services.ProfileService)
local Memory = require(Core.Adapters.InMemoryProfileAdapter)
local Inventory = require(Core.Services.InventoryService)
local Loadout = require(Core.Services.LoadoutService)
local Skills = require(Core.Services.SkillProgressionService)

local assertions = 0
local MAGE_ID = 77901
local FIGHTER_ID = 77902

--[[
Checks an isolated real-service training or persistence outcome.

Args:
    condition (boolean): Expected trainer state or saved purchased rank.
    description (string): Diagnostic identifying a rejected invariant.

Returns:
    nil: Records a passing check or raises.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 Base Training] " .. description)
end

--[[
Loads one detached character with actual class/race and training points.

Args:
    profiles (any): Isolated production profile service.
    user_id (number): Fake user ID with a private in-memory profile.
    class_id (string): Starting Fighter or Mage.
    race_id (string): Human or Elf.

Returns:
    nil: Mutates the isolated profile through its normal authority.
]]
local function seed_character(
    profiles: any, user_id: number,
    class_id: string, race_id: string
)
    check(profiles:load(user_id) ~= nil, "Test profile did not load")
    check(profiles:mutate(user_id, function(profile: any)
        local character = profile.Characters.Slot1
        character.Identity = {
            Version = 1,
            RaceId = race_id,
            BaseClassId = class_id,
            ClassId = class_id,
            CreationStage = "Complete",
        }
        character.Level = 1
        character.Progression.SkillPointEntitlement = 100
        if class_id == "Mage" then
            character.Equipment.Weapon = "apprentice_arcane_wand"
            character.Equipment.Body = "apprentice_mystic_robe"
        end
    end), "Source starting character could not be initialized")
end

--[[
Buys one real first-tier skill and proves it survives profile reload.

Args:
    profiles (any): In-memory production profile service.
    skills (any): Real server training/purchase service.
    user_id (number): Test character whose rank is purchased.
    skill_id (string): Real registered source-inspired novice skill.

Returns:
    nil: Confirms rank one, max rank and durable purchased state.
]]
local function buy_and_reload(
    profiles: any, skills: any,
    user_id: number, skill_id: string
)
    local result = skills:learn_trainer_skill(user_id, skill_id)
    check(result.ok == true and result.rank == 1,
        skill_id .. " did not sell its legitimate first rank")
    check(skills:purchase_rank(
        user_id, skill_id
    ).reason == "MaxRank",
        skill_id .. " sold a nonexistent second rank")
    check(profiles:save(user_id, "C4BaseTraining"),
        skill_id .. " rank did not save")
    check(profiles:release(user_id, "C4BaseTraining"),
        skill_id .. " profile could not release")
    check(profiles:load(user_id) ~= nil,
        skill_id .. " profile failed to reload")
    local character = assert(profiles:get_character(user_id))
    check(character.Progression.Skills[skill_id].PurchasedRank == 1,
        skill_id .. " purchased rank disappeared after reload")
end

--[[
Exercises the actual purchased-rank and level-expiry trainer boundary
for currently supported first-tier Human/Elf characters.

Args:
    None.

Returns:
    nil: Emits the checked real trainer purchase assertion count.
]]
local function main()
    local profiles = Profiles.new(Memory.new())
    local skills = Skills.new(
        profiles, Inventory.new(profiles), Loadout.new(profiles)
    )
    seed_character(profiles, MAGE_ID, "Mage", "Human")
    seed_character(profiles, FIGHTER_ID, "Fighter", "Elf")

    buy_and_reload(
        profiles, skills, MAGE_ID, "MysticRobeCasting"
    )
    buy_and_reload(
        profiles, skills, MAGE_ID, "MysticRobeManaRecovery"
    )
    buy_and_reload(
        profiles, skills, MAGE_ID, "MysticRobeAttackSpeed"
    )
    buy_and_reload(
        profiles, skills, FIGHTER_ID, "NoviceProtection"
    )

    check(profiles:mutate(FIGHTER_ID, function(profile: any)
        profile.Characters.Slot1.Level = 20
    end), "Cannot advance the Fighter to first-transfer level")
    check(not skills:learn_trainer_skill(
        FIGHTER_ID, "NoviceProtection"
    ).ok, "Novice protection cannot remain trainable after level 19")
    check(not skills:learn_trainer_skill(
        FIGHTER_ID, "MysticRobeCasting"
    ).ok, "Fighter trainer cannot sell Mage casting ranks")
    check(not skills:learn_trainer_skill(
        MAGE_ID, "FighterPhysicalTraining"
    ).ok, "Mage trainer cannot sell Fighter attack mastery")
    print(("[C4 Base Training] PASS: %d assertions.")
        :format(assertions))
end

main()
