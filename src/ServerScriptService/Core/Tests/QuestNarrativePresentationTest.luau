--!strict
-- Contract tests for reusable Adventure narrative presentation.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Core.Shared
local QuestDefinitions = require(Shared.QuestDefinitions)
local Narratives = require(Shared.QuestNarrativeDefinitions)
local Presenter = require(Shared.QuestNarrativePresenter)

local checks = 0

--[[
Counts one narrative-presentation assertion.

Args:
    condition (boolean): Expected presentation invariant.
    label (string): Diagnostic failure description.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(
        condition,
        "[Quest Narrative Presentation] " .. label
    )
end

--[[
Checks that one dialogue collection contains readable text.

Args:
    lines (any): Candidate dense dialogue list.
    label (string): Quest and phase description.

Returns:
    nil: Raises when the collection is empty or malformed.
]]
local function check_lines(lines: any, label: string)
    check(
        type(lines) == "table" and #lines >= 1,
        label .. " has at least one line"
    )

    for _, line in ipairs(lines) do
        check(
            type(line) == "string" and line ~= "",
            label .. " contains readable dialogue"
        )
    end
end

--[[
Runs catalogue coverage, continuity and action-state checks.

Args:
    None.

Returns:
    nil: Prints a stable pass marker after all checks succeed.
]]
local function main()
    local adventures = QuestDefinitions.adventures()

    for _, adventure in ipairs(adventures) do
        local narrative = Narratives.get(adventure.Id)
        check(
            narrative ~= nil,
            adventure.Id .. " has a narrative"
        )
        check(
            type(narrative.Speaker) == "string"
                and narrative.Speaker ~= "",
            adventure.Id .. " has a speaker"
        )
        check_lines(
            narrative.Start,
            adventure.Id .. " start"
        )
        check_lines(
            narrative.Progress,
            adventure.Id .. " progress"
        )
        check_lines(
            narrative.Ready,
            adventure.Id .. " ready"
        )
        check_lines(
            narrative.Complete,
            adventure.Id .. " complete"
        )
    end

    for _, quest_id in ipairs({
        "HiddenWardDiscovery",
        "TempleResonancePuzzle",
        "FractureTrail",
        "TempleWardDefense",
    }) do
        check(
            Presenter.speaker(quest_id)
                == "Temple Archivist",
            quest_id
                .. " keeps the Temple narrative voice"
        )
    end

    local worldroot = assert(
        QuestDefinitions.get("WorldrootRelic")
    )
    local button, enabled, mode =
        Presenter.action_state(
            worldroot,
            {
                Active = {},
                Completed = {},
            }
        )
    check(
        button == "Start Quest"
            and enabled == true
            and mode == "Start",
        "available quest opens start dialogue"
    )

    local mine = assert(
        QuestDefinitions.get("MineEchoes")
    )
    button, enabled, mode =
        Presenter.action_state(
            mine,
            {
                Active = {},
                Completed = {},
            }
        )
    check(
        button == "Locked"
            and enabled == false
            and mode == nil,
        "missing prerequisite remains locked"
    )

    button, enabled, mode =
        Presenter.action_state(
            worldroot,
            {
                Active = {
                    WorldrootRelic = {
                        Ready = false,
                    },
                },
                Completed = {},
            }
        )
    check(
        button == "Review"
            and enabled == true
            and mode == "Review",
        "active quest can review progress dialogue"
    )

    button, enabled, mode =
        Presenter.action_state(
            worldroot,
            {
                Active = {
                    WorldrootRelic = {
                        Ready = true,
                    },
                },
                Completed = {},
            }
        )
    check(
        button == "Claim Reward"
            and enabled == true
            and mode == "Claim",
        "ready quest opens turn-in dialogue"
    )

    button, enabled, mode =
        Presenter.action_state(
            worldroot,
            {
                Active = {},
                Completed = {
                    WorldrootRelic = true,
                },
            }
        )
    check(
        button == "Completed"
            and enabled == false
            and mode == nil,
        "completed quest cannot be accepted again"
    )

    check(
        Presenter.text(
            "TempleWardDefense",
            "Start"
        ):find("Resonance Ward", 1, true) ~= nil,
        "defense start dialogue explains the ward"
    )
    check(
        Presenter.text(
            "TempleResonancePuzzle",
            "Review"
        ):find("Moon, Root, Flame", 1, true) ~= nil,
        "puzzle progress dialogue preserves the rune order"
    )
    check(
        Presenter.text(
            "MissingQuest",
            "Start"
        ) == "No additional dialogue is available for this Adventure.",
        "missing narrative fails to readable fallback text"
    )

    print(
        ("[Quest Narrative Presentation] PASS: %d assertions")
            :format(checks)
    )
end

main()
