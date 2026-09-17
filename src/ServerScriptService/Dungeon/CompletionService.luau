--!strict
local CompletionService = {}
CompletionService.__index = CompletionService

local function result(ok: boolean, reason: string?, extra: any?): any
    local out = extra or {}
    out.ok = ok
    out.reason = reason
    return out
end

function CompletionService.new(
    session_service: any,
    reward_service: any,
    profile_service: any,
    reward_definition: any,
    skill_progression_service: any?,
    quest_service: any?,
    guild_service: any?
): any
    assert(session_service and reward_service and profile_service, "CompletionService dependencies are required")
    local self = setmetatable({}, CompletionService)
    self._sessions = session_service
    self._rewards = reward_service
    self._profiles = profile_service
    self._reward_definition = reward_definition
    self._skills = skill_progression_service
    self._quests = quest_service
    self._guilds = guild_service
    return self
end

function CompletionService:commit(session_id: string): any
    local session = self._sessions:get(session_id)
    if not session then return result(false, "SessionNotFound") end
    if session.State ~= "Complete" then return result(false, "SessionNotComplete") end
    if session.CompletionRewardsCommitted == true then
        return result(true, nil, {
            already_applied = true,
            member_results = session.CompletionRewardSummary or {},
        })
    end

    local member_results: {[string]: any} = {}
    for _, user_id in ipairs(session.CompletionRecipients or {}) do
        local granted = self._rewards:grant_completion(session_id, 1, user_id, self._reward_definition, nil, session.DungeonId)
        if not granted or granted.ok ~= true then
            return result(false, if granted then granted.reason else "RewardGrantFailed", {member_results = member_results})
        end
        if self._quests
            and type(session.DungeonId) == "string"
            and session.DungeonId ~= ""
        then
            local quest_result = self._quests:record_event(
                user_id,
                {
                    EventId = session_id .. ":DungeonClear",
                    Type = "DungeonClear",
                    TargetId = session.DungeonId,
                    Amount = 1,
                }
            )

            if not quest_result or quest_result.ok ~= true then
                return result(
                    false,
                    if quest_result and quest_result.reason
                        then quest_result.reason
                        else "QuestProgressFailed",
                    {member_results = member_results}
                )
            end

            granted.quest_progress = quest_result
        end

        member_results[tostring(user_id)] = granted
    end

    -- Save barrier: no shared progression or return portal opens until every
    -- affected player profile has persisted its completion rewards.
    for _, user_id in ipairs(session.CompletionRecipients or {}) do
        local saved, save_error = self._profiles:save(user_id, "DungeonCompletion")
        if not saved then
            return result(false, "ProfileSaveFailed", {
                save_user_id = user_id,
                save_error = save_error,
                member_results = member_results,
            })
        end
    end

    local guild_progress: any = nil
    if self._guilds then
        guild_progress = self._guilds:award_dungeon_clear(
            session.CompletionRecipients or {},
            session_id .. ":GuildClear"
        )
        if not guild_progress or guild_progress.ok ~= true then
            return result(false, "GuildProgressionFailed", {
                member_results = member_results,
                guild_progress = guild_progress,
            })
        end
    end

    local committed = self._sessions:mark_completion_rewards_committed(session_id, member_results)
    if not committed or committed.ok ~= true then
        return result(false, if committed then committed.reason else "SessionCommitFailed", {member_results = member_results})
    end
    return result(true, nil, {
        already_applied = false,
        member_results = member_results,
        guild_progress = guild_progress,
    })
end

return table.freeze(CompletionService)
