--!strict
-- Pure, server-readable passive effect rules for learned skill ranks.
local SkillDefinitions = require(
    script.Parent:WaitForChild("SkillProgressionDefinitions")
)
local ItemDefinitions = require(
    script.Parent:WaitForChild("ItemDefinitions")
)

local PassiveSkillEffects = {}

-- Reads the purchased rank only for a passive owned by the character's
-- current base class. A foreign class or unsaved preview gets no bonus.
--
-- Args:
--   character (any): Server-owned character or runtime snapshot.
--   definition (any): Registered passive skill definition.
-- Returns:
--   number: Earned, clamped passive rank or zero for an ineligible class.
local function purchased_rank(character: any, definition: any): number
    if type(character) ~= "table"
        or type(definition) ~= "table"
        or definition.Kind ~= "Passive"
    then
        return 0
    end

    local identity = character.Identity
    local allowed = definition.AllowedBaseClasses
    if type(identity) ~= "table" or type(allowed) ~= "table" then
        return 0
    end

    local eligible = false
    for _, class_id in ipairs(allowed) do
        if identity.BaseClassId == class_id then
            eligible = true
            break
        end
    end
    if not eligible then
        return 0
    end

    local allowed_races = definition.AllowedRaces
    if type(allowed_races) == "table" then
        local race_eligible = false
        for _, race_id in ipairs(allowed_races) do
            if identity.RaceId == race_id then
                race_eligible = true
                break
            end
        end
        if not race_eligible then
            return 0
        end
    end

    local progression = character.Progression
    local skills = type(progression) == "table" and progression.Skills
    local state = type(skills) == "table" and skills[definition.Id]
    if type(state) ~= "table" or state.Known ~= true then
        return 0
    end

    local rank = math.floor(tonumber(state.PurchasedRank) or 0)
    return math.clamp(rank, 0, definition.MaxRank)
end

-- Converts an earned passive rank to a server-authored stat bonus.
--
-- Args:
--   character (any): Current authoritative character.
--   skill_id (string): Registered passive skill identifier.
--   stat_field (string): The stat bonus field on that definition.
-- Returns:
--   number: Character-specific stat increase or zero when unavailable.
local function resolve_bonus(
    character: any,
    skill_id: string,
    stat_field: string
): number
    local definition = SkillDefinitions.get(skill_id)
    if type(definition) ~= "table" then
        return 0
    end

    local per_rank = definition[stat_field]
    if type(per_rank) ~= "number" then
        return 0
    end

    return purchased_rank(character, definition) * per_rank
end

--[[
Checks the real equipped weapon's registered tags, not client-supplied tags.

Args:
    character (any): Server-owned character and Equipment slots.
    required_tag (string): Dagger, Longbow, or another authoritative tag.

Returns:
    boolean: True only when an actual valid equipped weapon has the tag.
]]
local function equipped_weapon_has_tag(
    character: any,
    required_tag: string
): boolean
    local equipment = type(character) == "table"
        and character.Equipment
    local weapon_id = type(equipment) == "table"
        and equipment.Weapon
    local weapon = if type(weapon_id) == "string"
        then ItemDefinitions.get(weapon_id) else nil
    if not weapon or weapon.Kind ~= "Equipment"
        or weapon.Slot ~= "Weapon"
    then
        return false
    end
    for _, tag in ipairs(weapon.WeaponTags or {}) do
        if tag == required_tag then
            return true
        end
    end
    return false
end

-- Resolves a purchased physical or magical damage passive.
--
-- Args:
--   character (any): Current server-owned character.
--   skill_id (string): Registered damage passive skill.
-- Returns:
--   number: Additive damage multiplier increase.
function PassiveSkillEffects.damage_bonus(
    character: any,
    skill_id: string
): number
    if skill_id == "RogueEdgeDiscipline"
        and not equipped_weapon_has_tag(character, "Dagger")
    then
        return 0
    end
    return resolve_bonus(character, skill_id, "DamageBonusPerRank")
end

--[[
Returns real earned longbow range, not merely an unlocked skill button.

Args:
    character (any): Server-authoritative character and purchased skills.

Returns:
    number: Added studs to accepted Ranger projectile maximum range.
]]
function PassiveSkillEffects.bow_range_bonus(character: any): number
    if not equipped_weapon_has_tag(character, "Longbow") then
        return 0
    end
    return math.max(0, resolve_bonus(
        character, "RangerLongRange", "BowRangeBonusStudsPerRank"
    ))
end

--[[
Returns real earned arrow travel speed on server projectile delivery.

Args:
    character (any): Server-owned Ranger with its purchased skill ranks.

Returns:
    number: Added studs per second to actual Ranger arrows.
]]
function PassiveSkillEffects.arrow_speed_bonus(character: any): number
    if not equipped_weapon_has_tag(character, "Longbow") then
        return 0
    end
    return math.max(0, resolve_bonus(
        character, "RangerArrowVelocity", "ArrowSpeedBonusPerRank"
    ))
end

-- Resolves the Fighter's trained, flat maximum-health increase.
--
-- Args:
--   character (any): Current server-owned character.
-- Returns:
--   number: Extra maximum HP from earned passive ranks.
function PassiveSkillEffects.health_bonus(character: any): number
    return resolve_bonus(
        character, "StalwartTraining", "HealthBonusPerRank"
    )
end

-- Resolves the Mage's trained healing multiplier bonus.
--
-- Args:
--   character (any): Current server-owned character.
-- Returns:
--   number: Additive multiplier for authoritative healing.
function PassiveSkillEffects.heal_bonus(character: any): number
    return resolve_bonus(
        character, "RestorativeTraining", "HealBonusPerRank"
    )
end

--[[
Returns earned physical mitigation only while a valid light-body armour is
actually equipped. Unknown/wrong-slot/heavy armour never earns this bonus.

Args:
    character (any): Authoritative character with real Equipment and Skills.

Returns:
    number: Clamped physical reduction in the interval 0 through 0.08.
]]
function PassiveSkillEffects.light_armor_reduction(
    character: any
): number
    if type(character) ~= "table"
        or type(character.Equipment) ~= "table"
    then
        return 0
    end

    local body_id = character.Equipment.Body
    local body = if type(body_id) == "string"
        then ItemDefinitions.get(body_id)
        else nil
    if not body or body.Kind ~= "Equipment"
        or body.Slot ~= "Body"
        or body.Category ~= "LightArmor"
    then
        return 0
    end

    local bonus = resolve_bonus(
        character, "ScoutLightArmorMastery", "PhysicalReductionPerRank"
    )
    return math.clamp(bonus, 0, 0.08)
end

--[[
Returns the real Human Scout critical-hit damage bonus from owned ranks.

Args:
    character (any): Server-owned character and authenticated skill ranks.

Returns:
    number: Additive critical-damage multiplier from this passive.
]]
function PassiveSkillEffects.critical_damage_bonus(
    character: any
): number
    return resolve_bonus(
        character,
        "HumanScoutCriticalPower",
        "CriticalDamageBonusPerRank"
    )
end

--[[
Returns the purchased Human/Elf race-specific scout critical chance bonus.

Args:
    character (any): Server-owned player class, race and bought skill ranks.

Returns:
    number: Additive critical-hit chance granted by eligible Scout training.
]]
function PassiveSkillEffects.critical_chance_bonus(
    character: any
): number
    return resolve_bonus(
        character, "HumanScoutPrecision",
        "CriticalChanceBonusPerRank"
    ) + resolve_bonus(
        character, "ElvenScoutPrecision",
        "CriticalChanceBonusPerRank"
    )
end

return table.freeze(PassiveSkillEffects)
