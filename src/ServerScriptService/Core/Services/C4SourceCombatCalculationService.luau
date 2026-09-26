--!strict
-- Disabled source-only C4 skill damage/healing calculation provider.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared

local Formula = require(
    Shared.C4CombatFormulaReference
)
local Spatial = require(
    Shared.C4CombatSpatialReference
)
local SkillEffects = require(
    Shared.C4SkillEffectSource
)
local StatusEffects = require(
    Shared.C4StatusEffectReference
)
local SourceItems = require(
    Shared.C4SourceItemReference
)
local Runtime = require(
    ServerScriptService.Core.Services.ProgressionRuntimeState
)

local C4SourceCombatCalculationService = {}

local COMBAT_RANDOM = Random.new()

local WEAPON_VULNERABILITY_STATS = table.freeze({
    Bow = "BOW_WPN_VULN",
    Blunt = "BLUNT_WPN_VULN",
    Dagger = "DAGGER_WPN_VULN",
    Polearm = "POLE_WPN_VULN",
    Sword = "SWORD_WPN_VULN",
})

local SOURCE_COMMIT =
    "07f8536384e799f128d44198dd7ab23519660eea"

local NPC_RACE_ATTACK_STATS = table.freeze({
    NONE = table.freeze({}),
    UNDEAD = table.freeze({
        "PHYSICAL_ATK_UNDEAD",
        "PHYSICAL_ATK_MONSTERS",
    }),
    BEAST = table.freeze({
        "PHYSICAL_ATK_MONSTERS",
    }),
    ANIMAL = table.freeze({
        "PHYSICAL_ATK_ANIMALS",
    }),
    PLANT = table.freeze({
        "PHYSICAL_ATK_PLANTS",
    }),
    DRAGON = table.freeze({
        "PHYSICAL_ATK_DRAGONS",
    }),
    GIANT = table.freeze({
        "PHYSICAL_ATK_GIANTS",
    }),
    MAGIC_CREATURE = table.freeze({
        "PHYSICAL_ATK_MAGIC_CREATURES",
    }),
    BUG = table.freeze({
        "PHYSICAL_ATK_INSECTS",
    }),
    CREATURE_VALAKAS = table.freeze({
        "VALAKAS_PHYSICAL_DMG",
    }),
})

local feature_enabled = false
local shot_authority = nil

--[[
Resolves trusted server spatial inputs into reviewed C4 combat conditions.

Height delta is supplied in source coordinate units so this layer does not
invent a Roblox-stud conversion. The later live executor owns that mapping.

Args:
    spatial_context (any): Server-owned attacker/defender transform context.

Returns:
    (any?, string?): Hit-condition and shield-facing evidence.
]]
local function source_spatial_state(
    spatial_context: any
): (any?, string?)
    if type(spatial_context) ~= "table" then
        return nil, "SourceSpatialContextRequired"
    end

    local attacker_position = spatial_context.AttackerPosition
    local defender_cframe = spatial_context.DefenderCFrame
    local height_delta = spatial_context.HeightDeltaSourceUnits
    local is_night = spatial_context.IsNight

    if typeof(attacker_position) ~= "Vector3"
        or typeof(defender_cframe) ~= "CFrame"
        or type(height_delta) ~= "number"
        or type(is_night) ~= "boolean"
    then
        return nil, "InvalidSourceSpatialContext"
    end

    local relation, relation_reason = Spatial.classify_position(
        attacker_position,
        defender_cframe
    )
    if not relation then
        return nil, relation_reason
    end

    local hit_condition, hit_reason = Spatial.hit_condition(
        relation,
        height_delta,
        is_night
    )
    if not hit_condition then
        return nil, hit_reason
    end

    local shield_facing, shield_reason = Spatial.shield_facing(
        attacker_position,
        defender_cframe,
        120
    )
    if not shield_facing then
        return nil, shield_reason
    end

    return {
        PositionRelation = relation,
        HitCondition = hit_condition,
        ShieldFacing = shield_facing,
    }, nil
end

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
Validates one detached server-owned C4 NPC combat boundary.

Args:
    boundary (any): Candidate NPC source boundary from server authority.

Returns:
    (any?, string?): Validated boundary or strict denial reason.
]]
local function npc_source_boundary(
    boundary: any
): (any?, string?)
    if type(boundary) ~= "table"
        or boundary.SourceTargetKind ~= "Npc"
        or boundary.SourceCommit ~= SOURCE_COMMIT
        or boundary.SourceCombatPrerequisitesReady ~= true
        or boundary.SourceStatCandidateReady ~= true
        or type(boundary.SourceStatCandidate) ~= "table"
        or type(boundary.SourceNpcId) ~= "number"
        or boundary.SourceNpcId % 1 ~= 0
        or boundary.SourceNpcId <= 0
        or type(boundary.SourceNpcRace) ~= "string"
        or type(boundary.Level) ~= "number"
        or boundary.Level % 1 ~= 0
        or boundary.Level <= 0
    then
        return nil, "InvalidC4NpcSourceBoundary"
    end

    local required_stats = {
        "PHYSICAL_DEFENCE",
        "MAGICAL_DEFENCE",
        "EVASION_RATE",
        "FIRE_VULN",
        "WIND_VULN",
        "WATER_VULN",
        "EARTH_VULN",
        "HOLY_VULN",
        "DARK_VULN",
        "BLEED_VULN",
        "POISON_VULN",
        "BOW_WPN_VULN",
        "BLUNT_WPN_VULN",
        "DAGGER_WPN_VULN",
        "POLE_WPN_VULN",
        "SWORD_WPN_VULN",
    }

    for _, stat_name in ipairs(required_stats) do
        local value = boundary.SourceStatCandidate[stat_name]
        if type(value) ~= "number"
            or value ~= value
            or value < 0
            or value >= math.huge
        then
            return nil, "InvalidC4NpcSourceStats"
        end
    end

    return boundary, nil
end

--[[
Resolves either an authenticated player or reviewed server NPC target.

Args:
    target (any): Player UserId or detached server-owned NPC boundary.

Returns:
    (any?, string?, string?): Boundary, Player/Npc kind, or denial reason.
]]
local function source_target_boundary(
    target: any
): (any?, string?, string?)
    if type(target) == "number" then
        local boundary, reason = source_boundary(target)
        if not boundary then
            return nil, nil, reason
        end
        return boundary, "Player", nil
    end

    local boundary, reason = npc_source_boundary(target)
    if not boundary then
        return nil, nil, reason
    end

    return boundary, "Npc", nil
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
Reads one finite nonnegative source multiplier from a certified boundary.

Args:
    boundary (any): Authenticated source-ready migration boundary.
    stat_name (string): Exact C4 stat key.
    missing_reason (string): Stable denial reason when unavailable.

Returns:
    (number?, string?): Source multiplier or strict denial reason.
]]
local function source_multiplier(
    boundary: any,
    stat_name: string,
    missing_reason: string
): (number?, string?)
    local value = boundary.SourceStatCandidate[stat_name]

    if type(value) ~= "number"
        or value ~= value
        or value < 0
        or value >= math.huge
    then
        return nil, missing_reason
    end

    return value, nil
end

--[[
Resolves C4 weapon vulnerability against one source-ready player target.

The source selects a vulnerability stat from the attacker's active weapon
type. Unarmed attacks have no weapon-specific vulnerability multiplier.

Args:
    attacker (any): Authenticated source-ready attacker boundary.
    defender (any): Authenticated source-ready defender boundary.

Returns:
    (any?, string?): Weapon vulnerability evidence or strict denial reason.
]]
local function source_weapon_vulnerability(
    attacker: any,
    defender: any
): (any?, string?)
    local source_ids = attacker.ReviewedSourceItemIds
    if type(source_ids) ~= "table" then
        return nil, "OriginalSourceLoadoutUnavailable"
    end

    local weapon_id = source_ids.Weapon
    if weapon_id == nil then
        return {
            SourceWeaponId = nil,
            WeaponKind = nil,
            VulnerabilityStat = nil,
            Multiplier = 1,
            Unarmed = true,
        }, nil
    end

    local weapon = SourceItems.get(weapon_id)
    if not weapon or weapon.Slot ~= "Weapon" then
        return nil, "OriginalWeaponVulnerabilityUnavailable"
    end

    local stat_name = WEAPON_VULNERABILITY_STATS[weapon.Kind]
    if not stat_name then
        return nil, "OriginalWeaponVulnerabilityUnavailable"
    end

    local multiplier, reason = source_multiplier(
        defender,
        stat_name,
        "OriginalTargetWeaponVulnerabilityUnavailable"
    )
    if multiplier == nil then
        return nil, reason
    end

    return {
        SourceWeaponId = weapon_id,
        WeaponKind = weapon.Kind,
        VulnerabilityStat = stat_name,
        Multiplier = multiplier,
        Unarmed = false,
    }, nil
end

--[[
Resolves one player-versus-player C4 damage multiplier from source stats.

All current source-combat provider targets are authenticated player characters,
so the reviewed L2Playable-versus-L2Playable branch applies.

Args:
    attacker (any): Authenticated source-ready attacker boundary.
    stat_name (string): Exact C4 PvP damage stat.

Returns:
    (number?, string?): Source PvP multiplier or strict denial reason.
]]
local function source_pvp_multiplier(
    attacker: any,
    stat_name: string
): (number?, string?)
    return source_multiplier(
        attacker,
        stat_name,
        "OriginalPvpDamageMultiplierUnavailable"
    )
end

--[[
Resolves the PvP multiplier only when the target is another player.

Chronicle 4 applies these stats only to L2Playable-versus-L2Playable damage.
NPC targets therefore use an exact neutral multiplier of one.

Args:
    attacker (any): Authenticated source-ready attacker boundary.
    target_kind (string): Player or Npc.
    stat_name (string): Exact C4 PvP damage stat.

Returns:
    (number?, string?): Applicable multiplier or strict denial reason.
]]
local function source_target_pvp_multiplier(
    attacker: any,
    target_kind: string,
    stat_name: string
): (number?, string?)
    if target_kind == "Npc" then
        return 1, nil
    end

    return source_pvp_multiplier(attacker, stat_name)
end

--[[
Resolves Chronicle 4 player-to-NPC physical race modifiers.

The reviewed source intentionally falls through UNDEAD into BEAST, so undead
targets consume both PHYSICAL_ATK_UNDEAD and PHYSICAL_ATK_MONSTERS.

Args:
    attacker (any): Authenticated source-ready player attacker.
    defender (any): Source-ready target boundary.
    target_kind (string): Player or Npc.

Returns:
    (any?, string?): Race multiplier evidence or strict denial reason.
]]
local function source_npc_race_multiplier(
    attacker: any,
    defender: any,
    target_kind: string
): (any?, string?)
    if target_kind ~= "Npc" then
        return {
            Multiplier = 1,
            SourceNpcRace = nil,
            AppliedStats = {},
        }, nil
    end

    local race = defender.SourceNpcRace
    local stat_names = NPC_RACE_ATTACK_STATS[race]
    if not stat_names then
        return nil, "UnsupportedC4NpcRace"
    end

    local multiplier = 1
    local applied = {}

    for _, stat_name in ipairs(stat_names) do
        local value, reason = source_multiplier(
            attacker,
            stat_name,
            "OriginalNpcRaceAttackMultiplierUnavailable"
        )
        if value == nil then
            return nil, reason
        end

        multiplier *= value
        table.insert(applied, stat_name)
    end

    return {
        Multiplier = multiplier,
        SourceNpcRace = race,
        AppliedStats = applied,
    }, nil
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
Consumes the private one-use physical shot state.

Args:
    user_id (number): Authenticated source-ready attacker.

Returns:
    (any?, string?): Validated shot state or strict authority reason.
]]
local function consume_physical_shot(
    user_id: number
): (any?, string?)
    if not shot_authority
        or type(shot_authority.consume_physical) ~= "function"
    then
        return nil, "C4SourceShotAuthorityUnavailable"
    end

    local state = shot_authority:consume_physical(user_id)
    if type(state) ~= "table"
        or type(state.Soulshot) ~= "boolean"
    then
        return nil, "InvalidSourcePhysicalShotState"
    end

    return state, nil
end

--[[
Resolves elemental vulnerability for one source magic skill.

The pinned C4 formula starts at multiplier 1 and only applies an elemental
vulnerability when the source skill actually defines an element. Missing
element metadata therefore means neutral magic, not invalid source data.

Args:
    effect (any): Exact source skill effect rank.
    defender (any): Authenticated source target boundary.

Returns:
    (number?, string?, string?): Multiplier, source element, or denial reason.
]]
local function source_magic_element(
    effect: any,
    defender: any
): (number?, string?, string?)
    local element = effect.Sets.element
    if element == nil then
        return 1, nil, nil
    end
    if type(element) ~= "string" or element == "" then
        return nil, nil, "InvalidOriginalMagicElement"
    end

    local multiplier, reason =
        Formula.elemental_vulnerability(
            element,
            defender.SourceStatCandidate
        )
    if multiplier == nil then
        return nil, nil, reason
    end

    return multiplier, element, nil
end

--[[
Consumes the private one-use magical shot state.

Args:
    user_id (number): Authenticated source-ready caster.

Returns:
    (any?, string?): Validated magical shot state or strict authority reason.
]]
local function consume_magic_shot(
    user_id: number
): (any?, string?)
    if not shot_authority
        or type(shot_authority.consume_magic) ~= "function"
    then
        return nil, "C4SourceShotAuthorityUnavailable"
    end

    local state = shot_authority:consume_magic(user_id)
    if type(state) ~= "table"
        or type(state.Spiritshot) ~= "boolean"
        or type(state.BlessedSpiritshot) ~= "boolean"
        or (state.Spiritshot and state.BlessedSpiritshot)
    then
        return nil, "InvalidSourceMagicShotState"
    end

    return state, nil
end

--[[
Installs the private server shot authority used by source calculations.

The authority owns inventory consumption and charged state. This provider only
consumes already-authorized one-use charges.

Args:
    authority (any?): C4SourceShotService-compatible server authority.

Returns:
    nil: Replaces only the server-local authority reference.
]]
function C4SourceCombatCalculationService.set_shot_authority(
    authority: any?
)
    if authority ~= nil then
        assert(
            type(authority) == "table"
                and type(authority.consume_physical) == "function"
                and type(authority.consume_magic) == "function",
            "C4 source shot authority has an invalid contract"
        )
    end

    shot_authority = authority
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
    defender_target: any,
    spatial_context: any
): (any?, string?)
    if not feature_enabled then
        return nil, "C4SourceCombatCalculationDisabled"
    end

    local attacker, attacker_reason =
        source_boundary(attacker_user_id)
    if not attacker then
        return nil, attacker_reason
    end

    local defender, target_kind, defender_reason =
        source_target_boundary(defender_target)
    if not defender or not target_kind then
        return nil, defender_reason
    end

    local spatial, spatial_reason =
        source_spatial_state(spatial_context)
    if not spatial then
        return nil, spatial_reason
    end

    local accuracy =
        attacker.SourceStatCandidate.ACCURACY_COMBAT
    local evasion =
        defender.SourceStatCandidate.EVASION_RATE
    local roll = COMBAT_RANDOM:NextInteger(0, 999)
    local condition = spatial.HitCondition
    local resolved = Formula.resolve_normal_attack_hit(
        accuracy,
        evasion,
        condition.Multiplier,
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
        SourceConditionMultiplier = condition.Multiplier,
        SourceConditionIntegrated = true,
        SourcePositionRelation = condition.PositionRelation,
        SourcePositionBonusPercent = condition.PositionBonusPercent,
        SourceElevationRelation = condition.ElevationRelation,
        SourceElevationBonusPercent = condition.ElevationBonusPercent,
        SourceDarkBonusPercent = condition.DarkBonusPercent,
        SourceHeightDeltaUnits = condition.HeightDeltaSourceUnits,
        SourceNight = condition.IsNight,
        TargetKind = target_kind,
        SourceNpcId = defender.SourceNpcId,
        SourceNpcRace = defender.SourceNpcRace,
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
    defender_target: any
): (any?, string?)
    if not feature_enabled then
        return nil, "C4SourceCombatCalculationDisabled"
    end

    local attacker, attacker_reason =
        source_boundary(attacker_user_id)
    if not attacker then
        return nil, attacker_reason
    end

    local defender, target_kind, defender_reason =
        source_target_boundary(defender_target)
    if not defender or not target_kind then
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
        TargetKind = target_kind,
        SourceNpcId = defender.SourceNpcId,
        SourceNpcRace = defender.SourceNpcRace,
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
    defender_target: any,
    spatial_context: any
): (any?, string?)
    if not feature_enabled then
        return nil, "C4SourceCombatCalculationDisabled"
    end

    local spatial, spatial_reason =
        source_spatial_state(spatial_context)
    if not spatial then
        return nil, spatial_reason
    end

    local facing_eligible = spatial.ShieldFacing.Eligible

    local attacker, attacker_reason =
        source_boundary(attacker_user_id)
    if not attacker then
        return nil, attacker_reason
    end

    local defender, target_kind, defender_reason =
        source_target_boundary(defender_target)
    if not defender or not target_kind then
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
            TargetKind = target_kind,
            SourceNpcId = defender.SourceNpcId,
            SourceNpcRace = defender.SourceNpcRace,
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
        TargetKind = target_kind,
        SourceNpcId = defender.SourceNpcId,
        SourceNpcRace = defender.SourceNpcRace,
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
Resolves one complete C4 single-target ordinary physical attack.

The source sequence is hit first, then shield, critical and damage. A charged
Soulshot is consumed only after a successful hit, matching the reviewed attack
flow. This calculation represents one target/one strike; attack animation,
arrow inventory and pole/dual scheduling remain outside this provider.

Args:
    attacker_user_id (number): Authenticated source-ready attacker.
    defender_user_id (number): Authenticated source-ready defender.
    facing_eligible (boolean?): Server-owned shield-facing result when needed.

Returns:
    (any?, string?): Complete source attack result or strict denial reason.
]]
function C4SourceCombatCalculationService.normal_attack(
    attacker_user_id: number,
    defender_target: any,
    spatial_context: any
): (any?, string?)
    if not feature_enabled then
        return nil, "C4SourceCombatCalculationDisabled"
    end

    local attacker, attacker_reason =
        source_boundary(attacker_user_id)
    if not attacker then
        return nil, attacker_reason
    end

    local defender, target_kind, defender_reason =
        source_target_boundary(defender_target)
    if not defender or not target_kind then
        return nil, defender_reason
    end

    local spatial, spatial_reason =
        source_spatial_state(spatial_context)
    if not spatial then
        return nil, spatial_reason
    end

    local condition = spatial.HitCondition
    local hit = Formula.resolve_normal_attack_hit(
        attacker.SourceStatCandidate.ACCURACY_COMBAT,
        defender.SourceStatCandidate.EVASION_RATE,
        condition.Multiplier,
        COMBAT_RANDOM:NextInteger(0, 999)
    )

    if hit.Miss then
        return {
            Kind = "NormalAttack",
            Hit = false,
            Miss = true,
            Amount = 0,
            HitChancePerThousand = hit.ChancePerThousand,
            HitRoll = hit.Roll,
            Soulshot = false,
            SoulshotConsumed = false,
            SourceConditionMultiplier = condition.Multiplier,
            SourceConditionIntegrated = true,
            SourcePositionRelation = condition.PositionRelation,
            SourceElevationRelation = condition.ElevationRelation,
            SourceNight = condition.IsNight,
            TargetKind = target_kind,
            SourceNpcId = defender.SourceNpcId,
            SourceNpcRace = defender.SourceNpcRace,
            SourceOnly = true,
            LiveApplied = false,
        }, nil
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
        FacingEligible = spatial.ShieldFacing.Eligible,
    }

    if shield_equipped then
        local shield_result, shield_reason =
            C4SourceCombatCalculationService.shield_resolution(
                attacker_user_id,
                defender_target,
                spatial_context
            )
        if not shield_result then
            return nil, shield_reason
        end
        shield = shield_result
    end

    local multiplier, additive, power_reason =
        critical_power_inputs(attacker)
    if multiplier == nil or additive == nil then
        return nil, power_reason
    end

    local critical = Formula.resolve_physical_critical(
        attacker.SourceStatCandidate.CRITICAL_RATE,
        COMBAT_RANDOM:NextInteger(0, 999)
    )

    local variance, variance_reason =
        source_random_variance(attacker)
    if not variance then
        return nil, variance_reason
    end

    local vulnerability, vulnerability_reason =
        source_weapon_vulnerability(attacker, defender)
    if not vulnerability then
        return nil, vulnerability_reason
    end

    local race, race_reason = source_npc_race_multiplier(
        attacker,
        defender,
        target_kind
    )
    if not race then
        return nil, race_reason
    end

    local pvp_multiplier, pvp_reason =
        source_target_pvp_multiplier(
            attacker,
            target_kind,
            "PVP_PHYSICAL_DMG"
        )
    if pvp_multiplier == nil then
        return nil, pvp_reason
    end

    local shot, shot_reason =
        consume_physical_shot(attacker_user_id)
    if not shot then
        return nil, shot_reason
    end

    local amount = Formula.physical_damage({
        PAtk = attacker.SourceStatCandidate.PHYSICAL_ATTACK,
        PDef = defender.SourceStatCandidate.PHYSICAL_DEFENCE,
        Soulshot = shot.Soulshot,
        Shield = shield.Blocked,
        PerfectShield = shield.PerfectShield,
        ShieldDefense = shield.ShieldDefencePower,
        Critical = critical.Critical,
        CriticalPowerMultiplier = multiplier,
        CriticalPowerAdd = additive,
        WeaponVulnerabilityMultiplier = vulnerability.Multiplier,
        RandomDamageMultiplier = variance.Multiplier,
        RaceMultiplier = race.Multiplier,
        PvpMultiplier = pvp_multiplier,
    })

    return {
        Kind = "NormalAttack",
        Hit = true,
        Miss = false,
        Amount = amount,
        HitChancePerThousand = hit.ChancePerThousand,
        HitRoll = hit.Roll,
        Critical = critical.Critical,
        CriticalChancePerThousand = critical.ChancePerThousand,
        CriticalRoll = critical.Roll,
        CriticalPowerMultiplier = multiplier,
        CriticalPowerAdd = additive,
        Soulshot = shot.Soulshot,
        SoulshotConsumed = shot.Soulshot,
        RandomDamage = variance.RandomDamage,
        RandomDamageRoll = variance.Roll,
        RandomDamageMultiplier = variance.Multiplier,
        SourceWeaponId = vulnerability.SourceWeaponId,
        WeaponKind = vulnerability.WeaponKind,
        WeaponVulnerabilityStat = vulnerability.VulnerabilityStat,
        WeaponVulnerabilityMultiplier = vulnerability.Multiplier,
        NpcRaceMultiplier = race.Multiplier,
        NpcRaceStats = race.AppliedStats,
        PvpStat = "PVP_PHYSICAL_DMG",
        PvpMultiplier = pvp_multiplier,
        PvpApplied = target_kind == "Player",
        TargetKind = target_kind,
        SourceNpcId = defender.SourceNpcId,
        SourceNpcRace = defender.SourceNpcRace,
        ShieldEquipped = shield.ShieldEquipped,
        ShieldBlocked = shield.Blocked,
        PerfectShield = shield.PerfectShield,
        ShieldDefencePower = shield.ShieldDefencePower,
        ShieldFacingEligible = shield.FacingEligible,
        ShieldBlockRoll = shield.BlockRoll,
        ShieldPerfectRoll = shield.PerfectRoll,
        SourceConditionMultiplier = condition.Multiplier,
        SourceConditionIntegrated = true,
        SourcePositionRelation = condition.PositionRelation,
        SourcePositionBonusPercent = condition.PositionBonusPercent,
        SourceElevationRelation = condition.ElevationRelation,
        SourceElevationBonusPercent = condition.ElevationBonusPercent,
        SourceDarkBonusPercent = condition.DarkBonusPercent,
        SourceHeightDeltaUnits = condition.HeightDeltaSourceUnits,
        SourceNight = condition.IsNight,
        SourceOnly = true,
        LiveApplied = false,
    }, nil
end

--[[
Calculates C4 PDAM skill damage between source-ready players.

Weapon/unarmed variance, source weapon vulnerability, shots, authored PDAM
critical rate and the player PvP physical-skill multiplier are
server-authoritative. NPC race-specific modifiers remain outside this
player-only provider.

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
    defender_target: any,
    creative_skill_id: string,
    creative_rank: number,
    spatial_context: any?
): (any?, string?)
    if not feature_enabled then
        return nil, "C4SourceCombatCalculationDisabled"
    end

    local attacker, attacker_reason =
        source_boundary(attacker_user_id)
    if not attacker then
        return nil, attacker_reason
    end

    local defender, target_kind, defender_reason =
        source_target_boundary(defender_target)
    if not defender or not target_kind then
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

    local base_critical_rate =
        tonumber(effect.Sets.baseCritRate) or 0
    if base_critical_rate < 0
        or base_critical_rate >= math.huge
    then
        return nil, "OriginalPhysicalSkillCriticalRateInvalid"
    end

    local skill_critical = {
        Critical = false,
        ChancePerThousand = 0,
        Roll = nil,
    }

    if base_critical_rate > 0 then
        local str_bonus = attacker.SourceStrBonus
        if type(str_bonus) ~= "number"
            or str_bonus ~= str_bonus
            or str_bonus <= 0
            or str_bonus >= math.huge
        then
            return nil, "OriginalStrBonusUnavailable"
        end

        skill_critical =
            Formula.resolve_physical_skill_critical(
                base_critical_rate,
                str_bonus,
                COMBAT_RANDOM:NextInteger(0, 999)
            )
    end

    local variance, variance_reason =
        source_random_variance(attacker)
    if not variance then
        return nil, variance_reason
    end

    local vulnerability, vulnerability_reason =
        source_weapon_vulnerability(attacker, defender)
    if not vulnerability then
        return nil, vulnerability_reason
    end

    local race, race_reason = source_npc_race_multiplier(
        attacker,
        defender,
        target_kind
    )
    if not race then
        return nil, race_reason
    end

    local pvp_multiplier, pvp_reason =
        source_target_pvp_multiplier(
            attacker,
            target_kind,
            "PVP_PHYS_SKILL_DMG"
        )
    if pvp_multiplier == nil then
        return nil, pvp_reason
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
        FacingEligible = nil,
    }

    if shield_equipped then
        if spatial_context == nil then
            return nil, "SourceSpatialContextRequired"
        end

        local shield_result, shield_reason =
            C4SourceCombatCalculationService.shield_resolution(
                attacker_user_id,
                defender_target,
                spatial_context
            )
        if not shield_result then
            return nil, shield_reason
        end
        shield = shield_result
    end

    local shot, shot_reason =
        consume_physical_shot(attacker_user_id)
    if not shot then
        return nil, shot_reason
    end

    local amount = Formula.physical_damage({
        PAtk = attacker.SourceStatCandidate.PHYSICAL_ATTACK,
        PDef = defender.SourceStatCandidate.PHYSICAL_DEFENCE,
        SkillPower = effect.Sets.power,
        Soulshot = shot.Soulshot,
        Shield = shield.Blocked,
        PerfectShield = shield.PerfectShield,
        ShieldDefense = shield.ShieldDefencePower,
        WeaponVulnerabilityMultiplier = vulnerability.Multiplier,
        RandomDamageMultiplier = variance.Multiplier,
        RaceMultiplier = race.Multiplier,
        PvpMultiplier = pvp_multiplier,
    })

    if skill_critical.Critical then
        amount *= 2
    end

    return {
        Kind = "PhysicalDamage",
        Amount = amount,
        Soulshot = shot.Soulshot,
        RandomDamage = variance.RandomDamage,
        RandomDamageRoll = variance.Roll,
        RandomDamageMultiplier = variance.Multiplier,
        SourceWeaponId = variance.SourceWeaponId,
        Unarmed = variance.Unarmed,
        WeaponKind = vulnerability.WeaponKind,
        WeaponVulnerabilityStat = vulnerability.VulnerabilityStat,
        WeaponVulnerabilityMultiplier = vulnerability.Multiplier,
        NpcRaceMultiplier = race.Multiplier,
        NpcRaceStats = race.AppliedStats,
        PvpStat = "PVP_PHYS_SKILL_DMG",
        PvpMultiplier = pvp_multiplier,
        PvpApplied = target_kind == "Player",
        TargetKind = target_kind,
        SourceNpcId = defender.SourceNpcId,
        SourceNpcRace = defender.SourceNpcRace,
        PhysicalSkillCritical = skill_critical.Critical,
        PhysicalSkillCriticalChancePerThousand =
            skill_critical.ChancePerThousand,
        PhysicalSkillCriticalRoll = skill_critical.Roll,
        SourceSkillBaseCriticalRate = base_critical_rate,
        SourceStrBonus = attacker.SourceStrBonus,
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
Spiritshots, elemental vulnerability and the player PvP magical multiplier
are now source-authoritative for this player-only provider.

Args:
    attacker_user_id (number): Authenticated source-ready caster.
    defender_user_id (number): Authenticated source-ready defender.
    creative_skill_id (string): Server-selected creative magic skill ID.
    creative_rank (number): Server-resolved purchased creative rank.

Returns:
    (any?, string?): Source magical result or strict denial reason.
]]
--[[
Calculates one MDAM target using an already captured magical-shot state.

Keeping shot capture outside this helper lets TARGET_AREA reuse the same
Spiritshot/Blessed Spiritshot state across every target while retaining
target-specific critical, failure, elemental and PvP rolls.

Args:
    attacker (any): Authenticated source attacker boundary.
    defender (any): Reviewed source defender boundary.
    target_kind (string): Player or NPC target kind.
    source (any): Resolved source skill identity.
    effect (any): Resolved source effect rank.
    shot (any): One captured magical-shot state.

Returns:
    (any?, string?): Per-target source magic result or denial reason.
]]
local function calculate_magic_target(
    attacker: any,
    defender: any,
    target_kind: string,
    source: any,
    effect: any,
    shot: any
): (any?, string?)
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

    local elemental_multiplier, element, elemental_reason =
        source_magic_element(effect, defender)
    if elemental_multiplier == nil then
        return nil, elemental_reason
    end

    local pvp_multiplier, pvp_reason =
        source_target_pvp_multiplier(
            attacker,
            target_kind,
            "PVP_MAGICAL_DMG"
        )
    if pvp_multiplier == nil then
        return nil, pvp_reason
    end

    local amount = Formula.magic_damage({
        MAtk = attacker.SourceStatCandidate.MAGICAL_ATTACK,
        MDef = defender.SourceStatCandidate.MAGICAL_DEFENCE,
        SkillPower = effect.Sets.power,
        Spiritshot = shot.Spiritshot,
        BlessedSpiritshot = shot.BlessedSpiritshot,
        Failure = failure.Failure,
        MagicCritical = critical.Critical,
        ElementalMultiplier = elemental_multiplier,
        PvpMultiplier = pvp_multiplier,
    })

    return {
        Kind = "MagicDamage",
        Amount = amount,
        Spiritshot = shot.Spiritshot,
        BlessedSpiritshot = shot.BlessedSpiritshot,
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
        SourceElemental = element ~= nil,
        ElementalMultiplier = elemental_multiplier,
        PvpStat = "PVP_MAGICAL_DMG",
        PvpMultiplier = pvp_multiplier,
        PvpApplied = target_kind == "Player",
        TargetKind = target_kind,
        SourceNpcId = defender.SourceNpcId,
        SourceNpcRace = defender.SourceNpcRace,
        SourceSkillId = source.SkillId,
        SourceRank = source.Rank,
        SourceSkillPower = effect.Sets.power,
        SourceOnly = true,
        LiveApplied = false,
    }, nil
end

--[[
Calculates C4 MDAM skill damage against one reviewed source target.

The one-use magical shot is consumed once before target-specific critical,
failure, elemental and PvP calculations are resolved.

Args:
    attacker_user_id (number): Authenticated source-ready caster.
    defender_target (any): Player UserId or reviewed server NPC boundary.
    creative_skill_id (string): Server-selected creative magic skill ID.
    creative_rank (number): Server-resolved purchased creative rank.

Returns:
    (any?, string?): Source magical result or strict denial reason.
]]
function C4SourceCombatCalculationService.magic_skill(
    attacker_user_id: number,
    defender_target: any,
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

    local defender, target_kind, defender_reason =
        source_target_boundary(defender_target)
    if not defender or not target_kind then
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

    local shot, shot_reason =
        consume_magic_shot(attacker_user_id)
    if not shot then
        return nil, shot_reason
    end

    return calculate_magic_target(
        attacker,
        defender,
        target_kind,
        source,
        effect,
        shot
    )
end

--[[
Calculates one C4 TARGET_AREA MDAM cast against reviewed source targets.

The source SkillMdam handler snapshots Spiritshot/Blessed Spiritshot once,
uses that same shot state for every target, then consumes the charge once after
the target loop. This method preserves that one-charge multi-target behavior.

Args:
    attacker_user_id (number): Authenticated source-ready caster.
    defender_targets ({any}): Ordered reviewed source target boundaries.
    creative_skill_id (string): Server-selected creative area skill.
    creative_rank (number): Server-resolved purchased creative rank.

Returns:
    (any?, string?): Ordered per-target source results and area metadata.
]]
function C4SourceCombatCalculationService.magic_area_skill(
    attacker_user_id: number,
    defender_targets: {any},
    creative_skill_id: string,
    creative_rank: number
): (any?, string?)
    if not feature_enabled then
        return nil, "C4SourceCombatCalculationDisabled"
    end
    if type(defender_targets) ~= "table"
        or #defender_targets < 1
    then
        return nil, "OriginalMagicAreaTargetsUnavailable"
    end

    local attacker, attacker_reason =
        source_boundary(attacker_user_id)
    if not attacker then
        return nil, attacker_reason
    end

    local source, effect, source_reason = source_skill(
        attacker_user_id,
        creative_skill_id,
        creative_rank
    )
    if not source or not effect then
        return nil, source_reason
    end

    local sets = effect.Sets
    if sets.skillType ~= "MDAM"
        or sets.target ~= "TARGET_AREA"
        or type(sets.power) ~= "number"
        or type(sets.skillRadius) ~= "number"
        or sets.skillRadius <= 0
    then
        return nil, "UnsupportedOriginalMagicAreaSkill"
    end

    local resolved_targets = {}
    for index, defender_target in ipairs(defender_targets) do
        local defender, target_kind, defender_reason =
            source_target_boundary(defender_target)
        if not defender or not target_kind then
            return nil, defender_reason
        end
        resolved_targets[index] = {
            Defender = defender,
            TargetKind = target_kind,
        }
    end

    local shot, shot_reason =
        consume_magic_shot(attacker_user_id)
    if not shot then
        return nil, shot_reason
    end

    local results = {}
    for index, resolved in ipairs(resolved_targets) do
        local result, result_reason = calculate_magic_target(
            attacker,
            resolved.Defender,
            resolved.TargetKind,
            source,
            effect,
            shot
        )
        if not result then
            return nil, result_reason
        end

        results[index] = result
    end

    return {
        Kind = "MagicAreaDamage",
        Results = results,
        TargetCount = #results,
        SourceSkillId = source.SkillId,
        SourceRank = source.Rank,
        SourceSkillRadius = sets.skillRadius,
        Spiritshot = shot.Spiritshot,
        BlessedSpiritshot = shot.BlessedSpiritshot,
        SourceOnly = true,
        LiveApplied = false,
    }, nil
end

--[[
Calculates one reviewed C4 DRAIN skill against a source target.

The pinned C4 drain handler uses the normal magic-damage formula, then heals
the caster by absorbAbs plus absorbPart times drainable target HP damage. For
NPC targets without CP, the drainable amount is the lesser of calculated
damage and current target HP. The live executor applies that cap from actual
server-owned HP mutation.

Args:
    attacker_user_id (number): Authenticated source-ready caster.
    defender_target (any): Player UserId or reviewed server NPC boundary.
    creative_skill_id (string): Server-selected creative drain skill.
    creative_rank (number): Server-resolved purchased creative rank.

Returns:
    (any?, string?): Source drain damage and absorption contract.
]]
function C4SourceCombatCalculationService.drain_skill(
    attacker_user_id: number,
    defender_target: any,
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

    local defender, target_kind, defender_reason =
        source_target_boundary(defender_target)
    if not defender or not target_kind then
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

    local sets = effect.Sets
    if sets.skillType ~= "DRAIN"
        or type(sets.power) ~= "number"
        or sets.target ~= "TARGET_ONE"
    then
        return nil, "UnsupportedOriginalDrainSkillType"
    end

    local absorb_part = sets.absorbPart
    local absorb_abs = sets.absorbAbs or 0
    if type(absorb_part) ~= "number"
        or absorb_part < 0
        or absorb_part >= math.huge
        or type(absorb_abs) ~= "number"
        or absorb_abs < 0
        or absorb_abs >= math.huge
    then
        return nil, "InvalidOriginalDrainAbsorption"
    end

    local shot, shot_reason =
        consume_magic_shot(attacker_user_id)
    if not shot then
        return nil, shot_reason
    end

    local damage, damage_reason = calculate_magic_target(
        attacker,
        defender,
        target_kind,
        source,
        effect,
        shot
    )
    if not damage then
        return nil, damage_reason
    end

    return {
        Kind = "MagicDrain",
        Amount = damage.Amount,
        Damage = damage,
        AbsorbPart = absorb_part,
        AbsorbAbs = absorb_abs,
        Spiritshot = shot.Spiritshot,
        BlessedSpiritshot = shot.BlessedSpiritshot,
        SourceSkillId = source.SkillId,
        SourceRank = source.Rank,
        TargetKind = target_kind,
        SourceNpcId = defender.SourceNpcId,
        SourceOnly = true,
        LiveApplied = false,
    }, nil
end

--[[
Calculates one reviewed direct magic hit with a C4 movement-slow side effect.

The direct MDAM calculation owns the single Spiritshot consumption. The same
captured shot state is then reused by the source hostile-effect formula so a
combined spell can never consume a second shot for its slow roll.

Args:
    attacker_user_id (number): Authenticated source-ready caster.
    defender_target (any): Player UserId or reviewed server NPC boundary.
    creative_skill_id (string): Server-selected creative slow spell.
    creative_rank (number): Server-resolved purchased creative rank.

Returns:
    (any?, string?): Combined source damage/slow result or denial reason.
]]
function C4SourceCombatCalculationService.magic_slow_skill(
    attacker_user_id: number,
    defender_target: any,
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

    local defender, target_kind, defender_reason =
        source_target_boundary(defender_target)
    if not defender or not target_kind then
        return nil, defender_reason
    end

    local source, _, source_reason = source_skill(
        attacker_user_id,
        creative_skill_id,
        creative_rank
    )
    if not source then
        return nil, source_reason
    end

    local plan, plan_reason = StatusEffects.movement_slow_plan(
        source.SkillId,
        source.Rank
    )
    if not plan then
        return nil, plan_reason
    end

    local target_wit_bonus = defender.SourceWitBonus
    if type(target_wit_bonus) ~= "number"
        or target_wit_bonus <= 0
    then
        return nil, "OriginalMovementSlowWitBonusUnavailable"
    end

    local damage, damage_reason =
        C4SourceCombatCalculationService.magic_skill(
            attacker_user_id,
            defender_target,
            creative_skill_id,
            creative_rank
        )
    if not damage then
        return nil, damage_reason
    end

    local roll = COMBAT_RANDOM:NextInteger(0, 99)
    local slow, slow_reason =
        StatusEffects.resolve_effect_success({
            Power = plan.EffectPower,
            TargetStatBonus = target_wit_bonus,
            TargetVulnerability = 1,
            IsMagic = plan.IsMagic,
            AttackerMAtk =
                attacker.SourceStatCandidate.MAGICAL_ATTACK,
            TargetMDef =
                defender.SourceStatCandidate.MAGICAL_DEFENCE,
            Spiritshot = damage.Spiritshot,
            BlessedSpiritshot = damage.BlessedSpiritshot,
            AttackerLevel = attacker.Level,
            TargetLevel = defender.Level,
            MagicLevel = plan.MagicLevel,
        }, roll)
    if not slow then
        return nil, slow_reason
    end

    return {
        Kind = "MagicDamageMovementSlow",
        Amount = damage.Amount,
        Damage = damage,
        SlowLanded = slow.Landed,
        SlowRate = slow.Rate,
        SlowRoll = slow.Roll,
        SpeedMultiplier = plan.SpeedMultiplier,
        SlowFraction = plan.SlowFraction,
        DurationSeconds = plan.DurationSeconds,
        SaveVs = plan.SaveVs,
        EffectPower = plan.EffectPower,
        Spiritshot = damage.Spiritshot,
        BlessedSpiritshot = damage.BlessedSpiritshot,
        SourceSkillId = source.SkillId,
        SourceRank = source.Rank,
        TargetKind = target_kind,
        SourceNpcId = defender.SourceNpcId,
        SourceOnly = true,
        LiveApplied = false,
    }, nil
end

--[[
Resolves one reviewed C4 Sleep cast against a source target.

The source SkillDebuff path snapshots and consumes one magical shot for the
cast, then uses that shot state in the exact hostile-effect success formula.

Args:
    attacker_user_id (number): Authenticated source-ready caster.
    defender_target (any): Player UserId or reviewed server NPC boundary.
    creative_skill_id (string): Server-selected creative Sleep skill.
    creative_rank (number): Server-resolved purchased creative rank.

Returns:
    (any?, string?): Source Sleep land result or strict denial reason.
]]
function C4SourceCombatCalculationService.sleep_skill(
    attacker_user_id: number,
    defender_target: any,
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

    local defender, target_kind, defender_reason =
        source_target_boundary(defender_target)
    if not defender or not target_kind then
        return nil, defender_reason
    end

    local source, _, source_reason = source_skill(
        attacker_user_id,
        creative_skill_id,
        creative_rank
    )
    if not source then
        return nil, source_reason
    end

    local plan, plan_reason = StatusEffects.sleep_plan(
        source.SkillId,
        source.Rank
    )
    if not plan then
        return nil, plan_reason
    end

    local target_wit_bonus = defender.SourceWitBonus
    if type(target_wit_bonus) ~= "number"
        or target_wit_bonus <= 0
    then
        return nil, "OriginalSleepWitBonusUnavailable"
    end

    local shot, shot_reason =
        consume_magic_shot(attacker_user_id)
    if not shot then
        return nil, shot_reason
    end

    local roll = COMBAT_RANDOM:NextInteger(0, 99)
    local resolved, resolve_reason =
        StatusEffects.resolve_effect_success({
            Power = plan.EffectPower,
            TargetStatBonus = target_wit_bonus,
            TargetVulnerability = 1,
            IsMagic = plan.IsMagic,
            AttackerMAtk =
                attacker.SourceStatCandidate.MAGICAL_ATTACK,
            TargetMDef =
                defender.SourceStatCandidate.MAGICAL_DEFENCE,
            Spiritshot = shot.Spiritshot,
            BlessedSpiritshot = shot.BlessedSpiritshot,
            AttackerLevel = attacker.Level,
            TargetLevel = defender.Level,
            MagicLevel = plan.MagicLevel,
        }, roll)
    if not resolved then
        return nil, resolve_reason
    end

    return {
        Kind = "SleepControl",
        Landed = resolved.Landed,
        Rate = resolved.Rate,
        Roll = resolved.Roll,
        DurationSeconds = plan.DurationSeconds,
        BreaksOnDamage = plan.BreaksOnDamage,
        StopsMovement = plan.StopsMovement,
        StopsAttacks = plan.StopsAttacks,
        StopsCasting = plan.StopsCasting,
        SaveVs = plan.SaveVs,
        EffectPower = plan.EffectPower,
        Spiritshot = shot.Spiritshot,
        BlessedSpiritshot = shot.BlessedSpiritshot,
        SourceSkillId = source.SkillId,
        SourceRank = source.Rank,
        TargetKind = target_kind,
        SourceNpcId = defender.SourceNpcId,
        SourceOnly = true,
        LiveApplied = false,
    }, nil
end

--[[
Resolves one reviewed C4 elemental-vulnerability debuff cast.

The cast snapshots and consumes one magical shot, then uses that shot state in
the exact hostile-effect success formula. A landed result carries only the
source vulnerability metadata; the live executor owns runtime NPC mutation.

Args:
    attacker_user_id (number): Authenticated source-ready caster.
    defender_target (any): Player UserId or reviewed server NPC boundary.
    creative_skill_id (string): Server-selected creative debuff.
    creative_rank (number): Server-resolved purchased creative rank.

Returns:
    (any?, string?): Source vulnerability land result or strict denial reason.
]]
function C4SourceCombatCalculationService.elemental_vulnerability_skill(
    attacker_user_id: number,
    defender_target: any,
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

    local defender, target_kind, defender_reason =
        source_target_boundary(defender_target)
    if not defender or not target_kind then
        return nil, defender_reason
    end

    local source, _, source_reason = source_skill(
        attacker_user_id,
        creative_skill_id,
        creative_rank
    )
    if not source then
        return nil, source_reason
    end

    local plan, plan_reason =
        StatusEffects.elemental_vulnerability_plan(
            source.SkillId,
            source.Rank
        )
    if not plan then
        return nil, plan_reason
    end

    local target_wit_bonus = defender.SourceWitBonus
    if type(target_wit_bonus) ~= "number"
        or target_wit_bonus <= 0
    then
        return nil, "OriginalElementalVulnerabilityWitBonusUnavailable"
    end

    local shot, shot_reason =
        consume_magic_shot(attacker_user_id)
    if not shot then
        return nil, shot_reason
    end

    local roll = COMBAT_RANDOM:NextInteger(0, 99)
    local resolved, resolve_reason =
        StatusEffects.resolve_effect_success({
            Power = plan.EffectPower,
            TargetStatBonus = target_wit_bonus,
            TargetVulnerability = 1,
            IsMagic = plan.IsMagic,
            AttackerMAtk =
                attacker.SourceStatCandidate.MAGICAL_ATTACK,
            TargetMDef =
                defender.SourceStatCandidate.MAGICAL_DEFENCE,
            Spiritshot = shot.Spiritshot,
            BlessedSpiritshot = shot.BlessedSpiritshot,
            AttackerLevel = attacker.Level,
            TargetLevel = defender.Level,
            MagicLevel = plan.MagicLevel,
        }, roll)
    if not resolved then
        return nil, resolve_reason
    end

    return {
        Kind = "ElementalVulnerability",
        Landed = resolved.Landed,
        Rate = resolved.Rate,
        Roll = resolved.Roll,
        VulnerabilityStat = plan.VulnerabilityStat,
        VulnerabilityMultiplier =
            plan.VulnerabilityMultiplier,
        DurationSeconds = plan.DurationSeconds,
        StackType = plan.StackType,
        StackOrder = plan.StackOrder,
        SaveVs = plan.SaveVs,
        EffectPower = plan.EffectPower,
        MagicLevel = plan.MagicLevel,
        Spiritshot = shot.Spiritshot,
        BlessedSpiritshot = shot.BlessedSpiritshot,
        SourceSkillId = source.SkillId,
        SourceRank = source.Rank,
        TargetKind = target_kind,
        SourceNpcId = defender.SourceNpcId,
        SourceOnly = true,
        LiveApplied = false,
    }, nil
end

--[[
Resolves one reviewed C4 physical-attack weakening debuff cast.

The cast consumes one magical shot and uses the exact hostile-effect success
formula. A landed result carries the source attack multiplier only; the live
executor owns NPC runtime mutation.

Args:
    attacker_user_id (number): Authenticated source-ready caster.
    defender_target (any): Player UserId or reviewed server NPC boundary.
    creative_skill_id (string): Server-selected creative weakening debuff.
    creative_rank (number): Server-resolved purchased creative rank.

Returns:
    (any?, string?): Source weakening result or strict denial reason.
]]
function C4SourceCombatCalculationService.physical_attack_weakening_skill(
    attacker_user_id: number,
    defender_target: any,
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

    local defender, target_kind, defender_reason =
        source_target_boundary(defender_target)
    if not defender or not target_kind then
        return nil, defender_reason
    end

    local source, _, source_reason = source_skill(
        attacker_user_id,
        creative_skill_id,
        creative_rank
    )
    if not source then
        return nil, source_reason
    end

    local plan, plan_reason =
        StatusEffects.physical_attack_weakening_plan(
            source.SkillId,
            source.Rank
        )
    if not plan then
        return nil, plan_reason
    end

    local target_wit_bonus = defender.SourceWitBonus
    if type(target_wit_bonus) ~= "number"
        or target_wit_bonus <= 0
    then
        return nil, "OriginalPhysicalAttackWeakeningWitBonusUnavailable"
    end

    local shot, shot_reason =
        consume_magic_shot(attacker_user_id)
    if not shot then
        return nil, shot_reason
    end

    local roll = COMBAT_RANDOM:NextInteger(0, 99)
    local resolved, resolve_reason =
        StatusEffects.resolve_effect_success({
            Power = plan.EffectPower,
            TargetStatBonus = target_wit_bonus,
            TargetVulnerability = 1,
            IsMagic = plan.IsMagic,
            AttackerMAtk =
                attacker.SourceStatCandidate.MAGICAL_ATTACK,
            TargetMDef =
                defender.SourceStatCandidate.MAGICAL_DEFENCE,
            Spiritshot = shot.Spiritshot,
            BlessedSpiritshot = shot.BlessedSpiritshot,
            AttackerLevel = attacker.Level,
            TargetLevel = defender.Level,
            MagicLevel = plan.MagicLevel,
        }, roll)
    if not resolved then
        return nil, resolve_reason
    end

    return {
        Kind = "PhysicalAttackWeakening",
        Landed = resolved.Landed,
        Rate = resolved.Rate,
        Roll = resolved.Roll,
        PhysicalAttackMultiplier =
            plan.PhysicalAttackMultiplier,
        PowerReductionFraction =
            plan.PowerReductionFraction,
        DurationSeconds = plan.DurationSeconds,
        StackType = plan.StackType,
        StackOrder = plan.StackOrder,
        SaveVs = plan.SaveVs,
        EffectType = plan.EffectType,
        EffectPower = plan.EffectPower,
        MagicLevel = plan.MagicLevel,
        Spiritshot = shot.Spiritshot,
        BlessedSpiritshot = shot.BlessedSpiritshot,
        SourceSkillId = source.SkillId,
        SourceRank = source.Rank,
        TargetKind = target_kind,
        SourceNpcId = defender.SourceNpcId,
        SourceOnly = true,
        LiveApplied = false,
    }, nil
end

--[[
Resolves one periodic-status target using an already-owned shot snapshot.

Args:
    attacker (any): Authenticated source-ready caster boundary.
    defender (any): Reviewed source target boundary.
    target_kind (string): Reviewed source target family.
    source (any): Authenticated creative-to-source mapping.
    plan (any): Exact periodic-status source plan.
    shot (any): Single cast-owned magical shot snapshot.

Returns:
    (any?, string?): Per-target periodic source result or denial reason.
]]
local function resolve_periodic_target(
    attacker: any,
    defender: any,
    target_kind: string,
    source: any,
    plan: any,
    shot: any
): (any?, string?)
    local target_stat_bonus = if plan.SaveVs == "CON"
        then defender.SourceConBonus
        elseif plan.SaveVs == "MEN"
        then defender.SourceMenBonus
        else nil
    if type(target_stat_bonus) ~= "number"
        or target_stat_bonus <= 0
    then
        return nil, "OriginalPeriodicStatusSaveBonusUnavailable"
    end

    local vulnerability =
        defender.SourceStatCandidate[plan.VulnerabilityStat]
    if type(vulnerability) ~= "number"
        or vulnerability < 0
    then
        return nil, "OriginalPeriodicStatusVulnerabilityUnavailable"
    end

    local roll = COMBAT_RANDOM:NextInteger(0, 99)
    local resolved, reason =
        StatusEffects.resolve_effect_success({
            Power = plan.EffectPower,
            TargetStatBonus = target_stat_bonus,
            TargetVulnerability = vulnerability,
            IsMagic = plan.IsMagic,
            AttackerMAtk =
                attacker.SourceStatCandidate.MAGICAL_ATTACK,
            TargetMDef =
                defender.SourceStatCandidate.MAGICAL_DEFENCE,
            Spiritshot = shot.Spiritshot,
            BlessedSpiritshot = shot.BlessedSpiritshot,
            AttackerLevel = attacker.Level,
            TargetLevel = defender.Level,
            MagicLevel = plan.MagicLevel,
        }, roll)
    if not resolved then
        return nil, reason
    end

    return {
        Kind = "PeriodicStatus",
        Landed = resolved.Landed,
        Rate = resolved.Rate,
        Roll = resolved.Roll,
        EffectType = plan.EffectType,
        SaveVs = plan.SaveVs,
        VulnerabilityStat = plan.VulnerabilityStat,
        TickDamage = plan.TickDamage,
        TickCount = plan.TickCount,
        TickSeconds = plan.TickSeconds,
        Nonlethal = plan.Nonlethal,
        Spiritshot = shot.Spiritshot,
        BlessedSpiritshot = shot.BlessedSpiritshot,
        SourceSkillId = source.SkillId,
        SourceRank = source.Rank,
        TargetKind = target_kind,
        SourceNpcId = defender.SourceNpcId,
        SourceOnly = true,
        LiveApplied = false,
    }, nil
end

--[[
Resolves one reviewed C4 hostile periodic-status cast.

This path handles DEBUFF application only. It does not apply or schedule ticks.
The live executor owns periodic world mutation after a successful source roll.

Args:
    attacker_user_id (number): Authenticated source-ready caster.
    defender_target (any): Player UserId or reviewed server NPC boundary.
    creative_skill_id (string): Server-selected creative status skill.
    creative_rank (number): Server-resolved purchased creative rank.

Returns:
    (any?, string?): Source DEBUFF result and periodic plan or denial reason.
]]
function C4SourceCombatCalculationService.status_skill(
    attacker_user_id: number,
    defender_target: any,
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

    local defender, target_kind, defender_reason =
        source_target_boundary(defender_target)
    if not defender or not target_kind then
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

    local plan, plan_reason = StatusEffects.periodic_plan(
        source.SkillId,
        source.Rank
    )
    if not plan then
        return nil, plan_reason
    end

    local target_stat_bonus
    if plan.SaveVs == "CON" then
        target_stat_bonus = defender.SourceConBonus
    elseif plan.SaveVs == "MEN" then
        target_stat_bonus = defender.SourceMenBonus
    else
        return nil, "UnsupportedOriginalPeriodicStatusSaveStat"
    end

    if type(target_stat_bonus) ~= "number"
        or target_stat_bonus <= 0
    then
        return nil, "OriginalPeriodicStatusSaveBonusUnavailable"
    end

    local vulnerability =
        defender.SourceStatCandidate[plan.VulnerabilityStat]
    if type(vulnerability) ~= "number"
        or vulnerability < 0
    then
        return nil, "OriginalPeriodicStatusVulnerabilityUnavailable"
    end

    local shot = {
        Spiritshot = false,
        BlessedSpiritshot = false,
    }
    if plan.IsMagic then
        local consumed, shot_reason =
            consume_magic_shot(attacker_user_id)
        if not consumed then
            return nil, shot_reason
        end
        shot = consumed
    end

    local roll = COMBAT_RANDOM:NextInteger(0, 99)
    local resolved, resolve_reason =
        StatusEffects.resolve_effect_success({
            Power = plan.EffectPower,
            TargetStatBonus = target_stat_bonus,
            TargetVulnerability = vulnerability,
            IsMagic = plan.IsMagic,
            AttackerMAtk =
                attacker.SourceStatCandidate.MAGICAL_ATTACK,
            TargetMDef =
                defender.SourceStatCandidate.MAGICAL_DEFENCE,
            Spiritshot = shot.Spiritshot,
            BlessedSpiritshot = shot.BlessedSpiritshot,
            AttackerLevel = attacker.Level,
            TargetLevel = defender.Level,
            MagicLevel = plan.MagicLevel,
        }, roll)
    if not resolved then
        return nil, resolve_reason
    end

    return {
        Kind = "PeriodicStatus",
        Landed = resolved.Landed,
        Rate = resolved.Rate,
        Roll = resolved.Roll,
        EffectType = plan.EffectType,
        SaveVs = plan.SaveVs,
        VulnerabilityStat = plan.VulnerabilityStat,
        TickDamage = plan.TickDamage,
        TickCount = plan.TickCount,
        TickSeconds = plan.TickSeconds,
        Nonlethal = plan.Nonlethal,
        Spiritshot = shot.Spiritshot,
        BlessedSpiritshot = shot.BlessedSpiritshot,
        SourceSkillId = source.SkillId,
        SourceRank = source.Rank,
        TargetKind = target_kind,
        SourceNpcId = defender.SourceNpcId,
        SourceOnly = true,
        LiveApplied = false,
    }, nil
end

--[[
Resolves one C4 TARGET_AREA periodic debuff against reviewed source targets.

One magical-shot snapshot is shared across every target, matching the source
SkillDebuff target loop. Each target receives an independent hostile-effect
roll while the charge is consumed once for the cast.

Args:
    attacker_user_id (number): Authenticated source-ready caster.
    defender_targets ({any}): Ordered reviewed source target boundaries.
    creative_skill_id (string): Server-selected creative area status skill.
    creative_rank (number): Server-resolved purchased creative rank.

Returns:
    (any?, string?): Ordered periodic results and source-area metadata.
]]
function C4SourceCombatCalculationService.status_area_skill(
    attacker_user_id: number,
    defender_targets: {any},
    creative_skill_id: string,
    creative_rank: number
): (any?, string?)
    if not feature_enabled then
        return nil, "C4SourceCombatCalculationDisabled"
    end
    if type(defender_targets) ~= "table"
        or #defender_targets < 1
    then
        return nil, "OriginalPeriodicAreaTargetsUnavailable"
    end

    local attacker, attacker_reason =
        source_boundary(attacker_user_id)
    if not attacker then
        return nil, attacker_reason
    end

    local source, effect, source_reason = source_skill(
        attacker_user_id,
        creative_skill_id,
        creative_rank
    )
    if not source or not effect then
        return nil, source_reason
    end

    local sets = effect.Sets
    if sets.skillType ~= "DEBUFF"
        or sets.target ~= "TARGET_AREA"
        or type(sets.skillRadius) ~= "number"
        or sets.skillRadius <= 0
    then
        return nil, "UnsupportedOriginalPeriodicAreaSkill"
    end

    local plan, plan_reason = StatusEffects.periodic_plan(
        source.SkillId,
        source.Rank
    )
    if not plan then
        return nil, plan_reason
    end

    local resolved_targets = {}
    for index, defender_target in ipairs(defender_targets) do
        local defender, target_kind, defender_reason =
            source_target_boundary(defender_target)
        if not defender or not target_kind then
            return nil, defender_reason
        end
        resolved_targets[index] = {
            Defender = defender,
            TargetKind = target_kind,
        }
    end

    local shot = {
        Spiritshot = false,
        BlessedSpiritshot = false,
    }
    if plan.IsMagic then
        local consumed, shot_reason =
            consume_magic_shot(attacker_user_id)
        if not consumed then
            return nil, shot_reason
        end
        shot = consumed
    end

    local results = {}
    for index, target in ipairs(resolved_targets) do
        local result, result_reason = resolve_periodic_target(
            attacker,
            target.Defender,
            target.TargetKind,
            source,
            plan,
            shot
        )
        if not result then
            return nil, result_reason
        end
        results[index] = result
    end

    return {
        Kind = "PeriodicStatusArea",
        Results = results,
        TargetCount = #results,
        SourceSkillId = source.SkillId,
        SourceRank = source.Rank,
        SourceSkillRadius = sets.skillRadius,
        Spiritshot = shot.Spiritshot,
        BlessedSpiritshot = shot.BlessedSpiritshot,
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

    local shot, shot_reason =
        consume_magic_shot(caster_user_id)
    if not shot then
        return nil, shot_reason
    end

    return {
        Kind = "Heal",
        Amount = Formula.heal_amount(
            power,
            shot.Spiritshot,
            shot.BlessedSpiritshot
        ),
        Spiritshot = shot.Spiritshot,
        BlessedSpiritshot = shot.BlessedSpiritshot,
        SourceSkillId = source.SkillId,
        SourceRank = source.Rank,
        SourceHealPower = power,
        SourceOnly = true,
        LiveApplied = false,
    }, nil
end

--[[
Resolves one reviewed C4 self MANAHEAL skill.

Body To Mind restores its source power directly and consumes HP at hit time.
The C4 mana-heal handler also clears one magical shot after execution, even
though the shot does not amplify the restored MP amount.

Args:
    caster_user_id (number): Authenticated source-ready caster.
    creative_skill_id (string): Server-selected creative mana-heal skill.
    creative_rank (number): Server-resolved purchased creative rank.

Returns:
    (any?, string?): Source mana-heal contract or strict denial reason.
]]
function C4SourceCombatCalculationService.mana_heal_skill(
    caster_user_id: number,
    creative_skill_id: string,
    creative_rank: number
): (any?, string?)
    if not feature_enabled then
        return nil, "C4SourceCombatCalculationDisabled"
    end

    local source, effect, source_reason = source_skill(
        caster_user_id,
        creative_skill_id,
        creative_rank
    )
    if not source or not effect then
        return nil, source_reason
    end

    local sets = effect.Sets
    if sets.skillType ~= "MANAHEAL"
        or sets.target ~= "TARGET_SELF"
        or type(sets.power) ~= "number"
        or sets.power < 0
        or type(sets.hpConsume) ~= "number"
        or sets.hpConsume < 0
    then
        return nil, "UnsupportedOriginalManaHealSkill"
    end

    local shot, shot_reason =
        consume_magic_shot(caster_user_id)
    if not shot then
        return nil, shot_reason
    end

    return {
        Kind = "ManaHeal",
        ManaRestore = sets.power,
        HpConsume = sets.hpConsume,
        Spiritshot = shot.Spiritshot,
        BlessedSpiritshot = shot.BlessedSpiritshot,
        SourceSkillId = source.SkillId,
        SourceRank = source.Rank,
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
        NormalAttackHitConditionIntegrated = true,
        SpatialConditionInputServerOwned = true,
        NormalAttackPhysicalCriticalResolution = true,
        NormalAttackPhysicalCriticalRollServerOwned = true,
        NormalAttackCriticalPowerIntegrated = true,
        NormalAttackTargetSpecificCriticalModifiersIntegrated = false,
        NormalAttackDamageComposition = true,
        WeaponVulnerabilityIntegrated = true,
        PhysicalPDAM = true,
        MagicalMDAM = true,
        InstantHeal = true,
        ManaHealCalculation = true,
        ManaHealHpConsumeIntegrated = true,
        PeriodicStatusCalculation = true,
        PeriodicStatusAreaCalculation = true,
        PeriodicStatusAreaSingleShotSnapshot = true,
        MagicMovementSlowCalculation = true,
        MagicAreaDamageCalculation = true,
        MagicAreaSingleShotSnapshot = true,
        MagicDrainCalculation = true,
        MagicDrainSourceAbsorptionIntegrated = true,
        SleepControlCalculation = true,
        SleepControlEffectSuccessIntegrated = true,
        SleepControlConsumesOneMagicShot = true,
        ElementalVulnerabilityCalculation = true,
        ElementalVulnerabilityEffectSuccessIntegrated = true,
        ElementalVulnerabilityConsumesOneMagicShot = true,
        PhysicalAttackWeakeningCalculation = true,
        PhysicalAttackWeakeningEffectSuccessIntegrated = true,
        PhysicalAttackWeakeningConsumesOneMagicShot = true,
        MovementSlowEffectSuccessIntegrated = true,
        MovementSlowUsesSingleMagicShot = true,
        PeriodicStatusEffectSuccessIntegrated = true,
        PeriodicStatusNonlethalSemanticsIntegrated = true,
        ShotsIntegrated = true,
        ShotAuthorityInstalled = shot_authority ~= nil,
        PhysicalSoulshotIntegrated = true,
        MagicSpiritshotIntegrated = true,
        HealSpiritshotIntegrated = true,
        PhysicalRandomVarianceResolution = true,
        RandomWeaponVarianceIntegrated = true,
        UnarmedRandomVarianceIntegrated = true,
        CriticalResolutionIntegrated = true,
        PhysicalSkillCriticalIntegrated = true,
        PhysicalSkillCriticalRollServerOwned = true,
        MagicCriticalIntegrated = true,
        MagicCriticalRollServerOwned = true,
        ShieldSourceResolutionAvailable = true,
        ShieldRollServerOwned = true,
        ShieldPhysicalFormulaIntegrated = true,
        ShieldFacingRuntimeIntegrated = true,
        ShieldResolutionIntegrated = true,
        MagicFailureFormulaAvailable = true,
        MagicFailureResolutionIntegrated = true,
        MagicFailuresSourceDefaultEnabled =
            Formula.magic_failures_default_enabled(),
        ElementalResolutionIntegrated = true,
        NeutralNonElementalMagicIntegrated = true,
        ElementalPlayerTargetSourceStatsIntegrated = true,
        ElementalNpcTargetSourceStatsIntegrated = true,
        NpcTargetSourceBoundaryIntegrated = true,
        PvpFormulaModifiersIntegrated = true,
        PlayerTargetPvpModifiersIntegrated = true,
        NpcTargetPvpNeutralityIntegrated = true,
        NpcRacePhysicalModifiersIntegrated = true,
        LiveDamageApplied = false,
    }
end

return table.freeze(C4SourceCombatCalculationService)
