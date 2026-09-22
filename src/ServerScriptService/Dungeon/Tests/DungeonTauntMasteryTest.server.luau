--!strict
-- Focused zero-damage tank mastery, using real profile and bridge services.
local ServerScriptService = game:GetService("ServerScriptService")

local core = ServerScriptService:WaitForChild("Core")
local dungeon = ServerScriptService:WaitForChild("Dungeon")

local Memory = require(
    core.Adapters:WaitForChild("InMemoryProfileAdapter")
)
local Profiles = require(core.Services:WaitForChild("ProfileService"))
local Proficiency = require(
    core.Services:WaitForChild("ProficiencyService")
)
local Bridge = require(dungeon:WaitForChild("DungeonProgressionBridge"))

local USER_ID = 68101
local assertions = 0

-- Args:
--   condition (boolean): Expected server-owned mastery invariant.
--   message (string): Failure reason for a focused regression.
-- Returns:
--   nil: Counts the assertion or raises a useful error.
local function check(condition: boolean, message: string)
    assertions += 1
    assert(condition, "[Dungeon Taunt Mastery Tests] " .. message)
end

-- Args:
--   profiles (any): Loaded in-memory profile writer.
-- Returns:
--   nil: Seeds earned advancement and purchased combat abilities.
local function seed_tank(profiles: any)
    local saved = profiles:mutate(USER_ID, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = 24
        character.Identity = {
            Version = 1,
            RaceId = "Human",
            BaseClassId = "Fighter",
            ClassId = "Fighter",
            CreationStage = "Complete",
        }
        character.Progression.Skills.GuardBreaker = {
            Known = true,
            PurchasedRank = 3,
            Proficiency = 300,
        }
        character.Progression.Skills.ShieldBash = {
            Known = true,
            PurchasedRank = 3,
            Proficiency = 400,
        }
        character.Progression.Skills.VanguardChallenge = {
            Known = true,
            PurchasedRank = 1,
            Proficiency = 0,
        }
        character.ClassAdvancement.CompletedByRace.Human = {
            HumanVanguard = true,
        }
        character.ClassAdvancement.ActiveClassId = "HumanVanguard"
    end)
    check(saved, "A valid Vanguard profile must be persisted.")
end

-- Args:
--   profiles (any): Source of the character's actual skill record.
--   skill_id (string): Skill whose earned proficiency is inspected.
-- Returns:
--   number: Current persisted proficiency points.
local function proficiency(profiles: any, skill_id: string): number
    local character = assert(profiles:get_character(USER_ID))
    return character.Progression.Skills[skill_id].Proficiency
end

-- Args: None.
-- Returns:
--   nil: Verifies meaningful tank control, eligibility and mastery caps.
local function main()
    local profiles = Profiles.new(Memory.new())
    check(profiles:load(USER_ID) ~= nil, "Fixture must load.")
    seed_tank(profiles)

    local player = {UserId = USER_ID}
    local target = Instance.new("Model")
    target.Name = "TauntMastery_TARGET"
    target.Parent = workspace

    local active = true
    local encounter_id = "Room1"
    Bridge.bind({
        proficiency_service = Proficiency.new(profiles),
        encounter_service = {
            is_contribution_eligible = function(
                _self: any,
                user_id: number,
                _target: any
            ): boolean
                return active and user_id == USER_ID
            end,
            is_member_active = function(
                _self: any,
                user_id: number
            ): boolean
                return active and user_id == USER_ID
            end,
            get_current_id = function(_self: any): string
                return encounter_id
            end,
        },
    })

    local missed = Bridge.award_control(
        player, "VanguardChallenge", target, "Taunt", false
    )
    check(
        missed.granted == 0 and proficiency(
            profiles, "VanguardChallenge"
        ) == 0,
        "A taunt that did not affect an enemy cannot earn proficiency."
    )

    local effective = Bridge.award_control(
        player, "VanguardChallenge", target, "Taunt", true
    )
    check(
        effective.ok and effective.granted == 5
            and proficiency(profiles, "VanguardChallenge") == 5,
        "One meaningful zero-damage taunt must train its own skill."
    )

    active = false
    local disconnected = Bridge.award_control(
        player, "VanguardChallenge", target, "Taunt", true
    )
    check(
        disconnected.granted == 0
            and proficiency(profiles, "VanguardChallenge") == 5,
        "Disconnected or spectating members cannot farm taunt mastery."
    )

    active = true
    for _ = 1, 30 do
        Bridge.award_control(
            player, "VanguardChallenge", target, "Taunt", true
        )
    end
    check(
        proficiency(profiles, "VanguardChallenge") == 100,
        "Encounter cap must prevent repeated taunts from farming ranks."
    )

    encounter_id = "Room2"
    local next_room = Bridge.award_control(
        player, "VanguardChallenge", target, "Taunt", true
    )
    check(
        next_room.granted == 5
            and proficiency(profiles, "VanguardChallenge") == 105,
        "Real mastery may continue in a different eligible encounter."
    )

    target:Destroy()
    Bridge.bind({})
    print(string.format(
        "[Dungeon Taunt Mastery Tests] PASS: %d assertions.",
        assertions
    ))
end

main()
