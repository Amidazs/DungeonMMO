--!strict
-- Reusable presentation rules for Adventure Board quest conversations.

local Narratives = require(
    script.Parent:WaitForChild("QuestNarrativeDefinitions")
)

local Presenter = {}

--[[
Returns the player-facing action state for one Adventure.

Args:
    definition (any): Public Adventure quest definition.
    state (any): Current server-owned quest snapshot state.

Returns:
    string: Button text.
    boolean: Whether the action button is enabled.
    string?: Conversation mode when enabled.
]]
function Presenter.action_state(
    definition: any,
    state: any
): (string, boolean, string?)
    local completed = state
        and type(state.Completed) == "table"
        and state.Completed[definition.Id] == true

    if completed then
        return "Completed", false, nil
    end

    local active = state
        and type(state.Active) == "table"
        and state.Active[definition.Id]

    if type(active) == "table" then
        if active.Ready == true then
            return "Claim Reward", true, "Claim"
        end
        return "Review", true, "Review"
    end

    local prerequisite = definition.PrerequisiteQuestId
    if type(prerequisite) == "string"
        and (
            not state
            or type(state.Completed) ~= "table"
            or state.Completed[prerequisite] ~= true
        )
    then
        return "Locked", false, nil
    end

    return "Start Quest", true, "Start"
end

--[[
Returns one player-facing speaker label for a quest.

Args:
    quest_id (string): Stable Adventure quest identifier.

Returns:
    string: Speaker role or fallback board label.
]]
function Presenter.speaker(quest_id: string): string
    local narrative = Narratives.get(quest_id)

    return if narrative and type(narrative.Speaker) == "string"
        then narrative.Speaker
        else "Adventure Board"
end

--[[
Returns the ordered dialogue lines for one conversation mode.

Args:
    quest_id (string): Stable Adventure quest identifier.
    mode (string): Start, Review, Claim or Complete.

Returns:
    {string}: Ordered narrative lines.
]]
function Presenter.lines(
    quest_id: string,
    mode: string
): {string}
    local narrative = Narratives.get(quest_id)
    if not narrative then
        return {}
    end

    if mode == "Start" then
        return narrative.Start or {}
    elseif mode == "Review" then
        return narrative.Progress or {}
    elseif mode == "Claim" then
        return narrative.Ready or {}
    elseif mode == "Complete" then
        return narrative.Complete or {}
    end

    return {}
end

--[[
Returns paragraph-form dialogue for one conversation mode.

Args:
    quest_id (string): Stable Adventure quest identifier.
    mode (string): Start, Review, Claim or Complete.

Returns:
    string: Readable dialogue text.
]]
function Presenter.text(
    quest_id: string,
    mode: string
): string
    local lines = Presenter.lines(quest_id, mode)

    if #lines == 0 then
        return "No additional dialogue is available for this Adventure."
    end

    return table.concat(lines, "\n\n")
end

return table.freeze(Presenter)
