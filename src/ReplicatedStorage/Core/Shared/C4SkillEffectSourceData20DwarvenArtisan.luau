--!strict
-- Exact C4 source effects newly required by Dwarven Fighter / Artisan.
-- Source commit: 07f8536384e799f128d44198dd7ab23519660eea

local DATA = table.freeze({
    [25] = table.freeze({
        Id = 25,
        Name = "Summon Mechanic Golem",
        Ranks = table.freeze({
            [1] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    expPenalty = 0.15,
                    hitTime = 15000,
                    isMagic = true,
                    itemConsumeCount = 7,
                    itemConsumeCountOT = 4,
                    itemConsumeId = 1458,
                    itemConsumeIdOT = 1458,
                    itemConsumeSteps = 4,
                    mpConsume = 49,
                    npcId = 12187,
                    operateType = "ACTIVE",
                    reuseDelay = 20000,
                    skillType = "SUMMON",
                    summonTimeLostActive = 1000,
                    summonTimeLostIdle = 500,
                    summonTotalLifeTime = 1200000,
                    target = "TARGET_SELF",
                }),
            }),
        }),
        SourceFile = "L2jAdmins_Data/data/xml/stats/skills/0000-0099.xml",
        XmlLevels = 9,
    }),
    [42] = table.freeze({
        Id = 42,
        Name = "Sweeper",
        Ranks = table.freeze({
            [1] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    castRange = 20,
                    effectRange = 400,
                    hitTime = 500,
                    mpConsume = 3,
                    operateType = "ACTIVE",
                    reuseDelay = 500,
                    skillType = "SWEEP",
                    target = "TARGET_CORPSE_MOB",
                }),
            }),
        }),
        SourceFile = "L2jAdmins_Data/data/xml/stats/skills/0000-0099.xml",
        XmlLevels = 1,
    }),
    [150] = table.freeze({
        Id = 150,
        Name = "Weight Limit",
        Ranks = table.freeze({
            [1] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "mul",
                        order = "0x30",
                        stat = "MAX_LOAD",
                        val = 2,
                    }),
                }),
                Sets = table.freeze({
                    operateType = "PASSIVE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
            [2] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "mul",
                        order = "0x30",
                        stat = "MAX_LOAD",
                        val = 3,
                    }),
                }),
                Sets = table.freeze({
                    operateType = "PASSIVE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
        }),
        SourceFile = "L2jAdmins_Data/data/xml/stats/skills/0100-0199.xml",
        XmlLevels = 3,
    }),
    [172] = table.freeze({
        Id = 172,
        Name = "Create Item",
        Ranks = table.freeze({
            [1] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    operateType = "PASSIVE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
            [2] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    operateType = "PASSIVE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
            [3] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    operateType = "PASSIVE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
        }),
        SourceFile = "L2jAdmins_Data/data/xml/stats/skills/0100-0199.xml",
        XmlLevels = 9,
    }),
    [205] = table.freeze({
        Id = 205,
        Name = "Blunt Mastery",
        Ranks = table.freeze({
            [1] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "add",
                        UsingKind = "Blunt,Big Blunt",
                        order = "0x40",
                        stat = "PHYSICAL_ATTACK",
                        val = 4.5,
                    }),
                }),
                Sets = table.freeze({
                    operateType = "PASSIVE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
            [2] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "add",
                        UsingKind = "Blunt,Big Blunt",
                        order = "0x40",
                        stat = "PHYSICAL_ATTACK",
                        val = 7.3,
                    }),
                }),
                Sets = table.freeze({
                    operateType = "PASSIVE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
            [3] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "add",
                        UsingKind = "Blunt,Big Blunt",
                        order = "0x40",
                        stat = "PHYSICAL_ATTACK",
                        val = 8.9,
                    }),
                }),
                Sets = table.freeze({
                    operateType = "PASSIVE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
            [4] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "add",
                        UsingKind = "Blunt,Big Blunt",
                        order = "0x40",
                        stat = "PHYSICAL_ATTACK",
                        val = 10.7,
                    }),
                }),
                Sets = table.freeze({
                    operateType = "PASSIVE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
        }),
        SourceFile = "L2jAdmins_Data/data/xml/stats/skills/0200-0299.xml",
        XmlLevels = 45,
    }),
    [248] = table.freeze({
        Id = 248,
        Name = "Crystallize",
        Ranks = table.freeze({
            [1] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    operateType = "PASSIVE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
        }),
        SourceFile = "L2jAdmins_Data/data/xml/stats/skills/0200-0299.xml",
        XmlLevels = 5,
    }),
    [254] = table.freeze({
        Id = 254,
        Name = "Spoil",
        Ranks = table.freeze({
            [1] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    castRange = 40,
                    effectPower = 1,
                    effectRange = 400,
                    effectType = "DEBUFF",
                    hitTime = 1800,
                    magicLvl = 10,
                    mpConsume = 12,
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
    [1321] = table.freeze({
        Id = 1321,
        Name = "Dwarven Craft",
        Ranks = table.freeze({
            [1] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    operateType = "ACTIVE",
                    skillType = "DWARVEN_CRAFT",
                    target = "TARGET_SELF",
                }),
            }),
        }),
        SourceFile = "L2jAdmins_Data/data/xml/stats/skills/1300-1399.xml",
        XmlLevels = 1,
    }),
})

return DATA
