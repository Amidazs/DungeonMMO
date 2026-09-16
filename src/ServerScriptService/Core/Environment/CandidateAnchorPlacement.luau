--!strict
local CandidateAnchorPlacement = {}

local function pivot_of(instance: Instance): CFrame?
    if instance:IsA("BasePart") then
        return instance.CFrame
    elseif instance:IsA("Model") then
        return instance:GetPivot()
    end
    return nil
end

local function bounds_of(instance: Instance): (CFrame?, Vector3?)
    if instance:IsA("BasePart") then
        return instance.CFrame, instance.Size
    elseif instance:IsA("Model") then
        local ok, cf, size = pcall(function()
            return instance:GetBoundingBox()
        end)
        if ok then
            return cf, size
        end
    end
    return nil, nil
end

function CandidateAnchorPlacement.resolve(landmark: Instance, selector: any): CFrame?
    local offset = if typeof(selector.Offset) == "CFrame"
        then selector.Offset
        else CFrame.new()

    if selector.UseBounds == true then
        local bounds_cf, size = bounds_of(landmark)
        if not bounds_cf or not size then
            return nil
        end

        local fraction = math.clamp(
            tonumber(selector.HeightFraction) or 0.5,
            0,
            1
        )
        local local_y = (fraction - 0.5) * size.Y
        return bounds_cf * CFrame.new(0, local_y, 0) * offset
    end

    local pivot = pivot_of(landmark)
    if not pivot then
        return nil
    end

    return pivot * offset
end

return table.freeze(CandidateAnchorPlacement)
