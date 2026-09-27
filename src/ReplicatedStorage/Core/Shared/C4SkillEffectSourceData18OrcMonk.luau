--!strict
-- Exact C4 source effects newly required by Orc Monk through level 30.
-- Source commit: 07f8536384e799f128d44198dd7ab23519660eea

local FIST_CONDITION = table.freeze({
    table.freeze({
        kind = "Fist, Dual Fist",
        Tag = "using",
    }),
})

local EMPTY = table.freeze({})

--[[
Builds one Force Blaster source-rank record.

Args:
    mp_consume (number): Exact source MP cost.
    magic_level (number): Exact source magic level.
    power (number): Exact source physical power.

Returns:
    any: Frozen CHARGEDAM source record.
]]
local function force_blaster_rank(
    mp_consume: number,
    magic_level: number,
    power: number
): any
    return table.freeze({
        Conditions = FIST_CONDITION,
        Effects = EMPTY,
        Modifiers = EMPTY,
        Sets = table.freeze({
            castRange = 600,
            conditionValue = 1,
            effectRange = 1100,
            hitTime = 1900,
            magicLvl = magic_level,
            mpConsume = mp_consume,
            num_charges = 1,
            operateType = "ACTIVE",
            power = power,
            reuseDelay = 15000,
            skillType = "CHARGEDAM",
            target = "TARGET_ONE",
        }),
    })
end

--[[
Builds one Cripple source-rank record.

Args:
    mp_consume (number): Exact source MP cost.
    magic_level (number): Exact source magic level.

Returns:
    any: Frozen WIT-resisted movement-debuff record.
]]
local function cripple_rank(
    mp_consume: number,
    magic_level: number
): any
    return table.freeze({
        Conditions = FIST_CONDITION,
        Effects = table.freeze({
            table.freeze({
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "mul",
                        order = "0x30",
                        stat = "RUN_SPEED",
                        val = 0.7,
                    }),
                }),
                count = 1,
                name = "Debuff",
                stackOrder = 0.7,
                stackType = "RunSpeedDown",
                time = 120,
                val = 0,
            }),
        }),
        Modifiers = EMPTY,
        Sets = table.freeze({
            castRange = 40,
            coolTime = 296,
            effectPower = 80,
            effectRange = 400,
            effectType = "DEBUFF",
            hitTime = 1604,
            magicLvl = magic_level,
            mpConsume = mp_consume,
            operateType = "ACTIVE",
            reuseDelay = 7000,
            saveVs = "WIT",
            skillType = "DEBUFF",
            target = "TARGET_ONE",
        }),
    })
end

--[[
Builds one Stunning Fist source-rank record.

Args:
    mp_consume (number): Exact source MP cost.
    magic_level (number): Exact source magic level.
    power (number): Exact source physical power.

Returns:
    any: Frozen PDAM plus CON-resisted stun record.
]]
local function stunning_fist_rank(
    mp_consume: number,
    magic_level: number,
    power: number
): any
    return table.freeze({
        Conditions = FIST_CONDITION,
        Effects = table.freeze({
            table.freeze({
                Modifiers = EMPTY,
                abnormal = "STUN",
                count = 1,
                name = "Stun",
                stackOrder = 1,
                stackType = "Stun",
                time = 9,
                val = 0,
            }),
        }),
        Modifiers = EMPTY,
        Sets = table.freeze({
            castRange = 40,
            coolTime = 296,
            effectPower = 50,
            effectRange = 400,
            effectType = "STUN",
            hitTime = 1604,
            magicLvl = magic_level,
            mpConsume = mp_consume,
            operateType = "ACTIVE",
            overHit = true,
            power = power,
            reuseDelay = 13000,
            saveVs = "CON",
            skillType = "PDAM",
            target = "TARGET_ONE",
        }),
    })
end

--[[
Builds one Fist Mastery source-rank record.

Args:
    physical_attack (number): Exact additive source P.Atk bonus.

Returns:
    any: Frozen fist-conditional passive record.
]]
local function fist_mastery_rank(
    physical_attack: number
): any
    return table.freeze({
        Conditions = EMPTY,
        Effects = EMPTY,
        Modifiers = table.freeze({
            table.freeze({
                Operation = "add",
                UsingKind = "Fist, Dual Fist",
                order = "0x40",
                stat = "PHYSICAL_ATTACK",
                val = physical_attack,
            }),
        }),
        Sets = table.freeze({
            operateType = "PASSIVE",
            skillType = "DUMMY",
            target = "TARGET_SELF",
        }),
    })
end

local DATA = table.freeze({
    [50] = table.freeze({
        Id = 50,
        Name = "Focus Force",
        Ranks = table.freeze({
            [1] = table.freeze({
                Conditions = FIST_CONDITION,
                Effects = EMPTY,
                Modifiers = EMPTY,
                Sets = table.freeze({
                    hitTime = 900,
                    maxCharges = 1,
                    mpConsume = 7,
                    operateType = "ACTIVE",
                    reuseDelay = 1000,
                    skillType = "CHARGE",
                    target = "TARGET_SELF",
                }),
            }),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/0000-0099.xml",
        XmlLevels = 7,
    }),
    [54] = table.freeze({
        Id = 54,
        Name = "Force Blaster",
        Ranks = table.freeze({
            [1] = force_blaster_rank(19, 22, 143),
            [2] = force_blaster_rank(20, 23, 154),
            [3] = force_blaster_rank(21, 24, 166),
            [4] = force_blaster_rank(22, 26, 193),
            [5] = force_blaster_rank(23, 27, 207),
            [6] = force_blaster_rank(24, 28, 222),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/0000-0099.xml",
        XmlLevels = 49,
    }),
    [76] = table.freeze({
        Id = 76,
        Name = "Totem Spirit Bear",
        Ranks = table.freeze({
            [1] = table.freeze({
                Conditions = EMPTY,
                Effects = table.freeze({
                    table.freeze({
                        Modifiers = table.freeze({
                            table.freeze({
                                Operation = "mul",
                                order = "0x30",
                                stat = "RUN_SPEED",
                                val = 0.7,
                            }),
                            table.freeze({
                                Operation = "mul",
                                order = "0x30",
                                stat = "PHYSICAL_ATTACK",
                                val = 1.2,
                            }),
                        }),
                        count = 1,
                        name = "Buff",
                        stackOrder = 1,
                        stackType = "possession",
                        time = 120,
                        val = 0,
                    }),
                }),
                Modifiers = EMPTY,
                Sets = table.freeze({
                    hitTime = 1500,
                    mpConsume = 2,
                    operateType = "ACTIVE",
                    reuseDelay = 120000,
                    skillType = "BUFF",
                    target = "TARGET_SELF",
                }),
            }),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/0000-0099.xml",
        XmlLevels = 1,
    }),
    [83] = table.freeze({
        Id = 83,
        Name = "Totem Spirit Wolf",
        Ranks = table.freeze({
            [1] = table.freeze({
                Conditions = EMPTY,
                Effects = table.freeze({
                    table.freeze({
                        Modifiers = table.freeze({
                            table.freeze({
                                Operation = "mul",
                                order = "0x40",
                                stat = "RUN_SPEED",
                                val = 1.15,
                            }),
                        }),
                        count = 1,
                        name = "Buff",
                        stackOrder = 1,
                        stackType = "possession",
                        time = 120,
                        val = 0,
                    }),
                }),
                Modifiers = EMPTY,
                Sets = table.freeze({
                    hitTime = 1500,
                    mpConsume = 2,
                    operateType = "ACTIVE",
                    reuseDelay = 120000,
                    skillType = "BUFF",
                    target = "TARGET_SELF",
                }),
            }),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/0000-0099.xml",
        XmlLevels = 1,
    }),
    [95] = table.freeze({
        Id = 95,
        Name = "Cripple",
        Ranks = table.freeze({
            [1] = cripple_rank(19, 20),
            [2] = cripple_rank(22, 24),
            [3] = cripple_rank(25, 28),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/0000-0099.xml",
        XmlLevels = 20,
    }),
    [120] = table.freeze({
        Id = 120,
        Name = "Stunning Fist",
        Ranks = table.freeze({
            [1] = stunning_fist_rank(22, 18, 38),
            [2] = stunning_fist_rank(22, 19, 41),
            [3] = stunning_fist_rank(22, 20, 44),
            [4] = stunning_fist_rank(23, 22, 51),
            [5] = stunning_fist_rank(24, 23, 55),
            [6] = stunning_fist_rank(25, 24, 60),
            [7] = stunning_fist_rank(27, 26, 69),
            [8] = stunning_fist_rank(29, 27, 74),
            [9] = stunning_fist_rank(30, 28, 80),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/0100-0199.xml",
        XmlLevels = 15,
    }),
    [210] = table.freeze({
        Id = 210,
        Name = "Fist Mastery",
        Ranks = table.freeze({
            [1] = fist_mastery_rank(4.5),
            [2] = fist_mastery_rank(7.3),
            [3] = fist_mastery_rank(8.9),
            [4] = fist_mastery_rank(10.7),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/0200-0299.xml",
        XmlLevels = 45,
    }),
    [319] = table.freeze({
        Id = 319,
        Name = "Agile Movement",
        Ranks = table.freeze({
            [1] = table.freeze({
                Conditions = EMPTY,
                Effects = EMPTY,
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "add",
                        UsingKind = "Light",
                        order = "0x40",
                        stat = "RUN_SPEED",
                        val = 5,
                    }),
                    table.freeze({
                        Operation = "add",
                        UsingKind = "Light",
                        order = "0x40",
                        stat = "ACCURACY_COMBAT",
                        val = 2,
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
            "L2jAdmins_Data/data/xml/stats/skills/0300-0399.xml",
        XmlLevels = 2,
    }),
})

return DATA
