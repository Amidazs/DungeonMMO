--!strict
-- Five original C4 Rogue/Scout source ranks must buy and authorize
-- genuine paid server critical-damage effects, never passive icons.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared
local Schema = require(Shared.ProfileSchema)
local Progression = require(Shared.SkillProgressionDefinitions)
local Rules = require(Shared.SkillUnlockRules)
local Trainers = require(Shared.TrainerCatalogues)
local Combat = require(RS.Combat.Shared.SkillDefinitions)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)
local Toggles = require(SSS.Combat.ScoutCriticalToggleService)

local LEVELS = {20, 24, 28, 32, 36}
local BONUSES = {0.06, 0.08, 0.10, 0.12, 0.14}
local checks = 0

--[[
Checks a source-level skill requirement or actual execution contract.

Args:
    condition (boolean): Required C4 source/runtime fact.
    label (string): Precise test failure location.

Returns:
    nil: Records a successful assertion or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Scout Critical Toggle] " .. label)
end

--[[
Constructs an earned, isolated Rogue/Ranger character at source level.

Args:
    user_id (number): Unique isolated server progression owner.
    race_id (string): Human or Elf original C4 source.
    class_id (string): DungeonMMO Rogue or Ranger branch.

Returns:
    any: Mutable detached character with valid normal equipment.
]]
local function character_for(
    user_id: number, race_id: string, class_id: string
): any
    local character = Schema.create_default(user_id).Characters.Slot1
    character.Identity.RaceId = race_id
    character.Identity.BaseClassId = class_id
    character.Identity.ClassId = class_id
    character.Identity.CreationStage = "Complete"
    character.Equipment.Weapon = if class_id == "Ranger"
        then "apprentice_longbow" else "scout_dagger"
    character.Level = 36
    return character
end

--[[
Verifies exact purchased rank levels, class trainer and skill ownership.

Args:
    user_id (number): Test user for isolated runtime snapshot.
    race_id (string): Original Human Rogue or Elven Scout.
    class_id (string): Ranger or Rogue owning the purchased skill.

Returns:
    nil: Rejects premature visibility, training and cross-class access.
]]
local function check_skill(
    user_id: number, race_id: string, class_id: string
)
    local definition = assert(Progression.get(
        "ScoutCriticalPowerToggle"
    ))
    local character = character_for(user_id, race_id, class_id)
    check(definition.MaxRank == 5
        and definition.Kind == "Support",
        "C4 toggle must have five actually purchasable support ranks")
    check(Trainers.can_offer(
        class_id .. "Trainer", character,
        "ScoutCriticalPowerToggle"
    ).ok, "Legitimate trainer cannot sell critical-power toggle")
    for rank, level in ipairs(LEVELS) do
        local effect = assert(Combat.get_for_rank(
            "ScoutCriticalPowerToggle", rank
        ))
        check(definition.RankLevels[rank] == level
            and effect.KIND == "ScoutToggle",
            "Original source rank is not a real combat toggle")
        check(math.abs(
            effect.CRITICAL_DAMAGE_BONUS - BONUSES[rank]
        ) < 0.0001, "Critical-power bonus does not increase by rank")
        check(effect.STAMINA_COST > 0
            and effect.UPKEEP_STAMINA_PER_SECOND > 0,
            "Critical toggle must consume initial and continuous stamina")
        character.Level = level - 1
        check(not Rules.can_train(character, definition, rank),
            "Source critical toggle rank learned before class level")
        character.Level = level
        if rank > 1 then
            character.Progression.Skills.ScoutCriticalPowerToggle = {
                Known = true, PurchasedRank = rank - 1,
                Proficiency = 0,
            }
        end
        check(Rules.can_train(character, definition, rank),
            "Earned source critical toggle rank unavailable")
    end
    character.Level = 36
    character.Progression.Skills.ScoutCriticalPowerToggle = {
        Known = true, PurchasedRank = 5, Proficiency = 0,
    }
    character.Progression.Loadout[1] = "ScoutCriticalPowerToggle"
    Runtime.set_character(user_id, character)
    check(Runtime.is_skill_usable(
        user_id, "ScoutCriticalPowerToggle"
    ), "Owned/equipped critical toggle was rejected")
    Runtime.clear_character(user_id)

    character.Identity.BaseClassId = "Mage"
    character.Identity.ClassId = "Mage"
    check(not Rules.can_show(character, definition),
        "Mystic bypassed critical-power source class restrictions")
end

--[[
Runs source and effect contracts without faking a live player cast.

Args:
    None.

Returns:
    nil: Prints the count and the neutral default for absent toggle state.
]]
local function main()
    check_skill(99511, "Human", "Rogue")
    check_skill(99512, "Elf", "Ranger")
    check_skill(99513, "Human", "Ranger")
    check_skill(99514, "Elf", "Rogue")
    check(Toggles.get_bonus(nil) == 0,
        "Playerless server stance generated free critical damage")
    print(("[C4 Scout Critical Toggle] PASS: %d assertions")
        :format(checks))
end

main()
