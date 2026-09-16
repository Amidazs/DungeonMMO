--!strict
-- Pure completion-summary presentation. Reward grants remain unchanged.

local ItemDefinitions = require(script.Parent:WaitForChild("ItemDefinitions"))

local CompletionRewardPresentation = {}

function CompletionRewardPresentation.lines(completion: any): {string}
    if type(completion) ~= "table" then
        return {"Completion rewards unavailable."}
    end

    local lines = {
        string.format(
            "Completion Gold: +%d",
            math.max(0, math.floor(tonumber(completion.gold_granted) or 0))
        ),
        "Personal loot: " .. tostring(completion.item_id or "Nothing"),
    }

    local skill_book_item_id = completion.skill_book_item_id
    if type(skill_book_item_id) == "string"
        and skill_book_item_id ~= ""
    then
        local definition = ItemDefinitions.get(skill_book_item_id)
        local name =
            if definition and type(definition.Name) == "string"
                then definition.Name
                else skill_book_item_id
        table.insert(lines, "Bonus Skill Book: " .. name)
    end

    return lines
end

function CompletionRewardPresentation.text(completion: any): string
    return table.concat(
        CompletionRewardPresentation.lines(completion),
        "\n"
    )
end

return table.freeze(CompletionRewardPresentation)
