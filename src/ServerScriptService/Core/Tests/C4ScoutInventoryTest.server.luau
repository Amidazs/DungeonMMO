--!strict
-- Every raw C4 first-transfer rank is accounted for exactly once.

local Shared = game:GetService("ReplicatedStorage").Core.Shared
local Inventory = require(Shared.C4ScoutSkillInventory)
local Targets = require(Shared.C4ScoutReferenceTargets)
local Progression = require(Shared.SkillProgressionDefinitions)
local Combat = require(
    game:GetService("ReplicatedStorage").Combat.Shared.SkillDefinitions
)

local assertions = 0
local LEVELS = {20, 24, 28, 32, 36}
local EXPECTED = {
    Human = {Raw = 99, Functional = 81, Missing = 18,
        EquipmentMismatch = 0},
    Elf = {Raw = 129, Functional = 108, Missing = 21,
        EquipmentMismatch = 0},
}

--[[
Records an authoritative catalogue-coverage assertion.

Args:
    condition (boolean): Whether one inventory claim is accurate.
    description (string): Actionable inventory diagnostic.

Returns:
    nil: Counts the pass or raises immediately.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 Scout Inventory] " .. description)
end

--[[
Counts the exact authored ranks for a source category at one level.

Args:
    definition (any): Registered DungeonMMO progression definition.
    level (number): C4 source training bracket.

Returns:
    number: Number of distinct authored ranks offered at the level.
]]
local function ranks_at_level(definition: any, level: number): number
    local count = 0
    for rank = 1, definition.MaxRank do
        if definition.RankLevels[rank] == level then
            count += 1
        end
    end
    return count
end

--[[
Verifies one source family maps to a valid class-appropriate real effect.

Args:
    race_id (string): Source class race identifier.
    category (string): C4 skill family.
    level (number): Exact level being checked.
    count (number): Raw source rank entries at the level.

Returns:
    nil: Confirms mapped rank volume, owner and combat/passive effect.
]]
local function check_implementation(
    race_id: string, category: string, level: number, count: number
)
    local mapping = Inventory.implementation(category, race_id)
    if not mapping then
        return
    end
    local definition = assert(Progression.get(mapping.SkillId))
    check(ranks_at_level(definition, level) == count,
        race_id .. " " .. category .. " has wrong rank volume "
            .. "at level " .. tostring(level))
    local owned = false
    for _, class_id in ipairs(definition.AllowedBaseClasses or {}) do
        if mapping.Owner == "RangerRogue"
            or mapping.Owner == class_id then
            owned = true
        end
    end
    check(owned, mapping.SkillId .. " is not owned by its mapped class")

    if mapping.DaggerEquipmentPending == false
        and (category == "DaggerAttack"
            or category == "DaggerMastery"
            or category == "Bleed")
    then
        check(table.find(definition.WeaponTags or {}, "Dagger")
            ~= nil, "Dagger skill is not actually weapon-gated")
    end
    if category == "CurePoison" then
        local effect = assert(Combat.get_for_rank(mapping.SkillId, 1))
        check(effect.KIND == "MageHeal"
            and effect.TOTAL_HEAL == 0
            and effect.SELF_ONLY == true
            and effect.CURE_POISON_TIER >= 3
            and effect.MANA_COST > 0,
            "Elven Scout poison recovery must actually cleanse self")
    elseif category == "ActiveEvasion" or category == "DefenseBuff" then
        local effect = assert(Combat.get_for_rank(mapping.SkillId, 1))
        local kind = if category == "ActiveEvasion"
            then "Evasion" else "PhysicalGuard"
        check(effect.KIND == "Buff" and effect.BUFF_KIND == kind
            and effect.BUFF_MAGNITUDE > 0 and effect.BUFF_SECONDS > 0
            and effect.COOLDOWN_SECONDS > 0,
            mapping.SkillId .. " must execute a real timed combat status")
    elseif definition.Kind == "Passive" then
        local bonus = definition.DamageBonusPerRank
            or definition.PhysicalReductionPerRank
            or definition.CriticalDamageBonusPerRank
            or definition.CriticalChanceBonusPerRank
            or definition.RestingStaminaBonusPerRank
            or definition.RunningStaminaBonusPerRank
            or definition.EvasionChancePerRank
            or definition.MovementBonusPerRank
            or definition.AttackRateBonusPerRank
            or definition.BowRangeBonusStudsPerRank
            or definition.ArrowSpeedBonusPerRank
        check(type(bonus) == "number" and bonus > 0,
            mapping.SkillId .. " has no real passive stat effect")
    else
        local previous_effect = 0
        for rank = 1, definition.MaxRank do
            local effect = assert(Combat.get_for_rank(
                mapping.SkillId, rank
            ))
            local magnitude = if definition.Kind == "Support"
                then effect.TOTAL_HEAL else effect.BASE_DAMAGE
            check(type(magnitude) == "number"
                and magnitude > previous_effect,
                mapping.SkillId .. " has an unimplemented effect rank")
            if category == "HPRegeneration" then
                check(effect.SELF_ONLY == true,
                    "Elven regeneration must never heal a selected ally")
            elseif category == "ThreatCharm" then
                check(effect.THREAT_REDUCTION_FRACTION > 0
                    and effect.THREAT_REDUCTION_FRACTION <= 0.85,
                    "Elven charm must actually reduce server threat")
            end
            previous_effect = magnitude
        end
    end
end

--[[
Audits raw-source, analogue, remaining and dagger-mismatch totals.

Args:
    race_id (string): Human Rogue or Elf Elven Scout.

Returns:
    nil: Asserts every bracket/category exactly against C4 targets.
]]
local function check_race(race_id: string)
    local source = assert(Inventory.get(race_id))
    local reference = assert(Targets.get(race_id))
    local audit = assert(Inventory.audit(race_id))
    local expected = EXPECTED[race_id]

    for _, level in ipairs(LEVELS) do
        local sum = 0
        for category, count in pairs(source.Levels[level]) do
            check(type(count) == "number" and count > 0,
                race_id .. " has an invalid source rank count")
            sum += count
            check_implementation(race_id, category, level, count)
        end
        check(sum == reference.Levels[level],
            race_id .. " level " .. level .. " disagrees with source")
        check(audit.Levels[level].Raw == sum,
            race_id .. " level " .. level .. " raw audit mismatch")
        check(audit.Levels[level].Functional
            + audit.Levels[level].Missing == sum,
            race_id .. " level " .. level .. " double-counts ranks")
    end

    for field, expected_count in pairs(expected) do
        check(audit[field] == expected_count,
            race_id .. " incorrect " .. field .. " total")
    end
    check(audit.EquipmentMismatch <= audit.Functional,
        "Dagger equipment mismatch cannot exceed implemented volume")
    local remaining = 0
    for family, count in pairs(audit.MissingFamilies) do
        check(Inventory.implementation(family, race_id) == nil,
            race_id .. " missing inventory contains a mapped ability")
        check(count > 0,
            race_id .. " missing family " .. family .. " has zero ranks")
        remaining += count
    end
    check(remaining == audit.Missing,
        race_id .. " missing family ledger does not reconcile")
    check(audit.Missing > 0,
        "Incomplete C4 Scout catalogue must not be declared complete")

    -- Sorted missing source families form the next actionable content gate.
    local pending = {}
    for family, count in pairs(audit.MissingFamilies) do
        table.insert(pending, family .. "=" .. tostring(count))
    end
    table.sort(pending)
    print(("[C4 Scout Inventory] %s %d/%d, missing %d: %s")
        :format(
            race_id, audit.Functional, audit.Raw,
            audit.Missing, table.concat(pending, ", ")
        ))
end

check_race("Human")
check_race("Elf")
check(Inventory.get("Orc") == nil,
    "Unmapped races must not be mistaken for C4 Scout coverage")
print(("[C4 Scout Inventory] PASS: %d assertions."):format(
    assertions
))
