--!strict
local TravelCandidateLandmarkResolver = {}

local function descendants_with_name(
    root: Instance,
    target_name: string
): {Instance}
    local matches = {}

    for _, instance in ipairs(root:GetDescendants()) do
        if instance.Name == target_name then
            table.insert(matches, instance)
        end
    end

    return matches
end

local function contains(
    text: string,
    fragment: string
): boolean
    return string.find(
        string.lower(text),
        string.lower(fragment),
        1,
        true
    ) ~= nil
end

local function collect_fragment_matches(
    root: Instance,
    prefix: string?,
    fragments: {string}
): {Instance}
    local matches = {}

    for _, instance in ipairs(root:GetDescendants()) do
        local name = instance.Name
        local prefix_ok = (
            prefix == nil
            or prefix == ""
            or contains(name, prefix)
        )

        if prefix_ok then
            local fragment_ok = false

            for _, fragment in ipairs(fragments) do
                if contains(name, fragment) then
                    fragment_ok = true
                    break
                end
            end

            if fragment_ok then
                table.insert(matches, instance)
            end
        end
    end

    return matches
end

local function resolved(instance: Instance): any
    return {
        ok = true,
        instance = instance,
    }
end

local function ambiguous(matches: {Instance}): any
    local names = {}

    for _, instance in ipairs(matches) do
        table.insert(names, instance:GetFullName())
    end

    table.sort(names)

    return {
        ok = false,
        reason = "CandidateLandmarkAmbiguous",
        matches = names,
    }
end

function TravelCandidateLandmarkResolver.resolve(
    root: Instance,
    rule: any
): any
    assert(root ~= nil, "Travel candidate resolver requires a root.")

    local preferred_names =
        if type(rule) == "table"
            and type(rule.PreferredNames) == "table"
        then rule.PreferredNames
        else {}

    for _, target_name in ipairs(preferred_names) do
        if type(target_name) == "string"
            and target_name ~= ""
        then
            local matches =
                descendants_with_name(root, target_name)

            if #matches == 1 then
                return resolved(matches[1])
            elseif #matches > 1 then
                return ambiguous(matches)
            end
        end
    end

    local fragments =
        if type(rule) == "table"
            and type(rule.AreaFragments) == "table"
        then rule.AreaFragments
        else {}

    if #fragments > 0 then
        local prefix =
            if type(rule.PreferredPrefix) == "string"
            then rule.PreferredPrefix
            else nil

        if prefix and prefix ~= "" then
            local preferred =
                collect_fragment_matches(
                    root,
                    prefix,
                    fragments
                )

            if #preferred == 1 then
                return resolved(preferred[1])
            elseif #preferred > 1 then
                return ambiguous(preferred)
            end
        end

        local fallback =
            collect_fragment_matches(
                root,
                nil,
                fragments
            )

        if #fallback == 1 then
            return resolved(fallback[1])
        elseif #fallback > 1 then
            return ambiguous(fallback)
        end
    end

    return {
        ok = false,
        reason = "CandidateLandmarkMissing",
        matches = {},
    }
end

return table.freeze(TravelCandidateLandmarkResolver)
