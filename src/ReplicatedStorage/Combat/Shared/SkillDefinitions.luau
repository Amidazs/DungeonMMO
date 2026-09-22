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
    TAUNT_BONUS_THREAT: number?,
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

export type SkillDefinition = MeleeSkillDefinition
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
    AetherBolt = AETHER_BOLT,
    TrackerShot = TRACKER_SHOT,
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
    if definition.TAUNT_BONUS_THREAT ~= nil then
        assert(
            definition.TAUNT_BONUS_THREAT > 0
                and definition.TAUNT_BONUS_THREAT < math.huge,
            "Taunt threat must be positive and finite."
        )
    end
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
    assert(definition.TOTAL_HEAL > 0, "Mage Heal total must be positive.")
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
