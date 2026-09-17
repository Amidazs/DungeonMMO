--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local Core = ServerScriptService:WaitForChild("Core")
local Adapters = Core:WaitForChild("Adapters")
local Services = Core:WaitForChild("Services")

local module = Services:FindFirstChild("BestiaryService")
if not module then
    error("[Bestiary Service Tests] RED: BestiaryService is missing.")
end

local ProfileSchema = require(Shared:WaitForChild("ProfileSchema"))
local InMemoryProfileAdapter = require(Adapters:WaitForChild("InMemoryProfileAdapter"))
local ProfileService = require(Services:WaitForChild("ProfileService"))
local BestiaryService = require(module)

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Bestiary Service Tests] " .. message, 2)
    end
end

local character = ProfileSchema.create_default(9301).Characters.Slot1

local first = BestiaryService.apply_kill_to_character(character, "marauder")
check(first.ok == true and first.tracked == true, "First Marauder kill must track.")
check(first.kill_count == 1, "First Marauder kill count must be 1.")
check(#first.newly_unlocked == 1, "First kill must unlock one milestone.")
check(first.newly_unlocked[1].id == "first_defeat", "First milestone mismatch.")
check(first.newly_unlocked[1].reputation.points == 5, "First milestone reputation mismatch.")

for expected = 2, 4 do
    local result = BestiaryService.apply_kill_to_character(character, "marauder")
    check(result.kill_count == expected, "Intermediate kill count mismatch.")
    check(#result.newly_unlocked == 0, "Kills 2-4 must not repeat milestones.")
end

local fifth = BestiaryService.apply_kill_to_character(character, "marauder")
check(fifth.kill_count == 5, "Fifth Marauder kill count mismatch.")
check(#fifth.newly_unlocked == 1, "Fifth kill must unlock one milestone.")
check(fifth.newly_unlocked[1].id == "field_notes", "Fifth milestone mismatch.")

for _ = 6, 14 do
    local result = BestiaryService.apply_kill_to_character(character, "marauder")
    check(#result.newly_unlocked == 0, "Kills 6-14 must not unlock another milestone.")
end

local fifteenth = BestiaryService.apply_kill_to_character(character, "marauder")
check(fifteenth.kill_count == 15, "Fifteenth Marauder kill count mismatch.")
check(fifteenth.newly_unlocked[1].id == "dossier_complete", "Final Marauder milestone mismatch.")

local captain1 = BestiaryService.apply_kill_to_character(character, "marauder_captain")
check(captain1.kill_count == 1, "Captain first kill mismatch.")
check(captain1.newly_unlocked[1].id == "captain_defeated", "Captain first milestone mismatch.")
local captain2 = BestiaryService.apply_kill_to_character(character, "marauder_captain")
check(#captain2.newly_unlocked == 0, "Captain second kill must not unlock.")
local captain3 = BestiaryService.apply_kill_to_character(character, "marauder_captain")
check(captain3.newly_unlocked[1].id == "captain_studied", "Captain third milestone mismatch.")

local before_count = 0
for _ in pairs(character.Bestiary.Entries) do
    before_count += 1
end

local unknown = BestiaryService.apply_kill_to_character(character, "not_defined")
check(unknown.ok == true and unknown.tracked == false, "Unknown creature must be a safe no-op.")

local after_count = 0
for _ in pairs(character.Bestiary.Entries) do
    after_count += 1
end
check(after_count == before_count, "Unknown creature must not create state.")

local adapter = InMemoryProfileAdapter.new()
local profiles = ProfileService.new(adapter)
assert(profiles:load(9302))
local service = BestiaryService.new(profiles)
local snapshot = service:get_snapshot(9302)
check(snapshot.ok == true, "Loaded bestiary snapshot must succeed.")
snapshot.bestiary.Entries.fake = {
    Kills = 1,
    Milestones = {},
}
check(
    assert(profiles:get_character(9302, 1)).Bestiary.Entries.fake == nil,
    "Bestiary snapshot must be a deep clone."
)

print(string.format("[Bestiary Service Tests] PASS: %d assertions.", assertions))