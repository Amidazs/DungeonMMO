--!strict
-- Server-owned C4 TOGGLE authority for reviewed Warhowl stances.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared
local SkillEffects = require(Shared.C4SkillEffectSource)

local ActiveEffects = require(
    ServerScriptService.Core.Services.C4ActiveSourceEffectState
)
local Runtime = require(
    ServerScriptService.Core.Services.ProgressionRuntimeState
)
local ManaService = require(
    ServerScriptService.Combat.ManaService
)

local C4SourceToggleService = {}
C4SourceToggleService.__index = C4SourceToggleService

local REVIEWED = table.freeze({
    WarhowlPrecisionStance = table.freeze({
        SourceSkillId = 256,
    }),
    WarhowlPredatorStance = table.freeze({
        SourceSkillId = 312,
    }),
})

--[[
Checks one candidate has the minimum private owner identity.

Args:
    player (any): Player instance or disposable server test owner.

Returns:
    boolean: True when integral UserId and current Character are available.
]]
local function valid_owner(player: any): boolean
    return (
        type(player) == "table"
        or typeof(player) == "Instance"
    )
        and type(player.UserId) == "number"
        and player.UserId % 1 == 0
        and player.Character ~= nil
end

--[[
Finds the source MpConsumePerLevel effect that powers one toggle.

Args:
    effect (any): Exact source TOGGLE rank.

Returns:
    any?: Upkeep effect with positive period and finite base value.
]]
local function upkeep_effect(effect: any): any?
    for _, row in ipairs(effect.Effects or {}) do
        if row.name == "MpConsumePerLevel"
            and type(row.time) == "number"
            and row.time > 0
            and type(row.val) == "number"
            and row.val >= 0
            and row.val < math.huge
        then
            return row
        end
    end

    return nil
end

--[[
Calculates the exact C4 MP_CONSUME_PER_LEVEL periodic charge.

The pinned effect implementation uses:
    ((level - 1) / 7.5) * base * period

Args:
    level (number): Current authoritative character level.
    base (number): Exact source effect val.
    period (number): Exact source effect period in seconds.

Returns:
    number: Nonnegative periodic MP charge.
]]
function C4SourceToggleService.upkeep_cost(
    level: number,
    base: number,
    period: number
): number
    assert(
        type(level) == "number"
            and level >= 1
            and level < math.huge,
        "Source toggle level must be finite and positive"
    )
    assert(
        type(base) == "number"
            and base >= 0
            and base < math.huge,
        "Source toggle upkeep base must be finite and nonnegative"
    )
    assert(
        type(period) == "number"
            and period > 0
            and period < math.huge,
        "Source toggle period must be finite and positive"
    )

    return ((level - 1) / 7.5) * base * period
end

--[[
Creates a disabled toggle service around explicit server authorities.

Args:
    options (any?): Optional test replacements for runtime, effects, mana,
        active state, Players and RunService.

Returns:
    any: Disabled reviewed C4 toggle authority.
]]
function C4SourceToggleService.new(options: any?): any
    local config = options or {}
    local runtime = config.Runtime or Runtime
    local effects = config.SkillEffects or SkillEffects
    local mana = config.Mana or ManaService
    local active_effects =
        config.ActiveEffects or ActiveEffects

    assert(
        type(runtime.is_skill_usable) == "function"
            and type(runtime.get_skill_rank) == "function"
            and type(runtime.resolve_c4_active_source_effect)
                == "function"
            and type(runtime.get_c4_source_vitals) == "function",
        "Source toggle service requires progression authority"
    )
    assert(
        type(effects.get_rank) == "function",
        "Source toggle service requires source effect data"
    )
    assert(
        type(mana.try_spend) == "function"
            and type(mana.restore) == "function",
        "Source toggle service requires mana authority"
    )
    assert(
        type(active_effects.activate) == "function"
            and type(active_effects.deactivate) == "function",
        "Source toggle service requires active-effect authority"
    )

    return setmetatable({
        _enabled = false,
        _runtime = runtime,
        _effects = effects,
        _mana = mana,
        _active_effects = active_effects,
        _players = config.Players or Players,
        _run_service = config.RunService or RunService,
        _active_by_owner = {},
        _heartbeat = nil,
        _player_removing = nil,
    }, C4SourceToggleService)
end

--[[
Changes the reviewed toggle feature gate.

Args:
    enabled (boolean): Desired server gate state.

Returns:
    nil: Disabling immediately clears every active reviewed toggle.
]]
function C4SourceToggleService:set_enabled(enabled: boolean)
    assert(type(enabled) == "boolean")

    if self._enabled == enabled then
        return
    end

    self._enabled = enabled

    if not enabled then
        local owners = {}
        for owner in pairs(self._active_by_owner) do
            table.insert(owners, owner)
        end
        for _, owner in ipairs(owners) do
            self:clear_owner(owner)
        end
    end
end

--[[
Reports the reviewed toggle feature gate.

Args:
    None.

Returns:
    boolean: Current gate state.
]]
function C4SourceToggleService:is_enabled(): boolean
    return self._enabled
end

--[[
Reports whether one reviewed creative stance is currently active.

Args:
    player (any): Server-owned stance owner.
    creative_skill_id (string): Reviewed stance ID.

Returns:
    boolean: True only for a stored current-character stance.
]]
function C4SourceToggleService:is_active(
    player: any,
    creative_skill_id: string
): boolean
    local by_skill = self._active_by_owner[player]
    local record = by_skill and by_skill[creative_skill_id]

    return record ~= nil
        and record.Character == player.Character
end

--[[
Removes one reviewed stance and its authoritative source modifier.

Args:
    self (any): Toggle service.
    player (any): Server-owned stance owner.
    creative_skill_id (string): Reviewed stance ID.

Returns:
    boolean: True when an active stance was removed.
]]
local function stop_one(
    self: any,
    player: any,
    creative_skill_id: string
): boolean
    local by_skill = self._active_by_owner[player]
    local record = by_skill and by_skill[creative_skill_id]

    if not record then
        return false
    end

    by_skill[creative_skill_id] = nil
    self._active_effects.deactivate(
        player,
        creative_skill_id
    )

    if next(by_skill) == nil then
        self._active_by_owner[player] = nil
    end

    if player.Character
        and type(player.Character.SetAttribute) == "function"
    then
        player.Character:SetAttribute(
            "C4" .. creative_skill_id .. "Active",
            false
        )
    end

    return true
end

--[[
Validates and resolves one reviewed TOGGLE source rank before spending MP.

Args:
    self (any): Toggle service.
    player (any): Server-owned owner.
    creative_skill_id (string): Reviewed stance ID.

Returns:
    (any?, string?): Exact activation plan or strict denial reason.
]]
local function activation_plan(
    self: any,
    player: any,
    creative_skill_id: string
): (any?, string?)
    local review = REVIEWED[creative_skill_id]
    if not review then
        return nil, "C4SourceToggleSkillNotReviewed"
    end

    local usable, usable_reason =
        self._runtime.is_skill_usable(
            player.UserId,
            creative_skill_id
        )
    if not usable then
        return nil, usable_reason
    end

    local creative_rank =
        self._runtime.get_skill_rank(
            player.UserId,
            creative_skill_id
        )
    if creative_rank < 1 then
        return nil, "C4SourceToggleRankUnavailable"
    end

    local source, source_reason =
        self._runtime.resolve_c4_active_source_effect(
            player.UserId,
            creative_skill_id,
            creative_rank
        )
    if not source then
        return nil, source_reason
    end
    if source.SkillId ~= review.SourceSkillId
        or source.OperateType ~= "TOGGLE"
    then
        return nil, "C4SourceToggleReviewedSourceMismatch"
    end

    local effect = self._effects.get_rank(
        source.SkillId,
        source.Rank
    )
    if not effect
        or effect.Sets.operateType ~= "TOGGLE"
    then
        return nil, "C4SourceToggleEffectUnavailable"
    end

    local upkeep = upkeep_effect(effect)
    if not upkeep then
        return nil, "C4SourceToggleUpkeepUnavailable"
    end

    local initial =
        (tonumber(effect.Sets.mpInitialConsume) or 0)
        + (tonumber(effect.Sets.mpConsume) or 0)

    return {
        CreativeSkillId = creative_skill_id,
        CreativeRank = creative_rank,
        SourceSkillId = source.SkillId,
        SourceRank = source.Rank,
        InitialMp = math.max(0, initial),
        UpkeepBase = upkeep.val,
        UpkeepPeriod = upkeep.time,
    }, nil
end

--[[
Toggles one exact reviewed C4 stance for an authenticated owner.

Args:
    player (any): Server-owned stance owner.
    creative_skill_id (string): Precision or Predator stance.

Returns:
    (any?, string?): Activation/deactivation evidence or strict denial.
]]
function C4SourceToggleService:toggle(
    player: any,
    creative_skill_id: string
): (any?, string?)
    if not self._enabled then
        return nil, "C4SourceToggleDisabled"
    end
    if not valid_owner(player) then
        return nil, "C4SourceToggleOwnerInvalid"
    end
    if not REVIEWED[creative_skill_id] then
        return nil, "C4SourceToggleSkillNotReviewed"
    end

    if self:is_active(player, creative_skill_id) then
        stop_one(self, player, creative_skill_id)
        return {
            Applied = true,
            Active = false,
            CreativeSkillId = creative_skill_id,
            ClientAuthority = false,
        }, nil
    end

    local plan, reason = activation_plan(
        self,
        player,
        creative_skill_id
    )
    if not plan then
        return nil, reason
    end

    if not self._mana.try_spend(
        player,
        plan.InitialMp
    ) then
        return nil, "C4SourceToggleManaInsufficient"
    end

    local activated, active_reason =
        self._active_effects.activate(
            player,
            creative_skill_id,
            plan.CreativeRank
        )
    if not activated then
        self._mana.restore(player, plan.InitialMp)
        return nil, active_reason
    end

    local by_skill = self._active_by_owner[player]
    if not by_skill then
        by_skill = {}
        self._active_by_owner[player] = by_skill
    end

    by_skill[creative_skill_id] = {
        Character = player.Character,
        CreativeRank = plan.CreativeRank,
        SourceSkillId = plan.SourceSkillId,
        SourceRank = plan.SourceRank,
        InitialMp = plan.InitialMp,
        UpkeepBase = plan.UpkeepBase,
        UpkeepPeriod = plan.UpkeepPeriod,
        Elapsed = 0,
    }

    if type(player.Character.SetAttribute) == "function" then
        player.Character:SetAttribute(
            "C4" .. creative_skill_id .. "Active",
            true
        )
    end

    return {
        Applied = true,
        Active = true,
        CreativeSkillId = creative_skill_id,
        CreativeRank = plan.CreativeRank,
        SourceSkillId = plan.SourceSkillId,
        SourceRank = plan.SourceRank,
        InitialMpSpent = plan.InitialMp,
        UpkeepBase = plan.UpkeepBase,
        UpkeepPeriod = plan.UpkeepPeriod,
        ClientAuthority = false,
    }, nil
end

--[[
Checks one active record still belongs to the same usable skill/character.

Args:
    self (any): Toggle service.
    player (any): Server-owned owner.
    skill_id (string): Reviewed stance ID.
    record (any): Private active record.

Returns:
    boolean: True only while the exact source stance remains authorized.
]]
local function still_authorized(
    self: any,
    player: any,
    skill_id: string,
    record: any
): boolean
    if not valid_owner(player)
        or player.Character ~= record.Character
    then
        return false
    end

    local usable =
        self._runtime.is_skill_usable(
            player.UserId,
            skill_id
        )

    return usable == true
end

--[[
Advances exact source MP upkeep for all active reviewed toggles.

Args:
    delta_time (number): Server elapsed seconds since prior update.

Returns:
    nil: Insufficient MP or revoked authority drops only that stance.
]]
function C4SourceToggleService:step(delta_time: number)
    if not self._enabled then
        return
    end

    local delta = math.clamp(
        tonumber(delta_time) or 0,
        0,
        1
    )

    for player, by_skill in pairs(self._active_by_owner) do
        local skill_ids = {}
        for skill_id in pairs(by_skill) do
            table.insert(skill_ids, skill_id)
        end

        for _, skill_id in ipairs(skill_ids) do
            local record = by_skill[skill_id]
            if not record then
                continue
            end

            if not still_authorized(
                self,
                player,
                skill_id,
                record
            ) then
                stop_one(self, player, skill_id)
                continue
            end

            record.Elapsed += delta

            while record.Elapsed >= record.UpkeepPeriod do
                record.Elapsed -= record.UpkeepPeriod

                local vitals =
                    self._runtime.get_c4_source_vitals(
                        player.UserId
                    )
                if not vitals then
                    stop_one(self, player, skill_id)
                    break
                end

                local cost = C4SourceToggleService.upkeep_cost(
                    vitals.Level,
                    record.UpkeepBase,
                    record.UpkeepPeriod
                )

                if not self._mana.try_spend(
                    player,
                    cost
                ) then
                    stop_one(self, player, skill_id)
                    break
                end
            end
        end
    end
end

--[[
Binds live Heartbeat and PlayerRemoving cleanup once.

Args:
    None.

Returns:
    nil: Future server heartbeats enforce upkeep automatically.
]]
function C4SourceToggleService:bind_runtime()
    if self._heartbeat then
        return
    end

    self._heartbeat =
        self._run_service.Heartbeat:Connect(
            function(delta_time)
                self:step(delta_time)
            end
        )

    self._player_removing =
        self._players.PlayerRemoving:Connect(
            function(player)
                self:clear_owner(player)
            end
        )
end

--[[
Clears every reviewed stance for one owner.

Args:
    player (any): Departing or reset server owner.

Returns:
    nil: No source toggle modifier remains registered.
]]
function C4SourceToggleService:clear_owner(player: any)
    local by_skill = self._active_by_owner[player]
    if not by_skill then
        return
    end

    local skill_ids = {}
    for skill_id in pairs(by_skill) do
        table.insert(skill_ids, skill_id)
    end
    for _, skill_id in ipairs(skill_ids) do
        stop_one(self, player, skill_id)
    end
end

--[[
Returns detached reviewed toggle capability metadata.

Args:
    None.

Returns:
    any: Gate, source upkeep and authority evidence.
]]
function C4SourceToggleService:capability(): any
    return {
        Available = true,
        DefaultEnabled = false,
        CurrentlyEnabled = self._enabled,
        ReviewedSkillCount = 2,
        PrecisionStanceSourceSkillId = 256,
        PredatorStanceSourceSkillId = 312,
        MpConsumePerLevelFormula = true,
        ThreeSecondSourceUpkeep = true,
        ServerManaAuthority = true,
        ActiveSourceEffectAuthority = true,
        ClientAuthority = false,
    }
end

return C4SourceToggleService
