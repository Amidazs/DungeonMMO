--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Adapter = require(
    ServerScriptService
        :WaitForChild("Dungeon")
        :WaitForChild("TempleEnvironmentAdapter")
)

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Temple Environment Adapter Tests] " .. message, 2)
    end
end

local environment = Adapter.wait_for_ready(Workspace, 15)
check(environment.ok == true, "Temple environment must resolve")

check(
    typeof(environment:checkpoint_cframe(
        "Temple.Room1.Checkpoint"
    )) == "CFrame",
    "checkpoint_cframe must return CFrame"
)
check(
    #environment:enemy_spawn_cframes("Room1") >= 2,
    "Room 1 spawn CFrames must resolve"
)
check(
    #environment:enemy_spawn_cframes("Room2") >= 3,
    "Room 2 spawn CFrames must resolve"
)
check(
    typeof(environment:captain_spawn_cframe()) == "CFrame",
    "Captain CFrame must resolve"
)

local barrier = environment:get("Temple.Room1.ExitBarrier")
if barrier then
    local closed = environment:set_exit_open("Room1", false)
    check(closed.ok == true, "Room 1 barrier close must succeed")
    check(barrier.CanCollide == true, "closed barrier must collide")

    local opened = environment:set_exit_open("Room1", true)
    check(opened.ok == true, "Room 1 barrier open must succeed")
    check(barrier.CanCollide == false, "open barrier must not collide")

    environment:set_exit_open("Room1", false)
else
    local no_barrier = environment:set_exit_open("Room1", true)
    check(
        no_barrier.ok == true,
        "optional missing barrier must be a safe no-op"
    )
end

print(string.format(
    "[Temple Environment Adapter Tests] PASS: %d assertions.",
    assertions
))
