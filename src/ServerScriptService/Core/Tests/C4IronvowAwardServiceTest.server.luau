--!strict
-- A complete Ironroot Oath must precede a one-use physical mentor award.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared
local Sources = require(Shared.C4OriginalFirstTransferQuestStages)
local Careers = require(Shared.OriginalFirstTransferDefinitions)
local Identity = require(Shared.CharacterIdentityRules)
local Catalogues = require(Shared.TrainerCatalogues)
local Skills = require(Shared.SkillProgressionDefinitions)
local SkillRules = require(Shared.SkillUnlockRules)
local Profiles = require(SSS.Core.Services.ProfileService)
local Adapter = require(SSS.Core.Adapters.InMemoryProfileAdapter)
local Transfer = require(SSS.Core.Services.OriginalFirstTransferService)
local SkillService = require(SSS.Core.Services.SkillProgressionService)
local Inventory = require(SSS.Core.Services.InventoryService)
local Loadout = require(SSS.Core.Services.LoadoutService)

local USER_ID = 837921
local CHECKS = 0

--[[
Counts an actually verified authoritatively loaded class assertion.

Args:
    condition (boolean): Expected real profile or trainer outcome.
    label (string): Precise failure diagnostic.

Returns:
    nil: Raises for violations without granting a test-only class.
]]
local function check(condition: boolean, label: string)
    CHECKS += 1
    assert(condition, "[Ironvow Award] " .. label)
end

--[[
Creates one completed personal source quest, not an advanced class.

Args:
    profiles (any): Genuine in-memory exclusive profile authority.

Returns:
    nil: Prepares personal quest evidence for isolated mentor acceptance.
]]
local function seed_earned_source(profiles: any)
    local source = assert(Sources.get("HumanWarrior"))
    check(profiles:load(USER_ID), "Owner profile must load")
    check(profiles:mutate(USER_ID, function(profile: any)
        local owner = profile.Characters.Slot1
        owner.Level = 18
        owner.Identity = {
            Version = 1, RaceId = "Human",
            BaseClassId = "Fighter", ClassId = "Fighter",
            CreationStage = "Complete",
        }
        owner.ClassAdvancement = {
            Version = 1, CompletedByRace = {},
            OriginalFirstTransferChoiceId = source.BranchId,
            OriginalFirstTransferQuest = {
                QuestId = source.Id, BranchId = source.BranchId,
                Step = #source.Steps + 1, Count = 0, Ready = true,
                AppliedEvents = {}, Proofs = {
                    IronrootToken4 = true,
                    RidgebreakerSigil = true,
                },
            },
        }
    end), "Test owner completed both separate personal proof stages")
end

--[[
Creates an exact one-use private mentor proof validator for this owner.

Args:
    None.

Returns:
    (any, any): Server-only world verifier and pending receipt registry.
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
        local active = pending[user_id]
        pending[user_id] = nil
        return active == event and active.ActorUserId == user_id
            and active.Kind == "OriginalFirstTransfer"
            and active.TargetId == definition.MentorId
    end
    return world, pending
end

--[[
Verifies level, original proof, one-time mentor, saved class and trainer.

Args:
    profiles (any): Genuine current exclusive test profile writer.
    transfer (any): Existing server-only atomic first-class award service.
    pending (any): Single-use personally minted physical mentor receipts.

Returns:
    nil: Leaves the real selected character with earned Ironvow class.
]]
local function verify_award(
    profiles: any, transfer: any, pending: any
)
    local career = assert(Careers.for_branch("HumanWarrior"))
    local event = {
        EventId = "IronrootMentor:" .. tostring(USER_ID),
        ActorUserId = USER_ID, Kind = "OriginalFirstTransfer",
        TargetId = career.MentorId,
    }
    pending[USER_ID] = event
    check(transfer:claim(USER_ID, event).reason
        == "OriginalTransferLevelTooLow",
        "Finished source quest cannot transfer before level twenty")
    check(profiles:mutate(USER_ID, function(profile: any)
        profile.Characters.Slot1.Level = 20
    end), "Original Fighter now meets the real first-transfer level")
    check(not transfer:claim(USER_ID, {
        EventId = "ForgedMentor",
        ActorUserId = USER_ID, Kind = "OriginalFirstTransfer",
        TargetId = career.MentorId,
    }).ok, "A forged client-shaped mentor event must never award class")
    pending[USER_ID] = event
    check(transfer:claim(USER_ID, event).ok,
        "Server-only actual career mentor receipt awards Ironvow once")
    check(transfer:claim(USER_ID, event).reason
        == "OriginalTransferAlreadyCompleted",
        "Replayed physical mentor receipt never awards twice")
    local character = assert(profiles:get_character(USER_ID))
    check(Careers.awarded(character) == career
        and Identity.is_complete(character)
        and character.Identity.BaseClassId == "Fighter",
        "Exact new original class and Fighter family are persisted")
    check(Catalogues.resolve_for_character(
        career.TrainerId, character
    ).ok and SkillRules.can_show(
        character, assert(Skills.get("IronvowDrivingStrike"))
    ) == false, "New class trainer exists but precursor mastery still gates it")
    check(not Catalogues.resolve_for_character(
        "AshenbladeTrainer", character
    ).ok, "Ironvow cannot borrow a separate Scout class trainer")
end

--[[
Purchases a legitimate first Ironvow rank only with real prerequisite.

Args:
    profiles (any): Awarded character's actual skill progression writer.

Returns:
    nil: Buys and saves exactly one allowed physical mentor trainer skill.
]]
local function verify_skill_purchase(profiles: any)
    local service = SkillService.new(
        profiles, Inventory.new(profiles), Loadout.new(profiles)
    )
    check(not service:learn_trainer_skill(
        USER_ID, "IronvowDrivingStrike"
    ).ok, "New Fighter-transfer strike cannot bypass starter mastery")
    check(profiles:mutate(USER_ID, function(profile: any)
        local owner = profile.Characters.Slot1
        owner.Progression.SkillPointEntitlement = 1800
        owner.Progression.Skills.IronCleave = {
            Known = true, PurchasedRank = 9, Proficiency = 350,
        }
    end), "Disposable owner attains purchased/studied starter sword mastery")
    local result = service:learn_trainer_skill(
        USER_ID, "IronvowDrivingStrike"
    )
    check(result.ok and result.rank == 1,
        "Actual skill service sells learned level-20 Ironvow first rank")
    check(profiles:save(USER_ID, "IronvowOriginalTransfer"),
        "Earned Ironvow class and actual purchased sword rank save together")
end

--[[
Proves a fresh profile service accepts the exact earned class and rank.

Args:
    store (any): Persisted adapter shared across exclusive writer lifetimes.
    profiles (any): Current writer to hand off safely after saving.

Returns:
    nil: Class, unique mentor receipt and first skill survive reloading.
]]
local function verify_reload(store: any, profiles: any)
    check(profiles:forget_for_handoff(USER_ID),
        "Committed exclusive profile writer safely releases its cache")
    local reopened = Profiles.new(store)
    check(reopened:load(USER_ID), "Fresh writer loads class and training")
    local character = assert(reopened:get_character(USER_ID))
    check(Careers.awarded(character) == Careers.for_class("Ironvow")
        and character.Progression.Skills
            .IronvowDrivingStrike.PurchasedRank == 1,
        "Original earned class, receipt and bought first skill persist")
end

--[[
Tests the new independent Human Warrior career without a fake world claim.

Args:
    None.

Returns:
    nil: Prints only completed class-award, trainer and persistence tests.
]]
local function main()
    local store = Adapter.new()
    local profiles = Profiles.new(store)
    seed_earned_source(profiles)
    local world, pending = mentor_world()
    verify_award(
        profiles, Transfer.new(profiles, "Base", world), pending
    )
    verify_skill_purchase(profiles)
    verify_reload(store, profiles)
    print(("[Ironvow Award] PASS: %d assertions"):format(CHECKS))
end

main()
