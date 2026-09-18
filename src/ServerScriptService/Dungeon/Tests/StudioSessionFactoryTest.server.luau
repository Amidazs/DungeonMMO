--!strict
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Dungeon = ServerScriptService:WaitForChild("Dungeon")
local module = Dungeon:FindFirstChild("StudioSessionFactory")
if not module then
    error("[Studio Session Factory Tests] RED: StudioSessionFactory is missing.")
end
local StudioSessionFactory = require(module)

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then error("[Studio Session Factory Tests] " .. message, 2) end
end

if RunService:IsStudio() then
    local created_members = nil
    local created_difficulty = nil
    local resolved_difficulty = nil
    local fake_sessions: any = {}

    function fake_sessions:create(
        dungeon_id: string,
        member_ids: {number},
        return_place_id: number,
        reserved_code: string,
        difficulty_id: string?
    ): any
        created_members = table.clone(member_ids)
        created_difficulty = difficulty_id
        return {
            SessionId = "studio-session",
            DungeonId = dungeon_id,
            Difficulty = {
                Id = difficulty_id or "Depth1",
            },
            State = "Creating",
            Members = {
                [tostring(member_ids[1])] = {
                    UserId = member_ids[1],
                    Connected = false,
                    Mode = "Active",
                },
            },
            ReturnPlaceId = return_place_id,
            ReservedAccessCode = reserved_code,
        }
    end
    function fake_sessions:get_for_user(_user_id: number): any return nil end
    function fake_sessions:set_instance_state(
        _session_id: string,
        instance_state: any
    ): any
        resolved_difficulty = instance_state.DifficultyId
        return {
            ok = true,
            session = {
                SessionId = "studio-session",
                DungeonId = "TestDungeon",
                Difficulty = {
                    Id = created_difficulty or "Depth1",
                },
                State = "Creating",
                Members = {
                    ["777"] = {
                        UserId = 777,
                        Connected = false,
                        Mode = "Active",
                    },
                },
                ReturnPlaceId = 0,
                ReservedAccessCode = "StudioReservedServer",
                InstanceState = instance_state,
            },
        }
    end

    local fake_player: any = {UserId = 777}
    local created = StudioSessionFactory.create_for_players({fake_player}, fake_sessions)
    check(created.ok == true and created.session.SessionId == "studio-session", "Studio factory must create a generated DEV session.")
    check(created.teleport_data.SessionId == "studio-session" and created.teleport_data.DungeonId == "TestDungeon", "Studio routing data must mirror published routing IDs only.")
    check(
        created_members ~= nil
            and #created_members == 1
            and created_members[1] == 777,
        "Studio factory must use supplied player UserIds."
    )

    created_difficulty = nil
    resolved_difficulty = nil

    local depth2 = StudioSessionFactory.create_for_players(
        {fake_player},
        fake_sessions,
        "TestDungeon",
        "Depth2"
    )
    check(
        depth2.ok == true,
        "Explicit Studio Depth2 session must create."
    )
    check(
        created_difficulty == "Depth2",
        "Studio session creation must receive Depth2."
    )
    check(
        resolved_difficulty == "Depth2",
        "Studio InstanceState must materialize Depth2."
    )
    check(
        depth2.teleport_data.DifficultyId == "Depth2",
        "Studio routing data must preserve Depth2."
    )
else
    check(true, "Published mode intentionally skips Studio factory execution.")
end

print(string.format("[Studio Session Factory Tests] PASS: %d assertions.", assertions))
