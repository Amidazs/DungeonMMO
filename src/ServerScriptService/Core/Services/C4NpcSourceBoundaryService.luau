--!strict
-- Server-owned C4 source boundary resolver for live Dungeon enemy Models.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Reference = require(
    ReplicatedStorage.Core.Shared.C4NpcSourceReference
)

local C4NpcSourceBoundaryService = {}

local ARCHETYPE_ATTRIBUTE = "DungeonEnemyArchetypeId"

--[[
Checks whether one enemy Model is a current server-owned combat life.

Args:
    enemy (any): Candidate live Dungeon enemy Model.

Returns:
    (boolean, string?): Validity and stable denial reason.
]]
local function validate_enemy(enemy: any): (boolean, string?)
    if typeof(enemy) ~= "Instance" or not enemy:IsA("Model") then
        return false, "InvalidC4NpcSourceOwner"
    end

    if not enemy:IsDescendantOf(Workspace) then
        return false, "C4NpcSourceOwnerUnavailable"
    end

    local humanoid = enemy:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return false, "C4NpcSourceOwnerUnavailable"
    end

    return true, nil
end

--[[
Resolves a reviewed C4 combat boundary for one genuine enemy Model.

Only a server-created Dungeon archetype attribute selects the creative mapping.
No display name, client target label or arbitrary stat table is trusted.

Args:
    enemy (any): Current server-owned Dungeon enemy Model.

Returns:
    (any?, string?): Frozen source boundary or strict denial reason.
]]
function C4NpcSourceBoundaryService.for_model(
    enemy: any
): (any?, string?)
    local valid, valid_reason = validate_enemy(enemy)
    if not valid then
        return nil, valid_reason
    end

    local archetype_id =
        enemy:GetAttribute(ARCHETYPE_ATTRIBUTE)
    if type(archetype_id) ~= "string"
        or archetype_id == ""
    then
        return nil, "C4NpcSourceArchetypeUnavailable"
    end

    return Reference.get(archetype_id)
end

--[[
Reports immutable capability metadata for NPC source-boundary cutover.

Args:
    None.

Returns:
    any: Current mapping and server-authority guarantees.
]]
function C4NpcSourceBoundaryService.capability(): any
    return {
        Available = true,
        ServerModelOwned = true,
        ArchetypeAttribute =
            ARCHETYPE_ATTRIBUTE,
        DisplayNameUsedForMapping = false,
        ClientStatsAccepted = false,
        SourceNamesPlayerFacing = false,
        SupportedArchetypes =
            Reference.supported_archetypes(),
    }
end

return table.freeze(C4NpcSourceBoundaryService)
