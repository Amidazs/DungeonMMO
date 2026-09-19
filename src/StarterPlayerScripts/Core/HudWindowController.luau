--!strict
-- Coordinates player windows without coupling the individual UI scripts.
local Controller = {}
local registered: {[string]: (boolean) -> ()} = {}
local active: string? = nil
local changed = Instance.new("BindableEvent")

Controller.Changed = changed.Event

-- Registers a window's existing visibility function.
function Controller.register(
    name: string,
    apply_visibility: (boolean) -> ()
)
    registered[name] = apply_visibility
    apply_visibility(active == name)
end

-- Sets exclusive visibility for the requested window.
function Controller.set_visible(name: string, visible: boolean)
    if visible and not registered[name] then
        return
    end
    if visible then
        active = name
    elseif active == name then
        active = nil
    end
    for window_name, apply in pairs(registered) do
        apply(active == window_name)
    end
    changed:Fire(active)
end

-- Toggles a registered window from its menu button or shortcut.
function Controller.toggle(name: string)
    Controller.set_visible(name, active ~= name)
end

-- Returns the name of the currently open managed window.
function Controller.active(): string?
    return active
end

return Controller
