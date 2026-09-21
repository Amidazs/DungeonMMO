--!strict
-- Keep failed departure saves recoverable without handing the same
-- account to another writer before its dirty profile is persisted.
local WorldBossProfileExit = {}
WorldBossProfileExit.__index = WorldBossProfileExit

-- Args:
--   profiles: any; existing authoritative ProfileService.
--   leases: any; existing exclusive ProfileLeaseService.
-- Returns:
--   any: per-server tracker for unfinished departing profile saves.
function WorldBossProfileExit.new(profiles: any, leases: any): any
    assert(profiles ~= nil and leases ~= nil,
        "World boss exit requires profile and lease services")
    return setmetatable({
        _profiles = profiles,
        _leases = leases,
        _pending = {},
    }, WorldBossProfileExit)
end

-- Args:
--   user_id: number; the departing, server-owned character.
-- Returns:
--   boolean: whether their profile still awaits a successful save.
function WorldBossProfileExit:is_pending(user_id: number): boolean
    return self._pending[user_id] == true
end

-- Args:
--   user_id: number; departing character owned by this server.
--   reason: string; reason passed to the existing ProfileService.
-- Returns:
--   (boolean, string?): success only after save and lease release.
function WorldBossProfileExit:release(
    user_id: number,
    reason: string
): (boolean, string?)
    local saved, error_message = self._profiles:release(user_id, reason)
    if saved then
        self._pending[user_id] = nil
        return true, nil
    end

    self._pending[user_id] = true
    warn("[World Boss] Departure profile save pending for "
        .. tostring(user_id) .. ": " .. tostring(error_message))
    return false, error_message
end

-- Args: None.
-- Returns:
--   number: count of accounts that still need another safe save retry.
function WorldBossProfileExit:retry_pending(): number
    for user_id in pairs(self._pending) do
        local renewed = self._leases:renew(user_id)
        if not renewed.ok then
            warn("[World Boss] Pending profile lease unavailable for "
                .. tostring(user_id) .. ": "
                .. tostring(renewed.reason))
            continue
        end
        -- ProfileService clears its local cache after a successful save
        -- but before releasing the lease. If that final lease write
        -- failed, repeating ProfileService:release would return early
        -- because no writable profile remains. Finish the lease release
        -- explicitly only after confirming there is no dirty profile.
        if self._profiles:get_profile(user_id) == nil then
            local released = self._leases:release(user_id)
            if released.ok then
                self._pending[user_id] = nil
            else
                warn("[World Boss] Saved profile lease release pending: "
                    .. tostring(released.reason))
            end
        else
            self:release(user_id, "WorldBossDepartureRetry")
        end
    end

    local remaining = 0
    for _ in pairs(self._pending) do
        remaining += 1
    end
    return remaining
end

return table.freeze(WorldBossProfileExit)
