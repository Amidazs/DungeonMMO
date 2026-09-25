--!strict
-- Unpublished Studio-only server bridge for rehearsing the real C4 cutover.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local C4CombatCutoverStudioBridge = {}

local DEFAULT_BRIDGE_NAME = "C4CombatCutoverRehearsalBridge"

--[[
Checks the minimum coordinator contract used by this bridge.

Args:
    coordinator (any): Candidate server-owned cutover coordinator.

Returns:
    boolean: True when the required coordinator methods exist.
]]
local function valid_coordinator(coordinator: any): boolean
    return type(coordinator) == "table"
        and type(coordinator.enable) == "function"
        and type(coordinator.disable) == "function"
        and type(coordinator.snapshot) == "function"
end

--[[
Returns whether the rehearsal bridge is allowed in this DataModel.

The bridge is intentionally unavailable in published servers even when Studio
code is accidentally carried into a release build.

Args:
    None.

Returns:
    boolean: True only in an unpublished Studio place.
]]
local function rehearsal_allowed(): boolean
    return RunService:IsStudio()
        and game.PlaceId == 0
        and game.GameId == 0
end

--[[
Resolves an explicit set of currently connected server players.

Args:
    user_ids (any): Array of integer UserIds selected by trusted test code.

Returns:
    ({Player}?, string?): Connected players or strict denial reason.
]]
local function resolve_players(
    user_ids: any
): ({Player}?, string?)
    if type(user_ids) ~= "table" or #user_ids == 0 then
        return nil, "InvalidC4RehearsalPlayers"
    end

    local players = {}
    local seen = {}

    for _, user_id in ipairs(user_ids) do
        if type(user_id) ~= "number"
            or user_id % 1 ~= 0
            or seen[user_id]
        then
            return nil, "InvalidC4RehearsalPlayers"
        end

        local player = Players:GetPlayerByUserId(user_id)
        if not player then
            return nil, "C4RehearsalPlayerUnavailable"
        end

        seen[user_id] = true
        table.insert(players, player)
    end

    return players, nil
end

--[[
Creates one Studio-only BindableFunction around the real coordinator.

The BindableFunction lives in ServerStorage, so clients cannot invoke it.
Trusted Studio/server tooling can use it across Luau VM boundaries.

Args:
    coordinator (any): Actual runtime cutover coordinator.
    bridge_name (string?): Optional isolated test name.
    diagnostic_provider (((number) -> (any?, string?))?): Optional
        server-runtime source-boundary provider for unpublished diagnostics.

Returns:
    BindableFunction?: Created bridge, otherwise nil outside local Studio.
]]
function C4CombatCutoverStudioBridge.bind(
    coordinator: any,
    bridge_name: string?,
    diagnostic_provider: ((number) -> (any?, string?))?
): BindableFunction?
    assert(
        valid_coordinator(coordinator),
        "C4 Studio bridge requires a valid coordinator"
    )

    if not rehearsal_allowed() then
        return nil
    end

    local name = bridge_name or DEFAULT_BRIDGE_NAME
    assert(
        type(name) == "string" and name ~= "",
        "C4 Studio bridge name must be non-empty"
    )

    local existing = ServerStorage:FindFirstChild(name)
    if existing then
        existing:Destroy()
    end

    local bridge = Instance.new("BindableFunction")
    bridge.Name = name
    bridge.Parent = ServerStorage

    bridge.OnInvoke = function(
        action: any,
        payload: any?
    ): any
        if action == "snapshot" then
            return {
                ok = true,
                snapshot = coordinator:snapshot(),
            }
        end

        if action == "disable" then
            coordinator:disable()
            return {
                ok = true,
                snapshot = coordinator:snapshot(),
            }
        end

        if action == "diagnose" then
            if type(diagnostic_provider) ~= "function" then
                return {
                    ok = false,
                    reason = "C4RehearsalDiagnosticsUnavailable",
                    snapshot = coordinator:snapshot(),
                }
            end

            local players, player_reason =
                resolve_players(payload and payload.UserIds)
            if not players then
                return {
                    ok = false,
                    reason = player_reason,
                    snapshot = coordinator:snapshot(),
                }
            end

            local diagnostics = {}
            for _, player in ipairs(players) do
                local boundary, boundary_reason =
                    diagnostic_provider(player.UserId)
                local summary = {
                    UserId = player.UserId,
                    Reason = boundary_reason,
                }

                if type(boundary) == "table" then
                    summary.RaceId = boundary.RaceId
                    summary.ClassId = boundary.ClassId
                    summary.Level = boundary.Level
                    summary.ReviewedSixSlotLoadoutReady =
                        boundary.ReviewedSixSlotLoadoutReady
                    summary.ReviewedSixSlotLoadoutReason =
                        boundary.ReviewedSixSlotLoadoutReason
                    summary.OriginalOwnedPassivesIntegrated =
                        boundary.OriginalOwnedPassivesIntegrated
                    summary.OwnedPassiveSourceReason =
                        boundary.OwnedPassiveSourceReason
                    summary.ActiveEffectSourceStateReady =
                        boundary.ActiveEffectSourceStateReady
                    summary.ActiveEffectSourceStateReason =
                        boundary.ActiveEffectSourceStateReason
                    summary.CombatPointRuntimeReady =
                        boundary.CombatPointRuntimeReady
                    summary.CombatPointRuntimeReason =
                        boundary.CombatPointRuntimeReason
                    summary.SourceStatCandidateReady =
                        boundary.SourceStatCandidateReady
                    summary.SourceStatCandidateReason =
                        boundary.SourceStatCandidateReason
                    summary.CutoverPrerequisitesReady =
                        boundary.CutoverPrerequisitesReady
                    summary.ActivationBlockers =
                        boundary.ActivationBlockers
                end

                table.insert(diagnostics, summary)
            end

            return {
                ok = true,
                players = diagnostics,
                snapshot = coordinator:snapshot(),
            }
        end

        if action ~= "enable" then
            return {
                ok = false,
                reason = "UnknownC4RehearsalAction",
                snapshot = coordinator:snapshot(),
            }
        end

        if type(payload) ~= "table"
            or type(payload.SourceUnitsPerStud) ~= "number"
            or payload.SourceUnitsPerStud <= 0
            or type(payload.IsNight) ~= "boolean"
        then
            return {
                ok = false,
                reason = "InvalidC4RehearsalConfiguration",
                snapshot = coordinator:snapshot(),
            }
        end

        local players, player_reason =
            resolve_players(payload.UserIds)
        if not players then
            return {
                ok = false,
                reason = player_reason,
                snapshot = coordinator:snapshot(),
            }
        end

        local enabled, enable_reason = coordinator:enable(
            players,
            payload.SourceUnitsPerStud,
            function(): boolean
                return payload.IsNight
            end
        )

        return {
            ok = enabled,
            reason = enable_reason,
            snapshot = coordinator:snapshot(),
        }
    end

    return bridge
end

--[[
Removes one rehearsal bridge without changing coordinator gates.

Args:
    bridge_name (string?): Optional isolated test name.

Returns:
    nil: Destroys only the named ServerStorage BindableFunction.
]]
function C4CombatCutoverStudioBridge.clear(
    bridge_name: string?
)
    local name = bridge_name or DEFAULT_BRIDGE_NAME
    local existing = ServerStorage:FindFirstChild(name)

    if existing and existing:IsA("BindableFunction") then
        existing:Destroy()
    end
end

return table.freeze(C4CombatCutoverStudioBridge)
