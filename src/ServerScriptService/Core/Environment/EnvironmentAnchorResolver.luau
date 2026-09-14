--!strict
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Definitions = require(
    ReplicatedStorage
        :WaitForChild("Core")
        :WaitForChild("Shared")
        :WaitForChild("EnvironmentAnchorDefinitions")
)

local EnvironmentAnchorResolver = {}

local function failure(reason: string, anchor_id: string?): any
    return {
        ok = false,
        reason = reason,
        anchor_id = anchor_id,
        by_id = {},
        groups = {},
    }
end

local function belongs_to_root(instance: Instance, root: Instance): boolean
    return instance == root or instance:IsDescendantOf(root)
end

local function in_list(values: {string}?, candidate: string): boolean
    for _, value in ipairs(values or {}) do
        if value == candidate then
            return true
        end
    end
    return false
end

local function group_for_id(contract: any, anchor_id: string): any?
    for _, group in ipairs(contract.Groups or {}) do
        if string.sub(anchor_id, 1, #group.Prefix) == group.Prefix then
            return group
        end
    end
    return nil
end

function EnvironmentAnchorResolver.resolve(
    root: Instance,
    contract: any,
    tagged_instances: {Instance}?
): any
    if not root then
        return failure("InvalidAnchorRoot", nil)
    end
    if type(contract) ~= "table" or type(contract.EnvironmentId) ~= "string" then
        return failure("InvalidAnchorContract", nil)
    end

    local candidates = tagged_instances
        or CollectionService:GetTagged(Definitions.TAG)

    local by_id: {[string]: BasePart} = {}
    local groups: {[string]: {BasePart}} = {}

    for _, group in ipairs(contract.Groups or {}) do
        groups[group.Name] = {}
    end

    for _, instance in ipairs(candidates) do
        local raw_anchor_id = instance:GetAttribute(Definitions.ANCHOR_ATTRIBUTE)
        local anchor_id = if type(raw_anchor_id) == "string"
            then raw_anchor_id
            else nil

        if not instance:IsA("BasePart") or not belongs_to_root(instance, root) then
            return failure("InvalidAnchorInstance", anchor_id)
        end

        local environment_id =
            instance:GetAttribute(Definitions.ENVIRONMENT_ATTRIBUTE)
        if environment_id ~= contract.EnvironmentId then
            return failure("WrongEnvironment", anchor_id)
        end

        if not anchor_id or anchor_id == "" then
            return failure("InvalidAnchorInstance", nil)
        end

        local group = group_for_id(contract, anchor_id)
        local is_exact =
            in_list(contract.Required, anchor_id)
            or in_list(contract.Optional, anchor_id)

        -- Future contracts may add unrelated anchors to the same environment.
        -- Resolve only IDs that belong to the supplied contract.
        if is_exact or group ~= nil then
            if by_id[anchor_id] ~= nil then
                return failure("DuplicateAnchor", anchor_id)
            end

            by_id[anchor_id] = instance

            if group then
                table.insert(groups[group.Name], instance)
            end
        end
    end

    for _, anchor_id in ipairs(contract.Required or {}) do
        if by_id[anchor_id] == nil then
            return failure("MissingAnchor", anchor_id)
        end
    end

    for _, group in ipairs(contract.Groups or {}) do
        local values = groups[group.Name]
        table.sort(values, function(left: BasePart, right: BasePart): boolean
            return tostring(
                left:GetAttribute(Definitions.ANCHOR_ATTRIBUTE)
            ) < tostring(
                right:GetAttribute(Definitions.ANCHOR_ATTRIBUTE)
            )
        end)

        if #values < (tonumber(group.MinCount) or 0) then
            return failure("InsufficientAnchorGroup", group.Name)
        end
    end

    return {
        ok = true,
        reason = nil,
        by_id = by_id,
        groups = groups,
    }
end

return table.freeze(EnvironmentAnchorResolver)
