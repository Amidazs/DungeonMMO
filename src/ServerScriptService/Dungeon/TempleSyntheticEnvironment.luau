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

local function create_hidden_tutorial(root: Instance)
    local room = Instance.new("Folder")
    room.Name = "TutorialHiddenAlcove"
    room:SetAttribute("DungeonMMOQuestHiddenRoom", true)
    room.Parent = root

    local floor = make_part(
        room,
        "Floor",
        Vector3.new(48, 1, 32),
        CFrame.new(185, 0, -145)
    )
    floor.Color = Color3.fromRGB(67, 65, 82)

    local passage = make_part(
        room,
        "HiddenPassageFloor",
        Vector3.new(12, 1, 12),
        CFrame.new(211, 0, -145)
    )
    passage.Color = Color3.fromRGB(78, 79, 84)
    passage:SetAttribute("DungeonMMOQuestHiddenPassage", true)

    local door = make_part(
        room,
        "HiddenDoor",
        Vector3.new(2, 16, 12),
        CFrame.new(214, 8, -145)
    )
    door:SetAttribute("DungeonMMOQuestHiddenDoor", true)

    local panel = make_part(
        room,
        "HiddenPanel",
        Vector3.new(2, 5, 5),
        CFrame.new(217, 3, -133)
    )
    panel.Color = Color3.fromRGB(150, 117, 224)
    panel:SetAttribute(
        "DungeonMMOQuestInteractionId",
        "TempleHiddenPanel"
    )

    local relic = make_part(
        room,
        "HiddenWardFragment",
        Vector3.new(2, 3, 2),
        CFrame.new(177, 2, -145)
    )
    relic.Color = Color3.fromRGB(150, 117, 224)
    relic.Material = Enum.Material.Neon
    relic.CanCollide = false
    relic:SetAttribute(
        "DungeonMMOQuestCollectibleId",
        "TempleHiddenWardFragment"
    )

    for _, wall in ipairs({
        {
            "WestWall",
            Vector3.new(2, 18, 32),
            CFrame.new(161, 9, -145),
        },
        {
            "NorthWall",
            Vector3.new(48, 18, 2),
            CFrame.new(185, 9, -129),
        },
        {
            "SouthWall",
            Vector3.new(48, 18, 2),
            CFrame.new(185, 9, -161),
        },
    }) do
        local part = make_part(
            room,
            wall[1] :: string,
            wall[2] :: Vector3,
            wall[3] :: CFrame
        )
        part.Color = Color3.fromRGB(67, 65, 82)
    end
end

local function create_resonance_puzzle(root: Instance)
    local puzzle = Instance.new("Folder")
    puzzle.Name = "ResonancePuzzle"
    puzzle:SetAttribute("DungeonMMOPuzzleId", "TempleResonanceLock")
    puzzle.Parent = root

    local shard = make_part(
        puzzle,
        "TempleResonanceShard",
        Vector3.new(2, 3, 2),
        CFrame.new(270, 2, -60)
    )
    shard.Material = Enum.Material.Neon
    shard.Color = Color3.fromRGB(97, 181, 224)
    shard.CanCollide = false
    shard:SetAttribute(
        "DungeonMMOQuestCollectibleId",
        "TempleResonanceShard"
    )

    local runes = {
        {
            Name = "MoonRune",
            CFrame = CFrame.new(220, 2, -145),
        },
        {
            Name = "RootRune",
            CFrame = CFrame.new(250, 2, -170),
        },
        {
            Name = "FlameRune",
            CFrame = CFrame.new(280, 2, -145),
        },
    }

    for _, definition in ipairs(runes) do
        local rune = make_part(
            puzzle,
            definition.Name,
            Vector3.new(4, 4, 4),
            definition.CFrame
        )
        rune.Material = Enum.Material.Neon
        rune.Color = Color3.fromRGB(150, 117, 224)
        rune.CanCollide = false
        rune:SetAttribute(
            "DungeonMMOPuzzleId",
            "TempleResonanceLock"
        )
        rune:SetAttribute(
            "DungeonMMOPuzzleRuneId",
            definition.Name
        )
    end
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
    create_hidden_tutorial(root)
    create_resonance_puzzle(root)
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
