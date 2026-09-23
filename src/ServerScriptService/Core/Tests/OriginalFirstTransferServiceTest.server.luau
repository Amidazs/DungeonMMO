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
        verify_reload(store, owner, profiles)
    end
    verify_forged_migration()
    print(("[Original First Transfer] PASS: %d assertions")
        :format(assertions))
end

main()
