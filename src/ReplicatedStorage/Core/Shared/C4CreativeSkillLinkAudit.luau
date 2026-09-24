--!strict
-- Compare every original learning row with the exact existing candidate.
-- Source linkage is NOT proof of C4 skill power or effect equivalence.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared
local Combat = RS.Combat.Shared
local Tree = require(Shared.C4Level30SkillTreeSource)
local Source = require(Shared.C4SkillEffectSource)
local Map = require(Shared.C4CreativeSkillSourceMap)
local Classes = require(Shared.ClassProgressionDefinitions)
local Progression = require(Shared.SkillProgressionDefinitions)
local Skills = require(Combat.SkillDefinitions)

local Audit = {}

local CAREERS = table.freeze({
    HumanFighter = "Fighter", ElvenFighter = "Fighter",
    HumanMystic = "Mage", ElvenMystic = "Mage",
    HumanWarrior = "Ironvow", HumanKnight = "Oathguard",
    HumanRogue = "Ashenblade",
    ElvenKnight = "GreenwardWarden",
    ElvenScout = "GreenwardScout",
})

--[[
Enumerates actual teachable IDs without inferring source equivalence.

Args:
    class_id (string): Real starter or first-transfer class ID.

Returns:
    {[string]: boolean}: Current skill IDs available in that class.
]]
local function taught_ids(class_id: string): {[string]: boolean}
    local definition = assert(Classes.get(class_id))
    local ids = {}
    for _, field in ipairs({"StarterSkills", "TeachableSkills"}) do
        for _, id in ipairs(definition[field] or {}) do
            ids[id] = true
        end
    end
    return ids
end

--[[
Reports current MP as a comparable number only when both units exist.

Args:
    source (any): Pinned C4 rank-resolved XML fields.
    runtime (any?): Resolved current creative combat definition.

Returns:
    any: Source initial/final MP and current game mana, no HP inference.
]]
local function resource_costs(source: any, runtime: any?): any
    local sets = source.Sets
    local initial = sets.mpInitialConsume or 0
    local ongoing = sets.mpConsume or 0
    local present = sets.mpConsume ~= nil
        or sets.mpInitialConsume ~= nil
    local current = runtime and runtime.MANA_COST
    return {
        SourceInitialMp = initial,
        SourceOngoingMp = ongoing,
        SourceTotalMp = if present then initial + ongoing else nil,
        CreativeMana = current,
        SameNumber = if present and type(current) == "number"
            then current == initial + ongoing else nil,
        -- C4 source MP and a custom game mana pool may differ in scale.
        SameResourceEconomyCertified = false,
    }
end

--[[
Checks the exact skill ID, rank and learning level of one source row.

Args:
    scope_id (string): One of the nine verified original C4 paths.
    row (any): An original learning-tree row with its source rank.
    taught ({[string]: boolean}): Currently offered creative skill IDs.

Returns:
    any: Explicit gap or candidate, with a separate link issue if present.
]]
local function inspect_row(
    scope_id: string, row: any, taught: {[string]: boolean}
): any
    local record = Map.resolve(scope_id, row.SkillId, row.SkillLevel)
    local result = {
        Class = scope_id,
        SourceSkillId = row.SkillId,
        SourceSkillName = row.SkillName,
        SourceRank = row.SkillLevel,
        SourceLearnLevel = row.MinLevel,
        SourceSP = row.SP,
        Status = if record then record.Status else "Unexamined",
        Reason = record and record.Reason,
        CreativeSkillId = record and record.CreativeSkillId,
        CreativeRank = record and record.CreativeRank,
        Review = record and record.Review,
        ExactC4MechanicsCertified = false,
    }
    local source = Source.get_rank(row.SkillId, row.SkillLevel)
    if not source then
        result.Issue = "SourceEffectMissing"
        return result
    end
    if not record or record.Status ~= "Candidate" then
        return result
    end
    local skill = Progression.get(record.CreativeSkillId)
    if not skill then
        result.Issue = "CreativeProgressionMissing"
        return result
    end
    if not taught[record.CreativeSkillId] then
        result.Issue = "CreativeSkillNotTeachableInClass"
        return result
    end
    local actual_level = skill.RankLevels
        and skill.RankLevels[record.CreativeRank]
    result.CreativeLearnLevel = actual_level
    if actual_level == nil then
        result.Issue = "CreativeRankMissing"
    elseif actual_level ~= row.MinLevel then
        result.Issue = "LearningLevelMismatch"
    end
    local runtime = Skills.get_for_rank(
        record.CreativeSkillId, record.CreativeRank
    )
    result.SourceEffects = source
    result.CreativeEffects = runtime
    result.Resources = resource_costs(source, runtime)
    return result
end

--[[
Checks one race-specific original class without borrowing another path.

Args:
    scope_id (string): Exact C4 learning-tree class path.

Returns:
    any: Source rank coverage, unresolved gaps and creative extras.
]]
local function inspect_class(scope_id: string): any
    local source = assert(Tree.get(scope_id))
    local taught = taught_ids(assert(CAREERS[scope_id]))
    local mapped = {}
    local rows = {}
    local extras = {}
    for _, row in ipairs(source.Rows) do
        local record = inspect_row(scope_id, row, taught)
        table.insert(rows, record)
        if record.CreativeSkillId then
            mapped[record.CreativeSkillId] = true
        end
    end
    for id in pairs(taught) do
        if not mapped[id] then table.insert(extras, id) end
    end
    table.sort(extras)
    return {
        ScopeId = scope_id, SourceRows = #source.Rows,
        Rows = rows, CreativeSkillsOutsideThisSourceTree = extras,
    }
end

--[[
Audits all nine original paths without mutating live progression/combat.

Args:
    None.

Returns:
    any: Complete source-row linkage, gaps and mechanical parity flag.
]]
function Audit.report(): any
    local classes = {}
    local total = 0
    local candidates = 0
    local gaps = 0
    local errors = 0
    local differing_mp = 0
    for _, scope in ipairs(Tree.coverage().Scopes) do
        local class = inspect_class(scope.ScopeId)
        table.insert(classes, class)
        total += class.SourceRows
        for _, row in ipairs(class.Rows) do
            if row.Status == "Candidate" then
                candidates += 1
            elseif row.Status == "Missing" then
                gaps += 1
            end
            if row.Status == "Unexamined" or row.Issue then
                errors += 1
            end
            if row.Resources and row.Resources.SameNumber == false then
                differing_mp += 1
            end
        end
    end
    return {
        ClassPaths = #classes, SourceLearningRows = total,
        CandidateRows = candidates, ExplicitMissingRows = gaps,
        UnexaminedOrBrokenRows = errors,
        CandidateRowsWithDifferentMpNumbers = differing_mp,
        Classes = classes,
        ExactC4MechanicsCertified = false,
        LiveSkillMigrationComplete = false,
    }
end

return table.freeze(Audit)
