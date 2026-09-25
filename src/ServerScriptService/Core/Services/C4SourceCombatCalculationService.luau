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
local SourceItems = require(
    Shared.C4SourceItemReference
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
Resolves the exact C4 physical random-damage range from source equipment.

Reviewed weapon rnd_dam comes from the pinned C4 weapon table. An unarmed
source-ready character uses 5 + floor(sqrt(level)), matching L2Character.

Args:
    boundary (any): Authenticated source-ready migration boundary.

Returns:
    (any?, string?): Source random-damage profile or strict denial reason.
]]
local function random_damage_profile(
    boundary: any
): (any?, string?)
    local source_ids = boundary.ReviewedSourceItemIds

    if type(source_ids) ~= "table" then
        return nil, "OriginalSourceLoadoutUnavailable"
    end

    local weapon_id = source_ids.Weapon
    if weapon_id == nil then
        return {
            RandomDamage = Formula.unarmed_random_damage_range(
                boundary.Level
            ),
            SourceWeaponId = nil,
            Unarmed = true,
        }, nil
    end

    local weapon = SourceItems.get(weapon_id)
    if not weapon
        or weapon.Slot ~= "Weapon"
        or type(weapon.RandomDamage) ~= "number"
        or weapon.RandomDamage % 1 ~= 0
        or weapon.RandomDamage < 0
    then
        return nil, "OriginalWeaponRandomDamageUnavailable"
    end

    return {
        RandomDamage = weapon.RandomDamage,
        SourceWeaponId = weapon_id,
        Unarmed = false,
    }, nil
end

--[[
Rolls one server-owned C4 physical random-damage multiplier.

Args:
    boundary (any): Authenticated source-ready attacker boundary.

Returns:
    (any?, string?): Range, roll and multiplier or strict denial reason.
]]
local function source_random_variance(
    boundary: any
): (any?, string?)
    local profile, reason = random_damage_profile(boundary)
    if not profile then
        return nil, reason
    end

    local random_damage = profile.RandomDamage
    local roll = COMBAT_RANDOM:NextInteger(
        -random_damage,
        random_damage
    )

    return {
        RandomDamage = random_damage,
        Roll = roll,
        Multiplier =
            Formula.physical_random_damage_multiplier(
                random_damage,
                roll
            ),
        SourceWeaponId = profile.SourceWeaponId,
        Unarmed = profile.Unarmed,
    }, nil
end

--[[
Resolves the configured C4 magic-failure branch for one source skill.

The pinned source defaults MagicFailures to false. The exact two-roll
algorithm is still represented here so the provider can preserve source
behaviour if that source configuration is deliberately changed later.

Args:
    attacker (any): Authenticated source-ready caster boundary.
    defender (any): Authenticated source-ready defender boundary.
    effect (any): Reviewed source MDAM rank.

Returns:
    (any?, string?): Failure classification and source evidence.
]]
local function source_magic_failure(
    attacker: any,
    defender: any,
    effect: any
): (any?, string?)
    local magic_level = effect.Sets.magicLvl
    if type(magic_level) ~= "number"
        or magic_level % 1 ~= 0
    then
        return nil, "OriginalMagicLevelUnavailable"
    end

    if magic_level <= 0 then
        magic_level = attacker.Level
    end

    local threshold = Formula.magic_resist_threshold(
        defender.Level,
        magic_level
    )
    local enabled = Formula.magic_failures_default_enabled()

    if not enabled then
        return {
            Enabled = false,
            Failure = "None",
            MagicLevel = magic_level,
            Threshold = threshold,
            FirstRoll = nil,
            SecondRoll = nil,
        }, nil
    end

    local first_roll = COMBAT_RANDOM:NextInteger(0, 9999)
    local first = Formula.resolve_magic_success(
        defender.Level,
        magic_level,
        first_roll
    )

    if first.Success then
        return {
            Enabled = true,
            Failure = "None",
            MagicLevel = magic_level,
            Threshold = first.Threshold,
            FirstRoll = first.Roll,
            SecondRoll = nil,
        }, nil
    end

    local second_roll = COMBAT_RANDOM:NextInteger(0, 9999)
    local resolved = Formula.resolve_magic_failure(
        attacker.Level,
        defender.Level,
        magic_level,
        first_roll,
        second_roll
    )

    return {
        Enabled = true,
        Failure = resolved.Failure,
        MagicLevel = magic_level,
        Threshold = resolved.Threshold,
        FirstRoll = resolved.FirstRoll,
        SecondRoll = resolved.SecondRoll,
    }, nil
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
Resolves C4 shield block and perfect-shield rolls from source-ready players.

Facing eligibility is a semantic world-state input, not a source stat. This
module lives in ServerScriptService, so only trusted server code may provide
it. The later live combat executor must derive this boolean from authoritative
attacker/defender world transforms; clients must never send it.

Args:
    attacker_user_id (number): Authenticated source-ready attacker.
    defender_user_id (number): Authenticated source-ready defender.
    facing_eligible (boolean): Server-owned source shield-angle result.

Returns:
    (any?, string?): Source shield result or strict denial reason.
]]
function C4SourceCombatCalculationService.shield_resolution(
    attacker_user_id: number,
    defender_user_id: number,
    facing_eligible: boolean
): (any?, string?)
    if not feature_enabled then
        return nil, "C4SourceCombatCalculationDisabled"
    end

    if type(facing_eligible) ~= "boolean" then
        return nil, "InvalidShieldFacingEligibility"
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

    local stats = defender.SourceStatCandidate
    local shield_rate = stats.SHIELD_DEFENCE_RATE
    local shield_power = stats.SHIELD_DEFENCE_POWER

    if shield_rate == nil and shield_power == nil then
        return {
            Kind = "ShieldResolution",
            ShieldEquipped = false,
            Blocked = false,
            PerfectShield = false,
            FacingEligible = facing_eligible,
            SourceOnly = true,
            LiveApplied = false,
        }, nil
    end

    if type(shield_rate) ~= "number"
        or shield_rate < 0
        or type(shield_power) ~= "number"
        or shield_power < 0
        or type(defender.SourceDexBonus) ~= "number"
        or defender.SourceDexBonus <= 0
    then
        return nil, "OriginalShieldSourceStatsUnavailable"
    end

    local attacker_is_bow =
        type(attacker.ReviewedSourceKinds) == "table"
        and attacker.ReviewedSourceKinds.Weapon == "Bow"
    local block_roll = COMBAT_RANDOM:NextInteger(0, 99)
    local block = Formula.resolve_shield_block(
        shield_rate,
        defender.SourceDexBonus,
        attacker_is_bow,
        facing_eligible,
        block_roll
    )

    local perfect = nil
    if block.Blocked then
        perfect = Formula.resolve_perfect_shield(
            COMBAT_RANDOM:NextInteger(0, 99)
        )
    end

    return {
        Kind = "ShieldResolution",
        ShieldEquipped = true,
        ShieldDefenceRate = shield_rate,
        ShieldDefencePower = shield_power,
        SourceDexBonus = defender.SourceDexBonus,
        AttackerIsBow = attacker_is_bow,
        BowRateMultiplierApplied = attacker_is_bow,
        ShieldAngleDegrees = 120,
        FacingEligible = facing_eligible,
        EffectiveRate = block.EffectiveRate,
        BlockRoll = block.Roll,
        Blocked = block.Blocked,
        PerfectRoll = if perfect then perfect.Roll else nil,
        PerfectShield = if perfect
            then perfect.PerfectShield
            else false,
        SourceOnly = true,
        LiveApplied = false,
    }, nil
end

--[[
Resolves one source C4 physical random-damage variance roll.

This reusable source-only path supports both reviewed weapons and the original
unarmed fallback. The roll is private server state.

Args:
    attacker_user_id (number): Authenticated source-ready attacker.

Returns:
    (any?, string?): Source variance result or strict denial reason.
]]
function C4SourceCombatCalculationService.physical_random_variance(
    attacker_user_id: number
): (any?, string?)
    if not feature_enabled then
        return nil, "C4SourceCombatCalculationDisabled"
    end

    local attacker, attacker_reason =
        source_boundary(attacker_user_id)
    if not attacker then
        return nil, attacker_reason
    end

    local variance, variance_reason =
        source_random_variance(attacker)
    if not variance then
        return nil, variance_reason
    end

    return {
        Kind = "PhysicalRandomVariance",
        RandomDamage = variance.RandomDamage,
        Roll = variance.Roll,
        Multiplier = variance.Multiplier,
        SourceWeaponId = variance.SourceWeaponId,
        Unarmed = variance.Unarmed,
        SourceOnly = true,
        LiveApplied = false,
    }, nil
end

--[[
Calculates C4 PDAM skill damage between source-ready players.

Weapon or unarmed random-damage variance is now server-owned and exact.
Shots, PDAM skill criticals, race vulnerability and PvP bonuses remain neutral
until their authoritative runtime inputs are integrated.

Args:
    attacker_user_id (number): Authenticated source-ready attacker.
    defender_user_id (number): Authenticated source-ready defender.
    creative_skill_id (string): Server-selected creative physical skill ID.
    creative_rank (number): Server-resolved purchased creative rank.
    facing_eligible (boolean?): Server-owned shield-facing result when the
        defender has a reviewed source shield.

Returns:
    (any?, string?): Source physical result or strict denial reason.
]]
function C4SourceCombatCalculationService.physical_skill(
    attacker_user_id: number,
    defender_user_id: number,
    creative_skill_id: string,
    creative_rank: number,
    facing_eligible: boolean?
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

    local variance, variance_reason =
        source_random_variance(attacker)
    if not variance then
        return nil, variance_reason
    end

    local defender_stats = defender.SourceStatCandidate
    local shield_equipped =
        defender_stats.SHIELD_DEFENCE_RATE ~= nil
        or defender_stats.SHIELD_DEFENCE_POWER ~= nil
    local shield = {
        ShieldEquipped = false,
        Blocked = false,
        PerfectShield = false,
        ShieldDefencePower = 0,
        FacingEligible = facing_eligible,
    }

    if shield_equipped then
        if type(facing_eligible) ~= "boolean" then
            return nil, "ShieldFacingEligibilityRequired"
        end

        local shield_result, shield_reason =
            C4SourceCombatCalculationService.shield_resolution(
                attacker_user_id,
                defender_user_id,
                facing_eligible
            )
        if not shield_result then
            return nil, shield_reason
        end
        shield = shield_result
    end

    local amount = Formula.physical_damage({
        PAtk = attacker.SourceStatCandidate.PHYSICAL_ATTACK,
        PDef = defender.SourceStatCandidate.PHYSICAL_DEFENCE,
        SkillPower = effect.Sets.power,
        Shield = shield.Blocked,
        PerfectShield = shield.PerfectShield,
        ShieldDefense = shield.ShieldDefencePower,
        RandomDamageMultiplier = variance.Multiplier,
    })

    return {
        Kind = "PhysicalDamage",
        Amount = amount,
        RandomDamage = variance.RandomDamage,
        RandomDamageRoll = variance.Roll,
        RandomDamageMultiplier = variance.Multiplier,
        SourceWeaponId = variance.SourceWeaponId,
        Unarmed = variance.Unarmed,
        ShieldEquipped = shield.ShieldEquipped,
        ShieldBlocked = shield.Blocked,
        PerfectShield = shield.PerfectShield,
        ShieldDefencePower = shield.ShieldDefencePower,
        ShieldFacingEligible = shield.FacingEligible,
        ShieldBlockRoll = shield.BlockRoll,
        ShieldPerfectRoll = shield.PerfectRoll,
        SourceSkillId = source.SkillId,
        SourceRank = source.Rank,
        SourceSkillPower = effect.Sets.power,
        SourceOnly = true,
        LiveApplied = false,
    }, nil
end

--[[
Calculates C4 MDAM skill damage between source-ready players.

The final source magical critical rate is resolved with a private server roll.
The optional C4 magic-failure algorithm is represented exactly, while the
pinned source default keeps MagicFailures disabled. The reviewed source skill
element resolves against the defender's authenticated elemental vulnerability.
Spiritshots and PvP multipliers remain neutral until their authoritative
runtime sources are integrated.

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

    local critical_rate =
        attacker.SourceStatCandidate.MAGICAL_CRITICAL_RATE
    if type(critical_rate) ~= "number"
        or critical_rate ~= critical_rate
        or math.abs(critical_rate) >= math.huge
    then
        return nil, "OriginalMagicalCriticalRateUnavailable"
    end

    local critical = Formula.resolve_magic_critical(
        critical_rate,
        COMBAT_RANDOM:NextInteger(0, 999)
    )
    local failure, failure_reason = source_magic_failure(
        attacker,
        defender,
        effect
    )
    if not failure then
        return nil, failure_reason
    end

    local element = effect.Sets.element
    if type(element) ~= "string" or element == "" then
        return nil, "OriginalMagicElementUnavailable"
    end

    local elemental_multiplier, elemental_reason =
        Formula.elemental_vulnerability(
            element,
            defender.SourceStatCandidate
        )
    if elemental_multiplier == nil then
        return nil, elemental_reason
    end

    local amount = Formula.magic_damage({
        MAtk = attacker.SourceStatCandidate.MAGICAL_ATTACK,
        MDef = defender.SourceStatCandidate.MAGICAL_DEFENCE,
        SkillPower = effect.Sets.power,
        Failure = failure.Failure,
        MagicCritical = critical.Critical,
        ElementalMultiplier = elemental_multiplier,
    })

    return {
        Kind = "MagicDamage",
        Amount = amount,
        MagicLevel = failure.MagicLevel,
        MagicFailureEnabled = failure.Enabled,
        MagicFailure = failure.Failure,
        MagicFailureThreshold = failure.Threshold,
        MagicFailureFirstRoll = failure.FirstRoll,
        MagicFailureSecondRoll = failure.SecondRoll,
        MagicCritical = critical.Critical,
        MagicCriticalEffective =
            critical.Critical and failure.Failure == "None",
        MagicCriticalChancePerThousand =
            critical.ChancePerThousand,
        MagicCriticalRoll = critical.Roll,
        SourceMagicalCriticalRate = critical_rate,
        SourceElement = element,
        ElementalMultiplier = elemental_multiplier,
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
        PhysicalRandomVarianceResolution = true,
        RandomWeaponVarianceIntegrated = true,
        UnarmedRandomVarianceIntegrated = true,
        CriticalResolutionIntegrated = false,
        PhysicalSkillCriticalIntegrated = false,
        MagicCriticalIntegrated = true,
        MagicCriticalRollServerOwned = true,
        ShieldSourceResolutionAvailable = true,
        ShieldRollServerOwned = true,
        ShieldPhysicalFormulaIntegrated = true,
        ShieldFacingRuntimeIntegrated = false,
        ShieldResolutionIntegrated = false,
        MagicFailureFormulaAvailable = true,
        MagicFailureResolutionIntegrated = true,
        MagicFailuresSourceDefaultEnabled =
            Formula.magic_failures_default_enabled(),
        ElementalResolutionIntegrated = true,
        ElementalPlayerTargetSourceStatsIntegrated = true,
        PvpFormulaModifiersIntegrated = false,
        LiveDamageApplied = false,
    }
end

return table.freeze(C4SourceCombatCalculationService)
