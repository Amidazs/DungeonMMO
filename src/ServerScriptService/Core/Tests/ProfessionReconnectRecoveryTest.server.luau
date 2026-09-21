--!strict
-- Simulates the SAME account leaving while a server craft is suspended,
-- then reloading from one shared in-memory adapter and retrying safely.
-- This is a service lifecycle test, NOT a real same-account network login.
local SSS = game:GetService("ServerScriptService")
local Core = SSS:WaitForChild("Core")
local Services = Core:WaitForChild("Services")
local Adapters = Core:WaitForChild("Adapters")

local Adapter = require(Adapters:WaitForChild("InMemoryProfileAdapter"))
local Profiles = require(Services:WaitForChild("ProfileService"))
local Inventory = require(Services:WaitForChild("InventoryService"))
local Professions = require(Services:WaitForChild("ProfessionService"))
local Runtime = require(Services:WaitForChild("ProfessionRuntime"))

local USER_ID = 930153
local assertions = 0

-- Args:
--   valid: boolean; required recovery invariant.
--   description: string; useful failure context.
-- Returns:
--   nil: counts each assertion and raises if it fails.
local function check(valid: boolean, description: string)
    assertions += 1
    assert(valid, "[Profession Reconnect] " .. description)
end

-- Args:
--   predicate: () -> boolean; condition to await.
--   description: string; missing event to identify on timeout.
-- Returns:
--   nil: returns when condition becomes true, or raises.
local function wait_until(predicate: () -> boolean, description: string)
    local deadline = os.clock() + 5
    while not predicate() and os.clock() < deadline do
        task.wait(0.05)
    end
    check(predicate(), "timed out waiting for " .. description)
end

-- Args:
--   profiles: any; loaded authoritative account state.
-- Returns:
--   (number, number): available ore and crafted bars.
local function count_materials(profiles: any): (number, number)
    local character = assert(profiles:get_character(USER_ID, 1))
    return Inventory.count_item(character, "iron_ore"),
        Inventory.count_item(character, "iron_bar")
end

local adapter = Adapter.new()
local profiles = Profiles.new(adapter)
local inventory = Inventory.new(profiles)
local professions = Professions.new(profiles, inventory)
local guard = Runtime.new_craft_request_guard()

check(profiles:load(USER_ID) ~= nil, "initial account profile loads")
local initial_ore, initial_bars = count_materials(profiles)
if initial_ore > 0 then
    check(inventory:consume_item(
        USER_ID, "iron_ore", initial_ore).ok,
        "test removes any starter ore before controlled input")
end
check(inventory:add_item(USER_ID, "iron_ore", 2).ok,
    "the original session receives ingredients for one craft")
local acquired, old_ticket = guard:try_begin(USER_ID)
check(acquired and old_ticket ~= nil, "original request has a ticket")

local resume_old = Instance.new("BindableEvent")
local prepared_old = false
local completed_old = false
local stale_finish = true
local stale_awarded = false
task.spawn(function()
    local prepared = professions:prepare_craft(USER_ID, "smelt_iron_bar")
    prepared_old = prepared.ok == true
    resume_old.Event:Wait()
    if guard:is_current(USER_ID, old_ticket) then
        stale_awarded = professions:complete_craft(
            USER_ID, "smelt_iron_bar",
            professions.foundation_success_outcome(
                prepared.minigame_id)).ok
    end
    stale_finish = guard:finish(USER_ID, old_ticket)
    completed_old = true
end)
wait_until(function()
    return prepared_old
end, "original craft preparation")

check(guard:finish(USER_ID, old_ticket),
    "simulated PlayerRemoving invalidates the old request")
check(profiles:release(USER_ID, "SimulatedDisconnect"),
    "disconnect saves and releases the original profile")
check(profiles:get_profile(USER_ID) == nil,
    "old account cache is no longer writable")

check(profiles:load(USER_ID) ~= nil,
    "same UserId successfully reloads from the saved adapter")
local ore_after_reload, bars_after_reload = count_materials(profiles)
check(ore_after_reload == 2 and bars_after_reload == initial_bars,
    "interrupted preparation did not consume inputs or award output")

local new_acquired, new_ticket = guard:try_begin(USER_ID)
check(new_acquired and new_ticket ~= old_ticket,
    "reconnected account obtains a distinct current craft ticket")
resume_old:Fire()
wait_until(function()
    return completed_old
end, "suspended old request cancellation")
check(not stale_awarded and not stale_finish,
    "stale request cannot craft or clear the new connection's lock")
check(guard:is_current(USER_ID, new_ticket),
    "old request cleanup did not release the reconnected request")

local prepared_new = professions:prepare_craft(
    USER_ID, "smelt_iron_bar")
check(prepared_new.ok, "retry prepares with preserved materials")
local result = professions:complete_craft(
    USER_ID, "smelt_iron_bar",
    professions.foundation_success_outcome(prepared_new.minigame_id))
check(result.ok and result.item_id == "iron_bar",
    "new session crafts once through the authoritative service")
check(guard:finish(USER_ID, new_ticket),
    "new request releases only its own current ticket")
local final_ore, final_bars = count_materials(profiles)
check(final_ore == 0 and final_bars == initial_bars + 1,
    "retry consumes exactly two ore and grants precisely one bar")

check(profiles:release(USER_ID, "SimulatedSecondDisconnect"),
    "successful retry is saved before a second release")
local newly_started_profiles = Profiles.new(adapter)
check(newly_started_profiles:load(USER_ID) ~= nil,
    "fresh profile service can reload the same saved account")
local saved_ore, saved_bars = count_materials(newly_started_profiles)
check(saved_ore == 0 and saved_bars == initial_bars + 1,
    "save/release/reload preserves the one completed craft")

resume_old:Destroy()
print(string.format(
    "[Profession Reconnect] PASS: %d assertions.", assertions))
