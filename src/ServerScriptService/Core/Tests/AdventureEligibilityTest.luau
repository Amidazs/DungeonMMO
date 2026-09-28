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

    local captain = assert(
        QuestDefinitions.get("MarauderCaptainBounty")
    )
    local level_four = dark_elf_fighter({
        WorldrootRelic = true,
    })
    level_four.Level = 4
    check(
        not QuestDefinitions.is_character_eligible(
            level_four,
            captain
        ),
        "level-four Dark Elf cannot start Captain bounty"
    )

    local level_five = dark_elf_fighter({
        WorldrootRelic = true,
    })
    level_five.Level = 5
    check(
        QuestDefinitions.is_character_eligible(
            level_five,
            captain
        ),
        "level-five Dark Elf can start Captain bounty"
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

    local survey = assert(
        QuestDefinitions.get("RuinSurvey")
    )
    local level_seven_survey = dark_elf_fighter({
        WorldrootRelic = true,
        MineEchoes = true,
    })
    level_seven_survey.Level = 7
    check(
        not QuestDefinitions.is_character_eligible(
            level_seven_survey,
            survey
        ),
        "level-seven Dark Elf cannot start Ruin Survey"
    )

    local missing_survey_mine = dark_elf_fighter({
        WorldrootRelic = true,
    })
    missing_survey_mine.Level = 8
    check(
        not QuestDefinitions.is_character_eligible(
            missing_survey_mine,
            survey
        ),
        "level-eight Ruin Survey still requires Mine Echoes"
    )

    local level_eight_survey = dark_elf_fighter({
        WorldrootRelic = true,
        MineEchoes = true,
    })
    level_eight_survey.Level = 8
    check(
        QuestDefinitions.is_character_eligible(
            level_eight_survey,
            survey
        ),
        "level-eight Dark Elf can start Ruin Survey after Mine Echoes"
    )

    local foreman = assert(
        QuestDefinitions.get("CorruptedForemanBounty")
    )
    local level_nine = dark_elf_fighter({
        WorldrootRelic = true,
        MineEchoes = true,
    })
    level_nine.Level = 9
    check(
        not QuestDefinitions.is_character_eligible(
            level_nine,
            foreman
        ),
        "level-nine Dark Elf cannot start Foreman bounty"
    )

    local missing_mine = dark_elf_fighter({
        WorldrootRelic = true,
    })
    missing_mine.Level = 10
    check(
        not QuestDefinitions.is_character_eligible(
            missing_mine,
            foreman
        ),
        "level-ten Foreman bounty still requires Mine Echoes"
    )

    local level_ten = dark_elf_fighter({
        WorldrootRelic = true,
        MineEchoes = true,
    })
    level_ten.Level = 10
    check(
        QuestDefinitions.is_character_eligible(
            level_ten,
            foreman
        ),
        "level-ten Dark Elf can start Foreman bounty after Mine Echoes"
    )

    local boss_hunt = assert(
        QuestDefinitions.get("DungeonBossHunt")
    )
    local level_fourteen = dark_elf_fighter({
        WorldrootRelic = true,
        MineEchoes = true,
    })
    level_fourteen.Level = 14
    check(
        not QuestDefinitions.is_character_eligible(
            level_fourteen,
            boss_hunt
        ),
        "level-fourteen Dark Elf cannot start dual boss Adventure"
    )

    local level_fifteen = dark_elf_fighter({
        WorldrootRelic = true,
        MineEchoes = true,
    })
    level_fifteen.Level = 15
    check(
        QuestDefinitions.is_character_eligible(
            level_fifteen,
            boss_hunt
        ),
        "level-fifteen Dark Elf can start dual boss Adventure"
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
