--!strict
local DungeonRuntimeSelection = {}

function DungeonRuntimeSelection.resolve(
    players: any,
    workspace_service: any,
    run_service: any,
    dungeon_definitions: any,
    timeout_seconds: number?
): (string?, string?)
    if run_service:IsStudio() then
        local requested = workspace_service:GetAttribute("DungeonMMOStudioDungeonId")
        if type(requested) == "string" and dungeon_definitions.get(requested) then
            return requested, nil
        end
        return dungeon_definitions.TEST_DUNGEON.Id, nil
    end

    local function from_player(player: Player): string?
        local join_data = player:GetJoinData()
        local teleport_data = join_data and join_data.TeleportData
        local dungeon_id = teleport_data and teleport_data.DungeonId
        if type(dungeon_id) == "string" and dungeon_definitions.get(dungeon_id) then
            return dungeon_id
        end
        return nil
    end

    for _, player in ipairs(players:GetPlayers()) do
        local dungeon_id = from_player(player)
        if dungeon_id then return dungeon_id, nil end
    end

    local result_id: string? = nil
    local connection: RBXScriptConnection? = nil
    connection = players.PlayerAdded:Connect(function(player: Player)
        if result_id then return end
        result_id = from_player(player)
    end)

    local deadline = os.clock() + (timeout_seconds or 15)
    while not result_id and os.clock() < deadline do
        task.wait(0.05)
    end
    if connection then connection:Disconnect() end

    if result_id then return result_id, nil end
    return nil, "DungeonRuntimeSelectionTimeout"
end

return table.freeze(DungeonRuntimeSelection)
