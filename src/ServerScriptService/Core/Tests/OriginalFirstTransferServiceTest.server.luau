--!strict
-- Isolated original class-award, trainer gate and saved identity regression.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared
local Services = SSS.Core.Services
local Adapter = require(SSS.Core.Adapters.InMemoryProfileAdapter)
local Profiles = require(Services.ProfileService)
local Migration = require(Services.ProfileMigration)
local Schema = require(Shared.ProfileSchema)
local FirstTransfers = require(Shared.OriginalFirstTransferDefinitions)
local Sources = require(Shared.C4OriginalFirstTransferQuestStages)
local Transfers = require(Services.OriginalFirstTransferService)
local IdentityRules = require(Shared.CharacterIdentityRules)
local SkillRules = require(Shared.SkillUnlockRules)
local Skills = require(Shared.SkillProgressionDefinitions)
local Catalogues = require(Shared.TrainerCatalogues)
local Classes = require(Shared.ClassProgressionDefinitions)
local Inventory = require(Services.InventoryService)
local Loadout = require(Services.LoadoutService)
local SkillService = require(Services.SkillProgressionService)
local Combat = require(RS.Combat.Shared.SkillDefinitions)
local Runtime = require(Services.ProgressionRuntimeState)
local SourceInventory = require(Shared.C4ScoutSkillInventory)
local SkillMap = require(Shared.C4Level30ClassSkillMap)
local LaunchAudit = require(Shared.C4Level30LaunchCoverage)

local assertions = 0
local OWNERS = table.freeze({
    {UserId = 95711, RaceId = "Human", BranchId = "HumanRogue"},
    {UserId = 95712, RaceId = "Elf", BranchId = "ElvenScout"},
})

--[[
Checks a single server-side transfer, persistence or skill gate.

Args:
    condition (boolean): Observed result of the real service contract.
    label (string): Specific class and trainer invariant expected.

Returns:
    nil: Raises on failure and counts each executed assertion.
]]
local function check(condition: boolean, label: string)
    assertions += 1
    assert(condition, "[Original First Transfer] " .. label)
end

--[[
Prepares only a completed source quest; does not mint an advanced class.

Args:
    profiles (any): Actual isolated server-side character writer.
    owner (any): Race, branch and owner identifier for this case.

Returns:
    nil: Leaves Fighter at level 18 with independently saved quest proof.
]]
local function seed_source(profiles: any, owner: any)
    check(profiles:load(owner.UserId) ~= nil, "Profile loads")
    local source = assert(Sources.get(owner.BranchId))
    check(profiles:mutate(owner.UserId, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = 18
        character.Identity = {
            Version = 1, RaceId = owner.RaceId,
            BaseClassId = "Fighter",
            ClassId = "Fighter",
            CreationStage = "Complete",
        }
        local proof = {}
        for _, id in ipairs(source.RequiredProofIds) do
            proof[id] = true
        end
        character.ClassAdvancement = {
            Version = 1,
            CompletedByRace = {},
            OriginalFirstTransferChoiceId = owner.BranchId,
            OriginalFirstTransferQuest = {
                QuestId = source.Id,
                BranchId = owner.BranchId,
                Step = #source.Steps + 1,
                Count = 0,
                Ready = true,
                AppliedEvents = {},
                Proofs = proof,
            },
        }
    end), "Stage-complete source does not automatically award a class")
end

--[[
Creates an exact one-use, server-owned world proof for two mentor actors.

Args:
    None.

Returns:
    (any, any): One-use physical-proof fixture and approved event setter.
]]
local function mentor_world(): (any, any)
    local pending = {}
    local world = {}
    function world:available(_definition: any): boolean
        return true
    end
    function world:verify(
        user_id: number, event: any, definition: any
    ): boolean
        local receipt = pending[user_id]
        pending[user_id] = nil
        return receipt ~= nil and receipt == event
            and receipt.ActorUserId == user_id
            and receipt.TargetId == definition.MentorId
            and receipt.Kind == "OriginalFirstTransfer"
    end
    return world, pending
end

--[[
Verifies rejection of premature, cross-race and forged mentor claims.

Args:
    profiles (any): Actual isolated writer and saved quest owner.
    transfer (any): Source-of-truth level-20 service.
    owner (any): Selected race and first-transfer branch definition.
    pending (any): Private world-binder event receipts.

Returns:
    nil: Checks that each rejected attempt left Fighter unchanged.
]]
local function verify_denials(
    profiles: any, transfer: any, owner: any, pending: any
)
    local definition = assert(
        FirstTransfers.for_branch(owner.BranchId)
    )
    local counterfeit = {
        ActorUserId = owner.UserId,
        Kind = "OriginalFirstTransfer",
        TargetId = definition.MentorId,
        EventId = "Counterfeit" .. tostring(owner.UserId),
    }
    check(transfer:claim(owner.UserId, counterfeit).reason
        == "OriginalTransferLevelTooLow",
        "An earned source quest at level 18 is not a class award")
    check(profiles:mutate(owner.UserId, function(profile: any)
        profile.Characters.Slot1.Level = 20
    end), "Reach actual first-transfer level")
    check(transfer:claim(owner.UserId, counterfeit).reason
        == "TransferMentorProofRequired",
        "Client-shaped receipt cannot replace a real world mentor")
    local wrong = if owner.BranchId == "HumanRogue"
        then "ElvenScout" else "HumanRogue"
    check(FirstTransfers.can_transfer(
        profiles:get_character(owner.UserId), wrong
    ) == false,
        "A different race or branch cannot claim this character")
    local owner_character = profiles:get_character(owner.UserId)
    check(owner_character.Identity.ClassId == "Fighter"
        and owner_character.ClassAdvancement
            .OriginalFirstTransferClassId == nil,
        "Rejected claims never update the persistent class identity")
    check(not SkillRules.can_show(
        owner_character, assert(Skills.get(definition.SkillId))
    ), "Unawarded Fighter cannot see its advanced class ability")
    check(not Catalogues.resolve_for_character(
        definition.TrainerId, owner_character
    ).ok, "Unawarded Fighter cannot use the first-transfer trainer")
    pending[owner.UserId] = nil
end

--[[
Awards a genuine class once and verifies trainer, identity and save/reload.

Args:
    profiles (any): Real writer before handoff.
    transfer (any): Actual atomic original class-award service.
    owner (any): Isolated Human or Elf first-transfer quest owner.
    pending (any): Only server-owned one-use physical mentor evidence.

Returns:
    nil: Leaves one awarded identity, correct skill and exact stored proof.
]]
local function verify_award(
    profiles: any, transfer: any, owner: any, pending: any
)
    local definition = assert(
        FirstTransfers.for_branch(owner.BranchId)
    )
    local event = {
        ActorUserId = owner.UserId,
        Kind = "OriginalFirstTransfer",
        TargetId = definition.MentorId,
        EventId = "ServerMentor:" .. tostring(owner.UserId),
    }
    pending[owner.UserId] = event
    local awarded = transfer:claim(owner.UserId, event)
    check(awarded.ok and awarded.class_id == definition.Id,
        "Authenticated mentor awards exactly the chosen original class")
    local character = profiles:get_character(owner.UserId)
    check(character.Identity.BaseClassId == "Fighter"
        and character.Identity.ClassId == definition.Id
        and character.ClassAdvancement.OriginalFirstTransferClassId
            == definition.Id,
        "Actual current ClassId advances without rewriting its Fighter base")
    check(IdentityRules.is_complete(character)
        and FirstTransfers.awarded(character) == definition,
        "Earned character identity and saved mentor receipt agree")
    check(transfer:claim(owner.UserId, event).reason
        == "OriginalTransferAlreadyCompleted",
        "Replayed physical mentor event cannot award a second transfer")
    local skill = assert(Skills.get(definition.SkillId))
    check(SkillRules.can_train(character, skill, 1)
        and SkillRules.can_show(character, skill),
        "Only earned first-transfer character unlocks its level-20 skill")
    check(Classes.can_teach(definition.Id, definition.SkillId),
        "Original class teaches its own implemented skill, not legacy class")
    check(Catalogues.can_offer(
        definition.TrainerId, character, definition.SkillId
    ).ok, "Matching advanced trainer offers only the earned class skill")
    local other = if owner.BranchId == "HumanRogue"
        then FirstTransfers.for_branch("ElvenScout")
        else FirstTransfers.for_branch("HumanRogue")
    check(not Catalogues.resolve_for_character(
        other.TrainerId, character
    ).ok, "A wrong-race first-transfer trainer must reject the owner")
    check(profiles:save(owner.UserId, "OriginalFirstTransferTest"),
        "Actual awarded identity and receipt survive profile save")
end

--[[
Verifies two additional actual combat effects with purchase and mastery.

Args:
    profiles (any): Real test ProfileService and owner state.
    owner (any): The already awarded Human/Elf first-transfer owner.

Returns:
    nil: Checks both level/rank restrictions and persistent bought rank.
]]
local function verify_next_skill(profiles: any, owner: any)
    local definition = assert(FirstTransfers.for_branch(owner.BranchId))
    local skill_id = if owner.RaceId == "Human"
        then "AshenbladeOpening" else "GreenwardRenewal"
    local prerequisite = if owner.RaceId == "Human"
        then "FighterDaggerStrike" else "ElvenFighterRenewal"
    local required_rank = if owner.RaceId == "Human" then 3 else 1
    local required_proficiency = if owner.RaceId == "Human"
        then 80 else 30
    local skill_definition = assert(Skills.get(skill_id))
    local service = SkillService.new(
        profiles, Inventory.new(profiles), Loadout.new(profiles)
    )
    local owner_before = profiles:get_character(owner.UserId)
    check(not SkillRules.can_show(owner_before, skill_definition),
        "Level-24 advanced ability is invisible at level twenty")
    check(not service:learn_trainer_skill(owner.UserId, skill_id).ok,
        "Level-20 character cannot buy a level-24 class skill")
    check(profiles:mutate(owner.UserId, function(profile: any)
        profile.Characters.Slot1.Level = 24
        profile.Characters.Slot1.Progression.SkillPointEntitlement = 1000
    end), "Test character reaches next real level bracket")
    check(not SkillRules.can_show(
        profiles:get_character(owner.UserId), skill_definition
    ), "Missing earned starter mastery must hide advanced ability")
    check(profiles:mutate(owner.UserId, function(profile: any)
        profile.Characters.Slot1.Progression.Skills[prerequisite] = {
            Known = true, PurchasedRank = required_rank,
            Proficiency = required_proficiency - 1,
        }
    end), "Test fixture seeds purchased starter ranks only")
    check(not service:learn_trainer_skill(owner.UserId, skill_id).ok,
        "Advanced training must refuse missing use proficiency")
    check(profiles:mutate(owner.UserId, function(profile: any)
        profile.Characters.Slot1.Progression.Skills[
            prerequisite
        ].Proficiency = required_proficiency
    end), "Test fixture reaches earned mastery threshold")
    local owner_ready = profiles:get_character(owner.UserId)
    check(SkillRules.can_show(owner_ready, skill_definition)
        and Catalogues.can_offer(
            definition.TrainerId, owner_ready, skill_id
        ).ok, "Only the correct earned career may train its new skill")
    local learned = service:learn_trainer_skill(owner.UserId, skill_id)
    check(learned.ok and learned.rank == 1,
        "Real skill service must purchase level-24 first rank")
    local first = assert(Combat.get_for_rank(skill_id, 1))
    local second = assert(Combat.get_for_rank(skill_id, 2))
    local attribute = if owner.RaceId == "Human"
        then "BASE_DAMAGE" else "TOTAL_HEAL"
    check(first[attribute] < second[attribute],
        "Bought second rank must have a stronger real combat effect")
    check(not service:purchase_rank(owner.UserId, skill_id).ok,
        "Level-24 advanced rank cannot skip level-28 requirement")
    check(profiles:mutate(owner.UserId, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = 28
        character.Progression.Skills[skill_id].Proficiency = 79
    end), "Test fixture prepares level-28 skill-use threshold")
    check(not service:purchase_rank(owner.UserId, skill_id).ok,
        "Rank-two purchase must reject incomplete use proficiency")
    check(profiles:mutate(owner.UserId, function(profile: any)
        profile.Characters.Slot1.Progression.Skills[
            skill_id
        ].Proficiency = 80
    end), "Test fixture completes rank-two mastery")
    check(service:purchase_rank(owner.UserId, skill_id).rank == 2,
        "Real trainer service must purchase stronger second rank")
    check(profiles:get_character(owner.UserId).Progression.Skills[
        skill_id
    ].PurchasedRank == 2, "Actual advanced ability rank is saved")
    check(profiles:save(owner.UserId, "OriginalClassSkillTest"),
        "New purchased advanced skill and class identity both save")
end

--[[
Raises purchased starter mastery only in this disposable owner fixture.

Args:
    profiles (any): Current real ProfileService test writer.
    user_id (number): Actual isolated profile owner.

Returns:
    nil: Enables earned career tests without granting free production ranks.
]]
local function seed_first_transfer_mastery(
    profiles: any, user_id: number
)
    check(profiles:mutate(user_id, function(profile: any)
        local progression = profile.Characters.Slot1.Progression
        progression.SkillPointEntitlement = 3000
        for _, skill_id in ipairs({
            "FighterBowShot", "FighterDaggerStrike",
        }) do
            progression.Skills[skill_id] = {
                Known = true, PurchasedRank = 9, Proficiency = 320,
            }
        end
    end), "Mastered actual starter bow and dagger prerequisites")
end

--[[
Purchases each original-class skill rank in its exact C4 level bracket.

Args:
    profiles (any): Actual profile store used by the skill service.
    service (any): Authoritative rank purchase and SP deduction service.
    user_id (number): Selected original class owner.
    skill_id (string): One of the four new exclusively earned skills.
    rank_levels ({number}): Complete level-20/24/28 rank schedule.

Returns:
    nil: Verifies every separately earned class rank and level restriction.
]]
local function purchase_launch_line(
    profiles: any, service: any, user_id: number,
    skill_id: string, rank_levels: {number}
)
    local definition = assert(Skills.get(skill_id))
    local character = assert(profiles:get_character(user_id))
    check(Classes.can_teach(character.Identity.ClassId, skill_id)
        and Catalogues.can_offer(
            if character.Identity.ClassId == "Ashenblade"
                then "AshenbladeTrainer" else "GreenwardScoutTrainer",
            character, skill_id
        ).ok, "Only the real awarded class trainer offers this line")
    for rank, required_level in ipairs(rank_levels) do
        check(profiles:mutate(user_id, function(profile: any)
            local owner = profile.Characters.Slot1
            owner.Level = required_level
            local current = owner.Progression.Skills[skill_id]
            if current then
                current.Proficiency =
                    definition.RankThresholds[rank] or 0
            end
        end), "Test owner reaches this specific rank's own bracket")
        local outcome = if rank == 1
            then service:learn_trainer_skill(user_id, skill_id)
            else service:purchase_rank(user_id, skill_id)
        check(outcome.ok and outcome.rank == rank,
            "Actual trainer must purchase every separate source-rank "
                .. skill_id .. " " .. tostring(rank))
    end
    local current = profiles:get_character(user_id)
    check(current.Progression.Skills[skill_id].PurchasedRank
        == #rank_levels, "Full through-cap skill rank remains in profile")
    check(not service:purchase_rank(user_id, skill_id).ok,
        "No unregistered post-launch rank can be purchased")
end

--[[
Tests both original careers' weapon skills and applied combat masteries.

Args:
    profiles (any): Existing already awarded real profile writer.
    owner (any): Correct Human or Elf test character identity.

Returns:
    nil: Proves all 31 distinct training ranks and real damage effects.
]]
local function verify_weapon_skill_catalogue(
    profiles: any, owner: any
)
    seed_first_transfer_mastery(profiles, owner.UserId)
    local service = SkillService.new(
        profiles, Inventory.new(profiles), Loadout.new(profiles)
    )
    local nine = {20, 20, 20, 24, 24, 24, 28, 28, 28}
    local four = {20, 24, 28, 28}
    purchase_launch_line(
        profiles, service, owner.UserId, "WayfinderArrow", nine
    )
    purchase_launch_line(
        profiles, service, owner.UserId, "WayfinderCut", nine
    )
    local base = assert(profiles:get_character(owner.UserId))
    Runtime.set_character(owner.UserId, base)
    local initial_bow =
        Runtime.get_ranged_physical_multiplier(owner.UserId)
    local initial_dagger =
        Runtime.get_physical_multiplier(owner.UserId)
    purchase_launch_line(
        profiles, service, owner.UserId, "WayfinderBowMastery", nine
    )
    purchase_launch_line(
        profiles, service, owner.UserId, "WayfinderDaggerMastery", four
    )
    local trained = assert(profiles:get_character(owner.UserId))
    Runtime.set_character(owner.UserId, trained)
    check(Runtime.get_ranged_physical_multiplier(owner.UserId)
        > initial_bow, "Bow mastery increases actual server ranged damage")
    check(Runtime.get_physical_multiplier(owner.UserId)
        > initial_dagger, "Dagger mastery increases actual melee damage")
    check(Combat.get_for_rank("WayfinderArrow", 9).BASE_DAMAGE
        > Combat.get_for_rank("WayfinderArrow", 1).BASE_DAMAGE
        and Combat.get_for_rank("WayfinderCut", 9).BASE_DAMAGE
            > Combat.get_for_rank("WayfinderCut", 1).BASE_DAMAGE,
        "Both new nine-rank attacks scale actual server damage")
    Runtime.clear_character(owner.UserId)
    check(profiles:save(owner.UserId, "OriginalWeaponCatalogueTest"),
        "Separate learned attack and mastery rank state persists")
end

--[[
Prepares only a disposable crafting slot and its mastered starter literacy.

Args:
    profiles (any): Exclusive profile writer in the isolated Studio test.
    user_id (number): Already awarded first-transfer character owner.

Returns:
    nil: Tests that crafting choices remain required for source utility.
]]
local function seed_crafting_choice(profiles: any, user_id: number)
    check(profiles:mutate(user_id, function(profile: any)
        local owner = profile.Characters.Slot1
        owner.ProfessionSlots.Creation = "Blacksmithing"
        owner.Progression.SkillPointEntitlement = 3000
        owner.Progression.Skills.C4RecipeReading = {
            Known = true, PurchasedRank = 1, Proficiency = 0,
        }
    end), "Test-only Blacksmithing selection and recipe literacy accepted")
end

--[[
Buys every verified source-rank family via real SkillProgressionService.

Args:
    profiles (any): Actual original test character profile writer.
    service (any): Genuine class- and SP-gated purchase authority.
    user_id (number): Current selected owner of one original career.
    skill_id (string): Explicit source-mapped authored DungeonMMO skill.

Returns:
    nil: Verifies all capped rank purchases, no invented level-32 grants.
]]
local function purchase_source_family(
    profiles: any, service: any, user_id: number, skill_id: string
)
    local definition = assert(Skills.get(skill_id))
    local max_rank = 0
    for rank, required in pairs(definition.RankLevels or {}) do
        if required <= 30 then max_rank = math.max(max_rank, rank) end
    end
    local current = profiles:get_character(user_id)
        .Progression.Skills[skill_id]
    local first = if current and current.Known
        then current.PurchasedRank else 0
    for rank = first + 1, max_rank do
        check(profiles:mutate(user_id, function(profile: any)
            local owner = profile.Characters.Slot1
            owner.Level = definition.RankLevels[rank]
            local known = owner.Progression.Skills[skill_id]
            if known then
                known.Proficiency =
                    (definition.RankThresholds or {})[rank] or 0
            end
        end), "Prepared only this rank's exact character level")
        local purchased = if rank == 1
            then service:learn_trainer_skill(user_id, skill_id)
            else service:purchase_rank(user_id, skill_id)
        check(purchased.ok and purchased.rank == rank,
            "Source family could not purchase own correctly gated rank "
                .. skill_id .. ":" .. tostring(rank))
    end
    check(profiles:get_character(user_id).Progression.Skills[
        skill_id
    ].PurchasedRank == max_rank,
        "Capped source family retains exactly its purchased rank")
end

--[[
Exercises every first-transfer source family against the actual skill store.

Args:
    profiles (any): Authenticated first-transfer profile writer.
    owner (any): Human/Elf source quest branch with earned level-20 class.

Returns:
    nil: Buys unique categories without pretending to test every effect.
]]
local function verify_source_skill_purchases(
    profiles: any, owner: any
)
    seed_crafting_choice(profiles, owner.UserId)
    local service = SkillService.new(
        profiles, Inventory.new(profiles), Loadout.new(profiles)
    )
    local source = assert(SourceInventory.get(owner.RaceId))
    local skills_seen = {}
    for level, categories in pairs(source.Levels) do
        if level <= 30 then
            for category in pairs(categories) do
                local skill_id = assert(
                    SkillMap.get(owner.BranchId, category)
                )
                if not skills_seen[skill_id] then
                    skills_seen[skill_id] = true
                    purchase_source_family(
                        profiles, service, owner.UserId, skill_id
                    )
                end
            end
        end
    end
    local audit = assert(LaunchAudit.for_branch(owner.BranchId))
    check(audit.TrainerMappedRankEntries
        == audit.SourceRankEntriesThroughCap
        and audit.MissingRankScheduleEntries == 0,
        "Source schedule and actual purchase tests cover all recorded ranks")
    check(profiles:mutate(owner.UserId, function(profile: any)
        profile.Characters.Slot1.Level = 28
    end), "Restore appropriate purchased first-transfer combat level")
    check(profiles:save(owner.UserId, "OriginalLevel30CatalogueTest"),
        "Entire tested source-rank catalogue survives actual profile save")
end

--[[
Checks the dungeon runtime, weapon tag and earned-class cast barriers.

Args:
    profiles (any): Real test ProfileService with purchased advanced skill.
    owner (any): The respective personally earned original career.

Returns:
    nil: Purchased abilities remain unusable with forged identity or gear.
]]
local function verify_runtime_skill(profiles: any, owner: any)
    local skill_id = if owner.RaceId == "Human"
        then "AshenbladeOpening" else "GreenwardRenewal"
    local character = profiles:get_character(owner.UserId)
    Runtime.set_character(owner.UserId, character)
    local usable, reason = Runtime.is_skill_usable(
        owner.UserId, skill_id, {}
    )
    if owner.RaceId == "Human" then
        check(not usable and reason == "WrongWeapon",
            "Ashenblade strike must require a real equipped dagger")
        check(profiles:mutate(owner.UserId, function(profile: any)
            profile.Characters.Slot1.Equipment.Weapon = "scout_dagger"
        end), "Disposable Human weapon preparation succeeded")
        character = profiles:get_character(owner.UserId)
        Runtime.set_character(owner.UserId, character)
    end
    check(Runtime.is_skill_usable(owner.UserId, skill_id, {}),
        "Real earned first-transfer ability must be usable in combat")
    local forged = Schema.deep_clone(character)
    forged.Identity.ClassId = "Fighter"
    Runtime.set_character(owner.UserId, forged)
    check(not Runtime.is_skill_usable(owner.UserId, skill_id, {}),
        "Unawarded starter cannot cast bought first-transfer skill")
    Runtime.set_character(owner.UserId, character)
    check(Runtime.is_skill_usable(owner.UserId, skill_id, {}),
        "Restoring the earned class restores its legal combat ability")
    Runtime.clear_character(owner.UserId)
    check(profiles:save(owner.UserId, "OriginalClassEquipmentTest"),
        "Actual owned dagger setup and earned advanced skills save")
end

--[[
Verifies a completely new profile cache loads exactly the earned class.

Args:
    store (any): Same persisted adapter used by original profile writer.
    owner (any): Distinct previously awarded character owner.

Returns:
    nil: Confirms award, skills, class and proof survive migration.
]]
local function verify_reload(
    store: any, owner: any, previous_writer: any
)
    check(previous_writer:forget_for_handoff(owner.UserId),
        "Saved original class safely releases its exclusive writer cache")
    local loaded = Profiles.new(store)
    check(loaded:load(owner.UserId) ~= nil,
        "Fresh profile service loads awarded transfer")
    local character = assert(loaded:get_character(owner.UserId))
    local definition = assert(
        FirstTransfers.for_branch(owner.BranchId)
    )
    check(FirstTransfers.awarded(character) == definition
        and IdentityRules.is_complete(character),
        "Migrated character retains its actual original class and receipt")
    check(character.Identity.ClassId == definition.Id
        and character.Identity.BaseClassId == "Fighter",
        "New class identity preserves original Fighter base family")
    check(SkillRules.can_train(
        character, assert(Skills.get(definition.SkillId)), 1
    ), "Reloaded earned character retains advanced trainer entitlement")
    local next_id = if owner.RaceId == "Human"
        then "AshenbladeOpening" else "GreenwardRenewal"
    check(character.Progression.Skills[next_id].PurchasedRank == 2,
        "Fresh profile retains two purchased advanced combat ranks")
end

--[[
Checks that tampering with a raw class ID alone cannot mint a transfer.

Args:
    None.

Returns:
    nil: Migrated inconsistent test save never becomes an awarded class.
]]
local function verify_forged_migration()
    local raw = Schema.create_default(99701)
    local character = raw.Characters.Slot1
    character.Identity = {
        Version = 1, RaceId = "Human",
        BaseClassId = "Fighter", ClassId = "Ashenblade",
        CreationStage = "Complete",
    }
    character.Level = 20
    local migrated = Migration.migrate(raw).Characters.Slot1
    check(FirstTransfers.awarded(migrated) == nil
        and migrated.Identity.ClassId ~= "Ashenblade",
        "Unbacked raw ClassId is not a valid transferred character")
end

--[[
Runs distinct Human and Elf class award, replay and migration checks.

Args:
    None.

Returns:
    nil: Prints only assertions verified by the actual focused Studio test.
]]
local function main()
    local store = Adapter.new()
    local profiles = Profiles.new(store)
    local world, pending = mentor_world()
    local transfer = Transfers.new(profiles, "Base", world)
    for _, owner in ipairs(OWNERS) do
        seed_source(profiles, owner)
        verify_denials(profiles, transfer, owner, pending)
        verify_award(profiles, transfer, owner, pending)
        verify_next_skill(profiles, owner)
        verify_weapon_skill_catalogue(profiles, owner)
        verify_source_skill_purchases(profiles, owner)
        verify_runtime_skill(profiles, owner)
        verify_reload(store, owner, profiles)
    end
    verify_forged_migration()
    print(("[Original First Transfer] PASS: %d assertions")
        :format(assertions))
end

main()
