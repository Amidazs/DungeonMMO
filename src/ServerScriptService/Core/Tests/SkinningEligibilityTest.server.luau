--!strict
-- Deterministic server-owned creature eligibility for future corpse skinning.
local SSS = game:GetService("ServerScriptService")
local Skinning = require(
    SSS.Core.Services:WaitForChild("SkinningEligibility")
)

local assertions = 0

-- Args:
--   ok: boolean; condition that must hold.
--   message: string; describes the eligibility requirement.
-- Returns:
--   nil: increments the assertion count or raises on failure.
local function check(ok: boolean, message: string)
    assertions += 1
    assert(ok, "[Skinning Eligibility] " .. message)
end

for _, identity in ipairs({
    "TrainingMarauder", "Marauder", "MarauderCaptain",
    "TempleEventBoss", "MineDeepSurge", "human", "orc",
    "undead", "dragon", "forest_wolf_impostor",
}) do
    check(not Skinning.is_species_allowed(identity, "Beast"),
        "unlisted enemy must not gain skinning from a forged Beast family")
    check(not Skinning.can_skin(identity, "Beast", true, true, false),
        "unlisted enemy cannot yield animal hide")
end

for _, animal in ipairs({"forest_wolf", "wild_boar", "cave_bear"}) do
    check(Skinning.is_species_allowed(animal, "Beast"),
        "explicit registered animal should be eligible")
    check(not Skinning.can_skin(animal, "Humanoid", true, true, false),
        "animal name alone must not bypass the server family")
    check(not Skinning.can_skin(animal, "Beast", false, true, false),
        "living animal must never be skinnable")
    check(not Skinning.can_skin(animal, "Beast", true, false, false),
        "unlooted corpse must not be skinnable")
    check(not Skinning.can_skin(animal, "Beast", true, true, true),
        "already skinned corpse cannot grant duplicate hide")
    check(Skinning.can_skin(animal, "Beast", true, true, false),
        "registered animal should become eligible after death and loot")
end

check(not Skinning.can_skin(nil, "Beast", true, true, false),
    "missing identity must fail closed")
check(not Skinning.can_skin("forest_wolf", nil, true, true, false),
    "missing server family must fail closed")
check(not Skinning.can_skin("forest_wolf", "Beast", 1, true, false),
    "truthy but non-boolean death marker must not pass")
check(not Skinning.can_skin("forest_wolf", "Beast", true, true, nil),
    "missing claim state must fail closed")

print(string.format(
    "[Skinning Eligibility] PASS: %d assertions.", assertions))
