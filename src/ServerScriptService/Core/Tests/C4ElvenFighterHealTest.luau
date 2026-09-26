--!strict
-- C4 Elven Fighter level-fifteen three-rank self-renewal contract.

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared

local Schema = require(Shared.ProfileSchema)
local Skills = require(Shared.SkillProgressionDefinitions)
local Unlocks = require(Shared.SkillUnlockRules)
local Trainers = require(Shared.TrainerCatalogues)
local Combat = require(RS.Combat.Shared.SkillDefinitions)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)

local assertions = 0

--[[
Asserts a genuine Elven Fighter recovery effect or trainer gate.

Args:
    condition (boolean): Expected server-owned recovery or progression.
    description (string): Failure diagnostic.

Returns:
    nil: Counts the assertion or stops the focused contract.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 Elven Fighter Heal] " .. description)
end

--[[
Builds a complete Fighter of the specified source race.

Args:
    user_id (number): Isolated runtime identity.
    race_id (string): Human or Elf.

Returns:
    any: Detached mutable Fighter profile.
]]
local function make_fighter(user_id: number, race_id: string): any
    local fighter = Schema.create_default(user_id).Characters.Slot1
    fighter.Identity.RaceId = race_id
    fighter.Identity.BaseClassId = "Fighter"
    fighter.Identity.ClassId = "Fighter"
    fighter.Identity.CreationStage = "Complete"
    fighter.Level = 15
    return fighter
end

--[[
Checks source levels, all three distinct heal ranks and genuine ownership.

Args:
    None.

Returns:
    nil: Prints a count only after all race and effect checks succeed.
]]
local function main()
    local definition = assert(Skills.get("ElvenFighterRenewal"))
    check(definition.MaxRank == 3,
        "Elven Fighter recovery must contain all three source ranks")
    local fighter = make_fighter(77701, "Elf")
    fighter.Level = 14
    check(not Unlocks.can_show(fighter, definition),
        "Elf Fighter recovery must stay hidden before level fifteen")
    fighter.Level = 15
    check(Trainers.can_offer(
        "FighterTrainer", fighter, "ElvenFighterRenewal"
    ).ok, "The earned skill is missing from the Fighter trainer")

    local previous_heal = 0
    for rank = 1, 3 do
        check(definition.RankLevels[rank] == 15
            and Unlocks.can_train(fighter, definition, rank),
            "Elven Fighter source heal rank cannot be trained")
        local effect = assert(Combat.get_for_rank(
            "ElvenFighterRenewal", rank
        ))
        check(effect.KIND == "MageHeal" and effect.SELF_ONLY
            and effect.MANA_COST > 0
            and effect.TOTAL_HEAL > previous_heal,
            "Elemental recovery rank has no real self-heal effect")
        previous_heal = effect.TOTAL_HEAL
    end

    fighter.Progression.Skills.ElvenFighterRenewal = {
        Known = true, PurchasedRank = 3, Proficiency = 100,
    }
    fighter.Progression.Loadout[1] = "ElvenFighterRenewal"
    Runtime.set_character(77701, fighter)
    local usable, reason = Runtime.is_skill_usable(
        77701, "ElvenFighterRenewal"
    )
    check(usable, "Earned Elf recovery unusable: " .. tostring(reason))
    Runtime.clear_character(77701)

    for _, race_id in ipairs({"Human", "Orc"}) do
        local foreign = make_fighter(77702, race_id)
        check(not Unlocks.can_show(foreign, definition),
            "Elven-only recovery leaked to foreign Fighter race")
        foreign.Progression.Skills.ElvenFighterRenewal = {
            Known = true, PurchasedRank = 3, Proficiency = 100,
        }
        foreign.Progression.Loadout[1] = "ElvenFighterRenewal"
        Runtime.set_character(77702, foreign)
        check(not Runtime.is_skill_usable(
            77702, "ElvenFighterRenewal"
        ), "Forged recovery rank bypassed the race gate")
        Runtime.clear_character(77702)
    end
    print(("[C4 Elven Fighter Heal] PASS: %d assertions.")
        :format(assertions))
end

main()
