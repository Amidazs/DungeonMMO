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

local ledgers: {[Model]: ThreatLedger} = {}

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

-- Args:
--   enemy: Model; hostile NPC choosing its current target.
--   candidates: {Candidate}; living, encounter-valid, targetable players.
-- Returns:
--   (Player?, string): highest-threat player, otherwise nearest player.
function ThreatService.select_target(
    enemy: Model,
    candidates: {Candidate}
): (Player?, string)
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
--   enemy: Model; hostile NPC whose encounter has ended.
-- Returns:
--   nil: removes all per-player threat for that NPC.
function ThreatService.clear(enemy: Model)
    ledgers[enemy] = nil
end

return table.freeze(ThreatService)
