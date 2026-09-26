--!strict
-- Exact C4 source effects newly required by Elven Oracle through level 30.
-- Source commit: 07f8536384e799f128d44198dd7ab23519660eea

local DATA = table.freeze({
    [1013] = table.freeze({
        Id = 1013,
        Name = "Recharge",
        Ranks = table.freeze({
            [1] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    mpInitialConsume = 10,
                    mpConsume = 39,
                    power = 49,
                    target = "TARGET_ONE",
                    hitTime = 6000,
                    reuseDelay = 12000,
                    skillType = "MANARECHARGE",
                    isMagic = true,
                    operateType = "ACTIVE",
                    castRange = 400,
                    effectRange = 900,
                }),
            }),
            [2] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    mpInitialConsume = 11,
                    mpConsume = 42,
                    power = 52,
                    target = "TARGET_ONE",
                    hitTime = 6000,
                    reuseDelay = 12000,
                    skillType = "MANARECHARGE",
                    isMagic = true,
                    operateType = "ACTIVE",
                    castRange = 400,
                    effectRange = 900,
                }),
            }),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/1000-1099.xml",
        XmlLevels = 32,
    }),
    [1087] = table.freeze({
        Id = 1087,
        Name = "Agility",
        Ranks = table.freeze({
            [1] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        name = "Buff",
                        count = 1,
                        time = 1200,
                        val = 0,
                        stackOrder = 2,
                        stackType = "rEvas",
                        Modifiers = table.freeze({
                            table.freeze({
                                Operation = "add",
                                order = "0x40",
                                stat = "EVASION_RATE",
                                val = 2,
                            }),
                        }),
                    }),
                }),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    mpInitialConsume = 5,
                    mpConsume = 18,
                    target = "TARGET_ONE",
                    hitTime = 4000,
                    reuseDelay = 6000,
                    skillType = "BUFF",
                    isMagic = true,
                    operateType = "ACTIVE",
                    castRange = 400,
                    effectRange = 900,
                }),
            }),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/1000-1099.xml",
        XmlLevels = 3,
    }),
    [1206] = table.freeze({
        Id = 1206,
        Name = "Wind Shackle",
        Ranks = table.freeze({
            [2] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        name = "Debuff",
                        count = 1,
                        time = 15,
                        val = 0,
                        stackOrder = 0.8,
                        stackType = "pAtkSpdDown",
                        Modifiers = table.freeze({
                            table.freeze({
                                Operation = "mul",
                                order = "0x30",
                                stat = "PHYSICAL_ATTACK_SPEED",
                                val = 0.8,
                            }),
                        }),
                    }),
                }),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    mpInitialConsume = 2,
                    mpConsume = 8,
                    magicLvl = 20,
                    target = "TARGET_ONE",
                    hitTime = 1500,
                    reuseDelay = 8000,
                    skillType = "DEBUFF",
                    isMagic = true,
                    operateType = "ACTIVE",
                    castRange = 600,
                    effectRange = 1100,
                    effectType = "DEBUFF",
                    effectPower = 80,
                    saveVs = "WIT",
                }),
            }),
            [3] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        name = "Debuff",
                        count = 1,
                        time = 15,
                        val = 0,
                        stackOrder = 0.8,
                        stackType = "pAtkSpdDown",
                        Modifiers = table.freeze({
                            table.freeze({
                                Operation = "mul",
                                order = "0x30",
                                stat = "PHYSICAL_ATTACK_SPEED",
                                val = 0.8,
                            }),
                        }),
                    }),
                }),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    mpInitialConsume = 3,
                    mpConsume = 9,
                    magicLvl = 25,
                    target = "TARGET_ONE",
                    hitTime = 1500,
                    reuseDelay = 8000,
                    skillType = "DEBUFF",
                    isMagic = true,
                    operateType = "ACTIVE",
                    castRange = 600,
                    effectRange = 1100,
                    effectType = "DEBUFF",
                    effectPower = 80,
                    saveVs = "WIT",
                }),
            }),
            [4] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        name = "Debuff",
                        count = 1,
                        time = 15,
                        val = 0,
                        stackOrder = 0.8,
                        stackType = "pAtkSpdDown",
                        Modifiers = table.freeze({
                            table.freeze({
                                Operation = "mul",
                                order = "0x30",
                                stat = "PHYSICAL_ATTACK_SPEED",
                                val = 0.8,
                            }),
                        }),
                    }),
                }),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    mpInitialConsume = 3,
                    mpConsume = 11,
                    magicLvl = 30,
                    target = "TARGET_ONE",
                    hitTime = 1500,
                    reuseDelay = 8000,
                    skillType = "DEBUFF",
                    isMagic = true,
                    operateType = "ACTIVE",
                    castRange = 600,
                    effectRange = 1100,
                    effectType = "DEBUFF",
                    effectPower = 80,
                    saveVs = "WIT",
                }),
            }),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/1200-1299.xml",
        XmlLevels = 19,
    }),
})

return DATA
