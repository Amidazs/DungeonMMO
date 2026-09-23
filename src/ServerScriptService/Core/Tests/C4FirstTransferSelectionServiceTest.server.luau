--!strict
-- Actual C4 branch choice: server-owned, race-specific and persistence-safe.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared
local Adapter = require(SSS.Core.Adapters.InMemoryProfileAdapter)
local Profiles = require(SSS.Core.Services.ProfileService)
local Selection = require(
    SSS.Core.Services.C4FirstTransferSelectionService
)
local RaceChange = require(SSS.Core.Services.RaceChangeService)
local Branches = require(Shared.C4FirstTransferBranches)
local Inventory = require(SSS.Core.Services.InventoryService)
local checks = 0

--[[
Records one genuine explicit branch, persistence or replay assertion.

Args:
    condition (boolean): Required real profile decision or intact state.
    message (string): Short failure diagnostic.

Returns:
    nil: Increments the assertion count or fails actual Studio execution.
]]
local function check(condition: boolean, message: string)
    checks += 1
    assert(condition, "[C4 First Transfer Choice] " .. message)
end

--[[
Creates one original C4 Fighter/Mystic starting profile at source level.

Args:
    profiles (any): Real exclusive writer profile authority.
    user_id (number): Disposable isolated player identity.
    race (string): Human or Elf.
    family (string): Fighter or internal Mage/Mystic family.

Returns:
    nil: Preserves default original profile progression and professions.
]]
local function seed(
    profiles: any, user_id: number, race: string, family: string
)
    check(profiles:load(user_id), "Fresh original character must load")
    check(profiles:mutate(user_id, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = 18
        character.Gold = 149
        character.Identity = {
            Version = 1, RaceId = race,
            BaseClassId = family, ClassId = family,
            CreationStage = "Complete",
        }
    end), "Race and original starting family must be saved")
end

--[[
Proves no choices are persisted before level 18, wrong race or class.

Args:
    profiles (any): Real server profile service.
    service (any): Base-only authenticated original class selection.

Returns:
    nil: Validates all fail-closed boundaries for initial class choice.
]]
local function check_invalid_choices(profiles: any, service: any)
    seed(profiles, 99301, "Human", "Fighter")
    check(profiles:mutate(99301, function(profile: any)
        profile.Characters.Slot1.Level = 17
    end), "Level-17 trial profile must save")
    check(service:choose(99301, "HumanRogue").reason
        == "OriginalTransferLevelTooLow",
        "Original first class choice must not unlock at level 17")
    check(profiles:mutate(99301, function(profile: any)
        profile.Characters.Slot1.Level = 18
    end), "Level-18 choice must persist")
    check(service:choose(99301, "ElvenScout").reason
        == "OriginalClassChoiceUnavailable",
        "Human Fighter cannot choose an Elven branch")
    check(service:choose(99301, "HumanWizard").reason
        == "OriginalClassChoiceUnavailable",
        "Human Fighter cannot choose a Human Mystic branch")
    check(service:choose(99301, 1234).reason == "InvalidClassChoice",
        "Forged nonstring class ID must not be accepted")
    check(service:choose(99301, "SomeOtherClass").reason
        == "OriginalClassChoiceUnavailable",
        "Non-source custom role cannot be chosen as original C4 path")
    local character = assert(profiles:get_character(99301, 1))
    check(character.ClassAdvancement.OriginalFirstTransferChoiceId == nil,
        "No invalid selection may write a chosen C4 branch")
end

--[[
Persists one explicit source class, preserves unrelated profile state.

Args:
    profiles (any): Real profile service over a reusable memory adapter.
    service (any): Actual Base server-owned class-choice authority.

Returns:
    nil: Verifies different same-family choices and idempotent reload.
]]
local function check_chosen_paths(profiles: any, service: any)
    check_invalid_choices(profiles, service)
    seed(profiles, 99302, "Elf", "Fighter")
    seed(profiles, 99303, "Human", "Mage")

    local first = service:choose(99301, "HumanRogue")
    local second = service:choose(99302, "ElvenKnight")
    local third = service:choose(99303, "HumanCleric")
    check(first.ok and first.class_id == "HumanRogue"
        and first.quest_status == "OriginalQuestNotImplemented",
        "Human Fighter may explicitly choose Rogue without fake quest loot")
    check(second.ok and second.class_id == "ElvenKnight",
        "Elf Fighter can explicitly choose the other original fighter path")
    check(third.ok and third.class_id == "HumanCleric",
        "Human Mystic can explicitly select Cleric, not automatic Wizard")
    check(service:choose(99301, "HumanKnight").reason
        == "OriginalClassChoiceAlreadyMade",
        "Another choice cannot silently overwrite an existing source path")
    local owner = assert(profiles:get_character(99301, 1))
    local snapshot = service:build_snapshot(99301)
    check(snapshot.ok and #snapshot.Options == 3
        and snapshot.SelectedClassId == "HumanRogue"
        and snapshot.CanChoose == false
        and snapshot.QuestImplemented == false,
        "UI must report selected class and absent original quest honestly")
    check(owner.Identity.ClassId == "Fighter"
        and owner.ClassAdvancement.ActiveClassId == nil
        and owner.Gold == 149,
        "Selection must not award an advanced class, gold or progression")
    check(Inventory.count_item(owner, "captain_emblem") == 0,
        "Selecting a class must never mint any loot")

    for _, user_id in ipairs({99301, 99302, 99303}) do
        check(profiles:save(user_id, "OriginalC4ClassChoice"),
            "Explicit source class choice must save")
        check(profiles:release(user_id, "OriginalC4ClassChoice"),
            "Saving the class choice must release cleanly")
        check(profiles:load(user_id),
            "Saved original source class must reload")
    end
    check(service:build_snapshot(99301).SelectedClassId == "HumanRogue"
        and service:build_snapshot(99302).SelectedClassId
            == "ElvenKnight"
        and service:build_snapshot(99303).SelectedClassId
            == "HumanCleric",
        "Distinct race/family original choices must survive real migration")
    check(service:choose(99301, "HumanWarrior").reason
        == "OriginalClassChoiceAlreadyMade",
        "Reloaded original C4 class choice cannot be silently replaced")
    local race_change = RaceChange.new(profiles, "TEST")
    check(race_change:preview(99301, "Elf").reason
        == "OriginalClassRaceLocked",
        "An original Human C4 path cannot be reassigned to an Elf")
    check(race_change:apply(
        99301, "Elf", "forged_preview", "forged_transaction"
    ).reason == "OriginalClassRaceLocked",
        "Forged race-change commit cannot override the chosen source path")
    check(profiles:get_character(99301, 1).Identity.RaceId == "Human",
        "Blocked development race change must preserve the source race")

    local metadata = assert(Branches.find(
        "Human", "Fighter", "HumanRogue"
    ))
    check(metadata.GameplayStatus == "Partial"
        and metadata.GameQuestId == nil,
        "Source rank parity must never pretend real branch quest is ready")
end

--[[
Proves existing custom-class saves cannot be overwritten by new selection.

Args:
    profiles (any): Real selected character profile.
    service (any): Actual first-transfer choice service.

Returns:
    nil: Preserves old pending/completed advancement history for migration.
]]
local function check_legacy_safety(profiles: any, service: any)
    seed(profiles, 99304, "Human", "Fighter")
    check(profiles:mutate(99304, function(profile: any)
        local character = profile.Characters.Slot1
        character.Quests.Active.FighterAdvancementTrial = {
            Objectives = {ClearTemple = 0}, AppliedEvents = {},
            Ready = false,
        }
    end), "Existing started legacy quest must persist")
    check(service:choose(99304, "HumanRogue").reason
        == "LegacyClassMigrationRequired",
        "Existing in-progress quest must not be overwritten by a C4 choice")
    seed(profiles, 99305, "Elf", "Mage")
    check(profiles:mutate(99305, function(profile: any)
        local advancement = profile.Characters.Slot1.ClassAdvancement
        advancement.CompletedByRace.Elf = {ElfSpellweaver = true}
        advancement.ActiveClassId = "ElfSpellweaver"
    end), "Historical advanced class must persist")
    check(service:choose(99305, "ElvenOracle").reason
        == "LegacyClassMigrationRequired",
        "Existing advanced class history must remain migration-protected")
    check(profiles:get_character(99305, 1)
        .ClassAdvancement.ActiveClassId == "ElfSpellweaver",
        "Blocked source-choice attempts must not erase legacy class")
end

--[[
Runs only actual explicit C4 selection and non-destructive save checks.

Args:
    None.

Returns:
    nil: Emits precise executed assertion count after all checks succeed.
]]
local function main()
    local adapter = Adapter.new()
    local profiles = Profiles.new(adapter)
    local service = Selection.new(profiles, "Base")
    check_chosen_paths(profiles, service)
    check_legacy_safety(profiles, service)
    check(not Selection.new(profiles, "Dungeon"):choose(
        99301, "HumanWarrior"
    ).ok, "Original class choice is not available inside an active dungeon")
    print(("[C4 First Transfer Choice] PASS: %d assertions")
        :format(checks))
end

main()
