--!strict
-- First-tier Mystic debuff gates and real server NPC damage/cadence.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Shared = RS.Core.Shared
local Schema = require(Shared.ProfileSchema)
local Progression = require(Shared.SkillProgressionDefinitions)
local Unlocks = require(Shared.SkillUnlockRules)
local Trainers = require(Shared.TrainerCatalogues)
local Combat = require(RS.Combat.Shared.SkillDefinitions)
local Weakening = require(SSS.Combat.EnemyWeakeningService)
local Damage = require(SSS.Combat.EnemyDamageMultiplierRules)

local assertions = 0

--[[
Checks a sourced skill or a real outgoing enemy-combat condition.

Args:
    condition (boolean): Server-owned invariant to verify.
    description (string): Focused Studio failure explanation.

Returns:
    nil: Counts a passing assertion or raises on failure.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 Enemy Weakening] " .. description)
end

--[[
Creates an isolated saved-style starting Mystic for trainer gates.

Args:
    race_id (string): Human or Elf original Mystic race.

Returns:
    any: Mutable profile character with prerequisite skill rank.
]]
local function mystic(race_id: string): any
    local character = Schema.create_default(90771).Characters.Slot1
    character.Identity.RaceId = race_id
    character.Identity.BaseClassId = "Mage"
    character.Identity.ClassId = "Mage"
    character.Identity.CreationStage = "Complete"
    character.Equipment.Weapon = "apprentice_arcane_wand"
    character.Level = 14
    character.Progression.Skills.MysticWindBolt = {
        Known = true, PurchasedRank = 2, Proficiency = 0,
    }
    return character
end

--[[
Verifies actual class, race, level, trainer and authored rank gates.

Args:
    None.

Returns:
    nil: Checks both source-class skills without modifying live players.
]]
local function check_training()
    for _, race_id in {"Human", "Elf"} do
        local character = mystic(race_id)
        for _, skill_id in {"MysticFeebleCurse", "ElvenMysticLanguor"} do
            local skill = assert(Progression.get(skill_id))
            local permitted = skill_id == "MysticFeebleCurse"
                or race_id == "Elf"
            check(Unlocks.can_show(character, skill) == permitted,
                "Incorrect race or prerequisite for " .. skill_id)
            check(Trainers.can_offer(
                "MageTrainer", character, skill_id
            ).ok == permitted, "Incorrect trainer offer " .. skill_id)
            local definition = assert(Combat.get_for_rank(skill_id, 1))
            check(definition.KIND == "MagicProjectile"
                and definition.BASE_DAMAGE > 0
                and definition.MANA_COST > 0
                and definition.DEBUFF_SECONDS == 6,
                "Curse must have a mana cost and a real damaging hit")
            character.Level = 13
            check(not Unlocks.can_show(character, skill),
                "Curse was offered before its level-fourteen gate")
            character.Level = 14
        end
    end
end

--[[
Checks non-stacking live status against authoritative attack outputs.

Args:
    None.

Returns:
    nil: Destroys the isolated NPC after verifying effect and expiry.
]]
local function check_enemy_effect()
    local enemy = Instance.new("Model")
    enemy.Name = "C4WeakeningIsolatedEnemy"
    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = enemy
    enemy.Parent = workspace

    enemy:SetAttribute("DungeonDamageMultiplier", 1.5)
    check(not Weakening.apply(enemy, 0.9, 0, 3),
        "Out-of-bounds weakness should be rejected")
    check(Weakening.apply(enemy, 0.2, 0, 0.08),
        "A living NPC should accept power weakness")
    check(math.abs(Damage.get(enemy) - 1.2) < 0.001,
        "NPC outgoing physical damage was not reduced")
    check(Weakening.apply(enemy, 0, 0.2, 0.08),
        "Elven attack-rate impairment was rejected")
    check(math.abs(Weakening.get_interval_multiplier(enemy) - 1.25)
        < 0.001, "The next genuine enemy attack was not delayed")
    check(math.abs(Damage.get(enemy) - 1.2) < 0.001,
        "Distinct power and rate weaknesses should coexist")
    check(Weakening.apply(enemy, 0.1, 0.1, 0.08),
        "A weaker recast should refresh the status")
    check(math.abs(Damage.get(enemy) - 1.2) < 0.001,
        "A weaker recast overwrote an active stronger effect")
    task.wait(0.15)
    check(Damage.get(enemy) == 1.5,
        "Damage reduction survived its authored expiry")
    check(Weakening.get_interval_multiplier(enemy) == 1,
        "NPC attack-rate reduction survived its expiry")
    enemy:Destroy()
end

--[[
Runs only the new source and server effect contracts.

Args:
    None.

Returns:
    nil: Prints the result without rerunning older dungeon suites.
]]
local function main()
    check_training()
    check_enemy_effect()
    print(("[C4 Enemy Weakening] PASS: %d assertions.")
        :format(assertions))
end

main()
