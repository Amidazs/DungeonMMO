--!strict
local EnvironmentAnchorDefinitions = {}
EnvironmentAnchorDefinitions.TAG = "DungeonMMOEnvironmentAnchor"
EnvironmentAnchorDefinitions.ENVIRONMENT_ATTRIBUTE = "EnvironmentId"
EnvironmentAnchorDefinitions.ANCHOR_ATTRIBUTE = "AnchorId"
EnvironmentAnchorDefinitions.ROLE_ATTRIBUTE = "AnchorRole"
EnvironmentAnchorDefinitions.VERSION_ATTRIBUTE = "AnchorVersion"

EnvironmentAnchorDefinitions.BASE = table.freeze({
    EnvironmentId = "Base",
    Required = table.freeze({
        "Base.PlayerSpawn", "Base.ArrivalFromTemple", "Base.TemplePortal", "Base.DungeonBoard",
        "Base.Trainer.Fighter", "Base.Trainer.Mage", "Base.Trainer.Ranger",
        "Base.Service.Equipment", "Base.Service.Progression", "Base.Service.BankPlaceholder",
        "Base.Service.TravelPlaceholder", "Base.Profession.BlacksmithingPlaceholder",
        "Base.Profession.AlchemyPlaceholder", "Base.TrainingArea",
    }),
    Optional = table.freeze({}),
    Groups = table.freeze({}),
})

EnvironmentAnchorDefinitions.TEMPLE = table.freeze({
    EnvironmentId = "Temple",
    Required = table.freeze({
        "Temple.EntrySpawn", "Temple.Room1.Checkpoint", "Temple.Room1.Trigger",
        "Temple.Room2.Checkpoint", "Temple.Room2.Trigger", "Temple.Room3.Checkpoint",
        "Temple.Room3.Trigger", "Temple.Room3.CaptainSpawn", "Temple.CompletionPosition",
        "Temple.ReturnToBase",
    }),
    Optional = table.freeze({"Temple.Room1.ExitBarrier", "Temple.Room2.ExitBarrier"}),
    Groups = table.freeze({
        table.freeze({Name = "Room1EnemySpawns", Prefix = "Temple.Room1.EnemySpawn.", MinCount = 2}),
        table.freeze({Name = "Room2EnemySpawns", Prefix = "Temple.Room2.EnemySpawn.", MinCount = 3}),
    }),
})

EnvironmentAnchorDefinitions.ABANDONED_MINE = table.freeze({
    EnvironmentId = "AbandonedMine",
    Required = table.freeze({
        "Mine.EntrySpawn", "Mine.Room1.Checkpoint", "Mine.Room1.Trigger",
        "Mine.Room2.Checkpoint", "Mine.Room2.Trigger", "Mine.Room3.Checkpoint",
        "Mine.Room3.Trigger", "Mine.Room3.ForemanSpawn", "Mine.CompletionPosition",
        "Mine.ReturnToBase",
    }),
    Optional = table.freeze({"Mine.Room1.ExitBarrier", "Mine.Room2.ExitBarrier"}),
    Groups = table.freeze({
        table.freeze({Name = "MineRoom1EnemySpawns", Prefix = "Mine.Room1.EnemySpawn.", MinCount = 3}),
        table.freeze({Name = "MineRoom2EnemySpawns", Prefix = "Mine.Room2.EnemySpawn.", MinCount = 4}),
    }),
})

return table.freeze(EnvironmentAnchorDefinitions)
