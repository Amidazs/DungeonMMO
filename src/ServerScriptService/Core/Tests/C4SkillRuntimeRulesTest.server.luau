--!strict
-- Pure pinned C4 split-MP, instant-heal and magic-cast rule vectors.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Core.Shared
local Rules = require(Shared.C4SkillRuntimeRules)

local checks = 0

--[[
Records one deterministic source-rule assertion.

Args:
    condition (boolean): Expected source-equivalent result.
    label (string): Diagnostic for the first failed assertion.

Returns:
    nil: Increments the check count or raises on failure.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Skill Runtime Rules] " .. label)
end

--[[
Checks original Elemental Heal rank-four resource and heal semantics.

Args:
    None.

Returns:
    nil: Confirms split MP timing and shot-amplified heal amounts.
]]
local function check_elemental_heal_vectors()
    local costs = Rules.split_mana_cost(11, 42)
    check(costs.InitialMP == 11
        and costs.OngoingMP == 42
        and costs.TotalMP == 53,
        "rank-four split cost must remain 11 + 42 = 53")
    check(not Rules.can_begin_split_mana_cast(52, 11, 42),
        "52 MP must fail the original 53 MP affordability gate")
    check(Rules.can_begin_split_mana_cast(53, 11, 42),
        "53 MP must satisfy the original total-cost gate")

    local after_start, reason = Rules.begin_split_mana_cast(
        53,
        11,
        42
    )
    check(after_start == 42 and reason == nil,
        "cast start must spend only the 11 initial MP")
    check(Rules.finish_split_mana_cast(42, 42) == 0,
        "skill launch must then spend the 42 ongoing MP")
    check(Rules.finish_split_mana_cast(20, 42) == 0,
        "source launch reduction must clamp depleted MP at zero")

    check(Rules.instant_heal(95, false, false) == 95,
        "uncharged rank-four heal must restore source power 95")
    check(Rules.instant_heal(95, true, false) == 123.5,
        "Spiritshot must multiply instant heal by 1.3")
    check(Rules.instant_heal(95, false, true) == 142.5,
        "Blessed Spiritshot must multiply instant heal by 1.5")
end

--[[
Checks source magic-cast speed and shot acceleration order.

Args:
    None.

Returns:
    nil: Confirms scaling, 70-percent shot cast and 500 ms floor.
]]
local function check_magic_cast_vectors()
    check(Rules.magic_cast_time(5000, 333, false, false) == 5000,
        "333 M.Atk.Spd must preserve a 5000 ms authored cast")
    check(Rules.magic_cast_time(5000, 333, true, false) == 3500,
        "Spiritshot must reduce the scaled cast to 70 percent")
    check(Rules.magic_cast_time(5000, 333, false, true) == 3500,
        "Blessed Spiritshot uses the same 70-percent cast acceleration")
    check(Rules.magic_cast_time(500, 1000, true, false) == 500,
        "authored 500 ms skills must retain the source minimum")
end

--[[
Runs all deterministic C4 skill-runtime rule checks.

Args:
    None.

Returns:
    nil: Prints a focused source-only pass count.
]]
local function main()
    check_elemental_heal_vectors()
    check_magic_cast_vectors()

    print(("[C4 Skill Runtime Rules] SOURCE_ONLY_PASS: %d assertions")
        :format(checks))
end

main()
