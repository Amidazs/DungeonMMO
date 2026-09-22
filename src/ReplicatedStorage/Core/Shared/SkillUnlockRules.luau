--!strict
-- Character-level and earned-skill gates shared by trainers and quests.
local SkillDefinitions = require(
    script.Parent:WaitForChild("SkillProgressionDefinitions")
)

local SkillUnlockRules = {}

-- Reads a purchased rank and earned proficiency, never client-supplied
-- trainer preview fields.
--
-- Args:
--   character (any): Server-owned, selected character profile.
--   skill_id (string): Registered prerequisite skill.
-- Returns:
--   (number, number): Purchased rank and earned proficiency.
local function skill_progress(character: any, skill_id: string)
    local progression = type(character) == "table"
        and character.Progression
    local skills = type(progression) == "table"
        and progression.Skills
    local state = type(skills) == "table" and skills[skill_id]
    if type(state) ~= "table" or state.Known ~= true then
        return 0, 0
    end
    return math.max(0, math.floor(tonumber(state.PurchasedRank) or 0)),
        math.max(0, tonumber(state.Proficiency) or 0)
end

-- Validates a list of already-earned skills, including the maximum
-- purchased rank rather than a merely known skill or free proficiency.
--
-- Args:
--   character (any): Authoritative character profile.
--   requirements (any): List of SkillId, Rank and Proficiency thresholds.
-- Returns:
--   (boolean, string?, any?): Gate result, reason, unmet requirement.
function SkillUnlockRules.check_prerequisites(
    character: any,
    requirements: any
): (boolean, string?, any?)
    for _, requirement in ipairs(requirements or {}) do
        local definition = SkillDefinitions.get(requirement.SkillId)
        local rank, proficiency = skill_progress(
            character, requirement.SkillId
        )
        local required_rank = requirement.Rank or 1
        if not definition or rank < required_rank then
            return false, "PrerequisiteSkillRank", requirement
        end
        if proficiency < (requirement.Proficiency or 0) then
            return false, "PrerequisiteSkillProficiency", requirement
        end
    end
    return true, nil, nil
end

-- Checks the next trainable skill rank and its earned prerequisite skills.
--
-- Args:
--   character (any): Authoritative selected character profile.
--   definition (any): Registered skill metadata, never client metadata.
--   target_rank (number): Proposed rank to unlock or purchase.
-- Returns:
--   (boolean, string?, any?): Gate result, reason and missing requirement.
function SkillUnlockRules.can_train(
    character: any,
    definition: any,
    target_rank: number
): (boolean, string?, any?)
    if type(character) ~= "table"
        or type(definition) ~= "table"
        or type(target_rank) ~= "number"
        or target_rank < 1
        or target_rank > definition.MaxRank
    then
        return false, "InvalidSkillRank", nil
    end

    local rank_levels = definition.RankLevels
    local required_level = if type(rank_levels) == "table"
        then rank_levels[target_rank]
        else definition.MinimumLevel or 1
    if (tonumber(character.Level) or 0) < required_level then
        return false, "CharacterLevelTooLow", {
            RequiredLevel = required_level,
        }
    end

    return SkillUnlockRules.check_prerequisites(
        character, definition.Prerequisites
    )
end

-- Checks the distinct full-mastery prerequisites for a class trial.
--
-- Args:
--   character (any): Selected profile including real rank/proficiency.
--   quest (any): Registered class advancement quest definition.
-- Returns:
--   (boolean, string?, any?): Gate result and specific unmet requirement.
function SkillUnlockRules.can_start_trial(
    character: any,
    quest: any
): (boolean, string?, any?)
    if type(character) ~= "table" or type(quest) ~= "table" then
        return false, "InvalidTrial", nil
    end
    local required_level = quest.MinimumLevel or 1
    if (tonumber(character.Level) or 0) < required_level then
        return false, "CharacterLevelTooLow", {
            RequiredLevel = required_level,
        }
    end
    return SkillUnlockRules.check_prerequisites(
        character, quest.SkillPrerequisites
    )
end

return table.freeze(SkillUnlockRules)
