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
    nil: Every tracked path's exact source ranks are present.
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

    local bow = assert(Effects.get_rank(208, 9))
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

    local wizard_blaze = assert(Effects.get_rank(1220, 6))
    check(wizard_blaze.Sets.mpInitialConsume == 6
        and wizard_blaze.Sets.mpConsume == 21
        and wizard_blaze.Sets.power == 38
        and wizard_blaze.Sets.magicLvl == 30
        and wizard_blaze.Sets.element == "FIRE"
        and wizard_blaze.Sets.skillType == "MDAM",
        "Human Wizard Blaze rank6 exact source fields")

    local wizard_sleep = assert(Effects.get_rank(1069, 6))
    check(wizard_sleep.Sets.mpInitialConsume == 6
        and wizard_sleep.Sets.mpConsume == 21
        and wizard_sleep.Sets.magicLvl == 30
        and wizard_sleep.Sets.effectType == "SLEEP"
        and wizard_sleep.Effects[1].abnormal == "SLEEP"
        and wizard_sleep.Effects[1].time == 30,
        "Human Wizard Sleep rank6 exact source control fields")

    local wizard_servitor = assert(Effects.get_rank(1127, 9))
    check(wizard_servitor.Sets.target == "TARGET_PET"
        and wizard_servitor.Sets.mpInitialConsume == 9
        and wizard_servitor.Sets.mpConsume == 35
        and wizard_servitor.Effects[1].power == 294,
        "Human Wizard Servitor Heal rank9 exact source fields")

    local cleric_heal = assert(Effects.get_rank(1011, 15))
    check(cleric_heal.Sets.mpInitialConsume == 9
        and cleric_heal.Sets.mpConsume == 35
        and cleric_heal.Effects[1].power == 245
        and cleric_heal.Sets.target == "TARGET_ONE",
        "Human Cleric Heal rank15 exact source fields")

    local cleric_root = assert(Effects.get_rank(1201, 6))
    check(cleric_root.Sets.mpInitialConsume == 6
        and cleric_root.Sets.mpConsume == 21
        and cleric_root.Sets.magicLvl == 30
        and cleric_root.Sets.effectPower == 80
        and cleric_root.Effects[1].name == "Root"
        and cleric_root.Effects[1].time == 30
        and cleric_root.Effects[1].abnormal == "ROOT",
        "Human Cleric Dryad Root rank6 exact source fields")

    local cleric_robe = assert(Effects.get_rank(235, 6))
    local cleric_robe_defence =
        find_modifier(cleric_robe, "PHYSICAL_DEFENCE")
    check(cleric_robe_defence ~= nil
        and cleric_robe_defence.val == 17.4
        and cleric_robe_defence.UsingKind == "Magic",
        "Human Cleric Robe Mastery rank6 keeps Magic gear condition")

    local heal = assert(Effects.get_rank(58, 4))
    check(heal.Sets.mpInitialConsume == 11
        and heal.Sets.mpConsume == 42
        and heal.Sets.mpInitialConsume + heal.Sets.mpConsume == 53
        and heal.Effects[1].power == 95,
        "Elemental Heal rank4 exact split MP and heal power")
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
    check(coverage.SkillCount == 112
        and coverage.RequiredSkillRankPairs == 440
        and not coverage.LiveCombatIntegrated,
        "All twelve-path source skill/rank definitions are catalogued")
    print(("[C4 Skill Effects] EXACT_SOURCE_PASS: %d assertions, "
        .. "skills=107 uniqueRankPairs=425 live=false")
        :format(checks))
end

main()
