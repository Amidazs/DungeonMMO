--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService:WaitForChild("Core"):WaitForChild("Services")
local RuntimeServices = require(Services:WaitForChild("RuntimeServices"))
local ProgressionService = require(Services:WaitForChild("ProgressionService"))
local ProficiencyService = require(Services:WaitForChild("ProficiencyService"))

local failures = {}
local function expect(condition: boolean, message: string)
    if not condition then table.insert(failures, message) end
end

local original_progression = ProgressionService.get_default()
local original_proficiency = ProficiencyService.get_default()

RuntimeServices.new("Base")

expect(
    ProgressionService.get_default() == original_progression,
    "auxiliary RuntimeServices.new must not replace the Place-owned ProgressionService"
)
expect(
    ProficiencyService.get_default() == original_proficiency,
    "auxiliary RuntimeServices.new must not replace the Place-owned ProficiencyService"
)

ProgressionService.bind_default(original_progression)
ProficiencyService.bind_default(original_proficiency)

if #failures > 0 then
    error("[Runtime Default Binding Tests] FAIL: " .. table.concat(failures, "; "))
end

print("[Runtime Default Binding Tests] PASS: 2 assertions.")
