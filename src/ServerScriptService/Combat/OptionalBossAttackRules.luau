--!strict
-- Server-owned prototype ability profiles for the four dormant optional bosses.
-- Reuses captain poses, hit resolution and the accepted defence/damage path.
local Dungeon = game:GetService("ServerScriptService"):WaitForChild("Dungeon")
local CaptainFactory = require(Dungeon:WaitForChild("MarauderCaptainFactory"))
local OptionalBossAttackRules = {}

local ATTACKS = table.freeze({
    EclipseSweep = {Pose = "CaptainSlash", Reach = 8, Arc = 130,
        Windup = 0.6, Interval = 1.6, Health = 25, Stamina = 32,
        Color = Color3.fromRGB(242, 124, 83)},
    EclipsePulse = {Pose = "CaptainShockwave", Reach = 10, Arc = 360,
        Windup = 1.15, Interval = 2.15, Health = 30, Stamina = 45,
        Color = Color3.fromRGB(171, 111, 230)},
    VeilLunge = {Pose = "CaptainSlash", Reach = 10, Arc = 48,
        Windup = 0.7, Interval = 1.75, Health = 28, Stamina = 30,
        Color = Color3.fromRGB(112, 146, 238)},
    VeilCounter = {Pose = "CaptainHeavy", Reach = 6, Arc = 170,
        Windup = 0.55, Interval = 1.5, Health = 22, Stamina = 42,
        Color = Color3.fromRGB(184, 124, 218)},
    EchoQuake = {Pose = "CaptainShockwave", Reach = 12, Arc = 360,
        Windup = 1.25, Interval = 2.3, Health = 33, Stamina = 48,
        Color = Color3.fromRGB(235, 152, 81)},
    EchoCrush = {Pose = "CaptainSlash", Reach = 7, Arc = 85,
        Windup = 0.65, Interval = 1.65, Health = 29, Stamina = 37,
        Color = Color3.fromRGB(213, 101, 69)},
    GalleryFeint = {Pose = "CaptainSlash", Reach = 6, Arc = 50,
        Windup = 0.35, Interval = 1.3, Health = 19, Stamina = 23,
        Color = Color3.fromRGB(121, 207, 172)},
    GallerySeal = {Pose = "CaptainHeavy", Reach = 9, Arc = 115,
        Windup = 1.05, Interval = 2.05, Health = 35, Stamina = 50,
        Color = Color3.fromRGB(92, 186, 206)},
})

local PROFILES = table.freeze({
    TempleEventBoss = {
        PhaseOne = {"EclipseSweep", "EclipsePulse"},
        PhaseTwo = {"EclipsePulse", "EclipseSweep", "EclipsePulse"},
    },
    TempleSecretBoss = {
        PhaseOne = {"VeilLunge", "VeilCounter", "VeilLunge"},
        PhaseTwo = {"VeilCounter", "VeilLunge"},
    },
    AbandonedMineEventBoss = {
        PhaseOne = {"EchoQuake", "EchoCrush"},
        PhaseTwo = {"EchoCrush", "EchoQuake", "EchoQuake"},
    },
    AbandonedMineSecretBoss = {
        PhaseOne = {"GalleryFeint", "GallerySeal", "GalleryFeint"},
        PhaseTwo = {"GallerySeal", "GalleryFeint"},
    },
})

-- Resolves a distinct ability while retaining the accepted attack/defence path.
-- Unknown and ordinary bosses use the existing Marauder attack pattern.
function OptionalBossAttackRules.resolve(
    model: Model, pattern_index: number, health_fraction: number
): any?
    local boss_id = model:GetAttribute("BossId")
    local profile = if type(boss_id) == "string" then PROFILES[boss_id] else nil
    if not profile then
        return nil
    end
    local phase = if type(health_fraction) == "number"
        and health_fraction == health_fraction and health_fraction <= 0.5
        then "PhaseTwo" else "PhaseOne"
    local pattern = profile[phase]
    local index = if type(pattern_index) == "number"
        and pattern_index >= 1 and pattern_index % 1 == 0
        then ((pattern_index - 1) % #pattern) + 1 else 1
    local ability_id = pattern[index]
    local ability = ATTACKS[ability_id]
    assert(ability ~= nil, "Optional boss ability must be configured")
    local attack_name = ability.Pose
    local base = CaptainFactory.ATTACKS[attack_name]
    assert(base ~= nil, "Optional boss must reuse a registered captain attack")
    local definition = {}
    for key, value in pairs(base) do
        definition[key] = value
    end
    definition.DISPLAY_NAME = ability_id
    definition.ATTACK_REACH_STUDS = ability.Reach
    definition.ATTACK_ARC_DEGREES = ability.Arc
    definition.WIND_UP_SECONDS = ability.Windup
    definition.ATTACK_INTERVAL_SECONDS = ability.Interval
    definition.HEALTH_DAMAGE = ability.Health
    definition.STAMINA_DAMAGE = ability.Stamina
    definition.TELEGRAPH_COLOR = ability.Color
    return {
        AttackName = attack_name,
        Definition = definition,
        AbilityId = ability_id,
        Phase = phase,
        NextPatternIndex = index % #pattern + 1,
    }
end

return table.freeze(OptionalBossAttackRules)
