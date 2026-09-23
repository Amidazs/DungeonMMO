--!strict
-- Independently authored DungeonMMO level-30 launch parity audit.
-- Source rank counts are reference targets, not playable legacy skills.
local Shared = script.Parent
local Branches = require(Shared.C4FirstTransferBranches)
local ScoutInventory = require(Shared.C4ScoutSkillInventory)
local Careers = require(Shared.OriginalFirstTransferDefinitions)
local Classes = require(Shared.ClassProgressionDefinitions)
local Skills = require(Shared.SkillProgressionDefinitions)

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
        then ScoutInventory.get("Elf") else nil
    local levels, total = if source then source_counts(source)
        else {}, nil
    local authored = authored_skills(branch_id)
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
        -- A legacy skill mapping and a currently playable analogue
        -- do NOT demonstrate all original level-20/24/28 rank purchases.
        ExactSourceRankCoverageCertified = false,
        LaunchSkillCatalogueReady = false,
        Status = if source then "SkillRankParityOutstanding"
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
            end
        end
    end
    return {
        LevelCap = LAUNCH_CAP,
        FirstTransferBranches = #records,
        SourceAuditedBranches = source_audited,
        VerifiedCompleteBranches = 0,
        Branches = records,
        ReleaseSkillGatePassed = false,
    }
end

return table.freeze(Coverage)
