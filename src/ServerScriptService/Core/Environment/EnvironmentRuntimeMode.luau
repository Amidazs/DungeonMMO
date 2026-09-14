--!strict
local EnvironmentRuntimeMode = {}

local VALID = {
    Synthetic = true,
    Candidate = true,
    Authored = true,
}

function EnvironmentRuntimeMode.resolve(
    is_studio: boolean,
    requested_mode: any
): (string?, string?)
    local requested = if type(requested_mode) == "string"
        then requested_mode
        else nil

    if is_studio then
        local mode = requested or "Synthetic"
        if VALID[mode] then
            return mode, nil
        end
        return nil, "InvalidEnvironmentMode"
    end

    if requested == nil or requested == "Authored" then
        return "Authored", nil
    end

    if requested == "Candidate" or requested == "Synthetic" then
        return nil, "EnvironmentModeNotPublishSafe"
    end

    return nil, "InvalidEnvironmentMode"
end

return table.freeze(EnvironmentRuntimeMode)
