--!strict
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

if not RunService:IsStudio() then
    return
end

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Remotes")
local preview_request = remotes:WaitForChild("RaceChangePreviewRequest") :: RemoteEvent
local preview_remote = remotes:WaitForChild("RaceChangePreview") :: RemoteEvent
local apply_request = remotes:WaitForChild("RaceChangeApplyRequest") :: RemoteEvent
local action_result = remotes:WaitForChild("RaceChangeActionResult") :: RemoteEvent

local gui = Instance.new("ScreenGui")
gui.Name = "RaceChangeProofPanel"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "Panel"
frame.Size = UDim2.fromOffset(360, 260)
frame.Position = UDim2.new(1, -380, 0, 20)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 30)
title.Position = UDim2.fromOffset(10, 8)
title.Text = "DEV Race Change Proof"
title.Parent = frame
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 100)
status.Position = UDim2.fromOffset(10, 45)
status.TextWrapped = true
status.TextYAlignment = Enum.TextYAlignment.Top
status.Text = "Preview a target race."
status.Parent = frame

local function button(text: string, x: number): TextButton
    local control = Instance.new("TextButton")
    control.Size = UDim2.fromOffset(105, 34)
    control.Position = UDim2.fromOffset(x, 155)
    control.Text = text
    control.Parent = frame
    return control
end

local human = button("Preview Human", 10)
local elf = button("Preview Elf", 125)
local apply = button("Apply", 240)
apply.Active = false
apply.AutoButtonColor = false

local last_target: string? = nil
local last_hash: string? = nil

local function request_preview(target: string)
    last_target = nil
    last_hash = nil
    apply.Active = false
    apply.AutoButtonColor = false
    status.Text = "Requesting preview for " .. target .. "..."
    preview_request:FireServer(target)
end

human.Activated:Connect(function()
    request_preview("Human")
end)
elf.Activated:Connect(function()
    request_preview("Elf")
end)
preview_remote.OnClientEvent:Connect(function(payload: any)
    if type(payload) ~= "table" or payload.ok ~= true then
        local reason = if type(payload) == "table" then payload.reason else "InvalidPreview"
        status.Text = "Preview rejected: " .. tostring(reason)
        last_target = nil
        last_hash = nil
        apply.Active = false
        apply.AutoButtonColor = false
        return
    end

    last_target = payload.TargetRaceId
    last_hash = payload.Hash
    apply.Active = true
    apply.AutoButtonColor = true
    status.Text = string.format(
        "Target: %s\nArchive: %d  Restore: %d\nRefundable SP: %d  Unequip: %d",
        tostring(payload.TargetRaceId),
        #(payload.SkillsToArchive or {}),
        #(payload.SkillsToRestore or {}),
        tonumber(payload.RefundableSP) or 0,
        #(payload.EquipmentSlotsToUnequip or {})
    )
end)

apply.Activated:Connect(function()
    if not last_target or not last_hash then return end
    apply.Active = false
    apply.AutoButtonColor = false
    status.Text = "Applying Race Change..."
    apply_request:FireServer(
        last_target,
        last_hash,
        HttpService:GenerateGUID(false)
    )
end)

action_result.OnClientEvent:Connect(function(payload: any)
    if type(payload) ~= "table" then return end
    if payload.ok == true then
        local receipt = payload.receipt or {}
        status.Text = "Applied: " .. tostring(receipt.SourceRaceId)
            .. " -> " .. tostring(receipt.TargetRaceId)
            .. "\nRefunded allocation: " .. tostring(receipt.RefundableSP or 0)
    else
        status.Text = "Apply rejected: " .. tostring(payload.reason)
    end
    last_target = nil
    last_hash = nil
end)
