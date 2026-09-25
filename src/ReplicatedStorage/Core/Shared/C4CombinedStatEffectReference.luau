--!strict
-- C4 calculator ordering across owned passive and currently active effects.

local Source = require(script.Parent.C4SkillEffectSource)

local C4CombinedStatEffectReference = {}

local NEUTRAL_STATS = table.freeze({
    BOW_WPN_VULN = 1,
    PHYSICAL_CRITICAL_POWER_ADD = 0,
})

--[[
Checks a source equipment kind condition against reviewed paperdoll kinds.

Args:
    allowed (string?): Source comma-separated equipment kinds.
    equipment (any): Reviewed source-kind loadout.

Returns:
    boolean: True when at least one equipped source kind matches.
]]
local function uses_kind(allowed: string?, equipment: any): boolean
    if allowed == nil then
        return true
    end

    if type(equipment) ~= "table" then
        return false
    end

    for kind in string.gmatch(allowed, "[^,]+") do
        local trimmed = kind:match("^%s*(.-)%s*$")

        for _, slot in ipairs({"Weapon", "Body", "OffHand"}) do
            if equipment[slot] == trimmed then
                return true
            end
        end
    end

    return false
end

--[[
Validates source-wide passive equipment conditions.

Args:
    conditions (any): Exact source Conditions table.
    equipment (any): Reviewed source-kind loadout.

Returns:
    (boolean, string?): Allowed state or unsupported condition reason.
]]
local function meets_passive_conditions(
    conditions: any,
    equipment: any
): (boolean, string?)
    for _, condition in ipairs(conditions) do
        if condition.Tag ~= "using"
            or type(condition.kind) ~= "string"
        then
            return false, "UnsupportedSourceCondition"
        end

        if not uses_kind(condition.kind, equipment) then
            return false, nil
        end
    end

    return true, nil
end

--[[
Converts a C4 calculator order into a sortable number.

Args:
    priority (any): Decimal or hexadecimal source order.

Returns:
    number?: Parsed calculator order, or nil when invalid.
]]
local function order_number(priority: any): number?
    if type(priority) == "number" then
        return priority
    end

    if type(priority) ~= "string" then
        return nil
    end

    if priority:sub(1, 2) == "0x" then
        return tonumber(priority:sub(3), 16)
    end

    return tonumber(priority)
end

--[[
Converts one exact source modifier into an ordered operation record.

Args:
    modifier (any): C4 source modifier row.
    index (number): Stable collection order.
    skill_id (number): Historical source skill ID.
    rank (number): Historical source skill rank.
    origin (string): Passive or Active provenance.

Returns:
    (any?, string?): Ordered operation or strict rejection reason.
]]
local function source_operation(
    modifier: any,
    index: number,
    skill_id: number,
    rank: number,
    origin: string
): (any?, string?)
    local operation = modifier.Operation
    local order = order_number(modifier.order)
    local value = modifier.val

    if operation ~= "add"
        and operation ~= "sub"
        and operation ~= "mul"
    then
        return nil, "UnsupportedSourceOperation"
    end

    if not order
        or type(value) ~= "number"
        or value ~= value
        or math.abs(value) >= math.huge
        or type(modifier.stat) ~= "string"
    then
        return nil, "InvalidSourceModifier"
    end

    return {
        Stat = modifier.stat,
        Operation = operation,
        Value = value,
        Order = order,
        Index = index,
        UsingKind = modifier.UsingKind,
        SourceSkillId = skill_id,
        SourceRank = rank,
        Origin = origin,
    }, nil
end

--[[
Collects one highest owned rank from each passive source skill.

Args:
    source_ranks (any): Distinct owned passive SkillId/Rank pairs.
    equipment (any): Reviewed source-kind loadout.
    operations (any): Mutable combined operation list.

Returns:
    (boolean, string?): Success or strict source-data reason.
]]
local function collect_passives(
    source_ranks: any,
    equipment: any,
    operations: any
): (boolean, string?)
    local seen = {}

    for _, rank_id in ipairs(source_ranks) do
        local skill_id = rank_id.SkillId
        local rank_number = rank_id.Rank

        if type(skill_id) ~= "number"
            or type(rank_number) ~= "number"
            or seen[skill_id]
        then
            return false, "DuplicateOrInvalidSourcePassive"
        end
        seen[skill_id] = true

        local rank = Source.get_rank(skill_id, rank_number)
        if not rank then
            return false, "UnknownOriginalSkillRank"
        end
        if rank.Sets.operateType ~= "PASSIVE" then
            return false, "NonPassiveRankInPassiveSnapshot"
        end

        local allowed, condition_reason =
            meets_passive_conditions(rank.Conditions, equipment)
        if condition_reason then
            return false, condition_reason
        end

        if allowed then
            for _, modifier in ipairs(rank.Modifiers) do
                if uses_kind(modifier.UsingKind, equipment) then
                    local operation, reason = source_operation(
                        modifier,
                        #operations + 1,
                        skill_id,
                        rank_number,
                        "Passive"
                    )
                    if not operation then
                        return false, reason
                    end
                    table.insert(operations, operation)
                end
            end
        end
    end

    return true, nil
end

--[[
Selects the source-active effect that is in use for each C4 stack group.

Effects without a stack type are independent. For a named stack group, the
highest stackOrder is the effect whose stat functions are in use in C4.

Args:
    active_ranks (any): Authoritative active source SkillId/Rank pairs.

Returns:
    (any?, string?): Selected source effects or strict validation reason.
]]
local function select_active_effects(
    active_ranks: any
): (any?, string?)
    local selected = {}
    local stack_winners = {}
    local seen_skills = {}

    for _, rank_id in ipairs(active_ranks) do
        local skill_id = rank_id.SkillId
        local rank_number = rank_id.Rank

        if type(skill_id) ~= "number"
            or type(rank_number) ~= "number"
            or seen_skills[skill_id]
        then
            return nil, "DuplicateOrInvalidActiveSourceSkill"
        end
        seen_skills[skill_id] = true

        local rank = Source.get_rank(skill_id, rank_number)
        if not rank then
            return nil, "UnknownOriginalActiveSkillRank"
        end

        local operate_type = rank.Sets.operateType
        if operate_type ~= "ACTIVE" and operate_type ~= "TOGGLE" then
            return nil, "PassiveRankInActiveSnapshot"
        end

        local found_modifier_effect = false
        for effect_index, effect in ipairs(rank.Effects) do
            if type(effect.Modifiers) == "table"
                and #effect.Modifiers > 0
            then
                found_modifier_effect = true
                local stack_type = effect.stackType or "none"
                local stack_order = tonumber(effect.stackOrder) or 0
                local candidate = {
                    SkillId = skill_id,
                    Rank = rank_number,
                    EffectIndex = effect_index,
                    StackType = stack_type,
                    StackOrder = stack_order,
                    Modifiers = effect.Modifiers,
                }

                if stack_type == "none" then
                    table.insert(selected, candidate)
                else
                    local current = stack_winners[stack_type]
                    if not current
                        or stack_order >= current.StackOrder
                    then
                        stack_winners[stack_type] = candidate
                    end
                end
            end
        end

        if #rank.Modifiers > 0 and not found_modifier_effect then
            return nil, "ActiveModifierWithoutEffectBoundary"
        end
    end

    for _, candidate in pairs(stack_winners) do
        table.insert(selected, candidate)
    end

    table.sort(selected, function(left, right)
        if left.SkillId == right.SkillId then
            return left.EffectIndex < right.EffectIndex
        end
        return left.SkillId < right.SkillId
    end)

    return selected, nil
end

--[[
Collects selected active/toggle effect modifiers into calculator operations.

Args:
    active_ranks (any): Authoritative currently active source effects.
    equipment (any): Reviewed source-kind loadout.
    operations (any): Mutable combined operation list.

Returns:
    (any?, string?): Selected effects or strict source-data reason.
]]
local function collect_active(
    active_ranks: any,
    equipment: any,
    operations: any
): (any?, string?)
    local selected, reason = select_active_effects(active_ranks)
    if not selected then
        return nil, reason
    end

    for _, effect in ipairs(selected) do
        for _, modifier in ipairs(effect.Modifiers) do
            if uses_kind(modifier.UsingKind, equipment) then
                local operation, operation_reason = source_operation(
                    modifier,
                    #operations + 1,
                    effect.SkillId,
                    effect.Rank,
                    "Active"
                )
                if not operation then
                    return nil, operation_reason
                end
                table.insert(operations, operation)
            end
        end
    end

    return selected, nil
end

--[[
Applies one ordered source operation to a mutable source stat dictionary.

Only two missing source stats currently have proven C4 neutral bases:
bow-weapon vulnerability starts at 1 and additive critical-power starts at 0.

Args:
    values (any): Mutable source stat values.
    operation (any): Validated ordered source operation.

Returns:
    (boolean, string?): Success or missing-stat/operation reason.
]]
local function apply_operation(
    values: any,
    operation: any
): (boolean, string?)
    local current = values[operation.Stat]

    if current == nil then
        current = NEUTRAL_STATS[operation.Stat]
        if current ~= nil then
            values[operation.Stat] = current
        end
    end

    if type(current) ~= "number"
        or current ~= current
        or math.abs(current) >= math.huge
    then
        return false, "MissingOrInvalidOriginalStat:"
            .. operation.Stat
    end

    if operation.Operation == "add" then
        values[operation.Stat] = current + operation.Value
    elseif operation.Operation == "sub" then
        values[operation.Stat] = current - operation.Value
    elseif operation.Operation == "mul" then
        values[operation.Stat] = current * operation.Value
    else
        return false, "UnsupportedSourceOperation"
    end

    return true, nil
end

--[[
Applies owned passives and actually active C4 effects in one calculator order.

This is the important ordering boundary: all 0x30 operations are applied before
all 0x40 operations regardless of whether the function came from a permanent
passive, a timed buff or a toggle. Named stack groups contribute only their
highest source stackOrder effect.

Args:
    source_stats (any): Item-staged C4 stat dictionary.
    equipment (any): Reviewed C4 source-kind paperdoll.
    passive_ranks (any): Actually owned historical passive ranks.
    active_ranks (any): Actually active historical active/toggle ranks.

Returns:
    (any?, string?): Combined source stat snapshot or strict rejection reason.
]]
function C4CombinedStatEffectReference.apply(
    source_stats: any,
    equipment: any,
    passive_ranks: any,
    active_ranks: any
): (any?, string?)
    if type(source_stats) ~= "table"
        or type(equipment) ~= "table"
        or type(passive_ranks) ~= "table"
        or type(active_ranks) ~= "table"
    then
        return nil, "InvalidCombinedSourceInputs"
    end

    local operations = {}
    local passive_ok, passive_reason = collect_passives(
        passive_ranks,
        equipment,
        operations
    )
    if not passive_ok then
        return nil, passive_reason
    end

    local selected, active_reason = collect_active(
        active_ranks,
        equipment,
        operations
    )
    if not selected then
        return nil, active_reason
    end

    table.sort(operations, function(left, right)
        if left.Order == right.Order then
            return left.Index < right.Index
        end
        return left.Order < right.Order
    end)

    local values = table.clone(source_stats)
    for _, operation in ipairs(operations) do
        local ok, reason = apply_operation(values, operation)
        if not ok then
            return nil, reason
        end
    end

    return {
        Stats = values,
        AppliedModifiers = #operations,
        SelectedActiveEffects = selected,
        SourceOnly = true,
        LiveCombatIntegrated = false,
    }, nil
end

return table.freeze(C4CombinedStatEffectReference)
