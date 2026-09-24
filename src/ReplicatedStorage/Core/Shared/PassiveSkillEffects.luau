--!strict
-- Pure, server-readable passive effect rules for learned skill ranks.
local SkillDefinitions = require(
    script.Parent:WaitForChild("SkillProgressionDefinitions")
)
local ItemDefinitions = require(
    script.Parent:WaitForChild("ItemDefinitions")
)
local FirstTransfers = require(
    script.Parent:WaitForChild("OriginalFirstTransferDefinitions")
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

    -- An unearned Fighter must never receive an original transfer
    -- passive from a forged or stale purchased-skill field. Legacy
    -- Ranger/Rogue profiles retain their existing behavior.
    local transferred = definition.AllowedFirstTransferClasses
    if identity.BaseClassId == "Fighter"
        and type(transferred) == "table"
    then
        local awarded = FirstTransfers.awarded(character)
        local earned = false
        for _, class_id in ipairs(transferred) do
            if awarded and awarded.Id == class_id then
                earned = true
                break
            end
        end
        if not earned then return 0 end
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

--[[
Checks an actual registered sword OR blunt weapon equipped by the owner.

Only weapon-category metadata from the server's ItemDefinitions counts;
a dagger that temporarily uses a sword animation is not a sword.

Args:
    character (any): Authoritative player equipment and identity.

Returns:
    boolean: True only for a registered Sword or Blunt weapon category.
]]
local function equipped_sword_or_blunt(character: any): boolean
    local equipment = type(character) == "table"
        and character.Equipment
    local item_id = type(equipment) == "table"
        and equipment.Weapon
    local item = if type(item_id) == "string"
        then ItemDefinitions.get(item_id) else nil
    return item ~= nil
        and item.Kind == "Equipment"
        and item.Slot == "Weapon"
        and (item.Category == "Sword" or item.Category == "Blunt")
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
    if skill_id == "IronvowBladeTraining"
        and not equipped_sword_or_blunt(character)
    then
        return 0
    end
    if skill_id == "OathguardSteelAndStoneTraining"
        and not equipped_sword_or_blunt(character)
    then
        return 0
    end
    if skill_id == "IronvowPolearmTraining" then
        local equipment = type(character) == "table"
            and character.Equipment
        local weapon_id = type(equipment) == "table"
            and equipment.Weapon
        local weapon = if type(weapon_id) == "string"
            then ItemDefinitions.get(weapon_id) else nil
        if not weapon or weapon.Kind ~= "Equipment"
            or weapon.Slot ~= "Weapon"
            or weapon.Category ~= "Polearm"
        then
            return 0
        end
        local definition = SkillDefinitions.get(skill_id)
        local rank = purchased_rank(character, definition)
        local source_power = definition.SourcePhysicalAttackByRank
            and definition.SourcePhysicalAttackByRank[rank] or 0
        -- Flat source P.Atk is not Roblox's formula. Keep its rank
        -- ordering, but treat this conversion as provisional.
        return source_power * 0.001
    end
    return resolve_bonus(character, skill_id, "DamageBonusPerRank")
end

--[[
Returns C4's extra polearm target count only for the actual earned owner.

Args:
    character (any): Server-owned current class, skill rank and equipment.

Returns:
    number: Five extra targets only for earned, actually equipped polearm.
]]
function PassiveSkillEffects.polearm_extra_targets(
    character: any
): number
    if PassiveSkillEffects.damage_bonus(
        character, "IronvowPolearmTraining"
    ) <= 0 then
        return 0
    end
    return 5
end

--[[
Returns the equipped-gear permission earned through the purchased source rank.

Args:
    character (any): Authoritative race, base class, level and skill state.

Returns:
    boolean: Whether this character has earned source level-20 gear.
]]
function PassiveSkillEffects.has_scout_equipment_expertise(
    character: any
): boolean
    return type(character) == "table"
        and (tonumber(character.Level) or 0) >= 20
        and purchased_rank(
            character,
            SkillDefinitions.get("ScoutEquipmentExpertise")
        ) >= 1
end

--[[
Returns whether the personally awarded Knight owns source D-grade training.

Args:
    character (any): Authoritative owned character and paid skill ranks.

Returns:
    boolean: True only at level20+ with real Knight transfer and rank1.
]]
function PassiveSkillEffects.has_oathguard_equipment_expertise(
    character: any
): boolean
    return type(character) == "table"
        and (tonumber(character.Level) or 0) >= 20
        and purchased_rank(
            character,
            SkillDefinitions.get("OathguardEquipmentExpertise")
        ) >= 1
end

--[[
Authorizes only genuinely advanced, paid level-20 Warrior D-grade gear.

Args:
    character (any): The actual server-owned selected character.

Returns:
    boolean: Whether this owner bought the separate Warrior source rank.
]]
function PassiveSkillEffects.has_ironvow_equipment_expertise(
    character: any
): boolean
    return type(character) == "table"
        and (tonumber(character.Level) or 0) >= 20
        and purchased_rank(
            character,
            SkillDefinitions.get("IronvowEquipmentExpertise")
        ) >= 1
end

--[[
Computes the extra real underwater oxygen reserve from source training.

Args:
    character (any): Server-owned selected Scout/Rogue character.

Returns:
    number: Bounded earned seconds, zero for untrained/other classes.
]]
function PassiveSkillEffects.scout_oxygen_bonus(
    character: any
): number
    if (tonumber(character and character.Level) or 0) < 20 then
        return 0
    end
    return math.clamp(resolve_bonus(
        character, "ScoutLungCapacity", "OxygenSecondsBonusPerRank"
    ), 0, 15)
end

--[[
Computes the earned reduction only for world-impact fall injuries.

Args:
    character (any): Real class/race and purchased environmental skill.

Returns:
    number: Damage reduction in the interval zero through 0.4.
]]
function PassiveSkillEffects.scout_fall_reduction(
    character: any
): number
    if (tonumber(character and character.Level) or 0) < 20 then
        return 0
    end
    return math.clamp(resolve_bonus(
        character, "ScoutFallResistance", "FallDamageReductionPerRank"
    ), 0, 0.4)
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
    ) + resolve_bonus(
        character, "IronvowFortitude", "HealthBonusPerRank"
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
Returns the Fighter's trained physical mitigation only while real light or
heavy Body armour is equipped. Bare skin and invalid items grant nothing.

Args:
    character (any): Server-owned selected Fighter and equipped Body slot.

Returns:
    number: Non-negative physical NPC damage reduction up to 3.5%.
]]
function PassiveSkillEffects.fighter_armor_reduction(
    character: any
): number
    if type(character) ~= "table"
        or type(character.Equipment) ~= "table"
    then
        return 0
    end
    local body_id = character.Equipment.Body
    local body = if type(body_id) == "string"
        then ItemDefinitions.get(body_id) else nil
    if not body or body.Kind ~= "Equipment" or body.Slot ~= "Body"
        or (
            body.Category ~= "LightArmor"
            and body.Category ~= "HeavyArmor"
        )
    then
        return 0
    end
    local base = math.clamp(resolve_bonus(
        character, "FighterArmorTraining", "PhysicalReductionPerRank"
    ), 0, 0.035)
    local career_skill = if body.Category == "HeavyArmor"
        then "IronvowHeavyArmorTraining"
        else "IronvowLightArmorTraining"
    local advanced = resolve_bonus(
        character, career_skill, "PhysicalReductionPerRank"
    )
    if body.Category == "HeavyArmor" then
        advanced += resolve_bonus(
            character, "OathguardHeavyArmorTraining",
            "PhysicalReductionPerRank"
        )
    end
    -- Every original class passive requires the saved, verified personal
    -- advancement receipt and matching registered Body-armour category.
    -- A raw class ID, robe or unequipped shield never provides mitigation.
    return math.clamp(base + advanced, 0, 0.10)
end

--[[
Resolves a Mystic's physical-defence mastery only with a real robe Body.

Args:
    character (any): Server-owned Mage and equipped Body gear.

Returns:
    number: Passive physical mitigation in the range zero to 2.4%.
]]
function PassiveSkillEffects.mystic_armor_reduction(
    character: any
): number
    if type(character) ~= "table"
        or type(character.Equipment) ~= "table"
    then
        return 0
    end
    local body_id = character.Equipment.Body
    local body = if type(body_id) == "string"
        then ItemDefinitions.get(body_id) else nil
    if not body or body.Kind ~= "Equipment"
        or body.Slot ~= "Body"
        or body.Category ~= "Robe"
    then
        return 0
    end
    return math.clamp(
        resolve_bonus(
            character, "MysticArmorTraining",
            "PhysicalReductionPerRank"
        ),
        0, 0.024
    )
end

--[[
Returns trained magic defence independently of physical armour.

Args:
    character (any): Server-owned selected Mage and purchased ranks.

Returns:
    number: Magic damage mitigation in the range zero through 6%.
]]
function PassiveSkillEffects.mystic_magic_reduction(
    character: any
): number
    return math.clamp(
        resolve_bonus(
            character, "MysticSpellResistance",
            "MagicReductionPerRank"
        ),
        0, 0.06
    )
end

--[[
Returns earned Knight physical reduction with a registered shield equipped.

Args:
    character (any): Genuine Knight profile and server-owned OffHand item.

Returns:
    number: Zero without a valid shield; up to 1.6% with both paid ranks.
]]
function PassiveSkillEffects.oathguard_shield_reduction(
    character: any
): number
    local equipment = type(character) == "table"
        and character.Equipment
    local offhand_id = type(equipment) == "table"
        and equipment.OffHand
    local shield = if type(offhand_id) == "string"
        then ItemDefinitions.get(offhand_id) else nil
    if not shield or shield.Kind ~= "Equipment"
        or shield.Slot ~= "OffHand"
        or shield.Category ~= "Shield"
    then
        return 0
    end
    return math.clamp(resolve_bonus(
        character, "OathguardShieldMastery", "PhysicalReductionPerRank"
    ), 0, 0.016)
end

--[[
Returns purchased original Knight mitigation against real enemy magic only.

Args:
    character (any): Genuine original Human Oathguard and bought ranks.

Returns:
    number: Bounded mitigation from zero to 4.8% across eight ranks.
]]
function PassiveSkillEffects.oathguard_magic_reduction(
    character: any
): number
    return math.clamp(
        resolve_bonus(
            character, "OathguardRunicResistance",
            "MagicReductionPerRank"
        ),
        0, 0.048
    )
end

--[[
Returns the earned rank bonus only while a legitimate Mystic robe is worn.

Args:
    character (any): Server-owned class, purchased ranks and Body slot.
    skill_id (string): Registered Mystic robe passive.
    stat_field (string): Requested authored per-rank stat field.

Returns:
    number: Owned robe-only bonus, or zero when absent/ineligible.
]]
local function robe_bonus(
    character: any,
    skill_id: string,
    stat_field: string
): number
    if type(character) ~= "table"
        or type(character.Equipment) ~= "table"
    then
        return 0
    end
    local body_id = character.Equipment.Body
    local body = if type(body_id) == "string"
        then ItemDefinitions.get(body_id) else nil
    if not body or body.Kind ~= "Equipment"
        or body.Slot ~= "Body" or body.Category ~= "Robe"
    then
        return 0
    end
    return resolve_bonus(character, skill_id, stat_field)
end

--[[
Returns a bounded protection bonus only for a purchased level-one
starting-class passive while the authentic character is below level 20.

Args:
    character (any): Server-owned race, class, level and purchased ranks.

Returns:
    number: Real physical NPC mitigation from zero through two percent.
]]
function PassiveSkillEffects.novice_physical_reduction(
    character: any
): number
    if type(character) ~= "table"
        or type(character.Level) ~= "number"
        or character.Level < 1 or character.Level > 19
    then
        return 0
    end
    return math.clamp(
        resolve_bonus(
            character, "NoviceProtection", "PhysicalReductionPerRank"
        ),
        0, 0.02
    )
end

--[[
Returns a bought robe-only magical casting-rate bonus. Other gear,
foreign classes and untrained characters retain their normal cast time.

Args:
    character (any): Authentic selected Mage and real equipped Body item.

Returns:
    number: Casting-rate bonus from zero to six percent.
]]
function PassiveSkillEffects.robe_casting_rate_bonus(
    character: any
): number
    return math.clamp(
        robe_bonus(
            character,
            "MysticRobeCasting",
            "CastingRateBonusPerRank"
        ), 0, 0.06
    )
end

--[[
Returns the C4 starting Mystic's real mana-regeneration bonus.

Args:
    character (any): Authentic selected Mage and equipped robe.

Returns:
    number: Earned regeneration fraction, capped at fifteen percent.
]]
function PassiveSkillEffects.robe_mana_regen_bonus(
    character: any
): number
    return math.clamp(
        robe_bonus(
            character,
            "MysticRobeManaRecovery",
            "ManaRegenBonusPerRank"
        ), 0, 0.15
    )
end

--[[
Returns the C4 starting Mystic's robe-only basic attack speed bonus.

Args:
    character (any): Authentic selected Mage and equipped robe.

Returns:
    number: Earned basic attack speed bonus, capped at six percent.
]]
function PassiveSkillEffects.robe_attack_rate_bonus(
    character: any
): number
    return math.clamp(
        robe_bonus(
            character,
            "MysticRobeAttackSpeed",
            "AttackRateBonusPerRank"
        ), 0, 0.06
    )
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

--[[
Returns a positive movement-speed multiplier from the purchased Scout
mastery. This affects locomotion only; locked combat states remain locked.

Args:
    character (any): Server-owned class, race, and learned passive ranks.

Returns:
    number: Authoritative locomotion multiplier from 1 through 1.06.
]]
function PassiveSkillEffects.movement_multiplier(
    character: any
): number
    return math.clamp(
        1 + resolve_bonus(
            character, "ScoutFleetFoot", "MovementBonusPerRank"
        ),
        1, 1.06
    )
end

--[[
Returns Human first-transfer attack-rate training from purchased ranks.

Args:
    character (any): Server-owned race, combat class and skill states.

Returns:
    number: Additive attack-speed fraction from 0 through 0.06.
]]
function PassiveSkillEffects.attack_rate_bonus(
    character: any
): number
    return math.clamp(
        resolve_bonus(
            character, "HumanScoutRapidHands", "AttackRateBonusPerRank"
        ),
        0, 0.06
    )
end

--[[
Computes the chance that the current purchased Scout ranks evade a
direct NPC melee hit. Running Evasion only applies while actually moving.

Args:
    character (any): Server-owned purchased ranks, race and class.
    is_moving (boolean): Verified current server Humanoid motion state.

Returns:
    number: Evasion probability clamped to zero through 5.5 percent.
]]
function PassiveSkillEffects.scout_evasion_chance(
    character: any,
    is_moving: boolean
): number
    local chance = resolve_bonus(
        character, "ScoutEvasion", "EvasionChancePerRank"
    )
    if is_moving == true then
        chance += resolve_bonus(
            character, "ScoutRunningEvasion", "EvasionChancePerRank"
        )
    end
    return math.clamp(chance, 0, 0.055)
end

--[[
Computes recovery earned from purchased Human Fighter / Scout sitting
ranks or either Scout's running rank. Only verified actual motion or
sitting counts. These are original-game stamina analogues of the C4
source recovery families, not an unconditional healing modifier.

Args:
    character (any): Server-owned class, race and bought skill ranks.
    is_sitting (boolean): True only while the real Humanoid is seated.
    is_moving (boolean): True only with real nonzero server movement.

Returns:
    number: Bounded Stamina regeneration multiplier from 1 to 1.25.
]]
function PassiveSkillEffects.stamina_recovery_multiplier(
    character: any,
    is_sitting: boolean,
    is_moving: boolean
): number
    local bonus = 0
    if is_sitting == true then
        bonus = resolve_bonus(
            character,
            "FighterRestingRecovery",
            "RestingStaminaBonusPerRank"
        ) + resolve_bonus(
            character,
            "HumanScoutRestingRecovery",
            "RestingStaminaBonusPerRank"
        ) + resolve_bonus(
            character, "IronvowRestRecovery",
            "RestingStaminaBonusPerRank"
        )
    elseif is_moving == true then
        bonus = resolve_bonus(
            character,
            "ScoutRunningRecovery",
            "RunningStaminaBonusPerRank"
        )
    end
    return math.clamp(1 + bonus, 1, 1.25)
end

return table.freeze(PassiveSkillEffects)
