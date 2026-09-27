--!strict
-- Exact C4 source effects newly required by Scavenger.
-- Source commit: 07f8536384e799f128d44198dd7ab23519660eea

local DATA = table.freeze({
    [254] = table.freeze({
        Id = 254,
        Name = "Spoil",
        Ranks = table.freeze({
            [2] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    castRange = 40,
                    effectPower = 1,
                    effectRange = 400,
                    effectType = "DEBUFF",
                    hitTime = 1800,
                    magicLvl = 20,
                    mpConsume = 19,
                    operateType = "ACTIVE",
                    reuseDelay = 10000,
                    saveVs = "WIT",
                    skillType = "SPOIL",
                    target = "TARGET_ONE",
                }),
            }),
            [3] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    castRange = 40,
                    effectPower = 1,
                    effectRange = 400,
                    effectType = "DEBUFF",
                    hitTime = 1800,
                    magicLvl = 28,
                    mpConsume = 25,
                    operateType = "ACTIVE",
                    reuseDelay = 10000,
                    saveVs = "WIT",
                    skillType = "SPOIL",
                    target = "TARGET_ONE",
                }),
            }),
        }),
        SourceFile = "L2jAdmins_Data/data/xml/stats/skills/0200-0299.xml",
        XmlLevels = 11,
    }),
    [302] = table.freeze({
        Id = 302,
        Name = "Spoil Festival",
        Ranks = table.freeze({
            [1] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    castRange = 40,
                    effectPower = 0,
                    effectRange = 400,
                    effectType = "DEBUFF",
                    hitTime = 1800,
                    magicLvl = 28,
                    mpConsume = 73,
                    operateType = "ACTIVE",
                    reuseDelay = 10000,
                    saveVs = "WIT",
                    skillRadius = 200,
                    skillType = "SPOIL",
                    target = "TARGET_AREA",
                }),
            }),
        }),
        SourceFile = "L2jAdmins_Data/data/xml/stats/skills/0300-0399.xml",
        XmlLevels = 9,
    }),
})

return DATA
