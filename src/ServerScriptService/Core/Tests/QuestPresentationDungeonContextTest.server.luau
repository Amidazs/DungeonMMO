--!strict
-- Quest-to-dungeon/difficulty presentation regression coverage.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage.Core.Shared
local DungeonDefinitions = require(
    shared:WaitForChild("DungeonDefinitions")
)
local QuestDefinitions = require(
    shared:WaitForChild("QuestDefinitions")
)
local QuestPresentation = require(
    shared:WaitForChild("QuestPresentation")
)

local assertions = 0

--[[
Raises a focused test failure when a condition is false.

Args:
    condition (boolean): Expected condition.
    message (string): Failure context.

Returns:
    nil: Raises on failure and increments the assertion count on success.
]]
local function check(condition: boolean, message: string)
    assert(
        condition,
        "[Quest Presentation Dungeon Context] " .. message
    )
    assertions += 1
end

--[[
Returns one objective definition from a known Adventure quest.

Args:
    quest_id (string): Stable Adventure quest identifier.
    objective_id (string): Stable objective identifier.

Returns:
    any: Matching objective definition.
]]
local function objective(
    quest_id: string,
    objective_id: string
): any
    local definition = assert(
        QuestDefinitions.get(quest_id),
        "Missing quest " .. quest_id
    )

    for _, candidate in ipairs(definition.Objectives or {}) do
        if candidate.Id == objective_id then
            return candidate
        end
    end

    error(
        "Missing objective "
            .. objective_id
            .. " in "
            .. quest_id
    )
end

--[[
Returns whether one requirement contains a difficulty id.

Args:
    requirement (any): Dungeon requirement descriptor.
    difficulty_id (string): Stable difficulty identifier.

Returns:
    boolean: True when that depth can progress the objective.
]]
local function allows(
    requirement: any,
    difficulty_id: string
): boolean
    return QuestPresentation.requirement_allows_difficulty(
        requirement,
        difficulty_id
    )
end

local relic =
    QuestPresentation.objective_dungeon_requirement(
        objective("WorldrootRelic", "ClearTemple")
    )
check(relic ~= nil, "Worldroot Relic must resolve to a dungeon.")
check(
    relic.DungeonId == DungeonDefinitions.TEST_DUNGEON.Id,
    "Worldroot Relic must point to the Temple."
)
check(
    relic.DifficultyIds == nil,
    "Temple clear quest must accept any unlocked depth."
)
check(
    QuestPresentation.difficulty_text(relic)
        == "Any unlocked depth",
    "Temple clear quest must explain its open depth requirement."
)
check(
    allows(relic, "Depth1") and allows(relic, "Depth4"),
    "Temple clear quest must progress on Depth 1 or Depth 4."
)

local captain =
    QuestPresentation.objective_dungeon_requirement(
        objective(
            "MarauderCaptainBounty",
            "DefeatMarauderCaptain"
        )
    )
check(captain ~= nil, "Captain bounty must resolve to a dungeon.")
check(
    captain.DungeonId
        == DungeonDefinitions.TEST_DUNGEON.Id,
    "Captain bounty must point to the Temple."
)
check(
    QuestPresentation.difficulty_text(captain)
        == "Depth 1 or Depth 4",
    "Captain bounty must expose Depth 1 and Depth 4."
)
check(
    allows(captain, "Depth1"),
    "Captain bounty must progress on Depth 1."
)
check(
    not allows(captain, "Depth2"),
    "Captain bounty must not claim Depth 2 progress."
)
check(
    allows(captain, "Depth4"),
    "Captain bounty must progress on Depth 4 miniboss reuse."
)

local hidden_panel =
    QuestPresentation.objective_dungeon_requirement(
        objective(
            "HiddenWardDiscovery",
            "ActivateHiddenPanel"
        )
    )
check(
    hidden_panel ~= nil
        and hidden_panel.DungeonId
            == DungeonDefinitions.TEST_DUNGEON.Id,
    "Hidden-panel quest must point to the Temple."
)
check(
    QuestPresentation.difficulty_text(hidden_panel)
        == "Depth 1",
    "Hidden-panel quest must be marked Depth 1."
)
check(
    allows(hidden_panel, "Depth1")
        and not allows(hidden_panel, "Depth2"),
    "Hidden-panel quest must reject other depths."
)

local survey =
    QuestPresentation.objective_dungeon_requirement(
        objective("RuinSurvey", "ReachTempleInnerApproach")
    )
check(
    survey ~= nil
        and QuestPresentation.difficulty_text(survey)
            == "Depth 1",
    "Temple survey checkpoint must be Depth 1."
)

local foreman =
    QuestPresentation.objective_dungeon_requirement(
        objective(
            "CorruptedForemanBounty",
            "DefeatCorruptedForeman"
        )
    )
check(
    foreman ~= nil
        and foreman.DungeonId
            == DungeonDefinitions.ABANDONED_MINE.Id,
    "Foreman bounty must point to the Abandoned Mine."
)
check(
    QuestPresentation.difficulty_text(foreman)
        == "Depth 1 or Depth 4",
    "Foreman bounty must expose Depth 1 and Depth 4."
)
check(
    allows(foreman, "Depth1")
        and not allows(foreman, "Depth3")
        and allows(foreman, "Depth4"),
    "Foreman bounty depth compatibility must match authored bosses."
)

local hidden_definition = assert(
    QuestDefinitions.get("HiddenWardDiscovery")
)
local hidden_rows = QuestPresentation.dungeon_objective_rows(
    hidden_definition,
    {
        Objectives = {
            ActivateHiddenPanel = 1,
            CollectHiddenWardFragment = 0,
        },
        Ready = false,
    },
    DungeonDefinitions.TEST_DUNGEON.Id
)

check(
    #hidden_rows == 1,
    "Dungeon entrance must omit already-completed quest objectives."
)
check(
    hidden_rows[1].Id == "CollectHiddenWardFragment",
    "Dungeon entrance must show the remaining hidden-ward objective."
)
check(
    QuestPresentation.difficulty_text(hidden_rows[1])
        == "Depth 1",
    "Remaining hidden-ward objective must show Depth 1."
)

print(
    "[Quest Presentation Dungeon Context Tests] PASS: "
        .. tostring(assertions)
        .. " assertions."
)
