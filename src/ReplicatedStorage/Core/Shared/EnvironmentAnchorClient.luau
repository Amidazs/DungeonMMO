--!strict
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Definitions = require(
    ReplicatedStorage
        :WaitForChild("Core")
        :WaitForChild("Shared")
        :WaitForChild("EnvironmentAnchorDefinitions")
)

local EnvironmentAnchorClient = {}

function EnvironmentAnchorClient.find(
    environment_id: string,
    anchor_id: string
): BasePart?
    local found: BasePart? = nil

    for _, instance in ipairs(CollectionService:GetTagged(Definitions.TAG)) do
        if (
            instance:IsA("BasePart")
            and instance:IsDescendantOf(Workspace)
            and instance:GetAttribute(
                Definitions.ENVIRONMENT_ATTRIBUTE
            ) == environment_id
            and instance:GetAttribute(
                Definitions.ANCHOR_ATTRIBUTE
            ) == anchor_id
        ) then
            if found ~= nil then
                return nil
            end
            found = instance
        end
    end

    return found
end

function EnvironmentAnchorClient.wait_for(
    environment_id: string,
    anchor_id: string,
    timeout_seconds: number?
): BasePart?
    local timeout = timeout_seconds or 15
    local deadline = os.clock() + timeout

    repeat
        local found = EnvironmentAnchorClient.find(
            environment_id,
            anchor_id
        )
        if found then
            return found
        end
        task.wait(0.1)
    until os.clock() >= deadline

    return nil
end

return table.freeze(EnvironmentAnchorClient)
