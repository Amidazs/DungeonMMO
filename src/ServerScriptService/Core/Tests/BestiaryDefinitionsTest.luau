--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")

local module = Shared:FindFirstChild("BestiaryDefinitions")
if not module then
    error("[Bestiary Definitions Tests] RED: BestiaryDefinitions is missing.")
end

local BestiaryDefinitions = require(module)
local assertions = 0

local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Bestiary Definitions Tests] " .. message, 2)
    end
end

local valid, reason = BestiaryDefinitions.validate()
check(valid == true, reason or "Definitions must validate.")

local marauder = assert(BestiaryDefinitions.get("marauder"))
check(marauder.DisplayName == "Marauder", "Marauder display name mismatch.")
check(#marauder.Milestones == 3, "Marauder must have three proof milestones.")
check(marauder.Milestones[1].Id == "first_defeat", "First milestone mismatch.")
check(marauder.Milestones[1].RequiredKills == 1, "First threshold must be 1.")
check(marauder.Milestones[2].RequiredKills == 5, "Second threshold must be 5.")
check(marauder.Milestones[3].RequiredKills == 15, "Third threshold must be 15.")

local captain = assert(BestiaryDefinitions.get("marauder_captain"))
check(#captain.Milestones == 2, "Captain must have two proof milestones.")
check(captain.Milestones[1].RequiredKills == 1, "Captain first threshold must be 1.")
check(captain.Milestones[2].RequiredKills == 3, "Captain second threshold must be 3.")
local foreman = assert(
    BestiaryDefinitions.get("corrupted_foreman")
)
check(
    foreman.DisplayName == "Corrupted Foreman",
    "Foreman display name mismatch."
)
check(
    #foreman.Milestones == 2
        and foreman.Milestones[1].Id == "foreman_defeated"
        and foreman.Milestones[1].RequiredKills == 1
        and foreman.Milestones[2].Id == "foreman_studied"
        and foreman.Milestones[2].RequiredKills == 3,
    "Foreman keeps its independent 1/3 proof milestones."
)

check(BestiaryDefinitions.get("unknown") == nil, "Unknown creature must not resolve.")

print(string.format("[Bestiary Definitions Tests] PASS: %d assertions.", assertions))