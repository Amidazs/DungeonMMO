--!strict
-- Disabled source-combat dispatch bridge for existing server damage contexts.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Runtime = require(
    ServerScriptService.Core.Services.ProgressionRuntimeState
)
local DamageFamilies = require(
    ReplicatedStorage.Core.Shared.C4CombatDamageFamilyReference
)

local C4CombatDispatchAdapter = {}

local feature_enabled = false
local bound_executor: any? = nil
local npc_damage_observer: any? = nil
local skill_rank_provider: any = function(
    user_id: number,
    skill_id: string
): number
    return Runtime.get_skill_rank(user_id, skill_id)
end

local activation_audit_provider: any = function(): boolean
    return DamageFamilies.activation_ready()
end

--[[
Checks the minimal executor contract required by this dispatch layer.

Args:
    executor (any): Candidate live C4 executor.

Returns:
    boolean: True when required NPC action methods are available.
]]
local function valid_executor(executor: any): boolean
    return type(executor) == "table"
        and type(executor.is_enabled) == "function"
        and type(executor.set_npc_damage_observer) == "function"
        and type(executor.normal_attack_npc) == "function"
        and type(executor.physical_skill_npc) == "function"
        and type(executor.magic_skill_npc) == "function"
        and type(executor.status_skill_npc) == "function"
end

--[[
Returns an authenticated server attacker UserId when available.

Args:
    attacker (any): Existing DamageService attacker field.

Returns:
    number?: Integer server player identifier.
]]
local function attacker_user_id(attacker: any): number?
    if attacker == nil then
        return nil
    end

    local ok, user_id = pcall(function()
        return attacker.UserId
    end)
    if not ok
        or type(user_id) ~= "number"
        or user_id % 1 ~= 0
    then
        return nil
    end

    return user_id
end

--[[
Returns whether the target is an NPC rather than a player character.

Args:
    target (any): Existing DamageService target field.

Returns:
    boolean: True for a Model with no owning Roblox Player.
]]
local function is_npc_target(target: any): boolean
    return typeof(target) == "Instance"
        and target:IsA("Model")
        and Players:GetPlayerFromCharacter(target) == nil
end

--[[
Resolves the server-owned purchased rank for one creative skill.

Args:
    user_id (number): Authenticated attacker UserId.
    skill_id (string): Existing server damage source identifier.

Returns:
    number?: Positive purchased rank, otherwise nil.
]]
local function skill_rank(
    user_id: number,
    skill_id: string
): number?
    local rank = skill_rank_provider(user_id, skill_id)
    if type(rank) ~= "number"
        or rank % 1 ~= 0
        or rank <= 0
    then
        return nil
    end

    return rank
end

--[[
Binds the current place's live source executor.

Binding does not enable dispatch. A previously installed trusted NPC damage
observer is forwarded immediately so script load order cannot drop callbacks.

Args:
    executor (any?): Current place executor, or nil to unbind.

Returns:
    nil: Updates only this server-local bridge.
]]
function C4CombatDispatchAdapter.bind_executor(executor: any?)
    assert(
        executor == nil or valid_executor(executor),
        "C4 dispatch adapter requires a compatible executor"
    )

    bound_executor = executor
    if not executor then
        feature_enabled = false
        return
    end

    executor:set_npc_damage_observer(npc_damage_observer)
end

--[[
Installs the existing trusted post-damage observer on the bound executor.

Args:
    observer (any?): Callback receiving context, damage and lethal flag.

Returns:
    nil: Stores and forwards the observer without enabling dispatch.
]]
function C4CombatDispatchAdapter.set_npc_damage_observer(
    observer: any?
)
    assert(
        observer == nil or type(observer) == "function",
        "C4 dispatch NPC damage observer must be a function or nil"
    )

    npc_damage_observer = observer
    if bound_executor then
        bound_executor:set_npc_damage_observer(observer)
    end
end

--[[
Overrides source skill-rank lookup for isolated tests.

Args:
    provider (any?): Server rank callback, or nil to restore runtime lookup.

Returns:
    nil: Changes only the server-local rank provider.
]]
function C4CombatDispatchAdapter.set_skill_rank_provider_for_test(
    provider: any?
)
    assert(
        provider == nil or type(provider) == "function",
        "C4 dispatch rank provider must be a function or nil"
    )

    skill_rank_provider = provider or function(
        user_id: number,
        skill_id: string
    ): number
        return Runtime.get_skill_rank(user_id, skill_id)
    end
end

--[[
Overrides activation-audit readiness for isolated adapter tests.

Production uses the immutable damage-family audit. This hook exists only so
route behaviour can be exercised while known activation blockers remain.

Args:
    provider (any?): Zero-argument boolean provider, or nil for production.

Returns:
    nil: Changes only the server-local test readiness provider.
]]
function C4CombatDispatchAdapter.set_activation_audit_provider_for_test(
    provider: any?
)
    assert(
        provider == nil or type(provider) == "function",
        "C4 dispatch audit provider must be a function or nil"
    )

    activation_audit_provider = provider or function(): boolean
        return DamageFamilies.activation_ready()
    end
end

--[[
Reports whether existing damage contexts may route through source combat.

Args:
    None.

Returns:
    boolean: Explicit adapter gate state.
]]
function C4CombatDispatchAdapter.is_enabled(): boolean
    return feature_enabled
end

--[[
Changes the independent source dispatch gate.

Enabling is refused unless the bound live executor is already enabled. This
prevents the adapter from becoming an implicit way to activate source combat.

Args:
    enabled (boolean): Desired adapter gate.

Returns:
    (boolean, string?): Success or strict gate denial reason.
]]
function C4CombatDispatchAdapter.set_enabled(
    enabled: boolean
): (boolean, string?)
    if type(enabled) ~= "boolean" then
        return false, "InvalidC4CombatDispatchGate"
    end

    if not enabled then
        feature_enabled = false
        return true, nil
    end
    if not bound_executor then
        return false, "C4CombatExecutorUnavailable"
    end
    if not bound_executor:is_enabled() then
        return false, "C4LiveCombatExecutorDisabled"
    end
    if activation_audit_provider() ~= true then
        return false, "C4CombatDispatchAuditBlockingFamilies"
    end

    feature_enabled = true
    return true, nil
end

--[[
Creates one handled failure result without falling back to legacy formulas.

Args:
    reason (string): Stable source dispatch denial reason.

Returns:
    any: Handled zero-damage result.
]]
local function denied(reason: string): any
    return {
        Handled = true,
        AppliedDamage = 0,
        Applied = false,
        Miss = false,
        Reason = reason,
    }
end

--[[
Converts one executor result into the DamageService adapter contract.

Args:
    result (any?): Successful executor result.
    reason (string?): Executor denial reason.

Returns:
    any: Handled damage/miss/denial evidence.
]]
local function handled_result(
    result: any?,
    reason: string?
): any
    if not result then
        return denied(reason or "C4SourceDispatchFailed")
    end

    local applied_damage =
        tonumber(result.HealthDamage) or 0

    return {
        Handled = true,
        AppliedDamage = math.max(applied_damage, 0),
        Applied = result.Applied == true,
        Miss = result.Miss == true,
        Reason = nil,
        SourceResult = result,
    }
end

--[[
Attempts to route one existing trusted DamageService context through C4.

When disabled, the result is explicitly not handled and DamageService keeps its
current formula path unchanged. Once enabled, supported player-to-NPC damage
never falls back to legacy formulas after a source denial.

Args:
    context (any): Existing server-created DamageService context.

Returns:
    any: Adapter result containing Handled and applied-damage evidence.
]]
function C4CombatDispatchAdapter.try_damage(context: any): any
    if not feature_enabled then
        return {
            Handled = false,
        }
    end
    if not bound_executor
        or not bound_executor:is_enabled()
    then
        return denied("C4LiveCombatExecutorDisabled")
    end
    if type(context) ~= "table" then
        return denied("InvalidC4CombatDamageContext")
    end

    local attacker = context.attacker
    local user_id = attacker_user_id(attacker)
    local target = context.target
    if not user_id or not is_npc_target(target) then
        return {
            Handled = false,
        }
    end

    local source_kind = context.source_kind
    local source_id = context.source_id
        or context.attack_id
    if type(source_kind) ~= "string"
        or type(source_id) ~= "string"
        or source_id == ""
    then
        return denied("InvalidC4CombatDamageContext")
    end

    local family = DamageFamilies.get(source_kind)
    if not family then
        return denied("C4SourceDamageFamilyUnaudited")
    end
    if family.PlayerToNpc ~= true then
        return denied("C4SourceDamageFamilyNotPlayerToNpc")
    end
    if family.ActivationBlocker == true then
        return denied(
            family.Reason
                or "C4SourceDamageFamilyActivationBlocked"
        )
    end

    if DamageFamilies.is_periodic_status_skill(source_id) then
        local rank = skill_rank(user_id, source_id)
        if not rank then
            return denied("C4SourceSkillRankUnavailable")
        end

        local result, reason =
            bound_executor:status_skill_npc(
                attacker,
                target,
                source_id,
                rank,
                context.sequence_id
            )
        if not result then
            return denied(reason or "C4SourceStatusDispatchFailed")
        end

        return {
            Handled = true,
            AppliedDamage = 0,
            Applied = result.StatusApplied == true,
            StatusApplied = result.StatusApplied == true,
            Miss = result.Landed == false,
            Reason = nil,
            SourceResult = result,
        }
    end

    if family.Route == "LegacyPeriodicTickSuppressed" then
        return denied(
            family.Reason or "C4LegacyPeriodicTickSuppressed"
        )
    end

    if family.Route == "SourceNormal" then
        local result, reason =
            bound_executor:normal_attack_npc(
                attacker,
                target,
                context.sequence_id
            )
        return handled_result(result, reason)
    end

    if family.Route == "SourcePhysicalByRank" then
        local rank = skill_rank(user_id, source_id)
        if not rank then
            local result, reason =
                bound_executor:normal_attack_npc(
                    attacker,
                    target,
                    context.sequence_id
                )
            return handled_result(result, reason)
        end

        local result, reason =
            bound_executor:physical_skill_npc(
                attacker,
                target,
                source_id,
                rank,
                context.sequence_id
            )
        return handled_result(result, reason)
    end

    if family.Route == "SourcePDAM" then
        local rank = skill_rank(user_id, source_id)
        if not rank then
            return denied("C4SourceSkillRankUnavailable")
        end

        local result, reason =
            bound_executor:physical_skill_npc(
                attacker,
                target,
                source_id,
                rank,
                context.sequence_id
            )
        return handled_result(result, reason)
    end

    if family.Route == "SourceMDAM" then
        local rank = skill_rank(user_id, source_id)
        if not rank then
            return denied("C4SourceSkillRankUnavailable")
        end

        local result, reason =
            bound_executor:magic_skill_npc(
                attacker,
                target,
                source_id,
                rank,
                context.sequence_id
            )
        return handled_result(result, reason)
    end

    return denied("C4SourceDamageFamilyRouteUnavailable")
end

--[[
Returns current dispatch capability metadata.

Args:
    None.

Returns:
    any: Disabled-default and fail-closed bridge guarantees.
]]
function C4CombatDispatchAdapter.capability(): any
    return {
        Available = true,
        DefaultEnabled = false,
        CurrentlyEnabled = feature_enabled,
        ExecutorBound = bound_executor ~= nil,
        ExistingDamageContextInput = true,
        DisabledFallsBackToCurrentCombat = true,
        EnabledSourceFailureFallsClosed = true,
        ActivationAuditReady =
            DamageFamilies.activation_ready(),
        ActivationBlockers =
            DamageFamilies.activation_blockers(),
        NormalMeleeSupported = true,
        RangedPhysicalSupported = true,
        PhysicalSkillSupported = true,
        MagicSkillSupported = true,
        RangerAreaActivationBlocked = true,
        MagicBasicUsesSourceNormalAttack = true,
        PeriodicStatusSupported = true,
        PeriodicStatusActivationBlocked = false,
        LegacyPeriodicTicksSuppressed = true,
        NpcOnly = true,
        ClientDamageAuthority = false,
    }
end

return table.freeze(C4CombatDispatchAdapter)
