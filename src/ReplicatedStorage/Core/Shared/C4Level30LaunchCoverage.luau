--!strict
-- Independently authored DungeonMMO level-30 launch parity audit.
-- Source rank counts are reference targets, not playable legacy skills.
local Shared = script.Parent
local Branches = require(Shared.C4FirstTransferBranches)
local ScoutInventory = require(Shared.C4ScoutSkillInventory)
local WarriorKnight = require(Shared.C4WarriorKnightLevel30Sources)
local Careers = require(Shared.OriginalFirstTransferDefinitions)
local Classes = require(Shared.ClassProgressionDefinitions)
local Skills = require(Shared.SkillProgressionDefinitions)
local TrainerCatalogues = require(Shared.TrainerCatalogues)
local Mapping = require(Shared.C4Level30ClassSkillMap)

local Coverage = {}
local LAUNCH_CAP = 30
local BRACKETS = table.freeze({20, 24, 28})

--[[
Finds the registered source branch without enabling unimplemented races.

Args:
    branch_id (string): Stable source first-transfer branch identifier.

Returns:
    any?: Original reference metadata or nil for an unknown branch.
]]
local function find_branch(branch_id: string): any?
    for _, race_id in ipairs(Branches.races()) do
        for _, base_id in ipairs({"Fighter", "Mage"}) do
            for _, branch in ipairs(
                Branches.get(race_id, base_id) or {}
            ) do
                if branch.Id == branch_id then
                    return branch
                end
            end
        end
    end
    return nil
end

--[[
Lists implemented own-class skill identifiers within the launch cap.

Args:
    branch_id (string): Supported original DungeonMMO first-transfer path.

Returns:
    {string}: Actual authored class skills, not the legacy catalogue.
]]
local function authored_skills(branch_id: string): {string}
    local career = Careers.for_branch(branch_id)
    local definition = career and Classes.get(career.Id)
    local found = {}
    for _, skill_id in ipairs(
        definition and definition.TeachableSkills or {}
    ) do
        local skill = Skills.get(skill_id)
        if skill and skill.RankLevels then
            for _, level in pairs(skill.RankLevels) do
                if level <= LAUNCH_CAP then
                    table.insert(found, skill_id)
                    break
                end
            end
        end
    end
    table.sort(found)
    return found
end

--[[
Counts separately purchasable historical rank entries, not skill icons.

Args:
    source (any): Historical two-branch source bracket inventory.

Returns:
    ({[number]: number}, number): Bracket counts and total ranks at cap.
]]
local function source_counts(source: any): ({[number]: number}, number)
    local by_level = {}
    local total = 0
    for level, categories in pairs(source.Levels) do
        if level <= LAUNCH_CAP then
            local count = 0
            for _, ranks in pairs(categories) do
                count += ranks
            end
            by_level[level] = count
            total += count
        end
    end
    return by_level, total
end

--[[
Checks an exact source rank family against an earned career's registered
class, matching physical trainer and available 20/24/28 purchase schedule.

Args:
    career (any): Original DungeonMMO first-transfer career definition.
    source_category (string): Source family, not an old legacy skill ID.
    level (number): Exact historical training bracket.
    expected (number): Individually bought original ranks at that level.

Returns:
    boolean: Whether an original skill offers all rank rows in that band.
]]
local function category_matches(
    career: any, source_category: string,
    level: number, expected: number
): boolean
    local skill_id = Mapping.get(career.BranchId, source_category)
    local skill = skill_id and Skills.get(skill_id)
    local trainer = TrainerCatalogues.get(career.TrainerId)
    if not skill
        or not Classes.can_teach(career.Id, skill_id)
        or not trainer then
        return false
    end
    local taught = false
    for _, entry in ipairs(trainer.Skills) do
        if entry.SkillId == skill_id then taught = true end
    end
    if not taught then return false end
    local valid_family = false
    local valid_transfer = false
    for _, class_id in ipairs(skill.AllowedBaseClasses or {}) do
        if class_id == "Fighter" then valid_family = true end
    end
    for _, class_id in ipairs(
        skill.AllowedFirstTransferClasses or {}
    ) do
        if class_id == career.Id then valid_transfer = true end
    end
    if not valid_family or not valid_transfer then return false end
    local ranks = 0
    for _, rank_level in pairs(skill.RankLevels or {}) do
        if rank_level == level then ranks += 1 end
    end
    return ranks == expected
end

--[[
Measures each fully scheduled original source family by its real career.

Args:
    source (any): Complete existing historical 20/24/28 inventory.
    career (any): One actual earned-first-transfer trainer and class.

Returns:
    (number, number): Mapped individual ranks and still missing ranks.
]]
local function mapped_source_ranks(
    source: any, career: any
): (number, number)
    local mapped = 0
    local missing = 0
    for level, categories in pairs(source.Levels) do
        if level <= LAUNCH_CAP then
            for category, count in pairs(categories) do
                if category_matches(career, category, level, count) then
                    mapped += count
                else
                    missing += count
                end
            end
        end
    end
    return mapped, missing
end

--[[
Audits one first-transfer branch, distinguishing source rows from live code.

Args:
    branch_id (string): Registered source career being inspected.

Returns:
    any?: Scope, source-rank targets, real skill IDs and readiness state.
]]
function Coverage.for_branch(branch_id: string): any?
    local branch = find_branch(branch_id)
    if not branch then return nil end
    local career = Careers.for_branch(branch_id)
    local source = if branch_id == "HumanRogue"
        then ScoutInventory.get("Human")
        elseif branch_id == "ElvenScout"
        then ScoutInventory.get("Elf")
        else WarriorKnight.get(branch_id)
    local levels: {[number]: number} = {}
    local total: number? = nil
    if source then
        levels, total = source_counts(source)
    end
    local authored = authored_skills(branch_id)
    local mapped = 0
    local missing = if source then total or 0 else 0
    if source and career then
        mapped, missing = mapped_source_ranks(source, career)
    end
    return {
        BranchId = branch.Id,
        SourceClass = branch.SourceClass,
        SourceUrl = if source then source.SourceUrl
            else branch.SourceIndexUrl,
        LevelCap = LAUNCH_CAP,
        SourceBrackets = if source
            then BRACKETS else {},
        SourceRankEntriesByLevel = levels,
        SourceRankEntriesThroughCap = total,
        CurrentCareerId = if career then career.Id else nil,
        AuthoredClassSkillsThroughCap = authored,
        SourceInventoryAuditedThroughCap = source ~= nil,
        TrainerMappedRankEntries = mapped,
        MissingRankScheduleEntries = missing,
        SourceRankScheduleMapped = source ~= nil
            and career ~= nil and missing == 0,
        -- A legacy skill mapping and a currently playable analogue
        -- do NOT demonstrate all original level-20/24/28 rank purchases.
        ExactSourceRankCoverageCertified = false,
        LaunchSkillCatalogueReady = false,
        Status = if source and missing == 0
            then "RankScheduleMappedEffectsPending"
            elseif source and career then "SkillRankParityOutstanding"
            elseif source then "SourceRanksAuditedClassUnimplemented"
            else "HistoricalSourceAuditOutstanding",
    }
end

--[[
Summarizes all first-transfer branches for the level-30 launch gate.

Args:
    None.

Returns:
    any: Reference scope, branch totals and explicit incomplete status.
]]
function Coverage.report(): any
    local records = {}
    local source_audited = 0
    local schedule_mapped = 0
    for _, race_id in ipairs(Branches.races()) do
        for _, base_id in ipairs({"Fighter", "Mage"}) do
            for _, branch in ipairs(
                Branches.get(race_id, base_id) or {}
            ) do
                local record = Coverage.for_branch(branch.Id)
                table.insert(records, record)
                if record.SourceInventoryAuditedThroughCap then
                    source_audited += 1
                end
                if record.SourceRankScheduleMapped then
                    schedule_mapped += 1
                end
            end
        end
    end
    return {
        LevelCap = LAUNCH_CAP,
        FirstTransferBranches = #records,
        SourceAuditedBranches = source_audited,
        RankSchedulesMappedBranches = schedule_mapped,
        VerifiedCompleteBranches = 0,
        Branches = records,
        ReleaseSkillGatePassed = false,
    }
end

return table.freeze(Coverage)
