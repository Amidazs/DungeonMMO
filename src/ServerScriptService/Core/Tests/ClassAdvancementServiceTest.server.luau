--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Core = ServerScriptService:WaitForChild("Core")
local Adapters = Core:WaitForChild("Adapters")
local Services = Core:WaitForChild("Services")
local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")

local InMemoryProfileAdapter = require(
    Adapters:WaitForChild("InMemoryProfileAdapter")
)
local ProfileService = require(Services:WaitForChild("ProfileService"))
local QuestService = require(Services:WaitForChild("QuestService"))
local ClassAdvancementService = require(
    Services:WaitForChild("ClassAdvancementService")
)
local RaceChangeService = require(Services:WaitForChild("RaceChangeService"))
local DungeonDefinitions = require(Shared:WaitForChild("DungeonDefinitions"))
local QuestDefinitions = require(Shared:WaitForChild("QuestDefinitions"))


local assertions = 0

local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Class Advancement Tests] " .. message, 2)
    end
end

-- Seeds legitimate fully purchased prerequisite ranks and proficiency
-- without bypassing the production advancement or quest validators.
--
-- Args:
--   character (any): Mutable test character profile.
--   quest_id (string): Registered race/base-class advancement trial.
-- Returns:
--   nil: Creates earned skill states required by that class's quest.
local function seed_trial_mastery(character: any, quest_id: string)
    local trial = assert(QuestDefinitions.get(quest_id))
    character.Progression.SkillPointEntitlement = 60
    for _, requirement in ipairs(trial.SkillPrerequisites) do
        character.Progression.Skills[requirement.SkillId] = {
            Known = true,
            StarterGranted = false,
            PurchasedRank = requirement.Rank,
            Proficiency = requirement.Proficiency,
        }
    end
end

local function set_mage(
    profiles: any,
    user_id: number,
    race_id: string
)
    local ok, reason = profiles:mutate(user_id, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = 20
        character.Identity = {
            Version = 1,
            RaceId = race_id,
            BaseClassId = "Mage",
            ClassId = "Mage",
            CreationStage = "Complete",
        }
        seed_trial_mastery(character, "MageAdvancementTrial")
    end)
    check(ok == true, "Mage fixture mutation failed: " .. tostring(reason))
end

local profiles = ProfileService.new(InMemoryProfileAdapter.new())
assert(profiles:load(5201))
assert(profiles:load(5202))
assert(profiles:load(5203))
set_mage(profiles, 5201, "Human")
set_mage(profiles, 5202, "Elf")

local fixture_ok = profiles:mutate(5203, function(profile: any)
    local character = profile.Characters.Slot1
    character.Level = 20
    character.Identity = {
        Version = 1,
        RaceId = "Human",
        BaseClassId = "Fighter",
        ClassId = "Fighter",
        CreationStage = "Complete",
    }
    seed_trial_mastery(character, "FighterAdvancementTrial")
end)
check(fixture_ok == true, "Fighter fixture mutation failed.")

local quests = QuestService.new(profiles)
local base = ClassAdvancementService.new(profiles, quests, "Base")
local dungeon = ClassAdvancementService.new(profiles, quests, "Dungeon")

local dungeon_reject = dungeon:start_trial(5201)
check(
    dungeon_reject.ok == false and dungeon_reject.reason == "BaseOnlyAction",
    "Advancement trial must not start in Dungeon context."
)

local fighter_start = base:start_trial(5203)
check(
    fighter_start.ok and fighter_start.class_id == "HumanVanguard"
        and fighter_start.quest_id == "FighterAdvancementTrial"
        and fighter_start.role_id == "Tank",
    "Human Fighter must receive the Vanguard tank trial at level 20."
)

local human_start = base:start_trial(5201)
check(human_start.ok == true, "Human Mage trial must start.")

local early_claim = base:claim(5201)
check(
    early_claim.ok == false
        and early_claim.reason == "AdvancementQuestNotReady",
    "Advancement claim before objective completion must reject."
)

local human_event = quests:record_event(5201, {
    EventId = "human-session:DungeonClear",
    Type = "DungeonClear",
    TargetId = DungeonDefinitions.TEST_DUNGEON.Id,
    Amount = 1,
})
check(human_event.ok == true, "Human Temple clear must progress quest.")

local human_claim = base:claim(5201)
check(human_claim.ok == true, "Ready Human Mage advancement must claim.")
check(
    human_claim.class_id == "HumanArcanist",
    "Human Mage must advance to HumanArcanist."
)

local human_character = assert(profiles:get_character(5201, 1))
check(
    human_character.Identity.ClassId == "Mage"
        and human_character.Identity.BaseClassId == "Mage",
    "Advancement must preserve accepted Mage base-family identity."
)
check(
    human_character.ClassAdvancement.ActiveClassId == "HumanArcanist",
    "Human advanced identity must persist separately."
)
check(
    human_character.ClassAdvancement.CompletedByRace.Human.HumanArcanist
        == true,
    "Human advancement history must persist by race."
)
check(
    human_character.Quests.Active.MageAdvancementTrial == nil
        and human_character.Quests.Completed.MageAdvancementTrial == true,
    "Claim must atomically consume the ready quest into Completed."
)

local duplicate_claim = base:claim(5201)
check(
    duplicate_claim.ok == false
        and duplicate_claim.reason == "AdvancementAlreadyCompleted",
    "Duplicate Human advancement claim must reject."
)

check(base:start_trial(5202).ok == true, "Elf Mage trial must start.")
check(quests:record_event(5202, {
    EventId = "elf-session:DungeonClear",
    Type = "DungeonClear",
    TargetId = DungeonDefinitions.TEST_DUNGEON.Id,
    Amount = 1,
}).ok == true, "Elf Temple clear must progress quest.")

local elf_claim = base:claim(5202)
check(elf_claim.ok == true, "Ready Elf Mage advancement must claim.")
check(
    elf_claim.class_id == "ElfSpellweaver",
    "Elf Mage must advance to ElfSpellweaver."
)
local elf_character = assert(profiles:get_character(5202, 1))
check(
    elf_character.ClassAdvancement.ActiveClassId == "ElfSpellweaver",
    "Elf advanced identity must persist."
)
check(
    elf_character.ClassAdvancement.CompletedByRace.Elf.ElfSpellweaver
        == true,
    "Elf advancement history must persist by race."
)

local race_change = RaceChangeService.new(profiles, "TEST", function() return 888 end)
local elf_preview = race_change:preview(5201, "Elf")
check(elf_preview.ok == true, "Human advanced Mage must preview Elf Race Change.")
check(race_change:apply(5201, "Elf", elf_preview.Hash, "adv-human-to-elf").ok == true,
    "Human advanced Mage must apply Elf Race Change.")
local changed_snapshot = base:build_snapshot(5201)
check(changed_snapshot.ActiveClassId == nil,
    "HumanArcanist completion must not activate as an Elf class.")
check(changed_snapshot.CandidateClassId == "ElfSpellweaver" and changed_snapshot.Completed == false,
    "Human advancement must not manufacture equivalent Elf completion.")
check(assert(profiles:get_character(5201, 1)).ClassAdvancement.CompletedByRace.Human.HumanArcanist == true,
    "Human advancement history must remain stored while Elf.")

local human_preview = race_change:preview(5201, "Human")
check(human_preview.ok == true, "Elf Mage must preview return to Human.")
check(race_change:apply(5201, "Human", human_preview.Hash, "adv-elf-to-human").ok == true,
    "Elf Mage must return to Human.")
local restored_snapshot = base:build_snapshot(5201)
check(restored_snapshot.ActiveClassId == "HumanArcanist" and restored_snapshot.Completed == true,
    "Returning race must reactivate historical Human advancement without re-claiming.")

-- Four new race-specific advancement paths reuse the original
-- quest, profile, race history and ClassAdvancementService authority.
local fighter_early = base:claim(5203)
check(
    fighter_early.reason == "AdvancementQuestNotReady",
    "A Fighter cannot claim an uncompleted Temple trial."
)
check(
    quests:record_event(5203, {
        EventId = "fighter-wrong-mine:DungeonClear",
        Type = "DungeonClear",
        TargetId = DungeonDefinitions.ABANDONED_MINE.Id,
        Amount = 1,
    }).ok,
    "A Mine clear is unrelated to the Fighter Temple trial."
)
check(
    base:claim(5203).reason == "AdvancementQuestNotReady",
    "Wrong-dungeon completion must not advance a Fighter."
)
check(
    quests:record_event(5203, {
        EventId = "fighter-temple:DungeonClear",
        Type = "DungeonClear",
        TargetId = DungeonDefinitions.TEST_DUNGEON.Id,
        Amount = 1,
    }).ok,
    "The trusted Temple clear must ready the Fighter trial."
)
local fighter_claim = base:claim(5203)
check(
    fighter_claim.ok and fighter_claim.class_id == "HumanVanguard"
        and fighter_claim.role_id == "Tank",
    "The Vanguard must claim only after completing its own trial."
)
check(
    base:claim(5203).reason == "AdvancementAlreadyCompleted",
    "Vanguard advancement cannot be claimed twice."
)

-- Args:
--   user_id (number): Test character's stable user identity.
--   race_id (string): Supported Human or Elf race.
--   base_class_id (string): Supported Fighter or Ranger class.
-- Returns:
--   nil: Seeds one independent level-20 advancement candidate.
local function seed_candidate(
    user_id: number,
    race_id: string,
    base_class_id: string
)
    assert(profiles:load(user_id), "Candidate profile must load.")
    local mutated = profiles:mutate(user_id, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = 20
        character.Identity = {
            Version = 1,
            RaceId = race_id,
            BaseClassId = base_class_id,
            ClassId = base_class_id,
            CreationStage = "Complete",
        }
        local quest_id = if base_class_id == "Fighter"
            then "FighterAdvancementTrial"
            else "RangerAdvancementTrial"
        seed_trial_mastery(character, quest_id)
    end)
    check(mutated, "Advancement candidate profile mutation must succeed.")
end

local additional_paths = {
    {5204, "Elf", "Fighter", "ElfThornwarden", "Tank",
        DungeonDefinitions.TEST_DUNGEON.Id},
    {5205, "Human", "Ranger", "HumanSharpshooter",
        "RangedDamage", DungeonDefinitions.ABANDONED_MINE.Id},
    {5206, "Elf", "Ranger", "ElfWindrunner",
        "RangedDamage", DungeonDefinitions.ABANDONED_MINE.Id},
}
for _, path in ipairs(additional_paths) do
    local user_id = path[1]
    local race_id = path[2]
    local base_class_id = path[3]
    local class_id = path[4]
    local role_id = path[5]
    local dungeon_id = path[6]
    seed_candidate(user_id, race_id, base_class_id)

    local candidate = base:build_snapshot(user_id)
    check(
        candidate.CandidateClassId == class_id
            and candidate.CandidateRoleId == role_id
            and candidate.Completed == false,
        "Race and base class must select their own advanced role."
    )
    local started = base:start_trial(user_id)
    check(
        started.ok and started.class_id == class_id
            and started.role_id == role_id,
        "An eligible character must start only its own class trial."
    )
    check(
        base:claim(user_id).reason == "AdvancementQuestNotReady",
        "A class path cannot skip its required dungeon clear."
    )
    check(
        quests:record_event(user_id, {
            EventId = "advanced-path-" .. tostring(user_id),
            Type = "DungeonClear",
            TargetId = dungeon_id,
            Amount = 1,
        }).ok,
        "The chosen dungeon must progress this class's trial."
    )
    local claim = base:claim(user_id)
    local character = assert(profiles:get_character(user_id, 1))
    check(
        claim.ok and claim.class_id == class_id
            and character.ClassAdvancement.ActiveClassId == class_id
            and character.ClassAdvancement.CompletedByRace[
                race_id
            ][class_id] == true,
        "Every advanced path must persist its own race-bound class."
    )
    check(
        character.Identity.BaseClassId == base_class_id
            and character.Identity.ClassId == base_class_id,
        "Advancement must preserve the existing base combat family."
    )
    check(
        base:claim(user_id).reason == "AdvancementAlreadyCompleted",
        "Every new path must be claimable only once."
    )
end

seed_candidate(5207, "Human", "Ranger")
local level_check = profiles:mutate(5207, function(profile: any)
    profile.Characters.Slot1.Level = 19
end)
check(level_check, "Level-19 Ranger must be seeded.")
check(
    base:start_trial(5207).reason == "AdvancementRequirementsNotMet",
    "Advancement remains unavailable below level 20."
)

-- Saving and reloading a class must preserve the advanced role identity.
check(profiles:save(5206, "AdvancedClassTest"),
    "Advanced Ranger must persist to profile storage.")
check(profiles:release(5206, "AdvancedClassTest"),
    "Advanced Ranger profile must release cleanly.")
check(profiles:load(5206) ~= nil, "Advanced Ranger must reload.")
check(
    base:build_snapshot(5206).ActiveClassId == "ElfWindrunner"
        and base:build_snapshot(5206).Completed == true,
    "Reload must retain the Elf Ranger's completed class path."
)

print(string.format("[Class Advancement Tests] PASS: %d assertions.", assertions))
