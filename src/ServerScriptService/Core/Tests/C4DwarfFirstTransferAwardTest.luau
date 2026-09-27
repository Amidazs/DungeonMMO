--!strict
-- End-to-end saved Dwarf first-transfer award and capacity regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared
local Core = ServerScriptService.Core

local Adapter = require(Core.Adapters.InMemoryProfileAdapter)
local Profiles = require(Core.Services.ProfileService)
local Transfers = require(Core.Services.OriginalFirstTransferService)
local FirstTransfers = require(Shared.OriginalFirstTransferDefinitions)
local Stages = require(Shared.C4OriginalFirstTransferQuestStages)
local ProfessionRules = require(Shared.ProfessionSelectionRules)
local Trainers = require(Shared.TrainerCatalogues)

local checks = 0

local CASES = table.freeze({
    table.freeze({
        UserId = 956230,
        BranchId = "DwarfArtisan",
        ClassId = "Gearwright",
        Gathering = 1,
        Creation = 2,
    }),
    table.freeze({
        UserId = 956231,
        BranchId = "DwarfScavenger",
        ClassId = "Deepclaimer",
        Gathering = 2,
        Creation = 1,
    }),
})

--[[
Counts one Dwarf transfer assertion.

Args:
    valid (boolean): Expected server-owned transfer condition.
    label (string): Diagnostic description for failure.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[Dwarf First Transfer Award] " .. label)
end

--[[
Seeds one fully completed personal Dwarf transfer quest without class award.

Args:
    profiles (any): Exclusive in-memory profile writer.
    case (any): Dwarf branch and user fixture.

Returns:
    nil: Persists a ready quest while leaving ClassId as Fighter.
]]
local function seed_ready_quest(profiles: any, case: any)
    local quest = assert(Stages.get(case.BranchId))

    check(profiles:load(case.UserId), case.BranchId .. " profile loads")
    check(profiles:mutate(case.UserId, function(profile: any)
        local character = profile.Characters.Slot1
        local proofs = {}

        for _, proof_id in ipairs(quest.RequiredProofIds) do
            proofs[proof_id] = true
        end

        character.Level = 20
        character.Identity = {
            Version = 1,
            CreationStage = "Complete",
            RaceId = "Dwarf",
            BaseClassId = "Fighter",
            ClassId = "Fighter",
        }
        character.ClassAdvancement = {
            Version = 1,
            CompletedByRace = {},
            ActiveClassId = nil,
            OriginalFirstTransferChoiceId = case.BranchId,
            OriginalFirstTransferQuest = {
                QuestId = quest.Id,
                BranchId = case.BranchId,
                Step = #quest.Steps + 1,
                Count = 0,
                Ready = true,
                AppliedEvents = {},
                Proofs = proofs,
            },
        }
    end), case.BranchId .. " ready quest saves")
end

--[[
Creates one-use mentor evidence authority for both Dwarf careers.

Args:
    None.

Returns:
    any: Fake server-only physical mentor verifier.
    any: Mutable pending receipt table.
]]
local function mentor_world(): (any, any)
    local pending = {}
    local world = {}

    function world:available(_definition: any): boolean
        return true
    end

    function world:verify(
        user_id: number,
        event: any,
        definition: any
    ): boolean
        local receipt = pending[user_id]
        pending[user_id] = nil

        return receipt ~= nil
            and receipt == event
            and receipt.ActorUserId == user_id
            and receipt.Kind == "OriginalFirstTransfer"
            and receipt.TargetId == definition.MentorId
    end

    return world, pending
end

--[[
Awards and verifies one Dwarf first-transfer branch.

Args:
    profiles (any): Exclusive in-memory profile writer.
    service (any): Real first-transfer award service.
    pending (any): Fake server-only mentor receipt table.
    case (any): Dwarf branch/capacity fixture.

Returns:
    nil: Verifies class, receipt, trainer and profession capacity.
]]
local function exercise(
    profiles: any,
    service: any,
    pending: any,
    case: any
)
    seed_ready_quest(profiles, case)

    local definition = assert(
        FirstTransfers.for_branch(case.BranchId)
    )
    local before = assert(profiles:get_character(case.UserId, 1))
    local before_capacity = ProfessionRules.capacity(before)

    check(
        before.Identity.ClassId == "Fighter"
            and before_capacity.Gathering == 1
            and before_capacity.Creation == 1,
        case.BranchId .. " gains no capacity before mentor award"
    )

    local event = {
        ActorUserId = case.UserId,
        Kind = "OriginalFirstTransfer",
        TargetId = definition.MentorId,
        EventId = "DwarfMentor:" .. tostring(case.UserId),
    }
    pending[case.UserId] = event

    local awarded = service:claim(case.UserId, event)
    check(
        awarded.ok == true
            and awarded.class_id == case.ClassId,
        case.BranchId .. " awards exact Dwarf career"
    )

    local character = assert(profiles:get_character(case.UserId, 1))
    check(
        character.Identity.ClassId == case.ClassId
            and character.Identity.BaseClassId == "Fighter"
            and character.ClassAdvancement
                .OriginalFirstTransferClassId == case.ClassId
            and character.ClassAdvancement
                .OriginalFirstTransferReceiptId == event.EventId,
        case.BranchId .. " persists exact class and mentor receipt"
    )
    check(
        FirstTransfers.awarded(character) == definition,
        case.BranchId .. " passes full awarded identity verification"
    )

    local capacity = ProfessionRules.capacity(character)
    check(
        capacity.Gathering == case.Gathering
            and capacity.Creation == case.Creation,
        case.BranchId .. " activates only approved profession capacity"
    )
    check(
        Trainers.resolve_for_character(
            definition.TrainerId,
            character
        ).ok,
        case.BranchId .. " unlocks only its matching trainer"
    )

    local replay = service:claim(case.UserId, event)
    check(
        replay.ok ~= true
            and replay.reason == "OriginalTransferAlreadyCompleted",
        case.BranchId .. " cannot replay the mentor award"
    )
end

--[[
Runs both Dwarf first-transfer award chains.

Args:
    None.

Returns:
    nil: Prints a stable pass marker after both branches succeed.
]]
local function main()
    local profiles = Profiles.new(Adapter.new())
    local world, pending = mentor_world()
    local service = Transfers.new(profiles, "Base", world)

    for _, case in ipairs(CASES) do
        exercise(profiles, service, pending, case)
    end

    print(
        ("[Dwarf First Transfer Award] PASS: %d assertions")
            :format(checks)
    )
end

main()
