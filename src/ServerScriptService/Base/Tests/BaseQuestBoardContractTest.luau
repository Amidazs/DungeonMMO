--!strict
-- Focused contract for the physical Base Adventure Board.

local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local BaseEnvironmentAdapter = require(
    ServerScriptService.Base.BaseEnvironmentAdapter
)

local checks = 0

--[[
Counts one Adventure Board environment assertion.

Args:
    condition (boolean): Expected physical board invariant.
    label (string): Failure context.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[Base Adventure Board] " .. label)
end

--[[
Validates the resolved board anchor and contextual prompt.

Args:
    None.

Returns:
    nil: Prints a stable pass marker after all checks succeed.
]]
local function main()
    local environment = BaseEnvironmentAdapter.wait_for_ready(
        Workspace,
        15
    )
    check(environment.ok == true, "Base environment resolves")

    local board = environment:get("Base.DungeonBoard")
    check(
        board ~= nil and board:IsA("BasePart"),
        "existing Base board anchor resolves"
    )

    local prompt = board
        and board:FindFirstChild("QuestBoardPrompt")
    check(
        prompt ~= nil and prompt:IsA("ProximityPrompt"),
        "Adventure Board owns the contextual quest prompt"
    )
    check(
        prompt.ActionText == "Browse"
            and prompt.ObjectText == "Adventure Board",
        "quest prompt exposes the intended player-facing action"
    )
    check(
        prompt.MaxActivationDistance == 12,
        "Adventure Board uses the normal contextual access distance"
    )
    check(
        board:FindFirstChild("DungeonBoardPrompt") == nil,
        "legacy unused Dungeon Board prompt is not duplicated"
    )

    print(
        ("[Base Adventure Board] PASS: %d assertions")
            :format(checks)
    )
end

main()
