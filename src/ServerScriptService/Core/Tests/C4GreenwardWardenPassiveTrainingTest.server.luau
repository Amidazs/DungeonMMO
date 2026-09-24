--!strict
-- Isolated actual profile/trainer/equipment tests; not physical NPC Play.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared
local Services = SSS.Core.Services

local Adapter = require(SSS.Core.Adapters.InMemoryProfileAdapter)
local Profiles = require(Services.ProfileService)
local Transfers = require(Services.OriginalFirstTransferService)
local Skills = require(Services.SkillProgressionService)
local Inventory = require(Services.InventoryService)
local Professions = require(Services.ProfessionService)
local CraftRules = require(Shared.C4ProfessionSkillRules)
local Equipment = require(Services.EquipmentService)
local Loadout = require(Services.LoadoutService)
local Runtime = require(Services.ProgressionRuntimeState)
local Source = require(Shared.C4OriginalFirstTransferQuestStages)
local Definitions = require(Shared.SkillProgressionDefinitions)
local SkillRules = require(Shared.SkillUnlockRules)
local Trainers = require(Shared.TrainerCatalogues)
local Classes = require(Shared.ClassProgressionDefinitions)
local Passives = require(Shared.PassiveSkillEffects)
local Schema = require(Shared.ProfileSchema)
local Coverage = require(Shared.C4Level30LaunchCoverage)

local OWNER_ID = 848821
local BRANCH_ID = "ElvenKnight"
local CAREER_ID = "GreenwardWarden"
local TRAINER_ID = "GreenwardWardenTrainer"
local FAMILIES = table.freeze({
    table.freeze({
        Id = "GreenwardWardenSteelTraining",
        Levels = table.freeze({20, 24, 28, 28}),
    }),
    table.freeze({
        Id = "GreenwardWardenHeavyArmorTraining",
        Levels = table.freeze({
            20, 20, 20, 24, 24, 24, 28, 28, 28,
        }),
    }),
    table.freeze({
        Id = "GreenwardWardenMagicResistance",
        Levels = table.freeze({20, 20, 24, 24, 24, 28, 28, 28}),
    }),
    table.freeze({
        Id = "GreenwardWardenElementalHeal",
        Levels = table.freeze({
            20, 20, 20, 24, 24, 24, 28, 28, 28,
        }),
    }),
    table.freeze({
        Id = "GreenwardWardenCharm",
        Levels = table.freeze({
            20, 20, 20, 24, 24, 24, 28, 28, 28,
        }),
    }),
    table.freeze({
        Id = "GreenwardWardenAggression",
        Levels = table.freeze({24, 24, 24, 28, 28, 28}),
    }),
    table.freeze({
        Id = "GreenwardWardenEquipmentExpertise",
        Levels = table.freeze({20}),
    }),
    table.freeze({
        Id = "GreenwardWardenShieldMastery",
        Levels = table.freeze({20, 28}),
    }),
    table.freeze({
        Id = "GreenwardWardenDefenseAura",
        Levels = table.freeze({20}),
    }),
    table.freeze({
        Id = "GreenwardWardenLastStand",
        Levels = table.freeze({20}),
    }),
    table.freeze({
        Id = "GreenwardWardenPoisonRecovery",
        Levels = table.freeze({20}),
    }),
    table.freeze({
        Id = "GreenwardWardenBowWard",
        Levels = table.freeze({24}),
    }),
    table.freeze({
        Id = "GreenwardWardenAttackAura",
        Levels = table.freeze({28}),
    }),
    table.freeze({
        Id = "GreenwardWardenCommonItemCreation",
        Levels = table.freeze({20, 28}),
    }),
})
local assertions = 0

--[[
Checks one owner, purchased-rank or defensive-effect contract.

Args:
    valid (boolean): Tested requirement.
    label (string): Description of the precise failure.

Returns:
    nil: Counts a successful assertion or raises on failure.
]]
local function check(valid: boolean, label: string)
    assertions += 1
    assert(valid, "[Greenward Warden Passives] " .. label)
end

--[[
Creates a separately authenticated one-use test mentor receipt.

Args:
    None.

Returns:
    (any, any): Private mentor world and pending-event map.
]]
local function mentor_world(): (any, any)
    local pending = {}
    local world = {}
    function world:available(definition: any): boolean
        return definition.BranchId == BRANCH_ID
    end
    function world:verify(
        user_id: number, event: any, definition: any
    ): boolean
        local receipt = pending[user_id]
        pending[user_id] = nil
        return receipt == event and event.ActorUserId == user_id
            and event.TargetId == definition.MentorId
            and event.Kind == "OriginalFirstTransfer"
    end
    return world, pending
end

--[[
Builds a ready but unadvanced Elven Fighter in an isolated profile.

Args:
    profiles (any): In-memory exclusive profile writer.

Returns:
    nil: Source quest data exists without an automatically granted class.
]]
local function seed_owner(profiles: any)
    local source = assert(Source.get(BRANCH_ID))
    check(profiles:load(OWNER_ID) ~= nil, "Owner profile loads")
    check(profiles:mutate(OWNER_ID, function(profile: any)
        local owner = profile.Characters.Slot1
        owner.Level = 20
        owner.Identity = {
            Version = 1, RaceId = "Elf",
            BaseClassId = "Fighter", ClassId = "Fighter",
            CreationStage = "Complete",
        }
        owner.Progression.SkillPointEntitlement = 5000
        owner.ProfessionSlots.Creation = "Blacksmithing"
        owner.Progression.Skills.C4RecipeReading = {
            Known = true, PurchasedRank = 1, Proficiency = 0,
        }
        owner.Progression.Skills.C4CommonItemCreation = {
            Known = true, PurchasedRank = 1, Proficiency = 0,
        }
        local proofs = {}
        for _, proof_id in ipairs(source.RequiredProofIds) do
            proofs[proof_id] = true
        end
        owner.ClassAdvancement = {
            Version = 1,
            CompletedByRace = {},
            OriginalFirstTransferChoiceId = BRANCH_ID,
            OriginalFirstTransferQuest = {
                QuestId = source.Id, BranchId = BRANCH_ID,
                Step = #source.Steps + 1, Count = 0,
                Ready = true, AppliedEvents = {}, Proofs = proofs,
            },
        }
    end), "Ready source quest does not automatically grant class")
end

--[[
Verifies only a real one-use server mentor can unlock the Elven trainer.

Args:
    profiles (any): Actual isolated character service.

Returns:
    nil: Awards the original class and rejects forged earlier access.
]]
local function earn_class(profiles: any)
    local first = FAMILIES[1].Id
    local definition = assert(Definitions.get(first))
    local before = assert(profiles:get_character(OWNER_ID))
    check(not SkillRules.can_train(before, definition, 1),
        "Unadvanced Fighter cannot train a Warden passive")
    check(not Trainers.can_offer(TRAINER_ID, before, first).ok,
        "Unadvanced Fighter cannot use the Warden trainer")
    local world, pending = mentor_world()
    local transfer = Transfers.new(profiles, "Base", world)
    local event = {
        ActorUserId = OWNER_ID, Kind = "OriginalFirstTransfer",
        TargetId = "SentinelIlyra", EventId = "WardenPassiveMentor:1",
    }
    check(transfer:claim(OWNER_ID, event).reason
        == "TransferMentorProofRequired",
        "Unminted mentor event cannot award a class")
    pending[OWNER_ID] = event
    check(transfer:claim(OWNER_ID, event).class_id == CAREER_ID,
        "Only authenticated mentor grants the saved Elven Knight")
    local owner = assert(profiles:get_character(OWNER_ID))
    check(SkillRules.can_train(owner, definition, 1),
        "Earned Warden unlocks its own first passive rank")
    check(Trainers.can_offer(TRAINER_ID, owner, first).ok,
        "Genuine Warden may purchase at its private trainer")
    check(not Trainers.can_offer(
        "OathguardTrainer", owner, "OathguardShieldMastery"
    ).ok, "Warden cannot borrow Human Knight trainer")
end

--[[
Purchases every rank using the normal authoritative SP and level gates.

Args:
    profiles (any): Actual owner profile writer.
    service (any): Real SkillProgressionService rank-purchase authority.
    family (any): Separate source family and exact level schedule.

Returns:
    nil: Verifies every rank, no skipped levels, and no free final rank.
]]
local function purchase_family(
    profiles: any, service: any, family: any
)
    local definition = assert(Definitions.get(family.Id))
    check(definition.MaxRank == #family.Levels
        and Classes.can_teach(CAREER_ID, family.Id)
        and not Classes.can_teach("Oathguard", family.Id),
        "Warden passive must have its own trained source ranks")
    check(profiles:mutate(OWNER_ID, function(profile: any)
        profile.Characters.Slot1.Level = 20
    end), "Training bracket resets before each family")
    local initial = assert(profiles:get_character(OWNER_ID))
    if family.Levels[#family.Levels] > 20 then
        check(not SkillRules.can_train(
            initial, definition, definition.MaxRank
        ), "Level-20 owner cannot skip a higher-rank bracket")
    end
    for rank, level in ipairs(family.Levels) do
        check(profiles:mutate(OWNER_ID, function(profile: any)
            local owner = profile.Characters.Slot1
            owner.Level = level
            local state = owner.Progression.Skills[family.Id]
            if state then
                state.Proficiency = definition.RankThresholds
                    and definition.RankThresholds[rank] or 0
            end
        end), "Owner reaches the exact purchase level")
        local outcome = if rank == 1
            then service:learn_trainer_skill(OWNER_ID, family.Id)
            else service:purchase_rank(OWNER_ID, family.Id)
        check(outcome.ok and outcome.rank == rank,
            "Real service purchases each Warden rank "
                .. family.Id .. ":" .. tostring(rank))
    end
    local owned = assert(profiles:get_character(OWNER_ID))
    check(owned.Progression.Skills[family.Id].PurchasedRank
        == #family.Levels, "Every paid source rank remains owned")
    check(not service:purchase_rank(OWNER_ID, family.Id).ok,
        "No rank after the authored level-30 maximum")
end

--[[
Checks real weapon and armour equipment gates on purchased passives.

Args:
    profiles (any): Genuine owned and previously trained profile.
    equipment (any): Authoritative Base equipment transaction service.

Returns:
    nil: Weapon and armour effects require correct actual equipped items.
]]
local function verify_equipment(
    profiles: any, equipment: any
)
    local owner = assert(profiles:get_character(OWNER_ID))
    check(Passives.damage_bonus(
        owner, "GreenwardWardenSteelTraining"
    ) == 0 and Passives.fighter_armor_reduction(owner) == 0,
        "No unarmed damage or naked heavy-armour mastery is granted")
    local inventory = Inventory.new(profiles)
    check(inventory:add_item(OWNER_ID, "scout_dagger").ok,
        "Fixture owner receives one genuine dagger")
    check(inventory:add_item(OWNER_ID, "marauder_sword").ok,
        "Fixture owner receives one genuine sword")
    check(inventory:add_item(OWNER_ID, "marauder_shield").ok,
        "Fixture owner receives a real registered shield")
    check(inventory:add_item(OWNER_ID, "marauder_armor").ok,
        "Fixture owner receives one genuine heavy Body item")
    check(equipment:equip(
        OWNER_ID, "scout_dagger", "Weapon"
    ).ok, "Dagger equips through the actual service")
    owner = assert(profiles:get_character(OWNER_ID))
    check(Passives.damage_bonus(
        owner, "GreenwardWardenSteelTraining"
    ) == 0, "A dagger with borrowed sword animation is not a sword")
    check(equipment:equip(
        OWNER_ID, "marauder_sword", "Weapon"
    ).ok, "Actual sword equips")
    check(equipment:equip(
        OWNER_ID, "marauder_armor", "Body"
    ).ok, "Actual heavy armour equips")
    check(equipment:equip(
        OWNER_ID, "marauder_shield", "OffHand"
    ).ok, "Actual one-handed sword and shield pairing is allowed")
    owner = assert(profiles:get_character(OWNER_ID))
    check(Passives.damage_bonus(
        owner, "GreenwardWardenSteelTraining"
    ) > 0 and Passives.fighter_armor_reduction(owner) > 0,
        "Correct equipped categories activate purchased mastery")
    Runtime.set_character(OWNER_ID, owner)
    check(Passives.greenward_warden_shield_reduction(owner) > 0,
        "A legitimate equipped shield activates paid Warden mastery")
    check(Runtime.get_physical_multiplier(OWNER_ID) > 1
        and Runtime.get_fighter_armor_reduction(OWNER_ID) > 0
        and Runtime.get_greenward_warden_magic_reduction(OWNER_ID) > 0,
        "Earned masteries feed actual server damage/defence state")
    check(equipment:unequip(OWNER_ID, "Body").ok,
        "Heavy Body can be removed independently")
    owner = assert(profiles:get_character(OWNER_ID))
    check(Passives.fighter_armor_reduction(owner) == 0,
        "Removing heavy Body immediately disables armour mastery")
    Runtime.clear_character(OWNER_ID)
end

--[[
Tests real material-consuming paid crafting at the chosen Warden station.

Args:
    profiles (any): Earned Warden's isolated profile and purchased ranks.

Returns:
    nil: Produces real owned equipment without extra profession slots.
]]
local function verify_crafting(profiles: any)
    local owner = assert(profiles:get_character(OWNER_ID))
    check(CraftRules.can_make_warden_common(
        owner, "Blacksmithing", 1
    ) and CraftRules.can_make_warden_common(
        owner, "Blacksmithing", 2
    ), "Both real paid Elven Knight creation tiers are owned")
    check(not CraftRules.can_make_warden_common(
        owner, "Leatherworking", 1
    ), "Unchosen craft career must not unlock through Warden ranks")
    local inventory = Inventory.new(profiles)
    check(inventory:add_item(OWNER_ID, "iron_bar", 8).ok
        and inventory:add_item(OWNER_ID, "forging_flux", 2).ok
        and inventory:add_item(OWNER_ID, "cured_leather", 1).ok
        and inventory:add_item(OWNER_ID, "warding_rune", 1).ok,
        "Test-only materials belong to one exclusive owner")
    local service = Professions.new(profiles, inventory)
    local weapon = "warden_forge_weapon_rank_1"
    local armour = "warden_forge_armor_rank_2"
    check(service:prepare_craft(OWNER_ID, weapon).ok,
        "Paid class owner can prepare the registered Warden recipe")
    check(not service:prepare_craft(
        OWNER_ID, "knight_forge_armor_rank_2"
    ).ok, "Warden cannot use a Human Knight recipe")
    check(service:craft(OWNER_ID, weapon).ok
        and service:craft(OWNER_ID, weapon).ok,
        "Real two material-consuming crafts grant chosen profession XP")
    owner = assert(profiles:get_character(OWNER_ID))
    check(Inventory.count_item(
        owner, "greenward_training_mace"
    ) == 2, "Two real crafts produce two Elven Knight weapons")
    check(service:craft(OWNER_ID, armour).ok,
        "Paid rank-two craft consumes actual cross-profession inputs")
    owner = assert(profiles:get_character(OWNER_ID))
    check(Inventory.count_item(
        owner, "greenward_d_grade_armor"
    ) == 1, "Warden high-tier recipe produces owned D-grade armour")
    check(owner.ProfessionSlots.Creation == "Blacksmithing",
        "Warden common creation does not grant a second profession")
end

--[[
Checks a copied purchase cannot grant real cross-class combat bonuses.

Args:
    profiles (any): Genuine earned class from which a forged copy is made.

Returns:
    nil: Forged current class, wrong race and missing receipt gain nothing.
]]
local function verify_forgeries(profiles: any)
    local owner = assert(profiles:get_character(OWNER_ID))
    local forged = Schema.deep_clone(owner)
    forged.Identity.ClassId = "Fighter"
    check(Passives.damage_bonus(
        forged, "GreenwardWardenSteelTraining"
    ) == 0 and Passives.greenward_warden_magic_reduction(forged) == 0,
        "Class-ID forgery cannot activate Warden passive skills")
    forged = Schema.deep_clone(owner)
    forged.ClassAdvancement.OriginalFirstTransferReceiptId = nil
    check(Passives.greenward_warden_magic_reduction(forged) == 0,
        "Missing mentor receipt cannot grant magic mitigation")
    forged = Schema.deep_clone(owner)
    forged.Identity.RaceId = "Human"
    check(Passives.greenward_warden_magic_reduction(forged) == 0,
        "Copied Human cannot activate original Elven Knight skills")
    check(profiles:save(OWNER_ID, "GreenwardWardenPassiveFocus"),
        "Every independently bought rank persists in the owner profile")
end

--[[
Runs one owner through a real class award and three real passive trainers.

Args:
    None.

Returns:
    nil: Prints an assertion count only after all checks succeed.
]]
local function main()
    local profiles = Profiles.new(Adapter.new())
    seed_owner(profiles)
    earn_class(profiles)
    local skills = Skills.new(
        profiles, Inventory.new(profiles), Loadout.new(profiles)
    )
    for _, family in ipairs(FAMILIES) do
        purchase_family(profiles, skills, family)
    end
    local audit = assert(Coverage.for_branch(BRANCH_ID))
    check(audit.TrainerMappedRankEntries == 55
        and audit.MissingRankScheduleEntries == 1
        and not audit.LaunchSkillCatalogueReady,
        "No incomplete Warden source family becomes release-certified")
    verify_equipment(profiles, Equipment.new(profiles, "Base"))
    verify_crafting(profiles)
    verify_forgeries(profiles)
    print(("[Greenward Warden Passives] PASS: %d assertions")
        :format(assertions))
end

main()
