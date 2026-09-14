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

local BaseEnvironmentAdapter = {}
BaseEnvironmentAdapter.__index = BaseEnvironmentAdapter

local READY_ATTRIBUTE = "DungeonMMOBaseEnvironmentReady"
local ERROR_ATTRIBUTE = "DungeonMMOBaseEnvironmentError"

function BaseEnvironmentAdapter.resolve(root: Instance): any
    local resolved = Resolver.resolve(root, Definitions.BASE)

    if not resolved.ok then
        return resolved
    end

    local self = setmetatable({
        ok = true,
        reason = nil,
        anchors = resolved.by_id,
        groups = resolved.groups,
    }, BaseEnvironmentAdapter)

    return self
end

function BaseEnvironmentAdapter.wait_for_ready(
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
            return BaseEnvironmentAdapter.resolve(root)
        end

        task.wait(0.1)
    until os.clock() >= deadline

    return {
        ok = false,
        reason = "BaseEnvironmentBootstrapTimeout",
    }
end

function BaseEnvironmentAdapter:get(anchor_id: string): BasePart?
    return self.anchors[anchor_id]
end

function BaseEnvironmentAdapter:place_character(
    character: Model,
    destination: string
): any
    local anchor_id = if destination == "ArrivalFromTemple"
        then "Base.ArrivalFromTemple"
        else "Base.PlayerSpawn"

    local anchor = self:get(anchor_id)
    if not anchor then
        return {
            ok = false,
            reason = "MissingAnchor",
            anchor_id = anchor_id,
        }
    end

    character:PivotTo(anchor.CFrame + Vector3.new(0, 3, 0))
    return {
        ok = true,
        anchor_id = anchor_id,
    }
end

return BaseEnvironmentAdapter
