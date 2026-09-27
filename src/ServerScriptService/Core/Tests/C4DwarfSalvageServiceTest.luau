--!strict
-- Server-owned Deepclaimer Spoil/Sweep state and reward regression.

local ServerScriptService = game:GetService("ServerScriptService")

local Service = require(
    ServerScriptService.Core.Services.C4DwarfSalvageService
)

local checks = 0
local grants = {}
local fail_grant = false

local FakeInventory = {}

--[[
Records one deterministic salvage inventory grant.

Args:
    user_id (number): Reward owner.
    item_id (string): Granted salvage item.
    quantity (number): Granted quantity.

Returns:
    any: Success or deterministic failure result.
]]
function FakeInventory:add_item(
    user_id: number,
    item_id: string,
    quantity: number
): any
    if fail_grant then
        return {ok = false, reason = "InjectedGrantFailure"}
    end

    grants[user_id] = {
        ItemId = item_id,
        Quantity = quantity,
    }
    return {ok = true}
end

local FakeRng = {}

--[[
Returns the first weighted-roll bucket deterministically.

Args:
    _minimum (number): Lower inclusive bound.
    _maximum (number): Upper inclusive bound.

Returns:
    number: Deterministic first roll.
]]
function FakeRng:NextInteger(
    _minimum: number,
    _maximum: number
): number
    return 1
end

--[[
Counts one salvage authority assertion.

Args:
    valid (boolean): Expected server-owned state.
    label (string): Diagnostic failure description.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[Dwarf Salvage] " .. label)
end

--[[
Builds one disposable living server creature.

Args:
    name (string): Test model name.

Returns:
    Model: Workspace creature with a living Humanoid.
]]
local function make_target(name: string): Model
    local model = Instance.new("Model")
    model.Name = name

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    humanoid.Parent = model

    model.Parent = workspace
    return model
end

--[[
Runs ownership, death, idempotency and reward rollback checks.

Args:
    None.

Returns:
    nil: Prints a bounded pass marker after all checks pass.
]]
local function main()
    local owner = {UserId = 956210}
    local rival = {UserId = 956211}
    local service = Service.new(FakeInventory, FakeRng)
    local target = make_target("TEMP_DeepclaimerSalvageTarget")

    local marked = assert(service:mark(
        owner,
        target,
        254,
        2
    ))
    check(
        marked.Applied
            and marked.OwnerUserId == owner.UserId
            and marked.SourceRank == 2,
        "Spoil mark records exact owner and source rank"
    )

    local snapshot = service:snapshot(target)
    check(
        snapshot.Marked
            and snapshot.OwnerUserId == owner.UserId
            and not snapshot.Claimed,
        "server snapshot exposes owned unclaimed mark"
    )

    local stolen, stolen_reason = service:mark(
        rival,
        target,
        254,
        2
    )
    check(
        stolen == nil
            and stolen_reason == "C4SalvageAlreadyMarked",
        "another player cannot steal a living Spoil mark"
    )

    local early, early_reason = service:claim(owner, target)
    check(
        early == nil
            and early_reason == "C4SalvageTargetNotDeadEnemy",
        "Sweep cannot claim a living enemy"
    )

    local humanoid = assert(target:FindFirstChildOfClass("Humanoid"))
    humanoid.Health = 0

    local rival_claim, rival_reason = service:claim(rival, target)
    check(
        rival_claim == nil
            and rival_reason == "C4SalvageNotOwned",
        "another player cannot Sweep an owned corpse"
    )

    local claimed = assert(service:claim(owner, target))
    check(
        claimed.Applied
            and claimed.ItemId == "dense_mineral_shard"
            and claimed.Quantity == 1,
        "owned corpse grants deterministic secondary salvage"
    )
    check(
        grants[owner.UserId].ItemId == "dense_mineral_shard",
        "secondary salvage enters only the owner's inventory"
    )

    local duplicate, duplicate_reason = service:claim(owner, target)
    check(
        duplicate == nil
            and duplicate_reason == "C4SalvageAlreadyClaimed",
        "one corpse cannot be Swept twice"
    )

    local rollback = make_target("TEMP_DeepclaimerSalvageRollback")
    assert(service:mark(owner, rollback, 254, 3))
    local rollback_humanoid =
        assert(rollback:FindFirstChildOfClass("Humanoid"))
    rollback_humanoid.Health = 0

    fail_grant = true
    local failed, failed_reason = service:claim(owner, rollback)
    fail_grant = false
    check(
        failed == nil
            and failed_reason == "InjectedGrantFailure"
            and service:snapshot(rollback).Claimed == false,
        "failed inventory mutation releases the corpse claim lock"
    )

    target:Destroy()
    rollback:Destroy()

    print(
        ("[Dwarf Salvage] PASS: %d assertions")
            :format(checks)
    )
end

main()
