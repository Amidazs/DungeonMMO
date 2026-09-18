--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Dungeon = ServerScriptService:WaitForChild("Dungeon")

local module = Dungeon:FindFirstChild("DungeonEncounterPlan")
if not module then
    error(
        "[Dungeon Encounter Plan Tests] RED: "
            .. "DungeonEncounterPlan is missing."
    )
end

local Plan = require(module)
local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error("[Dungeon Encounter Plan Tests] " .. message, 2)
    end
end

local base = {
    {
        Id = "Combat1",
        RoomSlotId = "Room1",
        Kind = "Combat",
        PackId = "Pack1",
    },
    {
        Id = "Combat2",
        RoomSlotId = "Room2",
        Kind = "Combat",
        PackId = "Pack2",
    },
    {
        Id = "Boss1",
        RoomSlotId = "Room3",
        Kind = "Boss",
        BossId = "Boss1",
    },
}

local optional = {
    {
        Encounter = {
            Id = "EventBoss",
            RoomSlotId = "EventRoom",
            Kind = "EventBoss",
            BossId = "EventBoss",
        },
        InsertAfterId = "Combat1",
        CompletionRequired = true,
        Activation = {
            Type = "InstanceFlag",
            Key = "EventActive",
            Value = true,
        },
    },
    {
        Encounter = {
            Id = "SecretBoss",
            RoomSlotId = "SecretRoom",
            Kind = "SecretBoss",
            BossId = "SecretBoss",
        },
        InsertBeforeId = "Boss1",
        CompletionRequired = false,
        Activation = {
            Type = "RareState",
            Id = "HiddenCrypt",
        },
    },
}

local inactive = Plan.materialize(base, optional, {
    EventActive = false,
    RareStateId = nil,
})
check(inactive.ok == true, "Inactive optional plan must resolve.")
check(#inactive.encounters == 3, "Inactive plan must keep three base encounters.")
check(
    inactive.encounters[1].CompletionRequired == true,
    "Base encounters must default to completion-required."
)

local active = Plan.materialize(base, optional, {
    EventActive = true,
    RareStateId = "HiddenCrypt",
})
check(active.ok == true, "Active optional plan must resolve.")
check(#active.encounters == 5, "Both optional encounters must materialise.")
check(active.encounters[2].Id == "EventBoss", "Event boss insertion order mismatch.")
check(active.encounters[4].Id == "SecretBoss", "Secret boss insertion order mismatch.")
check(
    active.encounters[2].Kind == "EventBoss"
        and active.encounters[2].CompletionRequired == true,
    "Event boss must support required progression."
)
check(
    active.encounters[4].Kind == "SecretBoss"
        and active.encounters[4].CompletionRequired == false,
    "Secret boss must support optional progression."
)

active.encounters[1].Id = "Mutated"
local fresh = Plan.materialize(base, optional, {
    EventActive = true,
    RareStateId = "HiddenCrypt",
})
check(
    fresh.encounters[1].Id == "Combat1",
    "Materialised plans must be detached copies."
)

local bad_kind = Plan.materialize({
    {
        Id = "Bad",
        RoomSlotId = "Room1",
        Kind = "TreasureDragon",
    },
}, {}, {})
check(
    bad_kind.reason == "UnknownEncounterKind",
    "Unknown encounter kinds must fail closed."
)

local bad_anchor = Plan.materialize(base, {
    {
        Encounter = {
            Id = "LostSecret",
            RoomSlotId = "SecretRoom",
            Kind = "SecretBoss",
            BossId = "Secret",
        },
        InsertAfterId = "Missing",
        CompletionRequired = false,
    },
}, {})
check(
    bad_anchor.reason == "UnknownInsertionAnchor",
    "Unknown optional insertion anchors must fail closed."
)

local duplicate = Plan.materialize(base, {
    {
        Encounter = {
            Id = "Combat1",
            RoomSlotId = "SecretRoom",
            Kind = "SecretBoss",
            BossId = "Duplicate",
        },
        InsertAfterId = "Combat2",
        CompletionRequired = false,
    },
}, {})
check(
    duplicate.reason == "DuplicateEncounterId",
    "Duplicate encounter IDs must fail closed."
)

print(string.format(
    "[Dungeon Encounter Plan Tests] PASS: %d assertions.",
    assertion_count
))
