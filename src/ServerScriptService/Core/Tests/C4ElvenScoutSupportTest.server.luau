--!strict
-- Elf-only renewal and calming-arrow rank/identity/effect contract.

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared
local Schema = require(Shared.ProfileSchema)
local Skills = require(Shared.SkillProgressionDefinitions)
local Unlocks = require(Shared.SkillUnlockRules)
local Trainers = require(Shared.TrainerCatalogues)
local Combat = require(RS.Combat.Shared.SkillDefinitions)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)

local LEVELS = {20, 24, 28, 32, 36}
local assertions = 0

--[[
Checks one Elf-restricted skill or actual effect assertion.

Args:
    condition (boolean): Expected server-owned invariant.
    description (string): Actionable failure message.

Returns:
    nil: Counts a pass or raises the focused error.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 Elven Scout] " .. description)
end

--[[
Makes a complete detached test character for one race and class.

Args:
    race_id (string): Elf or Human identity.
    class_id (string): Ranger or Rogue base class.
    user_id (number): Unique isolated runtime user.

Returns:
    any: Mutable server-owned fixture character.
]]
local function make_character(
    race_id: string, class_id: string, user_id: number
): any
    local character = Schema.create_default(user_id).Characters.Slot1
    character.Identity.RaceId = race_id
    character.Identity.ClassId = class_id
    character.Identity.BaseClassId = class_id
    character.Identity.CreationStage = "Complete"
    character.Level = 36
    character.Equipment.Weapon = if class_id == "Ranger"
        then "apprentice_longbow" else "marauder_sword"
    return character
end

--[[
Confirms all fifteen ranks, correct class/race and real positive effects.

Args:
    skill_id (string): Elf-only recovery or calming shot.
    class_id (string): Valid owning class.
    user_id (number): Isolated combat-state user.
    effect_field (string): Server-effect value that must grow by rank.

Returns:
    nil: Verifies actual rank effects and runtime race gating.
]]
local function check_ladder(
    skill_id: string, class_id: string,
    user_id: number, effect_field: string
)
    local definition = assert(Skills.get(skill_id))
    check(definition.MaxRank == 15,
        skill_id .. " must have all fifteen first-transfer ranks")
    local human = make_character("Human", class_id, user_id + 100)
    for _, required in ipairs(definition.Prerequisites or {}) do
        human.Progression.Skills[required.SkillId] = {
            Known = true,
            PurchasedRank = required.Rank,
            Proficiency = required.Proficiency,
        }
    end
    check(not Unlocks.can_show(human, definition),
        skill_id .. " appeared in Human skill preview")
    local foreign_offer = Trainers.can_offer(
        class_id .. "Trainer", human, skill_id
    )
    check(not foreign_offer.ok,
        skill_id .. " appeared in a Human trainer")
    local elf = make_character("Elf", class_id, user_id)
    for _, required in ipairs(definition.Prerequisites or {}) do
        elf.Progression.Skills[required.SkillId] = {
            Known = true,
            PurchasedRank = required.Rank,
            Proficiency = required.Proficiency,
        }
    end
    elf.Level = 19
    check(not Unlocks.can_show(elf, definition),
        skill_id .. " appeared below level twenty")
    elf.Level = 20
    check(Unlocks.can_show(elf, definition),
        skill_id .. " missing after unlocking its actual basic skill")
    check(Trainers.can_offer(
        class_id .. "Trainer", elf, skill_id
    ).ok, "Earned Elf trainer cannot offer " .. skill_id)

    local last_effect = 0
    for rank = 1, 15 do
        local level = LEVELS[math.ceil(rank / 3)]
        elf.Level = level - 1
        check(not Unlocks.can_train(elf, definition, rank),
            skill_id .. " rank ignored character level")
        elf.Level = level
        check(Unlocks.can_train(elf, definition, rank),
            skill_id .. " rank missing at correct level")
        local effect = assert(Combat.get_for_rank(skill_id, rank))
        check(effect[effect_field] > last_effect,
            skill_id .. " rank did not increase real effect")
        last_effect = effect[effect_field]
    end
    elf.Level = 36
    elf.Progression.Skills[skill_id] = {
        Known = true, PurchasedRank = 15, Proficiency = 560,
    }
    elf.Progression.Loadout[1] = skill_id
    Runtime.set_character(user_id, elf)
    local usable, reason = Runtime.is_skill_usable(user_id, skill_id)
    check(usable, skill_id .. " rejected Elf: " .. tostring(reason))
    Runtime.clear_character(user_id)
    human.Progression.Skills[skill_id] = {
        Known = true, PurchasedRank = 15, Proficiency = 560,
    }
    human.Progression.Loadout[1] = skill_id
    Runtime.set_character(user_id + 100, human)
    check(not Runtime.is_skill_usable(user_id + 100, skill_id),
        skill_id .. " allowed Human runtime to bypass race gate")
    Runtime.clear_character(user_id + 100)
end

check_ladder("ElvenRenewal", "Ranger", 77611, "TOTAL_HEAL")
check_ladder("ElvenRenewal", "Rogue", 77612, "TOTAL_HEAL")
check_ladder("ElvenCalmingShot", "Ranger", 77613,
    "THREAT_REDUCTION_FRACTION")
local renewal = assert(Combat.get_for_rank("ElvenRenewal", 1))
check(renewal.SELF_ONLY == true and renewal.KIND == "MageHeal",
    "Elf renewal must use authoritative self-only healing")
local calm = assert(Combat.get_for_rank("ElvenCalmingShot", 15))
check(calm.KIND == "RangerProjectile"
    and calm.THREAT_REDUCTION_FRACTION <= 0.85
    and calm.MAX_TARGETS == 1,
    "Elf charm must reduce threat only for one confirmed target")
print(("[C4 Elven Scout] PASS: %d assertions."):format(assertions))
