--!strict
-- Real trainer purchase and save/reload for a mastered Rogue bleed skill.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared
local Core = SSS.Core

local ProfileService = require(Core.Services.ProfileService)
local Memory = require(Core.Adapters.InMemoryProfileAdapter)
local Inventory = require(Core.Services.InventoryService)
local Loadout = require(Core.Services.LoadoutService)
local Skills = require(Core.Services.SkillProgressionService)
local SkillDefinitions = require(Shared.SkillProgressionDefinitions)
local Snapshots = require(Core.Services.ProgressionSnapshotBuilder)

local USER_ID = 68523
local assertions = 0

--[[
Asserts one real skill-training and durable-profile invariant.

Args:
    condition (boolean): Whether the trusted operation was successful.
    description (string): Diagnostic for a failing progression gate.

Returns:
    nil: Records an assertion or stops the focused test.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 Bleed Training] " .. description)
end

--[[
Changes the isolated profile through the same mutation API as gameplay.

Args:
    profiles (any): In-memory profile service for this focused test.
    level (number): Authoritative test character level.
    rank_offset (number): Prerequisite purchased-rank deficit.
    mastery_offset (number): Prerequisite earned-mastery deficit.
    bleed_proficiency (number?): Existing bleed use proficiency.

Returns:
    nil: Stores only isolated server-side progression test state.
]]
local function set_progress(
    profiles: any,
    level: number,
    rank_offset: number,
    mastery_offset: number,
    bleed_proficiency: number?
)
    local definition = assert(SkillDefinitions.get("LaceratingCut"))
    check(profiles:mutate(USER_ID, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = level
        for _, required in ipairs(definition.Prerequisites) do
            character.Progression.Skills[required.SkillId] = {
                Known = true,
                PurchasedRank = required.Rank - rank_offset,
                Proficiency = required.Proficiency - mastery_offset,
            }
        end
        local learned = character.Progression.Skills.LaceratingCut
        if learned and bleed_proficiency then
            learned.Proficiency = bleed_proficiency
        end
    end), "Failed to seed isolated earned-skill requirements")
end

--[[
Exercises actual class, character-level, prerequisite, rank and reload
gates without accessing live Roblox player saves.

Args:
    None.

Returns:
    nil: Prints the real service training assertion count on success.
]]
local function main()
    local profiles = ProfileService.new(Memory.new())
    local skills = Skills.new(
        profiles, Inventory.new(profiles), Loadout.new(profiles)
    )
    check(profiles:load(USER_ID) ~= nil, "Cannot load test profile")
    check(profiles:mutate(USER_ID, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = 1
        character.Identity = {
            Version = 1, RaceId = "Human",
            BaseClassId = "Rogue", ClassId = "Rogue",
            CreationStage = "Complete",
        }
        character.Equipment.Weapon = "marauder_sword"
        character.Progression.SkillPointEntitlement = 100
    end), "Test Rogue identity did not persist")

    check(Snapshots.build(assert(profiles:get_character(USER_ID)))
        .Skills.LaceratingCut == nil,
        "Level-one player must not see unearned bleed")
    check(not skills:learn_trainer_skill(
        USER_ID, "LaceratingCut"
    ).ok, "Level-one player cannot train bleed")
    set_progress(profiles, 24, 1, 0, nil)
    check(not skills:learn_trainer_skill(
        USER_ID, "LaceratingCut"
    ).ok, "Missing basic purchased ranks must block bleed")
    set_progress(profiles, 24, 0, 1, nil)
    check(not skills:learn_trainer_skill(
        USER_ID, "LaceratingCut"
    ).ok, "Missing basic use proficiency must block bleed")
    set_progress(profiles, 24, 0, 0, nil)
    check(skills:learn_trainer_skill(
        USER_ID, "LaceratingCut"
    ).rank == 1, "Mastered Rogue must purchase first bleed rank")
    check(skills:purchase_rank(
        USER_ID, "LaceratingCut"
    ).reason == "CharacterLevelTooLow",
        "Rank two cannot bypass level 32")
    set_progress(profiles, 32, 0, 0, 119)
    check(skills:purchase_rank(
        USER_ID, "LaceratingCut"
    ).reason == "ProficiencyThresholdNotMet",
        "Rank two cannot bypass earned bleed mastery 120")
    set_progress(profiles, 32, 0, 0, 120)
    check(skills:purchase_rank(
        USER_ID, "LaceratingCut"
    ).rank == 2, "Mastered level-32 Rogue must purchase rank two")
    check(skills:purchase_rank(
        USER_ID, "LaceratingCut"
    ).reason == "MaxRank",
        "Third bleed rank must remain unavailable")
    check(profiles:save(USER_ID, "C4BleedTraining"),
        "Rank-two bleed must save in isolated profile")
    check(profiles:release(USER_ID, "C4BleedTraining"),
        "Rank-two bleed profile must release")
    check(profiles:load(USER_ID) ~= nil,
        "Saved bleed profile must reload")
    check(profiles:get_character(USER_ID).Progression.Skills
        .LaceratingCut.PurchasedRank == 2,
        "Reload lost trained level-32 bleed rank")
    print(("[C4 Bleed Training] PASS: %d assertions."):format(
        assertions
    ))
end

main()
