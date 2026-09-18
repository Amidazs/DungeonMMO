--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Definitions = require(
    ReplicatedStorage
        :WaitForChild("Core")
        :WaitForChild("Shared")
        :WaitForChild("EnvironmentAnchorDefinitions")
)
local Resolver = require(
    ServerScriptService
        :WaitForChild("Core")
        :WaitForChild("Environment")
        :WaitForChild("EnvironmentAnchorResolver")
)

local TempleEnvironmentAdapter = {}
TempleEnvironmentAdapter.__index = TempleEnvironmentAdapter

local READY_ATTRIBUTE = "DungeonMMOTempleEnvironmentReady"
local ERROR_ATTRIBUTE = "DungeonMMOTempleEnvironmentError"

local GROUP_BY_ROOM = {
    Room1 = "Room1EnemySpawns",
    Room2 = "Room2EnemySpawns",
}

local BARRIER_BY_ROOM = {
    Room1 = "Temple.Room1.ExitBarrier",
    Room2 = "Temple.Room2.ExitBarrier",
}

function TempleEnvironmentAdapter.resolve(
    root: Instance,
    contract: any?
): any
    local resolved = Resolver.resolve(
        root,
        contract or Definitions.TEMPLE
    )
    if not resolved.ok then
        return resolved
    end

    return setmetatable({
        ok = true,
        reason = nil,
        root = root,
        anchors = resolved.by_id,
        groups = resolved.groups,
    }, TempleEnvironmentAdapter)
end

function TempleEnvironmentAdapter.wait_for_ready(
    root: Instance,
    timeout_seconds: number?
): any
    local timeout = timeout_seconds or 15
    local deadline = os.clock() + timeout

    repeat
        local error_reason = root:GetAttribute(ERROR_ATTRIBUTE)
        if type(error_reason) == "string" and error_reason ~= "" then
            return {
                ok = false,
                reason = error_reason,
            }
        end

        if root:GetAttribute(READY_ATTRIBUTE) == true then
            return TempleEnvironmentAdapter.resolve(root)
        end

        task.wait(0.1)
    until os.clock() >= deadline

    return {
        ok = false,
        reason = "TempleEnvironmentBootstrapTimeout",
    }
end

function TempleEnvironmentAdapter:get(anchor_id: string): BasePart?
    return self.anchors[anchor_id]
end

function TempleEnvironmentAdapter:get_group(group_name: string): {BasePart}
    return self.groups[group_name] or {}
end

function TempleEnvironmentAdapter:checkpoint_cframe(
    anchor_id: string
): CFrame
    local anchor = assert(
        self:get(anchor_id),
        "Missing Temple checkpoint anchor " .. anchor_id
    )
    return anchor.CFrame + Vector3.new(0, 3, 0)
end

function TempleEnvironmentAdapter:enemy_spawn_cframes(
    room_id: string
): {CFrame}
    local group_name = GROUP_BY_ROOM[room_id]
    assert(group_name, "Unknown Temple room " .. room_id)

    local result = {}
    for _, anchor in ipairs(self:get_group(group_name)) do
        table.insert(result, anchor.CFrame)
    end
    return result
end

function TempleEnvironmentAdapter:captain_spawn_cframe(): CFrame
    return assert(
        self:get("Temple.Room3.CaptainSpawn"),
        "Temple.Room3.CaptainSpawn missing"
    ).CFrame
end

function TempleEnvironmentAdapter:set_exit_open(
    room_id: string,
    open: boolean
): any
    local anchor_id = BARRIER_BY_ROOM[room_id]
    if not anchor_id then
        return {
            ok = false,
            reason = "UnknownTempleRoom",
        }
    end

    local barrier = self:get(anchor_id)
    if not barrier then
        return {
            ok = true,
            barrier_present = false,
        }
    end

    barrier.CanCollide = not open
    barrier.Transparency = 1
    return {
        ok = true,
        barrier_present = true,
    }
end

return TempleEnvironmentAdapter
