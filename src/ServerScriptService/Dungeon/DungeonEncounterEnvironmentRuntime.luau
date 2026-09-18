--!strict
local DungeonEncounterEnvironmentRuntime = {}

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

-- Opens or closes the physical exit barrier declared by one binding.
function DungeonEncounterEnvironmentRuntime.set_exit_open(
    binding: any,
    environment: any,
    open: boolean
): any
    if type(binding) ~= "table" then
        return result(false, "InvalidEncounterBinding")
    end

    local anchor_id = binding.ExitBarrierAnchor
    if anchor_id == nil then
        return result(true, nil, {
            barrier_present = false,
        })
    end

    if type(anchor_id) ~= "string" or anchor_id == "" then
        return result(false, "InvalidExitBarrierBinding")
    end

    if type(environment) ~= "table"
        or type(environment.get) ~= "function"
    then
        return result(false, "EncounterEnvironmentInvalid")
    end

    local barrier = environment:get(anchor_id)
    if typeof(barrier) ~= "Instance"
        or not barrier:IsA("BasePart")
    then
        return result(false, "ExitBarrierAnchorMissing", {
            AnchorId = anchor_id,
        })
    end

    barrier.CanCollide = not open
    barrier.CanTouch = false
    barrier.Transparency = 1

    return result(true, nil, {
        barrier_present = true,
        AnchorId = anchor_id,
    })
end

return table.freeze(DungeonEncounterEnvironmentRuntime)
