--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Definitions = require(
    ReplicatedStorage
        :WaitForChild("Core")
        :WaitForChild("Shared")
        :WaitForChild("EnvironmentAnchorDefinitions")
)
local Resolver = require(
    ServerScriptService
        :WaitForChild("Core")
        :WaitForChild("Environment")
        :WaitForChild("EnvironmentAnchorResolver")
)

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Environment Anchor Resolver Tests] " .. message, 2)
    end
end

local function anchor(
    parent: Instance,
    environment_id: string,
    anchor_id: string
): Part
    local part = Instance.new("Part")
    part.Anchored = true
    part:SetAttribute(Definitions.ENVIRONMENT_ATTRIBUTE, environment_id)
    part:SetAttribute(Definitions.ANCHOR_ATTRIBUTE, anchor_id)
    part.Parent = parent
    return part
end

local contract = {
    EnvironmentId = "Temple",
    Required = {
        "Temple.EntrySpawn",
        "Temple.Room1.Trigger",
    },
    Optional = {},
    Groups = {
        {
            Name = "Room1EnemySpawns",
            Prefix = "Temple.Room1.EnemySpawn.",
            MinCount = 2,
        },
    },
}

do
    local root = Instance.new("Folder")
    local tagged = {
        anchor(root, "Temple", "Temple.EntrySpawn"),
        anchor(root, "Temple", "Temple.Room1.Trigger"),
        anchor(root, "Temple", "Temple.Room1.EnemySpawn.02"),
        anchor(root, "Temple", "Temple.Room1.EnemySpawn.01"),
    }
    local result = Resolver.resolve(root, contract, tagged)
    check(result.ok == true, "valid anchors must resolve")
    check(
        #result.groups.Room1EnemySpawns == 2,
        "spawn group must resolve"
    )
    check(
        result.groups.Room1EnemySpawns[1]
            :GetAttribute(Definitions.ANCHOR_ATTRIBUTE)
            == "Temple.Room1.EnemySpawn.01",
        "groups must sort by AnchorId"
    )
    root:Destroy()
end

do
    local root = Instance.new("Folder")
    local tagged = {
        anchor(root, "Temple", "Temple.EntrySpawn"),
        anchor(root, "Temple", "Temple.Room1.EnemySpawn.01"),
        anchor(root, "Temple", "Temple.Room1.EnemySpawn.02"),
    }
    local result = Resolver.resolve(root, contract, tagged)
    check(
        result.reason == "MissingAnchor",
        "missing exact anchor must fail with MissingAnchor"
    )
    root:Destroy()
end

do
    local root = Instance.new("Folder")
    local tagged = {
        anchor(root, "Temple", "Temple.EntrySpawn"),
        anchor(root, "Temple", "Temple.EntrySpawn"),
        anchor(root, "Temple", "Temple.Room1.Trigger"),
        anchor(root, "Temple", "Temple.Room1.EnemySpawn.01"),
        anchor(root, "Temple", "Temple.Room1.EnemySpawn.02"),
    }
    local result = Resolver.resolve(root, contract, tagged)
    check(
        result.reason == "DuplicateAnchor",
        "duplicate exact anchor must fail with DuplicateAnchor"
    )
    root:Destroy()
end

do
    local root = Instance.new("Folder")
    local invalid = Instance.new("Folder")
    invalid:SetAttribute(
        Definitions.ENVIRONMENT_ATTRIBUTE,
        "Temple"
    )
    invalid:SetAttribute(
        Definitions.ANCHOR_ATTRIBUTE,
        "Temple.EntrySpawn"
    )
    invalid.Parent = root
    local result = Resolver.resolve(root, contract, {invalid})
    check(
        result.reason == "InvalidAnchorInstance",
        "non-BasePart tagged instance must fail"
    )
    root:Destroy()
end


do
    local root = Instance.new("Folder")
    local outside = Instance.new("Folder")
    local part = anchor(outside, "Temple", "Temple.EntrySpawn")
    local result = Resolver.resolve(root, contract, {part})
    check(
        result.reason == "InvalidAnchorInstance",
        "anchor outside supplied root must fail"
    )
    root:Destroy()
    outside:Destroy()
end

do
    local root = Instance.new("Folder")
    local tagged = {
        anchor(root, "Base", "Temple.EntrySpawn"),
    }
    local result = Resolver.resolve(root, contract, tagged)
    check(
        result.reason == "WrongEnvironment",
        "wrong environment must fail with WrongEnvironment"
    )
    root:Destroy()
end

do
    local root = Instance.new("Folder")
    local tagged = {
        anchor(root, "Temple", "Temple.EntrySpawn"),
        anchor(root, "Temple", "Temple.Room1.Trigger"),
        anchor(root, "Temple", "Temple.Room1.EnemySpawn.01"),
    }
    local result = Resolver.resolve(root, contract, tagged)
    check(
        result.reason == "InsufficientAnchorGroup",
        "short group must fail with InsufficientAnchorGroup"
    )
    root:Destroy()
end

print(string.format(
    "[Environment Anchor Resolver Tests] PASS: %d assertions.",
    assertions
))
