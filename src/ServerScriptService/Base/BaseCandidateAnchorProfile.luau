--!strict
-- Current LobbyScene candidate calibration only.
-- Gameplay must never depend on these landmark names or offsets directly.
local BaseCandidateAnchorProfile = {}

BaseCandidateAnchorProfile.EnvironmentId = "Base"

BaseCandidateAnchorProfile.Entries = table.freeze({
    table.freeze({
        AnchorId = "Base.PlayerSpawn",
        Role = "Spawn",
        Selectors = table.freeze({
            table.freeze({
                Name = "HumanBarracks_01_AccessPath",
                Offset = CFrame.new(8, 2.5, -2),
            }),
            table.freeze({
                Name = "Anchor_FastTravel_Human_Gate",
                Offset = CFrame.new(0, 2.5, -8),
            }),
        }),
    }),
    table.freeze({
        AnchorId = "Base.ArrivalFromTemple",
        Role = "Arrival",
        Selectors = table.freeze({
            table.freeze({
                Name = "Central market circular cobbled plaza",
                Offset = CFrame.new(20, 2.5, -12),
            }),
            table.freeze({
                Name = "Anchor_FastTravel_Central_Tree_Market",
                Offset = CFrame.new(0, 2.5, 0),
            }),
        }),
    }),
    table.freeze({
        AnchorId = "Base.TemplePortal",
        Role = "DungeonPortal",
        Size = Vector3.new(8, 10, 4),
        Selectors = table.freeze({
            table.freeze({
                Name = "Portal_02",
                UseBounds = true,
                HeightFraction = 0.55,
                Offset = CFrame.new(),
            }),
            table.freeze({
                Name = "Portal_01",
                UseBounds = true,
                HeightFraction = 0.55,
                Offset = CFrame.new(),
            }),
            table.freeze({
                Name = "Portal_03",
                UseBounds = true,
                HeightFraction = 0.55,
                Offset = CFrame.new(),
            }),
        }),
    }),
    table.freeze({
        AnchorId = "Base.DungeonBoard",
        Role = "DungeonBoard",
        Size = Vector3.new(5, 6, 2),
        Selectors = table.freeze({
            table.freeze({
                Name = "Portal_02",
                Offset = CFrame.new(-10, -31, 8),
            }),
            table.freeze({
                Name = "Central market circular cobbled plaza",
                Offset = CFrame.new(-20, 3, -18),
            }),
        }),
    }),
    table.freeze({
        AnchorId = "Base.Trainer.Fighter",
        Role = "Trainer",
        Selectors = table.freeze({
            table.freeze({
                Name = "HumanBarracks_01_AccessPath",
                Offset = CFrame.new(-7, 3.5, 1),
            }),
            table.freeze({
                Name = "HumanBarracks_01",
                Offset = CFrame.new(0, -7, 12),
            }),
        }),
    }),
    table.freeze({
        AnchorId = "Base.Trainer.Mage",
        Role = "Trainer",
        Selectors = table.freeze({
            table.freeze({
                Name = "Central market circular cobbled plaza",
                Offset = CFrame.new(12, 3.5, 10),
            }),
            table.freeze({
                Name = "Market_SocialFurniture",
                Offset = CFrame.new(8, -1.5, 3),
            }),
        }),
    }),
    table.freeze({
        AnchorId = "Base.Trainer.Ranger",
        Role = "Trainer",
        Selectors = table.freeze({
            table.freeze({
                Name = "Central market circular cobbled plaza",
                Offset = CFrame.new(23, 3.5, 2),
            }),
            table.freeze({
                Name = "Anchor_FastTravel_Central_Tree_Market",
                Offset = CFrame.new(8, 2.5, 3),
            }),
        }),
    }),
    table.freeze({
        AnchorId = "Base.Service.Equipment",
        Role = "Service",
        Selectors = table.freeze({
            table.freeze({
                Name = "Blacksmith_Forge_AccessPath",
                Offset = CFrame.new(1, 3.5, 1),
            }),
            table.freeze({
                Name = "Blacksmith_Forge",
                Offset = CFrame.new(0, -10, 14),
            }),
        }),
    }),
    table.freeze({
        AnchorId = "Base.Service.Progression",
        Role = "Service",
        Selectors = table.freeze({
            table.freeze({
                Name = "Market_SocialFurniture",
                Offset = CFrame.new(-6, -1.5, 4),
            }),
            table.freeze({
                Name = "Central market circular cobbled plaza",
                Offset = CFrame.new(-10, 3.5, 8),
            }),
        }),
    }),
    table.freeze({
        AnchorId = "Base.Service.BankPlaceholder",
        Role = "Placeholder",
        Selectors = table.freeze({
            table.freeze({
                Name = "Central market circular cobbled plaza",
                Offset = CFrame.new(-20, 3.5, 4),
            }),
        }),
    }),
    table.freeze({
        AnchorId = "Base.Service.TravelPlaceholder",
        Role = "Placeholder",
        Selectors = table.freeze({
            table.freeze({
                Name = "Anchor_FastTravel_Central_Tree_Market",
                Offset = CFrame.new(0, 2.5, 0),
            }),
            table.freeze({
                Name = "Central market circular cobbled plaza",
                Offset = CFrame.new(20, 3.5, -12),
            }),
        }),
    }),
    table.freeze({
        AnchorId = "Base.Profession.BlacksmithingPlaceholder",
        Role = "Placeholder",
        Selectors = table.freeze({
            table.freeze({
                Name = "Blacksmith_Forge_AccessPath",
                Offset = CFrame.new(-5, 3.5, -2),
            }),
            table.freeze({
                Name = "Blacksmith_Forge",
                Offset = CFrame.new(-6, -10, 12),
            }),
        }),
    }),
    table.freeze({
        AnchorId = "Base.Profession.AlchemyPlaceholder",
        Role = "Placeholder",
        Selectors = table.freeze({
            table.freeze({
                Name = "Central market circular cobbled plaza",
                Offset = CFrame.new(-6, 3.5, -12),
            }),
        }),
    }),
    table.freeze({
        AnchorId = "Base.TrainingArea",
        Role = "TrainingArea",
        Size = Vector3.new(12, 3, 12),
        Selectors = table.freeze({
            table.freeze({
                Name = "HumanBarracks_01_AccessPath",
                Offset = CFrame.new(12, 2, -10),
            }),
            table.freeze({
                Name = "HumanBarracks_01",
                Offset = CFrame.new(12, -8, 14),
            }),
        }),
    }),
})

return table.freeze(BaseCandidateAnchorProfile)
