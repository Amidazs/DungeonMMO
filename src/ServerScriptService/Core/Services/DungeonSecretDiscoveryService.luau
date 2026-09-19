--!strict
-- Persists discovery of a preselected secret route in existing session state.
local DungeonSecretDiscoveryService = {}
DungeonSecretDiscoveryService.__index = DungeonSecretDiscoveryService

local MAX_TRIGGER_DISTANCE = 12

-- Returns a standard discovery result without mutating the session.
-- Args: ok (boolean): Whether discovery succeeded.
--       reason (string?): Failure explanation.
-- Returns: any: Service result.
local function result(ok: boolean, reason: string?): any
    return {ok = ok, reason = reason}
end

-- Checks that earlier encounters are resolved and this secret is pending.
-- Args: state (any): Authoritative saved run state.
--       encounter_id (string): Secret encounter identity.
-- Returns: string?: Secret unlock identity when discovery is permitted.
local function eligible_unlock(state: any, encounter_id: string): string?
    local plan = state.EncounterPlan
    local runtime = state.EncounterRuntime
    if type(plan) ~= "table" or type(runtime) ~= "table"
        or type(runtime.EncounterStates) ~= "table"
        or (runtime.NextEncounterId ~= nil
            and runtime.NextEncounterId ~= encounter_id)
    then
        return nil
    end
    for _, encounter in ipairs(plan) do
        local progress = runtime.EncounterStates[encounter.Id]
        if encounter.Id == encounter_id then
            if encounter.Kind ~= "SecretBoss" or progress ~= "Pending"
                or type(state.OptionalBossSecretUnlocks) ~= "table"
            then
                return nil
            end
            local unlock_id = if encounter.BossId == "TempleSecretBoss"
                then "TempleHiddenSanctum"
                elseif encounter.BossId == "AbandonedMineSecretBoss"
                then "MineSealedGallery" else nil
            if unlock_id and state.OptionalBossSecretUnlocks[unlock_id] == true then
                return unlock_id
            end
            return nil
        end
        if progress ~= "Cleared"
            and (progress ~= "Skipped"
                or encounter.CompletionRequired ~= false)
        then
            return nil
        end
    end
    return nil
end

-- Creates a discovery authority backed by the existing session service.
-- Args: sessions (any): Server-owned persistent dungeon session service.
-- Returns: any: Discovery service instance.
function DungeonSecretDiscoveryService.new(sessions: any): any
    assert(sessions ~= nil, "Discovery requires dungeon sessions")
    return setmetatable({_sessions = sessions}, DungeonSecretDiscoveryService)
end

-- Records a nearby active member's discovery once, including on reconnect.
-- Args: session_id (string): Active server-owned session identity.
--       user_id (number): Server-resolved touching player's user ID.
--       encounter_id (string): Bound secret encounter identity.
--       distance (number): Server-computed distance to trigger bounds.
-- Returns: any: Persisted result; invalid/replayed writes fail closed.
function DungeonSecretDiscoveryService:discover(
    session_id: string, user_id: number,
    encounter_id: string, distance: number
): any
    if type(distance) ~= "number" or distance ~= distance
        or distance < 0 or distance > MAX_TRIGGER_DISTANCE
        or type(encounter_id) ~= "string" or encounter_id == ""
    then
        return result(false, "InvalidDiscoveryDistanceOrEncounter")
    end
    local session = self._sessions:get(session_id)
    local member = session and session.Members
        and session.Members[tostring(user_id)]
    if not member or member.Connected ~= true or member.Mode ~= "Active"
        or type(session.InstanceState) ~= "table"
        or session.InstanceState.OptionalBossEnabled ~= true
        or session.InstanceState.OptionalBossSecretUnlocked ~= true
    then
        return result(false, "SecretDiscoveryMemberOrRunIneligible")
    end
    local unlock_id = eligible_unlock(session.InstanceState, encounter_id)
    if not unlock_id then
        return result(false, "SecretDiscoveryEncounterIneligible")
    end
    local updated = self._sessions:update_instance_state(
        session_id, function(state: any): (any, any?)
            local current_unlock = eligible_unlock(state, encounter_id)
            if not current_unlock or current_unlock ~= unlock_id
                or state.OptionalBossEnabled ~= true
                or state.OptionalBossSecretUnlocked ~= true
            then
                return state, {ok = false}
            end
            state.OptionalBossSecretDiscoveries =
                state.OptionalBossSecretDiscoveries or {}
            local already = state.OptionalBossSecretDiscoveries[unlock_id] == true
            state.OptionalBossSecretDiscoveries[unlock_id] = true
            return state, {ok = true, already_discovered = already}
        end
    )
    if updated.ok ~= true or type(updated.value) ~= "table"
        or updated.value.ok ~= true
    then
        return result(false, "SecretDiscoverySaveFailed")
    end
    return {ok = true,
        already_discovered = updated.value.already_discovered}
end

return table.freeze(DungeonSecretDiscoveryService)
