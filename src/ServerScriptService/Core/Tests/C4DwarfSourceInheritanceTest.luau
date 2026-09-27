--!strict
-- Authenticated Dwarven Fighter inheritance for both first transfers.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Core.Shared

local Active = require(Shared.C4ActiveSourceEffectResolver)
local Passives = require(Shared.C4OwnedPassiveSourceResolver)
local Stages = require(Shared.C4OriginalFirstTransferQuestStages)
local Unified = require(Shared.C4UnifiedStatReference)

local checks = 0

local CASES = table.freeze({
    table.freeze({
        BranchId = "DwarfArtisan",
        ClassId = "Gearwright",
        OwnSkillId = "GearwrightHammerShock",
        OwnRank = 9,
        OwnSourceSkillId = 100,
        OwnSourceRank = 9,
    }),
    table.freeze({
        BranchId = "DwarfScavenger",
        ClassId = "Deepclaimer",
        OwnSkillId = "DeepclaimerSalvageMark",
        OwnRank = 2,
        OwnSourceSkillId = 254,
        OwnSourceRank = 3,
    }),
})

--[[
Counts one Dwarf source-inheritance assertion.

Args:
    valid (boolean): Expected inherited/current source condition.
    label (string): Diagnostic description for failure.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[Dwarf Source Inheritance] " .. label)
end

--[[
Builds one fully awarded level-30 Dwarf first-transfer character.

Args:
    case (any): Branch/class/source active fixture.

Returns:
    any: Detached authoritative-style character with owned ranks.
]]
local function make_character(case: any): any
    local quest = assert(Stages.get(case.BranchId))
    local proofs = {}

    for _, proof_id in ipairs(quest.RequiredProofIds) do
        proofs[proof_id] = true
    end

    return {
        Level = 30,
        Identity = {
            Version = 1,
            CreationStage = "Complete",
            RaceId = "Dwarf",
            BaseClassId = "Fighter",
            ClassId = case.ClassId,
        },
        ClassAdvancement = {
            Version = 1,
            CompletedByRace = {},
            ActiveClassId = nil,
            OriginalFirstTransferChoiceId = case.BranchId,
            OriginalFirstTransferClassId = case.ClassId,
            OriginalFirstTransferReceiptId =
                "dwarf-source-" .. case.ClassId,
            OriginalFirstTransferQuest = {
                QuestId = quest.Id,
                BranchId = case.BranchId,
                Step = #quest.Steps + 1,
                Count = 0,
                Ready = true,
                AppliedEvents = {},
                Proofs = proofs,
            },
        },
        Progression = {
            Skills = {
                DwarfWeaponTraining = {
                    Known = true,
                    PurchasedRank = 3,
                },
                DwarfSalvageMark = {
                    Known = true,
                    PurchasedRank = 1,
                },
                [case.OwnSkillId] = {
                    Known = true,
                    PurchasedRank = case.OwnRank,
                },
            },
        },
    }
end

--[[
Checks starter and branch source resolution for one Dwarf first transfer.

Args:
    case (any): Branch/class/source active fixture.

Returns:
    nil: Verifies inherited active/passive and current active source ranks.
]]
local function exercise(case: any)
    local character = make_character(case)

    local inherited_active, inherited_reason = Active.resolve(
        character,
        "DwarfSalvageMark",
        1
    )
    check(
        inherited_reason == nil
            and inherited_active ~= nil
            and inherited_active.ScopeId == "DwarvenFighter"
            and inherited_active.SkillId == 254
            and inherited_active.Rank == 1,
        case.ClassId .. " resolves inherited starter Spoil rank one"
    )

    local own_active, own_reason = Active.resolve(
        character,
        case.OwnSkillId,
        case.OwnRank
    )
    check(
        own_reason == nil
            and own_active ~= nil
            and own_active.ScopeId == case.BranchId
            and own_active.SkillId == case.OwnSourceSkillId
            and own_active.Rank == case.OwnSourceRank,
        case.ClassId .. " resolves its own first-transfer active rank"
    )

    local passive_plan, passive_reason =
        Passives.for_character(character)
    check(
        passive_reason == nil
            and passive_plan ~= nil
            and passive_plan.Ready == true
            and #passive_plan.SourceRanks == 1
            and passive_plan.SourceRanks[1].SkillId == 141
            and passive_plan.SourceRanks[1].Rank == 3,
        case.ClassId .. " resolves inherited Weapon Mastery rank three"
    )

    local unified, unified_reason = Unified.get(
        "Dwarf",
        case.ClassId,
        30,
        {Weapon = "Blunt"},
        passive_plan.SourceRanks
    )
    check(
        unified_reason == nil
            and unified ~= nil
            and unified.PassiveStatSnapshot.PHYSICAL_ATTACK
                > unified.Naked.NakedPAtk,
        case.ClassId .. " accepts inherited passive in unified source stats"
    )
end

--[[
Runs both Dwarf first-transfer source-inheritance cases.

Args:
    None.

Returns:
    nil: Prints a stable pass marker after both branches succeed.
]]
local function main()
    for _, case in ipairs(CASES) do
        exercise(case)
    end

    print(
        ("[Dwarf Source Inheritance] PASS: %d assertions")
            :format(checks)
    )
end

main()
