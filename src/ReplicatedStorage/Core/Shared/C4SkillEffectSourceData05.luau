--!strict
-- Generated factual C4 skill data for the current level-30 source scope.
-- Source: https://github.com/Neco-spain/l2jadmins_C4-Scions-of-Destiny/blob/07f8536384e799f128d44198dd7ab23519660eea/L2jAdmins_Data/data/xml/stats/skills/1000-1099.xml
local DATA = table.freeze({
    [1011] = table.freeze({
        Id = 1011,
        Name = "Heal",
        Ranks = table.freeze({
            [1] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        name = "Heal",
                        power = 49,
                        val = 0,
                    }),
                }),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    castRange = 600,
                    effectRange = 1100,
                    hitTime = 5000,
                    isMagic = true,
                    mpConsume = 8,
                    mpInitialConsume = 2,
                    operateType = "ACTIVE",
                    reuseDelay = 10000,
                    skillType = "HEAL",
                    target = "TARGET_ONE",
                }),
            }),
            [2] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        name = "Heal",
                        power = 58,
                        val = 0,
                    }),
                }),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    castRange = 600,
                    effectRange = 1100,
                    hitTime = 5000,
                    isMagic = true,
                    mpConsume = 10,
                    mpInitialConsume = 3,
                    operateType = "ACTIVE",
                    reuseDelay = 10000,
                    skillType = "HEAL",
                    target = "TARGET_ONE",
                }),
            }),
            [3] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        name = "Heal",
                        power = 67,
                        val = 0,
                    }),
                }),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    castRange = 600,
                    effectRange = 1100,
                    hitTime = 5000,
                    isMagic = true,
                    mpConsume = 11,
                    mpInitialConsume = 3,
                    operateType = "ACTIVE",
                    reuseDelay = 10000,
                    skillType = "HEAL",
                    target = "TARGET_ONE",
                }),
            }),
            [4] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        name = "Heal",
                        power = 83,
                        val = 0,
                    }),
                }),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    castRange = 600,
                    effectRange = 1100,
                    hitTime = 5000,
                    isMagic = true,
                    mpConsume = 13,
                    mpInitialConsume = 4,
                    operateType = "ACTIVE",
                    reuseDelay = 10000,
                    skillType = "HEAL",
                    target = "TARGET_ONE",
                }),
            }),
            [5] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        name = "Heal",
                        power = 95,
                        val = 0,
                    }),
                }),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    castRange = 600,
                    effectRange = 1100,
                    hitTime = 5000,
                    isMagic = true,
                    mpConsume = 15,
                    mpInitialConsume = 4,
                    operateType = "ACTIVE",
                    reuseDelay = 10000,
                    skillType = "HEAL",
                    target = "TARGET_ONE",
                }),
            }),
            [6] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        name = "Heal",
                        power = 107,
                        val = 0,
                    }),
                }),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    castRange = 600,
                    effectRange = 1100,
                    hitTime = 5000,
                    isMagic = true,
                    mpConsume = 17,
                    mpInitialConsume = 5,
                    operateType = "ACTIVE",
                    reuseDelay = 10000,
                    skillType = "HEAL",
                    target = "TARGET_ONE",
                }),
            }),
        }),
        SourceFile = "L2jAdmins_Data/data/xml/stats/skills/1000-1099.xml",
        XmlLevels = 18,
    }),
    [1012] = table.freeze({
        Id = 1012,
        Name = "Cure Poison",
        Ranks = table.freeze({
            [1] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        name = "NegateEffect",
                        val = 0,
                    }),
                }),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    castRange = 600,
                    effectPower = 30,
                    effectRange = 1100,
                    hitTime = 4000,
                    isMagic = true,
                    mpConsume = 8,
                    mpInitialConsume = 2,
                    negateStats = "POISON",
                    operateType = "ACTIVE",
                    reuseDelay = 15000,
                    skillType = "BUFF",
                    target = "TARGET_ONE",
                }),
            }),
        }),
        SourceFile = "L2jAdmins_Data/data/xml/stats/skills/1000-1099.xml",
        XmlLevels = 3,
    }),
    [1015] = table.freeze({
        Id = 1015,
        Name = "Battle Heal",
        Ranks = table.freeze({
            [1] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        name = "Heal",
                        power = 83,
                        val = 0,
                    }),
                }),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    castRange = 600,
                    effectRange = 1100,
                    hitTime = 2000,
                    isMagic = true,
                    mpConsume = 20,
                    mpInitialConsume = 5,
                    operateType = "ACTIVE",
                    reuseDelay = 3000,
                    skillType = "HEAL",
                    target = "TARGET_ONE",
                }),
            }),
            [2] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        name = "Heal",
                        power = 95,
                        val = 0,
                    }),
                }),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    castRange = 600,
                    effectRange = 1100,
                    hitTime = 2000,
                    isMagic = true,
                    mpConsume = 22,
                    mpInitialConsume = 6,
                    operateType = "ACTIVE",
                    reuseDelay = 3000,
                    skillType = "HEAL",
                    target = "TARGET_ONE",
                }),
            }),
            [3] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        name = "Heal",
                        power = 107,
                        val = 0,
                    }),
                }),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    castRange = 600,
                    effectRange = 1100,
                    hitTime = 2000,
                    isMagic = true,
                    mpConsume = 25,
                    mpInitialConsume = 7,
                    operateType = "ACTIVE",
                    reuseDelay = 3000,
                    skillType = "HEAL",
                    target = "TARGET_ONE",
                }),
            }),
        }),
        SourceFile = "L2jAdmins_Data/data/xml/stats/skills/1000-1099.xml",
        XmlLevels = 15,
    }),
    [1027] = table.freeze({
        Id = 1027,
        Name = "Group Heal",
        Ranks = table.freeze({
            [1] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        name = "Heal",
                        power = 66,
                        val = 0,
                    }),
                }),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    hitTime = 7000,
                    isMagic = true,
                    mpConsume = 26,
                    mpInitialConsume = 7,
                    operateType = "ACTIVE",
                    reuseDelay = 25000,
                    skillRadius = 1000,
                    skillType = "HEAL",
                    target = "TARGET_PARTY",
                }),
            }),
            [2] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        name = "Heal",
                        power = 76,
                        val = 0,
                    }),
                }),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    hitTime = 7000,
                    isMagic = true,
                    mpConsume = 30,
                    mpInitialConsume = 8,
                    operateType = "ACTIVE",
                    reuseDelay = 25000,
                    skillRadius = 1000,
                    skillType = "HEAL",
                    target = "TARGET_PARTY",
                }),
            }),
            [3] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        name = "Heal",
                        power = 86,
                        val = 0,
                    }),
                }),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    hitTime = 7000,
                    isMagic = true,
                    mpConsume = 34,
                    mpInitialConsume = 9,
                    operateType = "ACTIVE",
                    reuseDelay = 25000,
                    skillRadius = 1000,
                    skillType = "HEAL",
                    target = "TARGET_PARTY",
                }),
            }),
        }),
        SourceFile = "L2jAdmins_Data/data/xml/stats/skills/1000-1099.xml",
        XmlLevels = 15,
    }),
    [1040] = table.freeze({
        Id = 1040,
        Name = "Shield",
        Ranks = table.freeze({
            [1] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        count = 1,
                        Modifiers = table.freeze({
                            table.freeze({
                                Operation = "mul",
                                order = "0x30",
                                stat = "PHYSICAL_DEFENCE",
                                val = 1.08,
                            }),
                        }),
                        name = "Buff",
                        stackOrder = 1.08,
                        stackType = "pDef",
                        time = 1200,
                        val = 0,
                    }),
                }),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "mul",
                        order = "0x30",
                        stat = "PHYSICAL_DEFENCE",
                        val = 1.08,
                    }),
                }),
                Sets = table.freeze({
                    castRange = 400,
                    effectRange = 900,
                    hitTime = 4000,
                    isMagic = true,
                    mpConsume = 8,
                    mpInitialConsume = 2,
                    operateType = "ACTIVE",
                    reuseDelay = 6000,
                    skillType = "BUFF",
                    target = "TARGET_ONE",
                }),
            }),
        }),
        SourceFile = "L2jAdmins_Data/data/xml/stats/skills/1000-1099.xml",
        XmlLevels = 3,
    }),
    [1068] = table.freeze({
        Id = 1068,
        Name = "Might",
        Ranks = table.freeze({
            [1] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        count = 1,
                        Modifiers = table.freeze({
                            table.freeze({
                                Operation = "mul",
                                order = "0x30",
                                stat = "PHYSICAL_ATTACK",
                                val = 1.08,
                            }),
                        }),
                        name = "Buff",
                        stackOrder = 1.08,
                        stackType = "pAtk",
                        time = 1200,
                        val = 0,
                    }),
                }),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "mul",
                        order = "0x30",
                        stat = "PHYSICAL_ATTACK",
                        val = 1.08,
                    }),
                }),
                Sets = table.freeze({
                    castRange = 400,
                    effectRange = 900,
                    hitTime = 4000,
                    isMagic = true,
                    mpConsume = 8,
                    mpInitialConsume = 2,
                    operateType = "ACTIVE",
                    reuseDelay = 6000,
                    skillType = "BUFF",
                    target = "TARGET_ONE",
                }),
            }),
        }),
        SourceFile = "L2jAdmins_Data/data/xml/stats/skills/1000-1099.xml",
        XmlLevels = 3,
    }),
})

return DATA
