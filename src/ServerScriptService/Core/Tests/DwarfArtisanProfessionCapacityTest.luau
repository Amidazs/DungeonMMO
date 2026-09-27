--!strict
-- Accepted Dwarf 1G+2C Gearwright profession-capacity regression.

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

local USER_ID = 956201
local checks = 0

--[[
Counts one Gearwright profession assertion.

Args:
    valid (boolean): Expected profession-capacity condition.
    label (string): Diagnostic description for failure.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[Gearwright Professions] " .. label)
end

--[[
Builds the complete server-side proof state for an earned Gearwright.

Args:
    character (any): Disposable in-memory character to advance.

Returns:
    nil: Mutates only the disposable test character.
]]
local function award_gearwright(character: any)
    local quest = assert(QuestStages.get("DwarfArtisan"))
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
        ClassId = "Gearwright",
    }
    character.ClassAdvancement = {
        Version = 1,
        CompletedByRace = {},
        ActiveClassId = nil,
        OriginalFirstTransferChoiceId = "DwarfArtisan",
        OriginalFirstTransferClassId = "Gearwright",
        OriginalFirstTransferReceiptId = "gearwright-test-receipt",
        OriginalFirstTransferQuest = {
            QuestId = quest.Id,
            BranchId = "DwarfArtisan",
            Ready = true,
            Step = #quest.Steps + 1,
            Proofs = proofs,
        },
    }
end

--[[
Runs the accepted Gearwright profession-capacity contract.

Args:
    None.

Returns:
    nil: Prints a bounded pass marker after service and spoof checks pass.
]]
local function main()
    local forged = {
        Level = 20,
        Identity = {
            CreationStage = "Complete",
            RaceId = "Dwarf",
            BaseClassId = "Fighter",
            ClassId = "Gearwright",
        },
        ClassAdvancement = {},
    }
    local forged_capacity = SelectionRules.capacity(forged)
    check(
        forged_capacity.Gathering == 1
            and forged_capacity.Creation == 1,
        "forged Gearwright identity cannot gain extra crafting"
    )

    local profiles = Profiles.new(ProfileAdapter.new())
    check(profiles:load(USER_ID), "disposable profile loads")
    check(profiles:mutate(USER_ID, function(profile: any)
        award_gearwright(profile.Characters.Slot1)
    end), "earned Gearwright state is installed")

    local service = Professions.new(profiles, Inventory.new(profiles))
    check(service:choose_profession(USER_ID, "Mining").ok,
        "Gearwright selects one gathering profession")
    check(service:choose_profession(USER_ID, "Blacksmithing").ok,
        "Gearwright selects first crafting profession")
    check(service:choose_profession(USER_ID, "Alchemy").ok,
        "Gearwright selects second crafting profession")

    local character = assert(profiles:get_character(USER_ID, 1))
    check(
        character.ProfessionSlots.Gathering == "Mining",
        "gathering persists in primary slot"
    )
    check(
        character.ProfessionSlots.Creation == "Blacksmithing"
            and character.ProfessionSlots.Creation2 == "Alchemy",
        "two crafting selections persist independently"
    )
    check(
        not service:choose_profession(USER_ID, "Enchanting").ok,
        "third crafting profession is rejected"
    )
    check(
        not service:choose_profession(USER_ID, "Herbalism").ok,
        "second gathering profession is rejected"
    )
    check(service:can_use(USER_ID, "Blacksmithing"),
        "first crafting profession remains authorized")
    check(service:can_use(USER_ID, "Alchemy"),
        "second crafting profession is authorized")
    check(not service:can_use(USER_ID, "Enchanting"),
        "unselected crafting profession remains unauthorized")

    local snapshot = service:build_snapshot(USER_ID)
    check(snapshot.ok, "profession snapshot builds")
    check(
        snapshot.ProfessionSlots.Creation2 == "Alchemy",
        "snapshot exposes earned second crafting slot"
    )

    print(
        ("[Gearwright Professions] PASS: %d assertions")
            :format(checks)
    )
end

main()
