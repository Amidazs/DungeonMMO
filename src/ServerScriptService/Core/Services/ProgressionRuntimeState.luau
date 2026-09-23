--!strict
-- Authoritative per-server combat/progression snapshot state.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")

local AttributeConfig = require(
    Shared:WaitForChild("AttributeConfig")
)
local CharacterCombatStats = require(
    Shared:WaitForChild("CharacterCombatStats")
)
local EquipmentStatResolver = require(
    Shared:WaitForChild("EquipmentStatResolver")
)
local EquipmentPresentationRules = require(
    Shared:WaitForChild("EquipmentPresentationRules")
)
local ProfileSchema = require(
    Shared:WaitForChild("ProfileSchema")
)
local SkillProgressionDefinitions = require(
    Shared:WaitForChild("SkillProgressionDefinitions")
)
local SkillUnlockRules = require(
    Shared:WaitForChild("SkillUnlockRules")
)
local PassiveSkillEffects = require(
    Shared:WaitForChild("PassiveSkillEffects")
)
local ItemDefinitions = require(
    Shared:WaitForChild("ItemDefinitions")
)

local CombatStatusService = require(
    ServerScriptService.Combat.CombatStatusService
)
local ScoutCriticalToggleService = require(
    ServerScriptService.Combat.ScoutCriticalToggleService
)

--[[
Returns a live, server-owned buff value without trusting client metadata.

Args:
    user_id (number): Authenticated owner of an active Roblox character.
    kind (string): One of the authored status service buff families.

Returns:
    number: Valid non-stacking buff magnitude or zero.
]]
local function active_buff(user_id: number, kind: string): number
    local player = Players:GetPlayerByUserId(user_id)
    return CombatStatusService.get(
        player and player.Character, kind
    )
end

local ProgressionRuntimeState = {}

local states: {[number]: any} = {}

--[[
Builds a fresh default character used only for neutral runtime fallbacks.

Args:
    None.

Returns:
    any: Mutable default character table.
]]
local function default_character(): any
    return ProfileSchema.create_default(0).Characters.Slot1
end

--[[
Builds a detached default identity for missing runtime state.

Args:
    None.

Returns:
    any: Mutable default Identity table.
]]
local function default_identity(): any
    return ProfileSchema.deep_clone(default_character().Identity)
end

--[[
Builds detached default progression for missing runtime state.

Args:
    None.

Returns:
    any: Mutable default Progression table.
]]
local function default_progression(): any
    return ProfileSchema.deep_clone(default_character().Progression)
end

--[[
Builds detached empty Equipment for missing runtime state.

Args:
    None.

Returns:
    any: Mutable empty Equipment table.
]]
local function default_equipment(): any
    return ProfileSchema.deep_clone(default_character().Equipment)
end

--[[
Returns the current authoritative runtime state or a neutral fallback state.

Fallback state is not persisted into the state registry. It exists only so
readers fail neutral for users that have not been seeded yet.

Args:
    user_id (number): Player user ID.

Returns:
    any: Runtime state wrapper containing identity, progression and Equipment.
]]
local function state_for(user_id: number): any
    local state = states[user_id]

    if state then
        return state
    end

    local equipment = default_equipment()

    return {
        Level = 1,
        Identity = default_identity(),
        ClassAdvancement = {},
        Progression = default_progression(),
        Equipment = equipment,
        EquipmentEffects = EquipmentStatResolver.resolve(equipment),
    }
end

--[[
Returns the progression portion of one runtime state.

Args:
    user_id (number): Player user ID.

Returns:
    any: Progression-shaped runtime table.
]]
local function progression_for(user_id: number): any
    return state_for(user_id).Progression
end

--[[
Returns cached resolved Equipment effects for one runtime state.

Args:
    user_id (number): Player user ID.

Returns:
    any: Frozen EquipmentStatResolver result.
]]
local function equipment_effects_for(user_id: number): any
    local state = state_for(user_id)

    if type(state.EquipmentEffects) == "table" then
        return state.EquipmentEffects
    end

    return EquipmentStatResolver.resolve(state.Equipment)
end

--[[
Seeds the authoritative per-server runtime snapshot for one character.

The character's Identity, Progression and Equipment are deep-cloned. Equipment
is resolved once at seed time so later source Inventory/Equipment mutation
cannot change an active Dungeon run until another authoritative reseed occurs.
Older accepted callers that provide only Progression remain compatible and use
neutral identity/equipment fallbacks.

Args:
    user_id (number): Player user ID whose runtime state is replaced.
    character_or_progression (any): Full character or legacy Progression table.

Returns:
    None.
]]
function ProgressionRuntimeState.set_character(
    user_id: number,
    character_or_progression: any
)
    local level: number
    local identity: any
    local advancement: any
    local progression: any
    local equipment: any

    if type(character_or_progression) == "table"
        and type(character_or_progression.Progression) == "table"
    then
        level = tonumber(character_or_progression.Level) or 1
        identity = if type(character_or_progression.Identity) == "table"
            then character_or_progression.Identity
            else default_identity()
        advancement = if type(character_or_progression.ClassAdvancement)
            == "table"
            then character_or_progression.ClassAdvancement
            else {}
        progression = character_or_progression.Progression
        equipment = if type(character_or_progression.Equipment) == "table"
            then character_or_progression.Equipment
            else default_equipment()
    elseif type(character_or_progression) == "table" then
        level = 1
        identity = default_identity()
        advancement = {}
        progression = character_or_progression
        equipment = default_equipment()
    else
        level = 1
        identity = default_identity()
        advancement = {}
        progression = default_progression()
        equipment = default_equipment()
    end

    local equipment_snapshot = ProfileSchema.deep_clone(equipment)

    states[user_id] = {
        Level = math.max(1, math.floor(level)),
        Identity = ProfileSchema.deep_clone(identity),
        ClassAdvancement = ProfileSchema.deep_clone(advancement),
        Progression = ProfileSchema.deep_clone(progression),
        Equipment = equipment_snapshot,
        EquipmentEffects = EquipmentStatResolver.resolve(
            equipment_snapshot
        ),
    }
end

--[[
Removes all runtime snapshot state for one user.

Args:
    user_id (number): Player user ID leaving the current server.

Returns:
    None.
]]
function ProgressionRuntimeState.clear_character(user_id: number)
    states[user_id] = nil
end

--[[
Returns the accepted Progression-shaped public runtime snapshot.

Args:
    user_id (number): Player user ID.

Returns:
    any: Deep-cloned Progression table; internal Equipment state stays
        private.
]]
function ProgressionRuntimeState.get_snapshot(user_id: number): any
    return ProfileSchema.deep_clone(progression_for(user_id))
end

--[[
Returns the authoritative runtime race ID.

Args:
    user_id (number): Player user ID.

Returns:
    string?: Stable race ID, otherwise nil.
]]
function ProgressionRuntimeState.get_race_id(user_id: number): string?
    local identity = state_for(user_id).Identity

    if type(identity) ~= "table" then
        return nil
    end

    return if type(identity.RaceId) == "string"
        then identity.RaceId
        else nil
end

--[[
Returns one authoritative runtime attribute with a neutral fallback.

Args:
    user_id (number): Player user ID.
    name (string): Attribute name.

Returns:
    number: Runtime attribute value or AttributeConfig.BASE_VALUE.
]]
function ProgressionRuntimeState.get_attribute(
    user_id: number,
    name: string
): number
    local progression = progression_for(user_id)
    local value = progression
        and progression.Attributes
        and progression.Attributes[name]

    return if type(value) == "number"
        then value
        else AttributeConfig.BASE_VALUE
end

--[[
Returns the runtime Attributes table for combat-stat calculations.

Args:
    user_id (number): Player user ID.

Returns:
    any: Attribute table or an empty neutral table.
]]
local function attributes_for(user_id: number): any
    local progression = progression_for(user_id)

    return if type(progression.Attributes) == "table"
        then progression.Attributes
        else {}
end

--[[
Returns the cached authoritative Equipment effects for a user.

Args:
    user_id (number): Player user ID.

Returns:
    any: Frozen resolved Equipment effects.
]]
function ProgressionRuntimeState.get_equipment_effects(
    user_id: number
): any
    return equipment_effects_for(user_id)
end

--[[
Returns a detached authoritative weapon-tag set derived from Equipment.

Args:
    user_id (number): Player user ID.

Returns:
    {[string]: boolean}: Copy of active runtime weapon tags.
]]
function ProgressionRuntimeState.get_weapon_tags(
    user_id: number
): {[string]: boolean}
    local effects = equipment_effects_for(user_id)
    local result: {[string]: boolean} = {}

    for tag, enabled in pairs(effects.WeaponTags or {}) do
        if type(tag) == "string" and enabled == true then
            result[tag] = true
        end
    end

    return result
end

--[[
Returns Strength scaling plus the approved Equipment physical-damage bonus.

Args:
    user_id (number): Player user ID.

Returns:
    number: Non-negative authoritative physical-damage multiplier.
]]
function ProgressionRuntimeState.get_physical_multiplier(
    user_id: number
): number
    local base_multiplier = AttributeConfig.physical_multiplier(
        ProgressionRuntimeState.get_attribute(user_id, "Strength")
    )
    local equipment_bonus = equipment_effects_for(user_id)
        .PhysicalDamageBonus

    local character = state_for(user_id)
    local passive_bonus = PassiveSkillEffects.damage_bonus(
        character, "IronDiscipline"
    ) + PassiveSkillEffects.damage_bonus(
        character, "FighterPhysicalTraining"
    ) + PassiveSkillEffects.damage_bonus(
        character, "MysticWeaponTraining"
    ) + PassiveSkillEffects.damage_bonus(
        character, "RogueBladeMastery"
    ) + PassiveSkillEffects.damage_bonus(
        character, "RogueEdgeDiscipline"
    ) + PassiveSkillEffects.damage_bonus(
        character, "WayfinderDaggerMastery"
    ) + PassiveSkillEffects.damage_bonus(
        character, "IronvowBladeTraining"
    )
    return math.max(
        0, base_multiplier + equipment_bonus + passive_bonus
            + active_buff(user_id, "PhysicalPower")
    )
end

--[[
Returns Dexterity-led physical ranged scaling for Ranger damage.

Args:
    user_id (number): Player user ID.

Returns:
    number: Non-negative authoritative ranged physical multiplier.
]]
function ProgressionRuntimeState.get_ranged_physical_multiplier(
    user_id: number
): number
    local baseline = AttributeConfig.ranged_physical_multiplier(
        ProgressionRuntimeState.get_attribute(user_id, "Dexterity")
    )
    local character = state_for(user_id)
    local mastery = PassiveSkillEffects.damage_bonus(
        character, "RangerBowMastery"
    ) + PassiveSkillEffects.damage_bonus(
        character, "ScoutBowDiscipline"
    ) + PassiveSkillEffects.damage_bonus(
        character, "WayfinderBowMastery"
    )
    -- Scout physical-power skills also strengthen real bow projectiles,
    -- not just the Rogue's melee attacks.
    return math.max(0, baseline + mastery
        + active_buff(user_id, "PhysicalPower"))
end

--[[
Returns actual server-owned studs added to Ranger projectile maximum range.

Args:
    user_id (number): Ranger player with authoritative owned skill ranks.

Returns:
    number: Non-negative Longbow range increase.
]]
function ProgressionRuntimeState.get_ranged_range_bonus(
    user_id: number
): number
    return PassiveSkillEffects.bow_range_bonus(
        state_for(user_id)
    )
end

--[[
Returns actual server-owned arrow flight-speed increase.

Args:
    user_id (number): Ranger player with authoritative purchased ranks.

Returns:
    number: Non-negative studs per second to add to real projectiles.
]]
function ProgressionRuntimeState.get_ranged_arrow_speed_bonus(
    user_id: number
): number
    return PassiveSkillEffects.arrow_speed_bonus(
        state_for(user_id)
    )
end

--[[
Returns the real movement multiplier earned by a Scout character.

Args:
    user_id (number): Server-authenticated character identity.

Returns:
    number: Movement multiplier, bounded to 1 through 1.06.
]]
function ProgressionRuntimeState.get_movement_multiplier(
    user_id: number
): number
    return PassiveSkillEffects.movement_multiplier(
        state_for(user_id)
    )
end

--[[
Returns the passive mitigation earned by a character wearing light
Body armour. This is a server-side defense against physical NPC hits.

Args:
    user_id (number): Defender's authoritative runtime identity.

Returns:
    number: Current physical-damage reduction, capped at eight percent.
]]
function ProgressionRuntimeState.get_light_armor_reduction(
    user_id: number
): number
    return PassiveSkillEffects.light_armor_reduction(
        state_for(user_id)
    )
end

--[[
Returns the physical-damage reduction earned by an equipped Fighter.

Args:
    user_id (number): Authentic server-owned Fighter identity.

Returns:
    number: Worn Body armour reduction from zero to 3.5%.
]]
function ProgressionRuntimeState.get_fighter_armor_reduction(
    user_id: number
): number
    return PassiveSkillEffects.fighter_armor_reduction(
        state_for(user_id)
    )
end

--[[
Returns physical-damage reduction from an actual equipped Mystic robe.

Args:
    user_id (number): Server-owned selected Mage identity.

Returns:
    number: Purchased robe mastery reduction from zero through 2.4%.
]]
function ProgressionRuntimeState.get_mystic_armor_reduction(
    user_id: number
): number
    return PassiveSkillEffects.mystic_armor_reduction(
        state_for(user_id)
    )
end

--[[
Returns the magic mitigation earned through Mystic anti-magic ranks.

Args:
    user_id (number): Server-owned selected Mage identity.

Returns:
    number: Purchased magic resistance from zero through 6%.
]]
function ProgressionRuntimeState.get_mystic_magic_reduction(
    user_id: number
): number
    return PassiveSkillEffects.mystic_magic_reduction(
        state_for(user_id)
    )
end

--[[
Returns verified original Knight resistance against enemy spell damage.

Args:
    user_id (number): Real server-owned selected character and saved rank.

Returns:
    number: Authentic Knight mitigation up to 4.8%, or zero if unearned.
]]
function ProgressionRuntimeState.get_oathguard_magic_reduction(
    user_id: number
): number
    return PassiveSkillEffects.oathguard_magic_reduction(
        state_for(user_id)
    )
end

--[[
Returns bounded real physical mitigation from a purchased starting-class
protection rank, ending automatically at first-transfer level 20.

Args:
    user_id (number): Server-authoritative character owner.

Returns:
    number: Actual novice physical damage reduction, zero to two percent.
]]
function ProgressionRuntimeState.get_novice_physical_reduction(
    user_id: number
): number
    return PassiveSkillEffects.novice_physical_reduction(
        state_for(user_id)
    )
end

--[[
Returns the accepted Spirit-based healing multiplier unchanged by 2C.C gear.

Args:
    user_id (number): Player user ID.

Returns:
    number: Authoritative healing multiplier.
]]
function ProgressionRuntimeState.get_heal_multiplier(
    user_id: number
): number
    local baseline = AttributeConfig.heal_multiplier(
        ProgressionRuntimeState.get_attribute(user_id, "Spirit")
    )
    return math.max(
        0,
        baseline + PassiveSkillEffects.heal_bonus(state_for(user_id))
    )
end

--[[
Returns the Phase 2C.D Intellect-based magical-damage multiplier.
]]
function ProgressionRuntimeState.get_magical_multiplier(
    user_id: number
): number
    local baseline = AttributeConfig.magical_multiplier(
        ProgressionRuntimeState.get_attribute(user_id, "Intellect")
    )
    local character = state_for(user_id)
    local passive_bonus = PassiveSkillEffects.damage_bonus(
        character, "ArcaneDiscipline"
    ) + PassiveSkillEffects.damage_bonus(
        character, "MysticWeaponTraining"
    )
    return math.max(
        0, baseline + passive_bonus + active_buff(user_id, "MagicPower")
    )
end

--[[
Returns the Phase 2C.D Spirit-based non-healing support multiplier.
]]
function ProgressionRuntimeState.get_support_multiplier(
    user_id: number
): number
    return AttributeConfig.support_multiplier(
        ProgressionRuntimeState.get_attribute(user_id, "Spirit")
    )
end

--[[
Returns the authoritative runtime Max Mana derived from Intellect and Spirit.
]]
function ProgressionRuntimeState.get_max_mana(
    user_id: number
): number
    return AttributeConfig.max_mana(
        ProgressionRuntimeState.get_attribute(user_id, "Intellect"),
        ProgressionRuntimeState.get_attribute(user_id, "Spirit")
    )
end

--[[
Returns the authoritative runtime Mana regeneration derived from Spirit.
]]
function ProgressionRuntimeState.get_mana_regen_per_second(
    user_id: number
): number
    local base_regen = AttributeConfig.mana_regen_per_second(
        ProgressionRuntimeState.get_attribute(user_id, "Spirit")
    )
    local robe_bonus = PassiveSkillEffects.robe_mana_regen_bonus(
        state_for(user_id)
    )
    return base_regen * (1 + robe_bonus)
end

--[[
Returns an eligible Mystic's purchased robe-only casting-rate multiplier.

Args:
    user_id (number): Server-authoritative selected character.

Returns:
    number: Casting rate from one through 1.06.
]]
function ProgressionRuntimeState.get_casting_rate_multiplier(
    user_id: number
): number
    local earned = PassiveSkillEffects.robe_casting_rate_bonus(
        state_for(user_id)
    )
    return 1 + earned
end

--[[
Calculates the real server magic wind-up from an authored skill and
earned robe-only casting speed; physical, control and channel timings
are unaffected.

Args:
    user_id (number): Authenticated caster whose equipment is checked.
    definition (any): Authoritative rank-resolved ability definition.

Returns:
    number: Non-negative actual wind-up delay for the current cast.
]]
function ProgressionRuntimeState.get_skill_wind_up_seconds(
    user_id: number,
    definition: any
): number
    local base_seconds = math.max(
        0, tonumber(definition.WIND_UP_SECONDS) or 0
    )
    if definition.KIND ~= "MagicProjectile"
        and definition.KIND ~= "MageHeal"
    then
        return base_seconds
    end
    return base_seconds
        / ProgressionRuntimeState.get_casting_rate_multiplier(user_id)
end

--[[
Returns owned and race/class-validated Scout dodge probability.

Args:
    user_id (number): Server-authenticated defender identity.
    is_moving (boolean): Server-measured Humanoid movement.

Returns:
    number: Chance to evade a direct enemy melee hit.
]]
function ProgressionRuntimeState.get_scout_evasion_chance(
    user_id: number,
    is_moving: boolean
): number
    return PassiveSkillEffects.scout_evasion_chance(
        state_for(user_id), is_moving
    )
end

--[[
Returns authoritative purchased recovery after the actual Humanoid
condition has been verified by the Stamina regeneration service.

Args:
    user_id (number): Server-authenticated selected character.
    is_sitting (boolean): Server-observed real seated state.
    is_moving (boolean): Server-observed nonzero movement.

Returns:
    number: Real resource regeneration multiplier, bounded 1..1.25.
]]
function ProgressionRuntimeState.get_stamina_recovery_multiplier(
    user_id: number,
    is_sitting: boolean,
    is_moving: boolean
): number
    return PassiveSkillEffects.stamina_recovery_multiplier(
        state_for(user_id), is_sitting, is_moving
    )
end

--[[
Returns race/attribute crit chance plus the approved Equipment crit bonus.

Args:
    user_id (number): Player user ID.

Returns:
    number: Authoritative critical chance clamped from zero to one.
]]
function ProgressionRuntimeState.get_critical_chance(
    user_id: number
): number
    local base_chance = CharacterCombatStats.critical_chance(
        attributes_for(user_id),
        ProgressionRuntimeState.get_race_id(user_id)
    )
    local equipment_bonus = equipment_effects_for(user_id)
        .CriticalChanceBonus

    local passive_bonus = PassiveSkillEffects.critical_chance_bonus(
        state_for(user_id)
    )
    return math.clamp(
        base_chance + equipment_bonus + passive_bonus,
        0, 1
    )
end

--[[
Returns accepted racial critical-damage behaviour unchanged by 2C.C gear.

Args:
    user_id (number): Player user ID.

Returns:
    number: Authoritative critical-damage multiplier.
]]
function ProgressionRuntimeState.get_critical_damage_multiplier(
    user_id: number
): number
    local racial_multiplier = CharacterCombatStats
        .critical_damage_multiplier(
            ProgressionRuntimeState.get_race_id(user_id)
        )
    local player = Players:GetPlayerByUserId(user_id)
    local toggle_bonus = 0
    if player then
        local usable = ProgressionRuntimeState.is_skill_usable(
            user_id, "ScoutCriticalPowerToggle"
        )
        if usable then
            toggle_bonus = ScoutCriticalToggleService.get_bonus(player)
        else
            ScoutCriticalToggleService.stop(player)
        end
    end
    return math.max(
        1,
        racial_multiplier + PassiveSkillEffects.critical_damage_bonus(
            state_for(user_id)
        ) + toggle_bonus
    )
end

--[[
Returns accepted racial basic-attack-rate behaviour unchanged by 2C.C gear.

Args:
    user_id (number): Player user ID.

Returns:
    number: Authoritative basic attack-rate multiplier.
]]
function ProgressionRuntimeState.get_basic_attack_rate(
    user_id: number
): number
    local baseline = CharacterCombatStats.basic_attack_rate(
        ProgressionRuntimeState.get_race_id(user_id)
    )
    local character = state_for(user_id)
    local earned_bonus = PassiveSkillEffects.attack_rate_bonus(
        character
    ) + PassiveSkillEffects.robe_attack_rate_bonus(character)
    return math.clamp(baseline * (1 + earned_bonus), 0.1, 2.0)
end

--[[
Returns racial/Vitality MaxHealth plus approved flat Equipment health.

Args:
    user_id (number): Player user ID.

Returns:
    number: Authoritative MaxHealth, never lower than one.
]]
function ProgressionRuntimeState.get_max_health(user_id: number): number
    local base_health = CharacterCombatStats.max_health(
        attributes_for(user_id),
        ProgressionRuntimeState.get_race_id(user_id)
    )
    local equipment_health = equipment_effects_for(user_id).MaxHealthFlat

    local trained_health = PassiveSkillEffects.health_bonus(
        state_for(user_id)
    )
    return math.max(
        1, base_health + equipment_health + trained_health
    )
end

--[[
Returns the purchased rank of a known runtime skill.

Args:
    user_id (number): Player user ID.
    skill_id (string): Stable skill ID.

Returns:
    number: Purchased rank, or zero when unknown/unpurchased.
]]
function ProgressionRuntimeState.get_skill_rank(
    user_id: number,
    skill_id: string
): number
    local progression = progression_for(user_id)
    local state = progression
        and progression.Skills
        and progression.Skills[skill_id]

    if type(state) ~= "table" or state.Known ~= true then
        return 0
    end

    return math.max(
        0,
        math.floor(tonumber(state.PurchasedRank) or 0)
    )
end

--[[
Checks whether one skill ID is present in the authoritative runtime loadout.

Args:
    user_id (number): Player user ID.
    skill_id (string): Stable skill ID.

Returns:
    boolean: True when the skill is equipped in any loadout slot.
]]
function ProgressionRuntimeState.is_skill_equipped(
    user_id: number,
    skill_id: string
): boolean
    local progression = progression_for(user_id)

    if not progression or type(progression.Loadout) ~= "table" then
        return false
    end

    for _, equipped_id in pairs(progression.Loadout) do
        if equipped_id == skill_id then
            return true
        end
    end

    return false
end

--[[
Checks whether a required weapon tag exists in a tag table.

Args:
    tags (any): Authoritative runtime weapon-tag table.
    required (string): Required tag name.

Returns:
    boolean: True when the required tag is represented.
]]
local function has_weapon_tag(tags: any, required: string): boolean
    if type(tags) ~= "table" then
        return false
    end

    for key, value in pairs(tags) do
        if value == required
            or (key == required and value == true)
        then
            return true
        end
    end

    return false
end

--[[
Validates purchased/equipped/weapon requirements for an active skill.

The third argument is retained for compatibility with accepted callers, but it
is deliberately ignored for authority. Weapon-family requirements are derived
only from the server runtime Equipment snapshot.

Args:
    user_id (number): Player user ID.
    skill_id (string): Stable skill ID.
    _weapon_tags (any): Legacy caller observation; ignored for authority.

Returns:
    boolean: True when the skill is usable.
    string?: Stable rejection reason, otherwise nil.
]]
function ProgressionRuntimeState.is_skill_usable(
    user_id: number,
    skill_id: string,
    _weapon_tags: any
): (boolean, string?)
    if ProgressionRuntimeState.get_skill_rank(user_id, skill_id) < 1 then
        return false, "SkillNotPurchased"
    end

    if not ProgressionRuntimeState.is_skill_equipped(user_id, skill_id) then
        return false, "SkillNotEquipped"
    end

    local definition = SkillProgressionDefinitions.get(skill_id)

    if not definition then
        return false, "UnknownSkill"
    end

    local allowed_classes = definition.AllowedBaseClasses or {}
    local correct_class = #allowed_classes == 0
    local identity = state_for(user_id).Identity
    for _, allowed_class in ipairs(allowed_classes) do
        if identity.BaseClassId == allowed_class then
            correct_class = true
            break
        end
    end
    if not correct_class then
        return false, "WrongClass"
    end

    local advanced_classes = definition.AllowedAdvancedClasses
    if type(advanced_classes) == "table" then
        local advancement = state_for(user_id).ClassAdvancement
        local active_class = advancement
            and advancement.ActiveClassId
        local matching = false
        for _, class_id in ipairs(advanced_classes) do
            if class_id == active_class then
                matching = true
                break
            end
        end
        if not matching then
            return false, "AdvancedClassRequired"
        end
    end

    local state = state_for(user_id)
    local earned, locked_reason = SkillUnlockRules.can_train({
        Level = state.Level,
        Identity = state.Identity,
        ClassAdvancement = state.ClassAdvancement,
        Progression = state.Progression,
    }, definition, ProgressionRuntimeState.get_skill_rank(
        user_id, skill_id
    ))
    if not earned then
        return false, locked_reason or "SkillLocked"
    end

    local authoritative_tags =
        ProgressionRuntimeState.get_weapon_tags(user_id)

    for _, required in ipairs(definition.WeaponTags or {}) do
        if not has_weapon_tag(authoritative_tags, required) then
            return false, "WrongWeapon"
        end
    end

    -- A shield attack may be learned without a shield but NEVER cast
    -- unless a real server-equipped offhand is registered as a Shield.
    -- Client-supplied weapon tags cannot satisfy this equipment gate.
    if definition.RequiresShield == true then
        local state_equipment = state.Equipment
        local shield_id = type(state_equipment) == "table"
            and state_equipment.OffHand or nil
        local shield = if type(shield_id) == "string"
            then ItemDefinitions.get(shield_id) else nil
        if not shield or shield.Kind ~= "Equipment"
            or shield.Slot ~= "OffHand"
            or shield.Category ~= "Shield"
        then
            return false, "ShieldRequired"
        end
    end

    return true, nil
end

--[[
Applies authoritative MaxHealth while preserving accepted full-health logic.

Args:
    player (Player): Player whose current Humanoid is updated.

Returns:
    None.
]]
local function apply_health(player: Player)
    local character = player.Character

    if not character then
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not humanoid then
        return
    end

    local previous_max = humanoid.MaxHealth
    local new_max = ProgressionRuntimeState.get_max_health(player.UserId)

    humanoid.MaxHealth = new_max

    if humanoid.Health > new_max then
        humanoid.Health = new_max
    elseif humanoid.Health >= previous_max - 0.001 then
        humanoid.Health = new_max
    end
end

--[[
Compatibility wrapper that reapplies authoritative MaxHealth only.

Args:
    player (Player): Player whose Humanoid is updated.

Returns:
    None.
]]
function ProgressionRuntimeState.apply_max_health(player: Player)
    apply_health(player)
end

--[[
Publishes authoritative runtime combat values and presentation item IDs.

Presentation IDs are written to Player attributes so Dungeon visual services
can follow server Equipment without reading profiles or owning combat stats.

Args:
    player (Player): Player receiving current runtime attributes/health.

Returns:
    None.
]]
function ProgressionRuntimeState.apply_runtime_stats(player: Player)
    local effects = equipment_effects_for(player.UserId)

    player:SetAttribute(
        EquipmentPresentationRules.WEAPON_ITEM_ATTRIBUTE,
        effects.WeaponItemId
    )
    player:SetAttribute(
        EquipmentPresentationRules.OFFHAND_ITEM_ATTRIBUTE,
        effects.OffHandItemId
    )

    local character = player.Character

    if not character then
        return
    end

    character:SetAttribute(
        "DungeonMMOBasicAttackRate",
        ProgressionRuntimeState.get_basic_attack_rate(player.UserId)
    )

    apply_health(player)
end

return table.freeze(ProgressionRuntimeState)
