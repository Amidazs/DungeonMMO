--!strict
-- Physical first-transfer mentor layout and Dwarf-anchor regression.

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Definitions = require(
    RS.Core.Shared.OriginalFirstTransferDefinitions
)
local Runtime = require(
    SSS.Base.OriginalFirstTransferMentorRuntime
)

local checks = 0

--[[
Counts one mentor-layout assertion.

Args:
    valid (boolean): Expected physical mentor/trainer condition.
    label (string): Diagnostic description for failure.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[First Transfer Mentor Binding] " .. label)
end

--[[
Creates one disposable physical environment anchor.

Args:
    name (string): Test anchor name.
    position (Vector3): World position for isolation.

Returns:
    Part: Anchored Workspace test part.
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
Creates the minimum profile facade required during runtime composition.

Args:
    None.

Returns:
    any: Disposable profile authority facade.
]]
local function fake_profiles(): any
    return {
        get_character = function(): any?
            return nil
        end,
    }
end

--[[
Creates a synthetic Base environment with optional Dwarf hub.

Args:
    spawn (Part): Generic Base player-spawn anchor.
    dwarf_anchor (Part?): Optional Dwarf quest-hub anchor.

Returns:
    any: Production-shaped environment getter.
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
Checks one branch has both its mentor and separate trainer actor.

Args:
    runtime (any): Attached mentor runtime.
    branch_id (string): First-transfer branch under test.

Returns:
    nil: Verifies physical actor identity and prompt separation.
]]
local function check_bound(runtime: any, branch_id: string)
    local definition = assert(Definitions.for_branch(branch_id))
    check(
        runtime:available(definition),
        branch_id .. " physical mentor is available"
    )

    local mentor = runtime._folder:FindFirstChild(definition.MentorId)
    local trainer = runtime._folder:FindFirstChild(definition.TrainerId)
    check(
        mentor ~= nil and trainer ~= nil and mentor ~= trainer,
        branch_id .. " mentor and trainer are separate actors"
    )
    check(
        mentor:FindFirstChild("FirstTransferMentorPrompt") ~= nil,
        branch_id .. " mentor has advancement prompt"
    )
    check(
        trainer:FindFirstChild("ProgressionTrainerPrompt") ~= nil,
        branch_id .. " trainer has training prompt"
    )
end

--[[
Runs explicit-layout and Dwarf-anchor structural acceptance.

Args:
    None.

Returns:
    nil: Prints a stable pass marker after layout checks succeed.
]]
local function main()
    local spawn = make_anchor(
        "TEMP_MentorSpawn",
        Vector3.new(7000, 20, 7000)
    )
    local dwarf_anchor = make_anchor(
        "TEMP_DwarfMentorHub",
        Vector3.new(7200, 20, 7000)
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

    check_bound(runtime, "HumanRogue")
    check_bound(runtime, "ElvenScout")
    check_bound(runtime, "DwarfArtisan")
    check_bound(runtime, "DwarfScavenger")

    check(
        not runtime:available(
            assert(Definitions.for_branch("OrcShaman"))
        ),
        "unlaid-out Orc mentor does not spawn at a random hub offset"
    )

    local artisan = assert(Definitions.for_branch("DwarfArtisan"))
    local scavenger = assert(Definitions.for_branch("DwarfScavenger"))
    check(
        artisan.MentorName == "Forgekeeper Orda",
        "Gearwright mentor display name is DungeonMMO-original"
    )
    check(
        scavenger.MentorName == "Salvage Master Veyda",
        "Deepclaimer mentor display name is DungeonMMO-original"
    )

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
        not no_dwarf_runtime:available(artisan)
            and not no_dwarf_runtime:available(scavenger),
        "Dwarf mentors do not fall back to Base.PlayerSpawn"
    )
    check(
        no_dwarf_runtime:available(
            assert(Definitions.for_branch("HumanRogue"))
        ),
        "existing explicit Human mentor layout remains available"
    )

    runtime._folder:Destroy()
    no_dwarf_runtime._folder:Destroy()
    spawn:Destroy()
    dwarf_anchor:Destroy()

    print(
        ("[First Transfer Mentor Binding] PASS: %d assertions")
            :format(checks)
    )
end

main()
