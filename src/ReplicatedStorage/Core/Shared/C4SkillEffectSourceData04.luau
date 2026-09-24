--!strict
-- Generated factual C4 skill data for the current level-30 source scope.
-- Source: https://github.com/Neco-spain/l2jadmins_C4-Scions-of-Destiny/blob/07f8536384e799f128d44198dd7ab23519660eea/L2jAdmins_Data/data/xml/stats/skills/0300-0399.xml
local DATA = table.freeze({
    [312] = table.freeze({
        Id = 312,
        Name = "Vicious Stance",
        Ranks = table.freeze({
            [1] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        count = "0x7fffffff",
                        Modifiers = table.freeze({
                            table.freeze({
                                Operation = "add",
                                order = "0x40",
                                stat = "PHYSICAL_CRITICAL_POWER_ADD",
                                val = 35,
                            }),
                        }),
                        name = "MpConsumePerLevel",
                        time = 3,
                        val = 0.4,
                    }),
                }),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "PHYSICAL_CRITICAL_POWER_ADD",
                        val = 35,
                    }),
                }),
                Sets = table.freeze({
                    mpInitialConsume = 4,
                    operateType = "TOGGLE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
            [2] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        count = "0x7fffffff",
                        Modifiers = table.freeze({
                            table.freeze({
                                Operation = "add",
                                order = "0x40",
                                stat = "PHYSICAL_CRITICAL_POWER_ADD",
                                val = 48,
                            }),
                        }),
                        name = "MpConsumePerLevel",
                        time = 3,
                        val = 0.4,
                    }),
                }),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "PHYSICAL_CRITICAL_POWER_ADD",
                        val = 48,
                    }),
                }),
                Sets = table.freeze({
                    mpInitialConsume = 5,
                    operateType = "TOGGLE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
            [3] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        count = "0x7fffffff",
                        Modifiers = table.freeze({
                            table.freeze({
                                Operation = "add",
                                order = "0x40",
                                stat = "PHYSICAL_CRITICAL_POWER_ADD",
                                val = 64,
                            }),
                        }),
                        name = "MpConsumePerLevel",
                        time = 3,
                        val = 0.4,
                    }),
                }),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "PHYSICAL_CRITICAL_POWER_ADD",
                        val = 64,
                    }),
                }),
                Sets = table.freeze({
                    mpInitialConsume = 5,
                    operateType = "TOGGLE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
        }),
        SourceFile = "L2jAdmins_Data/data/xml/stats/skills/0300-0399.xml",
        XmlLevels = 20,
    }),
})

return DATA
