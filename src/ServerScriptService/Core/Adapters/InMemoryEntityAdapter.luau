--!strict
local InMemoryEntityAdapter = {}

local function clone(value: any): any
    if type(value) ~= "table" then
        return value
    end
    local out = {}
    for key, child in pairs(value) do
        out[clone(key)] = clone(child)
    end
    return out
end

function InMemoryEntityAdapter.new(initial: {[string]: any}?): any
    local storage: {[string]: any} = {}
    if initial then
        for key, value in pairs(initial) do
            storage[key] = clone(value)
        end
    end

    local adapter = {}

    function adapter:load(key: string): (any?, string?)
        local value = storage[key]
        return if value == nil then nil else clone(value), nil
    end

    function adapter:update(key: string, transform: (any?) -> any): (any?, string?)
        local ok, result = pcall(transform, clone(storage[key]))
        if not ok then
            return nil, "UpdateTransformFailed"
        end
        if result == nil then
            return nil, "UpdateCancelled"
        end
        storage[key] = clone(result)
        return clone(result), nil
    end

    function adapter:remove(key: string): (boolean, string?)
        storage[key] = nil
        return true, nil
    end

    return table.freeze(adapter)
end

return table.freeze(InMemoryEntityAdapter)
