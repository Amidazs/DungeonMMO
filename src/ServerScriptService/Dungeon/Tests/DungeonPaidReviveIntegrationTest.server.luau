--!strict
-- In-memory production-service contract for paid revive and failed-run retry.
local SSS = game:GetService("ServerScriptService")
local Core = SSS:WaitForChild("Core")
local Services = Core:WaitForChild("Services")
local Adapters = Core:WaitForChild("Adapters")
local Dungeon = SSS:WaitForChild("Dungeon")

local InMemoryMapAdapter = require(
    Adapters:WaitForChild("InMemoryMapAdapter")
)
local DungeonSessionService = require(
    Services:WaitForChild("DungeonSessionService")
)
local RevivePurchaseService = require(
    Services:WaitForChild("RevivePurchaseService")
)
local DungeonDeathService = require(
    Dungeon:WaitForChild("DungeonDeathService")
)
local ReturnPortalService = require(
    Dungeon:WaitForChild("ReturnPortalService")
)

local now = 1000
local assertions = 0
local scheduled_callback: (() -> ())? = nil
local spawn_count = 0

-- Args:
--   condition: boolean; trusted server-owned invariant.
--   message: string; failure description.
-- Returns:
--   nil: records a passed assertion or raises.
local function check(condition: boolean, message: string)
    assertions += 1
    assert(condition, "[Dungeon Paid Retry Integration] " .. message)
end

-- Args: None.
-- Returns:
--   number: deterministic test time used by both backend services.
local function clock(): number
    return now
end

-- Args:
--   _delay_seconds: number; scheduled automatic revive interval.
--   callback: () -> (); completion callback to invoke explicitly.
-- Returns:
--   nil: preserves the callback without a background timer.
local function schedule(
    _delay_seconds: number,
    callback: () -> ()
)
    scheduled_callback = callback
end

-- Args:
--   _player: any; fixture player authorized to respawn.
--   _target: CFrame; the registered room-start checkpoint.
-- Returns:
--   boolean: true after recording an authorized respawn.
local function spawn_player(_player: any, _target: CFrame): boolean
    spawn_count += 1
    return true
end

local adapter = InMemoryMapAdapter.new(clock)
local sessions = DungeonSessionService.new(adapter, clock)
local player: any = {UserId = 98450, Name = "PaidRetryFixture"}
local first = assert(sessions:create(
    "TestDungeon", {player.UserId}, 100, "PaidRetryFirst_TEMP"
))
local session_id = first.SessionId
check(
    sessions:mark_connected(session_id, player.UserId).ok,
    "The original run must admit its test player."
)
local checkpoint = {
    get_active_checkpoint = function()
        return {
            Id = "EncounterStart:CombatRoom2",
            CFrame = CFrame.new(0, 4, 10),
        }
    end,
}
local death = DungeonDeathService.new(
    sessions, checkpoint, session_id, {
        clock = clock,
        schedule = schedule,
        spawn_player = spawn_player,
    }
)
local granted_callbacks = 0
local purchase = RevivePurchaseService.new(sessions, {
    is_studio = true,
    purchase_id_factory = function()
        return "PaidRetryPurchase1"
    end,
    on_granted = function(user_id: number, granted_session: string)
        check(
            user_id == player.UserId and granted_session == session_id,
            "The purchase callback must preserve the member and run."
        )
        granted_callbacks += 1
        local revived = death:complete_paid_revive(player)
        check(revived.ok == true,
            "The real paid grant callback must respawn its Active member.")
    end,
})

check(
    death:on_player_died(player, CFrame.new()).automatic_free_revive == true,
    "The first death must use the free revive."
)
local automatic = assert(scheduled_callback)
automatic()
check(spawn_count == 1, "The free revive must spawn exactly once.")
check(
    death:on_player_died(player, CFrame.new()).ok,
    "The second death must be accepted."
)
local paid = purchase:simulate_approved_purchase(
    player.UserId, session_id
)
check(
    paid.ok == true and paid.already_applied == false
        and granted_callbacks == 1 and spawn_count == 2,
    "A genuine authorized purchase must spawn the member once."
)
local member = sessions:get(session_id).Members[tostring(player.UserId)]
check(
    member.Mode == "Active" and member.PaidReviveCount == 1,
    "Paid revive must restore Active mode with one purchase receipt."
)

local duplicate = purchase:grant_revive_once(
    "PaidRetryPurchase1", player.UserId, session_id
)
check(
    duplicate.ok == true and duplicate.already_applied == true
        and granted_callbacks == 1 and spawn_count == 2,
    "A duplicate receipt must neither regrant nor respawn."
)
check(
    death:on_player_died(player, CFrame.new()).ok,
    "A later death must make the participant spectate."
)
now = 1030
check(death:tick(now).failed == true,
    "Expired wipe must make the old run terminal.")
local late = purchase:grant_revive_once(
    "PaidRetryPurchase2", player.UserId, session_id
)
check(
    late.ok == false and spawn_count == 2
        and granted_callbacks == 1,
    "A purchase after terminal failure cannot revive the old run."
)

local returns = ReturnPortalService.new(
    sessions, {
        return_to_base = function()
            error("Unpublished in-memory return cannot teleport")
        end,
    }, {is_studio = true}
)
local home = returns:request_failed_return(
    session_id, {player}
)
check(
    home.ok == true and home.simulated == true,
    "A member of the failed run must be able to return to Base."
)
local retry = assert(sessions:create(
    "TestDungeon", {player.UserId}, 100, "PaidRetryNew_TEMP"
))
check(
    retry.SessionId ~= session_id
        and retry.Checkpoint.Id == "Entrance"
        and retry.Members[tostring(player.UserId)].FreeReviveUsed == false,
    "A retry needs a fresh session, entrance and free revive."
)
check(
    sessions:get(session_id).State == "Failed"
        and sessions:get_for_user(player.UserId).SessionId
            == retry.SessionId,
    "Retry must not reopen the old run or its reward identity."
)

print(string.format(
    "[Dungeon Paid Retry Integration] PASS: %d assertions.", assertions
))
