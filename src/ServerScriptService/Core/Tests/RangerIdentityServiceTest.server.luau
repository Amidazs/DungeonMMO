--!strict
-- Fresh C4 characters must start as Fighter or Mystic only.
-- Ranger/Rogue remain loadable legacy/internal combat families until migrated.
local ServerScriptService = game:GetService("ServerScriptService")

local Core = ServerScriptService:WaitForChild("Core")
local ProfileService = require(
    Core:WaitForChild("Services"):WaitForChild("ProfileService")
)
local IdentityService = require(
    Core:WaitForChild("Services"):WaitForChild("IdentityService")
)
local InMemoryProfileAdapter = require(
    Core:WaitForChild("Adapters"):WaitForChild("InMemoryProfileAdapter")
)

local checks = 0

--[[
Records one exact starter-class or legacy-compatibility assertion.

Args:
    condition (boolean): Required fresh/legacy identity behavior.
    description (string): Precise class-selection regression message.

Returns:
    nil: Increments the verified assertion count or raises.
]]
local function check(condition: boolean, description: string)
    checks += 1
    assert(condition, "[C4 Starter Identity] " .. description)
end

--[[
Verifies a new character cannot start directly as Ranger or Rogue.

Args:
    race_id (string): Currently playable Human or Elf race.
    user_id (number): Isolated in-memory profile identity.

Returns:
    nil: Leaves the fresh character at ClassSelection after both refusals.
]]
local function reject_advanced_starters(
    race_id: string, user_id: number
)
    local profiles = ProfileService.new(InMemoryProfileAdapter.new())
    check(profiles:load(user_id), "Fresh profile must load")
    local identity = IdentityService.new(profiles)
    check(identity:select_race(user_id, race_id).ok,
        race_id .. " race selection must succeed")

    for _, class_id in ipairs({"Ranger", "Rogue"}) do
        local result = identity:select_base_class(user_id, class_id)
        check(not result.ok
            and result.reason == "OriginalC4StartingClassRequired",
            "Fresh " .. race_id .. " cannot begin directly as " .. class_id)
    end

    local character = assert(profiles:get_character(user_id, 1))
    check(character.Identity.CreationStage == "ClassSelection"
        and character.Identity.BaseClassId == nil
        and character.Identity.ClassId == nil,
        "Rejected advanced starter choices must not mutate identity")
end

--[[
Verifies the actual two C4 starting families remain selectable.

Args:
    race_id (string): Human or Elf.
    user_id (number): Isolated profile identity.
    class_id (string): Fighter or Mage internal Mystic family ID.

Returns:
    nil: Confirms only an allowed starting family completes creation.
]]
local function accept_original_starter(
    race_id: string, user_id: number, class_id: string
)
    local profiles = ProfileService.new(InMemoryProfileAdapter.new())
    check(profiles:load(user_id), "Starter profile must load")
    local identity = IdentityService.new(profiles)
    check(identity:select_race(user_id, race_id).ok,
        "Original race selection must succeed")
    local result = identity:select_base_class(user_id, class_id)
    check(result.ok, "Original " .. class_id .. " starter must succeed")
    local character = assert(profiles:get_character(user_id, 1))
    check(character.Identity.BaseClassId == class_id
        and character.Identity.ClassId == class_id
        and character.Identity.CreationStage == "Complete",
        "Original starter must become authoritative identity")
end

--[[
Runs the fresh-character C4 starter-class contract for both playable races.

Args:
    None.

Returns:
    nil: Prints actual selection assertions after all checks pass.
]]
local function main()
    reject_advanced_starters("Human", 7511)
    reject_advanced_starters("Elf", 7512)
    accept_original_starter("Human", 7513, "Fighter")
    accept_original_starter("Human", 7514, "Mage")
    accept_original_starter("Elf", 7515, "Fighter")
    accept_original_starter("Elf", 7516, "Mage")
    print(("[C4 Starter Identity] PASS: %d assertions")
        :format(checks))
end

main()
