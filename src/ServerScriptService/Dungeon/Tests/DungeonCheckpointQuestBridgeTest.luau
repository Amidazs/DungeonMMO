--!strict
-- Server-owned checkpoint-to-Adventure event bridge regression.

local ServerScriptService = game:GetService("ServerScriptService")

local Dungeon = ServerScriptService.Dungeon
local Bridge = require(Dungeon.DungeonCheckpointQuestBridge)

local checks = 0
local events = {}
local fail_user_id: number? = nil

local FakeQuestService = {}

--[[
Records one fake trusted quest event for bridge inspection.

Args:
    user_id (number): Target party member.
    event (any): Server-authored checkpoint event.

Returns:
    any: Successful or injected failed quest result.
]]
function FakeQuestService:record_event(
    user_id: number,
    event: any
): any
    table.insert(events, {
        UserId = user_id,
        Event = event,
    })

    if user_id == fail_user_id then
        return {
            ok = false,
            reason = "InjectedQuestFailure",
        }
    end

    return {ok = true}
end

--[[
Counts one checkpoint-bridge assertion.

Args:
    condition (boolean): Expected bridge result.
    label (string): Diagnostic failure description.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(
        condition,
        "[Checkpoint Quest Bridge] " .. label
    )
end

--[[
Runs stable target, party dedupe and failure-path checks.

Args:
    None.

Returns:
    nil: Prints a stable pass marker after all checks succeed.
]]
local function main()
    local target = Bridge.target_id(
        "TestDungeon",
        "EncounterStart:CombatRoom2"
    )
    check(
        target
            == "TestDungeon:EncounterStart:CombatRoom2",
        "target ID is stable and dungeon-scoped"
    )

    local recorded = Bridge.record(
        FakeQuestService,
        "TestDungeon",
        "checkpoint-session-a",
        {8101, 8102, 8101},
        "EncounterStart:CombatRoom2"
    )
    check(recorded.ok == true, "valid party checkpoint records")
    check(
        recorded.target_id == target,
        "record result returns the stable target"
    )
    check(
        #events == 2,
        "duplicate party member IDs emit only one event each"
    )

    local first = events[1]
    local second = events[2]
    check(
        first.UserId == 8101
            and first.Event.Type == "CheckpointReached"
            and first.Event.TargetId == target
            and first.Event.Amount == 1
            and first.Event.EventId
                == "checkpoint-session-a:CheckpointReached:"
                    .. "EncounterStart:CombatRoom2:8101",
        "first party member receives exact trusted event"
    )
    check(
        second.UserId == 8102
            and second.Event.EventId
                == "checkpoint-session-a:CheckpointReached:"
                    .. "EncounterStart:CombatRoom2:8102",
        "second party member receives independent event ID"
    )

    local invalid_context = Bridge.record(
        nil,
        "TestDungeon",
        "checkpoint-session-a",
        {8101},
        "EncounterStart:CombatRoom2"
    )
    check(
        not invalid_context.ok
            and invalid_context.reason
                == "CheckpointQuestContextInvalid",
        "missing QuestService fails closed"
    )

    local invalid_member = Bridge.record(
        FakeQuestService,
        "TestDungeon",
        "checkpoint-session-b",
        {8101, 0},
        "EncounterStart:CombatRoom2"
    )
    check(
        not invalid_member.ok
            and invalid_member.reason
                == "CheckpointQuestMemberInvalid",
        "invalid party member fails closed"
    )

    fail_user_id = 8102
    local failed = Bridge.record(
        FakeQuestService,
        "AbandonedMine",
        "checkpoint-session-c",
        {8101, 8102},
        "EncounterStart:CombatRoom2"
    )
    fail_user_id = nil
    check(
        not failed.ok
            and failed.reason == "InjectedQuestFailure",
        "QuestService failure is surfaced to Dungeon runtime"
    )

    print(
        ("[Checkpoint Quest Bridge] PASS: %d assertions")
            :format(checks)
    )
end

main()
