--!strict
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared_folder = ReplicatedStorage:WaitForChild("Combat"):WaitForChild("Shared")
local CombatConfig = require(shared_folder:WaitForChild("CombatConfig"))
local CriticalHitRules = require(shared_folder:WaitForChild("CriticalHitRules"))
local ScoutAccuracyRules = require(
    shared_folder:WaitForChild("ScoutAccuracyRules")
)
local CollectionService = game:GetService("CollectionService")
local CombatValidationService = require(script.Parent:WaitForChild("CombatValidationService"))
local WardService = require(script.Parent:WaitForChild("WardService"))
local CombatStatusService = require(
    script.Parent:WaitForChild("CombatStatusService")
)
local BlockedHitDamageRules = require(
    script.Parent:WaitForChild("BlockedHitDamageRules")
)
local ScoutAccuracyToggleService = require(
    script.Parent:WaitForChild("ScoutAccuracyToggleService")
)
local IronvowAccuracyToggleService = require(
    script.Parent:WaitForChild("IronvowAccuracyToggleService")
)
local ProgressionRuntimeState = require(
    ServerScriptService.Core.Services.ProgressionRuntimeState
)

local DamageService = {}
local critical_random = Random.new()

export type DamageContext = {
    attacker: Player?, attacker_character: Model?, target: Model,
    source_kind: string, source_id: string, attack_id: string?,
    base_damage: number, multiplier: number, sequence_id: number?,
    critical_chance: number?, critical_damage_multiplier: number?,
    critical_roll: number?, accuracy_roll: number?,
    blocked: boolean?,
}

local damage_callback:
    ((DamageContext, number, boolean) -> ())? = nil
local player_resource_damage_resolver:
    ((Player, number, boolean) -> (number, number))? = nil
local source_damage_adapter:
    ((DamageContext) -> any)? = nil

function DamageService.calculate_damage(base_damage: number, multiplier: number): number
    return math.max(0, base_damage * multiplier)
end

function DamageService.set_damage_callback(
    callback: ((DamageContext, number, boolean) -> ())?
)
    damage_callback = callback
end

--[[
Installs the optional server-only player resource damage resolver.

The resolver receives damage only after ordinary mitigation and ward
absorption. While the C4 cutover is inactive it must return the original
damage unchanged.

Args:
    callback ((Player, number, boolean) -> (number, number))?: Server-owned
        defender resolver returning HP damage and CP absorbed.

Returns:
    nil: Future player hits may pass through the optional resource layer.
]]
function DamageService.set_player_resource_damage_resolver(
    callback: ((Player, number, boolean) -> (number, number))?
)
    player_resource_damage_resolver = callback
end

--[[
Installs the optional server-only source damage dispatch adapter.

The adapter receives the existing trusted DamageService context. A disabled
adapter returns Handled=false and leaves the current damage path unchanged.

Args:
    callback (((DamageContext) -> any)?): Source dispatch callback or nil.

Returns:
    nil: Future eligible damage contexts may use the optional source path.
]]
function DamageService.set_source_damage_adapter(
    callback: ((DamageContext) -> any)?
)
    source_damage_adapter = callback
end

local function resolve_critical_multiplier(context: DamageContext): number
    if type(context.critical_chance) ~= "number"
        or type(context.critical_damage_multiplier) ~= "number" then return 1 end
    local roll = context.critical_roll
    if type(roll) ~= "number" then roll = critical_random:NextNumber() end
    return CriticalHitRules.resolve(context.critical_chance, context.critical_damage_multiplier, roll).multiplier
end

function DamageService.apply_damage(context: DamageContext): number
    -- Projectile or delayed-hit callbacks may arrive after the attacker
    -- dies or returns as a spectator. No damage or reward then applies.
    local attacker = context.attacker
    if attacker and attacker:GetAttribute(
        CombatConfig.DUNGEON_COMBAT_ALLOWED_ATTRIBUTE
    ) == false then
        return 0
    end
    local humanoid = context.target:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return 0 end

    if source_damage_adapter then
        local source_result = source_damage_adapter(context)
        if type(source_result) == "table"
            and source_result.Handled == true
        then
            local applied_damage =
                tonumber(source_result.AppliedDamage) or 0
            applied_damage = math.max(applied_damage, 0)

            if source_result.Miss == true then
                CombatValidationService.emit(
                    attacker,
                    "DAMAGE",
                    "MISSED",
                    tostring(context.source_id),
                    context.sequence_id
                )
            elseif source_result.StatusApplied == true then
                CombatValidationService.emit(
                    attacker,
                    "STATUS",
                    "APPLIED",
                    tostring(context.source_id)
                        .. " (C4 source)",
                    context.sequence_id
                )
            elseif applied_damage > 0 then
                CombatValidationService.emit(
                    attacker,
                    "DAMAGE",
                    "APPLIED",
                    string.format(
                        "%s %.1fHP -> %s (C4 source)",
                        context.attack_id or context.source_id,
                        applied_damage,
                        context.target.Name
                    ),
                    context.sequence_id
                )
            else
                CombatValidationService.emit(
                    attacker,
                    "DAMAGE",
                    "REJECT",
                    tostring(
                        source_result.Reason
                            or "C4SourceDamageNotApplied"
                    ),
                    context.sequence_id
                )
            end

            return applied_damage
        end
    end

    local normal_damage = DamageService.calculate_damage(
        context.base_damage,
        context.multiplier
    )
    if normal_damage <= 0 then return 0 end
    -- Only actual player-owned physical attacks against server-tagged NPCs
    -- with authored evasiveness can miss. An ordinary NPC with no
    -- evasiveness attribute retains the existing guaranteed contact hit.
    if attacker and (context.source_kind == "Melee"
        or context.source_kind == "RangedPhysical")
        and CollectionService:HasTag(
            context.target, CombatConfig.TARGETS.NPC_TAG
        )
    then
        local evasion = context.target:GetAttribute("CombatEvasionChance")
        if type(evasion) == "number" and evasion > 0 then
            local accuracy = math.clamp(
                ScoutAccuracyToggleService.get_bonus(attacker)
                    + IronvowAccuracyToggleService.get_bonus(attacker),
                0, 0.20
            )
            local roll = context.accuracy_roll
            if type(roll) ~= "number" then
                roll = critical_random:NextNumber()
            end
            if not ScoutAccuracyRules.is_hit(evasion, accuracy, roll) then
                CombatValidationService.emit(
                    attacker, "DAMAGE", "MISSED",
                    context.source_id, context.sequence_id
                )
                return 0
            end
        end
    end
    local damage = normal_damage * resolve_critical_multiplier(context)
    local incoming_damage = damage
    local defender = Players:GetPlayerFromCharacter(context.target)
    if defender and context.source_kind == "EnemyMelee" then
        local moving = humanoid.MoveDirection.Magnitude > 0.1
            and humanoid.WalkSpeed > 0
        local passive_evasion = ProgressionRuntimeState
            .get_scout_evasion_chance(defender.UserId, moving)
        local active_evasion = CombatStatusService.get(
            context.target, "Evasion"
        )
        local stance_penalty = CombatStatusService
            .get_evasion_penalty_chance(context.target)
        local evasion = math.clamp(
            passive_evasion + active_evasion - stance_penalty,
            0, 0.40
        )
        if evasion > 0 and critical_random:NextNumber() < evasion then
            CombatValidationService.emit(
                defender, "DAMAGE", "EVADED",
                context.source_id, context.sequence_id
            )
            return 0
        end
    end
    if defender and (
        context.source_kind == "EnemyMelee"
        or context.source_kind == "EnemyArea"
        or context.source_kind == "EnemyBow"
    ) then
        -- C4-inspired light-armour mastery mitigates real physical NPC
        -- attacks only. Magic, player attacks and unarmoured targets are
        -- unaffected; the defender's saved equipment/ranks own the value.
        local reduction = ProgressionRuntimeState
            .get_light_armor_reduction(defender.UserId)
        local fighter_reduction = ProgressionRuntimeState
            .get_fighter_armor_reduction(defender.UserId)
        local shield_reduction = ProgressionRuntimeState
            .get_oathguard_shield_reduction(defender.UserId)
        local warden_shield_reduction = ProgressionRuntimeState
            .get_greenward_warden_shield_reduction(defender.UserId)
        local mystic_reduction = ProgressionRuntimeState
            .get_mystic_armor_reduction(defender.UserId)
        local guard_bonus = CombatStatusService.get(
            context.target, "PhysicalGuard"
        )
        local novice_reduction = ProgressionRuntimeState
            .get_novice_physical_reduction(defender.UserId)
        local bow_bonus = if context.source_kind == "EnemyBow"
            then CombatStatusService.get(context.target, "BowGuard")
            else 0
        local fortress_bonus = CombatStatusService.get(
            context.target, "Fortress"
        )
        local max_reduction = if fortress_bonus > 0 then 0.70
            else 0.50
        damage *= 1 - math.clamp(
            reduction + fighter_reduction + shield_reduction
                + warden_shield_reduction + mystic_reduction + guard_bonus + novice_reduction
                + fortress_bonus + bow_bonus,
            0, max_reduction
        )
    elseif defender and context.source_kind == "EnemyMagic" then
        local mystic_reduction = ProgressionRuntimeState
            .get_mystic_magic_reduction(defender.UserId)
        local oathguard_reduction = ProgressionRuntimeState
            .get_oathguard_magic_reduction(defender.UserId)
        local greenward_reduction = ProgressionRuntimeState
            .get_greenward_warden_magic_reduction(defender.UserId)
        local fortress_bonus = CombatStatusService.get(
            context.target, "Fortress"
        )
        local max_reduction = if fortress_bonus > 0 then 0.70
            else 0.25
        damage *= 1 - math.clamp(
            mystic_reduction + oathguard_reduction
                + greenward_reduction + fortress_bonus,
            0, max_reduction
        )
    end
    -- The genuine server DefenseService decides whether this was blocked.
    -- Guard-break strikes are ordinary hits, and a timed parry/dodge never
    -- enters this damage path. This resolves chip after earned mitigations,
    -- before separate ward absorption; client flags are never trusted.
    if defender then
        damage = BlockedHitDamageRules.resolve(
            incoming_damage,
            damage,
            context.source_kind,
            context.blocked
        )
    end
    local health_damage, ward_absorbed = WardService.absorb_damage(
        context.target, damage
    )
    local cp_absorbed = 0

    if defender
        and health_damage > 0
        and player_resource_damage_resolver
    then
        health_damage, cp_absorbed =
            player_resource_damage_resolver(
                defender,
                health_damage,
                attacker ~= nil
            )
    end

    if health_damage > 0 then
        humanoid:TakeDamage(health_damage)
    end

    local observer = context.attacker
    if not observer then observer = Players:GetPlayerFromCharacter(context.target) end
    local detail = string.format(
        "%s %.1fHP -> %s",
        context.attack_id or context.source_id,
        health_damage,
        context.target.Name
    )
    if ward_absorbed > 0 then
        detail ..= string.format(
            " (%.1f absorbed by Arcane Ward)",
            ward_absorbed
        )
    end
    if cp_absorbed > 0 then
        detail ..= string.format(
            " (%.1f absorbed by C4 CP)",
            cp_absorbed
        )
    end
    CombatValidationService.emit(observer, "DAMAGE", "APPLIED", detail, context.sequence_id)
    if CombatConfig.DEBUG.PRINT_DAMAGE then
        print(string.format("[Damage] %s -%.1f HP", context.target.Name, health_damage))
    end

    if health_damage > 0 and damage_callback then
        -- A killing blow has already reduced Humanoid.Health to zero
        -- when this callback runs. Preserve that trusted hit evidence
        -- so the world-boss contribution gate does not discard it.
        damage_callback(context, health_damage, humanoid.Health <= 0)
    end

    return health_damage
end

return table.freeze(DamageService)
