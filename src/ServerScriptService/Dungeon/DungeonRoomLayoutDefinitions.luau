--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")
local DungeonRuntimeContentCatalog = require(
    Shared:WaitForChild("DungeonRuntimeContentCatalog")
)

local DungeonRoomLayoutDefinitions = {}

-- Returns one registered physical dungeon layout.
function DungeonRoomLayoutDefinitions.get(
    dungeon_id: string,
    layout_id: string
): any?
    return DungeonRuntimeContentCatalog.get_layout(
        dungeon_id,
        layout_id
    )
end

-- Returns whether a physical layout is currently registered.
function DungeonRoomLayoutDefinitions.is_registered(
    dungeon_id: string,
    layout_id: string
): boolean
    return DungeonRoomLayoutDefinitions.get(
        dungeon_id,
        layout_id
    ) ~= nil
end

return table.freeze(DungeonRoomLayoutDefinitions)
