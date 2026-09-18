--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")

local DungeonDefinitions = require(
    Shared:WaitForChild("DungeonDefinitions")
)
local DungeonDifficultyDefinitions = require(
    Shared:WaitForChild("DungeonDifficultyDefinitions")
)

local DungeonEntrySelectionRules = {}

-- Resolves legacy or structured client routing input into server-owned IDs.
function DungeonEntrySelectionRules.resolve(request: any): any
    local dungeon_id: string?
    local difficulty_id: string?

    if type(request) == "string" then
        dungeon_id = request
    elseif type(request) == "table"
        and type(request.DungeonId) == "string"
    then
        dungeon_id = request.DungeonId
        if request.DifficultyId ~= nil then
            if type(request.DifficultyId) ~= "string" then
                return {
                    ok = false,
                    reason = "UnknownDifficulty",
                }
            end
            difficulty_id = request.DifficultyId
        end
    else
        return {
            ok = false,
            reason = "UnknownDungeon",
        }
    end

    local dungeon = DungeonDefinitions.get(dungeon_id)
    if not dungeon or dungeon.SoloEntryEnabled ~= true then
        return {
            ok = false,
            reason = "UnknownDungeon",
        }
    end

    local difficulty = DungeonDifficultyDefinitions.resolve(
        dungeon.Id,
        difficulty_id
    )
    if not difficulty then
        return {
            ok = false,
            reason = "UnknownDifficulty",
            DungeonId = dungeon.Id,
        }
    end

    return {
        ok = true,
        reason = nil,
        DungeonId = dungeon.Id,
        DifficultyId = difficulty.Id,
        DungeonDefinition = dungeon,
        DifficultyDefinition = difficulty,
    }
end

return table.freeze(DungeonEntrySelectionRules)
