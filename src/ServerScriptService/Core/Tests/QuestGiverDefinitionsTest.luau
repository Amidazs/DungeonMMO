--!strict
-- Contract coverage for physical Adventure quest-giver definitions.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Core.Shared
local QuestDefinitions = require(Shared.QuestDefinitions)
local QuestGiverDefinitions = require(
    Shared.QuestGiverDefinitions
)
local Narratives = require(Shared.QuestNarrativeDefinitions)

local checks = 0

--[[
Counts one quest-giver definition assertion.

Args:
    condition (boolean): Expected definition invariant.
    label (string): Diagnostic failure description.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(
        condition,
        "[Quest Giver Definitions] " .. label
    )
end

--[[
Validates speaker coverage and one-to-one Adventure ownership.

Args:
    None.

Returns:
    nil: Prints a stable pass marker after all checks succeed.
]]
local function main()
    local givers = QuestGiverDefinitions.all()
    check(#givers == 8, "eight launch quest-giver roles exist")

    local seen = {}
    local quest_count = 0

    for _, giver in ipairs(givers) do
        check(
            type(giver.Id) == "string"
                and giver.Id ~= "",
            "giver has stable ID"
        )
        check(
            type(giver.Speaker) == "string"
                and giver.Speaker ~= "",
            giver.Id .. " has a readable speaker role"
        )
        check(
            type(giver.AnchorId) == "string"
                and giver.AnchorId:sub(1, 5) == "Base.",
            giver.Id .. " has a semantic Base anchor"
        )
        check(
            typeof(giver.Offset) == "CFrame",
            giver.Id .. " has a physical hub offset"
        )
        check(
            type(giver.QuestIds) == "table"
                and #giver.QuestIds >= 1,
            giver.Id .. " owns at least one Adventure"
        )

        for _, quest_id in ipairs(giver.QuestIds) do
            local quest = QuestDefinitions.get(quest_id)
            local narrative = Narratives.get(quest_id)

            check(
                quest ~= nil and quest.Kind == "Adventure",
                quest_id .. " resolves to an Adventure"
            )
            check(
                narrative ~= nil
                    and narrative.Speaker == giver.Speaker,
                quest_id .. " matches its giver speaker"
            )
            check(
                seen[quest_id] ~= true,
                quest_id .. " belongs to one giver only"
            )

            seen[quest_id] = true
            quest_count += 1
        end
    end

    local adventures = QuestDefinitions.adventures()
    check(
        quest_count == #adventures,
        "quest-giver map covers every current Adventure"
    )

    for _, adventure in ipairs(adventures) do
        check(
            seen[adventure.Id] == true,
            adventure.Id .. " has a physical quest-giver role"
        )
    end

    print(
        ("[Quest Giver Definitions] PASS: %d assertions")
            :format(checks)
    )
end

main()
