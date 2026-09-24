--!strict
-- Focused unpublished Studio report; does not rewrite gameplay values.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 skill fidelity audit requires a disposable local place")
local tests = game:GetService("ServerScriptService").Core.Tests
local source = assert(tests:FindFirstChild(
    "C4SkillEffectFidelityAuditTest"
))
local module = Instance.new("ModuleScript")
module.Name = "TEMP_C4SkillFidelityAudit"
module.Source = source.Source .. "\nreturn true\n"
module.Parent = tests
local ok, value = pcall(require, module)
module:Destroy()
assert(ok and value == true,
    "C4 reference inspection failed: " .. tostring(value))
print("[C4 FIDELITY] VERIFIED_AUDIT_EXECUTION_PARITY_NOT_CERTIFIED")
