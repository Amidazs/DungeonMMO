--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")
local Dungeon = ServerScriptService:WaitForChild("Dungeon")
local Environment = ServerScriptService
    :WaitForChild("Core")
    :WaitForChild("Environment")

local Definitions = require(
    Shared:WaitForChild("EnvironmentAnchorDefinitions")
)
local Resolver = require(
    Environment:WaitForChild("EnvironmentAnchorResolver")
)

local module = Dungeon:FindFirstChild(
    "DungeonLayoutEnvironmentContract"
)
if not module then
    error(
        "[Dungeon Layout Environment Contract Tests] RED: "
            .. "DungeonLayoutEnvironmentContract is missing."
    )
end

local ContractBuilder = require(module)
local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error(
            "[Dungeon Layout Environment Contract Tests] "
                .. message,
            2
        )
    end
end

local function contains(values: {string}, target: string): boolean
    for _, value in ipairs(values) do
        if value == target then
            return true
        end
    end
    return false
end

local base_contract = {
    EnvironmentId = "SyntheticDungeon",
    Required = {
        "Synthetic.CompletionPosition",
        "Synthetic.ReturnToBase",
    },
    Optional = {},
    Groups = {},
}

local layout = {
    Id = "Depth2",
    EntranceAnchor = "Synthetic.EntrySpawn",
    Slots = {
        Room1 = {
            TriggerAnchor = "Synthetic.Room1.Trigger",
            CheckpointAnchor = "Synthetic.Room1.Checkpoint",
        },
        Room2 = {
            TriggerAnchor = "Synthetic.Room2.Trigger",
            CheckpointAnchor = "Synthetic.Room2.Checkpoint",
        },
        Room3 = {
            TriggerAnchor = "Synthetic.Room3.Trigger",
            CheckpointAnchor = "Synthetic.Room3.Checkpoint",
        },
        Room4 = {
            TriggerAnchor = "Synthetic.Room4.Trigger",
            CheckpointAnchor = "Synthetic.Room4.Checkpoint",
            ExitBarrierAnchor =
                "Synthetic.Room4.ExitBarrier",
            BossSpawnAnchor =
                "Synthetic.Room4.BossSpawn",
            EnemySpawnGroup =
                "SyntheticRoom4EnemySpawns",
            EnemySpawnPrefix =
                "Synthetic.Room4.EnemySpawn.",
            EnemySpawnMinCount = 4,
            SupportsCombat = true,
            SupportsBoss = true,
        },
    },
}

local built = ContractBuilder.build(
    base_contract,
    layout
)
check(built.ok == true, "Synthetic selected layout must build.")
local contract = built.Contract
check(
    contract.EnvironmentId == "SyntheticDungeon",
    "EnvironmentId must come from the runtime base contract."
)

check(
    contains(
        contract.Required,
        "Synthetic.CompletionPosition"
    ),
    "Base completion anchor must remain required."
)
check(
    contains(contract.Required, "Synthetic.EntrySpawn"),
    "Selected layout entrance must become required."
)
check(
    contains(
        contract.Required,
        "Synthetic.Room4.Trigger"
    )
        and contains(
            contract.Required,
            "Synthetic.Room4.Checkpoint"
        ),
    "Room4 trigger/checkpoint must become required."
)
check(
    contains(
        contract.Required,
        "Synthetic.Room4.ExitBarrier"
    ),
    "Room4 barrier must become required."
)
check(
    contains(
        contract.Required,
        "Synthetic.Room4.BossSpawn"
    ),
    "Room4 boss spawn must become required."
)

check(
    #contract.Groups == 1,
    "Synthetic layout must contribute one spawn group."
)
local room4_group = contract.Groups[1]
check(
    room4_group.Name == "SyntheticRoom4EnemySpawns"
        and room4_group.Prefix
            == "Synthetic.Room4.EnemySpawn."
        and room4_group.MinCount == 4,
    "Room4 group metadata must come from the physical slot."
)

local root = Instance.new("Folder")
local tagged = {}

local function add_anchor(anchor_id: string): BasePart
    local part = Instance.new("Part")
    part.Anchored = true
    part:SetAttribute(
        Definitions.ENVIRONMENT_ATTRIBUTE,
        "SyntheticDungeon"
    )
    part:SetAttribute(
        Definitions.ANCHOR_ATTRIBUTE,
        anchor_id
    )
    part.Parent = root
    table.insert(tagged, part)
    return part
end

for _, anchor_id in ipairs(contract.Required) do
    add_anchor(anchor_id)
end
for index = 1, 4 do
    add_anchor(
        "Synthetic.Room4.EnemySpawn."
            .. string.format("%02d", index)
    )
end

local resolved = Resolver.resolve(
    root,
    contract,
    tagged
)
check(resolved.ok == true, "Built contract must resolve.")
check(
    resolved.by_id["Synthetic.Room4.Trigger"]
        ~= nil,
    "Resolver must expose selected Room4 exact anchors."
)
check(
    #resolved.groups.SyntheticRoom4EnemySpawns == 4,
    "Resolver must expose the selected Room4 spawn group."
)

local short_tagged = {}
for _, instance in ipairs(tagged) do
    local anchor_id = instance:GetAttribute(
        Definitions.ANCHOR_ATTRIBUTE
    )
    if anchor_id ~= "Synthetic.Room4.EnemySpawn.04" then
        table.insert(short_tagged, instance)
    end
end

local short_group = Resolver.resolve(
    root,
    contract,
    short_tagged
)
check(
    short_group.reason == "InsufficientAnchorGroup",
    "Selected layout spawn minimum must fail closed."
)

local invalid_layout = table.clone(layout)
invalid_layout.Slots = table.clone(layout.Slots)
invalid_layout.Slots.Room4 = table.clone(
    layout.Slots.Room4
)
invalid_layout.Slots.Room4.EnemySpawnPrefix = nil

local invalid = ContractBuilder.build(
    base_contract,
    invalid_layout
)
check(
    invalid.reason == "InvalidEnemySpawnGroup",
    "Incomplete combat spawn metadata must fail closed."
)

root:Destroy()

print(string.format(
    "[Dungeon Layout Environment Contract Tests] PASS: %d assertions.",
    assertion_count
))
