--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local BaseEnvironmentAdapter = require(
    ServerScriptService
        :WaitForChild("Base")
        :WaitForChild("BaseEnvironmentAdapter")
)

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Base Environment Contract Tests] " .. message, 2)
    end
end

local adapter = BaseEnvironmentAdapter.wait_for_ready(
    Workspace,
    15
)
check(adapter.ok == true, "Base environment must resolve")
check(
    Workspace:FindFirstChild("BasePrototype") == nil,
    "legacy BasePrototype must not be the environment contract"
)
check(
    adapter:get("Base.PlayerSpawn") ~= nil,
    "Base.PlayerSpawn required"
)
check(
    adapter:get("Base.TemplePortal") ~= nil,
    "Base.TemplePortal required"
)
check(
    adapter:get("Base.Trainer.Fighter") ~= nil,
    "Fighter trainer required"
)
check(
    adapter:get("Base.Trainer.Mage") ~= nil,
    "Mage trainer required"
)
check(
    adapter:get("Base.Trainer.Ranger") ~= nil,
    "Ranger trainer required"
)
check(
    adapter:get("Base.Service.Equipment") ~= nil,
    "Equipment service required"
)
check(
    adapter:get("Base.DungeonBoard") ~= nil,
    "Dungeon board required"
)

print(string.format(
    "[Base Environment Contract Tests] PASS: %d assertions.",
    assertions
))
