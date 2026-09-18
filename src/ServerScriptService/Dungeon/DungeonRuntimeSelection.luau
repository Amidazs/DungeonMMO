--!strict
local DungeonRuntimeSelection = {}

local function result(
    ok: boolean,
    reason: string?,
    extra: any?
): any
    local response = extra or {}
    response.ok = ok
    response.reason = reason
    return response
end

local function resolve_known_selection(
    dungeon_id: string,
    difficulty_id: string?,
    dungeon_definitions: any,
    difficulty_definitions: any,
    layout_definitions: any
): any
    if not dungeon_definitions.get(dungeon_id) then
        return result(false, "UnknownDungeon")
    end

    local selected_difficulty_id = difficulty_id
        or difficulty_definitions.default_id(dungeon_id)
    if type(selected_difficulty_id) ~= "string" then
        return result(false, "UnknownDifficulty")
    end

    local difficulty = difficulty_definitions.get(
        dungeon_id,
        selected_difficulty_id
    )
    if not difficulty then
        return result(false, "UnknownDifficulty")
    end

    local layout_id = difficulty.LayoutId
    if type(layout_id) ~= "string" or layout_id == "" then
        return result(false, "DungeonLayoutIdMissing")
    end

    if not layout_definitions.is_registered(
        dungeon_id,
        layout_id
    ) then
        return result(false, "DungeonLayoutNotRegistered", {
            DungeonId = dungeon_id,
            DifficultyId = selected_difficulty_id,
            LayoutId = layout_id,
        })
    end

    return result(true, nil, {
        DungeonId = dungeon_id,
        DifficultyId = selected_difficulty_id,
        LayoutId = layout_id,
    })
end

local function studio_selection(
    workspace_service: any,
    dungeon_definitions: any,
    difficulty_definitions: any,
    layout_definitions: any
): any
    local requested_dungeon = workspace_service:GetAttribute(
        "DungeonMMOStudioDungeonId"
    )
    local dungeon_id = if type(requested_dungeon) == "string"
            and dungeon_definitions.get(requested_dungeon)
        then requested_dungeon
        else dungeon_definitions.TEST_DUNGEON.Id

    local requested_difficulty = workspace_service:GetAttribute(
        "DungeonMMOStudioDifficultyId"
    )
    local difficulty_id = if type(requested_difficulty) == "string"
        then requested_difficulty
        else nil

    return resolve_known_selection(
        dungeon_id,
        difficulty_id,
        dungeon_definitions,
        difficulty_definitions,
        layout_definitions
    )
end

local function selection_from_player(
    player: any,
    dungeon_definitions: any,
    difficulty_definitions: any,
    layout_definitions: any
): any?
    local join_data = player:GetJoinData()
    local teleport_data = join_data and join_data.TeleportData
    if type(teleport_data) ~= "table" then
        return nil
    end

    local dungeon_id = teleport_data.DungeonId
    if type(dungeon_id) ~= "string" then
        return nil
    end

    local difficulty_id = teleport_data.DifficultyId
    if difficulty_id ~= nil and type(difficulty_id) ~= "string" then
        return result(false, "UnknownDifficulty")
    end

    return resolve_known_selection(
        dungeon_id,
        difficulty_id,
        dungeon_definitions,
        difficulty_definitions,
        layout_definitions
    )
end

-- Resolves authoritative Dungeon, Difficulty and Layout selection.
function DungeonRuntimeSelection.resolve_selection(
    players: any,
    workspace_service: any,
    run_service: any,
    dungeon_definitions: any,
    difficulty_definitions: any,
    layout_definitions: any,
    timeout_seconds: number?
): any
    if run_service:IsStudio() then
        return studio_selection(
            workspace_service,
            dungeon_definitions,
            difficulty_definitions,
            layout_definitions
        )
    end

    for _, player in ipairs(players:GetPlayers()) do
        local selected = selection_from_player(
            player,
            dungeon_definitions,
            difficulty_definitions,
            layout_definitions
        )
        if selected then
            return selected
        end
    end

    local selected: any? = nil
    local connection: RBXScriptConnection? = nil
    connection = players.PlayerAdded:Connect(function(player: Player)
        if selected then
            return
        end
        selected = selection_from_player(
            player,
            dungeon_definitions,
            difficulty_definitions,
            layout_definitions
        )
    end)

    local deadline = os.clock() + (timeout_seconds or 15)
    while not selected and os.clock() < deadline do
        task.wait(0.05)
    end
    if connection then
        connection:Disconnect()
    end

    if selected then
        return selected
    end
    return result(false, "DungeonRuntimeSelectionTimeout")
end

-- Resolves only the dungeon ID for compatibility with existing callers.
function DungeonRuntimeSelection.resolve(
    players: any,
    workspace_service: any,
    run_service: any,
    dungeon_definitions: any,
    timeout_seconds: number?
): (string?, string?)

    if run_service:IsStudio() then
        local requested = workspace_service:GetAttribute(
            "DungeonMMOStudioDungeonId"
        )
        if type(requested) == "string"
            and dungeon_definitions.get(requested)
        then
            return requested, nil
        end
        return dungeon_definitions.TEST_DUNGEON.Id, nil
    end

    local function from_player(player: any): string?
        local join_data = player:GetJoinData()
        local teleport_data = join_data and join_data.TeleportData
        local dungeon_id = teleport_data and teleport_data.DungeonId
        if type(dungeon_id) == "string"
            and dungeon_definitions.get(dungeon_id)
        then
            return dungeon_id
        end
        return nil
    end

    for _, player in ipairs(players:GetPlayers()) do
        local dungeon_id = from_player(player)
        if dungeon_id then
            return dungeon_id, nil
        end
    end

    local result_id: string? = nil
    local connection: RBXScriptConnection? = nil
    connection = players.PlayerAdded:Connect(function(player: Player)
        if result_id then
            return
        end
        result_id = from_player(player)
    end)

    local deadline = os.clock() + (timeout_seconds or 15)
    while not result_id and os.clock() < deadline do
        task.wait(0.05)
    end
    if connection then
        connection:Disconnect()
    end

    if result_id then
        return result_id, nil
    end
    return nil, "DungeonRuntimeSelectionTimeout"
end

return table.freeze(DungeonRuntimeSelection)
