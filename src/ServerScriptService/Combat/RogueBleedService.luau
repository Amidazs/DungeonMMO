--!strict
-- Authoritative non-stacking damage-over-time for confirmed Rogue hits.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local CombatConfig = require(
    ReplicatedStorage.Combat.Shared.CombatConfig
)
local CombatTargetRules = require(
    script.Parent:WaitForChild("CombatTargetRules")
)
local DamageService = require(
    script.Parent:WaitForChild("DamageService")
)
local ProgressionBridge = require(
    ServerScriptService.Dungeon.DungeonProgressionBridge
)

local BleedService = {}
local MAX_TICKS = 6
local MAX_TICK_DAMAGE = 50
local MIN_INTERVAL = 0.2
local MAX_INTERVAL = 5
local records: {[Model]: any} = {}

--[[
Removes the active bleed and its replicated presentation attributes.

Args:
    target (Model): NPC whose bleed should be cleared.

Returns:
    nil: Removes the record and safely invalidates old delayed ticks.
]]
function BleedService.clear(target: Model)
    records[target] = nil
    if target.Parent then
        target:SetAttribute("RogueBleedRemainingTicks", 0)
        target:SetAttribute("RogueBleedExpiresAt", 0)
        target:SetAttribute("RogueBleedSourceUserId", 0)
    end
end

--[[
Validates that the same living, admitted player still owns the effect.

Args:
    record (any): Original server-authored bleed application.
    target (Model): NPC receiving a scheduled damage tick.

Returns:
    boolean: Whether this tick may affect the current PvE encounter.
]]
local function can_tick(record: any, target: Model): boolean
    local player = record.player
    local character = record.character
    if player.Parent ~= Players
        or not target:IsDescendantOf(workspace)
        or player.Character ~= character
        or not character.Parent
        or player:GetAttribute(
            CombatConfig.DUNGEON_COMBAT_ALLOWED_ATTRIBUTE
        ) == false
    then
        return false
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return false
    end

    return CombatTargetRules.is_damageable(character, target)
end

--[[
Applies one scheduled tick only if its original application is current.

Args:
    target (Model): NPC originally hit by the Rogue.
    record (any): Immutable identity of the scheduled bleed.

Returns:
    nil: Deals an attributed server damage tick or cancels the bleed.
]]
local function run_tick(target: Model, record: any)
    if records[target] ~= record then
        return
    end
    if not can_tick(record, target) then
        BleedService.clear(target)
        return
    end

    local applied_damage = DamageService.apply_damage({
        attacker = record.player,
        attacker_character = record.character,
        target = target,
        source_kind = "StatusPhysical",
        source_id = record.skill_id,
        attack_id = nil,
        base_damage = record.tick_damage,
        multiplier = 1,
        sequence_id = nil,
        critical_chance = 0,
        critical_damage_multiplier = 1,
    })
    ProgressionBridge.award_damage(
        record.player, record.skill_id, target, applied_damage, 1
    )

    record.remaining -= 1
    target:SetAttribute("RogueBleedRemainingTicks", record.remaining)
    local target_humanoid = target:FindFirstChildOfClass("Humanoid")
    if record.remaining == 0
        or applied_damage <= 0
        or not target_humanoid
        or target_humanoid.Health <= 0
    then
        BleedService.clear(target)
        return
    end

    task.delay(record.interval, function()
        run_tick(target, record)
    end)
end

--[[
Begins or refreshes a single attributed bleed after a real melee hit.

Only a living tagged NPC may be affected. Reapplication replaces the old
record rather than stacking concurrent damage streams; delayed callbacks
from older applications cannot damage the refreshed target.

Args:
    player (Player): Authoritative attacker who landed the skill.
    target (Model): Server-confirmed living NPC target.
    skill_id (string): Server-authored source skill ID.
    tick_damage (number): Damage dealt per scheduled tick.
    tick_count (number): Positive number of ticks, capped at six.
    interval (number): Seconds between ticks, at least 0.2.

Returns:
    boolean: True if an eligible NPC received an active bleed.
]]
function BleedService.apply(
    player: Player,
    target: Model,
    skill_id: string,
    tick_damage: number,
    tick_count: number,
    interval: number
): boolean
    local character = player.Character
    if type(skill_id) ~= "string"
        or skill_id == ""
        or type(tick_damage) ~= "number"
        or tick_damage <= 0
        or tick_damage > MAX_TICK_DAMAGE
        or tick_damage ~= tick_damage
        or type(tick_count) ~= "number"
        or tick_count < 1
        or tick_count > MAX_TICKS
        or tick_count ~= math.floor(tick_count)
        or type(interval) ~= "number"
        or interval < MIN_INTERVAL
        or interval > MAX_INTERVAL
        or interval ~= interval
        or not character
    then
        return false
    end

    local record = {
        player = player,
        character = character,
        skill_id = skill_id,
        tick_damage = tick_damage,
        remaining = tick_count,
        interval = interval,
    }
    if not can_tick(record, target) then
        return false
    end

    records[target] = record
    target:SetAttribute("RogueBleedRemainingTicks", tick_count)
    target:SetAttribute(
        "RogueBleedExpiresAt", os.clock() + tick_count * interval
    )
    target:SetAttribute("RogueBleedSourceUserId", player.UserId)
    task.delay(interval, function()
        run_tick(target, record)
    end)
    return true
end

return table.freeze(BleedService)
