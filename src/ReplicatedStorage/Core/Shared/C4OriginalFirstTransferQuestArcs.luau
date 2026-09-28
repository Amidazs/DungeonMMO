--!strict
-- Three-quest presentation arcs over the trusted first-transfer step ledger.

local SourceQuests = require(
    script.Parent:WaitForChild("C4OriginalFirstTransferQuestStages")
)

local QuestArcs = {}

local RANGE_BY_STEP_COUNT = table.freeze({
    [6] = table.freeze({
        table.freeze({1, 2}),
        table.freeze({3, 4}),
        table.freeze({5, 6}),
    }),
    [7] = table.freeze({
        table.freeze({1, 2}),
        table.freeze({3, 5}),
        table.freeze({6, 7}),
    }),
    [9] = table.freeze({
        table.freeze({1, 2}),
        table.freeze({3, 7}),
        table.freeze({8, 9}),
    }),
    [10] = table.freeze({
        table.freeze({1, 4}),
        table.freeze({5, 8}),
        table.freeze({9, 10}),
    }),
    [11] = table.freeze({
        table.freeze({1, 3}),
        table.freeze({4, 7}),
        table.freeze({8, 11}),
    }),
})

local CHAPTER_SUFFIXES = table.freeze({
    "The Call",
    "Field Trial",
    "Final Proof",
})

--[[
Builds one immutable three-quest advancement arc.

Args:
    source (any): Trusted first-transfer source quest definition.

Returns:
    any: Arc with three distinct player-facing quest definitions.
]]
local function build_arc(source: any): any
    local ranges = RANGE_BY_STEP_COUNT[#source.Steps]
    assert(
        ranges ~= nil,
        "FirstTransferQuestArcRangeMissing:"
            .. tostring(source.BranchId)
    )

    local quests = {}
    for index, range in ipairs(ranges) do
        table.insert(quests, table.freeze({
            Id = source.Id .. "_Quest" .. tostring(index),
            DisplayName = source.SourceTitle
                .. " — "
                .. CHAPTER_SUFFIXES[index],
            Index = index,
            StartStep = range[1],
            EndStep = range[2],
        }))
    end

    return table.freeze({
        Id = source.Id .. "_Arc",
        BranchId = source.BranchId,
        SourceQuestId = source.Id,
        QuestCount = #quests,
        Quests = table.freeze(quests),
    })
end

local ARCS = {}
for _, source in ipairs(SourceQuests.inventoried()) do
    ARCS[source.BranchId] = build_arc(source)
end

--[[
Returns the three-quest arc for one first-transfer branch.

Args:
    branch_id (string): Stable first-transfer branch identifier.

Returns:
    any?: Frozen quest arc when the branch is mapped.
]]
function QuestArcs.for_branch(branch_id: string): any?
    return ARCS[branch_id]
end

--[[
Returns the current visible quest inside a three-quest advancement arc.

Args:
    branch_id (string): Stable first-transfer branch identifier.
    step (number): Current trusted ordered step.
    ready (boolean?): Whether the underlying source ledger is complete.

Returns:
    any?: Current quest definition, including the final quest when ready.
]]
function QuestArcs.current(
    branch_id: string,
    step: number,
    ready: boolean?
): any?
    local arc = ARCS[branch_id]
    if not arc then
        return nil
    end

    if ready == true then
        return arc.Quests[#arc.Quests]
    end

    for _, quest in ipairs(arc.Quests) do
        if step >= quest.StartStep
            and step <= quest.EndStep
        then
            return quest
        end
    end

    return nil
end

--[[
Lists every mapped three-quest first-transfer arc.

Args:
    None.

Returns:
    {any}: Dense immutable arc list in source inventory order.
]]
function QuestArcs.all(): {any}
    local result = {}
    for _, source in ipairs(SourceQuests.inventoried()) do
        table.insert(
            result,
            assert(ARCS[source.BranchId])
        )
    end
    return table.freeze(result)
end

return table.freeze(QuestArcs)
