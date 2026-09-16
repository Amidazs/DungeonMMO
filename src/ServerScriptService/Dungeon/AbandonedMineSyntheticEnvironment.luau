--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Factory = require(
    ServerScriptService:WaitForChild("Core"):WaitForChild("Environment"):WaitForChild("EnvironmentAnchorFactory")
)
local MineSyntheticEnvironment = {}

local function make_part(parent: Instance, name: string, size: Vector3, cframe: CFrame, material: Enum.Material, color: Color3): Part
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Anchored = true
    part.Material = material
    part.Color = color
    part.Parent = parent
    return part
end

function MineSyntheticEnvironment.create(parent: Instance)
    local existing = parent:FindFirstChild("DungeonMMOSyntheticMine")
    if existing then existing:Destroy() end
    local root = Instance.new("Folder")
    root.Name = "DungeonMMOSyntheticMine"
    root.Parent = parent

    local stone = Color3.fromRGB(68, 64, 59)
    local timber = Color3.fromRGB(91, 62, 37)
    make_part(root, "EntryFloor", Vector3.new(48,1,48), CFrame.new(450,0,42), Enum.Material.Slate, stone)
    make_part(root, "Room1Floor", Vector3.new(70,1,68), CFrame.new(450,0,-52), Enum.Material.Slate, stone)
    make_part(root, "Room2Floor", Vector3.new(78,1,76), CFrame.new(450,0,-160), Enum.Material.Slate, stone)
    make_part(root, "BossFloor", Vector3.new(84,1,80), CFrame.new(450,0,-302), Enum.Material.Slate, stone)
    make_part(root, "Corridor1", Vector3.new(18,1,46), CFrame.new(450,0,-3), Enum.Material.Slate, stone)
    make_part(root, "Corridor2", Vector3.new(18,1,42), CFrame.new(450,0,-107), Enum.Material.Slate, stone)
    make_part(root, "Corridor3", Vector3.new(18,1,64), CFrame.new(450,0,-232), Enum.Material.Slate, stone)
    for _, z in ipairs({-76, -28, 16}) do
        make_part(root, "SupportA_" .. tostring(z), Vector3.new(2,10,2), CFrame.new(420,5,z), Enum.Material.WoodPlanks, timber)
        make_part(root, "SupportB_" .. tostring(z), Vector3.new(2,10,2), CFrame.new(480,5,z), Enum.Material.WoodPlanks, timber)
    end

    local entries = {
        {"Mine.EntrySpawn", CFrame.new(450,1,53), "Spawn", Vector3.new(6,2,6), false, false},
        {"Mine.Room1.Checkpoint", CFrame.new(450,1,-18), "Checkpoint", Vector3.new(6,2,6), false, false},
        {"Mine.Room1.Trigger", CFrame.new(450,3,-18), "EncounterTrigger", Vector3.new(54,6,5), true, false},
        {"Mine.Room1.EnemySpawn.01", CFrame.new(430,2,-54), "EnemySpawn", Vector3.new(3,2,3), false, false},
        {"Mine.Room1.EnemySpawn.02", CFrame.new(470,2,-54), "EnemySpawn", Vector3.new(3,2,3), false, false},
        {"Mine.Room1.EnemySpawn.03", CFrame.new(450,2,-68), "EnemySpawn", Vector3.new(3,2,3), false, false},
        {"Mine.Room1.ExitBarrier", CFrame.new(450,5,-86), "ExitBarrier", Vector3.new(20,10,1.5), false, true},
        {"Mine.Room2.Checkpoint", CFrame.new(450,1,-122), "Checkpoint", Vector3.new(6,2,6), false, false},
        {"Mine.Room2.Trigger", CFrame.new(450,3,-122), "EncounterTrigger", Vector3.new(60,6,5), true, false},
        {"Mine.Room2.EnemySpawn.01", CFrame.new(426,2,-160), "EnemySpawn", Vector3.new(3,2,3), false, false},
        {"Mine.Room2.EnemySpawn.02", CFrame.new(450,2,-176), "EnemySpawn", Vector3.new(3,2,3), false, false},
        {"Mine.Room2.EnemySpawn.03", CFrame.new(474,2,-160), "EnemySpawn", Vector3.new(3,2,3), false, false},
        {"Mine.Room2.EnemySpawn.04", CFrame.new(450,2,-146), "EnemySpawn", Vector3.new(3,2,3), false, false},
        {"Mine.Room2.ExitBarrier", CFrame.new(450,5,-198), "ExitBarrier", Vector3.new(20,10,1.5), false, true},
        {"Mine.Room3.Checkpoint", CFrame.new(450,1,-266), "Checkpoint", Vector3.new(6,2,6), false, false},
        {"Mine.Room3.Trigger", CFrame.new(450,3,-266), "EncounterTrigger", Vector3.new(62,6,5), true, false},
        {"Mine.Room3.ForemanSpawn", CFrame.new(450,2,-302), "BossSpawn", Vector3.new(4,2,4), false, false},
        {"Mine.CompletionPosition", CFrame.new(450,2,-330), "CompletionPosition", Vector3.new(6,2,6), false, false},
        {"Mine.ReturnToBase", CFrame.new(450,2,-338), "ReturnPresentation", Vector3.new(6,2,6), false, false},
    }
    for _, entry in ipairs(entries) do
        local anchor = Factory.create(parent, "AbandonedMine", entry[1] :: string, entry[2] :: CFrame, entry[4] :: Vector3, entry[3] :: string)
        anchor.CanTouch = entry[5] == true
        anchor.CanCollide = entry[6] == true
    end
end

return table.freeze(MineSyntheticEnvironment)
