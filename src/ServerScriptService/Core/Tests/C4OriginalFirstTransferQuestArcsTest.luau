--!strict
-- Every mapped first-transfer branch must expose three distinct quests.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Core.Shared
local Source = require(
    Shared.C4OriginalFirstTransferQuestStages
)
local Arcs = require(
    Shared.C4OriginalFirstTransferQuestArcs
)

local checks = 0

--[[
Counts one advancement-arc assertion.

Args:
    condition (boolean): Expected arc invariant.
    label (string): Diagnostic failure description.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[First Transfer Quest Arcs] " .. label)
end

--[[
Runs coverage and contiguous-range validation for every first-transfer arc.

Args:
    None.

Returns:
    nil: Prints a stable pass marker after all branches validate.
]]
local function main()
    local inventoried = Source.inventoried()
    local arcs = Arcs.all()

    check(
        #inventoried == 18,
        "all eighteen first-transfer source branches remain inventoried"
    )
    check(
        #arcs == #inventoried,
        "every inventoried branch has a quest arc"
    )

    local seen_ids = {}

    for _, source in ipairs(inventoried) do
        local arc = assert(
            Arcs.for_branch(source.BranchId)
        )

        check(
            arc.QuestCount == 3
                and #arc.Quests == 3,
            source.BranchId .. " has exactly three quests"
        )
        check(
            arc.Quests[1].StartStep == 1
                and arc.Quests[3].EndStep == #source.Steps,
            source.BranchId .. " arc covers first through final step"
        )

        local expected_step = 1
        for index, quest in ipairs(arc.Quests) do
            check(
                quest.Index == index
                    and quest.StartStep == expected_step
                    and quest.EndStep >= quest.StartStep,
                source.BranchId
                    .. " quest ranges are ordered and contiguous"
            )
            check(
                seen_ids[quest.Id] ~= true,
                "quest IDs stay globally unique: " .. quest.Id
            )
            seen_ids[quest.Id] = true
            expected_step = quest.EndStep + 1
        end

        check(
            expected_step == #source.Steps + 1,
            source.BranchId .. " arc has no step gaps or overlaps"
        )

        for step = 1, #source.Steps do
            local current = Arcs.current(
                source.BranchId,
                step,
                false
            )
            check(
                current ~= nil
                    and step >= current.StartStep
                    and step <= current.EndStep,
                source.BranchId
                    .. " resolves step "
                    .. tostring(step)
            )
        end

        check(
            Arcs.current(
                source.BranchId,
                #source.Steps + 1,
                true
            ) == arc.Quests[3],
            source.BranchId
                .. " completed ledger remains on final quest"
        )
    end

    print(
        ("[First Transfer Quest Arcs] PASS: %d assertions")
            :format(checks)
    )
end

main()
