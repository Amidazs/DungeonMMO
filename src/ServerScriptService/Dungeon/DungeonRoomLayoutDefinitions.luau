--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")
local DungeonRuntimeContentCatalog = require(
    Shared:WaitForChild("DungeonRuntimeContentCatalog")
)

local DungeonRoomLayoutDefinitions = {}
local PlaceholderLayouts = require(script.Parent:WaitForChild(
    "DungeonPlaceholderPlayableLayouts"
))

local function studio_placeholder_enabled(): boolean
    return RunService:IsStudio()
        and game.PlaceId == 0
        and game.GameId == 0
        and Workspace:GetAttribute("DungeonMMOEnvironmentMode") == "Synthetic"
        and Workspace:GetAttribute("DungeonMMOPlaceholderPhysicalContentEnabled") == true
        and Workspace:GetAttribute("DungeonMMOPlaceholderPlayableEnabled") == true
end

-- Returns one registered physical dungeon layout.
function DungeonRoomLayoutDefinitions.get(
    dungeon_id: string,
    layout_id: string
): any?
    if studio_placeholder_enabled() then
        return PlaceholderLayouts.get(
            dungeon_id, layout_id,
            Workspace:GetAttribute("DungeonMMOPlaceholderOptionalPlayEnabled") == true
        )
    end
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
