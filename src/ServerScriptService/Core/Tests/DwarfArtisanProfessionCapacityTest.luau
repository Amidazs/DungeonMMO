--!strict
-- Accepted Dwarf 1G+2C Gearwright profession-capacity regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared
local Core = ServerScriptService.Core

local SelectionRules = require(Shared.ProfessionSelectionRules)
local ProfessionSkillRules = require(Shared.C4ProfessionSkillRules)
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

    character.Level = 28
    character.Identity = {
        Version = 1,
        CreationStage = "Complete",
        RaceId = "Dwarf",
        BaseClassId = "Fighter",
        ClassId = "Gearwright",
    }
    character.Progression = character.Progression or {}
    character.Progression.Skills = character.Progression.Skills or {}
    character.Progression.Skills.DwarfWorkshopCraft = {
        Known = true,
        PurchasedRank = 1,
    }
    character.Progression.Skills.DwarfBlueprintFoundation = {
        Known = true,
        PurchasedRank = 1,
    }
    character.Progression.Skills.DwarfCommonCraft = {
        Known = true,
        PurchasedRank = 1,
    }
    character.Progression.Skills.GearwrightBlueprintTraining = {
        Known = true,
        PurchasedRank = 2,
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
            Count = 0,
            AppliedEvents = {},
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
    local forged_slots = SelectionRules.normalize({
        Gathering = "Mining",
        Creation = "Blacksmithing",
        Creation2 = "Enchanting",
    }, forged)
    check(
        forged_capacity.Gathering == 1
            and forged_capacity.Creation == 1,
        "forged Gearwright identity cannot gain extra crafting"
    )
    check(
        forged_slots.Creation2 == nil,
        "forged persisted Creation2 slot is stripped"
    )

    local adapter = ProfileAdapter.new()
    local profiles = Profiles.new(adapter)
    check(profiles:load(USER_ID), "disposable profile loads")
    check(profiles:mutate(USER_ID, function(profile: any)
        award_gearwright(profile.Characters.Slot1)
    end), "earned Gearwright state is installed")

    local service = Professions.new(profiles, Inventory.new(profiles))
    check(service:choose_profession(USER_ID, "Mining").ok,
        "Gearwright selects one gathering profession")
    check(service:choose_profession(USER_ID, "Blacksmithing").ok,
        "Gearwright selects first crafting profession")
    check(service:choose_profession(USER_ID, "Enchanting").ok,
        "Gearwright selects second crafting profession")

    local character = assert(profiles:get_character(USER_ID, 1))
    check(
        character.ProfessionSlots.Gathering == "Mining",
        "gathering persists in primary slot"
    )
    check(
        character.ProfessionSlots.Creation == "Blacksmithing"
            and character.ProfessionSlots.Creation2 == "Enchanting",
        "two crafting selections persist independently"
    )
    check(
        not service:choose_profession(USER_ID, "Alchemy").ok,
        "third crafting profession is rejected"
    )
    check(
        not service:choose_profession(USER_ID, "Herbalism").ok,
        "second gathering profession is rejected"
    )
    check(service:can_use(USER_ID, "Blacksmithing"),
        "first crafting profession remains authorized")
    check(service:can_use(USER_ID, "Enchanting"),
        "second crafting profession is authorized")
    check(not service:can_use(USER_ID, "Alchemy"),
        "unselected crafting profession remains unauthorized")
    check(
        ProfessionSkillRules.can_make_gearwright_blueprint(
            character, "Blacksmithing", 1
        ),
        "rank-one blueprint works in first craft"
    )
    check(
        ProfessionSkillRules.can_make_gearwright_blueprint(
            character, "Enchanting", 2
        ),
        "rank-two blueprint works in second craft"
    )
    check(
        not ProfessionSkillRules.can_make_gearwright_blueprint(
            character, "Alchemy", 1
        ),
        "blueprint cannot bypass selected craft slots"
    )
    check(
        ProfessionSkillRules.can_make_common(
            character, "Blacksmithing"
        ),
        "inherited Dwarf common craft remains usable"
    )

    local snapshot = service:build_snapshot(USER_ID)
    check(snapshot.ok, "profession snapshot builds")
    check(
        snapshot.ProfessionSlots.Creation2 == "Enchanting",
        "snapshot exposes earned second crafting slot"
    )

    check(profiles:save(USER_ID, "GearwrightProfessionTest"),
        "earned Gearwright profession slots save")
    local restored = Profiles.new(adapter)
    check(restored:load(USER_ID), "earned Gearwright profile reloads")
    local restored_character = assert(
        restored:get_character(USER_ID, 1)
    )
    check(
        restored_character.ProfessionSlots.Gathering == "Mining"
            and restored_character.ProfessionSlots.Creation
                == "Blacksmithing"
            and restored_character.ProfessionSlots.Creation2
                == "Enchanting",
        "earned 1G+2C capacity survives profile reload"
    )

    print(
        ("[Gearwright Professions] PASS: %d assertions")
            :format(checks)
    )
end

main()
