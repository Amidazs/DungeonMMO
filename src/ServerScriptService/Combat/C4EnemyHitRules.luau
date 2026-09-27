--!strict
-- Source-backed C4 normal-attack hit resolution for live Dungeon NPCs.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Formula = require(
    ReplicatedStorage.Core.Shared.C4CombatFormulaReference
)
local AccuracyDebuff = require(
    ServerScriptService.Combat.C4NpcAccuracyDebuffService
)
local NpcBoundary = require(
    ServerScriptService.Core.Services.C4NpcSourceBoundaryService
)
local ProgressionRuntimeState = require(
    ServerScriptService.Core.Services.ProgressionRuntimeState
)

local C4EnemyHitRules = {}
local HIT_RANDOM = Random.new()

--[[
Returns a compatibility-preserving hit when source boundaries are unavailable.

Args:
    reason (string): Source migration reason kept for diagnostics.

Returns:
    any: Successful legacy result without claiming C4 source parity.
]]
local function legacy_hit(reason: string): any
    return {
        SourceReady = false,
        Hit = true,
        Miss = false,
        SourceReason = reason,
        SourceConditionMultiplier = 1,
    }
end

--[[
Resolves one live NPC ordinary-attack hit with C4 Accuracy/Evasion.

The source normal-attack condition multiplier remains neutral at one, matching
the current player-side source migration boundary. Unsupported NPC/player
identities preserve the existing legacy hit rather than breaking encounters.

Args:
    enemy (Model): Server-owned reviewed NPC attacker.
    player (Player): Current server-owned player target.
    supplied_roll (number?): Optional deterministic 0-999 roll for tests.

Returns:
    any: Source hit evidence or compatibility-preserving legacy hit.
]]
function C4EnemyHitRules.resolve_normal_attack(
    enemy: Model,
    player: Player,
    supplied_roll: number?
): any
    local npc, npc_reason = NpcBoundary.for_model(enemy)
    if not npc then
        return legacy_hit(
            npc_reason or "C4NpcSourceBoundaryUnavailable"
        )
    end

    npc = AccuracyDebuff.decorate_boundary(enemy, npc)

    local player_boundary, player_reason =
        ProgressionRuntimeState.get_c4_resource_migration_boundary(
            player.UserId
        )
    if not player_boundary
        or type(player_boundary.SourceStatCandidate) ~= "table"
    then
        return legacy_hit(
            player_reason or "C4PlayerSourceBoundaryUnavailable"
        )
    end

    local accuracy =
        npc.SourceStatCandidate.ACCURACY_COMBAT
    local evasion =
        player_boundary.SourceStatCandidate.EVASION_RATE
    if type(accuracy) ~= "number"
        or type(evasion) ~= "number"
    then
        return legacy_hit("C4HitStatsUnavailable")
    end

    local roll = supplied_roll
        or HIT_RANDOM:NextInteger(0, 999)
    local resolved =
        Formula.resolve_normal_attack_hit(
            accuracy,
            evasion,
            1,
            roll
        )

    return {
        SourceReady = true,
        Hit = resolved.Hit,
        Miss = resolved.Miss,
        ChancePerThousand = resolved.ChancePerThousand,
        Roll = resolved.Roll,
        SourceAccuracy = accuracy,
        SourceEvasion = evasion,
        AccuracyPenalty =
            AccuracyDebuff.get_penalty(enemy),
        SourceConditionMultiplier = 1,
        SourceConditionIntegrated = false,
    }
end

return table.freeze(C4EnemyHitRules)
