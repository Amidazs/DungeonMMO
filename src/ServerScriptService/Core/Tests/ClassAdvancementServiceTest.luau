--!strict
-- The old one-candidate trial must never grant a fresh C4 Fighter/Mystic
-- an invented original class. Already started old quests remain claimable.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared
local Adapter = require(SSS.Core.Adapters.InMemoryProfileAdapter)
local Profiles = require(SSS.Core.Services.ProfileService)
local Quests = require(SSS.Core.Services.QuestService)
local Advancements = require(SSS.Core.Services.ClassAdvancementService)
local Selection = require(
    SSS.Core.Services.C4FirstTransferSelectionService
)
local DungeonDefinitions = require(Shared.DungeonDefinitions)
local QuestDefinitions = require(Shared.QuestDefinitions)
local checks = 0

--[[
Checks one server-authoritative C4 advancement or legacy save invariant.

Args:
    condition (boolean): Required original class or preserved trial behavior.
    description (string): Focused Studio assertion label.

Returns:
    nil: Records a passing check or fails real Studio execution.
]]
local function check(condition: boolean, description: string)
    checks += 1
    assert(condition, "[Class Advancement Tests] " .. description)
end

--[[
Sets up a valid original starting class with paid trial skills in memory.

Args:
    profiles (any): Exclusive writer-owned real ProfileService.
    user_id (number): Disposable original starting-class profile.
    race_id (string): Human or Elf current playable original race.
    family (string): Fighter or internal Mage/Mystic family ID.

Returns:
    nil: Creates an actual eligible old trial fixture without claiming it.
]]
local function seed(
    profiles: any, user_id: number, race_id: string, family: string
)
    check(profiles:load(user_id), "Source class character must load")
    check(profiles:mutate(user_id, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = 20
        character.Gold = 500
        character.Identity = {
            Version = 1, RaceId = race_id,
            BaseClassId = family, ClassId = family,
            CreationStage = "Complete",
        }
        local quest_id = if family == "Fighter"
            then "FighterAdvancementTrial"
            else "MageAdvancementTrial"
        local trial = assert(QuestDefinitions.get(quest_id))
        character.Progression.SkillPointEntitlement = 70
        for _, requirement in ipairs(trial.SkillPrerequisites) do
            character.Progression.Skills[requirement.SkillId] = {
                Known = true, StarterGranted = false,
                PurchasedRank = requirement.Rank,
                Proficiency = requirement.Proficiency,
            }
        end
    end), "Original class level and skill mastery must persist")
end

--[[
Verifies a newly eligible character cannot begin or claim custom classes.

Args:
    profiles (any): Actual original class profile service.
    advancement (any): Existing live class advancement authority.
    choice (any): New explicit original C4 source branch selection service.

Returns:
    nil: Checks honest original choice and not falsely awarded class.
]]
local function check_original_starters(
    profiles: any, advancement: any, choice: any
)
    seed(profiles, 51001, "Human", "Fighter")
    seed(profiles, 51002, "Human", "Mage")
    seed(profiles, 51003, "Elf", "Fighter")
    seed(profiles, 51004, "Elf", "Mage")
    for _, user_id in ipairs({51001, 51002, 51003, 51004}) do
        check(advancement:start_trial(user_id).reason
            == "OriginalC4BranchChoiceRequired",
            "Fresh Fighter/Mystic must not start automatic custom class")
        check(advancement:claim(user_id).reason
            == "OriginalC4BranchChoiceRequired",
            "Unstarted legacy trial cannot manufacture a C4 first transfer")
        local snapshot = advancement:build_snapshot(user_id)
        check(snapshot.CandidateClassId == nil
            and snapshot.Completed == false,
            "New C4 characters must not see an automatic legacy candidate")
    end
    local selected = choice:choose(51001, "HumanRogue")
    check(selected.ok and selected.class_id == "HumanRogue",
        "Human Fighter must explicitly choose its original Rogue branch")
    check(advancement:start_trial(51001).reason
        == "OriginalC4BranchChoiceRequired",
        "An original source choice must not start an unrelated Vanguard trial")
    check(advancement:claim(51001).reason
        == "OriginalC4BranchChoiceRequired",
        "An original source choice cannot itself grant an advanced class")
    local fighter = assert(profiles:get_character(51001, 1))
    check(fighter.ClassAdvancement.OriginalFirstTransferChoiceId
        == "HumanRogue"
        and fighter.ClassAdvancement.ActiveClassId == nil
        and fighter.Identity.ClassId == "Fighter",
        "Explicit selection must be saved without an unearned transfer")
end

--[[
Tests that a pre-existing already-started quest may still be claimed.

Args:
    profiles (any): Real in-memory persistent profiles.
    quests (any): Actual server-owned preexisting quest authority.
    advancement (any): Existing class claim service with migration guard.
    choice (any): Explicit original C4 selection service.

Returns:
    nil: Preserves old completed-class and quest history without duplication.
]]
local function check_legacy_claim(
    profiles: any, quests: any, advancement: any, choice: any
)
    seed(profiles, 51005, "Human", "Fighter")
    check(quests:start(51005, "FighterAdvancementTrial").ok,
        "Existing prior trial may already have been started before update")
    check(choice:choose(51005, "HumanRogue").reason
        == "LegacyClassMigrationRequired",
        "New source choice must not erase an existing custom trial")
    check(advancement:start_trial(51005).reason
        == "OriginalC4BranchChoiceRequired",
        "Even an old active trial cannot be freshly started a second time")
    check(advancement:claim(51005).reason
        == "AdvancementQuestNotReady",
        "Previously started trial may not be claimed before its objectives")
    check(quests:record_event(51005, {
        EventId = "prior-legacy-temple-clear",
        Type = "DungeonClear",
        TargetId = DungeonDefinitions.TEST_DUNGEON.Id,
        Amount = 1,
    }).ok, "Actual original legacy dungeon event must ready old quest")
    local claim = advancement:claim(51005)
    check(claim.ok and claim.class_id == "HumanVanguard",
        "Already-started prior class trial remains claimable, not deleted")
    local character = assert(profiles:get_character(51005, 1))
    check(character.ClassAdvancement.ActiveClassId == "HumanVanguard"
        and character.Quests.Completed.FighterAdvancementTrial == true
        and character.Quests.Active.FighterAdvancementTrial == nil,
        "Old quest and advanced history commit once in the real profile")
    check(advancement:claim(51005).reason
        == "AdvancementAlreadyCompleted",
        "Legacy quest completion may not be replayed")
    check(choice:choose(51005, "HumanKnight").reason
        == "LegacyClassMigrationRequired",
        "Old completed advanced class must stay separate until migration")
    check(profiles:save(51005, "PreexistingClassHistory"),
        "Historical class completion must save")
    check(profiles:release(51005, "PreexistingClassHistory"),
        "Original legacy character must release safely")
    check(profiles:load(51005),
        "Original legacy character must reload after the source update")
    character = assert(profiles:get_character(51005, 1))
    check(character.ClassAdvancement.ActiveClassId == "HumanVanguard"
        and character.ClassAdvancement.CompletedByRace.Human
            .HumanVanguard == true
        and character.Level == 20 and character.Gold == 500,
        "Legacy class, level, gold and race-bound historical proof persist")
end

--[[
Runs focused non-destructive C4 class-choice and grandfathered trial tests.

Args:
    None.

Returns:
    nil: Prints counts only after all actual profile/quest checks pass.
]]
local function main()
    local profiles = Profiles.new(Adapter.new())
    local quests = Quests.new(profiles)
    local advancement = Advancements.new(profiles, quests, "Base")
    local selection = Selection.new(profiles, "Base")
    check_original_starters(profiles, advancement, selection)
    check_legacy_claim(profiles, quests, advancement, selection)
    check(Advancements.new(profiles, quests, "Dungeon"):start_trial(
        51001
    ).reason == "BaseOnlyAction", "Dungeon cannot start Base class trial")
    print(("[Class Advancement Tests] PASS: %d assertions")
        :format(checks))
end

main()
