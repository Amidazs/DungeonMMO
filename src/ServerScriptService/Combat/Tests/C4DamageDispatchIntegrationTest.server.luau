--!strict
-- FOCUSED_EDIT_ONLY_SINGLETON_TEST
local RunService = game:GetService("RunService")

if RunService:IsRunning() then
    print(
        "[C4 Damage Dispatch Integration] SKIP: singleton regression runs in focused Edit mode"
    )
    return
end
-- DamageService hook regression for disabled/handled C4 source dispatch.

local ServerScriptService = game:GetService("ServerScriptService")

local DamageService = require(
    ServerScriptService.Combat.DamageService
)

local checks = 0

--[[
Counts one DamageService source-hook assertion.

Args:
    valid (boolean): Expected integration condition.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Damage Dispatch Integration] " .. label)
end

--[[
Builds one disposable NPC target with a living Humanoid.

Args:
    None.

Returns:
    Model: Disposable target Model.
]]
local function target_fixture(): Model
    local target = Instance.new("Model")
    target.Name = "TEMP_C4DamageDispatchTarget"

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    humanoid.Parent = target

    return target
end

--[[
Builds one ordinary trusted DamageService context.

Args:
    target (Model): Current disposable NPC.

Returns:
    any: Existing server damage-context shape.
]]
local function damage_context(target: Model): any
    return {
        attacker = nil,
        attacker_character = nil,
        target = target,
        source_kind = "Melee",
        source_id = "TEMP_C4Dispatch",
        attack_id = "TEMP_C4Dispatch",
        base_damage = 50,
        multiplier = 1,
        sequence_id = 1,
    }
end

--[[
Runs handled-source and disabled-fallback integration checks.

Args:
    None.

Returns:
    nil: Prints bounded DamageService adapter evidence.
]]
local function main()
    local previous_adapter =
        DamageService.get_source_damage_adapter_for_test()
    local target = target_fixture()
    local humanoid = assert(
        target:FindFirstChildOfClass("Humanoid")
    )

    DamageService.set_source_damage_adapter(function(
        context: any
    ): any
        local current = assert(
            context.target:FindFirstChildOfClass("Humanoid")
        )
        current:TakeDamage(7)
        return {
            Handled = true,
            AppliedDamage = 7,
            Applied = true,
            Miss = false,
        }
    end)

    local applied = DamageService.apply_damage(
        damage_context(target)
    )
    check(
        applied == 7 and humanoid.Health == 93,
        "handled source result bypasses legacy 50-damage formula"
    )

    DamageService.set_source_damage_adapter(function(
        _context: any
    ): any
        return {
            Handled = false,
        }
    end)

    local fallback_context = damage_context(target)
    fallback_context.base_damage = 10
    local fallback = DamageService.apply_damage(
        fallback_context
    )
    check(
        fallback == 10 and humanoid.Health == 83,
        "unhandled adapter result preserves current DamageService path"
    )

    DamageService.set_source_damage_adapter(
        previous_adapter
    )
    target:Destroy()

    print((
        "[C4 Damage Dispatch Integration] PASS: %d assertions "
            .. "handled=true fallback=true"
    ):format(checks))
end

main()
