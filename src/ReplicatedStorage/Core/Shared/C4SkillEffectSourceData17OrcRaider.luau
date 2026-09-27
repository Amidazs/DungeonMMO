--!strict
-- Exact C4 source effects newly required by Orc Raider.
-- Source commit: 07f8536384e799f128d44198dd7ab23519660eea

local DATA = table.freeze({
    [34] = table.freeze({
        Id = 34,
        Name = "Bandage",
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
                    effectPower = 30,
                    hitTime = 1500,
                    magicLvl = 20,
                    mpConsume = 20,
                    negateStats = "BLEED",
                    operateType = "ACTIVE",
                    reuseDelay = 3000,
                    skillType = "BUFF",
                    target = "TARGET_SELF",
                }),
            }),
            [2] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        name = "NegateEffect",
                        val = 0,
                    }),
                }),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    effectPower = 70,
                    hitTime = 1500,
                    magicLvl = 46,
                    mpConsume = 35,
                    negateStats = "BLEED",
                    operateType = "ACTIVE",
                    reuseDelay = 3000,
                    skillType = "BUFF",
                    target = "TARGET_SELF",
                }),
            }),
            [3] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        name = "NegateEffect",
                        val = 0,
                    }),
                }),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    effectPower = 90,
                    hitTime = 1500,
                    magicLvl = 62,
                    mpConsume = 55,
                    negateStats = "BLEED",
                    operateType = "ACTIVE",
                    reuseDelay = 3000,
                    skillType = "BUFF",
                    target = "TARGET_SELF",
                }),
            }),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/0000-0099.xml",
        XmlLevels = 3,
    }),
    [94] = table.freeze({
        Id = 94,
        Name = "Rage",
        Ranks = table.freeze({
            [1] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        Modifiers = table.freeze({
                            table.freeze({
                                Operation = "mul",
                                order = "0x30",
                                stat = "PHYSICAL_ATTACK",
                                val = 1.45,
                            }),
                            table.freeze({
                                Operation = "mul",
                                order = "0x30",
                                stat = "PHYSICAL_DEFENCE",
                                val = 0.8,
                            }),
                            table.freeze({
                                Operation = "sub",
                                order = "0x40",
                                stat = "EVASION_RATE",
                                val = 3,
                            }),
                        }),
                        count = 1,
                        name = "Buff",
                        stackOrder = 1,
                        stackType = "pAtks",
                        time = 60,
                        val = 0,
                    }),
                }),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    hitTime = 1500,
                    mpConsume = 11,
                    operateType = "ACTIVE",
                    reuseDelay = 300000,
                    skillType = "BUFF",
                    target = "TARGET_SELF",
                }),
            }),
            [2] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({
                    table.freeze({
                        Modifiers = table.freeze({
                            table.freeze({
                                Operation = "mul",
                                order = "0x30",
                                stat = "PHYSICAL_ATTACK",
                                val = 1.55,
                            }),
                            table.freeze({
                                Operation = "mul",
                                order = "0x30",
                                stat = "PHYSICAL_DEFENCE",
                                val = 0.8,
                            }),
                            table.freeze({
                                Operation = "sub",
                                order = "0x40",
                                stat = "EVASION_RATE",
                                val = 3,
                            }),
                        }),
                        count = 1,
                        name = "Buff",
                        stackOrder = 2,
                        stackType = "pAtks",
                        time = 60,
                        val = 0,
                    }),
                }),
                Modifiers = table.freeze({}),
                Sets = table.freeze({
                    hitTime = 1500,
                    mpConsume = 25,
                    operateType = "ACTIVE",
                    reuseDelay = 300000,
                    skillType = "BUFF",
                    target = "TARGET_SELF",
                }),
            }),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/0000-0099.xml",
        XmlLevels = 2,
    }),
    [293] = table.freeze({
        Id = 293,
        Name = "Two-handed Weapon Mastery",
        Ranks = table.freeze({
            [1] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "PHYSICAL_ATTACK",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 4.5,
                    }),
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "ACCURACY_COMBAT",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 3,
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
                        order = "0x40",
                        stat = "PHYSICAL_ATTACK",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 7.3,
                    }),
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "ACCURACY_COMBAT",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 3,
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
                        order = "0x40",
                        stat = "PHYSICAL_ATTACK",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 10.7,
                    }),
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "ACCURACY_COMBAT",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 3,
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
                        order = "0x40",
                        stat = "PHYSICAL_ATTACK",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 15.1,
                    }),
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "ACCURACY_COMBAT",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 3,
                    }),
                }),
                Sets = table.freeze({
                    operateType = "PASSIVE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
            [5] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "PHYSICAL_ATTACK",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 20.5,
                    }),
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "ACCURACY_COMBAT",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 3,
                    }),
                }),
                Sets = table.freeze({
                    operateType = "PASSIVE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
            [6] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "PHYSICAL_ATTACK",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 27.1,
                    }),
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "ACCURACY_COMBAT",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 3,
                    }),
                }),
                Sets = table.freeze({
                    operateType = "PASSIVE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
            [7] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "PHYSICAL_ATTACK",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 32.9,
                    }),
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "ACCURACY_COMBAT",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 3,
                    }),
                }),
                Sets = table.freeze({
                    operateType = "PASSIVE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
            [8] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "PHYSICAL_ATTACK",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 39.4,
                    }),
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "ACCURACY_COMBAT",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 3,
                    }),
                }),
                Sets = table.freeze({
                    operateType = "PASSIVE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
            [9] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "PHYSICAL_ATTACK",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 46.6,
                    }),
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "ACCURACY_COMBAT",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 3,
                    }),
                }),
                Sets = table.freeze({
                    operateType = "PASSIVE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
            [10] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "PHYSICAL_ATTACK",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 54.6,
                    }),
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "ACCURACY_COMBAT",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 3,
                    }),
                }),
                Sets = table.freeze({
                    operateType = "PASSIVE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
            [11] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "PHYSICAL_ATTACK",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 63.3,
                    }),
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "ACCURACY_COMBAT",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 3,
                    }),
                }),
                Sets = table.freeze({
                    operateType = "PASSIVE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
            [12] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "PHYSICAL_ATTACK",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 72.7,
                    }),
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "ACCURACY_COMBAT",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 3,
                    }),
                }),
                Sets = table.freeze({
                    operateType = "PASSIVE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
            [13] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "PHYSICAL_ATTACK",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 79.3,
                    }),
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "ACCURACY_COMBAT",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 3,
                    }),
                }),
                Sets = table.freeze({
                    operateType = "PASSIVE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
            [14] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "PHYSICAL_ATTACK",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 86.6,
                    }),
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "ACCURACY_COMBAT",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 3,
                    }),
                }),
                Sets = table.freeze({
                    operateType = "PASSIVE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
            [15] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "PHYSICAL_ATTACK",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 93.1,
                    }),
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "ACCURACY_COMBAT",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 3,
                    }),
                }),
                Sets = table.freeze({
                    operateType = "PASSIVE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
            [16] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "PHYSICAL_ATTACK",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 100.2,
                    }),
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "ACCURACY_COMBAT",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 3,
                    }),
                }),
                Sets = table.freeze({
                    operateType = "PASSIVE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
            [17] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "PHYSICAL_ATTACK",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 107.5,
                    }),
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "ACCURACY_COMBAT",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 3,
                    }),
                }),
                Sets = table.freeze({
                    operateType = "PASSIVE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
            [18] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "PHYSICAL_ATTACK",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 114.8,
                    }),
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "ACCURACY_COMBAT",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 3,
                    }),
                }),
                Sets = table.freeze({
                    operateType = "PASSIVE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
            [19] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "PHYSICAL_ATTACK",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 122.1,
                    }),
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "ACCURACY_COMBAT",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 3,
                    }),
                }),
                Sets = table.freeze({
                    operateType = "PASSIVE",
                    skillType = "DUMMY",
                    target = "TARGET_SELF",
                }),
            }),
            [20] = table.freeze({
                Conditions = table.freeze({}),
                Effects = table.freeze({}),
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "PHYSICAL_ATTACK",
                        UsingKind = "Big Sword,Big Blunt",
                        val = 129.3,
                    }),
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "ACCURACY_COMBAT",
                        UsingKind = "Big Sword,Big Blunt",
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
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/0200-0299.xml",
        XmlLevels = 20,
    }),
})

return DATA
