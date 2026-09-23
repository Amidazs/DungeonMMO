--!strict
-- Tracks original C4 FIRST-TRANSFER SKILLS independently from class-choice
-- quests; a mapped DungeonMMO analogue is not a complete C4 rank catalogue.
local Shared = script.Parent
local Branches = require(Shared.C4FirstTransferBranches)
local Scout = require(Shared.C4ScoutSkillInventory)
local SourceSkills = require(Shared.C4OriginalFirstTransferSkillSources)

local SkillCoverage = {}

local SOURCES = table.freeze({
    HumanRogue = "https://l2hub.info/c4/classes/rogue",
    ElvenScout = "https://l2hub.info/c4/classes/elven_scout",
    HumanWarrior = "https://l2hub.info/c4/classes/warrior",
    HumanKnight = "https://l2hub.info/c4/classes/knight",
})

--[[
Reports one original C4 branch's skill status without inventing ranks.

Args:
    branch (any): Exact source registry branch, not an arbitrary role name.

Returns:
    any: Mapped analogue count, missing source audit, source URL and gates.
]]
function SkillCoverage.for_branch(branch: any): any
    if type(branch) ~= "table"
        or type(branch.Id) ~= "string"
    then
        return nil
    end
    local mapped = branch.Id == "HumanRogue"
        or branch.Id == "ElvenScout"
    local inventory = if mapped
        then Scout.audit(branch.SourceRace)
        else nil
    local original_level20 = SourceSkills.get(branch.Id)
    return {
        ClassId = branch.Id,
        SourceUrl = if original_level20
            then original_level20.SourceUrl
            else SOURCES[branch.Id] or branch.SourceQuestUrl,
        SourceInventoryStatus = if mapped
            then "DungeonMMOAnaloguesMapped"
            elseif original_level20 then "OriginalC4Level20SourceMapped"
            else "OriginalC4InventoryNotYetAudited",
        ExactOriginalLevel20RankEntries = if original_level20
            then #original_level20.Level20 else 0,
        ImplementedOriginalLevel20Ranks = 0,
        MappedAnalogueRanks = if inventory then inventory.Functional else 0,
        InventoriedAnalogueRanks = if inventory then inventory.Raw else 0,
        ExactC4RankParityCertified = false,
        OriginalTrainerSkillGateImplemented = false,
        TransferQuestImplemented = false,
        GameplayComplete = false,
    }
end

--[[
Reports exact source coverage of all five races, never just Human/Elf.

Args:
    None.

Returns:
    any: Original class totals, analogue counts and incomplete status.
]]
function SkillCoverage.report(): any
    local total = 0
    local mapped = 0
    local not_inventoried = {}
    local source_20 = 0
    local level20_ranks = 0
    for _, race in ipairs(Branches.races()) do
        for _, base in ipairs({"Fighter", "Mage"}) do
            for _, branch in ipairs(Branches.get(race, base) or {}) do
                total += 1
                local record = SkillCoverage.for_branch(branch)
                if record.SourceInventoryStatus
                    == "DungeonMMOAnaloguesMapped"
                then
                    mapped += 1
                else
                    table.insert(not_inventoried, branch.Id)
                    if record.SourceInventoryStatus
                        == "OriginalC4Level20SourceMapped"
                    then
                        source_20 += 1
                        level20_ranks += record.ExactOriginalLevel20RankEntries
                    end
                end
            end
        end
    end
    return {
        OriginalFirstTransferClasses = total,
        AnalogueRankInventoriesMapped = mapped,
        OriginalInventoriesNotAudited = #not_inventoried,
        OriginalClassLevel20SourcesInventoried = source_20,
        OriginalLevel20RankEntriesCatalogued = level20_ranks,
        NotAuditedClassIds = not_inventoried,
        ExactC4FirstTransferSkillCatalogueComplete = false,
    }
end

return table.freeze(SkillCoverage)
