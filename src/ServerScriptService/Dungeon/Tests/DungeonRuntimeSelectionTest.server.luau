--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Dungeon = ServerScriptService:WaitForChild("Dungeon")
local module = Dungeon:FindFirstChild("DungeonRuntimeSelection")
if not module then
    error(
        "[Dungeon Runtime Selection Tests] RED: "
            .. "DungeonRuntimeSelection is missing."
    )
end

local Selection = require(module)
local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error("[Dungeon Runtime Selection Tests] " .. message, 2)
    end
end

local definitions = {
    TEST_DUNGEON = {Id = "TestDungeon"},
}

function definitions.get(dungeon_id: string): any?
    if dungeon_id == "TestDungeon" then
        return definitions.TEST_DUNGEON
    end
    return nil
end

local difficulties = {}

function difficulties.default_id(dungeon_id: string): string?
    if dungeon_id == "TestDungeon" then
        return "Depth1"
    end
    return nil
end

function difficulties.get(
    dungeon_id: string,
    difficulty_id: string
): any?
    if dungeon_id ~= "TestDungeon" then
        return nil
    end
    if difficulty_id == "Depth1" then
        return {
            Id = "Depth1",
            LayoutId = "Depth1",
        }
    end
    if difficulty_id == "Depth2" then
        return {
            Id = "Depth2",
            LayoutId = "Depth2",
        }
    end
    return nil
end

local layouts = {}
function layouts.is_registered(
    dungeon_id: string,
    layout_id: string
): boolean
    return dungeon_id == "TestDungeon"
        and layout_id == "Depth1"
end

local studio_workspace: any = {
    Attributes = {},
}

function studio_workspace:GetAttribute(name: string): any
    return self.Attributes[name]
end

local studio_run: any = {}
function studio_run:IsStudio(): boolean
    return true
end

local no_players: any = {}
function no_players:GetPlayers(): {any}
    return {}
end

function no_players.PlayerAdded_Connect(_handler: any)
    return nil
end

local studio_default = Selection.resolve_selection(
    no_players,
    studio_workspace,
    studio_run,
    definitions,
    difficulties,
    layouts,
    0
)
check(studio_default.ok == true, "Studio default selection must resolve.")
check(
    studio_default.DungeonId == "TestDungeon"
        and studio_default.DifficultyId == "Depth1"
        and studio_default.LayoutId == "Depth1",
    "Studio default selection must use Depth1."
)

studio_workspace.Attributes.DungeonMMOStudioDifficultyId = "Depth1"
local studio_explicit_depth1 = Selection.resolve_selection(
    no_players,
    studio_workspace,
    studio_run,
    definitions,
    difficulties,
    layouts,
    0
)
check(
    studio_explicit_depth1.ok == true
        and studio_explicit_depth1.DifficultyId == "Depth1",
    "Explicit Studio Depth1 selection must resolve."
)

studio_workspace.Attributes.DungeonMMOStudioDifficultyId = "Depth2"
local studio_depth2 = Selection.resolve_selection(
    no_players,
    studio_workspace,
    studio_run,
    definitions,
    difficulties,
    layouts,
    0
)
check(
    studio_depth2.reason == "DungeonLayoutNotRegistered",
    "Studio must fail closed when selected layout is unregistered."
)

studio_workspace.Attributes.DungeonMMOStudioDifficultyId = "Unknown"
local invalid_studio = Selection.resolve_selection(
    no_players,
    studio_workspace,
    studio_run,
    definitions,
    difficulties,
    layouts,
    0
)
check(
    invalid_studio.reason == "UnknownDifficulty",
    "Unknown Studio difficulty must fail closed."
)

local production_run: any = {}
function production_run:IsStudio(): boolean
    return false
end

local player: any = {}
function player:GetJoinData(): any
    return {
        TeleportData = {
            DungeonId = "TestDungeon",
            DifficultyId = "Depth1",
        },
    }
end

local production_players: any = {}
function production_players:GetPlayers(): {any}
    return {player}
end

local production = Selection.resolve_selection(
    production_players,
    studio_workspace,
    production_run,
    definitions,
    difficulties,
    layouts,
    0
)
check(production.ok == true, "Production selection must resolve.")
check(
    production.DifficultyId == "Depth1",
    "Production must preserve TeleportData DifficultyId."
)

print(string.format(
    "[Dungeon Runtime Selection Tests] PASS: %d assertions.",
    assertion_count
))
