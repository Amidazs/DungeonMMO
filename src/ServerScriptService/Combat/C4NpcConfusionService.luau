--!strict
-- Server-owned C4 Confusion state for supported NPC AI.

local Players = game:GetService("Players")

local C4NpcConfusionService = {}

type Record = {
    CasterUserId: number,
    ExpiresAt: number,
    RetargetSeconds: number,
    RemainingRetargets: number,
    RadiusStuds: number,
}

local records: {[Model]: Record} = {}

--[[
Clears one NPC confusion generation.

Args:
    target (Model): NPC whose confusion state is removed.

Returns:
    nil: Clears server state and replicated diagnostics.
]]
function C4NpcConfusionService.clear(target: Model)
    records[target] = nil

    if target.Parent then
        target:SetAttribute("C4Confused", false)
        target:SetAttribute("C4ConfusionEndsAt", 0)
        target:SetAttribute("C4ConfusionCasterUserId", 0)
        target:SetAttribute("C4ConfusionRetargetsRemaining", 0)
    end
end

--[[
Applies one exact C4 confusion generation.

Args:
    target (Model): Reviewed living NPC.
    caster_user_id (number): Authenticated caster excluded from retargeting.
    retarget_count (number): Exact source action count.
    retarget_seconds (number): Exact source action interval.
    radius_studs (number): Server-converted source radius.

Returns:
    (boolean, string?): Applied state or strict denial reason.
]]
function C4NpcConfusionService.apply(
    target: Model,
    caster_user_id: number,
    retarget_count: number,
    retarget_seconds: number,
    radius_studs: number
): (boolean, string?)
    local humanoid = target:FindFirstChildOfClass("Humanoid")
    local root = target:FindFirstChild("HumanoidRootPart")

    if not target.Parent
        or not humanoid
        or humanoid.Health <= 0
        or not root
        or not root:IsA("BasePart")
    then
        return false, "C4ConfusionTargetUnavailable"
    end

    if type(caster_user_id) ~= "number"
        or caster_user_id % 1 ~= 0
        or caster_user_id <= 0
        or type(retarget_count) ~= "number"
        or retarget_count % 1 ~= 0
        or retarget_count <= 0
        or type(retarget_seconds) ~= "number"
        or retarget_seconds <= 0
        or type(radius_studs) ~= "number"
        or radius_studs <= 0
    then
        return false, "InvalidC4ConfusionPlan"
    end

    local record: Record = {
        CasterUserId = caster_user_id,
        ExpiresAt = os.clock() + retarget_count * retarget_seconds,
        RetargetSeconds = retarget_seconds,
        RemainingRetargets = retarget_count,
        RadiusStuds = radius_studs,
    }
    records[target] = record

    target:SetAttribute("C4Confused", true)
    target:SetAttribute("C4ConfusionEndsAt", record.ExpiresAt)
    target:SetAttribute(
        "C4ConfusionCasterUserId",
        caster_user_id
    )
    target:SetAttribute(
        "C4ConfusionRetargetsRemaining",
        retarget_count
    )

    task.delay(
        retarget_count * retarget_seconds,
        function()
            if records[target] == record then
                C4NpcConfusionService.clear(target)
            end
        end
    )

    return true, nil
end

--[[
Reports whether one NPC remains confused.

Args:
    target (Model): Reviewed NPC.

Returns:
    boolean: True only for a live unexpired generation.
]]
function C4NpcConfusionService.is_confused(target: Model): boolean
    local record = records[target]
    if not record then
        return false
    end

    local humanoid = target:FindFirstChildOfClass("Humanoid")
    if target.Parent == nil
        or not humanoid
        or humanoid.Health <= 0
        or os.clock() >= record.ExpiresAt
    then
        C4NpcConfusionService.clear(target)
        return false
    end

    return true
end

--[[
Selects one living player target for supported NPC AI while confused.

The original C4 effect chooses any nearby character except the caster. Current
Dungeon enemy controllers attack players, so this authority chooses uniformly
from their compatible nearby player targets and excludes the caster. If there
is no compatible player, no forced target is returned and the NPC remains in
its confused state until a compatible target appears or the effect expires.

Args:
    target (Model): Confused NPC.
    candidates ({any}): Server-reviewed player target contexts.

Returns:
    any?: One candidate context or nil.
]]
function C4NpcConfusionService.choose_player_target(
    target: Model,
    candidates: {any}
): any?
    local record = records[target]
    if not record or not C4NpcConfusionService.is_confused(target) then
        return nil
    end

    local root = target:FindFirstChild("HumanoidRootPart")
    if not root or not root:IsA("BasePart") then
        return nil
    end

    local eligible = {}
    for _, candidate in ipairs(candidates) do
        local player = candidate.player
        local target_root = candidate.root
        if player
            and type(player.UserId) == "number"
            and player.UserId ~= record.CasterUserId
            and target_root
            and target_root:IsA("BasePart")
            and (
                target_root.Position - root.Position
            ).Magnitude <= record.RadiusStuds
        then
            table.insert(eligible, candidate)
        end
    end

    if #eligible == 0 then
        return nil
    end

    return eligible[math.random(1, #eligible)]
end

--[[
Returns the exact caster excluded by this confusion generation.

Args:
    target (Model): Confused NPC.

Returns:
    number?: Authenticated caster UserId, otherwise nil.
]]
function C4NpcConfusionService.caster_user_id(
    target: Model
): number?
    local record = records[target]
    return if record then record.CasterUserId else nil
end

return table.freeze(C4NpcConfusionService)
