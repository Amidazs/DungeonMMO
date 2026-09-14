--!strict
-- Current Temple.rbxl calibration only.
-- These CFrames are replaceable candidate data, not gameplay geometry contracts.
local TempleCandidateAnchorProfile = {}

TempleCandidateAnchorProfile.EnvironmentId = "Temple"
TempleCandidateAnchorProfile.RequiredLandmark =
    "DungeonMMO_ThreeRoomDungeon_V2"

TempleCandidateAnchorProfile.Entries = table.freeze({
    table.freeze({
        AnchorId = "Temple.EntrySpawn",
        Role = "Spawn",
        CFrame = CFrame.new(-54.7148, 27.6, 369.6025),
        Size = Vector3.new(6, 2, 6),
    }),
    table.freeze({
        AnchorId = "Temple.Room1.Checkpoint",
        Role = "Checkpoint",
        CFrame = CFrame.new(-51.7148, 27.8, 343.3319),
        Size = Vector3.new(6, 2, 6),
    }),
    table.freeze({
        AnchorId = "Temple.Room1.Trigger",
        Role = "EncounterTrigger",
        CFrame = CFrame.new(-51.7148, 29.5, 338.0),
        Size = Vector3.new(54, 7, 5),
        CanTouch = true,
    }),
    table.freeze({
        AnchorId = "Temple.Room1.EnemySpawn.01",
        Role = "EnemySpawn",
        CFrame = CFrame.new(-68.0772, 28.2, 299.6989),
        Size = Vector3.new(3, 2, 3),
    }),
    table.freeze({
        AnchorId = "Temple.Room1.EnemySpawn.02",
        Role = "EnemySpawn",
        CFrame = CFrame.new(-35.3524, 28.2, 299.6989),
        Size = Vector3.new(3, 2, 3),
    }),
    table.freeze({
        AnchorId = "Temple.Room1.ExitBarrier",
        Role = "ExitBarrier",
        CFrame = CFrame.new(-54.44, 32.0, 250.42),
        Size = Vector3.new(34, 13, 3),
        CanCollide = true,
    }),
    table.freeze({
        AnchorId = "Temple.Room2.Checkpoint",
        Role = "Checkpoint",
        CFrame = CFrame.new(-51.7148, 27.8, 212.4329),
        Size = Vector3.new(6, 2, 6),
    }),
    table.freeze({
        AnchorId = "Temple.Room2.Trigger",
        Role = "EncounterTrigger",
        CFrame = CFrame.new(-51.7148, 29.5, 205.0),
        Size = Vector3.new(58, 7, 5),
        CanTouch = true,
    }),
    table.freeze({
        AnchorId = "Temple.Room2.EnemySpawn.01",
        Role = "EnemySpawn",
        CFrame = CFrame.new(-73.5313, 28.2, 152.4375),
        Size = Vector3.new(3, 2, 3),
    }),
    table.freeze({
        AnchorId = "Temple.Room2.EnemySpawn.02",
        Role = "EnemySpawn",
        CFrame = CFrame.new(-51.7148, 28.2, 152.4375),
        Size = Vector3.new(3, 2, 3),
    }),
    table.freeze({
        AnchorId = "Temple.Room2.EnemySpawn.03",
        Role = "EnemySpawn",
        CFrame = CFrame.new(-35.3524, 28.2, 152.4375),
        Size = Vector3.new(3, 2, 3),
    }),
    table.freeze({
        AnchorId = "Temple.Room2.ExitBarrier",
        Role = "ExitBarrier",
        CFrame = CFrame.new(-54.91, 32.0, 86.80),
        Size = Vector3.new(36, 13, 3),
        CanCollide = true,
    }),
    table.freeze({
        AnchorId = "Temple.Room3.Checkpoint",
        Role = "Checkpoint",
        CFrame = CFrame.new(-51.7148, 27.8, 48.8091),
        Size = Vector3.new(6, 2, 6),
    }),
    table.freeze({
        AnchorId = "Temple.Room3.Trigger",
        Role = "EncounterTrigger",
        CFrame = CFrame.new(-51.7148, 29.5, 43.0),
        Size = Vector3.new(58, 7, 5),
        CanTouch = true,
    }),
    table.freeze({
        AnchorId = "Temple.Room3.CaptainSpawn",
        Role = "BossSpawn",
        CFrame = CFrame.new(-51.7148, 28.2, -27.5487),
        Size = Vector3.new(4, 2, 4),
    }),
    table.freeze({
        AnchorId = "Temple.CompletionPosition",
        Role = "CompletionPosition",
        CFrame = CFrame.new(-52.2139, 28.8, -49.3652),
        Size = Vector3.new(6, 2, 6),
    }),
    table.freeze({
        AnchorId = "Temple.ReturnToBase",
        Role = "ReturnPresentation",
        CFrame = CFrame.new(-52.2139, 28.8, -55.0),
        Size = Vector3.new(6, 2, 6),
    }),
})

return table.freeze(TempleCandidateAnchorProfile)
