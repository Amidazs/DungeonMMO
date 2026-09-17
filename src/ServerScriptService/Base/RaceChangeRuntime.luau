--!strict
local RaceChangeRuntime = {}

local function valid_short_string(value: any): boolean
    return type(value) == "string" and value ~= "" and #value <= 128
end

function RaceChangeRuntime.attach(config: any): any
    assert(config.race_change ~= nil, "RaceChangeRuntime requires RaceChangeService")
    assert(config.remotes ~= nil, "RaceChangeRuntime requires Remotes")

    local preview_request = config.remotes:WaitForChild("RaceChangePreviewRequest") :: RemoteEvent
    local preview_remote = config.remotes:WaitForChild("RaceChangePreview") :: RemoteEvent
    local apply_request = config.remotes:WaitForChild("RaceChangeApplyRequest") :: RemoteEvent
    local action_result = config.remotes:WaitForChild("RaceChangeActionResult") :: RemoteEvent
    local rate_limits = config.rate_limits

    local function available(player: Player): boolean
        local callback = config.is_loaded
        return type(callback) ~= "function" or callback(player.UserId) == true
    end

    local function fire_action(player: Player, result: any)
        action_result:FireClient(player, {
            ok = result.ok == true,
            reason = result.reason,
            already_applied = result.already_applied == true,
            receipt = result.receipt,
        })
    end

    preview_request.OnServerEvent:Connect(function(player: Player, target_race_id: any)
        if not available(player) then return end
        if rate_limits and not rate_limits:allow(player.UserId, "RaceChangePreview", 6, 10) then
            preview_remote:FireClient(player, {ok=false, reason="RateLimited"})
            return
        end
        if not valid_short_string(target_race_id) then
            preview_remote:FireClient(player, {ok=false, reason="InvalidRaceChangeRequest"})
            return
        end
        preview_remote:FireClient(
            player,
            config.race_change:preview(player.UserId, target_race_id)
        )
    end)
    apply_request.OnServerEvent:Connect(function(
        player: Player,
        target_race_id: any,
        preview_hash: any,
        request_id: any
    )
        if not available(player) then return end
        if rate_limits and not rate_limits:allow(player.UserId, "RaceChangeApply", 2, 30) then
            fire_action(player, {ok=false, reason="RateLimited"})
            return
        end
        if not valid_short_string(target_race_id)
            or not valid_short_string(preview_hash)
            or not valid_short_string(request_id)
        then
            fire_action(player, {ok=false, reason="InvalidRaceChangeRequest"})
            return
        end

        local transaction_id = "RaceChange:" .. tostring(player.UserId) .. ":" .. request_id
        local applied = config.race_change:apply(
            player.UserId,
            target_race_id,
            preview_hash,
            transaction_id
        )
        fire_action(player, applied)

        if applied.ok == true then
            if type(config.on_changed) == "function" then
                config.on_changed(player)
            end
        end
    end)

    return {ok = true}
end

return table.freeze(RaceChangeRuntime)
