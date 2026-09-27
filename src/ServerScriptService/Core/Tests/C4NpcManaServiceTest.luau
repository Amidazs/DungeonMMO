--!strict
-- Server-owned NPC mana authority regression.

local ServerScriptService = game:GetService("ServerScriptService")
local Mana = require(
    ServerScriptService.Core.Services.C4NpcManaService
)

local checks = 0

--[[
Counts one NPC mana assertion.

Args:
    condition (boolean): Observed condition.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 NPC Mana] " .. label)
end

--[[
Runs initialization, draining, clamping and reset coverage.

Args:
    None.

Returns:
    nil: Prints bounded server-owned mana evidence.
]]
local function main()
    local npc = Instance.new("Model")
    npc.Name = "TEMP_C4NpcMana"

    check(
        Mana.get(npc) == 0 and Mana.get_max(npc) == 0,
        "uninitialized NPC mana is zero"
    )

    check(
        Mana.ensure(npc, 40) == 40
            and Mana.get(npc) == 40
            and Mana.get_max(npc) == 40,
        "reviewed maximum initializes current mana"
    )

    check(
        Mana.drain(npc, 7) == 7
            and Mana.get(npc) == 33,
        "exact mana drain is authoritative"
    )

    check(
        Mana.ensure(npc, 40) == 33
            and Mana.get(npc) == 33,
        "same reviewed maximum preserves current mana"
    )

    check(
        Mana.drain(npc, 100) == 33
            and Mana.get(npc) == 0,
        "mana drain clamps at zero"
    )

    check(
        Mana.ensure(npc, 55) == 55
            and Mana.get_max(npc) == 55,
        "changed reviewed maximum resets current mana"
    )

    Mana.clear(npc)
    check(
        Mana.get(npc) == 0 and Mana.get_max(npc) == 0,
        "clear removes only C4 mana state"
    )

    npc:Destroy()

    print((
        "[C4 NPC Mana] PASS: %d assertions server_owned=true"
    ):format(checks))
end

main()
