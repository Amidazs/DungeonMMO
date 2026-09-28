--!strict
-- Target-driven physical original quest NPC binding regression.

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Runtime = require(SSS.Base.C4OriginalQuestNpcRuntime)
local Quests = require(
    RS.Core.Shared.C4OriginalFirstTransferQuestStages
)

local checks = 0

--[[
Counts one physical-NPC binding assertion.

Args:
    valid (boolean): Expected world-binding condition.
    label (string): Diagnostic description for failure.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[Original Quest NPC Binding] " .. label)
end

--[[
Creates one disposable physical anchor.

Args:
    name (string): Test anchor name.
    position (Vector3): World position for synthetic placement.

Returns:
    Part: Anchored Workspace part for the fake environment.
]]
local function make_anchor(name: string, position: Vector3): Part
    local part = Instance.new("Part")
    part.Name = name
    part.Anchored = true
    part.CFrame = CFrame.new(position)
    part.Parent = workspace
    return part
end

--[[
Creates the minimum profile interface required to compose the NPC runtime.

Args:
    None.

Returns:
    any: Profile facade that intentionally exposes no loaded player.
]]
local function fake_profiles(): any
    return {
        get_character = function(): any?
            return nil
        end,
    }
end

--[[
Creates a synthetic Base environment with optional Dwarf quest anchor.

Args:
    spawn (Part): Existing Base player-spawn anchor.
    dwarf_anchor (Part?): Optional Dwarf quest-hub anchor.

Returns:
    any: Environment facade with the production get() contract.
]]
local function fake_environment(
    spawn: Part,
    dwarf_anchor: Part?
): any
    return {
        get = function(_self: any, key: string): any?
            if key == "Base.PlayerSpawn" then
                return spawn
            end
            if key == "Base.DwarfQuestHub" then
                return dwarf_anchor
            end
            return nil
        end,
    }
end

--[[
Checks every requested quest step against physical NPC availability.

Args:
    runtime (any): Attached original quest NPC runtime.
    branch_id (string): Original first-transfer branch.
    expected ({[number]: boolean}): Step-to-availability contract.

Returns:
    nil: Verifies talk/combat actors resolve to the correct world binder.
]]
local function check_steps(
    runtime: any,
    branch_id: string,
    expected: {[number]: boolean}
)
    local quest = assert(Quests.get(branch_id))

    for step_index, should_exist in pairs(expected) do
        check(
            runtime:available(quest, step_index) == should_exist,
            branch_id
                .. " step "
                .. tostring(step_index)
                .. " availability"
        )
    end
end

--[[
Runs target-driven mapping for existing and Dwarf quest shapes.

Args:
    None.

Returns:
    nil: Prints a stable pass marker after all bindings are verified.
]]
local function main()
    local spawn = make_anchor(
        "TEMP_OriginalNpcSpawn",
        Vector3.new(6000, 20, 6000)
    )
    local dwarf_anchor = make_anchor(
        "TEMP_DwarfQuestHub",
        Vector3.new(6200, 20, 6000)
    )

    local runtime = Runtime.attach({
        environment = fake_environment(spawn, dwarf_anchor),
        profiles = fake_profiles(),
        is_ready = function(): boolean
            return true
        end,
        on_progress = function()
        end,
    })

    check_steps(runtime, "HumanWarrior", {
        [1] = true,
        [2] = true,
        [3] = false,
        [4] = true,
        [5] = false,
        [6] = true,
    })
    check_steps(runtime, "HumanRogue", {
        [1] = true,
        [2] = true,
        [3] = false,
        [4] = true,
        [5] = true,
        [6] = false,
        [7] = true,
    })
    check_steps(runtime, "ElvenScout", {
        [1] = true,
        [2] = true,
        [3] = false,
        [4] = true,
        [5] = false,
        [6] = false,
        [7] = false,
        [8] = true,
        [9] = true,
    })

    check_steps(runtime, "DwarfArtisan", {
        [1] = true,
        [2] = false,
        [3] = false,
        [4] = true,
        [5] = true,
        [6] = true,
        [7] = false,
        [8] = true,
        [9] = true,
        [10] = true,
    })
    check_steps(runtime, "DwarfScavenger", {
        [1] = true,
        [2] = true,
        [3] = true,
        [4] = false,
        [5] = true,
        [6] = false,
        [7] = true,
        [8] = true,
        [9] = true,
        [10] = true,
        [11] = true,
    })

    local no_dwarf_runtime = Runtime.attach({
        environment = fake_environment(spawn, nil),
        profiles = fake_profiles(),
        is_ready = function(): boolean
            return true
        end,
        on_progress = function()
        end,
    })
    check(
        not no_dwarf_runtime:available(
            assert(Quests.get("DwarfArtisan")),
            1
        ),
        "Dwarf Artisan does not spawn at the generic Base player spawn"
    )
    check(
        not no_dwarf_runtime:available(
            assert(Quests.get("DwarfScavenger")),
            1
        ),
        "Dwarf Scavenger does not spawn without DwarfQuestHub"
    )
    check(
        no_dwarf_runtime:available(
            assert(Quests.get("HumanWarrior")),
            1
        ),
        "existing Human binding still uses Base.PlayerSpawn"
    )

    spawn:Destroy()
    dwarf_anchor:Destroy()

    print(
        ("[Original Quest NPC Binding] PASS: %d assertions")
            :format(checks)
    )
end

main()
