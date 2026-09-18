--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")
local Dungeon = ServerScriptService:WaitForChild("Dungeon")

local Difficulties = require(
    Shared:WaitForChild("DungeonDifficultyDefinitions")
)
local Bindings = require(
    Dungeon:WaitForChild("DungeonEncounterBindings")
)
local Layouts = require(
    Dungeon:WaitForChild("DungeonRoomLayoutDefinitions")
)

local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error("[Dungeon Encounter Bindings Tests] " .. message, 2)
    end
end

local function fake_environment(anchor_ids: {string}): any
    local anchors = {}
    for _, anchor_id in ipairs(anchor_ids) do
        local part = Instance.new("Part")
        part.Name = anchor_id
        anchors[anchor_id] = part
    end

    local environment: any = {}
    function environment:get(anchor_id: string): BasePart?
        return anchors[anchor_id]
    end
    function environment:destroy()
        for _, anchor in pairs(anchors) do
            anchor:Destroy()
        end
    end
    return environment
end

local temple_env = fake_environment({
    "Temple.EntrySpawn",
    "Temple.Room1.Trigger",
    "Temple.Room1.Checkpoint",
    "Temple.Room2.Trigger",
    "Temple.Room2.Checkpoint",
    "Temple.Room3.Trigger",
    "Temple.Room3.Checkpoint",
    "Temple.Room3.CaptainSpawn",
})
local mine_env = fake_environment({
    "Mine.EntrySpawn",
    "Mine.Room1.Trigger",
    "Mine.Room1.Checkpoint",
    "Mine.Room2.Trigger",
    "Mine.Room2.Checkpoint",
    "Mine.Room3.Trigger",
    "Mine.Room3.Checkpoint",
    "Mine.Room3.ForemanSpawn",
})

for _, entry in ipairs({
    {"TestDungeon", temple_env},
    {"AbandonedMine", mine_env},
}) do
    local dungeon_id = entry[1] :: string
    local environment = entry[2]
    local depth1 = assert(
        Difficulties.get(dungeon_id, "Depth1")
    )
    local result = Bindings.resolve(
        dungeon_id,
        depth1.LayoutId,
        depth1.EncounterSequence,
        environment
    )

    check(result.ok == true, dungeon_id .. " Depth1 must bind.")
    check(#result.ordered == 3, "Depth1 must resolve three slots.")
    check(
        result.by_slot.Room1.PlanEncounterId == "CombatRoom1"
            and result.by_slot.Room2.PlanEncounterId
                == "CombatRoom2"
            and result.by_slot.Room3.PlanEncounterId
                == "Depth1Boss",
        "Depth1 logical slot mapping must remain unchanged."
    )
    check(
        result.by_slot.Room1.RuntimeEncounterId
            == "CombatRoom1"
            and result.by_slot.Room2.RuntimeEncounterId
                == "CombatRoom2"
            and result.by_slot.Room3.RuntimeEncounterId
                == "MarauderCaptain",
        "Depth1 compatibility runtime IDs must come from descriptors."
    )
    check(
        result.by_slot.Room3.BossSpawnAnchor ~= nil,
        "Depth1 boss slot must expose a physical boss spawn anchor."
    )
end

check(
    Layouts.is_registered("TestDungeon", "Depth2") == false,
    "Depth2 physical layout must remain unregistered."
)
local depth2 = assert(
    Difficulties.get("TestDungeon", "Depth2")
)
local unregistered = Bindings.resolve(
    "TestDungeon",
    depth2.LayoutId,
    depth2.EncounterSequence,
    temple_env
)
check(
    unregistered.reason == "DungeonLayoutNotRegistered",
    "Unimplemented higher-depth layout must fail closed."
)

local synthetic_anchors = {"Synthetic.Entrance"}
local synthetic_slots = {}
for index = 1, 6 do
    local slot_id = "Room" .. tostring(index)
    local trigger = "Synthetic." .. slot_id .. ".Trigger"
    local checkpoint = "Synthetic." .. slot_id .. ".Checkpoint"
    local boss_spawn = "Synthetic." .. slot_id .. ".BossSpawn"
    table.insert(synthetic_anchors, trigger)
    table.insert(synthetic_anchors, checkpoint)
    table.insert(synthetic_anchors, boss_spawn)
    synthetic_slots[slot_id] = {
        TriggerAnchor = trigger,
        CheckpointAnchor = checkpoint,
        EnvironmentRoomId = slot_id,
        SupportsCombat = true,
        SupportsBoss = true,
        ExitBarrierRoomId = if index < 6 then slot_id else nil,
        BossSpawnAnchor = boss_spawn,
    }
end
synthetic_slots.EventArena = {
    TriggerAnchor = "Synthetic.EventArena.Trigger",
    CheckpointAnchor = "Synthetic.EventArena.Checkpoint",
    EnvironmentRoomId = "EventArena",
    SupportsCombat = true,
    SupportsBoss = true,
    ExitBarrierRoomId = "EventArena",
    BossSpawnAnchor = "Synthetic.EventArena.BossSpawn",
}
table.insert(synthetic_anchors, "Synthetic.EventArena.Trigger")
table.insert(synthetic_anchors, "Synthetic.EventArena.Checkpoint")
table.insert(synthetic_anchors, "Synthetic.EventArena.BossSpawn")

local synthetic_env = fake_environment(synthetic_anchors)
local synthetic_layout = {
    Id = "SyntheticDepth4",
    EntranceAnchor = "Synthetic.Entrance",
    Slots = synthetic_slots,
}

local depth4 = assert(
    Difficulties.get("TestDungeon", "Depth4")
)
local six_slot = Bindings.resolve_layout(
    synthetic_layout,
    depth4.EncounterSequence,
    synthetic_env
)
check(six_slot.ok == true, "Synthetic six-slot Depth4 must bind.")
check(#six_slot.ordered == 6, "Depth4 must preserve six slots.")
check(
    six_slot.by_slot.Room2.Kind == "MiniBoss"
        and six_slot.by_slot.Room4.Kind == "MiniBoss"
        and six_slot.by_slot.Room6.Kind == "FinalBoss",
    "Depth4 miniboss/final-boss slot kinds must survive binding."
)
check(
    six_slot.by_slot.Room6.RuntimeEncounterId
        == "Depth4FinalBoss",
    "Higher-depth runtime IDs must default to stable encounter IDs."
)

local event_plan = {}
for _, encounter in ipairs(depth4.EncounterSequence) do
    table.insert(event_plan, encounter)
    if encounter.Id == "Depth4Combat1" then
        table.insert(event_plan, {
            Id = "FestivalChampion",
            RoomSlotId = "EventArena",
            Kind = "EventBoss",
            ExecutorId = "Boss",
            BossId = "FestivalChampion",
        })
    end
end

local with_event = Bindings.resolve_layout(
    synthetic_layout,
    event_plan,
    synthetic_env
)
check(
    with_event.ok == true
        and with_event.by_slot.EventArena.Kind == "EventBoss",
    "Explicit EventArena slot must bind inserted Event Boss."
)
check(
    with_event.by_slot.EventArena.CheckpointSequence == 2,
    "Inserted Event Boss must receive materialized checkpoint order."
)

local missing_slot_plan = {
    {
        Id = "SecretGuardian",
        RoomSlotId = "SecretArena",
        Kind = "SecretBoss",
        ExecutorId = "Boss",
        BossId = "SecretGuardian",
    },
}
local missing_slot = Bindings.resolve_layout(
    synthetic_layout,
    missing_slot_plan,
    synthetic_env
)
check(
    missing_slot.reason == "EncounterBindingMissing",
    "Unbound Secret Boss arena must fail closed."
)

local combat_in_boss_only = Bindings.resolve_layout(
    {
        Id = "BossOnly",
        EntranceAnchor = "Synthetic.Entrance",
        Slots = {
            Room1 = {
                TriggerAnchor = "Synthetic.Room1.Trigger",
                CheckpointAnchor = "Synthetic.Room1.Checkpoint",
                EnvironmentRoomId = "Room1",
                SupportsCombat = false,
                SupportsBoss = true,
                BossSpawnAnchor = "Synthetic.Room1.BossSpawn",
            },
        },
    },
    {{
        Id = "Combat",
        RoomSlotId = "Room1",
        Kind = "Combat",
        ExecutorId = "CombatPack",
        PackId = "StandardRoom1",
    }},
    synthetic_env
)
check(
    combat_in_boss_only.reason == "CombatSlotNotSupported",
    "Combat encounter must reject a boss-only slot."
)

temple_env:destroy()
mine_env:destroy()
synthetic_env:destroy()

print(string.format(
    "[Dungeon Encounter Bindings Tests] PASS: %d assertions.",
    assertion_count
))
