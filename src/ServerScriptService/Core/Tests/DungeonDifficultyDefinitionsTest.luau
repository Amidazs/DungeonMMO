--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")

local module = Shared:FindFirstChild("DungeonDifficultyDefinitions")
if not module then
    error(
        "[Dungeon Difficulty Definitions Tests] RED: "
            .. "DungeonDifficultyDefinitions is missing."
    )
end

local Difficulties = require(module)
local assertion_count = 0

-- Verifies one difficulty-definition contract.
local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error(
            "[Dungeon Difficulty Definitions Tests] " .. message,
            2
        )
    end
end
-- Verifies the ordered 3/4/5/6 depth ladder for one dungeon.
local function check_ladder(
    dungeon_id: string,
    expected_boss_ids: {string}
)
    local ordered = Difficulties.ordered(dungeon_id)
    check(#ordered == 4, dungeon_id .. " must expose four depths.")

    local previous_health = 0
    local previous_damage = 0
    local previous_reward = 0

    for order, difficulty in ipairs(ordered) do
        check(
            difficulty.Id == "Depth" .. tostring(order),
            dungeon_id .. " depth IDs must be stable and ordered."
        )
        check(
            difficulty.Order == order,
            dungeon_id .. " depth order must match its ID."
        )
        check(
            #difficulty.EncounterSequence == order + 2,
            dungeon_id .. " depth must add exactly one encounter."
        )
        check(
            difficulty.EnemyHealthMultiplier > previous_health,
            dungeon_id .. " health scaling must increase by depth."
        )
        check(
            difficulty.EnemyDamageMultiplier > previous_damage,
            dungeon_id .. " damage scaling must increase by depth."
        )
        check(
            difficulty.MonsterRewardMultiplier > previous_reward,
            dungeon_id .. " monster rewards must increase by depth."
        )

        for _, encounter in ipairs(
            difficulty.EncounterSequence
        ) do
            local expected_executor = if encounter.Kind == "Combat"
                then "CombatPack"
                else "Boss"
            check(
                encounter.ExecutorId == expected_executor,
                dungeon_id
                    .. " "
                    .. encounter.Id
                    .. " executor ID mismatch."
            )
        end

        previous_health = difficulty.EnemyHealthMultiplier
        previous_damage = difficulty.EnemyDamageMultiplier
        previous_reward = difficulty.MonsterRewardMultiplier

        if order == 1 then
            check(
                difficulty.RuntimeReleaseEnabled == true,
                dungeon_id .. " Depth1 release must remain enabled."
            )
        else
            check(
                difficulty.RuntimeReleaseEnabled == false,
                dungeon_id .. " higher-depth release must remain disabled."
            )
        end
    end

    check(
        Difficulties.default_id(dungeon_id) == "Depth1",
        dungeon_id .. " must default to Depth1."
    )
    local final_depth = assert(Difficulties.get(dungeon_id, "Depth4"))
    local sequence = final_depth.EncounterSequence

    check(sequence[2].Kind == "MiniBoss", "Depth4 encounter 2 must be miniboss.")
    check(sequence[4].Kind == "MiniBoss", "Depth4 encounter 4 must be miniboss.")
    check(sequence[5].Kind == "MiniBoss", "Depth4 encounter 5 must be miniboss.")
    check(sequence[6].Kind == "FinalBoss", "Depth4 encounter 6 must be final boss.")

    check(
        sequence[2].BossId == expected_boss_ids[1],
        dungeon_id .. " must reuse Depth1 boss as first final-depth miniboss."
    )
    check(
        sequence[4].BossId == expected_boss_ids[2],
        dungeon_id .. " must reuse Depth2 boss as second final-depth miniboss."
    )
    check(
        sequence[5].BossId == expected_boss_ids[3],
        dungeon_id .. " must reuse Depth3 boss as third final-depth miniboss."
    )
    check(
        sequence[6].BossId == expected_boss_ids[4],
        dungeon_id .. " must end with its unique Depth4 boss."
    )
end
check_ladder(
    "TestDungeon",
    {
        "MarauderCaptain",
        "TempleDepth2Boss",
        "TempleDepth3Boss",
        "TempleDepth4Boss",
    }
)

check_ladder(
    "AbandonedMine",
    {
        "CorruptedForeman",
        "AbandonedMineDepth2Boss",
        "AbandonedMineDepth3Boss",
        "AbandonedMineDepth4Boss",
    }
)

check(
    Difficulties.get("TestDungeon", "Unknown") == nil,
    "Unknown difficulty IDs must not resolve."
)
check(
    Difficulties.ordered("UnknownDungeon")[1] == nil,
    "Unknown dungeons must expose no difficulties."
)

print(string.format(
    "[Dungeon Difficulty Definitions Tests] PASS: %d assertions.",
    assertion_count
))
