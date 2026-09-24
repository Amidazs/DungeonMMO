--!strict
-- Generated factual C4 skill data for the current level-30 source scope.
-- Source: https://github.com/Neco-spain/l2jadmins_C4-Scions-of-Destiny/blob/07f8536384e799f128d44198dd7ab23519660eea/L2jAdmins_Data/data/xml/stats/skills/1200-1299.xml
local DATA = table.freeze({
    [1206] = table.freeze({
        Id = 1206,
        Name = "Wind Shackle",
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
                                stat = "PHYSICAL_ATTACK_SPEED",
                                val = 0.83,
                            }),
                        }),
                        name = "Debuff",
                        stackOrder = 0.83,
                        stackType = "pAtkSpdDown",
                        time = 15,
                        val = 0,
                    }),
                }),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "mul",
                        order = "0x30",
                        stat = "PHYSICAL_ATTACK_SPEED",
                        val = 0.83,
                    }),
                }),
                Sets = table.freeze({
                    castRange = 600,
                    effectPower = 80,
                    effectRange = 1100,
                    effectType = "DEBUFF",
                    hitTime = 1500,
                    isMagic = true,
                    magicLvl = 14,
                    mpConsume = 2,
                    mpInitialConsume = 1,
                    operateType = "ACTIVE",
                    reuseDelay = 8000,
                    saveVs = "WIT",
                    skillType = "DEBUFF",
                    target = "TARGET_ONE",
                }),
            }),
        }),
        SourceFile = "L2jAdmins_Data/data/xml/stats/skills/1200-1299.xml",
        XmlLevels = 19,
    }),
    [1216] = table.freeze({
        Id = 1216,
        Name = "Self Heal",
        Ranks = table.freeze({
            [1] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        name = "Heal",
                        power = 42,
                        val = 0,
                    }),
                }),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    hitTime = 5000,
                    isMagic = true,
                    mpConsume = 7,
                    mpInitialConsume = 2,
                    operateType = "ACTIVE",
                    reuseDelay = 10000,
                    skillType = "HEAL",
                    target = "TARGET_SELF",
                }),
            }),
        }),
        SourceFile = "L2jAdmins_Data/data/xml/stats/skills/1200-1299.xml",
        XmlLevels = 1,
    }),
})

return DATA
