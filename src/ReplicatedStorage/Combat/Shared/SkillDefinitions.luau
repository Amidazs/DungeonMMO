--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared_folder = ReplicatedStorage
    :WaitForChild("Combat")
    :WaitForChild("Shared")
local CombatConfig = require(shared_folder:WaitForChild("CombatConfig"))

export type MeleeSkillDefinition = {
    KIND: "Melee", ID: string, DISPLAY_NAME: string,
    STAMINA_COST: number, COOLDOWN_SECONDS: number,
    WIND_UP_SECONDS: number, ACTIVE_SECONDS: number, RECOVERY_SECONDS: number,
    FORWARD_STEP_STUDS: number, REACH_STUDS: number, ARC_DEGREES: number,
    HITBOX: {SIZE: Vector3, FORWARD_OFFSET: number, SAMPLE_COUNT: number},
    BASE_DAMAGE: number, STAGGER_SECONDS: number,
    MANA_COST: number?, MAX_TARGETS: number?, SOURCE_POWER: number?,
    NO_STAGGER_REFRESH: boolean?, TAUNT_BONUS_THREAT: number?,
    MOVEMENT_SCALE: {WIND_UP: number, ACTIVE: number, RECOVERY: number},
    RANKS: {[number]: any}?,
}

export type SupportSkillDefinition = {
    KIND: "Support", ID: string, DISPLAY_NAME: string,
    STAMINA_COST: number, COOLDOWN_SECONDS: number,
    HEAL_AMOUNT: number, RANGE_STUDS: number, CHANNEL_SECONDS: number,
    PULSE_COUNT: number, PULSE_HEAL: number, PULSE_INTERVAL_SECONDS: number,
    RANKS: {[number]: any}?,
}

export type MageHealSkillDefinition = {
    KIND: "MageHeal", ID: string, DISPLAY_NAME: string,
    STAMINA_COST: number, MANA_COST: number, COOLDOWN_SECONDS: number,
    WIND_UP_SECONDS: number, ACTIVE_SECONDS: number, RECOVERY_SECONDS: number,
    RANGE_STUDS: number, TOTAL_HEAL: number,
    CURE_POISON_TIER: number?,
    HUMAN_INSTANT_FRACTION: number, HUMAN_HOT_SECONDS: number,
    ELF_INSTANT_FRACTION: number, ELF_HOT_SECONDS: number,
    HOT_TICK_SECONDS: number,
    MOVEMENT_SCALE: {WIND_UP: number, ACTIVE: number, RECOVERY: number},
    RANKS: {[number]: any}?,
}

export type MagicProjectileSkillDefinition = {
    KIND: "MagicProjectile", ID: string, DISPLAY_NAME: string,
    STAMINA_COST: number, MANA_COST: number, COOLDOWN_SECONDS: number,
    WIND_UP_SECONDS: number, ACTIVE_SECONDS: number, RECOVERY_SECONDS: number,
    RANGE_STUDS: number, PROJECTILE_SPEED: number, BASE_DAMAGE: number,
    MOVEMENT_SCALE: {WIND_UP: number, ACTIVE: number, RECOVERY: number},
    RANKS: {[number]: any}?,
}

export type WardSkillDefinition = {
    KIND: "Ward", ID: string, DISPLAY_NAME: string,
    STAMINA_COST: number, MANA_COST: number, COOLDOWN_SECONDS: number,
    WIND_UP_SECONDS: number, ACTIVE_SECONDS: number, RECOVERY_SECONDS: number,
    RANGE_STUDS: number, WARD_AMOUNT: number, DURATION_SECONDS: number,
    MOVEMENT_SCALE: {WIND_UP: number, ACTIVE: number, RECOVERY: number},
    RANKS: {[number]: any}?,
}

export type RangerProjectileSkillDefinition = {
    KIND: "RangerProjectile", ID: string, DISPLAY_NAME: string,
    STAMINA_COST: number, COOLDOWN_SECONDS: number,
    WIND_UP_SECONDS: number, ACTIVE_SECONDS: number, RECOVERY_SECONDS: number,
    RANGE_STUDS: number, PROJECTILE_SPEED: number, BASE_DAMAGE: number,
    MAX_TARGETS: number, DEFAULT_RETENTION: number, HUMAN_RETENTION: number,
    HUMAN_SLOW_FRACTION: number?, HUMAN_SLOW_SECONDS: number?,
    ELF_SLOW_FRACTION: number?, ELF_SLOW_SECONDS: number?,
    MOVEMENT_SCALE: {WIND_UP: number, ACTIVE: number, RECOVERY: number},
    RANKS: {[number]: any}?,
}

export type RangerVolleySkillDefinition = {
    KIND: "RangerVolley", ID: string, DISPLAY_NAME: string,
    STAMINA_COST: number, COOLDOWN_SECONDS: number,
    WIND_UP_SECONDS: number, ACTIVE_SECONDS: number, RECOVERY_SECONDS: number,
    AIM_RANGE_STUDS: number, RADIUS_STUDS: number,
    INITIAL_DAMAGE: number, PULSE_DAMAGE: number,
    PULSE_COUNT: number, PULSE_INTERVAL_SECONDS: number,
    MOVEMENT_SCALE: {WIND_UP: number, ACTIVE: number, RECOVERY: number},
    RANKS: {[number]: any}?,
}

export type BuffSkillDefinition = {
    KIND: "Buff", ID: string, DISPLAY_NAME: string,
    STAMINA_COST: number, MANA_COST: number, COOLDOWN_SECONDS: number,
    WIND_UP_SECONDS: number, ACTIVE_SECONDS: number, RECOVERY_SECONDS: number,
    BUFF_KIND: string, BUFF_MAGNITUDE: number, BUFF_SECONDS: number,
    MOVEMENT_SCALE: {WIND_UP: number, ACTIVE: number, RECOVERY: number},
    RANKS: {[number]: any}?,
}

export type ScoutToggleSkillDefinition = {
    KIND: "ScoutToggle", ID: string, DISPLAY_NAME: string,
    STAMINA_COST: number, COOLDOWN_SECONDS: number,
    CRITICAL_DAMAGE_BONUS: number,
    UPKEEP_STAMINA_PER_SECOND: number,
    RANKS: {[number]: any}?,
}

export type IronvowAccuracyToggleSkillDefinition = {
    KIND: "IronvowAccuracyToggle", ID: string, DISPLAY_NAME: string,
    STAMINA_COST: number, MANA_COST: number,
    COOLDOWN_SECONDS: number,
    ACCURACY_BONUS: number, SOURCE_ACCURACY: number,
    UPKEEP_MANA_PER_SECOND: number,
    RANKS: {[number]: any}?,
}

export type IronvowCriticalToggleSkillDefinition = {
    KIND: "IronvowCriticalToggle", ID: string, DISPLAY_NAME: string,
    STAMINA_COST: number, MANA_COST: number,
    COOLDOWN_SECONDS: number,
    CRITICAL_DAMAGE_BONUS: number, SOURCE_CRITICAL_POWER: number,
    UPKEEP_MANA_PER_SECOND: number,
    RANKS: {[number]: any}?,
}

export type ScoutAccuracyToggleSkillDefinition = {
    KIND: "ScoutAccuracyToggle", ID: string, DISPLAY_NAME: string,
    STAMINA_COST: number, COOLDOWN_SECONDS: number,
    ACCURACY_BONUS: number, UPKEEP_STAMINA_PER_SECOND: number,
    RANKS: {[number]: any}?,
}

export type SkillDefinition = ScoutAccuracyToggleSkillDefinition
    | IronvowCriticalToggleSkillDefinition
    | IronvowAccuracyToggleSkillDefinition
    | ScoutToggleSkillDefinition
    | MeleeSkillDefinition
    | BuffSkillDefinition
    | SupportSkillDefinition
    | MageHealSkillDefinition
    | MagicProjectileSkillDefinition
    | WardSkillDefinition
    | RangerProjectileSkillDefinition
    | RangerVolleySkillDefinition

local SHIELD_BASH: MeleeSkillDefinition = table.freeze({
    KIND = "Melee", ID = "ShieldBash", DISPLAY_NAME = "Shield Bash",
    STAMINA_COST = 20, COOLDOWN_SECONDS = 4.0,
    WIND_UP_SECONDS = 0.16, ACTIVE_SECONDS = 0.10, RECOVERY_SECONDS = 0.32,
    FORWARD_STEP_STUDS = 1.6, REACH_STUDS = 6.0,
    ARC_DEGREES = CombatConfig.DEFENSE.BLOCK_ARC_DEGREES,
    HITBOX = table.freeze({
        SIZE = Vector3.new(12.0, 5.0, 6.4),
        FORWARD_OFFSET = 3.2,
        SAMPLE_COUNT = 3,
    }),
    BASE_DAMAGE = 4, STAGGER_SECONDS = 0.9,
    MOVEMENT_SCALE = table.freeze({
        WIND_UP = 0.35,
        ACTIVE = 0.15,
        RECOVERY = 0.65,
    }),
    RANKS = table.freeze({
        [1] = table.freeze({BASE_DAMAGE = 4, STAGGER_SECONDS = 0.9}),
        [2] = table.freeze({BASE_DAMAGE = 5, STAGGER_SECONDS = 1.0}),
        [3] = table.freeze({BASE_DAMAGE = 6, STAGGER_SECONDS = 1.1}),
    }),
})

-- Zero-damage server-targeted Fighter Taunt. MeleeHitService validates
-- the actual hostile model and range; no damage event is fabricated.
local TAUNT: MeleeSkillDefinition = table.freeze({
    KIND = "Melee", ID = "Taunt", DISPLAY_NAME = "Taunt",
    STAMINA_COST = 12, COOLDOWN_SECONDS = 8,
    WIND_UP_SECONDS = 0.12, ACTIVE_SECONDS = 0.12,
    RECOVERY_SECONDS = 0.25,
    FORWARD_STEP_STUDS = 0, REACH_STUDS = 12, ARC_DEGREES = 100,
    HITBOX = table.freeze({
        SIZE = Vector3.new(14, 6, 12),
        FORWARD_OFFSET = 6,
        SAMPLE_COUNT = 3,
    }),
    BASE_DAMAGE = 0, STAGGER_SECONDS = 0,
    TAUNT_BONUS_THREAT = 15,
    MOVEMENT_SCALE = table.freeze({
        WIND_UP = 0.75, ACTIVE = 0.75, RECOVERY = 0.85,
    }),
    RANKS = table.freeze({
        [1] = table.freeze({TAUNT_BONUS_THREAT = 15}),
        [2] = table.freeze({TAUNT_BONUS_THREAT = 25}),
        [3] = table.freeze({TAUNT_BONUS_THREAT = 40}),
    }),
})

local MEND: SupportSkillDefinition = table.freeze({
    KIND = "Support", ID = "Mend", DISPLAY_NAME = "Mend",
    STAMINA_COST = 20, COOLDOWN_SECONDS = 8.0,
    HEAL_AMOUNT = 25, RANGE_STUDS = 12, CHANNEL_SECONDS = 2.0,
    PULSE_COUNT = 5, PULSE_HEAL = 5, PULSE_INTERVAL_SECONDS = 0.4,
    RANKS = table.freeze({
        [1] = table.freeze({PULSE_HEAL = 5, HEAL_AMOUNT = 25}),
        [2] = table.freeze({PULSE_HEAL = 6, HEAL_AMOUNT = 30}),
        [3] = table.freeze({PULSE_HEAL = 7, HEAL_AMOUNT = 35}),
    }),
})

local ARC_SLASH: MeleeSkillDefinition = table.freeze({
    KIND = "Melee", ID = "ArcSlash", DISPLAY_NAME = "Arc Slash",
    STAMINA_COST = 15, COOLDOWN_SECONDS = 5.0,
    WIND_UP_SECONDS = 0.22, ACTIVE_SECONDS = 0.12, RECOVERY_SECONDS = 0.38,
    FORWARD_STEP_STUDS = 2.2, REACH_STUDS = 7.0, ARC_DEGREES = 100,
    HITBOX = table.freeze({
        SIZE = Vector3.new(14.0, 5.0, 7.0),
        FORWARD_OFFSET = 3.5,
        SAMPLE_COUNT = 4,
    }),
    BASE_DAMAGE = 12, STAGGER_SECONDS = 0,
    MOVEMENT_SCALE = table.freeze({
        WIND_UP = 0.30,
        ACTIVE = 0.12,
        RECOVERY = 0.60,
    }),
    RANKS = table.freeze({
        [1] = table.freeze({BASE_DAMAGE = 12}),
        [2] = table.freeze({BASE_DAMAGE = 15}),
        [3] = table.freeze({BASE_DAMAGE = 18}),
    }),
})

local WIND_STRIKE: MagicProjectileSkillDefinition = table.freeze({
    KIND = "MagicProjectile", ID = "WindStrike", DISPLAY_NAME = "Wind Strike",
    STAMINA_COST = 0, MANA_COST = 25, COOLDOWN_SECONDS = 5.0,
    WIND_UP_SECONDS = 1.0, ACTIVE_SECONDS = 0.08, RECOVERY_SECONDS = 0.35,
    RANGE_STUDS = 60, PROJECTILE_SPEED = 78, BASE_DAMAGE = 30,
    MOVEMENT_SCALE = table.freeze({
        WIND_UP = 0,
        ACTIVE = 0,
        RECOVERY = 0,
    }),
    RANKS = table.freeze({
        [1] = table.freeze({BASE_DAMAGE = 30}),
        [2] = table.freeze({BASE_DAMAGE = 36}),
        [3] = table.freeze({BASE_DAMAGE = 42}),
    }),
})

local ARCANE_WARD: WardSkillDefinition = table.freeze({
    KIND = "Ward", ID = "ArcaneWard", DISPLAY_NAME = "Arcane Ward",
    STAMINA_COST = 0, MANA_COST = 25, COOLDOWN_SECONDS = 8.0,
    WIND_UP_SECONDS = 0.25, ACTIVE_SECONDS = 0.05, RECOVERY_SECONDS = 0.25,
    RANGE_STUDS = 22, WARD_AMOUNT = 30, DURATION_SECONDS = 6.0,
    MOVEMENT_SCALE = table.freeze({
        WIND_UP = 0.50,
        ACTIVE = 0.30,
        RECOVERY = 0.70,
    }),
    RANKS = table.freeze({
        [1] = table.freeze({WARD_AMOUNT = 30}),
        [2] = table.freeze({WARD_AMOUNT = 36}),
        [3] = table.freeze({WARD_AMOUNT = 42}),
    }),
})

local MAGE_HEAL: MageHealSkillDefinition = table.freeze({
    KIND = "MageHeal", ID = "MageHeal", DISPLAY_NAME = "Mage Heal",
    STAMINA_COST = 0, MANA_COST = 30, COOLDOWN_SECONDS = 6.0,
    WIND_UP_SECONDS = 0.25, ACTIVE_SECONDS = 0.05, RECOVERY_SECONDS = 0.25,
    RANGE_STUDS = 22, TOTAL_HEAL = 40,
    HUMAN_INSTANT_FRACTION = 0.80,
    HUMAN_HOT_SECONDS = 4.0,
    ELF_INSTANT_FRACTION = 0.30,
    ELF_HOT_SECONDS = 6.0,
    HOT_TICK_SECONDS = 1.0,
    MOVEMENT_SCALE = table.freeze({
        WIND_UP = 0.50,
        ACTIVE = 0.30,
        RECOVERY = 0.70,
    }),
    RANKS = table.freeze({
        [1] = table.freeze({TOTAL_HEAL = 40}),
        [2] = table.freeze({TOTAL_HEAL = 46}),
        [3] = table.freeze({TOTAL_HEAL = 52}),
    }),
})

local PIERCING_SHOT: RangerProjectileSkillDefinition = table.freeze({
    KIND = "RangerProjectile",
    ID = "PiercingShot",
    DISPLAY_NAME = "Piercing Shot",
    STAMINA_COST = 20,
    COOLDOWN_SECONDS = 6.0,
    WIND_UP_SECONDS = 0.24,
    ACTIVE_SECONDS = 0.06,
    RECOVERY_SECONDS = 0.30,
    RANGE_STUDS = 80,
    PROJECTILE_SPEED = 125,
    BASE_DAMAGE = 28,
    MAX_TARGETS = 4,
    DEFAULT_RETENTION = 0.70,
    HUMAN_RETENTION = 0.80,
    MOVEMENT_SCALE = table.freeze({
        WIND_UP = 0.55,
        ACTIVE = 0.45,
        RECOVERY = 0.80,
    }),
    RANKS = table.freeze({
        [1] = table.freeze({BASE_DAMAGE = 28}),
        [2] = table.freeze({BASE_DAMAGE = 33}),
        [3] = table.freeze({BASE_DAMAGE = 38}),
    }),
})

local CRIPPLING_SHOT: RangerProjectileSkillDefinition = table.freeze({
    KIND = "RangerProjectile",
    ID = "CripplingShot",
    DISPLAY_NAME = "Crippling Shot",
    STAMINA_COST = 20,
    COOLDOWN_SECONDS = 7.0,
    WIND_UP_SECONDS = 0.20,
    ACTIVE_SECONDS = 0.06,
    RECOVERY_SECONDS = 0.30,
    RANGE_STUDS = 75,
    PROJECTILE_SPEED = 115,
    BASE_DAMAGE = 18,
    MAX_TARGETS = 1,
    DEFAULT_RETENTION = 1.00,
    HUMAN_RETENTION = 1.00,
    HUMAN_SLOW_FRACTION = 0.30,
    HUMAN_SLOW_SECONDS = 3.0,
    ELF_SLOW_FRACTION = 0.40,
    ELF_SLOW_SECONDS = 4.0,
    MOVEMENT_SCALE = table.freeze({
        WIND_UP = 0.60,
        ACTIVE = 0.45,
        RECOVERY = 0.82,
    }),
    RANKS = table.freeze({
        [1] = table.freeze({BASE_DAMAGE = 18}),
        [2] = table.freeze({BASE_DAMAGE = 22}),
        [3] = table.freeze({BASE_DAMAGE = 26}),
    }),
})

local VOLLEY: RangerVolleySkillDefinition = table.freeze({
    KIND = "RangerVolley",
    ID = "Volley",
    DISPLAY_NAME = "Volley",
    STAMINA_COST = 30,
    COOLDOWN_SECONDS = 10.0,
    WIND_UP_SECONDS = 0.28,
    ACTIVE_SECONDS = 0.06,
    RECOVERY_SECONDS = 0.36,
    AIM_RANGE_STUDS = 60,
    RADIUS_STUDS = 10,
    INITIAL_DAMAGE = 14,
    PULSE_DAMAGE = 7,
    PULSE_COUNT = 4,
    PULSE_INTERVAL_SECONDS = 0.5,
    MOVEMENT_SCALE = table.freeze({
        WIND_UP = 0.45,
        ACTIVE = 0.35,
        RECOVERY = 0.75,
    }),
    RANKS = table.freeze({
        [1] = table.freeze({INITIAL_DAMAGE = 14, PULSE_DAMAGE = 7}),
        [2] = table.freeze({INITIAL_DAMAGE = 16, PULSE_DAMAGE = 8}),
        [3] = table.freeze({INITIAL_DAMAGE = 18, PULSE_DAMAGE = 9}),
    }),
})

local function rogue_melee(
    id: string,
    display_name: string,
    stamina: number,
    cooldown: number,
    damage: number,
    step: number,
    extras: any?
): any
    local definition: any = {
        KIND = "Melee",
        ID = id,
        DISPLAY_NAME = display_name,
        STAMINA_COST = stamina,
        COOLDOWN_SECONDS = cooldown,
        WIND_UP_SECONDS = 0.14,
        ACTIVE_SECONDS = 0.08,
        RECOVERY_SECONDS = 0.24,
        FORWARD_STEP_STUDS = step,
        REACH_STUDS = 6.5,
        ARC_DEGREES = 90,
        HITBOX = table.freeze({
            SIZE = Vector3.new(11.5, 5.0, 6.5),
            FORWARD_OFFSET = 3.0,
            SAMPLE_COUNT = 3,
        }),
        BASE_DAMAGE = damage,
        STAGGER_SECONDS = 0,
        MOVEMENT_SCALE = table.freeze({
            WIND_UP = 0.55,
            ACTIVE = 0.35,
            RECOVERY = 0.78,
        }),
        RANKS = table.freeze({
            [1] = table.freeze({BASE_DAMAGE = damage}),
            [2] = table.freeze({
                BASE_DAMAGE = if damage > 0 then damage + 3 else 0,
            }),
            [3] = table.freeze({
                BASE_DAMAGE = if damage > 0 then damage + 6 else 0,
            }),
        }),
    }
    for key, value in pairs(extras or {}) do
        definition[key] = value
    end
    return table.freeze(definition)
end

local QUICK_STRIKE = rogue_melee("QuickStrike", "Quick Strike", 10, 3.0, 10, 1.8, nil)
local BACKSTAB = rogue_melee("Backstab", "Backstab", 18, 5.0, 14, 2.0, {REAR_MULTIPLIER = 1.75})
local FEINT = rogue_melee("Feint", "Feint", 12, 5.0, 6, 1.2, {EXPOSE_SECONDS = 2.0})
local SHADOW_DASH = rogue_melee("ShadowDash", "Shadow Dash", 16, 7.0, 4, 6.5, nil)
local EVASIVE_STEP = rogue_melee("EvasiveStep", "Evasive Step", 15, 6.0, 0, 4.5, {EVASION_IFRAME_SECONDS = 0.22})
local THREAT_DROP = rogue_melee("ThreatDrop", "Threat Drop", 12, 9.0, 0, 0.2, {AGGRO_SUPPRESS_SECONDS = 2.5})

local DUELIST_AMBUSH = rogue_melee("DuelistAmbush", "Ambush", 18, 7.0, 12, 7.0, {REAR_MULTIPLIER = 1.35})
local DUELIST_DEADLY_BLOW = rogue_melee("DuelistDeadlyBlow", "Deadly Blow", 22, 8.0, 18, 2.0, {REAR_MULTIPLIER = 1.80})
local DUELIST_EXPOSE = rogue_melee("DuelistExposeWeakness", "Expose Weakness", 14, 8.0, 8, 1.4, {EXPOSE_SECONDS = 4.0})
local DUELIST_RUSH = rogue_melee("DuelistRush", "Rush", 18, 7.0, 8, 7.0, nil)

local WINDSTALKER_FLURRY = rogue_melee("WindstalkerFlurry", "Flurry", 16, 5.0, 11, 2.2, nil)
local WINDSTALKER_SLIPSTREAM = rogue_melee("WindstalkerSlipstream", "Slipstream", 14, 6.0, 5, 6.0, nil)
local WINDSTALKER_BLUR = rogue_melee("WindstalkerBlur", "Blur", 16, 8.0, 0, 4.8, {EVASION_IFRAME_SECONDS = 0.28})
local WINDSTALKER_QUICKSTEP = rogue_melee("WindstalkerQuickstep", "Quickstep", 10, 4.0, 4, 5.0, nil)

-- Reuses verified hit, threat, projectile and volley executors. Advanced
-- skills have different server-owned costs and ranks, not a second
-- combat implementation or untested client-side effects.
--
-- Args:
--   source (any): Existing validated combat skill definition.
--   id (string): Stable advanced-class skill identifier.
--   display_name (string): Player-facing ability name.
--   overrides (any): Authoritative combat values and rank effects.
-- Returns:
--   any: Frozen definition with the original executor-compatible shape.
local function specialize_skill(
    source: any,
    id: string,
    display_name: string,
    overrides: any
): any
    local definition = {}
    for key, value in pairs(source) do
        definition[key] = value
    end
    definition.ID = id
    definition.DISPLAY_NAME = display_name
    for key, value in pairs(overrides) do
        definition[key] = value
    end
    return table.freeze(definition)
end

-- Low-level Mage defence and attack use the already-validated ward
-- and projectile executors. All values and upgrades are server-owned.
local DAWN_WARD = specialize_skill(
    ARCANE_WARD, "DawnWard", "Dawn Ward", {
        MANA_COST = 12,
        COOLDOWN_SECONDS = 7.0,
        WARD_AMOUNT = 14,
        DURATION_SECONDS = 4.0,
        RANKS = table.freeze({
            [1] = table.freeze({WARD_AMOUNT = 14}),
            [2] = table.freeze({WARD_AMOUNT = 21}),
            [3] = table.freeze({WARD_AMOUNT = 29}),
        }),
    }
)

local CINDER_BOLT = specialize_skill(
    WIND_STRIKE, "CinderBolt", "Cinder Bolt", {
        MANA_COST = 10,
        COOLDOWN_SECONDS = 3.5,
        BASE_DAMAGE = 12,
        RANKS = table.freeze({
            [1] = table.freeze({BASE_DAMAGE = 12}),
            [2] = table.freeze({BASE_DAMAGE = 18}),
            [3] = table.freeze({BASE_DAMAGE = 25}),
        }),
    }
)

local GUARD_BREAKER = specialize_skill(
    SHIELD_BASH, "GuardBreaker", "Guard Breaker", {
        STAMINA_COST = 16,
        COOLDOWN_SECONDS = 6,
        BASE_DAMAGE = 5,
        STAGGER_SECONDS = 0.5,
        RANKS = table.freeze({
            [1] = table.freeze({BASE_DAMAGE = 5, STAGGER_SECONDS = 0.5}),
            [2] = table.freeze({BASE_DAMAGE = 7, STAGGER_SECONDS = 0.6}),
            [3] = table.freeze({BASE_DAMAGE = 9, STAGGER_SECONDS = 0.7}),
        }),
    }
)

local AETHER_BOLT = specialize_skill(
    WIND_STRIKE, "AetherBolt", "Aether Bolt", {
        MANA_COST = 17,
        COOLDOWN_SECONDS = 4,
        BASE_DAMAGE = 18,
        RANKS = table.freeze({
            [1] = table.freeze({BASE_DAMAGE = 18}),
            [2] = table.freeze({BASE_DAMAGE = 22}),
            [3] = table.freeze({BASE_DAMAGE = 26}),
        }),
    }
)

local TRACKER_SHOT = specialize_skill(
    PIERCING_SHOT, "TrackerShot", "Tracker Shot", {
        STAMINA_COST = 15,
        COOLDOWN_SECONDS = 5,
        BASE_DAMAGE = 18,
        MAX_TARGETS = 1,
        RANKS = table.freeze({
            [1] = table.freeze({BASE_DAMAGE = 18}),
            [2] = table.freeze({BASE_DAMAGE = 22}),
            [3] = table.freeze({BASE_DAMAGE = 26}),
        }),
    }
)

local VIPER_STRIKE = specialize_skill(
    QUICK_STRIKE, "ViperStrike", "Viper Strike", {
        STAMINA_COST = 14,
        COOLDOWN_SECONDS = 4,
        BASE_DAMAGE = 11,
        RANKS = table.freeze({
            [1] = table.freeze({BASE_DAMAGE = 11}),
            [2] = table.freeze({BASE_DAMAGE = 14}),
            [3] = table.freeze({BASE_DAMAGE = 17}),
        }),
    }
)

-- A lower-damage two-target control arrow. Every rank improves the
-- server-owned slow duration, not just the projectile's damage.
local BRIAR_VOLLEY = specialize_skill(
    CRIPPLING_SHOT, "BriarVolley", "Briar Volley", {
        STAMINA_COST = 24,
        COOLDOWN_SECONDS = 9,
        MAX_TARGETS = 2,
        DEFAULT_RETENTION = 0.85,
        HUMAN_RETENTION = 0.85,
        BASE_DAMAGE = 9,
        HUMAN_SLOW_FRACTION = 0.20,
        ELF_SLOW_FRACTION = 0.25,
        HUMAN_SLOW_SECONDS = 1.5,
        ELF_SLOW_SECONDS = 2.0,
        RANKS = table.freeze({
            [1] = table.freeze({
                BASE_DAMAGE = 9,
                HUMAN_SLOW_SECONDS = 1.5,
                ELF_SLOW_SECONDS = 2.0,
            }),
            [2] = table.freeze({
                BASE_DAMAGE = 12,
                HUMAN_SLOW_SECONDS = 2.0,
                ELF_SLOW_SECONDS = 2.5,
            }),
            [3] = table.freeze({
                BASE_DAMAGE = 15,
                HUMAN_SLOW_SECONDS = 2.5,
                ELF_SLOW_SECONDS = 3.0,
            }),
        }),
    }
)

-- A close-range interruption with brief stagger, instead of Feint's
-- exposed-target damage amplifier. Stagger duration increases by rank.
local DISRUPTING_CUT = specialize_skill(
    FEINT, "DisruptingCut", "Disrupting Cut", {
        STAMINA_COST = 16,
        COOLDOWN_SECONDS = 8,
        BASE_DAMAGE = 5,
        EXPOSE_SECONDS = 0,
        STAGGER_SECONDS = 0.35,
        RANKS = table.freeze({
            [1] = table.freeze({
                BASE_DAMAGE = 5, STAGGER_SECONDS = 0.35,
            }),
            [2] = table.freeze({
                BASE_DAMAGE = 7, STAGGER_SECONDS = 0.50,
            }),
            [3] = table.freeze({
                BASE_DAMAGE = 9, STAGGER_SECONDS = 0.70,
            }),
        }),
    }
)

-- C4-inspired level-36 bow stun: unlike Briar Volley it targets one
-- enemy and invokes the existing authoritative stagger executor.
local THUNDER_SHOT = specialize_skill(
    CRIPPLING_SHOT, "ThunderShot", "Thunder Shot", {
        STAMINA_COST = 26,
        COOLDOWN_SECONDS = 9.0,
        MAX_TARGETS = 1,
        BASE_DAMAGE = 19,
        HUMAN_SLOW_FRACTION = 0,
        ELF_SLOW_FRACTION = 0,
        HUMAN_SLOW_SECONDS = 0,
        ELF_SLOW_SECONDS = 0,
        STAGGER_SECONDS = 0.35,
        RANKS = table.freeze({
            [1] = table.freeze({
                BASE_DAMAGE = 19, STAGGER_SECONDS = 0.35,
            }),
            [2] = table.freeze({
                BASE_DAMAGE = 22, STAGGER_SECONDS = 0.50,
            }),
            [3] = table.freeze({
                BASE_DAMAGE = 25, STAGGER_SECONDS = 0.70,
            }),
        }),
    }
)

-- Nine effective sword strikes spanning the first three Fighter brackets.
local IRON_CLEAVE = specialize_skill(
    ARC_SLASH, "IronCleave", "Iron Cleave", {
        STAMINA_COST = 12,
        COOLDOWN_SECONDS = 4,
        FORWARD_STEP_STUDS = 1.4,
        BASE_DAMAGE = 6,
        RANKS = table.freeze({
            [1] = table.freeze({BASE_DAMAGE = 6}),
            [2] = table.freeze({BASE_DAMAGE = 8}),
            [3] = table.freeze({BASE_DAMAGE = 10}),
            [4] = table.freeze({BASE_DAMAGE = 12}),
            [5] = table.freeze({BASE_DAMAGE = 14}),
            [6] = table.freeze({BASE_DAMAGE = 16}),
            [7] = table.freeze({BASE_DAMAGE = 18}),
            [8] = table.freeze({BASE_DAMAGE = 20}),
            [9] = table.freeze({BASE_DAMAGE = 22}),
        }),
    }
)

-- A mobile, lower-damage strike: longer forward step than Iron Cleave.
local PURSUIT_STEP = specialize_skill(
    QUICK_STRIKE, "PursuitStep", "Pursuit Step", {
        STAMINA_COST = 15,
        COOLDOWN_SECONDS = 6,
        FORWARD_STEP_STUDS = 4.5,
        BASE_DAMAGE = 4,
        RANKS = table.freeze({
            [1] = table.freeze({BASE_DAMAGE = 4}),
            [2] = table.freeze({BASE_DAMAGE = 5}),
            [3] = table.freeze({BASE_DAMAGE = 6}),
            [4] = table.freeze({BASE_DAMAGE = 7}),
            [5] = table.freeze({BASE_DAMAGE = 8}),
            [6] = table.freeze({BASE_DAMAGE = 9}),
            [7] = table.freeze({BASE_DAMAGE = 10}),
            [8] = table.freeze({BASE_DAMAGE = 11}),
            [9] = table.freeze({BASE_DAMAGE = 12}),
        }),
    }
)

-- A sustained healing variant of Mage Heal, not a cosmetic spellbook.
-- Each purchased rank raises the actual server-applied healing amount.
local RENEWING_LIGHT = specialize_skill(
    MAGE_HEAL, "RenewingLight", "Renewing Light", {
        MANA_COST = 22,
        COOLDOWN_SECONDS = 7,
        HUMAN_INSTANT_FRACTION = 0.35,
        ELF_INSTANT_FRACTION = 0.15,
        BASE_DAMAGE = nil,
        TOTAL_HEAL = 16,
        RANKS = table.freeze({
            [1] = table.freeze({TOTAL_HEAL = 16}),
            [2] = table.freeze({TOTAL_HEAL = 20}),
            [3] = table.freeze({TOTAL_HEAL = 24}),
            [4] = table.freeze({TOTAL_HEAL = 28}),
            [5] = table.freeze({TOTAL_HEAL = 32}),
            [6] = table.freeze({TOTAL_HEAL = 36}),
        }),
    }
)

-- Early weapon progression reuses proven C4-style high-impact bow
-- shots and rear-attack strikes. All nine ranks have real damage.
local ARCHER_DRAW = specialize_skill(
    PIERCING_SHOT, "ArcherDraw", "Archer Draw", {
        STAMINA_COST = 15,
        COOLDOWN_SECONDS = 4.5,
        MAX_TARGETS = 1,
        BASE_DAMAGE = 7,
        RANKS = table.freeze({
            [1] = table.freeze({BASE_DAMAGE = 7}),
            [2] = table.freeze({BASE_DAMAGE = 9}),
            [3] = table.freeze({BASE_DAMAGE = 11}),
            [4] = table.freeze({BASE_DAMAGE = 13}),
            [5] = table.freeze({BASE_DAMAGE = 15}),
            [6] = table.freeze({BASE_DAMAGE = 17}),
            [7] = table.freeze({BASE_DAMAGE = 19}),
            [8] = table.freeze({BASE_DAMAGE = 21}),
            [9] = table.freeze({BASE_DAMAGE = 23}),
        }),
    }
)

local ROGUE_VITAL_BLOW = specialize_skill(
    BACKSTAB, "RogueVitalBlow", "Vital Blow", {
        STAMINA_COST = 14,
        COOLDOWN_SECONDS = 4.5,
        BASE_DAMAGE = 7,
        REAR_MULTIPLIER = 1.5,
        RANKS = table.freeze({
            [1] = table.freeze({BASE_DAMAGE = 7}),
            [2] = table.freeze({BASE_DAMAGE = 9}),
            [3] = table.freeze({BASE_DAMAGE = 11}),
            [4] = table.freeze({BASE_DAMAGE = 13}),
            [5] = table.freeze({BASE_DAMAGE = 15}),
            [6] = table.freeze({BASE_DAMAGE = 17}),
            [7] = table.freeze({BASE_DAMAGE = 19}),
            [8] = table.freeze({BASE_DAMAGE = 21}),
            [9] = table.freeze({BASE_DAMAGE = 23}),
        }),
    }
)

-- A C4-inspired bleeding sword strike with an actual server-applied
-- damage-over-time component; upgrading changes the subsequent ticks.
local LACERATING_CUT = specialize_skill(
    BACKSTAB, "LaceratingCut", "Lacerating Cut", {
        STAMINA_COST = 20,
        COOLDOWN_SECONDS = 10,
        BASE_DAMAGE = 6,
        REAR_MULTIPLIER = 1,
        BLEED_TICK_DAMAGE = 3,
        BLEED_TICK_COUNT = 3,
        BLEED_TICK_INTERVAL = 0.6,
        RANKS = table.freeze({
            [1] = table.freeze({
                BASE_DAMAGE = 6,
                BLEED_TICK_DAMAGE = 3,
            }),
            [2] = table.freeze({
                BASE_DAMAGE = 9,
                BLEED_TICK_DAMAGE = 5,
            }),
        }),
    }
)

-- C4 first-transfer 20/24/28/32/36 bow and sword damage ladders.
-- All fifteen ranks have a distinct server-executed impact, not mere
-- trainer entries. The dagger path will replace the temporary sword.
local SCOUT_FOCUSED_SHOT = specialize_skill(
    PIERCING_SHOT, "ScoutFocusedShot", "Focused Shot", {
        STAMINA_COST = 23,
        COOLDOWN_SECONDS = 5,
        MAX_TARGETS = 1,
        BASE_DAMAGE = 24,
        RANKS = table.freeze({
            [1] = table.freeze({BASE_DAMAGE = 24}),
            [2] = table.freeze({BASE_DAMAGE = 27}),
            [3] = table.freeze({BASE_DAMAGE = 30}),
            [4] = table.freeze({BASE_DAMAGE = 33}),
            [5] = table.freeze({BASE_DAMAGE = 36}),
            [6] = table.freeze({BASE_DAMAGE = 39}),
            [7] = table.freeze({BASE_DAMAGE = 42}),
            [8] = table.freeze({BASE_DAMAGE = 45}),
            [9] = table.freeze({BASE_DAMAGE = 48}),
            [10] = table.freeze({BASE_DAMAGE = 51}),
            [11] = table.freeze({BASE_DAMAGE = 54}),
            [12] = table.freeze({BASE_DAMAGE = 57}),
            [13] = table.freeze({BASE_DAMAGE = 60}),
            [14] = table.freeze({BASE_DAMAGE = 63}),
            [15] = table.freeze({BASE_DAMAGE = 66}),
        }),
    }
)

local ROGUE_FINISHING_CUT = specialize_skill(
    BACKSTAB, "RogueFinishingCut", "Finishing Cut", {
        STAMINA_COST = 20,
        COOLDOWN_SECONDS = 5,
        BASE_DAMAGE = 20,
        REAR_MULTIPLIER = 1.65,
        RANKS = table.freeze({
            [1] = table.freeze({BASE_DAMAGE = 20}),
            [2] = table.freeze({BASE_DAMAGE = 23}),
            [3] = table.freeze({BASE_DAMAGE = 26}),
            [4] = table.freeze({BASE_DAMAGE = 29}),
            [5] = table.freeze({BASE_DAMAGE = 32}),
            [6] = table.freeze({BASE_DAMAGE = 35}),
            [7] = table.freeze({BASE_DAMAGE = 38}),
            [8] = table.freeze({BASE_DAMAGE = 41}),
            [9] = table.freeze({BASE_DAMAGE = 44}),
            [10] = table.freeze({BASE_DAMAGE = 47}),
            [11] = table.freeze({BASE_DAMAGE = 50}),
            [12] = table.freeze({BASE_DAMAGE = 53}),
            [13] = table.freeze({BASE_DAMAGE = 56}),
            [14] = table.freeze({BASE_DAMAGE = 59}),
            [15] = table.freeze({BASE_DAMAGE = 62}),
        }),
    }
)

-- Elf-only first-transfer recovery uses the same verified self/ally
-- heal-over-time executor, but explicitly targets the owner.
local ELVEN_RENEWAL = specialize_skill(
    MAGE_HEAL, "ElvenRenewal", "Elven Renewal", {
        SELF_ONLY = true,
        MANA_COST = 15,
        COOLDOWN_SECONDS = 6,
        ELF_INSTANT_FRACTION = 0.15,
        ELF_HOT_SECONDS = 4.5,
        HOT_TICK_SECONDS = 0.75,
        TOTAL_HEAL = 15,
        RANKS = table.freeze({
            [1] = table.freeze({TOTAL_HEAL = 15}),
            [2] = table.freeze({TOTAL_HEAL = 18}),
            [3] = table.freeze({TOTAL_HEAL = 21}),
            [4] = table.freeze({TOTAL_HEAL = 24}),
            [5] = table.freeze({TOTAL_HEAL = 27}),
            [6] = table.freeze({TOTAL_HEAL = 30}),
            [7] = table.freeze({TOTAL_HEAL = 33}),
            [8] = table.freeze({TOTAL_HEAL = 36}),
            [9] = table.freeze({TOTAL_HEAL = 39}),
            [10] = table.freeze({TOTAL_HEAL = 42}),
            [11] = table.freeze({TOTAL_HEAL = 45}),
            [12] = table.freeze({TOTAL_HEAL = 48}),
            [13] = table.freeze({TOTAL_HEAL = 51}),
            [14] = table.freeze({TOTAL_HEAL = 54}),
            [15] = table.freeze({TOTAL_HEAL = 57}),
        }),
    }
)

-- Confirmed Elf arrows lower the caster's actual threat on that NPC.
-- Reduction grows across all fifteen source-band ranks.
local ELVEN_CALMING_SHOT = specialize_skill(
    PIERCING_SHOT, "ElvenCalmingShot", "Calming Shot", {
        STAMINA_COST = 18,
        COOLDOWN_SECONDS = 6,
        MAX_TARGETS = 1,
        BASE_DAMAGE = 7,
        THREAT_REDUCTION_FRACTION = 0.10,
        RANKS = table.freeze({
            [1] = table.freeze({
                BASE_DAMAGE = 7,
                THREAT_REDUCTION_FRACTION = 0.100,
            }),
            [2] = table.freeze({
                BASE_DAMAGE = 8,
                THREAT_REDUCTION_FRACTION = 0.125,
            }),
            [3] = table.freeze({
                BASE_DAMAGE = 9,
                THREAT_REDUCTION_FRACTION = 0.150,
            }),
            [4] = table.freeze({
                BASE_DAMAGE = 10,
                THREAT_REDUCTION_FRACTION = 0.175,
            }),
            [5] = table.freeze({
                BASE_DAMAGE = 11,
                THREAT_REDUCTION_FRACTION = 0.200,
            }),
            [6] = table.freeze({
                BASE_DAMAGE = 12,
                THREAT_REDUCTION_FRACTION = 0.225,
            }),
            [7] = table.freeze({
                BASE_DAMAGE = 13,
                THREAT_REDUCTION_FRACTION = 0.250,
            }),
            [8] = table.freeze({
                BASE_DAMAGE = 14,
                THREAT_REDUCTION_FRACTION = 0.275,
            }),
            [9] = table.freeze({
                BASE_DAMAGE = 15,
                THREAT_REDUCTION_FRACTION = 0.300,
            }),
            [10] = table.freeze({
                BASE_DAMAGE = 16,
                THREAT_REDUCTION_FRACTION = 0.325,
            }),
            [11] = table.freeze({
                BASE_DAMAGE = 17,
                THREAT_REDUCTION_FRACTION = 0.350,
            }),
            [12] = table.freeze({
                BASE_DAMAGE = 18,
                THREAT_REDUCTION_FRACTION = 0.375,
            }),
            [13] = table.freeze({
                BASE_DAMAGE = 19,
                THREAT_REDUCTION_FRACTION = 0.400,
            }),
            [14] = table.freeze({
                BASE_DAMAGE = 20,
                THREAT_REDUCTION_FRACTION = 0.425,
            }),
            [15] = table.freeze({
                BASE_DAMAGE = 21,
                THREAT_REDUCTION_FRACTION = 0.450,
            }),
        }),
    }
)

-- First-tier Fighter bow and dagger ranks share the accepted
-- authoritative ranged/melee executors and have distinct real damage.
local FIGHTER_BOW_SHOT = specialize_skill(
    PIERCING_SHOT, "FighterBowShot", "Fighter Bow Shot", {
        STAMINA_COST = 13,
        COOLDOWN_SECONDS = 5,
        MAX_TARGETS = 1,
        BASE_DAMAGE = 11,
        RANKS = table.freeze({
            [1] = table.freeze({
                BASE_DAMAGE = 11,
            }),
            [2] = table.freeze({
                BASE_DAMAGE = 14,
            }),
            [3] = table.freeze({
                BASE_DAMAGE = 17,
            }),
            [4] = table.freeze({
                BASE_DAMAGE = 20,
            }),
            [5] = table.freeze({
                BASE_DAMAGE = 23,
            }),
            [6] = table.freeze({
                BASE_DAMAGE = 26,
            }),
            [7] = table.freeze({
                BASE_DAMAGE = 29,
            }),
            [8] = table.freeze({
                BASE_DAMAGE = 32,
            }),
            [9] = table.freeze({
                BASE_DAMAGE = 35,
            }),
        }),
    }
)

local FIGHTER_DAGGER_STRIKE = specialize_skill(
    BACKSTAB, "FighterDaggerStrike", "Fighter Dagger Strike", {
        STAMINA_COST = 12,
        COOLDOWN_SECONDS = 5,
        BASE_DAMAGE = 12,
        REAR_MULTIPLIER = 1,
        RANKS = table.freeze({
            [1] = table.freeze({
                BASE_DAMAGE = 12,
            }),
            [2] = table.freeze({
                BASE_DAMAGE = 15,
            }),
            [3] = table.freeze({
                BASE_DAMAGE = 18,
            }),
            [4] = table.freeze({
                BASE_DAMAGE = 21,
            }),
            [5] = table.freeze({
                BASE_DAMAGE = 24,
            }),
            [6] = table.freeze({
                BASE_DAMAGE = 27,
            }),
            [7] = table.freeze({
                BASE_DAMAGE = 30,
            }),
            [8] = table.freeze({
                BASE_DAMAGE = 33,
            }),
            [9] = table.freeze({
                BASE_DAMAGE = 36,
            }),
        }),
    }
)

-- C4 first-tier Mystic Wind Strike ranks after the owned starter.
-- Uses the real server MagicProjectile executor and four increasing hits.
local MYSTIC_WIND_BOLT = specialize_skill(
    WIND_STRIKE, "MysticWindBolt", "Mystic Wind Bolt", {
        MANA_COST = 11,
        COOLDOWN_SECONDS = 4,
        BASE_DAMAGE = 13,
        RANKS = table.freeze({
            [1] = table.freeze({BASE_DAMAGE = 13}),
            [2] = table.freeze({BASE_DAMAGE = 15}),
            [3] = table.freeze({BASE_DAMAGE = 18}),
            [4] = table.freeze({BASE_DAMAGE = 21}),
        }),
    }
)

-- Human/Elven first-tier healing ranks after the owned starter.
-- The accepted MageHeal executor handles the target and HoT on server.
local MYSTIC_HEALING_PRAYER = specialize_skill(
    MAGE_HEAL, "MysticHealingPrayer", "Healing Prayer", {
        MANA_COST = 12,
        COOLDOWN_SECONDS = 6,
        TOTAL_HEAL = 49,
        RANKS = table.freeze({
            [1] = table.freeze({TOTAL_HEAL = 49}),
            [2] = table.freeze({TOTAL_HEAL = 58}),
            [3] = table.freeze({TOTAL_HEAL = 67}),
            [4] = table.freeze({TOTAL_HEAL = 83}),
            [5] = table.freeze({TOTAL_HEAL = 95}),
            [6] = table.freeze({TOTAL_HEAL = 107}),
        }),
    }
)

-- C4 level-14 Battle Heal acts on an actual selected friendly target
-- through the existing server-only MageHeal service and spends mana.
local MYSTIC_BATTLE_HEAL = specialize_skill(
    MAGE_HEAL, "MysticBattleHeal", "Battle Heal", {
        MANA_COST = 25,
        COOLDOWN_SECONDS = 7,
        TOTAL_HEAL = 78,
        RANKS = table.freeze({
            [1] = table.freeze({TOTAL_HEAL = 78}),
            [2] = table.freeze({TOTAL_HEAL = 92}),
            [3] = table.freeze({TOTAL_HEAL = 108}),
        }),
    }
)

-- Genuine C4 level-fourteen party healing. Each target receives
-- the authored per-member rank amount and shares one mana/cooldown.
-- No free extra heal-over-time ticks may bypass party revalidation.
local MYSTIC_PARTY_HEAL = specialize_skill(
    MAGE_HEAL, "MysticPartyHeal", "Party Heal", {
        PARTY_HEAL = true,
        MANA_COST = 28,
        COOLDOWN_SECONDS = 12,
        RANGE_STUDS = 24,
        TOTAL_HEAL = 34,
        HUMAN_INSTANT_FRACTION = 1,
        ELF_INSTANT_FRACTION = 1,
        HUMAN_HOT_SECONDS = 0,
        ELF_HOT_SECONDS = 0,
        RANKS = table.freeze({
            [1] = table.freeze({TOTAL_HEAL = 34}),
            [2] = table.freeze({TOTAL_HEAL = 44}),
            [3] = table.freeze({TOTAL_HEAL = 56}),
        }),
    }
)

-- The source C4 Mage level-seven cure spends mana and removes only
-- an authenticated friendly poison at or below the authored tier.
local MYSTIC_CURE_POISON = specialize_skill(
    MAGE_HEAL, "MysticCurePoison", "Cure Poison", {
        MANA_COST = 10,
        COOLDOWN_SECONDS = 5,
        TOTAL_HEAL = 0,
        CURE_POISON_TIER = 3,
        RANKS = table.freeze({
            [1] = table.freeze({CURE_POISON_TIER = 3}),
        }),
    }
)

-- Elven Scout Poison Recovery uses the same authenticated cleanse
-- executor but cannot be redirected to another player's character.
local ELVEN_SCOUT_POISON_RECOVERY = specialize_skill(
    MAGE_HEAL, "ElvenScoutPoisonRecovery", "Poison Recovery", {
        SELF_ONLY = true,
        MANA_COST = 10,
        COOLDOWN_SECONDS = 6,
        TOTAL_HEAL = 0,
        CURE_POISON_TIER = 3,
        RANKS = table.freeze({
            [1] = table.freeze({CURE_POISON_TIER = 3}),
        }),
    }
)

-- Real server-confirmed human Mystic life drain. The NPC must lose
-- health before the attacker receives any heal from the same hit.
local MYSTIC_LIFE_DRAIN = specialize_skill(
    WIND_STRIKE, "MysticLifeDrain", "Life Drain", {
        MANA_COST = 17,
        COOLDOWN_SECONDS = 5,
        BASE_DAMAGE = 17,
        LIFE_DRAIN_FRACTION = 0.20,
        RANKS = table.freeze({
            [1] = table.freeze({
                BASE_DAMAGE = 17, LIFE_DRAIN_FRACTION = 0.20,
            }),
            [2] = table.freeze({
                BASE_DAMAGE = 23, LIFE_DRAIN_FRACTION = 0.30,
            }),
        }),
    }
)

-- Human Mystic C4 level-seven poison curse: only a genuine NPC
-- projectile hit may start bounded, non-stacking periodic damage.
local MYSTIC_POISON_CURSE = specialize_skill(
    WIND_STRIKE, "MysticPoisonCurse", "Poison Curse", {
        MANA_COST = 15,
        COOLDOWN_SECONDS = 10,
        BASE_DAMAGE = 3,
        POISON_TICK_DAMAGE = 4,
        POISON_TICK_COUNT = 3,
        POISON_TICK_SECONDS = 1,
        POISON_TIER = 1,
        RANKS = table.freeze({
            [1] = table.freeze({
                BASE_DAMAGE = 3,
                POISON_TICK_DAMAGE = 4,
                POISON_TICK_COUNT = 3,
                POISON_TICK_SECONDS = 1,
                POISON_TIER = 1,
            }),
        }),
    }
)

-- Physical attack power and attack frequency are separate server
-- effects, triggered exclusively after a genuine NPC projectile hit.
local MYSTIC_FEEBLE_CURSE = specialize_skill(
    WIND_STRIKE, "MysticFeebleCurse", "Feeble Curse", {
        MANA_COST = 16,
        COOLDOWN_SECONDS = 9,
        BASE_DAMAGE = 3,
        DEBUFF_POWER_FRACTION = 0.20,
        DEBUFF_SECONDS = 6,
        RANKS = table.freeze({
            [1] = table.freeze({
                BASE_DAMAGE = 3,
                DEBUFF_POWER_FRACTION = 0.20,
                DEBUFF_SECONDS = 6,
            }),
        }),
    }
)

local ELVEN_MYSTIC_LANGUOR = specialize_skill(
    WIND_STRIKE, "ElvenMysticLanguor", "Languor", {
        MANA_COST = 16,
        COOLDOWN_SECONDS = 9,
        BASE_DAMAGE = 3,
        DEBUFF_RATE_FRACTION = 0.20,
        DEBUFF_SECONDS = 6,
        RANKS = table.freeze({
            [1] = table.freeze({
                BASE_DAMAGE = 3,
                DEBUFF_RATE_FRACTION = 0.20,
                DEBUFF_SECONDS = 6,
            }),
        }),
    }
)

-- Each authentic server projectile applies a real non-stacking slow
-- only after impact on a living NPC. All four source ranks improve it.
local MYSTIC_FROST_BOLT = specialize_skill(
    WIND_STRIKE, "MysticFrostBolt", "Mystic Frost Bolt", {
        MANA_COST = 14,
        COOLDOWN_SECONDS = 5,
        BASE_DAMAGE = 9,
        MAGIC_SLOW_FRACTION = 0.20,
        MAGIC_SLOW_SECONDS = 2,
        RANKS = table.freeze({
            [1] = table.freeze({
                BASE_DAMAGE = 9,
                MAGIC_SLOW_FRACTION = 0.2,
                MAGIC_SLOW_SECONDS = 2,
            }),
            [2] = table.freeze({
                BASE_DAMAGE = 11,
                MAGIC_SLOW_FRACTION = 0.24,
                MAGIC_SLOW_SECONDS = 2.5,
            }),
            [3] = table.freeze({
                BASE_DAMAGE = 14,
                MAGIC_SLOW_FRACTION = 0.28,
                MAGIC_SLOW_SECONDS = 3,
            }),
            [4] = table.freeze({
                BASE_DAMAGE = 17,
                MAGIC_SLOW_FRACTION = 0.32,
                MAGIC_SLOW_SECONDS = 3.5,
            }),
        }),
    }
)

-- Elven first-tier Fighter's C4 level-15 self-regeneration.
-- The authenticated MageHeal executor handles the immediate and HoT
-- portions without requiring a Mage's wand or cross-class access.
local ELVEN_FIGHTER_RENEWAL = specialize_skill(
    MAGE_HEAL, "ElvenFighterRenewal", "Elemental Renewal", {
        SELF_ONLY = true,
        MANA_COST = 12,
        COOLDOWN_SECONDS = 7,
        TOTAL_HEAL = 22,
        ELF_INSTANT_FRACTION = 0.20,
        ELF_HOT_SECONDS = 4.5,
        HOT_TICK_SECONDS = 0.75,
        RANKS = table.freeze({
            [1] = table.freeze({TOTAL_HEAL = 22}),
            [2] = table.freeze({TOTAL_HEAL = 27}),
            [3] = table.freeze({TOTAL_HEAL = 32}),
        }),
    }
)

local ELVENFIGHTERGUARD = specialize_skill(
    MAGE_HEAL, "ElvenFighterGuard", "Elven Guard Aura", {
        KIND = "Buff",
        SELF_ONLY = true,
        MANA_COST = 12,
        STAMINA_COST = 0,
        COOLDOWN_SECONDS = 15,
        BUFF_KIND = "PhysicalGuard",
        BUFF_MAGNITUDE = 0.035,
        BUFF_SECONDS = 12,
        WIND_UP_SECONDS = 0.20,
        ACTIVE_SECONDS = 0.10,
        RECOVERY_SECONDS = 0.25,
        RANKS = table.freeze({
            [1] = table.freeze({
                BUFF_MAGNITUDE = 0.035,
                BUFF_SECONDS = 12,
            }),
        }),
    }
)

local ELVENFIGHTERBATTLECRY = specialize_skill(
    MAGE_HEAL, "ElvenFighterBattleCry", "Elven Battle Cry", {
        KIND = "Buff",
        SELF_ONLY = true,
        MANA_COST = 10,
        STAMINA_COST = 0,
        COOLDOWN_SECONDS = 15,
        BUFF_KIND = "PhysicalPower",
        BUFF_MAGNITUDE = 0.05,
        BUFF_SECONDS = 12,
        WIND_UP_SECONDS = 0.20,
        ACTIVE_SECONDS = 0.10,
        RECOVERY_SECONDS = 0.25,
        RANKS = table.freeze({
            [1] = table.freeze({
                BUFF_MAGNITUDE = 0.05,
                BUFF_SECONDS = 12,
            }),
        }),
    }
)

local MYSTICBATTLECHANT = specialize_skill(
    MAGE_HEAL, "MysticBattleChant", "Mystic Battle Chant", {
        KIND = "Buff",
        SELF_ONLY = true,
        MANA_COST = 12,
        STAMINA_COST = 0,
        COOLDOWN_SECONDS = 15,
        BUFF_KIND = "PhysicalPower",
        BUFF_MAGNITUDE = 0.05,
        BUFF_SECONDS = 12,
        WIND_UP_SECONDS = 0.20,
        ACTIVE_SECONDS = 0.10,
        RECOVERY_SECONDS = 0.25,
        RANKS = table.freeze({
            [1] = table.freeze({
                BUFF_MAGNITUDE = 0.05,
                BUFF_SECONDS = 12,
            }),
        }),
    }
)

local MYSTICSTONESKIN = specialize_skill(
    MAGE_HEAL, "MysticStoneSkin", "Mystic Stone Skin", {
        KIND = "Buff",
        SELF_ONLY = true,
        MANA_COST = 12,
        STAMINA_COST = 0,
        COOLDOWN_SECONDS = 15,
        BUFF_KIND = "PhysicalGuard",
        BUFF_MAGNITUDE = 0.06,
        BUFF_SECONDS = 12,
        WIND_UP_SECONDS = 0.20,
        ACTIVE_SECONDS = 0.10,
        RECOVERY_SECONDS = 0.25,
        RANKS = table.freeze({
            [1] = table.freeze({
                BUFF_MAGNITUDE = 0.06,
                BUFF_SECONDS = 12,
            }),
        }),
    }
)

-- A purchased C4 Scout active evasion buff: real temporary server
-- status, with no permanent benefit when not cast or after expiry.
local SCOUT_EVASIVE_FOCUS = specialize_skill(
    MAGE_HEAL, "ScoutEvasiveFocus", "Evasive Focus", {
        KIND = "Buff",
        SELF_ONLY = true,
        MANA_COST = 0,
        STAMINA_COST = 18,
        COOLDOWN_SECONDS = 28,
        BUFF_KIND = "Evasion",
        BUFF_MAGNITUDE = 0.14,
        BUFF_SECONDS = 7,
        WIND_UP_SECONDS = 0.12,
        ACTIVE_SECONDS = 0.08,
        RECOVERY_SECONDS = 0.22,
        RANKS = table.freeze({
            [1] = table.freeze({
                BUFF_MAGNITUDE = 0.14, BUFF_SECONDS = 7,
            }),
        }),
    }
)

-- Source C4 Elven Scout self-defence uses the same real server
-- guard status that reduces incoming physical NPC melee damage.
local ELVEN_SCOUT_GUARD = specialize_skill(
    MAGE_HEAL, "ElvenScoutGuard", "Elven Scout Guard", {
        KIND = "Buff",
        SELF_ONLY = true,
        MANA_COST = 9,
        STAMINA_COST = 0,
        COOLDOWN_SECONDS = 22,
        BUFF_KIND = "PhysicalGuard",
        BUFF_MAGNITUDE = 0.07,
        BUFF_SECONDS = 12,
        WIND_UP_SECONDS = 0.16,
        ACTIVE_SECONDS = 0.08,
        RECOVERY_SECONDS = 0.22,
        RANKS = table.freeze({
            [1] = table.freeze({
                BUFF_MAGNITUDE = 0.07, BUFF_SECONDS = 12,
            }),
        }),
    }
)

-- Real Elf Scout self-heal: no friendly-player selection or free HoT.
local ELVEN_SCOUT_CURE_WOUNDS = specialize_skill(
    MAGE_HEAL, "ElvenScoutCureWounds", "Cure Wounds", {
        SELF_ONLY = true,
        MANA_COST = 12,
        COOLDOWN_SECONDS = 10,
        RANGE_STUDS = 12,
        TOTAL_HEAL = 42,
        HUMAN_INSTANT_FRACTION = 1,
        ELF_INSTANT_FRACTION = 1,
        HUMAN_HOT_SECONDS = 0,
        ELF_HOT_SECONDS = 0,
        RANKS = table.freeze({
            [1] = table.freeze({TOTAL_HEAL = 42}),
        }),
    }
)

-- The existing authoritative buff executor consumes resources on use.
local ELVEN_SCOUT_BATTLE_FOCUS = specialize_skill(
    MAGE_HEAL, "ElvenScoutBattleFocus", "Battle Focus", {
        KIND = "Buff",
        SELF_ONLY = true,
        MANA_COST = 0,
        STAMINA_COST = 14,
        COOLDOWN_SECONDS = 22,
        BUFF_KIND = "PhysicalPower",
        BUFF_MAGNITUDE = 0.08,
        BUFF_SECONDS = 10,
        WIND_UP_SECONDS = 0.14,
        ACTIVE_SECONDS = 0.08,
        RECOVERY_SECONDS = 0.22,
        RANKS = table.freeze({
            [1] = table.freeze({
                BUFF_MAGNITUDE = 0.08,
                BUFF_SECONDS = 10,
            }),
        }),
    }
)

-- A distinct cast-only movement buff, never a second speed passive.
local ELVEN_SCOUT_WIND_RUN = specialize_skill(
    MAGE_HEAL, "ElvenScoutWindRun", "Wind Run", {
        KIND = "Buff",
        SELF_ONLY = true,
        MANA_COST = 0,
        STAMINA_COST = 16,
        COOLDOWN_SECONDS = 24,
        BUFF_KIND = "Movement",
        BUFF_MAGNITUDE = 0.10,
        BUFF_SECONDS = 10,
        WIND_UP_SECONDS = 0.14,
        ACTIVE_SECONDS = 0.08,
        RECOVERY_SECONDS = 0.22,
        RANKS = table.freeze({
            [1] = table.freeze({
                BUFF_MAGNITUDE = 0.10,
                BUFF_SECONDS = 10,
            }),
        }),
    }
)

-- Human Rogue source Sprint runs through actual combat movement and
-- stamina/cooldown authorization, not client-written WalkSpeed.
local HUMAN_SCOUT_SPRINT = specialize_skill(
    ELVEN_SCOUT_WIND_RUN, "HumanScoutSprint", "Sprint", {
        STAMINA_COST = 20,
        COOLDOWN_SECONDS = 28,
        BUFF_MAGNITUDE = 0.18,
        BUFF_SECONDS = 7,
        RANKS = table.freeze({
            [1] = table.freeze({
                BUFF_MAGNITUDE = 0.18,
                BUFF_SECONDS = 7,
            }),
        }),
    }
)

-- Independently authored first-transfer blade strike shares the
-- server-side dagger hit window; rank two increases actual hit damage.
local ASHENBLADE_OPENING = specialize_skill(
    FIGHTER_DAGGER_STRIKE, "AshenbladeOpening", "Ashen Opening", {
        STAMINA_COST = 19,
        COOLDOWN_SECONDS = 8,
        BASE_DAMAGE = 20,
        REAR_MULTIPLIER = 1.1,
        RANKS = table.freeze({
            [1] = table.freeze({BASE_DAMAGE = 20}),
            [2] = table.freeze({BASE_DAMAGE = 27}),
        }),
    }
)

-- Greenward's two purchased renewal ranks perform a real personal
-- health restore through the established server-owned heal executor.
local GREENWARD_RENEWAL = specialize_skill(
    ELVEN_SCOUT_CURE_WOUNDS, "GreenwardRenewal", "Greenward Renewal", {
        MANA_COST = 16,
        COOLDOWN_SECONDS = 16,
        TOTAL_HEAL = 35,
        RANKS = table.freeze({
            [1] = table.freeze({TOTAL_HEAL = 35}),
            [2] = table.freeze({TOTAL_HEAL = 52}),
        }),
    }
)

-- Both first-transfer classes have an independently authored bow and
-- dagger training line. Each purchased rank changes real server damage;
-- existing combat projectiles and melee hit authority stay unchanged.
local WAYFINDER_ARROW = specialize_skill(
    FIGHTER_BOW_SHOT, "WayfinderArrow", "Wayfinder Arrow", {
        STAMINA_COST = 17,
        COOLDOWN_SECONDS = 6,
        BASE_DAMAGE = 22,
        RANKS = table.freeze({
            [1] = table.freeze({BASE_DAMAGE = 22}),
            [2] = table.freeze({BASE_DAMAGE = 25}),
            [3] = table.freeze({BASE_DAMAGE = 28}),
            [4] = table.freeze({BASE_DAMAGE = 31}),
            [5] = table.freeze({BASE_DAMAGE = 34}),
            [6] = table.freeze({BASE_DAMAGE = 37}),
            [7] = table.freeze({BASE_DAMAGE = 40}),
            [8] = table.freeze({BASE_DAMAGE = 43}),
            [9] = table.freeze({BASE_DAMAGE = 46}),
        }),
    }
)

local WAYFINDER_CUT = specialize_skill(
    FIGHTER_DAGGER_STRIKE, "WayfinderCut", "Wayfinder Cut", {
        STAMINA_COST = 17,
        COOLDOWN_SECONDS = 6,
        BASE_DAMAGE = 23,
        RANKS = table.freeze({
            [1] = table.freeze({BASE_DAMAGE = 23}),
            [2] = table.freeze({BASE_DAMAGE = 26}),
            [3] = table.freeze({BASE_DAMAGE = 29}),
            [4] = table.freeze({BASE_DAMAGE = 32}),
            [5] = table.freeze({BASE_DAMAGE = 35}),
            [6] = table.freeze({BASE_DAMAGE = 38}),
            [7] = table.freeze({BASE_DAMAGE = 41}),
            [8] = table.freeze({BASE_DAMAGE = 44}),
            [9] = table.freeze({BASE_DAMAGE = 47}),
        }),
    }
)

-- The authenticated existing bleed executor applies wound ticks
-- only after a real dagger hit; a missed swing cannot apply the status.
local WAYFINDER_WOUND = specialize_skill(
    LACERATING_CUT, "WayfinderWound", "Wayfinder Wound", {
        BASE_DAMAGE = 8,
        BLEED_TICK_DAMAGE = 3,
        RANKS = table.freeze({
            [1] = table.freeze({
                BASE_DAMAGE = 8, BLEED_TICK_DAMAGE = 3,
            }),
        }),
    }
)

-- The original Greenward calming arrow preserves the server-owned
-- threat-reduction-on-hit contract in nine independently bought ranks.
local GREENWARD_CALMING_ARROW = specialize_skill(
    ELVEN_CALMING_SHOT, "GreenwardCalmingArrow",
    "Greenward Calming Arrow", {
        BASE_DAMAGE = 9,
        THREAT_REDUCTION_FRACTION = 0.10,
        RANKS = table.freeze({
            [1] = table.freeze({
                BASE_DAMAGE = 9,
                THREAT_REDUCTION_FRACTION = 0.100,
            }),
            [2] = table.freeze({
                BASE_DAMAGE = 10,
                THREAT_REDUCTION_FRACTION = 0.125,
            }),
            [3] = table.freeze({
                BASE_DAMAGE = 11,
                THREAT_REDUCTION_FRACTION = 0.150,
            }),
            [4] = table.freeze({
                BASE_DAMAGE = 12,
                THREAT_REDUCTION_FRACTION = 0.175,
            }),
            [5] = table.freeze({
                BASE_DAMAGE = 13,
                THREAT_REDUCTION_FRACTION = 0.200,
            }),
            [6] = table.freeze({
                BASE_DAMAGE = 14,
                THREAT_REDUCTION_FRACTION = 0.225,
            }),
            [7] = table.freeze({
                BASE_DAMAGE = 15,
                THREAT_REDUCTION_FRACTION = 0.250,
            }),
            [8] = table.freeze({
                BASE_DAMAGE = 16,
                THREAT_REDUCTION_FRACTION = 0.275,
            }),
            [9] = table.freeze({
                BASE_DAMAGE = 17,
                THREAT_REDUCTION_FRACTION = 0.300,
            }),
        }),
    }
)

-- Prepared original Human Warrior combat. No source quest or real
-- mentor is available yet, so normal clients cannot learn this skill.
local IRONVOW_DRIVING_STRIKE = specialize_skill(
    IRON_CLEAVE, "IronvowDrivingStrike", "Ironvow Driving Strike", {
        STAMINA_COST = 21,
        COOLDOWN_SECONDS = 7,
        BASE_DAMAGE = 25,
        RANKS = table.freeze({
            [1] = table.freeze({BASE_DAMAGE = 25}),
            [2] = table.freeze({BASE_DAMAGE = 28}),
            [3] = table.freeze({BASE_DAMAGE = 31}),
            [4] = table.freeze({BASE_DAMAGE = 34}),
            [5] = table.freeze({BASE_DAMAGE = 37}),
            [6] = table.freeze({BASE_DAMAGE = 40}),
            [7] = table.freeze({BASE_DAMAGE = 43}),
            [8] = table.freeze({BASE_DAMAGE = 46}),
            [9] = table.freeze({BASE_DAMAGE = 49}),
        }),
    }
)

-- C4 Warrior's source Wild Sweep family is a real polearm-only
-- area skill with 9 separately purchased levels and MP on use.
-- Original 90..191 skill power is *not* Roblox HP damage; the
-- 0.15 conversion below is provisional pending full C4 P.Atk maths.
-- C4 physical AoE has a separate 20-target PvE cap, not the
-- normal polearm five/ten-target basic swing.
local IRONVOW_CRESCENT_SWEEP = specialize_skill(
    ARC_SLASH, "IronvowCrescentSweep", "Crescent Sweep", {
        STAMINA_COST = 0, MANA_COST = 22,
        COOLDOWN_SECONDS = 8,
        FORWARD_STEP_STUDS = 0.6,
        REACH_STUDS = 7.0, ARC_DEGREES = 125,
        HITBOX = table.freeze({
            SIZE = Vector3.new(12.0, 5.0, 8.0),
            FORWARD_OFFSET = 3.5,
            SAMPLE_COUNT = 4,
        }),
        MAX_TARGETS = 20, BASE_DAMAGE = 13.5,
        SOURCE_POWER = 90, STAGGER_SECONDS = 0,
        RANKS = table.freeze({
            [1] = table.freeze({
                SOURCE_POWER = 90, MANA_COST = 22,
                BASE_DAMAGE = 13.5,
            }),
            [2] = table.freeze({
                SOURCE_POWER = 97, MANA_COST = 22,
                BASE_DAMAGE = 14.55,
            }),
            [3] = table.freeze({
                SOURCE_POWER = 105, MANA_COST = 22,
                BASE_DAMAGE = 15.75,
            }),
            [4] = table.freeze({
                SOURCE_POWER = 123, MANA_COST = 23,
                BASE_DAMAGE = 18.45,
            }),
            [5] = table.freeze({
                SOURCE_POWER = 132, MANA_COST = 24,
                BASE_DAMAGE = 19.8,
            }),
            [6] = table.freeze({
                SOURCE_POWER = 143, MANA_COST = 25,
                BASE_DAMAGE = 21.45,
            }),
            [7] = table.freeze({
                SOURCE_POWER = 165, MANA_COST = 27,
                BASE_DAMAGE = 24.75,
            }),
            [8] = table.freeze({
                SOURCE_POWER = 177, MANA_COST = 29,
                BASE_DAMAGE = 26.55,
            }),
            [9] = table.freeze({
                SOURCE_POWER = 191, MANA_COST = 30,
                BASE_DAMAGE = 28.65,
            }),
        }),
    }
)

-- Source C4 Warrior Stun Attack family: single-target blunt damage
-- plus non-refreshable shock, with nine source MP/power ranks.
-- Original source "cannot be stunned again while dazed" is enforced
-- for this ability by checking the existing authoritative stagger.
-- 1.1s PvE shock and power*0.3 Roblox HP are provisional adapters,
-- NOT original C4 crowd-control duration or damage formula.
local IRONVOW_STONEBREAKER = specialize_skill(
    IRON_CLEAVE, "IronvowStonebreaker", "Stonebreaker", {
        STAMINA_COST = 0, MANA_COST = 22,
        COOLDOWN_SECONDS = 9, MAX_TARGETS = 1,
        FORWARD_STEP_STUDS = 0.4,
        REACH_STUDS = 5.2, ARC_DEGREES = 75,
        HITBOX = table.freeze({
            SIZE = Vector3.new(6.0, 5.0, 5.2),
            FORWARD_OFFSET = 2.6,
            SAMPLE_COUNT = 3,
        }),
        BASE_DAMAGE = 9, SOURCE_POWER = 30,
        STAGGER_SECONDS = 1.1, NO_STAGGER_REFRESH = true,
        RANKS = table.freeze({
            [1] = table.freeze({
                SOURCE_POWER = 30, MANA_COST = 22,
                BASE_DAMAGE = 9,
                STAGGER_SECONDS = 1.1,
            }),
            [2] = table.freeze({
                SOURCE_POWER = 33, MANA_COST = 22,
                BASE_DAMAGE = 9.9,
                STAGGER_SECONDS = 1.1,
            }),
            [3] = table.freeze({
                SOURCE_POWER = 35, MANA_COST = 22,
                BASE_DAMAGE = 10.5,
                STAGGER_SECONDS = 1.1,
            }),
            [4] = table.freeze({
                SOURCE_POWER = 41, MANA_COST = 23,
                BASE_DAMAGE = 12.3,
                STAGGER_SECONDS = 1.1,
            }),
            [5] = table.freeze({
                SOURCE_POWER = 44, MANA_COST = 24,
                BASE_DAMAGE = 13.2,
                STAGGER_SECONDS = 1.1,
            }),
            [6] = table.freeze({
                SOURCE_POWER = 48, MANA_COST = 25,
                BASE_DAMAGE = 14.4,
                STAGGER_SECONDS = 1.1,
            }),
            [7] = table.freeze({
                SOURCE_POWER = 55, MANA_COST = 27,
                BASE_DAMAGE = 16.5,
                STAGGER_SECONDS = 1.1,
            }),
            [8] = table.freeze({
                SOURCE_POWER = 59, MANA_COST = 29,
                BASE_DAMAGE = 17.7,
                STAGGER_SECONDS = 1.1,
            }),
            [9] = table.freeze({
                SOURCE_POWER = 64, MANA_COST = 30,
                BASE_DAMAGE = 19.2,
                STAGGER_SECONDS = 1.1,
            }),
        }),
    }
)

local IRONVOW_BATTLE_CALL = specialize_skill(
    ELVEN_SCOUT_BATTLE_FOCUS, "IronvowBattleCall",
    "Ironvow Battle Call", {
        STAMINA_COST = 18,
        COOLDOWN_SECONDS = 25,
        BUFF_MAGNITUDE = 0.08,
        BUFF_SECONDS = 12,
        RANKS = table.freeze({
            [1] = table.freeze({
                BUFF_MAGNITUDE = 0.08, BUFF_SECONDS = 12,
            }),
            [2] = table.freeze({
                BUFF_MAGNITUDE = 0.10, BUFF_SECONDS = 12,
            }),
            [3] = table.freeze({
                BUFF_MAGNITUDE = 0.12, BUFF_SECONDS = 12,
            }),
        }),
    }
)

-- The Knight's seven C4 source-banded drain ranks reuse the already
-- authenticated magic projectile and 20%-of-dealt-damage owner heal.
-- Power/MP per rank follow the recorded C4 reference; actual Roblox
-- target, casting, scaling and animation still need equivalence checks.
local OATHGUARD_UMBRAL_SIPHON = specialize_skill(
    WIND_STRIKE, "OathguardUmbralSiphon", "Umbral Siphon", {
        MANA_COST = 12,
        COOLDOWN_SECONDS = 4,
        WIND_UP_SECONDS = 3,
        BASE_DAMAGE = 20,
        LIFE_DRAIN_FRACTION = 0.20,
        RANKS = table.freeze({
            [1] = table.freeze({
                BASE_DAMAGE = 20, MANA_COST = 12,
            }),
            [2] = table.freeze({
                BASE_DAMAGE = 22, MANA_COST = 13,
            }),
            [3] = table.freeze({
                BASE_DAMAGE = 24, MANA_COST = 14,
            }),
            [4] = table.freeze({
                BASE_DAMAGE = 26, MANA_COST = 15,
            }),
            [5] = table.freeze({
                BASE_DAMAGE = 28, MANA_COST = 15,
            }),
            [6] = table.freeze({
                BASE_DAMAGE = 29, MANA_COST = 17,
            }),
            [7] = table.freeze({
                BASE_DAMAGE = 31, MANA_COST = 17,
            }),
        }),
    }
)

-- C4's separate level-20 Knight stance gives 7% physical defence
-- at a two-point Evasion penalty; it is NOT immobile Ultimate Defence.
-- Source P.Def/Evasion units still need conversion to Roblox stat formulas.
local OATHGUARD_STEADFAST_STANCE = specialize_skill(
    ELVEN_SCOUT_GUARD, "OathguardSteadfastStance",
    "Oathguard Steadfast Stance", {
        MANA_COST = 10,
        STAMINA_COST = 0,
        COOLDOWN_SECONDS = 3,
        BUFF_MAGNITUDE = 0.07,
        BUFF_SECONDS = 300,
        EVASION_PENALTY_POINTS = 2,
        RANKS = table.freeze({
            [1] = table.freeze({
                BUFF_MAGNITUDE = 0.07, BUFF_SECONDS = 300,
            }),
        }),
    }
)

-- A distinct C4 Ultimate Defence analogue: +1800 physical and
-- +1350 magic DEF source statistics, immobilised for 30 seconds.
-- The current Roblox combat reduction conversion is provisional;
-- the source numbers are retained separately for future exact formulas.
local OATHGUARD_LAST_BASTION = specialize_skill(
    ELVEN_SCOUT_GUARD, "OathguardLastBastion",
    "Oathguard Last Bastion", {
        MANA_COST = 19,
        STAMINA_COST = 0,
        COOLDOWN_SECONDS = 1800,
        BUFF_KIND = "Fortress",
        BUFF_MAGNITUDE = 0.35,
        BUFF_SECONDS = 30,
        SOURCE_PHYSICAL_DEFENCE = 1800,
        SOURCE_MAGIC_DEFENCE = 1350,
        IMMOBILIZES_CASTER = true,
        RANKS = table.freeze({
            [1] = table.freeze({
                BUFF_MAGNITUDE = 0.35,
                BUFF_SECONDS = 30,
            }),
        }),
    }
)

-- C4 Deflect Arrow effect ranks 1/2 are separate anti-bow defence,
-- not regular melee armour; MP22/28 and source bow attributes -16/-19.
-- Roblox's 16/19 percent incoming bow-damage translation is provisional.
local OATHGUARD_ARROW_WARD = specialize_skill(
    ELVEN_SCOUT_GUARD, "OathguardArrowWard",
    "Oathguard Arrow Ward", {
        MANA_COST = 22,
        STAMINA_COST = 0,
        COOLDOWN_SECONDS = 3,
        BUFF_KIND = "BowGuard",
        BUFF_MAGNITUDE = 0.16,
        BUFF_SECONDS = 1200,
        SOURCE_BOW_DEFENCE_ATTRIBUTE = -16,
        RANKS = table.freeze({
            [1] = table.freeze({
                MANA_COST = 22, BUFF_MAGNITUDE = 0.16,
                SOURCE_BOW_DEFENCE_ATTRIBUTE = -16,
            }),
            [2] = table.freeze({
                MANA_COST = 28, BUFF_MAGNITUDE = 0.19,
                SOURCE_BOW_DEFENCE_ATTRIBUTE = -19,
            }),
        }),
    }
)

-- Oathguard's personal recovery uses the existing server-owned heal
-- executor; no client-selected healing target or arbitrary HP amount.
local OATHGUARD_MENDING_OATH = specialize_skill(
    ELVEN_SCOUT_CURE_WOUNDS, "OathguardMendingOath",
    "Oathguard Mending Oath", {
        SELF_ONLY = true,
        MANA_COST = 15,
        COOLDOWN_SECONDS = 18,
        TOTAL_HEAL = 30,
        RANKS = table.freeze({
            [1] = table.freeze({TOTAL_HEAL = 30}),
            [2] = table.freeze({TOTAL_HEAL = 37}),
            [3] = table.freeze({TOTAL_HEAL = 44}),
        }),
    }
)

-- Original Oathguard shield impacts and zero-damage taunts share the
-- real authenticated melee and threat executors. A usable impact must
-- also pass the runtime's server-owned offhand Shield equipment gate.
local OATHGUARD_SHIELD_IMPACT = specialize_skill(
    SHIELD_BASH, "OathguardShieldImpact", "Stonewatch Impact", {
        STAMINA_COST = 19,
        COOLDOWN_SECONDS = 6,
        BASE_DAMAGE = 7,
        RANKS = table.freeze({
            [1] = table.freeze({
                BASE_DAMAGE = 7,
                STAGGER_SECONDS = 0.70,
            }),
            [2] = table.freeze({
                BASE_DAMAGE = 9,
                STAGGER_SECONDS = 0.80,
            }),
            [3] = table.freeze({
                BASE_DAMAGE = 11,
                STAGGER_SECONDS = 0.90,
            }),
            [4] = table.freeze({
                BASE_DAMAGE = 13,
                STAGGER_SECONDS = 1.00,
            }),
            [5] = table.freeze({
                BASE_DAMAGE = 15,
                STAGGER_SECONDS = 1.10,
            }),
            [6] = table.freeze({
                BASE_DAMAGE = 17,
                STAGGER_SECONDS = 1.20,
            }),
            [7] = table.freeze({
                BASE_DAMAGE = 19,
                STAGGER_SECONDS = 1.30,
            }),
            [8] = table.freeze({
                BASE_DAMAGE = 21,
                STAGGER_SECONDS = 1.40,
            }),
            [9] = table.freeze({
                BASE_DAMAGE = 23,
                STAGGER_SECONDS = 1.50,
            }),
        }),
    }
)

local OATHGUARD_CHALLENGE = specialize_skill(
    TAUNT, "OathguardChallenge", "Oathguard Challenge", {
        COOLDOWN_SECONDS = 10,
        BASE_DAMAGE = 0,
        TAUNT_BONUS_THREAT = 24,
        RANKS = table.freeze({
            [1] = table.freeze({
                TAUNT_BONUS_THREAT = 24,
            }),
            [2] = table.freeze({
                TAUNT_BONUS_THREAT = 31,
            }),
            [3] = table.freeze({
                TAUNT_BONUS_THREAT = 38,
            }),
            [4] = table.freeze({
                TAUNT_BONUS_THREAT = 45,
            }),
            [5] = table.freeze({
                TAUNT_BONUS_THREAT = 52,
            }),
            [6] = table.freeze({
                TAUNT_BONUS_THREAT = 59,
            }),
        }),
    }
)

-- A genuine longbow impact applies slow through RangerCombatService.
local ELVEN_SCOUT_SNARING_SHOT = specialize_skill(
    CRIPPLING_SHOT, "ElvenScoutSnaringShot", "Snaring Shot", {
        STAMINA_COST = 24,
        COOLDOWN_SECONDS = 11,
        BASE_DAMAGE = 14,
        HUMAN_SLOW_FRACTION = 0,
        HUMAN_SLOW_SECONDS = 0,
        ELF_SLOW_FRACTION = 0.35,
        ELF_SLOW_SECONDS = 4,
        RANKS = table.freeze({
            [1] = table.freeze({BASE_DAMAGE = 14}),
        }),
    }
)

-- Genuine on/off C4 power stance: source-banded critical damage
-- and continuous stamina upkeep, not a one-off timed buff.
-- C4 source Vicious Stance tiers: +35/+48/+64 critical power,
-- 4/5/5 MP on activation and continuous MP consumption.
-- This temporary Roblox adapter converts original *flat* critical
-- power into a bounded multiplier; original C4 damage math is pending.
local IRONVOW_CRITICAL_STANCE: IronvowCriticalToggleSkillDefinition =
    table.freeze({
        KIND = "IronvowCriticalToggle",
        ID = "IronvowCriticalStance",
        DISPLAY_NAME = "Ironvow Critical Stance",
        STAMINA_COST = 0,
        MANA_COST = 4,
        COOLDOWN_SECONDS = 0,
        CRITICAL_DAMAGE_BONUS = 0.035,
        SOURCE_CRITICAL_POWER = 35,
        UPKEEP_MANA_PER_SECOND = 2,
        RANKS = table.freeze({
            [1] = table.freeze({
                MANA_COST = 4,
                SOURCE_CRITICAL_POWER = 35,
                CRITICAL_DAMAGE_BONUS = 0.035,
            }),
            [2] = table.freeze({
                MANA_COST = 5,
                SOURCE_CRITICAL_POWER = 48,
                CRITICAL_DAMAGE_BONUS = 0.048,
            }),
            [3] = table.freeze({
                MANA_COST = 5,
                SOURCE_CRITICAL_POWER = 64,
                CRITICAL_DAMAGE_BONUS = 0.064,
            }),
        }),
    })

local SCOUT_CRITICAL_POWER_TOGGLE: ScoutToggleSkillDefinition =
    table.freeze({
        KIND = "ScoutToggle",
        ID = "ScoutCriticalPowerToggle",
        DISPLAY_NAME = "Critical Power",
        STAMINA_COST = 3,
        COOLDOWN_SECONDS = 0,
        CRITICAL_DAMAGE_BONUS = 0.06,
        UPKEEP_STAMINA_PER_SECOND = 3,
        RANKS = table.freeze({
            [1] = table.freeze({CRITICAL_DAMAGE_BONUS = 0.06}),
            [2] = table.freeze({CRITICAL_DAMAGE_BONUS = 0.08}),
            [3] = table.freeze({CRITICAL_DAMAGE_BONUS = 0.10}),
            [4] = table.freeze({CRITICAL_DAMAGE_BONUS = 0.12}),
            [5] = table.freeze({CRITICAL_DAMAGE_BONUS = 0.14}),
        }),
    })

-- A genuine on/off C4 accuracy stance against authored NPC evasion.
-- Source C4 Warrior's single Accuracy toggle improves the source
-- Accuracy stat by 3, activation costs 1 MP and upkeep consumes MP.
-- The Roblox percentage to-hit adapter is provisional.
local IRONVOW_ACCURACY_STANCE: IronvowAccuracyToggleSkillDefinition =
    table.freeze({
        KIND = "IronvowAccuracyToggle",
        ID = "IronvowAccuracyStance",
        DISPLAY_NAME = "Ironvow Keen Aim",
        STAMINA_COST = 0,
        MANA_COST = 1,
        COOLDOWN_SECONDS = 0,
        ACCURACY_BONUS = 0.03,
        SOURCE_ACCURACY = 3,
        UPKEEP_MANA_PER_SECOND = 2,
        RANKS = table.freeze({
            [1] = table.freeze({
                ACCURACY_BONUS = 0.03,
                SOURCE_ACCURACY = 3,
                MANA_COST = 1,
            }),
        }),
    })

local SCOUT_ACCURACY_TOGGLE: ScoutAccuracyToggleSkillDefinition =
    table.freeze({
        KIND = "ScoutAccuracyToggle",
        ID = "ScoutAccuracyToggle",
        DISPLAY_NAME = "Accuracy",
        STAMINA_COST = 3,
        COOLDOWN_SECONDS = 0,
        ACCURACY_BONUS = 0.12,
        UPKEEP_STAMINA_PER_SECOND = 3,
        RANKS = table.freeze({
            [1] = table.freeze({ACCURACY_BONUS = 0.12}),
        }),
    })

local ARCANIST_EMBER = specialize_skill(
    WIND_STRIKE, "ArcanistEmber", "Arcanist Ember", {
        MANA_COST = 38,
        COOLDOWN_SECONDS = 7.5,
        BASE_DAMAGE = 45,
        RANKS = table.freeze({
            [1] = table.freeze({BASE_DAMAGE = 45}),
            [2] = table.freeze({BASE_DAMAGE = 53}),
            [3] = table.freeze({BASE_DAMAGE = 62}),
        }),
    }
)

local SPELLWEAVER_AEGIS = specialize_skill(
    ARCANE_WARD, "SpellweaverAegis", "Spellweaver Aegis", {
        MANA_COST = 35,
        COOLDOWN_SECONDS = 9,
        WARD_AMOUNT = 45,
        DURATION_SECONDS = 8,
        RANKS = table.freeze({
            [1] = table.freeze({WARD_AMOUNT = 45}),
            [2] = table.freeze({WARD_AMOUNT = 55}),
            [3] = table.freeze({WARD_AMOUNT = 67}),
        }),
    }
)

local VANGUARD_CHALLENGE = specialize_skill(
    TAUNT, "VanguardChallenge", "Vanguard Challenge", {
        COOLDOWN_SECONDS = 10,
        REACH_STUDS = 14,
        TAUNT_BONUS_THREAT = 22,
        RANKS = table.freeze({
            [1] = table.freeze({TAUNT_BONUS_THREAT = 22}),
            [2] = table.freeze({TAUNT_BONUS_THREAT = 34}),
            [3] = table.freeze({TAUNT_BONUS_THREAT = 48}),
        }),
    }
)

local THORNWARDEN_BASH = specialize_skill(
    SHIELD_BASH, "ThornwardenBash", "Thornwarden Bash", {
        COOLDOWN_SECONDS = 7,
        BASE_DAMAGE = 3,
        STAGGER_SECONDS = 1.5,
        RANKS = table.freeze({
            [1] = table.freeze({BASE_DAMAGE = 3, STAGGER_SECONDS = 1.5}),
            [2] = table.freeze({BASE_DAMAGE = 4, STAGGER_SECONDS = 1.8}),
            [3] = table.freeze({BASE_DAMAGE = 5, STAGGER_SECONDS = 2.1}),
        }),
    }
)

local SHARPSHOOTER_PIERCE = specialize_skill(
    PIERCING_SHOT, "SharpshooterPierce", "Sharpshooter Pierce", {
        COOLDOWN_SECONDS = 9,
        RANGE_STUDS = 95,
        BASE_DAMAGE = 44,
        RANKS = table.freeze({
            [1] = table.freeze({BASE_DAMAGE = 44}),
            [2] = table.freeze({BASE_DAMAGE = 50}),
            [3] = table.freeze({BASE_DAMAGE = 58}),
        }),
    }
)

local WINDRUNNER_VOLLEY = specialize_skill(
    VOLLEY, "WindrunnerVolley", "Windrunner Volley", {
        COOLDOWN_SECONDS = 7,
        RADIUS_STUDS = 8,
        INITIAL_DAMAGE = 12,
        PULSE_DAMAGE = 7,
        RANKS = table.freeze({
            [1] = table.freeze({INITIAL_DAMAGE = 12, PULSE_DAMAGE = 7}),
            [2] = table.freeze({INITIAL_DAMAGE = 14, PULSE_DAMAGE = 8}),
            [3] = table.freeze({INITIAL_DAMAGE = 16, PULSE_DAMAGE = 9}),
        }),
    }
)

local DEFINITIONS: {[string]: SkillDefinition} = table.freeze({
    ShieldBash = SHIELD_BASH,
    GuardBreaker = GUARD_BREAKER,
    IronCleave = IRON_CLEAVE,
    FighterBowShot = FIGHTER_BOW_SHOT,
    FighterDaggerStrike = FIGHTER_DAGGER_STRIKE,
    PursuitStep = PURSUIT_STEP,
    DawnWard = DAWN_WARD,
    CinderBolt = CINDER_BOLT,
    MysticWindBolt = MYSTIC_WIND_BOLT,
    MysticFrostBolt = MYSTIC_FROST_BOLT,
    ElvenFighterRenewal = ELVEN_FIGHTER_RENEWAL,
    ElvenFighterGuard = ELVENFIGHTERGUARD,
    ElvenFighterBattleCry = ELVENFIGHTERBATTLECRY,
    MysticBattleChant = MYSTICBATTLECHANT,
    MysticStoneSkin = MYSTICSTONESKIN,
    MysticHealingPrayer = MYSTIC_HEALING_PRAYER,
    MysticBattleHeal = MYSTIC_BATTLE_HEAL,
    MysticPartyHeal = MYSTIC_PARTY_HEAL,
    ScoutEvasiveFocus = SCOUT_EVASIVE_FOCUS,
    ElvenScoutGuard = ELVEN_SCOUT_GUARD,
    ElvenScoutCureWounds = ELVEN_SCOUT_CURE_WOUNDS,
    ElvenScoutBattleFocus = ELVEN_SCOUT_BATTLE_FOCUS,
    ElvenScoutWindRun = ELVEN_SCOUT_WIND_RUN,
    HumanScoutSprint = HUMAN_SCOUT_SPRINT,
    AshenbladeOpening = ASHENBLADE_OPENING,
    GreenwardRenewal = GREENWARD_RENEWAL,
    WayfinderArrow = WAYFINDER_ARROW,
    WayfinderCut = WAYFINDER_CUT,
    WayfinderWound = WAYFINDER_WOUND,
    GreenwardCalmingArrow = GREENWARD_CALMING_ARROW,
    IronvowDrivingStrike = IRONVOW_DRIVING_STRIKE,
    IronvowCrescentSweep = IRONVOW_CRESCENT_SWEEP,
    IronvowStonebreaker = IRONVOW_STONEBREAKER,
    IronvowBattleCall = IRONVOW_BATTLE_CALL,
    OathguardShieldImpact = OATHGUARD_SHIELD_IMPACT,
    OathguardMendingOath = OATHGUARD_MENDING_OATH,
    OathguardSteadfastStance = OATHGUARD_STEADFAST_STANCE,
    OathguardLastBastion = OATHGUARD_LAST_BASTION,
    OathguardArrowWard = OATHGUARD_ARROW_WARD,
    OathguardUmbralSiphon = OATHGUARD_UMBRAL_SIPHON,
    OathguardChallenge = OATHGUARD_CHALLENGE,
    ElvenScoutSnaringShot = ELVEN_SCOUT_SNARING_SHOT,
    MysticLifeDrain = MYSTIC_LIFE_DRAIN,
    MysticPoisonCurse = MYSTIC_POISON_CURSE,
    MysticFeebleCurse = MYSTIC_FEEBLE_CURSE,
    ElvenMysticLanguor = ELVEN_MYSTIC_LANGUOR,
    MysticCurePoison = MYSTIC_CURE_POISON,
    ElvenScoutPoisonRecovery = ELVEN_SCOUT_POISON_RECOVERY,
    AetherBolt = AETHER_BOLT,
    RenewingLight = RENEWING_LIGHT,
    TrackerShot = TRACKER_SHOT,
    BriarVolley = BRIAR_VOLLEY,
    ThunderShot = THUNDER_SHOT,
    ArcherDraw = ARCHER_DRAW,
    ScoutFocusedShot = SCOUT_FOCUSED_SHOT,
    ScoutCriticalPowerToggle = SCOUT_CRITICAL_POWER_TOGGLE,
    IronvowCriticalStance = IRONVOW_CRITICAL_STANCE,
    IronvowAccuracyStance = IRONVOW_ACCURACY_STANCE,
    ScoutAccuracyToggle = SCOUT_ACCURACY_TOGGLE,
    ElvenRenewal = ELVEN_RENEWAL,
    ElvenCalmingShot = ELVEN_CALMING_SHOT,
    RogueVitalBlow = ROGUE_VITAL_BLOW,
    RogueFinishingCut = ROGUE_FINISHING_CUT,
    LaceratingCut = LACERATING_CUT,
    DisruptingCut = DISRUPTING_CUT,
    ArcanistEmber = ARCANIST_EMBER,
    SpellweaverAegis = SPELLWEAVER_AEGIS,
    ViperStrike = VIPER_STRIKE,
    Taunt = TAUNT,
    VanguardChallenge = VANGUARD_CHALLENGE,
    ThornwardenBash = THORNWARDEN_BASH,
    SharpshooterPierce = SHARPSHOOTER_PIERCE,
    WindrunnerVolley = WINDRUNNER_VOLLEY,
    Mend = MEND,
    ArcSlash = ARC_SLASH,
    WindStrike = WIND_STRIKE,
    ArcaneWard = ARCANE_WARD,
    MageHeal = MAGE_HEAL,
    PiercingShot = PIERCING_SHOT,
    CripplingShot = CRIPPLING_SHOT,
    Volley = VOLLEY,
    QuickStrike = QUICK_STRIKE,
    Backstab = BACKSTAB,
    Feint = FEINT,
    ShadowDash = SHADOW_DASH,
    EvasiveStep = EVASIVE_STEP,
    ThreatDrop = THREAT_DROP,
    DuelistAmbush = DUELIST_AMBUSH,
    DuelistDeadlyBlow = DUELIST_DEADLY_BLOW,
    DuelistExposeWeakness = DUELIST_EXPOSE,
    DuelistRush = DUELIST_RUSH,
    WindstalkerFlurry = WINDSTALKER_FLURRY,
    WindstalkerSlipstream = WINDSTALKER_SLIPSTREAM,
    WindstalkerBlur = WINDSTALKER_BLUR,
    WindstalkerQuickstep = WINDSTALKER_QUICKSTEP,
})

local SkillDefinitions = {}

local function clone_definition(definition: any): any
    local copy = {}
    for key, value in pairs(definition) do
        if key ~= "RANKS" then
            copy[key] = value
        end
    end
    return copy
end

local function validate_common(definition: SkillDefinition)
    assert(definition.ID ~= "", "Skill id cannot be empty.")
    assert(definition.STAMINA_COST >= 0, "Skill Stamina cannot be negative.")
    assert(definition.COOLDOWN_SECONDS >= 0, "Cooldown cannot be negative.")
end

local function validate_timed(definition: any)
    assert(definition.WIND_UP_SECONDS >= 0, "Wind-up cannot be negative.")
    assert(definition.ACTIVE_SECONDS > 0, "Active window must be positive.")
    assert(definition.RECOVERY_SECONDS >= 0, "Recovery cannot be negative.")
    assert(
        definition.MOVEMENT_SCALE ~= nil,
        "Timed skill needs movement scale."
    )
end

local function validate_melee(definition: MeleeSkillDefinition)
    validate_timed(definition)
    assert(definition.REACH_STUDS > 0, "Skill reach must be positive.")
    assert(
        definition.ARC_DEGREES > 0 and definition.ARC_DEGREES <= 180,
        "Skill arc must be inside 0-180 degrees."
    )
    assert(definition.HITBOX.SIZE.Magnitude > 0, "Hitbox must have size.")
    assert(definition.HITBOX.SAMPLE_COUNT >= 1, "Hitbox needs a sample.")
    assert(definition.BASE_DAMAGE >= 0, "Skill damage cannot be negative.")
    assert(definition.STAGGER_SECONDS >= 0, "Stagger cannot be negative.")
    if definition.MAX_TARGETS ~= nil then
        assert(definition.MAX_TARGETS >= 1
            and definition.MAX_TARGETS % 1 == 0
            and definition.MAX_TARGETS <= 20,
            "Melee area skill target cap must be a safe integer <= 20.")
    end
    if definition.MANA_COST ~= nil then
        assert(definition.MANA_COST >= 0,
            "Melee skill mana cannot be negative.")
    end
    if definition.TAUNT_BONUS_THREAT ~= nil then
        assert(
            definition.TAUNT_BONUS_THREAT > 0
                and definition.TAUNT_BONUS_THREAT < math.huge,
            "Taunt threat must be positive and finite."
        )
    end
end

--[[
Validates the bounded self-buff contract before it reaches server combat.

Args:
    definition (BuffSkillDefinition): Authored rank-one combat buff.

Returns:
    nil: Raises on invalid kind, magnitude, expiry or resource costs.
]]
local function validate_buff(definition: BuffSkillDefinition)
    validate_timed(definition)
    assert(definition.MANA_COST >= 0,
        "Combat buff Mana cost cannot be negative.")
    assert(
        definition.BUFF_KIND == "PhysicalPower"
            or definition.BUFF_KIND == "PhysicalGuard"
            or definition.BUFF_KIND == "Fortress"
            or definition.BUFF_KIND == "BowGuard"
            or definition.BUFF_KIND == "MagicPower"
            or definition.BUFF_KIND == "Evasion"
            or definition.BUFF_KIND == "Movement",
        "Unknown authoritative combat buff kind."
    )
    assert(definition.BUFF_MAGNITUDE > 0
        and definition.BUFF_MAGNITUDE <= 0.50,
        "Combat buff magnitude must be bounded."
    )
    local max_seconds = if definition.BUFF_KIND == "BowGuard"
        then 1200
        elseif definition.BUFF_KIND == "PhysicalGuard" then 300
        else 60
    assert(definition.BUFF_SECONDS > 0
        and definition.BUFF_SECONDS <= max_seconds,
        "Combat buff duration must be bounded."
    )
end

--[[
Validates an authoritatively purchased rank and bounded upkeep contract.

Args:
    definition (ScoutToggleSkillDefinition): Real source-level stance.

Returns:
    nil: Rejects cosmetic or resource-free toggle definitions.
]]
--[[
Validates one earned Warrior's source-ranked MP critical stance.

Args:
    definition (IronvowCriticalToggleSkillDefinition): Actual source
        rank definitions supplied to the server-owned toggle.

Returns:
    nil: Rejects free, unbounded or incorrectly ordered rank stances.
]]
--[[
Validates source-owned Warrior MP Accuracy rank before server requests.

Args:
    definition (IronvowAccuracyToggleSkillDefinition): The genuine
        one-rank C4 source-stat and upkeep contract.

Returns:
    nil: Rejects free resource toggles and invalid accuracy magnitudes.
]]
local function validate_ironvow_accuracy(
    definition: IronvowAccuracyToggleSkillDefinition
)
    assert(definition.STAMINA_COST == 0
        and definition.MANA_COST == 1
        and definition.UPKEEP_MANA_PER_SECOND > 0
        and definition.UPKEEP_MANA_PER_SECOND <= 5
        and definition.SOURCE_ACCURACY == 3
        and definition.ACCURACY_BONUS > 0
        and definition.ACCURACY_BONUS <= 0.15,
        "Source Warrior Accuracy must spend MP and add bounded hit chance.")
end

local function validate_ironvow_critical(
    definition: IronvowCriticalToggleSkillDefinition
)
    assert(definition.STAMINA_COST == 0
        and definition.MANA_COST >= 1
        and definition.UPKEEP_MANA_PER_SECOND > 0
        and definition.UPKEEP_MANA_PER_SECOND <= 5,
        "Warrior critical stance must continuously spend bounded MP.")
    local previous = 0
    for rank, source_power in ipairs({35, 48, 64}) do
        local row = assert(definition.RANKS[rank])
        assert(row.SOURCE_CRITICAL_POWER == source_power
            and row.MANA_COST == (if rank == 1 then 4 else 5)
            and row.CRITICAL_DAMAGE_BONUS > previous
            and row.CRITICAL_DAMAGE_BONUS <= 0.15,
            "Warrior critical stance must retain genuine source ranks.")
        previous = row.CRITICAL_DAMAGE_BONUS
    end
end

local function validate_scout_toggle(definition: ScoutToggleSkillDefinition)
    assert(definition.STAMINA_COST > 0
        and definition.STAMINA_COST <= 20,
        "Scout toggle must cost stamina on activation.")
    assert(definition.UPKEEP_STAMINA_PER_SECOND >= 1
        and definition.UPKEEP_STAMINA_PER_SECOND <= 10,
        "Scout toggle requires bounded continuous stamina upkeep.")
    assert(definition.CRITICAL_DAMAGE_BONUS > 0
        and definition.CRITICAL_DAMAGE_BONUS <= 0.20,
        "Scout toggle requires bounded critical damage scaling.")
    local previous = 0
    for rank = 1, 5 do
        local value = definition.RANKS[rank].CRITICAL_DAMAGE_BONUS
        assert(value > previous and value <= 0.20,
            "Five critical-power source ranks must increase the bonus.")
        previous = value
    end
end

--[[
Checks the bounded resource cost and real chance bonus for Accuracy.

Args:
    definition (ScoutAccuracyToggleSkillDefinition): Source C4 stance.

Returns:
    nil: Raises if the stance is resource-free or grants a fake effect.
]]
local function validate_accuracy_toggle(
    definition: ScoutAccuracyToggleSkillDefinition
)
    assert(definition.STAMINA_COST > 0
        and definition.UPKEEP_STAMINA_PER_SECOND >= 1
        and definition.UPKEEP_STAMINA_PER_SECOND <= 10,
        "Accuracy must spend actual stamina on cast and every second.")
    assert(definition.ACCURACY_BONUS > 0
        and definition.ACCURACY_BONUS <= 0.2,
        "Accuracy must provide a bounded real physical hit bonus.")
end

local function validate_support(definition: SupportSkillDefinition)
    assert(definition.HEAL_AMOUNT > 0, "Support healing must be positive.")
    assert(definition.RANGE_STUDS > 0, "Support range must be positive.")
    assert(definition.CHANNEL_SECONDS > 0, "Support channel must be positive.")
    assert(
        definition.PULSE_COUNT >= 1
            and definition.PULSE_COUNT == math.floor(definition.PULSE_COUNT),
        "Support skill needs whole-number pulses."
    )
    assert(definition.PULSE_HEAL > 0, "Support pulse heal must be positive.")
    assert(
        definition.PULSE_INTERVAL_SECONDS > 0,
        "Support pulse interval must be positive."
    )
    assert(
        definition.PULSE_HEAL * definition.PULSE_COUNT
            == definition.HEAL_AMOUNT,
        "Support pulses must equal total healing."
    )
end

local function validate_mage_heal(definition: MageHealSkillDefinition)
    validate_timed(definition)
    assert(definition.MANA_COST > 0, "Mage Heal must cost Mana.")
    assert(definition.RANGE_STUDS > 0, "Mage Heal range must be positive.")
    local cure_tier = definition.CURE_POISON_TIER or 0
    assert(
        definition.TOTAL_HEAL > 0
            or (definition.TOTAL_HEAL == 0
                and cure_tier >= 1 and cure_tier <= 7),
        "Mage support requires positive healing or authored poison cure."
    )
    assert(
        definition.HUMAN_INSTANT_FRACTION >= 0
            and definition.HUMAN_INSTANT_FRACTION <= 1,
        "Human heal split must be normalized."
    )
    assert(
        definition.ELF_INSTANT_FRACTION >= 0
            and definition.ELF_INSTANT_FRACTION <= 1,
        "Elf heal split must be normalized."
    )
    assert(
        definition.HOT_TICK_SECONDS > 0,
        "Heal-over-time tick must be positive."
    )
end

local function validate_magic_projectile(
    definition: MagicProjectileSkillDefinition
)
    validate_timed(definition)
    assert(definition.MANA_COST > 0, "Magic projectile must cost Mana.")
    assert(
        definition.RANGE_STUDS > 0,
        "Magic projectile range must be positive."
    )
    assert(
        definition.PROJECTILE_SPEED > 0,
        "Magic projectile speed must be positive."
    )
    assert(
        definition.BASE_DAMAGE > 0,
        "Magic projectile damage must be positive."
    )
end

local function validate_ward(definition: WardSkillDefinition)
    validate_timed(definition)
    assert(definition.MANA_COST > 0, "Ward must cost Mana.")
    assert(definition.RANGE_STUDS > 0, "Ward range must be positive.")
    assert(definition.WARD_AMOUNT > 0, "Ward amount must be positive.")
    assert(definition.DURATION_SECONDS > 0, "Ward duration must be positive.")
end

local function validate_ranger_projectile(
    definition: RangerProjectileSkillDefinition
)
    validate_timed(definition)
    assert(definition.STAMINA_COST > 0, "Ranger projectile must cost Stamina.")
    assert(
        definition.RANGE_STUDS > 0,
        "Ranger projectile range must be positive."
    )
    assert(
        definition.PROJECTILE_SPEED > 0,
        "Ranger projectile speed must be positive."
    )
    assert(
        definition.BASE_DAMAGE > 0,
        "Ranger projectile damage must be positive."
    )
    assert(definition.MAX_TARGETS >= 1, "Ranger projectile needs a target.")
    assert(
        definition.DEFAULT_RETENTION >= 0
            and definition.DEFAULT_RETENTION <= 1,
        "Ranger projectile retention must be normalized."
    )
    assert(
        definition.HUMAN_RETENTION >= 0
            and definition.HUMAN_RETENTION <= 1,
        "Human Ranger projectile retention must be normalized."
    )
end

local function validate_ranger_volley(
    definition: RangerVolleySkillDefinition
)
    validate_timed(definition)
    assert(definition.STAMINA_COST > 0, "Volley must cost Stamina.")
    assert(
        definition.AIM_RANGE_STUDS > 0,
        "Volley aim range must be positive."
    )
    assert(definition.RADIUS_STUDS > 0, "Volley radius must be positive.")
    assert(
        definition.INITIAL_DAMAGE > 0,
        "Volley initial damage must be positive."
    )
    assert(
        definition.PULSE_DAMAGE > 0,
        "Volley pulse damage must be positive."
    )
    assert(
        definition.PULSE_COUNT == 4,
        "Volley must contain initial plus three pulses."
    )
    assert(
        definition.PULSE_INTERVAL_SECONDS > 0,
        "Volley pulse interval must be positive."
    )
end

for _, definition in DEFINITIONS do
    validate_common(definition)
    if definition.KIND == "Melee" then
        validate_melee(definition)
    elseif definition.KIND == "ScoutAccuracyToggle" then
        validate_accuracy_toggle(
            definition :: ScoutAccuracyToggleSkillDefinition
        )
    elseif definition.KIND == "ScoutToggle" then
        validate_scout_toggle(definition :: ScoutToggleSkillDefinition)
    elseif definition.KIND == "IronvowCriticalToggle" then
        validate_ironvow_critical(
            definition :: IronvowCriticalToggleSkillDefinition
        )
    elseif definition.KIND == "IronvowAccuracyToggle" then
        validate_ironvow_accuracy(
            definition :: IronvowAccuracyToggleSkillDefinition
        )
    elseif definition.KIND == "Buff" then
        validate_buff(definition :: BuffSkillDefinition)
    elseif definition.KIND == "Support" then
        validate_support(definition :: SupportSkillDefinition)
    elseif definition.KIND == "MageHeal" then
        validate_mage_heal(definition :: MageHealSkillDefinition)
    elseif definition.KIND == "MagicProjectile" then
        validate_magic_projectile(definition :: MagicProjectileSkillDefinition)
    elseif definition.KIND == "Ward" then
        validate_ward(definition :: WardSkillDefinition)
    elseif definition.KIND == "RangerProjectile" then
        validate_ranger_projectile(
            definition :: RangerProjectileSkillDefinition
        )
    elseif definition.KIND == "RangerVolley" then
        validate_ranger_volley(
            definition :: RangerVolleySkillDefinition
        )
    else
        error("Unknown skill kind: " .. tostring((definition :: any).KIND))
    end
end

function SkillDefinitions.get(skill_id: string): SkillDefinition?
    return DEFINITIONS[skill_id]
end

function SkillDefinitions.get_for_rank(
    skill_id: string,
    rank: number
): any?
    local definition = DEFINITIONS[skill_id]
    if not definition then
        return nil
    end

    local safe_rank = math.max(1, math.floor(rank))
    local copy = clone_definition(definition)
    local ranks = (definition :: any).RANKS

    if type(ranks) == "table" then
        local overrides = ranks[safe_rank] or ranks[1]
        if type(overrides) == "table" then
            for key, value in pairs(overrides) do
                copy[key] = value
            end
        end
    end

    return table.freeze(copy)
end

function SkillDefinitions.is_valid(skill_id: string): boolean
    return DEFINITIONS[skill_id] ~= nil
end

function SkillDefinitions.all(): {[string]: SkillDefinition}
    return DEFINITIONS
end

return table.freeze(SkillDefinitions)
