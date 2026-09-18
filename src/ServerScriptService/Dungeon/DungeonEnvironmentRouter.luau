--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")
local DungeonDefinitions = require(
    Shared:WaitForChild("DungeonDefinitions")
)
local EnvironmentAnchorDefinitions = require(
    Shared:WaitForChild("EnvironmentAnchorDefinitions")
)

local Dungeon = script.Parent
local TempleAdapter = require(
    Dungeon:WaitForChild("TempleEnvironmentAdapter")
)
local MineAdapter = require(
    Dungeon:WaitForChild("AbandonedMineEnvironmentAdapter")
)
local DungeonRoomLayoutDefinitions = require(
    Dungeon:WaitForChild("DungeonRoomLayoutDefinitions")
)
local DungeonLayoutEnvironmentContract = require(
    Dungeon:WaitForChild("DungeonLayoutEnvironmentContract")
)

local DungeonEnvironmentRouter = {}

local READY_ATTRIBUTE =
    "DungeonMMODungeonEnvironmentReady"
local ERROR_ATTRIBUTE =
    "DungeonMMODungeonEnvironmentError"
local LAYOUT_ATTRIBUTE =
    "DungeonMMOResolvedLayoutId"

local function runtime_base_for_dungeon(
    dungeon_id: string
): any?
    if dungeon_id == DungeonDefinitions.TEST_DUNGEON.Id then
        return EnvironmentAnchorDefinitions
            .TEMPLE_RUNTIME_BASE
    end
    if dungeon_id
        == DungeonDefinitions.ABANDONED_MINE.Id
    then
        return EnvironmentAnchorDefinitions
            .ABANDONED_MINE_RUNTIME_BASE
    end
    return nil
end

local function resolve_ready_environment(
    root: Instance,
    dungeon_id: string
): any
    local layout_id = root:GetAttribute(LAYOUT_ATTRIBUTE)
    if type(layout_id) ~= "string"
        or layout_id == ""
    then
        return {
            ok = false,
            reason = "DungeonLayoutIdMissing",
        }
    end

    local layout = DungeonRoomLayoutDefinitions.get(
        dungeon_id,
        layout_id
    )
    if not layout then
        return {
            ok = false,
            reason = "DungeonLayoutNotRegistered",
        }
    end

    local base_contract = runtime_base_for_dungeon(
        dungeon_id
    )
    if not base_contract then
        return {
            ok = false,
            reason = "UnknownDungeonEnvironment",
        }
    end

    local built = DungeonLayoutEnvironmentContract.build(
        base_contract,
        layout
    )
    if built.ok ~= true then
        return built
    end

    if dungeon_id == DungeonDefinitions.TEST_DUNGEON.Id then
        return TempleAdapter.resolve(
            root,
            built.Contract
        )
    end

    return MineAdapter.resolve(
        root,
        built.Contract
    )
end

-- Waits for bootstrap and resolves the selected layout environment.
function DungeonEnvironmentRouter.wait_for_ready(
    root: Instance,
    dungeon_id: string,
    timeout_seconds: number?
): any
    local deadline = os.clock()
        + (timeout_seconds or 15)

    repeat
        local error_reason = root:GetAttribute(
            ERROR_ATTRIBUTE
        )
        if type(error_reason) == "string"
            and error_reason ~= ""
        then
            return {
                ok = false,
                reason = error_reason,
            }
        end

        if root:GetAttribute(READY_ATTRIBUTE) == true then
            return resolve_ready_environment(
                root,
                dungeon_id
            )
        end

        task.wait(0.1)
    until os.clock() >= deadline

    return {
        ok = false,
        reason = "DungeonEnvironmentBootstrapTimeout",
    }
end

return table.freeze(DungeonEnvironmentRouter)
