--!strict
local RunService = game:GetService("RunService")

local DungeonContributionBridge = {}

local event_serial = 0
local bound_service: any = nil
local recorder_override: ((number, any) -> any)? = nil
local damage_target_validator: ((any) -> boolean)? = nil
local quest_damage_observer: any? = nil

local function next_event_id(
    kind: string,
    user_id: number,
    source_id: string
): string
    event_serial += 1

    return string.format(
        "%s:%d:%s:%d",
        kind,
        user_id,
        source_id,
        event_serial
    )
end

local function valid_amount(amount: any): boolean
    return type(amount) == "number"
        and amount == amount
        and amount > 0
        and math.abs(amount) < math.huge
end

-- Args:
--   user_id: any; authenticated Roblox player UserId.
-- Returns:
--   boolean: positive live identity or negative local Studio identity.
local function valid_user_id(user_id: any): boolean
    return type(user_id) == "number"
        and user_id % 1 == 0
        and user_id < math.huge and user_id > -math.huge
        and (user_id > 0
            or (user_id < 0 and RunService:IsStudio()))
end

local function user_id_of(value: any): number?
    if type(value) ~= "table" and typeof(value) ~= "Instance" then
        return nil
    end

    local ok, user_id = pcall(function()
        return value.UserId
    end)

    if ok and valid_user_id(user_id) then
        return user_id
    end

    return nil
end

function DungeonContributionBridge.bind_service(service: any?)
    bound_service = service
end

-- Args:
--   validator: ((any) -> boolean)?; server-only target admission rule.
-- Returns:
--   nil: installs the scoped damage filter, or restores default behavior.
function DungeonContributionBridge.bind_damage_target_validator(
    validator: ((any) -> boolean)?
)
    damage_target_validator = validator
end

--[[
Installs the optional server-only quest kill ledger without replacing the
normal damage, threat or contribution subscriber.

Args:
    observer (any?): Ledger with record_damage, or nil to unbind it.

Returns:
    nil: Subsequent accepted combat hits reach the quest observer.
]]
function DungeonContributionBridge.bind_quest_damage_observer(
    observer: any?
)
    assert(observer == nil
        or (type(observer) == "table"
            and type(observer.record_damage) == "function"))
    quest_damage_observer = observer
end

function DungeonContributionBridge.set_recorder_for_test(
    recorder: ((number, any) -> any)?
)
    recorder_override = recorder
end

local function record(
    user_id: number,
    event_type: string,
    amount: number,
    source_id: string,
    metadata: any?
): any
    if not valid_amount(amount) then
        return {
            ok = false,
            reason = "InvalidContributionEvent",
        }
    end

    local event = {
        EventId = next_event_id(
            event_type,
            user_id,
            source_id
        ),
        Type = event_type,
        Amount = amount,
        Metadata = metadata,
    }

    if recorder_override then
        return recorder_override(user_id, event)
    end

    if not bound_service then
        return {
            ok = false,
            reason = "ContributionUnavailable",
        }
    end

    return bound_service:record_for_user(
        user_id,
        event
    )
end

-- Args:
--   context: any; trusted server-created damage context.
--   applied_damage: number; positive damage applied by DamageService.
--   lethal_hit: boolean?; server-observed death from that exact hit.
-- Returns:
--   any: recorded damage or an explicit contribution rejection.
function DungeonContributionBridge.record_damage(
    context: any,
    applied_damage: number,
    lethal_hit: boolean?
): any
    if type(context) ~= "table" then
        return {ok = false, reason = "InvalidContributionEvent"}
    end

    if damage_target_validator and not damage_target_validator(context) then
        return {ok = false, reason = "IneligibleDamageTarget"}
    end

    local attacker_id = user_id_of(context.attacker)
    if not attacker_id then
        return {ok = false, reason = "NoContributionOwner"}
    end

    local source_id = tostring(
        context.attack_id
            or context.source_id
            or "Damage"
    )

    local credited = record(
        attacker_id,
        "DamageDealt",
        applied_damage,
        source_id,
        {
            SourceId = source_id,
            SequenceId = context.sequence_id,
            TargetName = if context.target
                then context.target.Name
                else nil,
            VerifiedLethalHit = lethal_hit == true,
        }
    )
    if credited.ok == true and quest_damage_observer then
        local observed, reason = pcall(
            quest_damage_observer.record_damage,
            quest_damage_observer,
            context,
            applied_damage,
            lethal_hit == true
        )
        if not observed then
            warn("[C4 Quest Combat] Damage observer failed: "
                .. tostring(reason))
        end
    end
    return credited
end

function DungeonContributionBridge.record_heal(
    caster: any,
    target: any,
    healed: number,
    source_id: string?
): any
    local caster_id = user_id_of(caster)
    if not caster_id then
        return {ok = false, reason = "NoContributionOwner"}
    end

    local resolved_source = source_id or "MageHeal"

    return record(
        caster_id,
        "EffectiveHealing",
        healed,
        resolved_source,
        {
            SourceId = resolved_source,
            TargetUserId = user_id_of(target),
        }
    )
end

function DungeonContributionBridge.record_ward(
    caster: any,
    target: any,
    absorbed: number,
    source_id: string?
): any
    local caster_id = user_id_of(caster)
    if not caster_id then
        return {ok = false, reason = "NoContributionOwner"}
    end

    local resolved_source = source_id or "ArcaneWard"

    return record(
        caster_id,
        "EffectiveWard",
        absorbed,
        resolved_source,
        {
            SourceId = resolved_source,
            TargetUserId = user_id_of(target),
        }
    )
end

function DungeonContributionBridge.record_mitigation(
    user_id: number,
    mitigated: number,
    source_id: string?
): any
    if not valid_user_id(user_id) then
        return {ok = false, reason = "NoContributionOwner"}
    end

    local resolved_source = source_id or "DamageMitigation"

    return record(
        user_id,
        "DamageMitigated",
        mitigated,
        resolved_source,
        {
            SourceId = resolved_source,
        }
    )
end

return table.freeze(DungeonContributionBridge)
