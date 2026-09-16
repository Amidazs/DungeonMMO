--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Base = ServerScriptService:WaitForChild("Base")

local Module = Base:FindFirstChild("TravelCandidateLandmarkResolver")
if not Module then
    error("[Travel Candidate Resolver Tests] RED: resolver is missing.")
end
local Resolver = require(Module)

local root = Instance.new("Folder")
root.Name = "TravelCandidateResolverTest"

local dwarf = Instance.new("Part")
dwarf.Name = "Anchor_FastTravel_Dwarf_Mine"
dwarf.Parent = root

local orc = Instance.new("Part")
orc.Name = "Anchor_FastTravel_Orc_Farm"
orc.Parent = root

local dwarf_result = Resolver.resolve(root, {
    PreferredNames = {"Anchor_FastTravel_Dwarf_Mine"},
    PreferredPrefix = "Anchor_FastTravel",
    AreaFragments = {"Dwarf", "Dwarven", "Mine"},
})
assert(dwarf_result.ok == true and dwarf_result.instance == dwarf)

local orc_result = Resolver.resolve(root, {
    PreferredNames = {"Anchor_FastTravel_Orc_Farm"},
    PreferredPrefix = "Anchor_FastTravel",
    AreaFragments = {"Orc", "Orcs", "Farm"},
})
assert(orc_result.ok == true and orc_result.instance == orc)

local duplicate = Instance.new("Part")
duplicate.Name = "Anchor_FastTravel_Dwarf_Mine"
duplicate.Parent = root

local ambiguous = Resolver.resolve(root, {
    PreferredNames = {"Anchor_FastTravel_Dwarf_Mine"},
    PreferredPrefix = "Anchor_FastTravel",
    AreaFragments = {"Dwarf", "Mine"},
})
assert(ambiguous.ok == false and ambiguous.reason == "CandidateLandmarkAmbiguous")

root:ClearAllChildren()

local missing = Resolver.resolve(root, {
    PreferredNames = {"Anchor_FastTravel_Orc_Farm"},
    PreferredPrefix = "Anchor_FastTravel",
    AreaFragments = {"Orc", "Farm"},
})
assert(missing.ok == false and missing.reason == "CandidateLandmarkMissing")

root:Destroy()

print("[Travel Candidate Resolver Tests] PASS")
