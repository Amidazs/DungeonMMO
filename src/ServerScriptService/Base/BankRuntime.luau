--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")

local BankAccessRules = require(
    Shared:WaitForChild("BankAccessRules")
)
local CharacterIdentityRules = require(
    Shared:WaitForChild("CharacterIdentityRules")
)

local BankRuntime = {}

local function root_part(player: Player): BasePart?
    local character = player.Character
    if not character then
        return nil
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    return if root and root:IsA("BasePart") then root else nil
end

function BankRuntime.attach(config: any): any
    assert(config.bank ~= nil, "BankRuntime requires BankService")
    assert(config.profiles ~= nil, "BankRuntime requires ProfileService")
    assert(config.environment ~= nil, "BankRuntime requires Base environment")
    assert(config.remotes ~= nil, "BankRuntime requires Remotes")

    local bank_anchor = config.environment:get("Base.Service.Bank")
    assert(bank_anchor ~= nil, "Base.Service.Bank anchor is required")

    local snapshot_request =
        config.remotes:WaitForChild("BankSnapshotRequest") :: RemoteEvent
    local snapshot_remote =
        config.remotes:WaitForChild("BankSnapshot") :: RemoteEvent
    local deposit_request =
        config.remotes:WaitForChild("BankDepositRequest") :: RemoteEvent
    local withdraw_request =
        config.remotes:WaitForChild("BankWithdrawRequest") :: RemoteEvent
    local action_result =
        config.remotes:WaitForChild("BankActionResult") :: RemoteEvent

    local function access_reason(player: Player): string?
        if config.is_handoff_pending
            and config.is_handoff_pending(player.UserId) == true
        then
            return "TeleportPending"
        end

        local character =
            config.profiles:get_character(player.UserId, 1)
        if not character then
            return "ProfileNotLoaded"
        end

        if not CharacterIdentityRules.is_complete(character) then
            return "IdentityIncomplete"
        end

        local root = root_part(player)
        if not root then
            return "CharacterUnavailable"
        end

        if not BankAccessRules.within_distance(
            root.Position,
            bank_anchor.Position
        ) then
            return "TooFarFromBank"
        end

        return nil
    end

    local function send_result(
        player: Player,
        action: string,
        result: any
    )
        action_result:FireClient(player, {
            ok = result.ok == true,
            reason = result.reason,
            action = action,
            item_id = result.item_id,
            quantity = result.quantity,
        })
    end

    local function send_snapshot(player: Player): boolean
        local reason = access_reason(player)
        if reason then
            send_result(
                player,
                "snapshot",
                {ok = false, reason = reason}
            )
            return false
        end

        local snapshot =
            config.bank:build_snapshot(player.UserId)
        if snapshot.ok ~= true then
            send_result(player, "snapshot", snapshot)
            return false
        end

        snapshot_remote:FireClient(player, snapshot)
        return true
    end

    snapshot_request.OnServerEvent:Connect(function(player: Player)
        send_snapshot(player)
    end)

    deposit_request.OnServerEvent:Connect(function(
        player: Player,
        item_id: any,
        quantity: any
    )
        local reason = access_reason(player)
        if reason then
            send_result(
                player,
                "deposit",
                {ok = false, reason = reason}
            )
            return
        end

        local result = config.bank:deposit(
            player.UserId,
            item_id,
            quantity
        )
        send_result(player, "deposit", result)

        if result.ok == true then
            if config.on_profile_changed then
                config.on_profile_changed(player)
            end
            send_snapshot(player)
        end
    end)

    withdraw_request.OnServerEvent:Connect(function(
        player: Player,
        item_id: any,
        quantity: any
    )
        local reason = access_reason(player)
        if reason then
            send_result(
                player,
                "withdraw",
                {ok = false, reason = reason}
            )
            return
        end

        local result = config.bank:withdraw(
            player.UserId,
            item_id,
            quantity
        )
        send_result(player, "withdraw", result)

        if result.ok == true then
            if config.on_profile_changed then
                config.on_profile_changed(player)
            end
            send_snapshot(player)
        end
    end)

    return {
        anchor = bank_anchor,
    }
end

return table.freeze(BankRuntime)
