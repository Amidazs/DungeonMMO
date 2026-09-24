--!strict
-- Unpublished local all-class skill reference inventory.
assert(game.PlaceId == 0 and game.GameId == 0,
    "All-class C4 audit runs only in a disposable local place")
local tests = game:GetService("ServerScriptService").Core.Tests
local source = assert(tests:FindFirstChild(
    "C4AllImplementedClassSkillAuditTest"
))
local module = Instance.new("ModuleScript")
module.Name = "TEMP_C4AllClassesAudit"
module.Source = source.Source .. "\nreturn true\n"
module.Parent = tests
local ok, value = pcall(require, module)
module:Destroy()
assert(ok and value == true,
    "Complete-current-scope inventory failed: " .. tostring(value))
print("[C4 ALL-CLASS AUDIT] VERIFIED_INVENTORY_NOT_PARITY")
