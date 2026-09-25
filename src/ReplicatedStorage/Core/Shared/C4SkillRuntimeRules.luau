--!strict
-- Shared Chronicle 4 skill-runtime rules transcribed from pinned source.
-- These helpers are pure references until a caller explicitly wires them live.

local Shared = script.Parent
local Formulas = require(Shared.C4CombatFormulaReference)

local C4SkillRuntimeRules = {}

local SOURCE_COMMIT =
    "07f8536384e799f128d44198dd7ab23519660eea"
local SOURCE_ROOT =
    "https://github.com/Neco-spain/"
    .. "l2jadmins_C4-Scions-of-Destiny/blob/"
    .. SOURCE_COMMIT
local SOURCE_URLS = table.freeze({
    Character = SOURCE_ROOT
        .. "/L2jAdmins_Core/src/l2j/gameserver/model/actor/"
        .. "L2Character.java",
    Player = SOURCE_ROOT
        .. "/L2jAdmins_Core/src/l2j/gameserver/model/actor/instance/"
        .. "L2PcInstance.java",
    CharacterStatus = SOURCE_ROOT
        .. "/L2jAdmins_Core/src/l2j/gameserver/model/actor/manager/"
        .. "character/status/CharStatus.java",
})

--[[
Validates an original MP cost field.

Args:
    value (number): Source mpInitialConsume or mpConsume value.
    label (string): Diagnostic field name.

Returns:
    number: Unchanged nonnegative integer source cost.
]]
local function source_cost(value: number, label: string): number
    assert(
        type(value) == "number"
            and value == value
            and value >= 0
            and value < math.huge
            and value % 1 == 0,
        label .. " must be a finite nonnegative integer"
    )
    return value
end

--[[
Returns the exact split MP cost shape used by Chronicle 4 active skills.

The original client request gate requires current MP to cover both parts.
The initial amount is then spent when casting starts; the ongoing amount
is spent only when the skill launches.

Args:
    initial_mp (number): Original mpInitialConsume value.
    ongoing_mp (number): Original mpConsume value.

Returns:
    any: Immutable InitialMP, OngoingMP and TotalMP source costs.
]]
function C4SkillRuntimeRules.split_mana_cost(
    initial_mp: number,
    ongoing_mp: number
): any
    local initial = source_cost(initial_mp, "Initial MP")
    local ongoing = source_cost(ongoing_mp, "Ongoing MP")

    return table.freeze({
        InitialMP = initial,
        OngoingMP = ongoing,
        TotalMP = initial + ongoing,
    })
end

--[[
Checks the original pre-cast MP affordability gate.

Args:
    current_mp (number): Current authoritative MP before cast start.
    initial_mp (number): Original initial MP charge.
    ongoing_mp (number): Original launch-time MP charge.

Returns:
    boolean: True only when current MP covers both source charges.
]]
function C4SkillRuntimeRules.can_begin_split_mana_cast(
    current_mp: number,
    initial_mp: number,
    ongoing_mp: number
): boolean
    if type(current_mp) ~= "number"
        or current_mp ~= current_mp
        or current_mp < 0
        or current_mp == math.huge
    then
        return false
    end

    local costs = C4SkillRuntimeRules.split_mana_cost(
        initial_mp,
        ongoing_mp
    )
    return current_mp >= costs.TotalMP
end

--[[
Applies only the original cast-start MP charge after total affordability.

Interrupted casts intentionally keep this first charge spent, matching the
source lifecycle where the second charge occurs only on skill launch.

Args:
    current_mp (number): Current MP immediately before cast start.
    initial_mp (number): Original initial MP charge.
    ongoing_mp (number): Original launch-time MP charge.

Returns:
    (number?, string?): MP after the initial charge, or denial reason.
]]
function C4SkillRuntimeRules.begin_split_mana_cast(
    current_mp: number,
    initial_mp: number,
    ongoing_mp: number
): (number?, string?)
    if not C4SkillRuntimeRules.can_begin_split_mana_cast(
        current_mp,
        initial_mp,
        ongoing_mp
    ) then
        return nil, "NotEnoughMana"
    end

    return current_mp - source_cost(initial_mp, "Initial MP"), nil
end

--[[
Applies the original launch-time MP charge.

Chronicle 4's reduceMp clamps at zero instead of re-running the original
pre-cast affordability gate. Normal casts still have enough MP because the
combined amount was checked before the first charge.

Args:
    current_mp (number): Current MP at skill launch.
    ongoing_mp (number): Original launch-time MP charge.

Returns:
    number: MP after the source launch charge, clamped at zero.
]]
function C4SkillRuntimeRules.finish_split_mana_cast(
    current_mp: number,
    ongoing_mp: number
): number
    assert(
        type(current_mp) == "number"
            and current_mp == current_mp
            and current_mp >= 0
            and current_mp < math.huge,
        "Current MP must be finite and nonnegative"
    )
    local ongoing = source_cost(ongoing_mp, "Ongoing MP")
    return math.max(0, current_mp - ongoing)
end

--[[
Returns Chronicle 4 instant-heal output for one original effect power.

Args:
    power (number): Original Heal effect power.
    spiritshot (boolean): Ordinary Spiritshot charge.
    blessed_spiritshot (boolean): Blessed Spiritshot charge.

Returns:
    number: Exact pre-MaxHP-clamp source heal amount.
]]
function C4SkillRuntimeRules.instant_heal(
    power: number,
    spiritshot: boolean,
    blessed_spiritshot: boolean
): number
    return Formulas.heal_amount(
        power,
        spiritshot,
        blessed_spiritshot
    )
end

--[[
Returns the Chronicle 4 magic cast time including shot acceleration.

The source first scales authored hitTime by final M.Atk.Spd, then applies
70 percent cast time for either Spiritshot type. Skills authored at 500 ms
or longer retain the original 500 ms minimum after acceleration.

Args:
    source_time_ms (number): Original skill hitTime.
    magic_attack_speed (number): Final source M.Atk.Spd.
    spiritshot (boolean): Ordinary Spiritshot charge.
    blessed_spiritshot (boolean): Blessed Spiritshot charge.

Returns:
    number: Source-equivalent final magic cast time in milliseconds.
]]
function C4SkillRuntimeRules.magic_cast_time(
    source_time_ms: number,
    magic_attack_speed: number,
    spiritshot: boolean,
    blessed_spiritshot: boolean
): number
    local cast_ms = Formulas.skill_cast_time(
        source_time_ms,
        magic_attack_speed
    )

    if spiritshot or blessed_spiritshot then
        cast_ms = math.floor(cast_ms * 0.70)
    end

    if source_time_ms >= 500 and cast_ms < 500 then
        return 500
    end

    return cast_ms
end

--[[
Returns Chronicle 4 magic cool-time scaling without the hit-time floor.

The source scales coolTime with the same M.Atk.Spd and shot acceleration as
hitTime, but the later 500 ms minimum applies only to hitTime.

Args:
    source_time_ms (number): Original skill coolTime.
    magic_attack_speed (number): Final source M.Atk.Spd.
    spiritshot (boolean): Ordinary Spiritshot charge.
    blessed_spiritshot (boolean): Blessed Spiritshot charge.

Returns:
    number: Source-equivalent final magic cool time in milliseconds.
]]
function C4SkillRuntimeRules.magic_cool_time(
    source_time_ms: number,
    magic_attack_speed: number,
    spiritshot: boolean,
    blessed_spiritshot: boolean
): number
    local cool_ms = Formulas.skill_cast_time(
        source_time_ms,
        magic_attack_speed
    )

    if spiritshot or blessed_spiritshot then
        cool_ms = math.floor(cool_ms * 0.70)
    end

    return cool_ms
end

--[[
Returns source reuse delay after reuse-rate and attack-speed scaling.

This reproduces the pinned source calculation order but does not determine
skill mastery. A caller must supply the already-resolved source reuse multiplier.

Args:
    source_reuse_ms (number): Authored skill reuseDelay.
    attack_speed (number): Final M.Atk.Spd or P.Atk.Spd as appropriate.
    reuse_multiplier (number): Final MAGICAL/PHYSICAL_SKILL_REUSE multiplier.

Returns:
    number: Source-equivalent reuse delay before skill-mastery override.
]]
function C4SkillRuntimeRules.skill_reuse_delay(
    source_reuse_ms: number,
    attack_speed: number,
    reuse_multiplier: number
): number
    assert(
        type(source_reuse_ms) == "number"
            and source_reuse_ms == source_reuse_ms
            and source_reuse_ms >= 0
            and source_reuse_ms < math.huge,
        "Source reuse delay must be finite and nonnegative"
    )
    assert(
        type(attack_speed) == "number"
            and attack_speed == attack_speed
            and attack_speed > 0
            and attack_speed < math.huge,
        "Attack speed must be finite and positive"
    )
    assert(
        type(reuse_multiplier) == "number"
            and reuse_multiplier == reuse_multiplier
            and reuse_multiplier >= 0
            and reuse_multiplier < math.huge,
        "Reuse multiplier must be finite and nonnegative"
    )

    local rate_scaled = math.floor(
        source_reuse_ms * reuse_multiplier
    )
    return math.floor(rate_scaled * 333 / attack_speed)
end

--[[
Returns the exact pinned source files used for split-MP/cast semantics.

Args:
    None.

Returns:
    any: Source commit and reviewed player/character/status file URLs.
]]
function C4SkillRuntimeRules.sources(): any
    return {
        SourceCommit = SOURCE_COMMIT,
        CharacterUrl = SOURCE_URLS.Character,
        PlayerUrl = SOURCE_URLS.Player,
        CharacterStatusUrl = SOURCE_URLS.CharacterStatus,
    }
end

return table.freeze(C4SkillRuntimeRules)
