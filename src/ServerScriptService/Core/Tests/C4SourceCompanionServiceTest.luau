--!strict
-- Human Wizard server-owned companion lifecycle regression.

local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local CompanionService = require(
    ServerScriptService.Core.Services.C4SourceCompanionService
)

local checks = 0
local delayed_callbacks = {}
local consume_calls = {}
local fail_next_consume = false

local owner = {
    UserId = 938211,
    Character = nil,
}

local FakeInventory = {}

--[[
Records one fake inventory consume request.

Args:
    _self (any): Fake service receiver.
    user_id (number): Expected owner identifier.
    item_id (string): Creative reagent item.
    quantity (number?): Requested amount.

Returns:
    any: Success unless the next consume is configured to fail.
]]
function FakeInventory.consume_item(
    _self: any,
    user_id: number,
    item_id: string,
    quantity: number?
): any
    table.insert(consume_calls, {
        UserId = user_id,
        ItemId = item_id,
        Quantity = quantity or 1,
    })

    if fail_next_consume then
        fail_next_consume = false
        return {ok = false, reason = "ItemNotOwned"}
    end

    return {ok = true}
end

local FakeCombat = {}

--[[
Returns one short-lived deterministic summon plan.

Args:
    _user_id (number): Disposable owner identifier.
    skill_id (string): Reviewed summon skill.
    rank (number): Creative rank.

Returns:
    (any?, string?): Fake exact source plan.
]]
function FakeCombat.companion_summon_plan(
    _user_id: number,
    skill_id: string,
    rank: number
): (any?, string?)
    local source_id = if skill_id == "EmberweaverManaCompanion"
        then 1111
        else 1225

    return {
        SourceSkillId = source_id,
        SourceRank = rank,
        SourceNpcId = if source_id == 1111 then 12006 else 12348,
        ExpPenalty = if source_id == 1111 then 0.3 else 0.9,
        TotalLifeTimeMs = 1000,
        TimeLostIdleMs = 600,
        TimeLostActiveMs = 800,
        ItemConsumeId = 1458,
        ItemConsumeCount = 3,
        ItemConsumeIdOverTime = 1458,
        ItemConsumeCountOverTime = 1,
        ItemConsumeSteps = 1,
    }, nil
end

--[[
Returns one deterministic Servitor Heal plan.

Args:
    _user_id (number): Disposable owner identifier.
    _skill_id (string): Reviewed pet-heal skill.
    rank (number): Creative rank.

Returns:
    (any?, string?): Fake heal plan.
]]
function FakeCombat.companion_heal_plan(
    _user_id: number,
    _skill_id: string,
    rank: number
): (any?, string?)
    return {
        Amount = 65,
        SourceSkillId = 1127,
        SourceRank = rank,
        Spiritshot = false,
        BlessedSpiritshot = false,
    }, nil
end

--[[
Returns one deterministic Servitor Recharge plan.

Args:
    _user_id (number): Disposable owner identifier.
    _skill_id (string): Reviewed recharge skill.
    rank (number): Creative rank.
    rate (number): Server-owned target recharge multiplier.

Returns:
    (any?, string?): Fake recharge plan.
]]
function FakeCombat.companion_recharge_plan(
    _user_id: number,
    _skill_id: string,
    rank: number,
    rate: number
): (any?, string?)
    return {
        Amount = 41 * rate,
        SourceSkillId = 1126,
        SourceRank = rank,
        RechargeRate = rate,
    }, nil
end

--[[
Creates one deterministic companion model for tests.

Args:
    _owner (any): Disposable owner.
    plan (any): Fake source summon plan.
    role (string): Mana or Combat role.

Returns:
    Model: Workspace-owned fake companion.
]]
local function model_factory(
    _owner: any,
    plan: any,
    role: string
): Model
    local model = Instance.new("Model")
    model.Name = "TEMP_C4CompanionTest"

    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Anchored = true
    root.Parent = model

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 100
    humanoid.Health = 50
    humanoid.Parent = model

    model.PrimaryPart = root
    model:SetAttribute("C4SourceNpcId", plan.SourceNpcId)
    model:SetAttribute("C4CompanionRole", role)
    model:SetAttribute("C4CompanionMana", 20)
    model:SetAttribute("C4CompanionMaxMana", 100)
    model:SetAttribute("C4RechargeMpRate", 1)
    model:SetAttribute("C4CompanionActive", false)
    model.Parent = Workspace

    return model
end

--[[
Captures one delayed companion lifetime callback.

Args:
    _seconds (number): Expected one-second delay.
    callback (any): Deferred server callback.

Returns:
    any: Dummy task handle.
]]
local function delay_provider(
    _seconds: number,
    callback: any
): any
    table.insert(delayed_callbacks, callback)
    return {}
end

--[[
Counts one companion lifecycle assertion.

Args:
    condition (boolean): Observed state.
    label (string): Failure description.

Returns:
    nil: Raises on failure and increments the assertion count.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Companion Service] " .. label)
end

--[[
Runs summon, pet support, reagent and lifetime acceptance.

Args:
    None.

Returns:
    nil: Prints green regression evidence.
]]
local function main()
    local service = CompanionService.new(
        FakeInventory,
        FakeCombat,
        {
            ModelFactory = model_factory,
            DelayProvider = delay_provider,
        }
    )

    local summoned = assert(service:summon(
        owner,
        "EmberweaverManaCompanion",
        1,
        "Mana"
    ))
    check(
        summoned.Applied
            and summoned.SourceSkillId == 1111
            and summoned.SourceNpcId == 12006
            and summoned.ExpPenalty == 0.3
            and consume_calls[1].ItemId
                == "emberweaver_spirit_ore"
            and consume_calls[1].Quantity == 3,
        "summon consumes exact initial source reagent and preserves identity"
    )

    local duplicate, duplicate_reason = service:summon(
        owner,
        "EmberweaverCombatCompanion",
        1,
        "Combat"
    )
    check(
        duplicate == nil
            and duplicate_reason == "C4CompanionAlreadySummoned",
        "one-owner one-companion source rule is enforced"
    )

    local healed = assert(service:heal_owned(
        owner,
        "EmberweaverServitorHeal",
        1
    ))
    check(
        healed.EffectiveHeal == 50
            and healed.HealthBefore == 50
            and healed.HealthAfter == 100,
        "Servitor Heal clamps exact requested heal to companion maximum"
    )

    local recharged = assert(service:recharge_owned(
        owner,
        "EmberweaverServitorRecharge",
        1
    ))
    check(
        recharged.RequestedMana == 41
            and recharged.ManaBefore == 20
            and recharged.ManaAfter == 61,
        "Servitor Recharge applies source power through target recharge rate"
    )

    check(
        #delayed_callbacks == 1,
        "summon schedules its first source lifetime tick"
    )
    delayed_callbacks[1]()
    check(
        consume_calls[2].Quantity == 1
            and service:snapshot(owner).TimeRemainingMs == 400,
        "crossing source lifetime threshold consumes over-time reagent"
    )

    local second_tick = delayed_callbacks[2]
    assert(second_tick)
    second_tick()
    check(
        not service:snapshot(owner).Active,
        "source lifetime expiry unsummons the companion"
    )

    local combat = assert(service:summon(
        owner,
        "EmberweaverCombatCompanion",
        1,
        "Combat"
    ))
    check(
        combat.Role == "Combat"
            and combat.SourceSkillId == 1225,
        "combat companion uses its distinct source summon family"
    )

    fail_next_consume = true
    local callback = delayed_callbacks[#delayed_callbacks]
    callback()
    check(
        not service:snapshot(owner).Active,
        "missing over-time reagent immediately unsummons the companion"
    )

    print((
        "[C4 Companion Service] PASS: %d assertions"
    ):format(checks))
end

main()
