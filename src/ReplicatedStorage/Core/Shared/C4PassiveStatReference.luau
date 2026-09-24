--!strict
-- Read-only source C4 passive stat operations on supplied source stats.
-- This is NOT connected to live combat, items, buffs or player profiles.
local Source = require(script.Parent.C4SkillEffectSource)

local C4PassiveStatReference = {}

--[[
Checks a source equipment condition without guessing Roblox item tags.

Args:
    allowed (string?): Source comma-separated weapon or armour kinds.
    equipped_kind (string?): Historical kind of actual source equipment.

Returns:
    boolean: Whether an equipped original item meets this exact kind.
]]
local function uses_kind(allowed: string?, equipped_kind: string?): boolean
    if allowed == nil then return true end
    if not equipped_kind then return false end
    for kind in string.gmatch(allowed, "[^,]+") do
        local trimmed = kind:match("^%s*(.-)%s*$")
        if trimmed == equipped_kind then return true end
    end
    return false
end

--[[
Checks every source-wide equipment condition on one original skill.

Args:
    conditions (any): Exact source Conditions table, possibly empty.
    equipped_kind (string?): C4 equipment kind to check.

Returns:
    (boolean, string?): Allowed status and reason for unsupported rules.
]]
local function meets_conditions(
    conditions: any, equipped_kind: string?
): (boolean, string?)
    for _, condition in ipairs(conditions) do
        if condition.Tag ~= "using" or type(condition.kind) ~= "string"
        then
            return false, "UnsupportedSourceCondition"
        end
        if not uses_kind(condition.kind, equipped_kind) then
            return false, nil
        end
    end
    return true, nil
end

--[[
Parses original calculator priorities such as hexadecimal 0x30.

Args:
    priority (any): Source modifier order.

Returns:
    number?: C4 numerical order, or nil if not represented here.
]]
local function order_number(priority: any): number?
    if type(priority) == "number" then return priority end
    if type(priority) ~= "string" then return nil end
    if priority:sub(1, 2) == "0x" then
        return tonumber(priority:sub(3), 16)
    end
    return tonumber(priority)
end

--[[
Creates a sorted source modifier record while retaining input order.

Args:
    modifier (any): Exact C4 source modifier row.
    index (number): Stable index across all source skill ranks.

Returns:
    (any?, string?): Strict operation or fail-closed unsupported reason.
]]
local function source_operation(
    modifier: any, index: number
): (any?, string?)
    local operation = modifier.Operation
    local order = order_number(modifier.order)
    local value = modifier.val
    if operation ~= "add" and operation ~= "mul" then
        return nil, "UnsupportedSourceOperation"
    end
    if not order or type(value) ~= "number"
        or value ~= value or math.abs(value) >= math.huge
        or type(modifier.stat) ~= "string"
    then
        return nil, "InvalidSourceModifier"
    end
    return {
        Stat = modifier.stat, Operation = operation, Value = value,
        Order = order, Index = index, UsingKind = modifier.UsingKind,
    }, nil
end

--[[
Collects original passive rows only, without applying active buffs.

Args:
    source_ranks (any): List of {SkillId:number, Rank:number}.
    equipped_kind (string?): Original C4 weapon/armour kind.

Returns:
    (any?, string?): Sortable original operations or refusal reason.
]]
local function collect_passives(
    source_ranks: any, equipped_kind: string?
): (any?, string?)
    local modifiers = {}
    local seen = {}
    for _, rank_id in ipairs(source_ranks) do
        local id = rank_id.SkillId
        if seen[id] then return nil, "DuplicateSourcePassive" end
        seen[id] = true
        local rank = Source.get_rank(id, rank_id.Rank)
        if not rank then return nil, "UnknownOriginalSkillRank" end
        if rank.Sets.operateType ~= "PASSIVE" then
            return nil, "ActiveOrToggleSkillRequiresSeparateExecutor"
        end
        local allowed, issue = meets_conditions(
            rank.Conditions, equipped_kind
        )
        if issue then return nil, issue end
        if allowed then
            for _, modifier in ipairs(rank.Modifiers) do
                if uses_kind(modifier.UsingKind, equipped_kind) then
                    local item, reason = source_operation(
                        modifier, #modifiers + 1
                    )
                    if not item then return nil, reason end
                    table.insert(modifiers, item)
                end
            end
        end
    end
    table.sort(modifiers, function(left, right)
        if left.Order == right.Order then
            return left.Index < right.Index
        end
        return left.Order < right.Order
    end)
    return modifiers, nil
end

--[[
Applies C4 passive modifiers in calculator order to supplied stats.

Equipment values and character growth must already be authentic C4
inputs. Only additive and multiplicative source modifiers are supported.
A missing stat or unsupported source operation rejects the entire call.

Args:
    source_stats (any): Historical stat-name to numerical base values.
    equipped_kind (string?): Exact C4 weapon/armour kind or nil.
    source_ranks (any): One or more distinct original passive ranks.

Returns:
    (any?, string?): New stat table and source operation count, or reason.
]]
function C4PassiveStatReference.apply(
    source_stats: any, equipped_kind: string?, source_ranks: any
): (any?, string?)
    if type(source_stats) ~= "table" or type(source_ranks) ~= "table"
    then return nil, "InvalidSourceInputs" end
    local modifiers, reason = collect_passives(
        source_ranks, equipped_kind
    )
    if not modifiers then return nil, reason end
    local values = table.clone(source_stats)
    for _, modifier in ipairs(modifiers) do
        local current = values[modifier.Stat]
        if type(current) ~= "number" or current ~= current
            or math.abs(current) >= math.huge
        then
            return nil, "MissingOrInvalidOriginalStat:"
                .. modifier.Stat
        end
        values[modifier.Stat] = if modifier.Operation == "add"
            then current + modifier.Value
            else current * modifier.Value
    end
    return {
        Stats = values,
        AppliedModifiers = #modifiers,
        SourceOnly = true,
        LiveCombatIntegrated = false,
    }, nil
end

return table.freeze(C4PassiveStatReference)
