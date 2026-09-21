--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local combat = ReplicatedStorage:WaitForChild("Combat")
local core = ReplicatedStorage:WaitForChild("Core")
local shared = core:WaitForChild("Shared")
local remotes = core:WaitForChild("Remotes")

local CombatConfig = require(
    combat:WaitForChild("Shared"):WaitForChild("CombatConfig")
)
local CompletionRewardPresentation = require(
    shared:WaitForChild("CompletionRewardPresentation")
)
local PresentationLayers = require(
    shared:WaitForChild("PresentationLayers")
)
local UiComponents = require(
    shared:WaitForChild("UiComponents")
)
local UiStateRules = require(
    shared:WaitForChild("UiStateRules")
)
local UiTheme = require(
    shared:WaitForChild("UiTheme")
)

local dungeon_state = remotes:WaitForChild(
    "DungeonStateChanged"
) :: RemoteEvent
local revive_request = remotes:WaitForChild(
    "ReviveRequest"
) :: RemoteEvent
local revive_state = remotes:WaitForChild(
    "ReviveStateChanged"
) :: RemoteEvent
local return_request = remotes:WaitForChild(
    "ReturnRequest"
) :: RemoteEvent

local player_gui = player:WaitForChild("PlayerGui")
local old = player_gui:FindFirstChild("DungeonUi")
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "DungeonUi"
gui.ResetOnSpawn = false
gui.DisplayOrder = PresentationLayers.DUNGEON_REVIVE
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player_gui

local objective_card = Instance.new("Frame")
objective_card.Name = "ObjectiveCard"
objective_card.AnchorPoint = Vector2.new(0.5, 0)
objective_card.Position = UDim2.fromScale(0.5, 0.022)
objective_card.Size = UDim2.fromOffset(570, 62)
UiTheme.style_panel(objective_card, false)
objective_card.Parent = gui
UiTheme.bind_responsive_scale(
    objective_card,
    1366,
    0.78,
    1
)

local objective_caption = UiComponents.label(
    objective_card,
    "Caption",
    "CURRENT OBJECTIVE",
    "Caption"
)
objective_caption.Position = UDim2.fromOffset(16, 8)
objective_caption.Size = UDim2.new(1, -32, 0, 14)
objective_caption.TextColor3 = UiTheme.PALETTE.Accent
objective_caption.TextXAlignment = Enum.TextXAlignment.Center

local objective = UiComponents.label(
    objective_card,
    "Objective",
    "Entering the dungeon...",
    "Heading"
)
objective.Position = UDim2.fromOffset(16, 25)
objective.Size = UDim2.new(1, -32, 0, 27)
objective.TextXAlignment = Enum.TextXAlignment.Center
objective.TextWrapped = true

local boss_frame = Instance.new("Frame")
boss_frame.Name = "BossFrame"
boss_frame.AnchorPoint = Vector2.new(0.5, 0)
boss_frame.Position = UDim2.fromScale(0.5, 0.102)
boss_frame.Size = UDim2.fromOffset(640, 82)
UiTheme.style_panel(boss_frame, false)
boss_frame.Visible = false
boss_frame.Parent = gui
UiTheme.bind_responsive_scale(
    boss_frame,
    1366,
    0.78,
    1
)

local boss_caption = UiComponents.label(
    boss_frame,
    "Caption",
    "BOSS ENCOUNTER",
    "Caption"
)
boss_caption.Position = UDim2.fromOffset(16, 8)
boss_caption.Size = UDim2.new(0.4, 0, 0, 14)
boss_caption.TextColor3 = UiTheme.PALETTE.Danger

local boss_name = UiComponents.label(
    boss_frame,
    "BossName",
    "Unknown Boss",
    "Heading"
)
boss_name.Position = UDim2.fromOffset(16, 22)
boss_name.Size = UDim2.new(0.68, 0, 0, 24)

local boss_value = UiComponents.label(
    boss_frame,
    "BossValue",
    "",
    "Muted"
)
boss_value.AnchorPoint = Vector2.new(1, 0)
boss_value.Position = UDim2.new(1, -16, 0, 24)
boss_value.Size = UDim2.new(0.3, 0, 0, 22)
boss_value.TextXAlignment = Enum.TextXAlignment.Right

local boss_track = Instance.new("Frame")
boss_track.Name = "BossTrack"
boss_track.Position = UDim2.fromOffset(16, 55)
boss_track.Size = UDim2.new(1, -32, 0, 12)
boss_track.BackgroundColor3 = UiTheme.PALETTE.HealthDark
boss_track.BorderSizePixel = 0
UiTheme.add_corner(boss_track, 6)
boss_track.Parent = boss_frame

local boss_fill = Instance.new("Frame")
boss_fill.Name = "BossFill"
boss_fill.Size = UDim2.fromScale(1, 1)
boss_fill.BackgroundColor3 = UiTheme.PALETTE.Health
boss_fill.BorderSizePixel = 0
UiTheme.add_corner(boss_fill, 6)
UiTheme.add_gradient(
    boss_fill,
    UiTheme.PALETTE.Health:Lerp(
        UiTheme.PALETTE.Text,
        0.1
    ),
    UiTheme.PALETTE.Health
)
boss_fill.Parent = boss_track

local modal_backdrop = Instance.new("Frame")
modal_backdrop.Name = "ModalBackdrop"
modal_backdrop.Size = UDim2.fromScale(1, 1)
modal_backdrop.BackgroundColor3 = UiTheme.PALETTE.Backdrop
modal_backdrop.BackgroundTransparency = 0.28
modal_backdrop.Visible = false
modal_backdrop.ZIndex = 20
modal_backdrop.Parent = gui

local revive_panel = Instance.new("Frame")
revive_panel.Name = "RevivePanel"
revive_panel.AnchorPoint = Vector2.new(0.5, 0.5)
revive_panel.Position = UDim2.fromScale(0.5, 0.5)
revive_panel.Size = UDim2.fromOffset(500, 282)
revive_panel.ZIndex = 21
UiTheme.style_panel(revive_panel, true)
revive_panel.Visible = false
revive_panel.Parent = gui
UiTheme.bind_responsive_scale(
    revive_panel,
    1366,
    0.76,
    1
)

local revive_caption = UiComponents.label(
    revive_panel,
    "Caption",
    "EXPEDITION STATUS",
    "Caption"
)
revive_caption.Position = UDim2.fromOffset(24, 22)
revive_caption.Size = UDim2.new(1, -48, 0, 16)
revive_caption.TextColor3 = UiTheme.PALETTE.Danger
revive_caption.TextXAlignment = Enum.TextXAlignment.Center
revive_caption.ZIndex = 22

local revive_title = UiComponents.label(
    revive_panel,
    "Title",
    "DEFEATED",
    "Title"
)
revive_title.Position = UDim2.fromOffset(24, 43)
revive_title.Size = UDim2.new(1, -48, 0, 36)
revive_title.TextXAlignment = Enum.TextXAlignment.Center
revive_title.TextSize = 30
revive_title.ZIndex = 22

local revive_timer = UiComponents.label(
    revive_panel,
    "Timer",
    "Party still fighting",
    "Body"
)
revive_timer.Position = UDim2.fromOffset(24, 92)
revive_timer.Size = UDim2.new(1, -48, 0, 42)
revive_timer.TextXAlignment = Enum.TextXAlignment.Center
revive_timer.TextWrapped = true
revive_timer.ZIndex = 22

local revive_hint = UiComponents.label(
    revive_panel,
    "Hint",
    "Revive to rejoin the fight, or abandon this expedition.",
    "Muted"
)
revive_hint.Position = UDim2.fromOffset(34, 134)
revive_hint.Size = UDim2.new(1, -68, 0, 36)
revive_hint.TextXAlignment = Enum.TextXAlignment.Center
revive_hint.TextWrapped = true
revive_hint.ZIndex = 22

local revive_button = UiComponents.button(
    revive_panel,
    "ReviveButton",
    "Free Revive",
    "Primary"
)
revive_button.Position = UDim2.fromOffset(24, 204)
revive_button.Size = UDim2.new(0.5, -30, 0, 52)
revive_button.ZIndex = 22

local lobby_button = UiComponents.button(
    revive_panel,
    "LobbyButton",
    "Abandon Run",
    "Danger"
)
lobby_button.AnchorPoint = Vector2.new(1, 0)
lobby_button.Position = UDim2.new(1, -24, 0, 204)
lobby_button.Size = UDim2.new(0.5, -30, 0, 52)
lobby_button.ZIndex = 22

local complete_panel = Instance.new("Frame")
complete_panel.Name = "CompletePanel"
complete_panel.AnchorPoint = Vector2.new(0.5, 0.5)
complete_panel.Position = UDim2.fromScale(0.5, 0.5)
complete_panel.Size = UDim2.fromOffset(560, 320)
complete_panel.ZIndex = 21
UiTheme.style_panel(complete_panel, true)
complete_panel.Visible = false
complete_panel.Parent = gui
UiTheme.bind_responsive_scale(
    complete_panel,
    1366,
    0.76,
    1
)

local complete_caption = UiComponents.label(
    complete_panel,
    "Caption",
    "EXPEDITION COMPLETE",
    "Caption"
)
complete_caption.Position = UDim2.fromOffset(24, 22)
complete_caption.Size = UDim2.new(1, -48, 0, 16)
complete_caption.TextColor3 = UiTheme.PALETTE.Success
complete_caption.TextXAlignment = Enum.TextXAlignment.Center
complete_caption.ZIndex = 22

local complete_title = UiComponents.label(
    complete_panel,
    "Title",
    "VICTORY",
    "Title"
)
complete_title.Position = UDim2.fromOffset(24, 44)
complete_title.Size = UDim2.new(1, -48, 0, 40)
complete_title.TextXAlignment = Enum.TextXAlignment.Center
complete_title.TextSize = 31
complete_title.ZIndex = 22

local reward_frame = Instance.new("Frame")
reward_frame.Name = "RewardFrame"
reward_frame.Position = UDim2.fromOffset(28, 102)
reward_frame.Size = UDim2.new(1, -56, 0, 116)
reward_frame.BackgroundColor3 = UiTheme.PALETTE.Backdrop
reward_frame.BackgroundTransparency = 0.36
reward_frame.BorderSizePixel = 0
reward_frame.ZIndex = 22
UiTheme.add_corner(reward_frame, 8)
UiTheme.add_stroke(
    reward_frame,
    UiTheme.PALETTE.BorderSoft,
    0.5
)
reward_frame.Parent = complete_panel

local reward_label = UiComponents.label(
    reward_frame,
    "Reward",
    "Rewards are being finalised...",
    "Body"
)
reward_label.Position = UDim2.fromOffset(16, 12)
reward_label.Size = UDim2.new(1, -32, 1, -24)
reward_label.TextXAlignment = Enum.TextXAlignment.Center
reward_label.TextYAlignment = Enum.TextYAlignment.Center
reward_label.TextWrapped = true
reward_label.ZIndex = 23

local return_button = UiComponents.button(
    complete_panel,
    "ReturnButton",
    "Return to Base",
    "Primary"
)
return_button.AnchorPoint = Vector2.new(0, 0)
return_button.Position = UDim2.new(0, 28, 0, 244)
return_button.Size = UDim2.new(0.5, -36, 0, 52)
return_button.ZIndex = 22

local replay_button = UiComponents.button(
    complete_panel,
    "PlayAgainButton",
    "Play again",
    "Primary"
)
replay_button.Position = UDim2.new(0.5, 8, 0, 244)
replay_button.Size = UDim2.new(0.5, -36, 0, 52)
replay_button.ZIndex = 22

local wipe_ends_at: number? = nil
local revive_at: number? = nil
local current_member_mode: string? = nil
local revive_server_time = 0
local revive_received_at = 0
local return_at: number? = nil
local return_server_time = 0
local return_received_at = 0
local revive_action: string? = nil
local run_failed = false

--[[
Updates whether the full-screen modal backdrop is visible.

Args:
    None.

Returns:
    None.
]]
local function update_backdrop()
    modal_backdrop.Visible = revive_panel.Visible
        or complete_panel.Visible
end

--[[
Forces the local combat camera back to unlocked mode.

Args:
    None.

Returns:
    None.
]]
local function force_view_lock_off()
    player:SetAttribute(
        CombatConfig.VIEW_LOCK.STATE_ATTRIBUTE,
        false
    )
end

--[[
Updates the boss health presentation.

Args:
    payload (any): Dungeon-state payload containing boss health.

Returns:
    None.
]]
local function update_boss(payload: any)
    local health = tonumber(payload.boss_health) or 0
    local maximum = math.max(
        1,
        tonumber(payload.boss_max_health) or 1
    )

    boss_name.Text = tostring(
        payload.boss_name or "Dungeon Boss"
    )
    boss_value.Text = string.format(
        "%.0f / %.0f",
        health,
        maximum
    )
    UiTheme.set_bar_ratio(
        boss_fill,
        health / maximum
    )
end

--[[
Applies the revive-state payload to the defeat overlay.

Args:
    payload (any): Revive-state payload from the server.

Returns:
    None.
]]
local function apply_revive_state(payload: any)
    if type(payload) ~= "table" then
        return
    end

    if payload.error then
        revive_timer.Text = "Revive error: "
            .. tostring(payload.error)
        return
    end

    local mode = payload.member_mode
    current_member_mode = if type(mode) == "string"
        then mode
        else nil
    local state_name = if mode == "Dead"
        then "ReviveChoice"
        else tostring(mode)
    local projected = UiStateRules.for_state(
        state_name,
        payload
    )

    if projected.force_view_lock_off == true then
        force_view_lock_off()
    end

    revive_panel.Visible = mode == "Dead"
        or mode == "Reviving"
        or mode == "Spectating"
    complete_panel.Visible = false
    update_backdrop()

    local offer = payload.paid_offer
    if mode == "Reviving" then
        revive_title.Text = "RETURNING"
        revive_action = nil
        revive_button.Text = "Revive in progress"
        UiTheme.set_button_enabled(
            revive_button,
            false
        )
    elseif payload.free_available == true then
        revive_title.Text = "DEFEATED"
        revive_action = "Free"
        revive_button.Text = "Use Free Revive"
        UiTheme.set_button_enabled(
            revive_button,
            true
        )
    elseif type(offer) == "table" then
        revive_title.Text = "DEFEATED"
        revive_action = "Paid"
        revive_button.Text = if RunService:IsStudio()
            then string.format(
                "Simulate Revive  •  %d R$",
                offer.price or 0
            )
            else string.format(
                "Revive  •  %d R$",
                offer.price or 0
            )
        UiTheme.set_button_enabled(
            revive_button,
            RunService:IsStudio()
                or offer.live_enabled == true
        )
    else
        revive_title.Text = "DEFEATED"
        revive_action = nil
        revive_button.Text = "Revive unavailable"
        UiTheme.set_button_enabled(
            revive_button,
            false
        )
    end

    wipe_ends_at = payload.wipe_ends_at
    revive_at = payload.revive_at
    revive_server_time = payload.server_time or 0
    revive_received_at = os.clock()
end

--[[
Applies a dungeon-state payload to objective, boss and completion UI.

Args:
    payload (any): Dungeon-state payload from the server.

Returns:
    None.
]]
local function apply_dungeon_state(payload: any)
    if type(payload) ~= "table" then
        return
    end

    if type(payload.objective) == "string" then
        objective.Text = payload.objective
    end

    local state = tostring(payload.state)
    local projected = UiStateRules.for_state(
        state,
        payload
    )
    if projected.force_view_lock_off == true then
        force_view_lock_off()
    end

    boss_frame.Visible = state == "Boss"
    if state == "Boss" then
        update_boss(payload)
    end

    if state == "Complete" then
        run_failed = false
        complete_caption.Text = "EXPEDITION COMPLETE"
        complete_title.Text = "VICTORY"
        return_button.Text = "Return to Base"
        replay_button.Text = "Play again"
        UiTheme.set_button_enabled(replay_button, true)
        revive_panel.Visible = false
        boss_frame.Visible = false
        complete_panel.Visible = true
        update_backdrop()

        if payload.completion_eligible == false then
            reward_label.Text = "No completion reward. "
                .. "You were not eligible when the "
                .. "final encounter ended."
        elseif type(payload.completion) == "table" then
            reward_label.Text =
                CompletionRewardPresentation.text(
                    payload.completion
                )
        elseif payload.return_simulated == true then
            reward_label.Text =
                "Studio return simulated. "
                .. "Your committed reward remains saved."
        end

        if type(payload.return_at) == "number" then
            return_at = payload.return_at
            return_server_time = payload.server_time or 0
            return_received_at = os.clock()
        end
    elseif state == "Failed" then
        run_failed = true
        return_at = nil
        revive_action = nil
        complete_caption.Text = "EXPEDITION FAILED"
        complete_title.Text = "PARTY DEFEATED"
        return_button.Text = "Return to Base"
        replay_button.Text = "Play again"
        UiTheme.set_button_enabled(replay_button, true)
        reward_label.Text = if payload.return_simulated == true
            then "Studio return simulated. Start a new run from Base."
            else "This run has ended. Return to Base to start a new run."
        revive_panel.Visible = false
        boss_frame.Visible = false
        complete_panel.Visible = true
        update_backdrop()
    elseif state == "ReplayWaiting" then
        replay_button.Text = "Waiting for party"
        UiTheme.set_button_enabled(replay_button, false)
        reward_label.Text = "Waiting for the remaining party members "
            .. "to choose Play again. You can still return to Base."
    elseif state == "ReplaySimulated" then
        replay_button.Text = "Replay simulated"
        UiTheme.set_button_enabled(replay_button, false)
        reward_label.Text = "Studio replay simulated. In the published "
            .. "game a new reserved run would start."
    elseif state == "ReplayError" then
        replay_button.Text = "Retry Play again"
        UiTheme.set_button_enabled(replay_button, true)
        reward_label.Text = "Replay could not start: "
            .. tostring(payload.replay_error)
    end
end

--[[
Refreshes countdown text for revive and automatic return states.

Args:
    None.

Returns:
    None.
]]
local function update_countdowns()
    if revive_panel.Visible
        and current_member_mode == "Reviving"
        and type(revive_at) == "number" then
        local now = revive_server_time
            + (os.clock() - revive_received_at)
        revive_timer.Text = string.format(
            "Returning to the fight in %d",
            math.max(
                1,
                math.ceil(revive_at - now)
            )
        )
    elseif revive_panel.Visible
        and type(wipe_ends_at) == "number" then
        local now = revive_server_time
            + (os.clock() - revive_received_at)
        revive_timer.Text = string.format(
            "Revive window  •  %ds remaining",
            math.max(
                0,
                math.ceil(wipe_ends_at - now)
            )
        )
    elseif revive_panel.Visible then
        revive_timer.Text =
            "Your party is still fighting."
    end

    if complete_panel.Visible
        and type(return_at) == "number" then
        local now = return_server_time
            + (os.clock() - return_received_at)
        return_button.Text = string.format(
            "Return to Base  •  %ds",
            math.max(
                0,
                math.ceil(return_at - now)
            )
        )
    end
end

revive_button.Activated:Connect(function()
    if revive_action then
        revive_request:FireServer(revive_action)
    end
end)

lobby_button.Activated:Connect(function()
    return_request:FireServer("Abandon")
end)

return_button.Activated:Connect(function()
    return_request:FireServer(if run_failed then "Abandon" else "Complete")
end)

replay_button.Activated:Connect(function()
    UiTheme.set_button_enabled(replay_button, false)
    replay_button.Text = "Starting..."
    return_request:FireServer("PlayAgain")
end)

revive_state.OnClientEvent:Connect(
    apply_revive_state
)
dungeon_state.OnClientEvent:Connect(
    apply_dungeon_state
)
RunService.RenderStepped:Connect(
    update_countdowns
)
