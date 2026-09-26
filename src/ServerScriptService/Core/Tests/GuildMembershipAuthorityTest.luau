--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Core = ServerScriptService:WaitForChild("Core")
local Adapters = Core:WaitForChild("Adapters")
local Services = Core:WaitForChild("Services")

local InMemoryEntityAdapter = require(Adapters:WaitForChild("InMemoryEntityAdapter"))
local GuildService = require(Services:WaitForChild("GuildService"))

local assertions = 0
local function check(value: boolean, message: string)
    assertions += 1
    if not value then error("[Guild Membership Authority Tests] " .. message, 2) end
end

local now = 100
local guilds = GuildService.new(
    InMemoryEntityAdapter.new(),
    function() return now end,
    function() return "guild-authority" end
)

local created = guilds:create_guild(1, 1, "Authority Guild", "create-1")
check(created.ok == true, "Leader must be able to create guild.")
check(guilds:get_membership(1, 1).Role == "Leader", "Creator must be sole Leader.")

local invite2 = guilds:create_invite(1, 2, "invite-2")
check(invite2.ok == true, "Leader must be able to invite.")
local joined2 = guilds:accept_invite(2, "guild-authority", "join-2")
check(joined2.ok == true, "Invited member must be able to join.")
local promoted = guilds:set_role(1, 2, "Officer", "promote-2")
check(promoted.ok == true, "Leader must be able to promote Officer.")
check(guilds:get_membership(2, 1).Role == "Officer", "Target role must update.")

local invite3 = guilds:create_invite(2, 3, "invite-3")
check(invite3.ok == true, "Officer must be able to invite.")
local joined3 = guilds:accept_invite(3, "guild-authority", "join-3")
check(joined3.ok == true, "Officer invite must be joinable.")

local member_invite = guilds:create_invite(3, 4, "invite-4")
check(member_invite.ok == false and member_invite.reason == "GuildPermissionDenied",
    "Member must not be able to invite.")
local officer_kick = guilds:kick(2, 3, "officer-kick")
check(officer_kick.ok == false and officer_kick.reason == "GuildPermissionDenied",
    "Officer must not be able to kick.")

local replay_promote = guilds:set_role(1, 2, "Officer", "promote-2")
check(replay_promote.ok == true, "Role transaction replay must be idempotent.")
local transfer = guilds:transfer_leadership(1, 2, "transfer-2")
check(transfer.ok == true, "Leader must be able to transfer leadership.")
check(guilds:get_membership(2, 1).Role == "Leader", "Target must become Leader.")
check(guilds:get_membership(1, 1).Role == "Officer", "Old Leader must become Officer.")
local old_leader_kick = guilds:kick(1, 3, "old-leader-kick")
check(old_leader_kick.ok == false and old_leader_kick.reason == "GuildPermissionDenied",
    "Transferred old Leader must no longer have Leader authority.")

local new_leader_kick = guilds:kick(2, 3, "new-leader-kick")
check(new_leader_kick.ok == true, "New Leader must be able to kick.")
check(guilds:get_membership(3, 1) == nil, "Kicked member pointer must be removed.")

local leader_leave = guilds:leave(2, "leader-leave")
check(leader_leave.ok == false and leader_leave.reason == "LeaderTransferRequired",
    "Leader must transfer leadership before leaving while members remain.")

local transfer_back = guilds:transfer_leadership(2, 1, "transfer-back")
check(transfer_back.ok == true, "Leadership must be transferable back to an existing member.")
local officer_leave = guilds:leave(2, "officer-leave")
check(officer_leave.ok == true, "Non-Leader member must be able to leave.")
check(guilds:get_membership(2, 1) == nil, "Leaving member pointer must clear.")

print(string.format(
    "[Guild Membership Authority Tests] PASS: %d assertions.",
    assertions
))
