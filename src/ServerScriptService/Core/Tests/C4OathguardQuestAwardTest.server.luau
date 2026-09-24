--!strict
-- Original Knight quest and class award via real isolated profile services.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared
local Quests = require(Shared.C4OriginalFirstTransferQuestStages)
local Careers = require(Shared.OriginalFirstTransferDefinitions)
local Identity = require(Shared.CharacterIdentityRules)
local Profiles = require(SSS.Core.Services.ProfileService)
local Adapter = require(SSS.Core.Adapters.InMemoryProfileAdapter)
local Selection = require(SSS.Core.Services.C4FirstTransferSelectionService)
local QuestService = require(
    SSS.Core.Services.C4OriginalFirstTransferQuestService
)
local Transfer = require(SSS.Core.Services.OriginalFirstTransferService)
local Inventory = require(SSS.Core.Services.InventoryService)
local SkillService = require(SSS.Core.Services.SkillProgressionService)
local Loadout = require(SSS.Core.Services.LoadoutService)
local SkillDefinitions = require(Shared.SkillProgressionDefinitions)
local PassiveEffects = require(Shared.PassiveSkillEffects)
local RuntimeState = require(
    SSS.Core.Services.ProgressionRuntimeState
)
local Schema = require(Shared.ProfileSchema)

local USER_ID = 837931
local CHECKS = 0
local QUEST = assert(Quests.get("HumanKnight"))

--[[
Checks one actual quest transaction, personal item or class denial.

Args:
    condition (boolean): Observed actual service/owner state.
    label (string): Precise regression diagnostic.

Returns:
    nil: Adds exactly one independently executed assertion.
]]
local function check(condition: boolean, label: string)
    CHECKS += 1
    assert(condition, "[Oathguard Quest] " .. label)
end

--[[
Produces an exact server-owned world-action fixture for one owner.

Args:
    stage (number): Exact current original Knight quest stage.
    count (number): Independently registered physical monster life.

Returns:
    any: Mock-world verified event, never a trusted client report.
]]
local function world_event(stage: number, count: number): any
    local step = QUEST.Steps[stage]
    return {
        Kind = step.Kind, TargetId = step.TargetId,
        EventId = "Stonewatch:" .. stage .. ":" .. count,
        ActorUserId = USER_ID, ServerVerified = true,
        MonsterReceiptId = if step.Kind == "QuestMonsterDefeat"
            then "StonewatchLife:" .. stage .. ":" .. count else nil,
        VerifiedProofIds = if stage == 3
            then {StonewatchBadge = true}
            elseif stage == 5 then {GloamBulwarkSeal = true}
            else {},
    }
end

--[[
Creates an isolated legitimate first-transfer world for this branch.

Args:
    None.

Returns:
    (any, any): Private quest verifier and one-use mentor event registry.
]]
local function trusted_world(): (any, any)
    local pending = {}
    local world = {}
    function world:available(_quest: any): boolean
        return true
    end
    function world:verify(
        user_id: number, event: any,
        _quest: any, _state: any
    ): boolean
        return event.ServerVerified == true
            and event.ActorUserId == user_id
    end
    function world:verify_mentor(
        user_id: number, event: any, career: any
    ): boolean
        local owned = pending[user_id]
        pending[user_id] = nil
        return owned == event and event.ActorUserId == user_id
            and event.TargetId == career.MentorId
    end
    return world, pending
end

--[[
Starts the real level-18 Fighter quest without ever awarding a class.

Args:
    profiles (any): Current exclusive in-memory original profile writer.
    quest_service (any): Actual source quest transaction service.

Returns:
    nil: Persists only the exact Human Knight source branch and stage one.
]]
local function start(profiles: any, quest_service: any)
    check(profiles:load(USER_ID), "Knight owner must have a loaded profile")
    check(profiles:mutate(USER_ID, function(profile: any)
        local owner = profile.Characters.Slot1
        owner.Level = 18
        owner.Identity = {
            Version = 1, RaceId = "Human",
            BaseClassId = "Fighter", ClassId = "Fighter",
            CreationStage = "Complete",
        }
    end), "Actual Human Fighter level-18 identity exists")
    check(Selection.new(profiles, "Base"):choose(
        USER_ID, "HumanKnight"
    ).ok, "Human Fighter chooses Knight branch without class award")
    check(quest_service:start(USER_ID).ok,
        "Physical first-step quest service accepts real owned branch")
    check(not quest_service:record_world_event(
        USER_ID, world_event(2, 1)
    ).ok, "Cannot skip original first officer's physical source stage")
end

--[[
Commits distinct monster receipts and personally owned quest return items.

Args:
    profiles (any): Exclusive Knight item and quest profile writer.
    quest_service (any): Real ordered source quest service.

Returns:
    nil: Verifies badge/ward seal transactions and exact stage completion.
]]
local function finish(profiles: any, quest_service: any)
    for stage = 1, 2 do
        check(quest_service:record_world_event(
            USER_ID, world_event(stage, 1)
        ).ok, "Original physical watch actor advances only its own step")
    end
    local fake = world_event(3, 1)
    fake.VerifiedProofIds = {}
    check(not quest_service:record_world_event(
        USER_ID, fake
    ).ok, "A kill without earned personal badge cannot finish a step")
    for count = 1, 3 do
        local event = world_event(3, count)
        check(quest_service:record_world_event(
            USER_ID, event
        ).ok, "Independent world life grants only its exact personal badge")
        check(not quest_service:record_world_event(
            USER_ID, event
        ).ok, "Replay cannot claim a second monster's badge")
    end
    local owner = assert(profiles:get_character(USER_ID))
    check(Inventory.count_item(owner, "stonewatch_badge") == 3
        and owner.ClassAdvancement.OriginalFirstTransferQuest
            .Proofs.StonewatchBadge3 == true,
        "Exactly three owner-bound signal badges are stored")
    check(quest_service:record_world_event(
        USER_ID, world_event(4, 1)
    ).ok, "Real quartermaster stage atomically consumes three badges")
    check(Inventory.count_item(
        profiles:get_character(USER_ID), "stonewatch_badge"
    ) == 0, "Spent source items are not retained after physical return")
    local boss = world_event(5, 1)
    boss.VerifiedProofIds = {}
    check(not quest_service:record_world_event(
        USER_ID, boss
    ).ok, "Original boss without independently earned seal is rejected")
    check(quest_service:record_world_event(
        USER_ID, world_event(5, 1)
    ).ok, "Unique boss life grants only its owner's ward seal")
    check(Inventory.count_item(
        profiles:get_character(USER_ID), "gloam_ward_seal"
    ) == 1, "Exactly one character personally owns final proof")
    check(quest_service:record_world_event(
        USER_ID, world_event(6, 1)
    ).ok, "Final physical officer consumes saved unique ward seal")
    owner = assert(profiles:get_character(USER_ID))
    local state = owner.ClassAdvancement.OriginalFirstTransferQuest
    check(state.Ready == true and state.Step == 7
        and state.Proofs.GloamBulwarkSeal == true
        and Inventory.count_item(owner, "gloam_ward_seal") == 0
        and owner.Identity.ClassId == "Fighter",
        "Full source quest saves both proofs without free class award")
end

--[[
Exercises real paid Knight shield ranks against the server equipment snapshot.

Args:
    profiles (any): In-memory quest-awarded Knight profile service.
    service (any): Genuine training and rank-purchase service.

Returns:
    nil: Checks class ownership, training, equipped gear and runtime safety.
]]
local function verify_shield_mastery(profiles: any, service: any)
    local shield_id = "OathguardShieldMastery"
    local first_shield = service:learn_trainer_skill(USER_ID, shield_id)
    check(first_shield.ok and first_shield.rank == 1,
        "Earned Knight buys its own first shield-training rank")
    local first_owned = Schema.deep_clone(assert(
        profiles:get_character(USER_ID)
    ))
    first_owned.Equipment.OffHand = "marauder_shield"
    check(math.abs(PassiveEffects.oathguard_shield_reduction(
        first_owned
    ) - 0.008) < 1e-6,
        "Only first purchased Knight shield rank gives 0.8% reduction")
    local second_shield = service:purchase_rank(USER_ID, shield_id)
    check(second_shield.ok and second_shield.rank == 2,
        "Knight separately buys the level-28 shield-training rank")
    local bare = assert(profiles:get_character(USER_ID))
    check(PassiveEffects.oathguard_shield_reduction(bare) == 0,
        "Purchased shield ranks cannot defend without real shield gear")
    check(profiles:mutate(USER_ID, function(profile: any)
        profile.Characters.Slot1.Equipment.OffHand = "marauder_shield"
    end), "Fixture equips the registered shield ID into owned snapshot")
    local shield_owner = assert(profiles:get_character(USER_ID))
    check(math.abs(PassiveEffects.oathguard_shield_reduction(
        shield_owner
    ) - 0.016) < 1e-6,
        "Two bought ranks and registered shield ID give 1.6% mitigation")
    local wrong_gear = Schema.deep_clone(shield_owner)
    wrong_gear.Equipment.OffHand = "marauder_armor"
    check(PassiveEffects.oathguard_shield_reduction(wrong_gear) == 0,
        "Body armour ID in OffHand cannot impersonate a shield")
    local unknown_gear = Schema.deep_clone(shield_owner)
    unknown_gear.Equipment.OffHand = "unknown_shield"
    check(PassiveEffects.oathguard_shield_reduction(unknown_gear) == 0,
        "Unknown offhand item is not a registered equipped shield")
    RuntimeState.set_character(USER_ID, shield_owner)
    check(math.abs(
        RuntimeState.get_oathguard_shield_reduction(USER_ID) - 0.016
    ) < 1e-6,
        "Server combat obtains only the authenticated shield mitigation")
    local copied = Schema.deep_clone(shield_owner)
    copied.Identity.ClassId = "Fighter"
    check(PassiveEffects.oathguard_shield_reduction(copied) == 0,
        "Forged class and copied ranks cannot activate shield protection")
    RuntimeState.clear_character(USER_ID)
end

--[[
Purchases a separate timed Knight guard through the earned-class trainer.

Args:
    profiles (any): Isolated quest-awarded Oathguard profile service.
    service (any): Actual authoritative trainer and skill-purchase service.

Returns:
    nil: Confirms paid Fighter armour prerequisite and saved Knight stance.
]]
local function verify_defensive_stance(profiles: any, service: any)
    local stance_id = "OathguardSteadfastStance"
    check(profiles:mutate(USER_ID, function(profile: any)
        profile.Characters.Slot1.Level = 19
    end), "Knight starts below level twenty for strict source gate")
    local denied = service:learn_trainer_skill(USER_ID, stance_id)
    check(not denied.ok,
        "Knight cannot learn C4 source stance before level twenty")
    check(profiles:mutate(USER_ID, function(profile: any)
        profile.Characters.Slot1.Level = 20
    end), "Knight reaches original C4 level-twenty stance bracket")
    local result = service:learn_trainer_skill(USER_ID, stance_id)
    check(result.ok and result.rank == 1,
        "Earned Knight's own physical trainer sells its distinct stance")
    check(profiles:get_character(USER_ID).Progression
        .Skills[stance_id].PurchasedRank == 1,
        "Purchased Knight stance persists in the authoritative profile")
end

--[[
Buys every separately ranked Knight damage-to-heal spell.

Args:
    profiles (any): Authenticated, personally quest-awarded Knight owner.
    service (any): Real class-trainer skill and rank purchase service.

Returns:
    nil: Checks level brackets, every paid rank and persisted ownership.
]]
local function verify_umbral_siphon(profiles: any, service: any)
    local skill_id = "OathguardUmbralSiphon"
    local levels = {20, 20, 24, 24, 28, 28, 28}
    for rank, level in ipairs(levels) do
        if rank == 3 or rank == 5 then
            local blocked = service:purchase_rank(USER_ID, skill_id)
            check(not blocked.ok,
                "Knight cannot buy the next drain rank before its level")
        end
        check(profiles:mutate(USER_ID, function(profile: any)
            local owner = profile.Characters.Slot1
            owner.Level = level
            owner.Progression.SkillPointEntitlement = 12000
        end), "Knight reaches the individually paid drain rank level")
        local result = if rank == 1
            then service:learn_trainer_skill(USER_ID, skill_id)
            else service:purchase_rank(USER_ID, skill_id)
        check(result.ok and result.rank == rank,
            "Earned Knight buys genuine drain rank "
                .. tostring(rank) .. " " .. tostring(result.reason))
    end
    check(profiles:get_character(USER_ID).Progression
        .Skills[skill_id].PurchasedRank == 7,
        "All seven personally purchased drain ranks persist")
end

--[[
Awards Knight only at level twenty with one-use private mentor evidence.

Args:
    profiles (any): Genuine completed Knight source profile writer.
    pending (any): Test-only server minted physical mentor event registry.

Returns:
    nil: Verifies correct class, trainer, purchased skill and fresh reload.
]]
local function award(profiles: any, pending: any)
    local career = assert(Careers.for_branch("HumanKnight"))
    local world = {
        available = function(): boolean return true end,
        verify = function(
            _self: any, user_id: number, event: any, definition: any
        ): boolean
            local approved = pending[user_id]
            pending[user_id] = nil
            return approved == event and event.ActorUserId == user_id
                and event.TargetId == definition.MentorId
        end,
    }
    local transfer = Transfer.new(profiles, "Base", world)
    local event = {
        Kind = "OriginalFirstTransfer",
        TargetId = career.MentorId, ActorUserId = USER_ID,
        EventId = "StonewatchMentorOnce",
    }
    pending[USER_ID] = event
    check(not transfer:claim(USER_ID, event).ok,
        "Completed Knight quest cannot award class at level eighteen")
    check(profiles:mutate(USER_ID, function(profile: any)
        local owner = profile.Characters.Slot1
        owner.Level = 20
        owner.Progression.SkillPointEntitlement = 1000
        owner.Progression.Skills.ShieldBash = {
            Known = true, PurchasedRank = 3, Proficiency = 0,
        }
    end), "Actual earned owner reaches level-twenty shield prerequisites")
    pending[USER_ID] = event
    check(transfer:claim(USER_ID, event).ok,
        "Authenticated one-use mentor awards actual Oathguard class")
    check(not transfer:claim(USER_ID, event).ok,
        "Original Knight mentor proof cannot be replayed")
    local owner = assert(profiles:get_character(USER_ID))
    check(Careers.awarded(owner) == career
        and Identity.is_complete(owner),
        "Full earned career receipt—not raw class name—is authoritative")
    local service = SkillService.new(
        profiles, Inventory.new(profiles), Loadout.new(profiles)
    )
    check(service:learn_trainer_skill(
        USER_ID, "OathguardShieldImpact"
    ).ok, "Actual server trainer sells an independently purchased Knight rank")
    -- This client-independent fixture tests every genuine rank purchase
    -- with prepared character levels, not a naturally earned level grind.
    local levels = {20, 20, 24, 24, 24, 28, 28, 28}
    local magic_id = "OathguardRunicResistance"
    local definition = assert(SkillDefinitions.get(magic_id))
    check(definition.MaxRank == #levels,
        "Knight rune resistance has eight separately purchasable ranks")
    for rank, level in ipairs(levels) do
        check(profiles:mutate(USER_ID, function(profile: any)
            local owner = profile.Characters.Slot1
            owner.Level = level
            owner.Progression.SkillPointEntitlement = 12000
        end), "Test Knight enters the exact earned magical rank bracket")
        local result = if rank == 1
            then service:learn_trainer_skill(USER_ID, magic_id)
            else service:purchase_rank(USER_ID, magic_id)
        check(result.ok and result.rank == rank,
            "Actual Knight trainer must purchase every separate rune "
                .. tostring(rank) .. " " .. tostring(result.reason))
    end
    local trained = assert(profiles:get_character(USER_ID))
    check(math.abs(PassiveEffects.oathguard_magic_reduction(
        trained
    ) - 0.048) < 1e-6,
        "Eight authentic paid Knight rune ranks mitigate enemy magic")
    RuntimeState.set_character(USER_ID, trained)
    check(math.abs(
        RuntimeState.get_oathguard_magic_reduction(USER_ID) - 0.048
    ) < 1e-6,
        "Live combat's actual Knight resistance uses current owner state")
    local forged = Schema.deep_clone(trained)
    forged.Identity.ClassId = "Fighter"
    check(PassiveEffects.oathguard_magic_reduction(forged) == 0,
        "A forged Fighter with copied rune ranks has no magic resistance")
    RuntimeState.clear_character(USER_ID)
    check(profiles:mutate(USER_ID, function(profile: any)
        local character = profile.Characters.Slot1
        character.Progression.Skills.FighterRestingRecovery = {
            Known = true, PurchasedRank = 1, Proficiency = 0,
        }
    end), "Earned Fighter endurance is present before advanced self-heal")
    local recovery_id = "OathguardMendingOath"
    for rank = 1, 3 do
        if rank > 1 then
            check(profiles:mutate(USER_ID, function(profile: any)
                profile.Characters.Slot1.Progression.Skills[
                    recovery_id
                ].Proficiency = if rank == 2 then 40 else 80
            end), "Actually earned rank threshold is prepared for this test")
        end
        local result = if rank == 1
            then service:learn_trainer_skill(USER_ID, recovery_id)
            else service:purchase_rank(USER_ID, recovery_id)
        check(result.ok and result.rank == rank,
            "Knight bought valid independently ranked personal recovery "
                .. tostring(rank) .. " " .. tostring(result.reason))
    end
    check(profiles:get_character(USER_ID)
        .Progression.Skills[recovery_id].PurchasedRank == 3,
        "Three source-level-28 personal recovery ranks remain purchased")
    verify_shield_mastery(profiles, service)
    verify_defensive_stance(profiles, service)
    check(profiles:mutate(USER_ID, function(profile: any)
        profile.Characters.Slot1.Level = 20
    end), "Knight first acquires drain at source level twenty")
    verify_umbral_siphon(profiles, service)
    check(profiles:save(USER_ID, "OathguardOriginalTransfer"),
        "Knight quest, rune, recovery, shield, stance and drain persist")
end

--[[
Runs real server quest and transfer operations in isolated in-memory store.

Args:
    None.

Returns:
    nil: Prints actual verification rather than implying client playtests.
]]
local function main()
    local profiles = Profiles.new(Adapter.new())
    local quest_world, pending = trusted_world()
    local quest_service = QuestService.new(
        profiles, "Base", quest_world
    )
    start(profiles, quest_service)
    finish(profiles, quest_service)
    award(profiles, pending)
    print(("[Oathguard Quest] PASS: %d assertions")
        :format(CHECKS))
end

main()
