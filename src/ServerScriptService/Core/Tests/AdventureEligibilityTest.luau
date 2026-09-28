--!strict
-- Launch Adventure eligibility must track creation-enabled races.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Core.Shared

local QuestDefinitions = require(Shared.QuestDefinitions)
local RaceDefinitions = require(Shared.RaceDefinitions)

local checks = 0

--[[
Counts one Adventure eligibility assertion.

Args:
    condition (boolean): Expected catalogue or character condition.
    label (string): Diagnostic failure description.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(
        condition,
        "[Adventure Eligibility] " .. label
    )
end

--[[
Returns whether one dense string list contains a value.

Args:
    values ({string}): Dense identifier collection.
    expected (string): Identifier to find.

Returns:
    boolean: True when the identifier is present.
]]
local function contains(
    values: {string},
    expected: string
): boolean
    for _, value in ipairs(values) do
        if value == expected then
            return true
        end
    end

    return false
end

--[[
Builds one complete Dark Elf Fighter for Adventure checks.

Args:
    completed ({[string]: boolean}): Persisted completed quest flags.

Returns:
    any: Detached launch-valid character identity.
]]
local function dark_elf_fighter(
    completed: {[string]: boolean}
): any
    return {
        Level = 1,
        Identity = {
            Version = 1,
            RaceId = "DarkElf",
            BaseClassId = "Fighter",
            ClassId = "Fighter",
            CreationStage = "Complete",
        },
        Quests = {
            Version = 1,
            Active = {},
            Completed = completed,
        },
    }
end

--[[
Runs launch Adventure race and prerequisite acceptance.

Args:
    None.

Returns:
    nil: Prints a stable pass marker after all checks succeed.
]]
local function main()
    local enabled_races = {}

    for race_id, definition in pairs(
        RaceDefinitions.all()
    ) do
        if definition.CreationEnabled ~= false then
            enabled_races[race_id] = true
        end
    end

    check(
        enabled_races.Human == true
            and enabled_races.Elf == true
            and enabled_races.DarkElf == true,
        "Human, Elf and Dark Elf are creation-enabled"
    )
    check(
        enabled_races.Orc ~= true
            and enabled_races.Dwarf ~= true,
        "Orc and Dwarf remain creation-disabled"
    )

    for _, adventure in ipairs(
        QuestDefinitions.adventures()
    ) do
        for race_id in pairs(enabled_races) do
            check(
                contains(
                    adventure.AllowedRaces,
                    race_id
                ),
                adventure.Id
                    .. " includes creation-enabled "
                    .. race_id
            )
        end

        check(
            not contains(adventure.AllowedRaces, "Orc")
                and not contains(
                    adventure.AllowedRaces,
                    "Dwarf"
                ),
            adventure.Id
                .. " does not pre-enable disabled races"
        )
    end

    local worldroot = assert(
        QuestDefinitions.get("WorldrootRelic")
    )
    check(
        QuestDefinitions.is_character_eligible(
            dark_elf_fighter({}),
            worldroot
        ),
        "Dark Elf Fighter can start Worldroot Relic"
    )

    local mine = assert(
        QuestDefinitions.get("MineEchoes")
    )
    check(
        QuestDefinitions.is_character_eligible(
            dark_elf_fighter({
                WorldrootRelic = true,
            }),
            mine
        ),
        "Dark Elf Fighter can continue to Mine Echoes"
    )

    local provisioning = assert(
        QuestDefinitions.get(
            "ExpeditionProvisioning"
        )
    )
    check(
        QuestDefinitions.is_character_eligible(
            dark_elf_fighter({
                WorldrootRelic = true,
                MineEchoes = true,
            }),
            provisioning
        ),
        "Dark Elf Fighter can continue to Provisioning"
    )

    print(
        ("[Adventure Eligibility] PASS: %d assertions")
            :format(checks)
    )
end

main()
