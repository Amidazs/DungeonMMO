--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local RuntimeMode = require(
    ServerScriptService
        :WaitForChild("Core")
        :WaitForChild("Environment")
        :WaitForChild("EnvironmentRuntimeMode")
)

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Environment Runtime Mode Tests] " .. message, 2)
    end
end

local mode, reason = RuntimeMode.resolve(true, nil)
check(mode == "Synthetic" and reason == nil, "Studio default is Synthetic")

mode, reason = RuntimeMode.resolve(true, "Candidate")
check(mode == "Candidate" and reason == nil, "Studio may use Candidate")

mode, reason = RuntimeMode.resolve(true, "Authored")
check(mode == "Authored" and reason == nil, "Studio may inspect Authored")

mode, reason = RuntimeMode.resolve(false, "Authored")
check(mode == "Authored" and reason == nil, "non-Studio accepts Authored")

mode, reason = RuntimeMode.resolve(false, "Candidate")
check(
    mode == nil and reason == "EnvironmentModeNotPublishSafe",
    "non-Studio rejects Candidate"
)

mode, reason = RuntimeMode.resolve(false, "Synthetic")
check(
    mode == nil and reason == "EnvironmentModeNotPublishSafe",
    "non-Studio rejects Synthetic"
)

mode, reason = RuntimeMode.resolve(false, nil)
check(mode == "Authored" and reason == nil, "non-Studio defaults to Authored")

print(string.format(
    "[Environment Runtime Mode Tests] PASS: %d assertions.",
    assertions
))
