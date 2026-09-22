--!strict
-- C4 Human Mystic life drain must heal only from real dealt NPC damage.

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
Checks one skill-gating or actual rank-effects contract.

Args:
    condition (boolean): Expected server-owned healing skill behavior.
    description (string): Source-level or race-specific diagnostic.

Returns:
    nil: Counts a passing check or stops on a failure.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 Life Drain] " .. description)
end

--[[
Makes a detached Mystic profile with legitimate prerequisite magic.

Args:
    user_id (number): Isolated progression runtime identity.
    race_id (string): Human or Elf source Mystic identity.

Returns:
    any: Fully defined selected Mage character used only in tests.
]]
local function make_mystic(user_id: number, race_id: string): any
    local character = Schema.create_default(user_id).Characters.Slot1
    character.Identity.RaceId = race_id
    character.Identity.BaseClassId = "Mage"
    character.Identity.ClassId = "Mage"
    character.Identity.CreationStage = "Complete"
    character.Level = 14
    character.Equipment.Weapon = "apprentice_arcane_wand"
    return character
end

--[[
Tests Human-only level gates, mastered previous magic, real rank
effect and restriction of foreign-race or unequipped heal casting.

Args:
    None.

Returns:
    nil: Emits a passing count only after both ranks are validated.
]]
local function main()
    local definition = assert(Skills.get("MysticLifeDrain"))
    local human = make_mystic(77841, "Human")
    local elf = make_mystic(77842, "Elf")

    check(definition.MaxRank == 2
        and definition.RankLevels[1] == 14
        and definition.RankLevels[2] == 14,
        "Human drain must have two source level-14 ranks")
    check(not Unlocks.can_show(human, definition),
        "Unmastered Human Mage should not see Life Drain")
    human.Progression.Skills.MysticWindBolt = {
        Known = true, PurchasedRank = 2, Proficiency = 0,
    }
    human.Level = 13
    check(not Unlocks.can_show(human, definition),
        "Life Drain appeared before source level 14")
    human.Level = 14
    check(Unlocks.can_show(human, definition),
        "Human Mystic cannot see earned Life Drain")
    check(Trainers.can_offer(
        "MageTrainer", human, "MysticLifeDrain"
    ).ok, "Human Mage trainer cannot sell earned Life Drain")
    check(not Unlocks.can_show(elf, definition),
        "Human-only Life Drain appeared to an Elven Mystic")
    check(not Trainers.can_offer(
        "MageTrainer", elf, "MysticLifeDrain"
    ).ok, "Elven Mage trainer offered Human-only Life Drain")

    local previous_damage = 0
    local previous_fraction = 0
    for rank = 1, 2 do
        local effect = assert(Combat.get_for_rank(
            "MysticLifeDrain", rank
        ))
        check(effect.KIND == "MagicProjectile"
            and effect.MANA_COST > 0
            and effect.BASE_DAMAGE > previous_damage
            and effect.LIFE_DRAIN_FRACTION > previous_fraction
            and effect.LIFE_DRAIN_FRACTION <= 0.30,
            "Life Drain rank does not improve real bounded lifesteal")
        previous_damage = effect.BASE_DAMAGE
        previous_fraction = effect.LIFE_DRAIN_FRACTION
    end

    human.Progression.Skills.MysticLifeDrain = {
        Known = true, PurchasedRank = 2, Proficiency = 65,
    }
    human.Progression.Loadout[1] = "MysticLifeDrain"
    Runtime.set_character(77841, human)
    local usable, reason = Runtime.is_skill_usable(
        77841, "MysticLifeDrain"
    )
    check(usable, "Owned human Life Drain blocked: " .. tostring(reason))
    human.Equipment.Weapon = nil
    Runtime.set_character(77841, human)
    check(not Runtime.is_skill_usable(77841, "MysticLifeDrain"),
        "Life Drain ignored the equipped wand gate")
    Runtime.clear_character(77841)
    print(("[C4 Life Drain] PASS: %d assertions."):format(assertions))
end

main()
