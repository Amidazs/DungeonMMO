--!strict
-- Focused C4-inspired Rogue bleed gate and actual rank-effect contract.

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Shared = RS.Core.Shared
local Schema = require(Shared.ProfileSchema)
local Skills = require(Shared.SkillProgressionDefinitions)
local Unlocks = require(Shared.SkillUnlockRules)
local Trainers = require(Shared.TrainerCatalogues)
local Classes = require(Shared.ClassProgressionDefinitions)
local Combat = require(RS.Combat.Shared.SkillDefinitions)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)

local assertions = 0

--[[
Asserts one focused bleed progression invariant.

Args:
    condition (boolean): Required server-owned content or gate condition.
    message (string): Failure reason.

Returns:
    nil: Increments successful assertions or raises an error.
]]
local function check(condition: boolean, message: string)
    assertions += 1
    assert(condition, "[C4 Rogue Bleed] " .. message)
end

--[[
Builds a fresh owned character for early/late progression checks.

Args:
    class_id (string): Starting combat class of the character.

Returns:
    any: A mutable isolated server-profile character.
]]
local function make_character(class_id: string): any
    local character = Schema.create_default(77591)
        .Characters.Slot1
    character.Identity.RaceId = "Human"
    character.Identity.BaseClassId = class_id
    character.Identity.ClassId = class_id
    character.Identity.CreationStage = "Complete"
    character.Equipment.Weapon = "marauder_sword"
    return character
end

--[[
Seeds only the exact already-earned skill progression in this test.

Args:
    character (any): Mutable isolated test character.
    skill_id (string): Basic skill to mark as earned.
    rank (number): Purchased basic rank.
    proficiency (number): Earned use proficiency.

Returns:
    nil: Updates this in-memory test character's owned skills.
]]
local function seed(
    character: any, skill_id: string, rank: number,
    proficiency: number
)
    character.Progression.Skills[skill_id] = {
        Known = true,
        PurchasedRank = rank,
        Proficiency = proficiency,
    }
end

local definition = assert(Skills.get("LaceratingCut"))
local rogue = make_character("Rogue")
check(not Unlocks.can_show(rogue, definition),
    "Bleed must be hidden below its level and mastery")
check(not Trainers.can_offer(
    "RogueTrainer", rogue, "LaceratingCut"
).ok, "Trainer cannot reveal unearned bleed")
check(Classes.can_teach("Rogue", "LaceratingCut"),
    "Rogue class must authorize bleed training")
check(not Classes.can_teach("Ranger", "LaceratingCut"),
    "Foreign class must not teach bleed")

rogue.Level = 24
check(not Unlocks.can_show(rogue, definition),
    "Level alone cannot reveal advanced bleed")
for _, requirement in ipairs(definition.Prerequisites) do
    seed(
        rogue, requirement.SkillId,
        requirement.Rank - 1, requirement.Proficiency
    )
end
check(not Unlocks.can_show(rogue, definition),
    "Partial purchased prerequisites may not reveal bleed")
for _, requirement in ipairs(definition.Prerequisites) do
    seed(
        rogue, requirement.SkillId,
        requirement.Rank, requirement.Proficiency - 1
    )
end
check(not Unlocks.can_show(rogue, definition),
    "Purchased rank alone cannot substitute use mastery")
for _, requirement in ipairs(definition.Prerequisites) do
    seed(
        rogue, requirement.SkillId,
        requirement.Rank, requirement.Proficiency
    )
end
check(Unlocks.can_show(rogue, definition),
    "Fully mastered Rogue must see level-24 bleed")
check(Trainers.can_offer(
    "RogueTrainer", rogue, "LaceratingCut"
).ok, "Earned Rogue must see bleed at authorized trainer")
check(not Unlocks.can_train(rogue, definition, 2),
    "Rank two requires character level 32")

seed(rogue, "LaceratingCut", 1, 119)
rogue.Level = 32
check(not Unlocks.can_train(rogue, definition, 3),
    "Undefined third bleed rank may not be bought")
local rank_one = assert(Combat.get_for_rank("LaceratingCut", 1))
local rank_two = assert(Combat.get_for_rank("LaceratingCut", 2))
check(rank_one.KIND == "Melee" and rank_two.KIND == "Melee",
    "Both ranks need a real server melee executor")
check(rank_one.BLEED_TICK_COUNT == 3
    and rank_one.BLEED_TICK_DAMAGE > 0,
    "Rank one must apply positive server bleed ticks")
check(rank_two.BLEED_TICK_DAMAGE
    > rank_one.BLEED_TICK_DAMAGE,
    "Rank two must increase real periodic damage")
check(rank_two.BASE_DAMAGE > rank_one.BASE_DAMAGE,
    "Rank two must also improve actual direct damage")
check(rank_one.BLEED_TICK_INTERVAL >= 0.2
    and rank_one.BLEED_TICK_COUNT <= 6,
    "Bleed must have bounded duration and tick count")

local ranger = make_character("Ranger")
ranger.Level = 36
for _, requirement in ipairs(definition.Prerequisites) do
    seed(
        ranger, requirement.SkillId,
        requirement.Rank, requirement.Proficiency
    )
end
check(not Unlocks.can_show(ranger, definition),
    "Foreign class cannot reveal mastered Rogue bleed")
seed(rogue, "LaceratingCut", 1, 120)
check(Unlocks.can_train(rogue, definition, 2),
    "Level 32 and use mastery 120 must allow rank two")
rogue.Progression.Loadout[1] = "LaceratingCut"
Runtime.set_character(77591, rogue)
local usable, reason = Runtime.is_skill_usable(77591, "LaceratingCut")
check(usable,
    "Learned melee bleed blocked: " .. tostring(reason))
Runtime.clear_character(77591)

print(("[C4 Rogue Bleed] PASS: %d assertions."):format(assertions))
