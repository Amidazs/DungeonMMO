--!strict
-- Exact C4 source effects newly required by Shillien Oracle through level 30.
-- Source commit: 07f8536384e799f128d44198dd7ab23519660eea

local DATA = table.freeze({
    [1059] = table.freeze({
        Id = 1059,
        Name = "Greater Empower",
        Ranks = table.freeze({
            [1] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        Modifiers = table.freeze({
                            table.freeze({
                                Operation = "mul",
                                order = "0x30",
                                stat = "MAGICAL_ATTACK",
                                val = 1.55,
                            }),
                        }),
                        count = 1,
                        name = "Buff",
                        stackOrder = 1.55,
                        stackType = "mAtk",
                        time = 1200,
                        val = 0,
                    }),
                }),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    castRange = 400,
                    effectRange = 900,
                    hitTime = 4000,
                    isMagic = true,
                    mpConsume = 18,
                    mpInitialConsume = 5,
                    operateType = "ACTIVE",
                    reuseDelay = 6000,
                    skillType = "BUFF",
                    target = "TARGET_ONE",
                }),
            }),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/1000-1099.xml",
        XmlLevels = 3,
    }),
    [1268] = table.freeze({
        Id = 1268,
        Name = "Vampiric Rage",
        Ranks = table.freeze({
            [1] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        Modifiers = table.freeze({
                            table.freeze({
                                Operation = "add",
                                order = "0x40",
                                stat = "ABSORB_DAMAGE_PERCENT",
                                val = 6,
                            }),
                        }),
                        count = 1,
                        name = "Buff",
                        stackOrder = 6,
                        stackType = "vampRage",
                        time = 1200,
                        val = 0,
                    }),
                }),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    castRange = 400,
                    effectRange = 900,
                    hitTime = 4000,
                    isMagic = true,
                    mpConsume = 21,
                    mpInitialConsume = 6,
                    operateType = "ACTIVE",
                    power = 0,
                    reuseDelay = 6000,
                    skillType = "BUFF",
                    target = "TARGET_ONE",
                }),
            }),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/1200-1299.xml",
        XmlLevels = 4,
    }),
})

return DATA
