--!strict
-- Validates newly playable advanced skills without rerunning every dungeon.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Core = ServerScriptService:WaitForChild("Core")
local Shared = ReplicatedStorage.Core.Shared
local Services = Core.Services

local InMemoryProfileAdapter = require(
    Core.Adapters:WaitForChild("InMemoryProfileAdapter")
)
local ProfileService = require(Services:WaitForChild("ProfileService"))
local InventoryService = require(Services:WaitForChild("InventoryService"))
local LoadoutService = require(Services:WaitForChild("LoadoutService"))
local SkillProgressionService = require(
    Services:WaitForChild("SkillProgressionService")
)
local ProgressionRuntimeState = require(
    Services:WaitForChild("ProgressionRuntimeState")
)
local SkillProgressionDefinitions = require(
    Shared:WaitForChild("SkillProgressionDefinitions")
)
local TrainerCatalogues = require(
    Shared:WaitForChild("TrainerCatalogues")
)
local SecondaryClassDefinitions = require(
    Shared:WaitForChild("SecondaryClassDefinitions")
)
local CombatSkills = require(
    ReplicatedStorage.Combat.Shared:WaitForChild("SkillDefinitions")
)

local assertions = 0

-- Args:
--   condition (boolean): Required class or combat eligibility invariant.
--   message (string): Expected behaviour when an assertion fails.
-- Returns:
--   nil: Records one checked behaviour or raises with a useful message.
local function check(condition: boolean, message: string)
    assertions += 1
    assert(condition, "[Advanced Class Skill Tests] " .. message)
end

local profiles = ProfileService.new(InMemoryProfileAdapter.new())
local inventory = InventoryService.new(profiles)
local loadout = LoadoutService.new(profiles)
local skills = SkillProgressionService.new(
    profiles, inventory, loadout
)

local cases = {
    {
        UserId = 6101,
        RaceId = "Human",
        BaseClassId = "Fighter",
        ClassId = "HumanVanguard",
        TrainerId = "VanguardTrainer",
        SkillId = "VanguardChallenge",
        Kind = "Melee",
    },
    {
        UserId = 6102,
        RaceId = "Elf",
        BaseClassId = "Fighter",
        ClassId = "ElfThornwarden",
        TrainerId = "ThornwardenTrainer",
        SkillId = "ThornwardenBash",
        Kind = "Melee",
    },
    {
        UserId = 6103,
        RaceId = "Human",
        BaseClassId = "Ranger",
        ClassId = "HumanSharpshooter",
        TrainerId = "SharpshooterTrainer",
        SkillId = "SharpshooterPierce",
        Kind = "RangerProjectile",
    },
    {
        UserId = 6104,
        RaceId = "Elf",
        BaseClassId = "Ranger",
        ClassId = "ElfWindrunner",
        TrainerId = "WindrunnerTrainer",
        SkillId = "WindrunnerVolley",
        Kind = "RangerVolley",
    },
}

-- Args:
--   path (any): One race-specific advanced class test case.
-- Returns:
--   nil: Sets up an eligible character but without its advancement.
local function seed_character(path: any)
    assert(profiles:load(path.UserId), "Test profile must load.")
    local ok = profiles:mutate(path.UserId, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = 20
        character.Identity = {
            Version = 1,
            RaceId = path.RaceId,
            BaseClassId = path.BaseClassId,
            ClassId = path.BaseClassId,
            CreationStage = "Complete",
        }
        character.Progression.SkillPointEntitlement = 60
        if path.BaseClassId == "Ranger" then
            character.Equipment.Weapon = "apprentice_longbow"
        end
    end)
    check(ok, "Advanced skill fixture must seed a loaded character.")
end

for _, path in ipairs(cases) do
    seed_character(path)
    local user_id = path.UserId
    local before = profiles:get_character(user_id)

    check(
        SecondaryClassDefinitions.resolve(
            path.RaceId, path.BaseClassId
        ).Id == path.ClassId,
        "The class progression path must match race and base class."
    )
    check(
        TrainerCatalogues.resolve_for_character(
            path.TrainerId, before
        ).reason == "TrainerRestricted",
        "Advanced trainer must reject a base-class-only character."
    )
    check(
        skills:learn_trainer_skill(
            user_id, path.SkillId
        ).reason == "ClassCannotTeachSkill",
        "Advanced ability cannot be bought without advancement."
    )

    local unlocked = profiles:mutate(user_id, function(profile: any)
        profile.Characters.Slot1.ClassAdvancement.ActiveClassId =
            path.ClassId
    end)
    check(unlocked, "Advanced class must be activated in test profile.")
    local advanced = profiles:get_character(user_id)

    check(
        TrainerCatalogues.can_offer(
            path.TrainerId, advanced, path.SkillId
        ).ok == true,
        "The correct advanced trainer must offer its exclusive skill."
    )
    check(
        TrainerCatalogues.can_offer(
            path.TrainerId, advanced, "ArcSlash"
        ).ok == false,
        "Advanced trainers must reject arbitrary skill requests."
    )
    local learned = skills:learn_trainer_skill(
        user_id, path.SkillId
    )
    check(
        learned.ok and learned.rank == 1,
        "The advanced ability must cost SP and enter the skill book."
    )
    check(
        skills:learn_trainer_skill(
            user_id, path.SkillId
        ).reason == "AlreadyKnown",
        "Buying an advanced skill twice must not duplicate its cost."
    )
    local definition = SkillProgressionDefinitions.get(path.SkillId)
    local combat = CombatSkills.get(path.SkillId)
    check(
        definition.AllowedAdvancedClasses[1] == path.ClassId
            and combat.KIND == path.Kind
            and CombatSkills.get_for_rank(path.SkillId, 3).ID
                == path.SkillId,
        "The advanced ability must have valid ranked combat definitions."
    )

    local current = profiles:get_character(user_id)
    ProgressionRuntimeState.set_character(user_id, current)
    local usable, reason =
        ProgressionRuntimeState.is_skill_usable(
            user_id, path.SkillId, {}
        )
    check(
        usable == true,
        "Purchased advanced skill must be executable: "
            .. tostring(reason)
    )

    local stripped = profiles:mutate(user_id, function(profile: any)
        profile.Characters.Slot1.ClassAdvancement.ActiveClassId = nil
    end)
    check(stripped, "Changing class must refresh the owner profile.")
    ProgressionRuntimeState.set_character(
        user_id, profiles:get_character(user_id)
    )
    local still_usable, denied =
        ProgressionRuntimeState.is_skill_usable(
            user_id, path.SkillId, {}
        )
    check(
        still_usable == false and denied == "AdvancedClassRequired",
        "A learned skill must be unusable after losing its advanced class."
    )

    local other_class = cases[
        if path.RaceId == "Human" then 2 else 1
    ].ClassId
    local spoofed = profiles:mutate(user_id, function(profile: any)
        profile.Characters.Slot1.ClassAdvancement.ActiveClassId =
            other_class
    end)
    check(spoofed, "Alternative class must seed for fail-closed test.")
    ProgressionRuntimeState.set_character(
        user_id, profiles:get_character(user_id)
    )
    check(
        select(2, ProgressionRuntimeState.is_skill_usable(
            user_id, path.SkillId, {}
        )) == "AdvancedClassRequired",
        "A different advanced class must not use this specialization."
    )
    ProgressionRuntimeState.clear_character(user_id)
end

print(string.format(
    "[Advanced Class Skill Tests] PASS: %d assertions.", assertions
))
