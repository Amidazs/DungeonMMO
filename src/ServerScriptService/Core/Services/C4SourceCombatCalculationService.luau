--!strict
-- Disabled source-only C4 skill damage/healing calculation provider.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared

local Formula = require(
    Shared.C4CombatFormulaReference
)
local SkillEffects = require(
    Shared.C4SkillEffectSource
)
local Runtime = require(
    ServerScriptService.Core.Services.ProgressionRuntimeState
)

local C4SourceCombatCalculationService = {}

local COMBAT_RANDOM = Random.new()

local feature_enabled = false

--[[
Returns a source-ready stat boundary for one authoritative runtime owner.

Args:
    user_id (number): Server-owned selected character user ID.

Returns:
    (any?, string?): Source-ready migration boundary or strict reason.
]]
local function source_boundary(
    user_id: number
): (any?, string?)
    local boundary, reason =
        Runtime.get_c4_resource_migration_boundary(user_id)

    if not boundary then
        return nil, reason
    end

    if boundary.CutoverPrerequisitesReady ~= true
        or boundary.SourceStatCandidateReady ~= true
        or type(boundary.SourceStatCandidate) ~= "table"
    then
        return nil, "C4SourceCombatPrerequisitesIncomplete"
    end

    return boundary, nil
end

--[[
Resolves an actually owned creative active skill to its pinned C4 rank.

Args:
    user_id (number): Authenticated runtime skill owner.
    creative_skill_id (string): Creative skill selected by server code.
    creative_rank (number): Server-resolved purchased creative rank.

Returns:
    (any?, any?, string?): Source link, source effect rank, or denial reason.
]]
local function source_skill(
    user_id: number,
    creative_skill_id: string,
    creative_rank: number
): (any?, any?, string?)
    local source, reason =
        Runtime.resolve_c4_active_source_effect(
            user_id,
            creative_skill_id,
            creative_rank
        )

    if not source then
        return nil, nil, reason
    end

    local effect = SkillEffects.get_rank(
        source.SkillId,
        source.Rank
    )

    if not effect then
        return nil, nil, "OriginalCombatSkillEffectUnavailable"
    end

    return source, effect, nil
end

--[[
Returns the direct Heal effect power from one source HEAL skill rank.

Args:
    effect (any): Pinned C4 source skill-effect rank.

Returns:
    (number?, string?): Exact heal effect power or strict source-data reason.
]]
local function heal_power(effect: any): (number?, string?)
    for _, row in ipairs(effect.Effects) do
        if row.name == "Heal"
            and type(row.power) == "number"
            and row.power > 0
        then
            return row.power, nil
        end
    end

    return nil, "OriginalHealPowerUnavailable"
end


--[[
Returns exact source critical-power calculator inputs.

C4 calcPhysDam reads PHYSICAL_CRITICAL_POWER with a neutral base of 1 and
PHYSICAL_CRITICAL_POWER_ADD with a neutral base of 0. Both must already be
present in the authenticated final source stat candidate so this service never
invents a combat modifier.

Args:
    boundary (any): Authenticated source-ready migration boundary.

Returns:
    (number?, number?, string?): Multiplier, additive power, or strict reason.
]]
local function critical_power_inputs(
    boundary: any
): (number?, number?, string?)
    local stats = boundary.SourceStatCandidate
    local multiplier = stats.PHYSICAL_CRITICAL_POWER
    local additive = stats.PHYSICAL_CRITICAL_POWER_ADD

    if type(multiplier) ~= "number"
        or multiplier ~= multiplier
        or multiplier < 0
        or multiplier >= math.huge
        or type(additive) ~= "number"
        or additive ~= additive
        or math.abs(additive) >= math.huge
    then
        return nil, nil, "OriginalPhysicalCriticalPowerUnavailable"
    end

    return multiplier, additive, nil
end

--[[
Changes the calculation-provider gate.

This gate controls only source calculation previews. It does not alter
Humanoid HP, ManaService, CP, cooldowns, damage, healing or production saves.

Args:
    enabled (boolean): Whether source combat calculations may be requested.

Returns:
    nil: Updates only this server-local calculation gate.
]]
function C4SourceCombatCalculationService.set_enabled(
    enabled: boolean
)
    assert(
        type(enabled) == "boolean",
        "C4 source combat calculation gate must be boolean"
    )
    feature_enabled = enabled
end

--[[
Reports whether source combat calculations are currently enabled.

Args:
    None.

Returns:
    boolean: Current server-local calculation gate.
]]
function C4SourceCombatCalculationService.is_enabled(): boolean
    return feature_enabled
end

--[[
Resolves one source C4 normal-attack hit/miss roll between ready players.

This path intentionally belongs to ordinary physical attacks, not PDAM skills:
the reviewed C4 SkillPdam handler calculates PDAM directly and does not call
the normal-attack calcHitMiss path. Accuracy and Evasion come only from the
authenticated final source stat candidate. The random 0-999 roll is created
inside this server-only module.

The original positional/night/elevation hit-condition multiplier remains
neutral at 1 until Roblox equivalents are explicitly mapped and owned by the
server. That limitation is returned in the result rather than silently treated
as certified source parity.

Args:
    attacker_user_id (number): Authenticated source-ready attacker.
    defender_user_id (number): Authenticated source-ready defender.

Returns:
    (any?, string?): Source normal-attack hit result or strict denial reason.
]]
function C4SourceCombatCalculationService.normal_attack_hit(
    attacker_user_id: number,
    defender_user_id: number
): (any?, string?)
    if not feature_enabled then
        return nil, "C4SourceCombatCalculationDisabled"
    end

    local attacker, attacker_reason =
        source_boundary(attacker_user_id)
    if not attacker then
        return nil, attacker_reason
    end

    local defender, defender_reason =
        source_boundary(defender_user_id)
    if not defender then
        return nil, defender_reason
    end

    local accuracy =
        attacker.SourceStatCandidate.ACCURACY_COMBAT
    local evasion =
        defender.SourceStatCandidate.EVASION_RATE
    local roll = COMBAT_RANDOM:NextInteger(0, 999)
    local resolved = Formula.resolve_normal_attack_hit(
        accuracy,
        evasion,
        1,
        roll
    )

    return {
        Kind = "NormalAttackHit",
        Hit = resolved.Hit,
        Miss = resolved.Miss,
        ChancePerThousand = resolved.ChancePerThousand,
        Roll = resolved.Roll,
        SourceAccuracy = accuracy,
        SourceEvasion = evasion,
        SourceConditionMultiplier = 1,
        SourceConditionIntegrated = false,
        SourceOnly = true,
        LiveApplied = false,
    }, nil
end

--[[
Resolves one source C4 normal physical critical roll between ready players.

This path belongs to ordinary weapon attacks. The reviewed C4 normal-attack
flow calls getCriticalHit, caps the final source rate at 500 per thousand and
then calls calcCrit. PDAM skill critical behaviour is separate in SkillPdam
and is deliberately not claimed here.

Critical-power multiplier/additive values come from the authenticated final
source stat candidate. The random 0-999 roll is private server state.

Args:
    attacker_user_id (number): Authenticated source-ready attacker.
    defender_user_id (number): Authenticated source-ready defender.

Returns:
    (any?, string?): Source critical result or strict denial reason.
]]
function C4SourceCombatCalculationService.normal_attack_critical(
    attacker_user_id: number,
    defender_user_id: number
): (any?, string?)
    if not feature_enabled then
        return nil, "C4SourceCombatCalculationDisabled"
    end

    local attacker, attacker_reason =
        source_boundary(attacker_user_id)
    if not attacker then
        return nil, attacker_reason
    end

    local defender, defender_reason =
        source_boundary(defender_user_id)
    if not defender then
        return nil, defender_reason
    end

    local multiplier, additive, power_reason =
        critical_power_inputs(attacker)
    if multiplier == nil or additive == nil then
        return nil, power_reason
    end

    local critical_rate =
        attacker.SourceStatCandidate.CRITICAL_RATE
    local roll = COMBAT_RANDOM:NextInteger(0, 999)
    local resolved = Formula.resolve_physical_critical(
        critical_rate,
        roll
    )

    return {
        Kind = "NormalAttackCritical",
        Critical = resolved.Critical,
        ChancePerThousand = resolved.ChancePerThousand,
        Roll = resolved.Roll,
        SourceCriticalRate = critical_rate,
        CriticalPowerMultiplier = multiplier,
        CriticalPowerAdd = additive,
        TargetSourceReady = defender ~= nil,
        TargetSpecificCriticalModifiersIntegrated = false,
        SourceOnly = true,
        LiveApplied = false,
    }, nil
end

--[[
Calculates deterministic C4 PDAM skill damage between source-ready players.

Shots, random weapon variance, criticals, race vulnerability and PvP bonuses
remain neutral here. Those require separate authoritative runtime inputs before
live integration.

Args:
    attacker_user_id (number): Authenticated source-ready attacker.
    defender_user_id (number): Authenticated source-ready defender.
    creative_skill_id (string): Server-selected creative physical skill ID.
    creative_rank (number): Server-resolved purchased creative rank.

Returns:
    (any?, string?): Source physical result or strict denial reason.
]]
function C4SourceCombatCalculationService.physical_skill(
    attacker_user_id: number,
    defender_user_id: number,
    creative_skill_id: string,
    creative_rank: number
): (any?, string?)
    if not feature_enabled then
        return nil, "C4SourceCombatCalculationDisabled"
    end

    local attacker, attacker_reason =
        source_boundary(attacker_user_id)
    if not attacker then
        return nil, attacker_reason
    end

    local defender, defender_reason =
        source_boundary(defender_user_id)
    if not defender then
        return nil, defender_reason
    end

    local source, effect, source_reason = source_skill(
        attacker_user_id,
        creative_skill_id,
        creative_rank
    )
    if not source or not effect then
        return nil, source_reason
    end

    if effect.Sets.skillType ~= "PDAM"
        or type(effect.Sets.power) ~= "number"
    then
        return nil, "UnsupportedOriginalPhysicalSkillType"
    end

    local amount = Formula.physical_damage({
        PAtk = attacker.SourceStatCandidate.PHYSICAL_ATTACK,
        PDef = defender.SourceStatCandidate.PHYSICAL_DEFENCE,
        SkillPower = effect.Sets.power,
    })

    return {
        Kind = "PhysicalDamage",
        Amount = amount,
        SourceSkillId = source.SkillId,
        SourceRank = source.Rank,
        SourceSkillPower = effect.Sets.power,
        SourceOnly = true,
        LiveApplied = false,
    }, nil
end

--[[
Calculates deterministic C4 MDAM skill damage between source-ready players.

Failure, magic critical, Spiritshot, elemental and PvP multipliers stay neutral
until their authoritative runtime sources are integrated.

Args:
    attacker_user_id (number): Authenticated source-ready caster.
    defender_user_id (number): Authenticated source-ready defender.
    creative_skill_id (string): Server-selected creative magic skill ID.
    creative_rank (number): Server-resolved purchased creative rank.

Returns:
    (any?, string?): Source magical result or strict denial reason.
]]
function C4SourceCombatCalculationService.magic_skill(
    attacker_user_id: number,
    defender_user_id: number,
    creative_skill_id: string,
    creative_rank: number
): (any?, string?)
    if not feature_enabled then
        return nil, "C4SourceCombatCalculationDisabled"
    end

    local attacker, attacker_reason =
        source_boundary(attacker_user_id)
    if not attacker then
        return nil, attacker_reason
    end

    local defender, defender_reason =
        source_boundary(defender_user_id)
    if not defender then
        return nil, defender_reason
    end

    local source, effect, source_reason = source_skill(
        attacker_user_id,
        creative_skill_id,
        creative_rank
    )
    if not source or not effect then
        return nil, source_reason
    end

    if effect.Sets.skillType ~= "MDAM"
        or type(effect.Sets.power) ~= "number"
    then
        return nil, "UnsupportedOriginalMagicSkillType"
    end

    local amount = Formula.magic_damage({
        MAtk = attacker.SourceStatCandidate.MAGICAL_ATTACK,
        MDef = defender.SourceStatCandidate.MAGICAL_DEFENCE,
        SkillPower = effect.Sets.power,
    })

    return {
        Kind = "MagicDamage",
        Amount = amount,
        SourceSkillId = source.SkillId,
        SourceRank = source.Rank,
        SourceSkillPower = effect.Sets.power,
        SourceOnly = true,
        LiveApplied = false,
    }, nil
end

--[[
Calculates one deterministic C4 instant HEAL amount from an owned source rank.

Spiritshot modifiers remain neutral until source shot ownership/consumption is
server-authoritative. Caster M.Atk is intentionally absent because the reviewed
C4 EffectHeal implementation applies effect power directly.

Args:
    caster_user_id (number): Authenticated source-ready caster.
    creative_skill_id (string): Server-selected creative healing skill ID.
    creative_rank (number): Server-resolved purchased creative rank.

Returns:
    (any?, string?): Source healing result or strict denial reason.
]]
function C4SourceCombatCalculationService.heal_skill(
    caster_user_id: number,
    creative_skill_id: string,
    creative_rank: number
): (any?, string?)
    if not feature_enabled then
        return nil, "C4SourceCombatCalculationDisabled"
    end

    local boundary, boundary_reason =
        source_boundary(caster_user_id)
    if not boundary then
        return nil, boundary_reason
    end

    local source, effect, source_reason = source_skill(
        caster_user_id,
        creative_skill_id,
        creative_rank
    )
    if not source or not effect then
        return nil, source_reason
    end

    if effect.Sets.skillType ~= "HEAL" then
        return nil, "UnsupportedOriginalHealSkillType"
    end

    local power, power_reason = heal_power(effect)
    if not power then
        return nil, power_reason
    end

    return {
        Kind = "Heal",
        Amount = Formula.heal_amount(
            power,
            false,
            false
        ),
        SourceSkillId = source.SkillId,
        SourceRank = source.Rank,
        SourceHealPower = power,
        SourceOnly = true,
        LiveApplied = false,
    }, nil
end

--[[
Returns immutable capability metadata for the source combat provider.

Args:
    None.

Returns:
    any: Supported source formula families and deliberate non-live limits.
]]
function C4SourceCombatCalculationService.capability(): any
    return {
        Available = true,
        DefaultEnabled = false,
        CurrentlyEnabled = feature_enabled,
        NormalAttackHitResolution = true,
        NormalAttackHitRollServerOwned = true,
        NormalAttackHitConditionIntegrated = false,
        NormalAttackPhysicalCriticalResolution = true,
        NormalAttackPhysicalCriticalRollServerOwned = true,
        NormalAttackCriticalPowerIntegrated = true,
        NormalAttackTargetSpecificCriticalModifiersIntegrated = false,
        PhysicalPDAM = true,
        MagicalMDAM = true,
        InstantHeal = true,
        ShotsIntegrated = false,
        RandomWeaponVarianceIntegrated = false,
        CriticalResolutionIntegrated = false,
        PhysicalSkillCriticalIntegrated = false,
        MagicCriticalIntegrated = false,
        ShieldResolutionIntegrated = false,
        MagicFailureResolutionIntegrated = false,
        ElementalResolutionIntegrated = false,
        PvpFormulaModifiersIntegrated = false,
        LiveDamageApplied = false,
    }
end

return table.freeze(C4SourceCombatCalculationService)
