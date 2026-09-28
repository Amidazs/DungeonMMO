--!strict
-- Bridges server-owned dungeon checkpoint progression into Adventure quests.

local DungeonCheckpointQuestBridge = {}

local EVENT_TYPE = "CheckpointReached"

--[[
Builds the stable quest target for one dungeon checkpoint.

Args:
    dungeon_id (string): Stable released dungeon identifier.
    checkpoint_id (string): Stable server checkpoint identifier.

Returns:
    string: Dungeon-scoped target used by Adventure objectives.
]]
function DungeonCheckpointQuestBridge.target_id(
    dungeon_id: string,
    checkpoint_id: string
): string
    assert(
        type(dungeon_id) == "string" and dungeon_id ~= "",
        "Checkpoint quest target requires dungeon_id."
    )
    assert(
        type(checkpoint_id) == "string" and checkpoint_id ~= "",
        "Checkpoint quest target requires checkpoint_id."
    )

    return dungeon_id .. ":" .. checkpoint_id
end

--[[
Records one successfully committed checkpoint for active dungeon members.

Args:
    quest_service (any): Authoritative QuestService instance.
    dungeon_id (string): Stable released dungeon identifier.
    session_id (string): Stable dungeon session identifier.
    member_user_ids ({number}): Active loaded party members.
    checkpoint_id (string): Successfully activated server checkpoint.

Returns:
    any: Success with per-member results, or a stable failure reason.
]]
function DungeonCheckpointQuestBridge.record(
    quest_service: any,
    dungeon_id: string,
    session_id: string,
    member_user_ids: {number},
    checkpoint_id: string
): any
    if type(quest_service) ~= "table"
        or type(quest_service.record_event) ~= "function"
        or type(dungeon_id) ~= "string"
        or dungeon_id == ""
        or type(session_id) ~= "string"
        or session_id == ""
        or type(member_user_ids) ~= "table"
        or type(checkpoint_id) ~= "string"
        or checkpoint_id == ""
    then
        return {
            ok = false,
            reason = "CheckpointQuestContextInvalid",
        }
    end

    local target_id =
        DungeonCheckpointQuestBridge.target_id(
            dungeon_id,
            checkpoint_id
        )
    local member_results = {}
    local seen = {}

    for _, user_id in ipairs(member_user_ids) do
        if type(user_id) ~= "number"
            or user_id % 1 ~= 0
            or user_id <= 0
        then
            return {
                ok = false,
                reason = "CheckpointQuestMemberInvalid",
                member_results = member_results,
            }
        end

        if not seen[user_id] then
            seen[user_id] = true

            local result = quest_service:record_event(
                user_id,
                {
                    EventId = session_id
                        .. ":CheckpointReached:"
                        .. checkpoint_id
                        .. ":"
                        .. tostring(user_id),
                    Type = EVENT_TYPE,
                    TargetId = target_id,
                    Amount = 1,
                }
            )

            member_results[tostring(user_id)] = result

            if not result or result.ok ~= true then
                return {
                    ok = false,
                    reason = if result and result.reason
                        then result.reason
                        else "CheckpointQuestProgressFailed",
                    member_results = member_results,
                }
            end
        end
    end

    return {
        ok = true,
        target_id = target_id,
        member_results = member_results,
    }
end

return table.freeze(DungeonCheckpointQuestBridge)
