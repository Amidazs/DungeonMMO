--!strict
-- Server-owned temporary player immobility for C4 self buffs.

local C4PlayerImmobileService = {}

type Record = {
    Character: Model,
    Root: BasePart,
    ExpiresAt: number,
    AnchoredByService: boolean,
}

local records: {[any]: Record} = setmetatable({}, {
    __mode = "k",
})

--[[
Clears one active immobility generation.

Args:
    owner (any): Server-owned player-like object.

Returns:
    nil: Restores only anchoring introduced by this service.
]]
function C4PlayerImmobileService.clear(owner: any)
    local record = records[owner]
    records[owner] = nil

    if not record then
        return
    end

    if record.Root.Parent
        and record.AnchoredByService
    then
        record.Root.Anchored = false
    end

    if record.Character.Parent then
        record.Character:SetAttribute("C4Immobile", false)
        record.Character:SetAttribute("C4ImmobileEndsAt", 0)
    end
end

--[[
Applies or refreshes server-owned immobility.

The root is anchored only when this service found it unanchored. Existing
anchoring is preserved when the effect later clears.

Args:
    owner (any): Server-owned player-like object.
    duration_seconds (number): Positive exact source duration.

Returns:
    (boolean, string?): Applied state or strict denial reason.
]]
function C4PlayerImmobileService.apply(
    owner: any,
    duration_seconds: number
): (boolean, string?)
    local character = owner and owner.Character
    if typeof(character) ~= "Instance"
        or not character:IsA("Model")
    then
        return false, "C4ImmobileCharacterUnavailable"
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid
        or humanoid.Health <= 0
        or not root
        or not root:IsA("BasePart")
    then
        return false, "C4ImmobileCharacterUnavailable"
    end

    if type(duration_seconds) ~= "number"
        or duration_seconds ~= duration_seconds
        or duration_seconds <= 0
        or duration_seconds >= math.huge
    then
        return false, "InvalidC4ImmobileDuration"
    end

    local current = records[owner]
    local expires_at = os.clock() + duration_seconds
    if current
        and current.Character == character
        and current.ExpiresAt > expires_at
    then
        expires_at = current.ExpiresAt
    end

    local anchored_by_service = if current
        and current.Character == character
        then current.AnchoredByService
        else not root.Anchored

    if anchored_by_service then
        root.Anchored = true
    end
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero

    local record: Record = {
        Character = character,
        Root = root,
        ExpiresAt = expires_at,
        AnchoredByService = anchored_by_service,
    }
    records[owner] = record

    character:SetAttribute("C4Immobile", true)
    character:SetAttribute("C4ImmobileEndsAt", expires_at)

    task.delay(
        math.max(0, expires_at - os.clock()),
        function()
            if records[owner] ~= record then
                return
            end
            if os.clock() < record.ExpiresAt then
                return
            end
            C4PlayerImmobileService.clear(owner)
        end
    )

    return true, nil
end

--[[
Reports whether the current character is immobile.

Args:
    owner (any): Server-owned player-like object.

Returns:
    boolean: True only for the active unexpired generation.
]]
function C4PlayerImmobileService.is_immobile(owner: any): boolean
    local record = records[owner]
    if not record then
        return false
    end

    if owner.Character ~= record.Character
        or record.Character.Parent == nil
        or os.clock() >= record.ExpiresAt
    then
        C4PlayerImmobileService.clear(owner)
        return false
    end

    return true
end

return table.freeze(C4PlayerImmobileService)
