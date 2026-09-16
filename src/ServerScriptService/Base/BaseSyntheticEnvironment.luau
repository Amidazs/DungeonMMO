--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Factory = require(
    ServerScriptService
        :WaitForChild("Core")
        :WaitForChild("Environment")
        :WaitForChild("EnvironmentAnchorFactory")
)

local BaseSyntheticEnvironment = {}

local function floor(parent: Instance)
    local existing = parent:FindFirstChild("DungeonMMOSyntheticBase")
    if existing then
        existing:Destroy()
    end

    local root = Instance.new("Folder")
    root.Name = "DungeonMMOSyntheticBase"
    root.Parent = parent

    local part = Instance.new("Part")
    part.Name = "SyntheticBaseFloor"
    part.Size = Vector3.new(96, 1, 96)
    part.CFrame = CFrame.new(0, -0.5, 0)
    part.Anchored = true
    part.Material = Enum.Material.Slate
    part.Parent = root
end

function BaseSyntheticEnvironment.create(parent: Instance)
    floor(parent)

    local entries = {
        {"Base.PlayerSpawn", CFrame.new(0, 1, 20), "Spawn", Vector3.new(6, 2, 6)},
        {"Base.ArrivalFromTemple", CFrame.new(0, 1, 12), "Arrival", Vector3.new(6, 2, 6)},
        {"Base.TemplePortal", CFrame.new(0, 5, -24), "DungeonPortal", Vector3.new(8, 10, 4)},
        {"Base.DungeonBoard", CFrame.new(12, 3, -18), "DungeonBoard", Vector3.new(5, 6, 2)},
        {"Base.Trainer.Fighter", CFrame.new(20, 3.5, 10), "Trainer", Vector3.new(5, 7, 4)},
        {"Base.Trainer.Mage", CFrame.new(20, 3.5, 0), "Trainer", Vector3.new(5, 7, 4)},
        {"Base.Trainer.Ranger", CFrame.new(20, 3.5, -10), "Trainer", Vector3.new(5, 7, 4)},
        {"Base.Service.Equipment", CFrame.new(-20, 3.5, 8), "Service", Vector3.new(5, 7, 4)},
        {"Base.Service.Progression", CFrame.new(-20, 3.5, -2), "Service", Vector3.new(5, 7, 4)},
        {"Base.Service.Bank", CFrame.new(-20, 3.5, -12), "Service", Vector3.new(5, 7, 4)},
        {"Base.Service.Travel", CFrame.new(8, 2.5, 8), "Service", Vector3.new(4, 5, 4)},
        {"Base.Travel.Market", CFrame.new(-8, 1, -4), "TravelDestination", Vector3.new(5, 2, 5)},
        {"Base.Travel.Dwarves", CFrame.new(-36, 1, 28), "TravelDestination", Vector3.new(5, 2, 5)},
        {"Base.Travel.Portals", CFrame.new(0, 1, -16), "TravelDestination", Vector3.new(5, 2, 5)},
        {"Base.Travel.Orcs", CFrame.new(36, 1, 28), "TravelDestination", Vector3.new(5, 2, 5)},
        {"Base.Profession.BlacksmithingPlaceholder", CFrame.new(-30, 3.5, 18), "Placeholder", Vector3.new(5, 7, 4)},
        {"Base.Profession.AlchemyPlaceholder", CFrame.new(-30, 3.5, -20), "Placeholder", Vector3.new(5, 7, 4)},
        {"Base.TrainingArea", CFrame.new(32, 1.5, 28), "TrainingArea", Vector3.new(14, 3, 14)},
    }

    for _, entry in ipairs(entries) do
        Factory.create(
            parent,
            "Base",
            entry[1] :: string,
            entry[2] :: CFrame,
            entry[4] :: Vector3,
            entry[3] :: string
        )
    end
end

return table.freeze(BaseSyntheticEnvironment)
