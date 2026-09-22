--!strict
-- Source-verified C4 rank counts compared against real DungeonMMO ranks.
-- This is a gap report, never a fabricated "parity achieved" assertion.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared

local Targets = require(Shared:WaitForChild("C4SkillVolumeTargets"))
local Classes = require(Shared:WaitForChild("ClassProgressionDefinitions"))
local Skills = require(Shared:WaitForChild("SkillProgressionDefinitions"))

local checked = 0
local gaps = 0
local unmapped = 0

-- Returns one class's real authored training ranks, not a count of buttons.
--
-- Args:
--   base_class_id (string): Existing Fighter or Mage base class.
-- Returns:
--   ({[number]: number}, {string}): Per-level ranks and unassigned skills.
local function count_authored_ranks(base_class_id: string)
    local class = assert(Classes.get(base_class_id))
    local counts = {}
    local missing = {}
    local seen = {}

    for _, group in ipairs({
        class.StarterSkills, class.TeachableSkills,
    }) do
        for _, skill_id in ipairs(group) do
            if not seen[skill_id] then
                seen[skill_id] = true
                local skill = assert(Skills.get(skill_id))
                if type(skill.RankLevels) == "table" then
                    for rank = 1, skill.MaxRank do
                        local level = skill.RankLevels[rank]
                        if level then
                            counts[level] = (counts[level] or 0) + 1
                        else
                            table.insert(missing, skill_id .. ":" .. rank)
                        end
                    end
                else
                    table.insert(missing, skill_id)
                end
            end
        end
    end
    table.sort(missing)
    return counts, missing
end

-- Emits one explicit target/gap row per verified C4 reference bracket.
--
-- Args:
--   race_id (string): Human or Elf.
--   base_class_id (string): Fighter or Mage.
-- Returns:
--   nil: Prints data and increments audit counters.
local function report_class(race_id: string, base_class_id: string)
    local target = assert(Targets.get(race_id, base_class_id))
    local actual, missing = count_authored_ranks(base_class_id)
    for level, expected in pairs(target.Levels) do
        local authored = actual[level] or 0
        checked += 1
        if authored ~= expected then
            gaps += 1
        end
        print(string.format(
            "[C4 Volume] %s/%s lvl=%d source_ranks=%d "
                .. "authored_ranks=%d gap=%+d",
            race_id, base_class_id, level, expected,
            authored, expected - authored
        ))
    end
    unmapped += #missing
    print(string.format(
        "[C4 Volume] %s/%s unmapped_skill_ranks=%d",
        race_id, base_class_id, #missing
    ))
end

for _, race_id in ipairs({"Human", "Elf"}) do
    for _, base_class_id in ipairs({"Fighter", "Mage"}) do
        report_class(race_id, base_class_id)
    end
end

assert(checked >= 16, "Verified C4 early levels must be audited.")
local status = if gaps == 0 and unmapped == 0
    then "PARITY_IN_SCOPE_COMPLETE"
    else "PARITY_NOT_YET_COMPLETE"
print(string.format(
    "[C4 Volume] REPORT brackets=%d mismatched=%d "
        .. "unmapped_skill_ranks=%d %s",
    checked, gaps, unmapped, status
))
