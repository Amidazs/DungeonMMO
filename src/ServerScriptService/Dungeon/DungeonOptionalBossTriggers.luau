--!strict
-- Evaluates only authoritative instance-state triggers, never client input.
local DungeonOptionalBossTriggers = {}

-- Checks an encounter's independent server-controlled activation gate.
-- Args: activation (any): Server-configured activation rule.
--       state (any): Server-owned session instance state.
-- Returns: boolean: Whether the explicit activation gate is satisfied.
local function activation_matches(activation: any, state: any): boolean
    if type(activation) ~= "table"
        or activation.Type ~= "InstanceFlag"
        or type(activation.Key) ~= "string"
        or activation.Value ~= true
    then
        return false
    end
    return state[activation.Key] == true
end

-- Checks entry-time eligibility against a server-defined event window.
-- Args: trigger (any): Configured timed event ID.
--       state (any): Authoritative run snapshot with entry time/windows.
-- Returns: boolean: True only for a run entered inside its event window.
local function event_matches(trigger: any, state: any): boolean
    if type(trigger.EventId) ~= "string"
        or trigger.EventId == ""
        or state.OptionalBossEventId ~= trigger.EventId
        or type(state.OptionalBossEventWindows) ~= "table"
    then
        return false
    end

    local window = state.OptionalBossEventWindows[trigger.EventId]
    local entered_at = if type(state.RunEnteredAtUnix) == "number"
        then state.RunEnteredAtUnix
        else state.CreatedAt
    if type(window) ~= "table"
        or type(window.StartUnix) ~= "number"
        or type(window.EndUnix) ~= "number"
        or type(entered_at) ~= "number"
        or window.StartUnix < 1
        or window.EndUnix <= window.StartUnix
    then
        return false
    end
    return entered_at >= window.StartUnix
        and entered_at < window.EndUnix
end

-- Checks a secret token granted by authoritative dungeon progression.
-- Args: trigger (any): Configured secret-unlock identity.
--       state (any): Server-owned unlocks for this run.
-- Returns: boolean: True only for an explicitly unlocked secret.
local function secret_matches(trigger: any, state: any): boolean
    return type(trigger.UnlockId) == "string"
        and trigger.UnlockId ~= ""
        and type(state.OptionalBossSecretUnlocks) == "table"
        and state.OptionalBossSecretUnlocks[trigger.UnlockId] == true
end

-- Resolves whether one optional boss is eligible for this saved run.
-- Args: optional (any): Optional encounter definition with trigger.
--       instance_state (any): Server-owned run state.
-- Returns: any: {ok, active, reason}; invalid rules fail closed.
function DungeonOptionalBossTriggers.evaluate(
    optional: any,
    instance_state: any
): any
    if type(optional) ~= "table"
        or type(optional.Trigger) ~= "table"
        or type(optional.Activation) ~= "table"
    then
        return {ok = false, active = false,
            reason = "OptionalBossTriggerMissing"}
    end

    local trigger = optional.Trigger
    if trigger.Type ~= "TimedEvent"
        and trigger.Type ~= "SecretUnlock"
    then
        return {ok = false, active = false,
            reason = "UnknownOptionalBossTrigger"}
    end
    if type(instance_state) ~= "table"
        or not activation_matches(optional.Activation, instance_state)
    then
        return {ok = true, active = false}
    end

    local active = if trigger.Type == "TimedEvent"
        then event_matches(trigger, instance_state)
        else secret_matches(trigger, instance_state)
    return {ok = true, active = active}
end

return table.freeze(DungeonOptionalBossTriggers)
