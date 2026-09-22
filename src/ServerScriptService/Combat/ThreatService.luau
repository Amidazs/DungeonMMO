--!strict
-- Server-authoritative per-enemy threat ledger shared by dungeon enemies
-- and world bosses. Distance is only used before any eligible threat exists.
local RunService = game:GetService("RunService")

local ThreatService = {}

type ThreatLedger = {[number]: number}
type Candidate = {
    player: Player,
    distance: number,
}

local SUPPORT_THREAT_MULTIPLIER = 0.5

local ledgers: {[Model]: ThreatLedger} = {}
local candidate_users: {[Model]: {[number]: boolean}} = {}

-- Args:
--   user_id: any; authenticated Roblox player identity.
-- Returns:
--   boolean: live positive ID, or negative local Studio test identity.
local function valid_user_id(user_id: any): boolean
    return type(user_id) == "number"
        and user_id % 1 == 0
        and user_id < math.huge and user_id > -math.huge
        and (user_id > 0
            or (user_id < 0 and RunService:IsStudio()))
end

local function valid_amount(amount: any): boolean
    return type(amount) == "number"
        and amount == amount
        and amount > 0
        and amount < math.huge
end

local function get_ledger(enemy: Model): ThreatLedger
    local ledger = ledgers[enemy]
    if not ledger then
        ledger = {}
        ledgers[enemy] = ledger
    end
    return ledger
end

-- Args:
--   enemy: Model; authoritative hostile NPC that owns this threat table.
--   user_id: number; authenticated player receiving threat.
--   amount: number; positive server-calculated threat amount.
-- Returns:
--   number: the player's updated threat total for this enemy.
function ThreatService.add_threat(
    enemy: Model,
    user_id: number,
    amount: number
): number
    assert(enemy:IsA("Model"), "Threat enemy must be a Model")
    assert(valid_user_id(user_id),
        "Threat user ID must be a valid player identity")
    assert(valid_amount(amount), "Threat amount must be positive and finite")

    local ledger = get_ledger(enemy)
    local updated = (ledger[user_id] or 0) + amount
    assert(valid_amount(updated),
        "Threat total must remain positive and finite")
    ledger[user_id] = updated
    return updated
end

-- Args:
--   enemy: Model; hostile NPC damaged by the player.
--   player: Player; authoritative attacker from DamageService.
--   damage: number; actual health damage applied by the server.
-- Returns:
--   number: updated threat total after one point of threat per damage.
function ThreatService.record_damage(
    enemy: Model,
    player: Player,
    damage: number
): number
    return ThreatService.add_threat(enemy, player.UserId, damage)
end

-- Args:
--   enemy: Model; hostile NPC whose attention should be forced.
--   player: Player; authenticated taunting player.
--   bonus_threat: number; positive server-owned threat added above leader.
-- Returns:
--   number: new threat total guaranteed to exceed the current leader.
function ThreatService.taunt(
    enemy: Model,
    player: Player,
    bonus_threat: number
): number
    assert(valid_amount(bonus_threat),
        "Taunt bonus threat must be positive and finite")

    local ledger = get_ledger(enemy)
    local highest = 0
    for _, value in pairs(ledger) do
        highest = math.max(highest, value)
    end

    local forced = math.max(
        ledger[player.UserId] or 0,
        highest + bonus_threat
    )
    assert(valid_amount(forced),
        "Taunt must not overflow the enemy threat ledger")
    ledger[player.UserId] = forced
    return forced
end

-- Args:
--   enemy: Model; hostile NPC with a threat ledger.
--   user_id: number; player whose current value is requested.
-- Returns:
--   number: non-negative current threat.
function ThreatService.get_threat(
    enemy: Model,
    user_id: number
): number
    local ledger = ledgers[enemy]
    return if ledger then ledger[user_id] or 0 else 0
end

--[[
Removes a fraction of the authenticated caster's existing threat on one NPC.

Args:
    enemy (Model): Server-confirmed NPC with a threat ledger.
    player (Player): Original attacking player.
    fraction (number): Authoritative positive reduction fraction.

Returns:
    number: Threat removed, or zero when the player had no threat.
]]
function ThreatService.reduce_threat(
    enemy: Model,
    player: Player,
    fraction: number
): number
    assert(enemy:IsA("Model"), "Threat target must be an NPC Model")
    assert(player:IsA("Player") and valid_user_id(player.UserId),
        "Threat-reduction caster must have a valid player identity")
    assert(type(fraction) == "number"
        and fraction == fraction
        and fraction > 0 and fraction < math.huge,
        "Threat reduction must be positive and finite")

    local ledger = ledgers[enemy]
    local before = if ledger then ledger[player.UserId] or 0 else 0
    if before <= 0 then
        return 0
    end

    local after = before * (1 - math.clamp(fraction, 0, 0.85))
    ledger[player.UserId] = after
    return before - after
end

-- Args:
--   caster: Player; authenticated player creating effective support.
--   target: Player; living ally who received healing or ward absorption.
--   effective_amount: number; actual health restored or damage absorbed.
-- Returns:
--   number: count of engaged enemies that received support threat.
function ThreatService.record_support(
    caster: Player,
    target: Player,
    effective_amount: number
): number
    assert(valid_user_id(caster.UserId),
        "Support threat caster must have a valid player identity")
    assert(valid_user_id(target.UserId),
        "Support threat target must have a valid player identity")
    assert(valid_amount(effective_amount),
        "Support threat amount must be positive and finite")

    local threat_amount = effective_amount * SUPPORT_THREAT_MULTIPLIER
    local affected = 0

    for enemy, users in pairs(candidate_users) do
        local ledger = ledgers[enemy]
        local engaged = false
        if ledger then
            for user_id, amount in pairs(ledger) do
                if users[user_id] == true and amount > 0 then
                    engaged = true
                    break
                end
            end
        end

        if enemy.Parent
            and engaged
            and users[caster.UserId] == true
            and users[target.UserId] == true
        then
            ThreatService.add_threat(enemy, caster.UserId, threat_amount)
            affected += 1
        end
    end

    return affected
end

-- Args:
--   enemy: Model; hostile NPC choosing its current target.
--   candidates: {Candidate}; living, encounter-valid, targetable players.
-- Returns:
--   (Player?, string): highest-threat player, otherwise nearest player.
function ThreatService.select_target(
    enemy: Model,
    candidates: {Candidate}
): (Player?, string)
    local users: {[number]: boolean} = {}
    for _, candidate in ipairs(candidates) do
        users[candidate.player.UserId] = true
    end
    candidate_users[enemy] = users

    local ledger = ledgers[enemy]
    local best_player: Player? = nil
    local best_threat = 0
    local best_distance = math.huge

    if ledger then
        for _, candidate in ipairs(candidates) do
            local threat = ledger[candidate.player.UserId] or 0
            if threat > 0
                and (threat > best_threat
                    or (threat == best_threat
                        and candidate.distance < best_distance))
            then
                best_player = candidate.player
                best_threat = threat
                best_distance = candidate.distance
            end
        end
    end

    if best_player then
        return best_player, "Threat"
    end

    for _, candidate in ipairs(candidates) do
        if candidate.distance < best_distance then
            best_player = candidate.player
            best_distance = candidate.distance
        end
    end

    return best_player, if best_player then "Nearest" else "None"
end

-- Args:
--   user_id: number; authenticated ID of the departing player.
-- Returns:
--   nil: discards their threat and candidacy across active enemies.
function ThreatService.remove_player(user_id: number)
    assert(valid_user_id(user_id),
        "Departing threat user ID must be a valid player identity")

    for _, ledger in pairs(ledgers) do
        ledger[user_id] = nil
    end

    for _, users in pairs(candidate_users) do
        users[user_id] = nil
    end
end

-- Args:
--   enemy: Model; hostile NPC whose encounter has ended.
-- Returns:
--   nil: removes all per-player threat for that NPC.
function ThreatService.clear(enemy: Model)
    ledgers[enemy] = nil
    candidate_users[enemy] = nil
end

return table.freeze(ThreatService)
