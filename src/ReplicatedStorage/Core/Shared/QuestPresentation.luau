--!strict
-- Shared formatting and Base navigation rules for Adventure quest UI.

local DungeonDefinitions = require(
    script.Parent:WaitForChild("DungeonDefinitions")
)
local DungeonDifficultyDefinitions = require(
    script.Parent:WaitForChild("DungeonDifficultyDefinitions")
)
local ItemDefinitions = require(
    script.Parent:WaitForChild("ItemDefinitions")
)
local QuestGiverDefinitions = require(
    script.Parent:WaitForChild("QuestGiverDefinitions")
)

local QuestPresentation = {}

--[[
Returns a readable catalogue name for one item.

Args:
    item_id (string): Stable item identifier.

Returns:
    string: Display name when known, otherwise the identifier.
]]
local function item_name(item_id: string): string
    local definition = ItemDefinitions.get(item_id)

    return if definition
        then tostring(definition.Name)
        else item_id
end

--[[
Returns the current integer progress for one objective.

Args:
    state (any): Active quest state.
    objective_id (string): Stable objective identifier.

Returns:
    number: Non-negative current progress.
]]
local function objective_progress(
    state: any,
    objective_id: string
): number
    local objectives = type(state) == "table"
        and state.Objectives
        or nil

    return math.max(
        0,
        math.floor(
            tonumber(
                type(objectives) == "table"
                    and objectives[objective_id]
                    or 0
            ) or 0
        )
    )
end

--[[
Returns the required integer progress for one objective.

Args:
    objective (any): Quest objective definition.

Returns:
    number: Required progress, always at least one.
]]
local function objective_required(objective: any): number
    return math.max(
        1,
        math.floor(tonumber(objective.Required) or 1)
    )
end

--[[
Returns a readable label for one Adventure objective.

Args:
    objective (any): Shared quest objective definition.

Returns:
    string: Player-facing objective label.
]]
function QuestPresentation.objective_label(objective: any): string
    if type(objective) ~= "table" then
        return "Objective"
    end

    local target_id = tostring(objective.TargetId or "")

    if objective.Type == "DungeonClear" then
        if target_id == "TestDungeon" then
            return "Clear the Temple"
        elseif target_id == "AbandonedMine" then
            return "Clear the Abandoned Mine"
        end
    elseif objective.Type == "CheckpointReached" then
        if string.find(target_id, "TestDungeon", 1, true) then
            return "Reach the Temple's inner approach"
        elseif string.find(target_id, "AbandonedMine", 1, true) then
            return "Reach the Mine's lower works"
        end
    elseif objective.Type == "EnemyDefeat" then
        if target_id == "forest_wolf" then
            return "Defeat Forest Wolves"
        elseif target_id == "marauder_captain" then
            return "Defeat the Marauder Captain"
        elseif target_id == "corrupted_foreman" then
            return "Defeat the Corrupted Foreman"
        end
    elseif objective.Type == "WorldInteraction" then
        if target_id == "TestDungeon:HiddenPanel:Room2" then
            return "Activate the faded Temple panel"
        end
    elseif objective.Type == "ItemCollected" then
        if target_id == "hidden_ward_fragment" then
            return "Collect the Hidden Ward Fragment"
        elseif target_id == "temple_resonance_shard" then
            return "Collect the Temple Resonance Shard"
        end
    elseif objective.Type == "EscortCompleted" then
        if target_id == "AbandonedMine:MineSurveyor" then
            return "Guide the Lost Surveyor through the Mine"
        end
    elseif objective.Type == "PuzzleCompleted" then
        if target_id == "TestDungeon:ResonanceLock:Room2" then
            return "Solve the Temple Resonance Lock"
        end
    elseif objective.Type == "DefenseCompleted" then
        if target_id == "TestDungeon:ResonanceWard:Room2" then
            return "Hold the Temple Resonance Ward"
        end
    end

    return tostring(
        objective.Id or objective.Type or "Objective"
    )
end

--[[
Builds ordered objective lines for one active quest.

Args:
    definition (any): Shared Adventure quest definition.
    state (any): Persisted active quest state.

Returns:
    {any}: Objective rows containing text and completion state.
]]
function QuestPresentation.objective_rows(
    definition: any,
    state: any
): {any}
    local rows = {}

    for _, objective in ipairs(definition.Objectives or {}) do
        local required = objective_required(objective)
        local current = math.min(
            required,
            objective_progress(state, objective.Id)
        )

        table.insert(rows, {
            Id = objective.Id,
            Text = string.format(
                "%s  %d/%d",
                QuestPresentation.objective_label(objective),
                current,
                required
            ),
            Current = current,
            Required = required,
            Complete = current >= required,
            Definition = objective,
        })
    end

    return rows
end

local DUNGEON_ORDER = table.freeze({
    DungeonDefinitions.TEST_DUNGEON.Id,
    DungeonDefinitions.ABANDONED_MINE.Id,
})

local DEPTH1_TARGETS = table.freeze({
    forest_wolf = DungeonDefinitions.TEST_DUNGEON.Id,
    hidden_ward_fragment = DungeonDefinitions.TEST_DUNGEON.Id,
    temple_resonance_shard = DungeonDefinitions.TEST_DUNGEON.Id,
})

local BOSS_TARGETS = table.freeze({
    marauder_captain = table.freeze({
        DungeonId = DungeonDefinitions.TEST_DUNGEON.Id,
        BossId = "MarauderCaptain",
    }),
    corrupted_foreman = table.freeze({
        DungeonId = DungeonDefinitions.ABANDONED_MINE.Id,
        BossId = "CorruptedForeman",
    }),
})

--[[
Returns difficulty IDs containing one runtime encounter or boss target.

Args:
    dungeon_id (string): Stable dungeon identifier.
    runtime_id (string?): Runtime encounter identifier to match.
    boss_id (string?): Boss content identifier to match.

Returns:
    {string}: Ordered matching difficulty IDs.
]]
local function matching_difficulties(
    dungeon_id: string,
    runtime_id: string?,
    boss_id: string?
): {string}
    local result = {}

    for _, difficulty in ipairs(
        DungeonDifficultyDefinitions.ordered(dungeon_id)
    ) do
        for _, encounter in ipairs(
            difficulty.EncounterSequence or {}
        ) do
            local runtime_matches = runtime_id ~= nil
                and encounter.RuntimeEncounterId == runtime_id
            local boss_matches = boss_id ~= nil
                and encounter.BossId == boss_id

            if runtime_matches or boss_matches then
                table.insert(result, difficulty.Id)
                break
            end
        end
    end

    return result
end

--[[
Resolves one quest objective to its dungeon and eligible difficulties.

A nil DifficultyIds value means every unlocked depth can progress it.

Args:
    objective (any): Shared Adventure objective definition.

Returns:
    any?: Dungeon requirement descriptor when the objective is dungeon-bound.
]]
function QuestPresentation.objective_dungeon_requirement(
    objective: any
): any?
    if type(objective) ~= "table" then
        return nil
    end

    local target_id = tostring(objective.TargetId or "")

    if objective.Type == "DungeonClear"
        and DungeonDefinitions.get(target_id)
    then
        return {
            DungeonId = target_id,
            DifficultyIds = nil,
        }
    end

    local depth1_dungeon = DEPTH1_TARGETS[target_id]
    if depth1_dungeon then
        return {
            DungeonId = depth1_dungeon,
            DifficultyIds = {"Depth1"},
        }
    end

    local checkpoint_dungeon, runtime_id = string.match(
        target_id,
        "^([^:]+):EncounterStart:(.+)$"
    )
    if checkpoint_dungeon
        and runtime_id
        and DungeonDefinitions.get(checkpoint_dungeon)
    then
        local difficulty_ids = matching_difficulties(
            checkpoint_dungeon,
            runtime_id,
            nil
        )
        if #difficulty_ids > 0 then
            return {
                DungeonId = checkpoint_dungeon,
                DifficultyIds = difficulty_ids,
            }
        end
    end

    if objective.Type == "EnemyDefeat" then
        local boss_target = BOSS_TARGETS[target_id]
        if boss_target then
            local difficulty_ids = matching_difficulties(
                boss_target.DungeonId,
                nil,
                boss_target.BossId
            )
            if #difficulty_ids > 0 then
                return {
                    DungeonId = boss_target.DungeonId,
                    DifficultyIds = difficulty_ids,
                }
            end
        end
    end

    for _, dungeon_id in ipairs(DUNGEON_ORDER) do
        local prefix = dungeon_id .. ":"
        if string.sub(target_id, 1, #prefix) == prefix then
            return {
                DungeonId = dungeon_id,
                DifficultyIds = {"Depth1"},
            }
        end
    end

    return nil
end

--[[
Returns incomplete objectives for one specific dungeon entrance.

Args:
    definition (any): Shared Adventure quest definition.
    state (any): Active quest state.
    dungeon_id (string): Dungeon represented by the entrance.

Returns:
    {any}: Objective rows extended with dungeon requirements.
]]
function QuestPresentation.dungeon_objective_rows(
    definition: any,
    state: any,
    dungeon_id: string
): {any}
    local result = {}

    for _, row in ipairs(
        QuestPresentation.objective_rows(definition, state)
    ) do
        if not row.Complete then
            local requirement =
                QuestPresentation.objective_dungeon_requirement(
                    row.Definition
                )
            if requirement
                and requirement.DungeonId == dungeon_id
            then
                row.DungeonId = requirement.DungeonId
                row.DifficultyIds = requirement.DifficultyIds
                table.insert(result, row)
            end
        end
    end

    return result
end

--[[
Returns whether one difficulty can progress a dungeon objective.

Args:
    requirement (any): Dungeon requirement or objective row.
    difficulty_id (string?): Selected difficulty identifier.

Returns:
    boolean: True when the selected depth can progress the objective.
]]
function QuestPresentation.requirement_allows_difficulty(
    requirement: any,
    difficulty_id: string?
): boolean
    if type(requirement) ~= "table"
        or type(difficulty_id) ~= "string"
    then
        return false
    end

    if requirement.DifficultyIds == nil then
        return true
    end

    for _, allowed_id in ipairs(requirement.DifficultyIds) do
        if allowed_id == difficulty_id then
            return true
        end
    end

    return false
end

--[[
Builds the player-facing difficulty text for one dungeon objective.

Args:
    requirement (any): Dungeon requirement or objective row.

Returns:
    string: "Any unlocked depth" or the eligible depth names.
]]
function QuestPresentation.difficulty_text(requirement: any): string
    if type(requirement) ~= "table"
        or requirement.DifficultyIds == nil
    then
        return "Any unlocked depth"
    end

    local names = {}
    for _, difficulty_id in ipairs(requirement.DifficultyIds) do
        local definition = DungeonDifficultyDefinitions.get(
            tostring(requirement.DungeonId or ""),
            difficulty_id
        )
        table.insert(
            names,
            definition and definition.DisplayName or difficulty_id
        )
    end

    return if #names > 0
        then table.concat(names, " or ")
        else "Any unlocked depth"
end

--[[
Builds a compact reward string for one Adventure quest.

Args:
    reward (any): Shared server-owned reward definition.

Returns:
    string: Readable gold and item reward summary.
]]
function QuestPresentation.reward_text(reward: any): string
    if type(reward) ~= "table" then
        return "No listed reward"
    end

    local pieces = {}
    local gold = math.max(
        0,
        math.floor(tonumber(reward.Gold) or 0)
    )

    if gold > 0 then
        table.insert(pieces, tostring(gold) .. " Gold")
    end

    local items = reward.Items
    if type(items) == "table" then
        for _, item in ipairs(items) do
            if type(item) == "table"
                and type(item.ItemId) == "string"
            then
                local quantity = math.max(
                    1,
                    math.floor(tonumber(item.Quantity) or 1)
                )
                table.insert(
                    pieces,
                    string.format(
                        "%dx %s",
                        quantity,
                        item_name(item.ItemId)
                    )
                )
            end
        end
    elseif type(reward.ItemId) == "string" then
        local quantity = math.max(
            1,
            math.floor(tonumber(reward.Quantity) or 1)
        )
        table.insert(
            pieces,
            string.format(
                "%dx %s",
                quantity,
                item_name(reward.ItemId)
            )
        )
    end

    if #pieces == 0 then
        return "No listed reward"
    end

    return table.concat(pieces, "  •  ")
end

--[[
Returns the physical Base quest giver responsible for one quest.

Args:
    quest_id (string): Stable Adventure quest identifier.

Returns:
    any?: Shared giver definition when known.
]]
function QuestPresentation.giver_for_quest(
    quest_id: string
): any?
    return QuestGiverDefinitions.for_quest(quest_id)
end

--[[
Returns the first incomplete objective row for one active quest.

Args:
    definition (any): Shared Adventure definition.
    state (any): Active quest state.

Returns:
    any?: First incomplete objective row.
]]
function QuestPresentation.first_incomplete(
    definition: any,
    state: any
): any?
    for _, row in ipairs(
        QuestPresentation.objective_rows(definition, state)
    ) do
        if not row.Complete then
            return row
        end
    end

    return nil
end

--[[
Returns the Base-side navigation target for a tracked quest.

Ready quests point to their physical giver. Incomplete quests point toward the
relevant dungeon/travel entrance. This presentation rule does not grant or
advance quest state.

Args:
    definition (any): Shared Adventure quest definition.
    state (any): Active quest state.

Returns:
    any?: Navigation descriptor with Kind, Id and Label.
]]
function QuestPresentation.base_navigation_target(
    definition: any,
    state: any
): any?
    local giver = QuestGiverDefinitions.for_quest(definition.Id)

    if type(state) == "table" and state.Ready == true then
        if not giver then
            return nil
        end

        return {
            Kind = "Giver",
            Id = giver.Id,
            Label = "Return to " .. tostring(giver.Speaker),
        }
    end

    local row = QuestPresentation.first_incomplete(
        definition,
        state
    )
    if not row then
        return nil
    end

    local requirement =
        QuestPresentation.objective_dungeon_requirement(
            row.Definition
        )

    if requirement
        and requirement.DungeonId
            == DungeonDefinitions.ABANDONED_MINE.Id
    then
        return {
            Kind = "Anchor",
            Id = "Base.Travel.Dwarves",
            Label = "Head toward the Abandoned Mine",
        }
    end

    if requirement
        and requirement.DungeonId
            == DungeonDefinitions.TEST_DUNGEON.Id
    then
        return {
            Kind = "Anchor",
            Id = "Base.TemplePortal",
            Label = "Head toward the Temple",
        }
    end

    return nil
end

return table.freeze(QuestPresentation)
