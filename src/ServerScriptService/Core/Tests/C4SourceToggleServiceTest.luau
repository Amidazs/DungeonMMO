--!strict
-- Exact Warhowl Precision/Predator C4 toggle regression.

local ServerScriptService = game:GetService("ServerScriptService")
local Service = require(
    ServerScriptService.Core.Services.C4SourceToggleService
)

local attributes = {}
local humanoid = {
    Health = 50,
    MaxHealth = 100,
    Sit = false,
}
local character = {}

--[[
Returns the disposable humanoid for source Relax tests.

Args:
    class_name (string): Expected Humanoid class request.

Returns:
    any?: Fake humanoid for Humanoid, otherwise nil.
]]
function character:FindFirstChildOfClass(class_name: string): any?
    return if class_name == "Humanoid" then humanoid else nil
end

--[[
Stores one disposable character attribute.

Args:
    name (string): Attribute key.
    value (any): Attribute value.

Returns:
    nil: Records the value for assertions.
]]
function character:SetAttribute(name: string, value: any)
    attributes[name] = value
end

local OWNER = {
    UserId = 938271,
    Character = character,
}

local skill_ranks = {
    OrcRelax = 1,
    WarhowlPrecisionStance = 1,
    WarhowlPredatorStance = 3,
}

local FakeRuntime = {}

--[[
Reports both reviewed toggles as currently usable.

Args:
    _user_id (number): Expected owner.
    skill_id (string): Reviewed stance.

Returns:
    (boolean, string?): Usability or unknown-skill denial.
]]
function FakeRuntime.is_skill_usable(
    _user_id: number,
    skill_id: string
): (boolean, string?)
    return skill_ranks[skill_id] ~= nil,
        if skill_ranks[skill_id] then nil else "UnknownSkill"
end

--[[
Returns the deterministic purchased creative rank.

Args:
    _user_id (number): Expected owner.
    skill_id (string): Reviewed stance.

Returns:
    number: Purchased test rank.
]]
function FakeRuntime.get_skill_rank(
    _user_id: number,
    skill_id: string
): number
    return skill_ranks[skill_id] or 0
end

--[[
Resolves exact reviewed source toggle identities.

Args:
    _user_id (number): Expected owner.
    skill_id (string): Reviewed stance.
    creative_rank (number): Purchased creative rank.

Returns:
    (any?, string?): Exact source rank or denial.
]]
function FakeRuntime.resolve_c4_active_source_effect(
    _user_id: number,
    skill_id: string,
    creative_rank: number
): (any?, string?)
    if skill_id == "OrcRelax"
        and creative_rank == 1
    then
        return {
            SkillId = 226,
            Rank = 1,
            OperateType = "TOGGLE",
        }, nil
    end

    if skill_id == "WarhowlPrecisionStance"
        and creative_rank == 1
    then
        return {
            SkillId = 256,
            Rank = 1,
            OperateType = "TOGGLE",
        }, nil
    end

    if skill_id == "WarhowlPredatorStance"
        and creative_rank == 3
    then
        return {
            SkillId = 312,
            Rank = 3,
            OperateType = "TOGGLE",
        }, nil
    end

    return nil, "ToggleSourceUnavailable"
end

--[[
Returns exact level-30 source vitals for upkeep calculation.

Args:
    _user_id (number): Expected owner.

Returns:
    any: Minimal level evidence.
]]
function FakeRuntime.get_c4_source_vitals(_user_id: number): any
    return {Level = 30}
end

local mana = 100
local FakeMana = {}

--[[
Attempts one deterministic MP payment.

Args:
    _owner (any): Expected owner.
    amount (number): Requested source MP.

Returns:
    boolean: True only when current fake MP covers the request.
]]
function FakeMana.try_spend(_owner: any, amount: number): boolean
    if mana < amount then
        return false
    end

    mana -= amount
    return true
end

--[[
Restores deterministic MP after a failed activation transaction.

Args:
    _owner (any): Expected owner.
    amount (number): MP to restore.

Returns:
    number: Actual restored amount.
]]
function FakeMana.restore(_owner: any, amount: number): number
    mana += amount
    return amount
end

local activated = {}
local deactivated = {}
local FakeActive = {}

--[[
Records one authoritative source toggle activation.

Args:
    _owner (any): Expected owner.
    skill_id (string): Creative stance ID.
    rank (number): Purchased creative rank.

Returns:
    (boolean, string?): Successful activation.
]]
function FakeActive.activate(
    _owner: any,
    skill_id: string,
    rank: number
): (boolean, string?)
    activated[skill_id] = rank
    return true, nil
end

--[[
Records one authoritative source toggle deactivation.

Args:
    _owner (any): Expected owner.
    skill_id (string): Creative stance ID.

Returns:
    nil: Records the removal.
]]
function FakeActive.deactivate(
    _owner: any,
    skill_id: string
)
    deactivated[skill_id] = true
    activated[skill_id] = nil
end

local checks = 0

--[[
Counts one exact source toggle assertion.

Args:
    condition (boolean): Required toggle behavior.
    label (string): Failure description.

Returns:
    nil: Raises on mismatch and increments count.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Warhowl Toggle] " .. label)
end

--[[
Runs activation, coexistence, upkeep and exhaustion acceptance.

Args:
    None.

Returns:
    nil: Prints exact source toggle coverage.
]]
local function main()
    local service = Service.new({
        Runtime = FakeRuntime,
        Mana = FakeMana,
        ActiveEffects = FakeActive,
    })
    service:set_enabled(true)

    check(
        math.abs(
            Service.upkeep_cost(30, 0.2, 3) - 2.32
        ) < 0.000001,
        "Precision rank one uses exact level-30 MP upkeep formula"
    )
    check(
        math.abs(
            Service.upkeep_cost(30, 0.4, 3) - 4.64
        ) < 0.000001,
        "Predator stance uses exact level-30 MP upkeep formula"
    )

    local precision = assert(service:toggle(
        OWNER,
        "WarhowlPrecisionStance"
    ))
    check(
        precision.Active
            and precision.SourceSkillId == 256
            and precision.SourceRank == 1
            and precision.InitialMpSpent == 1
            and mana == 99
            and service:is_active(
                OWNER,
                "WarhowlPrecisionStance"
            ),
        "Precision Stance spends exact source activation MP"
    )

    local predator = assert(service:toggle(
        OWNER,
        "WarhowlPredatorStance"
    ))
    check(
        predator.Active
            and predator.SourceSkillId == 312
            and predator.SourceRank == 3
            and predator.InitialMpSpent == 5
            and mana == 94
            and service:is_active(
                OWNER,
                "WarhowlPredatorStance"
            ),
        "Predator rank three spends exact source activation MP"
    )

    service:step(1)
    service:step(1)
    service:step(1)
    check(
        math.abs(mana - 87.04) < 0.000001,
        "both stances independently drain exact three-second MP upkeep"
    )

    local precision_off = assert(service:toggle(
        OWNER,
        "WarhowlPrecisionStance"
    ))
    check(
        not precision_off.Active
            and deactivated.WarhowlPrecisionStance
            and not service:is_active(
                OWNER,
                "WarhowlPrecisionStance"
            )
            and service:is_active(
                OWNER,
                "WarhowlPredatorStance"
            ),
        "Precision can deactivate without dropping Predator"
    )

    mana = 4
    service:step(1)
    service:step(1)
    service:step(1)
    check(
        not service:is_active(
            OWNER,
            "WarhowlPredatorStance"
        )
            and deactivated.WarhowlPredatorStance
            and mana == 4,
        "Predator drops when current MP is below exact next upkeep"
    )

    mana = 20
    humanoid.Health = 50
    humanoid.MaxHealth = 100
    humanoid.Sit = false

    local relax = assert(service:toggle(
        OWNER,
        "OrcRelax"
    ))
    check(
        relax.Active
            and relax.SourceSkillId == 226
            and relax.SourceRank == 1
            and relax.InitialMpSpent == 2
            and relax.UpkeepKind == "Relax"
            and humanoid.Sit
            and mana == 18,
        "Orc Relax spends two MP and forces sitting on activation"
    )

    service:step(1)
    service:step(1)
    check(
        mana == 16
            and service:is_active(OWNER, "OrcRelax"),
        "Orc Relax consumes exact two MP every two seconds"
    )

    humanoid.Sit = false
    service:step(1)
    check(
        not service:is_active(OWNER, "OrcRelax")
            and deactivated.OrcRelax
            and mana == 16,
        "Orc Relax deactivates immediately after standing"
    )

    humanoid.Health = 100
    humanoid.Sit = false
    local before_full_hp_attempt = mana
    local full_hp, full_hp_reason = service:toggle(
        OWNER,
        "OrcRelax"
    )
    check(
        full_hp == nil
            and full_hp_reason == "C4RelaxHpFull"
            and mana == before_full_hp_attempt,
        "Orc Relax cannot activate at full HP or spend MP"
    )

    local capability = service:capability()
    check(
        capability.ReviewedSkillCount == 3
            and capability.RelaxFixedTwoSecondUpkeep
            and capability.RelaxRequiresSittingAndMissingHp
            and capability.MpConsumePerLevelFormula
            and capability.ThreeSecondSourceUpkeep
            and capability.ServerManaAuthority
            and capability.ActiveSourceEffectAuthority
            and not capability.ClientAuthority,
        "capability reports both exact source toggle families"
    )

    print((
        "[C4 Warhowl Toggle] PASS: %d assertions reviewed=3"
    ):format(checks))
end

main()
