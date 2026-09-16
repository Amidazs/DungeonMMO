--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")

local TravelAccessRules = require(
    Shared:WaitForChild("TravelAccessRules")
)
local TravelConfig = require(
    Shared:WaitForChild("TravelConfig")
)

local BaseTravelRuntime = {}

local function root_part(player: Player): BasePart?
    local character = player.Character
    if not character then
        return nil
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    return if root and root:IsA("BasePart") then root else nil
end

function BaseTravelRuntime.attach(config: any): any
    assert(config.travel ~= nil, "BaseTravelRuntime requires TravelService")
    assert(config.environment ~= nil, "BaseTravelRuntime requires Base environment")
    assert(config.remotes ~= nil, "BaseTravelRuntime requires Remotes")

    local travel_anchor =
        config.environment:get("Base.Service.Travel")

    assert(
        travel_anchor ~= nil,
        "Base.Service.Travel anchor is required"
    )

    local snapshot_request =
        config.remotes:WaitForChild("TravelSnapshotRequest") :: RemoteEvent
    local snapshot_remote =
        config.remotes:WaitForChild("TravelSnapshot") :: RemoteEvent
    local travel_request =
        config.remotes:WaitForChild("TravelRequest") :: RemoteEvent
    local action_result =
        config.remotes:WaitForChild("TravelActionResult") :: RemoteEvent

    local function physical_reason(player: Player): string?
        local root = root_part(player)
        if not root then
            return "CharacterUnavailable"
        end

        if not TravelAccessRules.within_service_distance(
            root.Position,
            travel_anchor.Position
        ) then
            return "TooFarFromTravelService"
        end

        return nil
    end

    local function send_result(player: Player, result: any)
        action_result:FireClient(player, {
            ok = result.ok == true,
            reason = result.reason,
            destination_id = result.destination_id,
            CooldownRemaining = result.CooldownRemaining,
        })
    end

    snapshot_request.OnServerEvent:Connect(function(player: Player)
        local reason = physical_reason(player)
        if reason then
            send_result(player, {ok = false, reason = reason})
            return
        end

        local snapshot =
            config.travel:build_snapshot(player.UserId)

        if snapshot.ok ~= true then
            send_result(player, snapshot)
            return
        end

        snapshot_remote:FireClient(player, snapshot)
    end)

    travel_request.OnServerEvent:Connect(function(
        player: Player,
        destination_id: any
    )
        local reason = physical_reason(player)
        if reason then
            send_result(player, {ok = false, reason = reason})
            return
        end

        local logical =
            config.travel:validate_request(
                player.UserId,
                destination_id
            )

        if logical.ok ~= true then
            send_result(player, logical)
            return
        end

        local destination = logical.destination
        local destination_anchor =
            config.environment:get(destination.AnchorId)

        if not destination_anchor then
            send_result(player, {
                ok = false,
                reason = "DestinationUnavailable",
            })
            return
        end

        local root = root_part(player)
        local character = player.Character

        if not root or not character then
            send_result(player, {
                ok = false,
                reason = "CharacterUnavailable",
            })
            return
        end

        if TravelAccessRules.already_at_destination(
            root.Position,
            destination_anchor.Position
        ) then
            send_result(player, {
                ok = false,
                reason = "AlreadyAtDestination",
            })
            return
        end

        reason = physical_reason(player)
        if reason then
            send_result(player, {ok = false, reason = reason})
            return
        end

        local target =
            destination_anchor.CFrame
            + Vector3.new(
                0,
                TravelConfig.ARRIVAL_HEIGHT_OFFSET,
                0
            )

        local moved = pcall(function()
            character:PivotTo(target)
        end)

        if not moved then
            send_result(player, {
                ok = false,
                reason = "TravelFailed",
            })
            return
        end

        config.travel:record_success(player.UserId)

        send_result(player, {
            ok = true,
            destination_id = destination.Id,
            CooldownRemaining =
                config.travel:remaining_cooldown(
                    player.UserId
                ),
        })
    end)

    Players.PlayerRemoving:Connect(function(player: Player)
        config.travel:clear_user(player.UserId)
    end)

    return {
        anchor = travel_anchor,
    }
end

return table.freeze(BaseTravelRuntime)
