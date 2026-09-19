--!strict
local StarterGui = game:GetService("StarterGui")

--[[
Sets one Roblox CoreGui feature when the engine currently permits it.

Args:
    core_gui_type (Enum.CoreGuiType): CoreGui feature to update.
    enabled (boolean): Desired enabled state.

Returns:
    None.
]]
local function set_core_gui(
    core_gui_type: Enum.CoreGuiType,
    enabled: boolean
)
    local attempts = 0

    while attempts < 8 do
        attempts += 1

        local ok = pcall(function()
            StarterGui:SetCoreGuiEnabled(
                core_gui_type,
                enabled
            )
        end)

        if ok then
            return
        end

        task.wait(0.25)
    end
end

task.spawn(function()
    set_core_gui(Enum.CoreGuiType.Health, false)
    set_core_gui(Enum.CoreGuiType.Backpack, false)
end)
