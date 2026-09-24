--!strict
-- Exact C4 XML effect catalogue coverage; no live skill values are changed.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared
local Tree = require(Shared.C4Level30SkillTreeSource)
local Effects = require(Shared.C4SkillEffectSource)

local checks = 0

--[[
Counts one source-effect catalogue assertion.

Args:
    valid (boolean): Expected rank-resolved C4 source condition.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Skill Effects] " .. label)
end

--[[
Finds a passive modifier by source stat name.

Args:
    rank (any): Rank-resolved C4 source definition.
    stat_name (string): Original source stat identifier.

Returns:
    any?: First matching source modifier.
]]
local function find_modifier(rank: any, stat_name: string): any?
    for _, modifier in ipairs(rank.Modifiers) do
        if modifier.stat == stat_name then
            return modifier
        end
    end
    return nil
end

--[[
Checks every learning-tree skill/rank resolves to pinned XML facts.

Args:
    None.

Returns:
    nil: All nine paths' exact source ranks are present.
]]
local function check_all_tree_rows()
    for _, scope in ipairs(Tree.coverage().Scopes) do
        local class = assert(Tree.get(scope.ScopeId))
        for _, row in ipairs(class.Rows) do
            local rank = Effects.get_rank(
                row.SkillId, row.SkillLevel
            )
            check(rank ~= nil,
                scope.ScopeId .. " source effect "
                    .. tostring(row.SkillId) .. ":"
                    .. tostring(row.SkillLevel))
        end
    end
end

--[[
Checks representative active, passive, control and utility source fields.

Args:
    None.

Returns:
    nil: Verifies parser resolved source tables at exact skill ranks.
]]
local function check_known_vectors()
    local strike = assert(Effects.get_rank(3, 1))
    check(strike.Sets.mpConsume == 10
        and strike.Sets.power == 25
        and strike.Sets.hitTime == 1080
        and strike.Sets.reuseDelay == 13000
        and strike.Sets.skillType == "PDAM",
        "Power Strike rank1 exact active source fields")

    local stun = assert(Effects.get_rank(100, 3))
    check(stun.Sets.mpConsume == 22
        and stun.Sets.power == 35
        and stun.Sets.effectType == "STUN"
        and stun.Sets.effectPower == 50
        and stun.Sets.saveVs == "CON",
        "Warrior Stun Attack rank3 exact status fields")

    local bow = assert(Effects.get_rank(208, 18))
    local bow_attack = find_modifier(bow, "PHYSICAL_ATTACK")
    check(bow_attack ~= nil
        and bow_attack.Operation == "add"
        and bow_attack.UsingKind == "Bow",
        "Scout Bow Mastery source passive keeps Bow condition")

    local common = assert(Effects.get_rank(1320, 3))
    check(common.Sets.target == "TARGET_SELF"
        and common.Sets.skillType == "DUMMY"
        and common.Sets.operateType == "PASSIVE",
        "Create Common Item rank3 exact passive identity")

    local expertise = assert(Effects.get_rank(239, 1))
    check(expertise.Sets.target == "TARGET_SELF"
        and expertise.Sets.operateType == "PASSIVE",
        "Expertise D rank1 exact passive identity")

    local heal = assert(Effects.get_rank(58, 4))
    check(heal.Sets.mpConsume == 53,
        "Elven Elemental Heal C4 rank4 exact MP")
end

--[[
Runs source XML coverage for the whole current original class catalogue.

Args:
    None.

Returns:
    nil: Prints effect-source coverage, never live effect parity.
]]
local function main()
    check_all_tree_rows()
    check_known_vectors()
    local coverage = Effects.coverage()
    check(coverage.SkillCount == 75
        and coverage.RequiredSkillRankPairs == 272
        and not coverage.LiveCombatIntegrated,
        "All required source skill/rank definitions are catalogued")
    print(("[C4 Skill Effects] EXACT_SOURCE_PASS: %d assertions, "
        .. "skills=75 uniqueRankPairs=272 live=false")
        :format(checks))
end

main()
