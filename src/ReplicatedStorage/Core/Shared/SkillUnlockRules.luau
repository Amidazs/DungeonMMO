--!strict
-- Character-level and earned-skill gates shared by trainers and quests.
local SkillDefinitions = require(
    script.Parent:WaitForChild("SkillProgressionDefinitions")
)
local Classes = require(
    script.Parent:WaitForChild("SecondaryClassDefinitions")
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

    local identity = character.Identity or {}
    local allowed_classes = definition.AllowedBaseClasses
    if type(allowed_classes) == "table" then
        local matches = false
        for _, class_id in ipairs(allowed_classes) do
            if identity.BaseClassId == class_id then
                matches = true
                break
            end
        end
        if not matches then
            return false, "WrongClass", nil
        end
    end

    local allowed_races = definition.AllowedRaces
    if type(allowed_races) == "table" then
        local correct_race = false
        for _, race_id in ipairs(allowed_races) do
            if identity.RaceId == race_id then
                correct_race = true
                break
            end
        end
        if not correct_race then
            return false, "WrongRace", nil
        end
    end

    local advanced = definition.AllowedAdvancedClasses
    if type(advanced) == "table" then
        local owned = character.ClassAdvancement
        local active = type(owned) == "table"
            and owned.ActiveClassId
        local matches = false
        for _, class_id in ipairs(advanced) do
            if active == class_id then
                matches = true
                break
            end
        end
        if not matches then
            return false, "AdvancedClassRequired", nil
        end

        local class = Classes.get(active)
        local history = type(owned) == "table"
            and owned.CompletedByRace
        local race_history = type(history) == "table"
            and history[identity.RaceId]
        if not class
            or class.RaceId ~= identity.RaceId
            or class.BaseClassId ~= identity.BaseClassId
            or type(race_history) ~= "table"
            or race_history[active] ~= true
        then
            return false, "AdvancedClassNotEarned", nil
        end
    end

    local rank_levels = definition.RankLevels
    local required_level = if type(rank_levels) == "table"
        then rank_levels[target_rank]
        else definition.MinimumLevel or 1
    if (tonumber(character.Level) or 1) < required_level then
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
    if (tonumber(character.Level) or 1) < required_level then
        return false, "CharacterLevelTooLow", {
            RequiredLevel = required_level,
        }
    end
    return SkillUnlockRules.check_prerequisites(
        character, quest.SkillPrerequisites
    )
end

-- Filters a trainer/journal catalogue before revealing an unknown,
-- level-locked or class-locked skill to that character.
--
-- Args:
--   character (any): Authoritative selected character profile.
--   definition (any): Registered skill metadata.
-- Returns:
--   boolean: Known skills stay visible; unknown skills require rank-1
--       eligibility, including current race/class, level and mastery.
function SkillUnlockRules.can_show(
    character: any,
    definition: any
): boolean
    if type(character) ~= "table"
        or type(definition) ~= "table"
    then
        return false
    end

    local progression = character.Progression
    local skills = type(progression) == "table"
        and progression.Skills
    local state = type(skills) == "table"
        and skills[definition.Id]
    -- Previously learned skills are not a loophole after a race change,
    -- class switch or loss of an earned prerequisite.
    return select(1, SkillUnlockRules.can_train(
        character, definition, 1
    ))
end

return table.freeze(SkillUnlockRules)
