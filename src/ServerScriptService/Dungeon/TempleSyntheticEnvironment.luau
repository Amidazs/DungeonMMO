--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Factory = require(
    ServerScriptService
        :WaitForChild("Core")
        :WaitForChild("Environment")
        :WaitForChild("EnvironmentAnchorFactory")
)

local TempleSyntheticEnvironment = {}

local function make_part(
    parent: Instance,
    name: string,
    size: Vector3,
    cframe: CFrame
): Part
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Anchored = true
    part.Material = Enum.Material.Slate
    part.Color = Color3.fromRGB(78, 79, 84)
    part.Parent = parent
    return part
end

local function create_route(parent: Instance)
    local existing = parent:FindFirstChild("DungeonMMOSyntheticTemple")
    if existing then
        existing:Destroy()
    end

    local root = Instance.new("Folder")
    root.Name = "DungeonMMOSyntheticTemple"
    root.Parent = parent

    make_part(root, "EntranceFloor", Vector3.new(52, 1, 50), CFrame.new(250, 0, 35))
    make_part(root, "Room1Floor", Vector3.new(64, 1, 64), CFrame.new(250, 0, -45))
    make_part(root, "Room2Floor", Vector3.new(72, 1, 72), CFrame.new(250, 0, -145))
    make_part(root, "Room3Floor", Vector3.new(80, 1, 80), CFrame.new(250, 0, -315))
    make_part(root, "Corridor1", Vector3.new(18, 1, 32), CFrame.new(250, 0, -2))
    make_part(root, "Corridor2", Vector3.new(18, 1, 40), CFrame.new(250, 0, -95))
    make_part(root, "Corridor3", Vector3.new(18, 1, 94), CFrame.new(250, 0, -228))
end

function TempleSyntheticEnvironment.create(parent: Instance)
    create_route(parent)

    local entries = {
        {"Temple.EntrySpawn", CFrame.new(250, 1, 50), "Spawn", Vector3.new(6, 2, 6), false, false},
        {"Temple.Room1.Checkpoint", CFrame.new(250, 1, -18), "Checkpoint", Vector3.new(6, 2, 6), false, false},
        {"Temple.Room1.Trigger", CFrame.new(250, 3, -18), "EncounterTrigger", Vector3.new(50, 6, 5), true, false},
        {"Temple.Room1.EnemySpawn.01", CFrame.new(238, 2, -48), "EnemySpawn", Vector3.new(3, 2, 3), false, false},
        {"Temple.Room1.EnemySpawn.02", CFrame.new(262, 2, -48), "EnemySpawn", Vector3.new(3, 2, 3), false, false},
        {"Temple.Room1.ExitBarrier", CFrame.new(250, 5, -76), "ExitBarrier", Vector3.new(20, 10, 1.5), false, true},
        {"Temple.Room2.Checkpoint", CFrame.new(250, 1, -112), "Checkpoint", Vector3.new(6, 2, 6), false, false},
        {"Temple.Room2.Trigger", CFrame.new(250, 3, -112), "EncounterTrigger", Vector3.new(56, 6, 5), true, false},
        {"Temple.Room2.EnemySpawn.01", CFrame.new(232, 2, -148), "EnemySpawn", Vector3.new(3, 2, 3), false, false},
        {"Temple.Room2.EnemySpawn.02", CFrame.new(250, 2, -160), "EnemySpawn", Vector3.new(3, 2, 3), false, false},
        {"Temple.Room2.EnemySpawn.03", CFrame.new(268, 2, -148), "EnemySpawn", Vector3.new(3, 2, 3), false, false},
        {"Temple.Room2.ExitBarrier", CFrame.new(250, 5, -181), "ExitBarrier", Vector3.new(20, 10, 1.5), false, true},
        {"Temple.Room3.Checkpoint", CFrame.new(250, 1, -284), "Checkpoint", Vector3.new(6, 2, 6), false, false},
        {"Temple.Room3.Trigger", CFrame.new(250, 3, -284), "EncounterTrigger", Vector3.new(58, 6, 5), true, false},
        {"Temple.Room3.CaptainSpawn", CFrame.new(250, 2, -315), "BossSpawn", Vector3.new(4, 2, 4), false, false},
        {"Temple.CompletionPosition", CFrame.new(250, 2, -337), "CompletionPosition", Vector3.new(6, 2, 6), false, false},
        {"Temple.ReturnToBase", CFrame.new(250, 2, -344), "ReturnPresentation", Vector3.new(6, 2, 6), false, false},
    }

    for _, entry in ipairs(entries) do
        local anchor = Factory.create(
            parent,
            "Temple",
            entry[1] :: string,
            entry[2] :: CFrame,
            entry[4] :: Vector3,
            entry[3] :: string
        )
        anchor.CanTouch = entry[5] == true
        anchor.CanCollide = entry[6] == true
    end
end

return table.freeze(TempleSyntheticEnvironment)
