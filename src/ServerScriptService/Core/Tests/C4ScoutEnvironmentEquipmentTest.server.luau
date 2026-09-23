--!strict
-- Real C4 Scout environment skill purchases, equipment and injury rules.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared
local Skills = require(Shared.SkillProgressionDefinitions)
local Unlocks = require(Shared.SkillUnlockRules)
local Trainers = require(Shared.TrainerCatalogues)
local Schema = require(Shared.ProfileSchema)
local Passives = require(Shared.PassiveSkillEffects)
local Environment = require(Shared.ScoutEnvironmentalRules)
local EquipmentRules = require(Shared.EquipmentRules)
local Items = require(Shared.ItemDefinitions)
local Recipes = require(Shared.ProfessionRecipes)
local Combat = require(RS.Combat.Shared.SkillDefinitions)
local Adapter = require(SSS.Core.Adapters.InMemoryProfileAdapter)
local Profiles = require(SSS.Core.Services.ProfileService)
local Inventory = require(SSS.Core.Services.InventoryService)
local Equipment = require(SSS.Core.Services.EquipmentService)
local SkillService = require(SSS.Core.Services.SkillProgressionService)
local Loadout = require(SSS.Core.Services.LoadoutService)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)

local SOURCE_SKILLS = {
    "ScoutEquipmentExpertise", "ScoutLungCapacity",
    "ScoutFallResistance",
}
local checks = 0

--[[
Checks one authentic equipment/environment/C4 source requirement.

Args:
    condition (boolean): Required character, item or injury invariant.
    description (string): Error message identifying the failed contract.

Returns:
    nil: Increments the suite count or fails an actual Studio test.
]]
local function check(condition: boolean, description: string)
    checks += 1
    assert(condition, "[C4 Scout Environment] " .. description)
end

--[[
Creates an isolated source character with actual server profile services.

Args:
    user_id (number): Disposable user identity.
    race_id (string): Original C4 Human/Elf source race.
    class_id (string): Eligible Ranger/Rogue base-class analogue.

Returns:
    any: Real profile, inventory, training and equipment services.
]]
local function setup(
    user_id: number, race_id: string, class_id: string
): any
    local profiles = Profiles.new(Adapter.new())
    check(profiles:load(user_id), "Isolated profile must load")
    check(profiles:mutate(user_id, function(profile: any)
        local character = profile.Characters.Slot1
        character.Identity = {
            Version = 1, RaceId = race_id,
            BaseClassId = class_id, ClassId = class_id,
            CreationStage = "Complete",
        }
        character.Level = 20
        character.Progression.SkillPointEntitlement = 250
        character.Gold = 1500
    end), "Selected original source character must persist")
    local inventory = Inventory.new(profiles)
    return {
        Profiles = profiles, Inventory = inventory,
        Equipment = Equipment.new(profiles, "Base"),
        Skills = SkillService.new(
            profiles, inventory, Loadout.new(profiles)
        ),
        UserId = user_id,
    }
end

--[[
Validates source-level gates and genuine paid environmental training.

Args:
    services (any): Real authoritative source profile and skill service.

Returns:
    nil: Checks unbought effects, early training and paid active effects.
]]
local function verify_passives(services: any)
    local owner = services.UserId
    local character = assert(services.Profiles:get_character(owner, 1))
    local class_id = character.Identity.BaseClassId
    check(Passives.scout_oxygen_bonus(character) == 0,
        "Unbought Lung Capacity cannot grant extra oxygen")
    check(Passives.scout_fall_reduction(character) == 0,
        "Unbought Fall Resistance cannot reduce hard-landing injury")
    check(not Passives.has_scout_equipment_expertise(character),
        "Unbought Equipment Expertise cannot unlock crafted Scout gear")
    for _, skill_id in ipairs(SOURCE_SKILLS) do
        local definition = assert(Skills.get(skill_id))
        check(definition.Kind == "Passive" and definition.MaxRank == 1
            and definition.RankLevels[1] == 20,
            "All three source skills must require a paid level-20 rank")
        check(Trainers.can_offer(
            class_id .. "Trainer", character, skill_id
        ).ok, "Real selected class trainer cannot teach a source passive")
        check(services.Profiles:mutate(owner, function(profile: any)
            profile.Characters.Slot1.Level = 19
        end), "Pre-level character mutation failed")
        check(not services.Skills:learn_trainer_skill(
            owner, skill_id
        ).ok, "Character bought source passive before level 20")
        check(services.Profiles:mutate(owner, function(profile: any)
            profile.Characters.Slot1.Level = 20
        end), "Genuine level-20 source progression failed")
        check(services.Skills:learn_trainer_skill(
            owner, skill_id
        ).ok, "Source passive not bought with real rank service")
    end
    character = assert(services.Profiles:get_character(owner, 1))
    check(Passives.has_scout_equipment_expertise(character),
        "Purchased rank must unlock a genuine crafted armor permission")
    check(Environment.max_oxygen(character) == 27,
        "Actual source rank must add 15 seconds to submerged breathing")
    check(math.abs(Passives.scout_fall_reduction(
        character
    ) - 0.4) < 0.0001,
        "Purchased fall rank must actually reduce world impact injury")
end

--[[
Proves server oxygen and fall calculations change only on earned ranks.

Args:
    services (any): Authenticated paid Scout from the real profile service.

Returns:
    nil: Verifies water/drowning boundary and fall-only damage reduction.
]]
local function verify_environment(services: any)
    local character = assert(services.Profiles:get_character(
        services.UserId, 1
    ))
    local base = Schema.create_default(99371).Characters.Slot1
    check(Environment.max_oxygen(base) == 12,
        "Untrained classes must retain the twelve-second base air reserve")
    check(Environment.next_oxygen(12, 1, true, base) == 11,
        "Underwater untrained character must lose actual air")
    check(Environment.next_oxygen(11, 1, false, base) == 12,
        "Surfacing must refill air without an unearned bonus")
    check(Environment.next_oxygen(0, 1, true, character) == 0,
        "Submerged zero oxygen must remain zero for drowning injury")
    check(Environment.next_oxygen(27, 1, true, character) == 26,
        "Purchased capacity must extend actual submersion time")
    check(Environment.next_oxygen(26, 1, false, character) == 27,
        "Purchased air reserve restores only to the earned ceiling")
    check(Environment.fall_damage(base, 65) == 0,
        "Ordinary small falls must not injure a character")
    check(math.abs(Environment.fall_damage(base, 100) - 18) < 0.001,
        "Untrained hard landing must cause actual calculated damage")
    check(math.abs(
        Environment.fall_damage(character, 100) - 10.8
    ) < 0.001, "Purchased resistance must reduce actual injury by 40%")
    character.Identity.BaseClassId = "Mage"
    check(Environment.max_oxygen(character) == 12,
        "Forged foreign class cannot keep the oxygen bonus")
    check(math.abs(
        Environment.fall_damage(character, 100) - 18
    ) < 0.001, "Forged foreign class cannot keep fall resistance")
end

--[[
Tests an actual crafted Scout vest through server preview/equip and HP.

Args:
    services (any): Selected real source profile, inventory and equipment.

Returns:
    nil: Rejects unbought/wrong-class gear; confirms equipped health effect.
]]
local function verify_equipment(services: any)
    local owner = services.UserId
    local item_id = "scout_expert_leather_vest"
    local item = assert(Items.get(item_id))
    local recipe = assert(Recipes.get("stitch_scout_expert_vest"))
    check(recipe.ProfessionId == "Leatherworking"
        and recipe.StationId == "Leatherworking"
        and recipe.RequiredLevel >= 2
        and recipe.Output.ItemId == item_id
        and #recipe.Inputs >= 3,
        "Expert equipment must be made by a real selected Leatherworker")
    check(item.RequiredSkillId == "ScoutEquipmentExpertise"
        and item.RequiredSkillRank == 1
        and item.CombatModifiers.MaxHealthFlat == 12,
        "Expert vest must have real stat benefit and paid equipping gate")
    check(services.Inventory:add_item(owner, item_id, 1).ok,
        "Real inventory can receive another player's crafted vest")
    check(services.Profiles:mutate(owner, function(profile: any)
        profile.Characters.Slot1.Progression.Skills
            .ScoutEquipmentExpertise = nil
    end), "Test fixture removes only the expertise purchase")
    check(services.Equipment:equip(owner, item_id, "Body").reason
        == "ScoutEquipmentExpertiseRequired",
        "Actually owned expert vest must not equip before purchase")
    check(services.Profiles:mutate(owner, function(profile: any)
        profile.Characters.Slot1.Progression.Skills
            .ScoutEquipmentExpertise = {
                Known = true, PurchasedRank = 1, Proficiency = 0,
            }
    end), "Restored purchased rank must persist")
    local character = assert(services.Profiles:get_character(owner, 1))
    check(EquipmentRules.validate(
        character, item, "Body"
    ).ok, "A trained Rogue/Scout must be allowed to equip crafted vest")
    Runtime.set_character(owner, character)
    local before = Runtime.get_max_health(owner)
    check(services.Equipment:equip(owner, item_id, "Body").ok,
        "The real equipment service must equip the genuine owned vest")
    character = assert(services.Profiles:get_character(owner, 1))
    Runtime.set_character(owner, character)
    check(Runtime.get_max_health(owner) == before + 12,
        "Real expert vest must grant its resolved combat maximum health")
    check(services.Equipment:unequip(owner, "Body").ok,
        "Expert vest must unequip through the existing equipment service")
    character = assert(services.Profiles:get_character(owner, 1))
    Runtime.set_character(owner, character)
    check(Runtime.get_max_health(owner) == before,
        "Unequipping the source-gated vest must revoke its actual HP")
    Runtime.clear_character(owner)
end

--[[
Verifies the Human-only source Sprint uses actual paid combat authority.

Args:
    None.

Returns:
    nil: Confirms class/race, stamina, timing and equipped-skill gates.
]]
local function verify_human_sprint()
    local definition = assert(Skills.get("HumanScoutSprint"))
    local effect = assert(Combat.get_for_rank("HumanScoutSprint", 1))
    check(definition.MaxRank == 1 and definition.RankLevels[1] == 20
        and definition.Kind == "Support",
        "Original level-20 Sprint must be a separately purchased skill")
    check(effect.KIND == "Buff" and effect.BUFF_KIND == "Movement"
        and effect.STAMINA_COST >= 15
        and effect.COOLDOWN_SECONDS >= 20
        and effect.BUFF_MAGNITUDE > 0
        and effect.BUFF_SECONDS > 0,
        "Sprint must truly pay stamina for a timed combat-safe boost")
    local elf = Schema.create_default(99373).Characters.Slot1
    elf.Identity = {
        Version = 1, RaceId = "Elf", BaseClassId = "Rogue",
        ClassId = "Rogue", CreationStage = "Complete",
    }
    elf.Level = 20
    check(not Unlocks.can_show(elf, definition),
        "Elven Scout must not learn Human Rogue source Sprint")
    local human = setup(99374, "Human", "Rogue")
    check(human.Skills:learn_trainer_skill(
        human.UserId, "HumanScoutSprint"
    ).ok, "Human Rogue must buy real Sprint at its class trainer")
    local character = assert(human.Profiles:get_character(human.UserId, 1))
    Runtime.set_character(human.UserId, character)
    check(not Runtime.is_skill_usable(
        human.UserId, "HumanScoutSprint"
    ), "Purchased but unequipped Sprint cannot be invoked for free")
    check(human.Profiles:mutate(human.UserId, function(profile: any)
        profile.Characters.Slot1.Progression.Loadout[1] =
            "HumanScoutSprint"
    end), "Active Sprint loadout selection must persist")
    Runtime.set_character(
        human.UserId,
        assert(human.Profiles:get_character(human.UserId, 1))
    )
    check(Runtime.is_skill_usable(human.UserId, "HumanScoutSprint"),
        "Bought and equipped Human Rogue Sprint must be usable")
    Runtime.clear_character(human.UserId)
end

--[[
Runs real rank purchases, gear equips and pure environmental mechanics.

Args:
    None.

Returns:
    nil: Prints the actual executed assertions only after successful tests.
]]
local function main()
    for _, spec in ipairs({
        {99361, "Human", "Rogue"},
        {99362, "Elf", "Ranger"},
    }) do
        local services = setup(spec[1], spec[2], spec[3])
        verify_passives(services)
        verify_environment(services)
        verify_equipment(services)
    end
    verify_human_sprint()
    print(("[C4 Scout Environment] PASS: %d assertions")
        :format(checks))
end

main()
