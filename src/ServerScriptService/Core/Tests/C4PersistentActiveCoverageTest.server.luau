--!strict
-- Launch-cap persistent active skill coverage against the pinned C4 tree.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CombatDefinitions = require(
    ReplicatedStorage.Combat.Shared.SkillDefinitions
)
local Shared = ReplicatedStorage.Core.Shared
local Effects = require(Shared.C4SkillEffectSource)
local Map = require(Shared.C4CreativeSkillSourceMap)
local ProgressionDefinitions = require(
    Shared.SkillProgressionDefinitions
)
local Tree = require(Shared.C4Level30SkillTreeSource)

local SCOPES = table.freeze({
    "HumanFighter",
    "HumanMystic",
    "ElvenFighter",
    "ElvenMystic",
    "HumanWarrior",
    "HumanKnight",
    "HumanRogue",
    "ElvenKnight",
    "ElvenScout",
})

local PERSISTENT_KINDS = table.freeze({
    Buff = true,
    HealthSurge = true,
    ScoutToggle = true,
    ScoutAccuracyToggle = true,
    IronvowCriticalToggle = true,
    IronvowAccuracyToggle = true,
})

local checks = 0

--[[
Counts one persistent-active catalogue assertion.

Args:
    valid (boolean): Expected launch-cap coverage condition.
    label (string): Diagnostic description for a failed assertion.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Persistent Active Coverage] " .. label)
end

--[[
Checks whether one progression definition belongs to the current launch base.

Legacy Rogue/Warrior class trees remain in the repository but are not part of
the current original Fighter/Mage identity model and must not pollute this
coverage gate.

Args:
    progression (any): Creative progression definition.

Returns:
    boolean: True for a current Fighter/Mage launch progression.
]]
local function is_current_base(progression: any): boolean
    for _, base_class in ipairs(
        progression.AllowedBaseClasses or {}
    ) do
        if base_class == "Fighter" or base_class == "Mage" then
            return true
        end
    end

    return false
end

--[[
Builds the reviewed active/toggle source mapping by creative rank.

The same creative rank may appear in inherited starter and first-transfer
scopes, but every occurrence must resolve to the same historical skill/rank.

Args:
    None.

Returns:
    (any, {string}): Mapping table plus any ambiguous/reviewed rows.
]]
local function source_active_ranks(): (any, {string})
    local mapped = {}
    local issues = {}

    for _, scope_id in ipairs(SCOPES) do
        local scope = assert(Tree.get(scope_id))

        for _, row in ipairs(scope.Rows) do
            local effect = Effects.get_rank(
                row.SkillId,
                row.SkillLevel
            )
            local operate_type = effect
                and effect.Sets.operateType

            if operate_type == "ACTIVE"
                or operate_type == "TOGGLE"
            then
                local link = Map.resolve(
                    scope_id,
                    row.SkillId,
                    row.SkillLevel
                )

                if link
                    and link.Status == "Candidate"
                    and type(link.CreativeSkillId) == "string"
                    and (tonumber(link.CreativeRank) or 0) >= 1
                then
                    local skill_id = link.CreativeSkillId
                    local rank = link.CreativeRank
                    local ranks = mapped[skill_id] or {}
                    local prior = ranks[rank]

                    if prior and (
                        prior.SkillId ~= row.SkillId
                        or prior.Rank ~= row.SkillLevel
                    ) then
                        table.insert(
                            issues,
                            skill_id .. "#" .. tostring(rank)
                                .. ":AmbiguousSourceRank"
                        )
                    else
                        ranks[rank] = {
                            SkillId = row.SkillId,
                            Rank = row.SkillLevel,
                        }
                        mapped[skill_id] = ranks
                    end

                    if link.Review ~= nil then
                        table.insert(
                            issues,
                            skill_id .. "#" .. tostring(rank)
                                .. ":ReviewRequired"
                        )
                    end
                end
            end
        end
    end

    table.sort(issues)
    return mapped, issues
end

--[[
Audits every persistent stat-effect rank actually reachable by level 30.

Args:
    mapped (any): Reviewed source active/toggle mapping by creative rank.

Returns:
    (number, number, {string}): Skill count, rank count and missing rows.
]]
local function audit_launch_ranks(
    mapped: any
): (number, number, {string})
    local skill_count = 0
    local rank_count = 0
    local missing = {}

    for skill_id, definition in pairs(
        CombatDefinitions.all()
    ) do
        local progression = ProgressionDefinitions.get(skill_id)

        if PERSISTENT_KINDS[definition.KIND]
            and progression
            and is_current_base(progression)
        then
            local has_launch_rank = false

            for rank, level in pairs(
                progression.RankLevels or {}
            ) do
                if type(rank) == "number"
                    and type(level) == "number"
                    and level <= 30
                then
                    has_launch_rank = true
                    rank_count += 1

                    if not (
                        mapped[skill_id]
                        and mapped[skill_id][rank]
                    ) then
                        table.insert(
                            missing,
                            skill_id .. "#" .. tostring(rank)
                        )
                    end
                end
            end

            if has_launch_rank then
                skill_count += 1
            end
        end
    end

    table.sort(missing)
    return skill_count, rank_count, missing
end

--[[
Runs the launch-cap persistent active source-coverage gate.

Args:
    None.

Returns:
    nil: Prints a bounded source-only success marker.
]]
local function main()
    local mapped, mapping_issues = source_active_ranks()
    local skill_count, rank_count, missing =
        audit_launch_ranks(mapped)

    check(
        #mapping_issues == 0,
        "persistent source mappings are unambiguous and review-free"
    )
    check(
        #missing == 0,
        "every reachable persistent active rank has a C4 source rank"
    )
    check(
        skill_count == 21,
        "exactly twenty-one persistent launch skills are in scope"
    )
    check(
        rank_count == 25,
        "exactly twenty-five reachable persistent ranks are source-covered"
    )

    print((
        "[C4 Persistent Active Coverage] SOURCE_ONLY_PASS: %d assertions "
        .. "skills=%d ranks=%d missing=0 reviews=0"
    ):format(checks, skill_count, rank_count))
end

main()
