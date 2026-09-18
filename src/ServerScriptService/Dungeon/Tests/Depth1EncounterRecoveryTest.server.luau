--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")
local Dungeon = ServerScriptService:WaitForChild("Dungeon")

local module = Dungeon:FindFirstChild("Depth1EncounterRecovery")
if not module then
    error(
        "[Depth1 Encounter Recovery Tests] RED: "
            .. "Depth1EncounterRecovery is missing."
    )
end

local Difficulties = require(
    Shared:WaitForChild("DungeonDifficultyDefinitions")
)
local Bindings = require(
    Dungeon:WaitForChild("Depth1EncounterBindings")
)
local Recovery = require(module)

local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error("[Depth1 Encounter Recovery Tests] " .. message, 2)
    end
end

local depth1 = assert(Difficulties.get("TestDungeon", "Depth1"))
local bindings = Bindings.resolve(depth1.EncounterSequence)
assert(bindings.ok)

local room1 = assert(
    Recovery.snapshot_from_checkpoint(
        bindings,
        "EncounterStart:CombatRoom1"
    )
)
check(
    room1.EncounterStates.CombatRoom1 == "Pending",
    "Room1 restart must leave Room1 pending."
)
check(
    room1.NextEncounterId == "CombatRoom1",
    "Room1 restart must target Room1."
)

local legacy_room2 = assert(
    Recovery.snapshot_from_checkpoint(bindings, "Room2Start")
)
check(
    legacy_room2.EncounterStates.CombatRoom1 == "Cleared",
    "Legacy Room2 checkpoint must preserve Room1 clear."
)
check(
    legacy_room2.EncounterStates.CombatRoom2 == "Pending",
    "Legacy Room2 checkpoint must replay Room2."
)
check(
    legacy_room2.NextEncounterId == "CombatRoom2",
    "Legacy Room2 checkpoint must target Room2."
)

local boss = assert(
    Recovery.snapshot_from_checkpoint(
        bindings,
        "EncounterStart:Depth1Boss"
    )
)
check(
    boss.EncounterStates.CombatRoom1 == "Cleared"
        and boss.EncounterStates.CombatRoom2 == "Cleared",
    "Boss checkpoint must preserve both combat-room clears."
)
check(
    boss.EncounterStates.Depth1Boss == "Pending",
    "Interrupted boss must restart as pending."
)
check(
    boss.NextEncounterId == "Depth1Boss",
    "Boss checkpoint must target the logical boss encounter."
)

local legacy_boss = assert(
    Recovery.snapshot_from_checkpoint(bindings, "BossRoomStart")
)
check(
    legacy_boss.NextEncounterId == "Depth1Boss",
    "Legacy boss checkpoint must migrate to logical boss ID."
)

local entrance = assert(
    Recovery.snapshot_from_checkpoint(bindings, "Entrance")
)
check(
    entrance.NextEncounterId == "CombatRoom1",
    "Entrance must begin at the first encounter."
)

check(
    Recovery.snapshot_from_checkpoint(
        bindings,
        "NotARealCheckpoint"
    ) == nil,
    "Unknown checkpoint must fail closed."
)

print(string.format(
    "[Depth1 Encounter Recovery Tests] PASS: %d assertions.",
    assertion_count
))
