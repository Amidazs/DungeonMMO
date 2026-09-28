--!strict
-- Accepted Dwarf 2G+1C Deepclaimer profession-capacity regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared
local Core = ServerScriptService.Core

local SelectionRules = require(Shared.ProfessionSelectionRules)
local QuestStages = require(Shared.C4OriginalFirstTransferQuestStages)
local Profiles = require(Core.Services.ProfileService)
local Professions = require(Core.Services.ProfessionService)
local Inventory = require(Core.Services.InventoryService)
local ProfileAdapter = require(Core.Adapters.InMemoryProfileAdapter)

local USER_ID = 956202
local checks = 0

--[[
Counts one Deepclaimer profession assertion.

Args:
    valid (boolean): Expected profession-capacity condition.
    label (string): Diagnostic description for failure.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[Deepclaimer Professions] " .. label)
end

--[[
Builds complete server-side proof state for an earned Deepclaimer.

Args:
    character (any): Disposable in-memory character to advance.

Returns:
    nil: Mutates only the disposable test character.
]]
local function award_deepclaimer(character: any)
    local quest = assert(QuestStages.get("DwarfScavenger"))
    local proofs = {}

    for _, proof_id in ipairs(quest.RequiredProofIds) do
        proofs[proof_id] = true
    end

    character.Level = 28
    character.Identity = {
        Version = 1,
        CreationStage = "Complete",
        RaceId = "Dwarf",
        BaseClassId = "Fighter",
        ClassId = "Deepclaimer",
    }
    character.ClassAdvancement = {
        Version = 1,
        CompletedByRace = {},
        ActiveClassId = nil,
        OriginalFirstTransferChoiceId = "DwarfScavenger",
        OriginalFirstTransferClassId = "Deepclaimer",
        OriginalFirstTransferReceiptId = "deepclaimer-test-receipt",
        OriginalFirstTransferQuest = {
            QuestId = quest.Id,
            BranchId = "DwarfScavenger",
            Ready = true,
            Step = #quest.Steps + 1,
            Count = 0,
            AppliedEvents = {},
            Proofs = proofs,
        },
    }
end

--[[
Runs the accepted Deepclaimer profession-capacity contract.

Args:
    None.

Returns:
    nil: Prints a bounded pass marker after service and spoof checks pass.
]]
local function main()
    local forged = {
        Level = 28,
        Identity = {
            CreationStage = "Complete",
            RaceId = "Dwarf",
            BaseClassId = "Fighter",
            ClassId = "Deepclaimer",
        },
        ClassAdvancement = {},
    }
    local forged_capacity = SelectionRules.capacity(forged)
    local forged_slots = SelectionRules.normalize({
        Gathering = "Mining",
        Gathering2 = "Skinning",
        Creation = "Blacksmithing",
    }, forged)
    check(
        forged_capacity.Gathering == 1
            and forged_capacity.Creation == 1,
        "forged Deepclaimer identity cannot gain extra gathering"
    )
    check(
        forged_slots.Gathering2 == nil,
        "forged persisted Gathering2 slot is stripped"
    )

    local adapter = ProfileAdapter.new()
    local profiles = Profiles.new(adapter)
    check(profiles:load(USER_ID), "disposable profile loads")
    check(profiles:mutate(USER_ID, function(profile: any)
        award_deepclaimer(profile.Characters.Slot1)
    end), "earned Deepclaimer state is installed")

    local service = Professions.new(profiles, Inventory.new(profiles))
    check(service:choose_profession(USER_ID, "Mining").ok,
        "Deepclaimer selects first gathering profession")
    check(service:choose_profession(USER_ID, "Skinning").ok,
        "Deepclaimer selects second gathering profession")
    check(service:choose_profession(USER_ID, "Blacksmithing").ok,
        "Deepclaimer selects one crafting profession")

    local character = assert(profiles:get_character(USER_ID, 1))
    check(
        character.ProfessionSlots.Gathering == "Mining"
            and character.ProfessionSlots.Gathering2 == "Skinning",
        "two gathering selections persist independently"
    )
    check(
        character.ProfessionSlots.Creation == "Blacksmithing",
        "single crafting selection persists"
    )
    check(
        not service:choose_profession(USER_ID, "Herbalism").ok,
        "third gathering profession is rejected"
    )
    check(
        not service:choose_profession(USER_ID, "Alchemy").ok,
        "second crafting profession is rejected"
    )
    check(service:can_use(USER_ID, "Mining"),
        "first gathering profession remains authorized")
    check(service:can_use(USER_ID, "Skinning"),
        "second gathering profession is authorized")
    check(not service:can_use(USER_ID, "Herbalism"),
        "unselected gathering profession remains unauthorized")
    check(service:can_use(USER_ID, "Blacksmithing"),
        "selected crafting profession remains authorized")

    local snapshot = service:build_snapshot(USER_ID)
    check(snapshot.ok, "profession snapshot builds")
    check(
        snapshot.ProfessionSlots.Gathering2 == "Skinning",
        "snapshot exposes earned second gathering slot"
    )

    check(profiles:save(USER_ID, "DeepclaimerProfessionTest"),
        "earned Deepclaimer profession slots save")
    local restored = Profiles.new(adapter)
    check(restored:load(USER_ID), "earned Deepclaimer profile reloads")
    local restored_character = assert(
        restored:get_character(USER_ID, 1)
    )
    check(
        restored_character.ProfessionSlots.Gathering == "Mining"
            and restored_character.ProfessionSlots.Gathering2
                == "Skinning"
            and restored_character.ProfessionSlots.Creation
                == "Blacksmithing",
        "earned 2G+1C capacity survives profile reload"
    )

    print(
        ("[Deepclaimer Professions] PASS: %d assertions")
            :format(checks)
    )
end

main()
