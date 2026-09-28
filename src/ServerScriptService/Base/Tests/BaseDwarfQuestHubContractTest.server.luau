--!strict
-- Optional Dwarf quest-hub environment anchor regression.

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Definitions = require(
    RS.Core.Shared.EnvironmentAnchorDefinitions
)
local Resolver = require(
    SSS.Core.Environment.EnvironmentAnchorResolver
)
local Synthetic = require(
    SSS.Base.BaseSyntheticEnvironment
)

local checks = 0

--[[
Counts one Dwarf quest-hub environment assertion.

Args:
    valid (boolean): Expected environment-contract condition.
    label (string): Diagnostic description for failure.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[Dwarf Quest Hub Contract] " .. label)
end

--[[
Checks whether one anchor identifier occurs in an immutable list.

Args:
    values ({string}): Anchor ID list.
    target (string): Anchor identifier to locate.

Returns:
    boolean: True when the exact anchor identifier exists.
]]
local function contains(values: {string}, target: string): boolean
    for _, value in ipairs(values) do
        if value == target then
            return true
        end
    end
    return false
end

--[[
Runs the optional-anchor and synthetic-resolution contract.

Args:
    None.

Returns:
    nil: Prints a stable pass marker after all checks succeed.
]]
local function main()
    check(
        contains(
            Definitions.BASE.Optional,
            "Base.DwarfQuestHub"
        ),
        "Dwarf quest hub is declared as an optional Base anchor"
    )
    check(
        not contains(
            Definitions.BASE.Required,
            "Base.DwarfQuestHub"
        ),
        "Dwarf quest hub does not break older Base environments"
    )

    local root = Instance.new("Folder")
    root.Name = "TEMP_DwarfQuestHubEnvironment"
    root.Parent = workspace

    Synthetic.create(root)
    local resolved = Resolver.resolve(root, Definitions.BASE)

    check(resolved.ok == true, "synthetic Base environment resolves")
    local anchor = resolved.by_id["Base.DwarfQuestHub"]
    check(
        anchor ~= nil
            and anchor:IsA("BasePart"),
        "synthetic Base exposes physical Dwarf quest-hub anchor"
    )
    check(
        anchor:GetAttribute(
            Definitions.ROLE_ATTRIBUTE
        ) == "QuestHub",
        "Dwarf quest-hub anchor keeps explicit QuestHub role"
    )

    root:Destroy()

    print(
        ("[Dwarf Quest Hub Contract] PASS: %d assertions")
            :format(checks)
    )
end

main()
