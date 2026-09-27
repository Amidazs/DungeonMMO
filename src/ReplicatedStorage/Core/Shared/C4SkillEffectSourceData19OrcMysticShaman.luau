--!strict
-- Exact C4 source effects required by Orc Mystic and Orc Shaman.
-- Source commit: 07f8536384e799f128d44198dd7ab23519660eea

local EMPTY = table.freeze({})

--[[
Builds one Orc caster weapon-mastery passive rank.

Args:
    physical_attack (number): Exact additive P.Atk source value.
    magical_attack (number): Exact additive M.Atk source value.

Returns:
    any: Frozen source passive rank.
]]
local function weapon_mastery_rank(
    physical_attack: number,
    magical_attack: number
): any
    return table.freeze({
        Conditions = EMPTY,
        Effects = EMPTY,
        Modifiers = table.freeze({
            table.freeze({
                Operation = "add",
                order = "0x40",
                stat = "PHYSICAL_ATTACK",
                val = physical_attack,
            }),
            table.freeze({
                Operation = "add",
                order = "0x40",
                stat = "MAGICAL_ATTACK",
                val = magical_attack,
            }),
            table.freeze({
                Operation = "mul",
                order = "0x30",
                stat = "PHYSICAL_ATTACK",
                val = 1.45,
            }),
            table.freeze({
                Operation = "mul",
                order = "0x30",
                stat = "MAGICAL_ATTACK",
                val = 1.17,
            }),
        }),
        Sets = table.freeze({
            operateType = "PASSIVE",
            skillType = "DUMMY",
            target = "TARGET_SELF",
        }),
    })
end

--[[
Builds one armour-mastery passive rank.

Args:
    physical_defence (number): Exact additive P.Def source value.
    armour_kind (string): Exact source equipment condition.
    magic_speed (number?): Optional exact M.Atk Speed multiplier.
    attack_speed (number?): Optional exact P.Atk Speed multiplier.
    mp_regen (number?): Optional exact MP regeneration multiplier.

Returns:
    any: Frozen source passive rank.
]]
local function armour_mastery_rank(
    physical_defence: number,
    armour_kind: string,
    magic_speed: number?,
    attack_speed: number?,
    mp_regen: number?
): any
    local modifiers = {
        table.freeze({
            Operation = "add",
            UsingKind = armour_kind,
            order = "0x40",
            stat = "PHYSICAL_DEFENCE",
            val = physical_defence,
        }),
    }

    if magic_speed then
        table.insert(modifiers, table.freeze({
            Operation = "mul",
            UsingKind = armour_kind,
            order = "0x30",
            stat = "MAGICAL_ATTACK_SPEED",
            val = magic_speed,
        }))
    end
    if attack_speed then
        table.insert(modifiers, table.freeze({
            Operation = "mul",
            UsingKind = armour_kind,
            order = "0x30",
            stat = "PHYSICAL_ATTACK_SPEED",
            val = attack_speed,
        }))
    end
    if mp_regen then
        table.insert(modifiers, table.freeze({
            Operation = "mul",
            UsingKind = armour_kind,
            order = "0x30",
            stat = "REG_MP_RATE",
            val = mp_regen,
        }))
    end

    return table.freeze({
        Conditions = EMPTY,
        Effects = EMPTY,
        Modifiers = table.freeze(modifiers),
        Sets = table.freeze({
            operateType = "PASSIVE",
            skillType = "DUMMY",
            target = "TARGET_SELF",
        }),
    })
end

--[[
Builds one Soul Cry toggle rank.

Args:
    physical_attack (number): Exact additive P.Atk source value.
    mana_drain (number): Exact periodic MP drain.
    initial_mana (number): Exact initial MP cost.

Returns:
    any: Frozen source toggle rank.
]]
local function soul_cry_rank(
    physical_attack: number,
    mana_drain: number,
    initial_mana: number
): any
    return table.freeze({
        Conditions = EMPTY,
        Effects = table.freeze({
            table.freeze({
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "add",
                        order = "0x40",
                        stat = "PHYSICAL_ATTACK",
                        val = physical_attack,
                    }),
                }),
                count = 0x7fffffff,
                name = "ManaDamOverTime",
                time = 3,
                val = mana_drain,
            }),
        }),
        Modifiers = EMPTY,
        Sets = table.freeze({
            mpInitialConsume = initial_mana,
            operateType = "TOGGLE",
            skillType = "DUMMY",
            target = "TARGET_SELF",
        }),
    })
end

--[[
Builds one standard C4 buff rank.

Args:
    config (any): Exact source sets and one stat multiplier.

Returns:
    any: Frozen source buff rank.
]]
local function buff_rank(config: any): any
    local sets = {
        hitTime = config.hitTime or 2500,
        isMagic = true,
        mpConsume = config.mpConsume,
        mpInitialConsume = config.mpInitialConsume,
        operateType = "ACTIVE",
        reuseDelay = config.reuseDelay or 20000,
        skillType = "BUFF",
        target = config.target,
    }

    if config.skillRadius then
        sets.skillRadius = config.skillRadius
    end
    if config.castRange then
        sets.castRange = config.castRange
    end
    if config.effectRange then
        sets.effectRange = config.effectRange
    end

    return table.freeze({
        Conditions = EMPTY,
        Effects = table.freeze({
            table.freeze({
                Modifiers = table.freeze({
                    table.freeze({
                        Operation = "mul",
                        order = "0x30",
                        stat = config.stat,
                        val = config.multiplier,
                    }),
                }),
                count = 1,
                name = "Buff",
                stackOrder = config.multiplier,
                stackType = config.stackType,
                time = 1200,
                val = 0,
            }),
        }),
        Modifiers = EMPTY,
        Sets = table.freeze(sets),
    })
end

--[[
Builds one Life Drain source rank.

Args:
    initial_mana (number): Exact initial MP cost.
    mana (number): Exact ongoing MP cost.
    magic_level (number): Exact source magic level.
    power (number): Exact source magic power.

Returns:
    any: Frozen source drain rank.
]]
local function life_drain_rank(
    initial_mana: number,
    mana: number,
    magic_level: number,
    power: number
): any
    return table.freeze({
        Conditions = EMPTY,
        Effects = EMPTY,
        Modifiers = EMPTY,
        Sets = table.freeze({
            absorbPart = 0.8,
            castRange = 600,
            effectRange = 1100,
            element = "DARK",
            hitTime = 4000,
            isMagic = true,
            magicLvl = magic_level,
            mpConsume = mana,
            mpInitialConsume = initial_mana,
            operateType = "ACTIVE",
            power = power,
            reuseDelay = 6000,
            skillType = "DRAIN",
            target = "TARGET_ONE",
        }),
    })
end

--[[
Builds one standard resisted control/debuff rank.

Args:
    config (any): Exact source targeting, resistance and effect fields.

Returns:
    any: Frozen source control/debuff rank.
]]
local function control_rank(config: any): any
    local sets = {
        effectPower = config.effectPower,
        effectType = config.effectType,
        hitTime = config.hitTime or 4000,
        isMagic = true,
        magicLvl = config.magicLvl,
        mpConsume = config.mpConsume,
        mpInitialConsume = config.mpInitialConsume,
        operateType = "ACTIVE",
        reuseDelay = config.reuseDelay,
        skillType = "DEBUFF",
        target = config.target,
    }

    if config.castRange then
        sets.castRange = config.castRange
    end
    if config.effectRange then
        sets.effectRange = config.effectRange
    end
    if config.skillRadius then
        sets.skillRadius = config.skillRadius
    end
    if config.saveVs then
        sets.saveVs = config.saveVs
    end
    if config.element then
        sets.element = config.element
    end

    return table.freeze({
        Conditions = EMPTY,
        Effects = table.freeze({
            table.freeze({
                Modifiers = config.modifiers or EMPTY,
                abnormal = config.abnormal,
                count = config.count,
                name = config.effectName,
                stackOrder = config.stackOrder,
                stackType = config.stackType,
                time = config.time,
                val = config.val or 0,
            }),
        }),
        Modifiers = EMPTY,
        Sets = table.freeze(sets),
    })
end

--[[
Builds one Chant of Life source rank.

Args:
    initial_mana (number): Exact initial MP cost.
    mana (number): Exact ongoing MP cost.
    magic_level (number): Exact source magic level.
    healing (number): Exact heal-over-time value.

Returns:
    any: Frozen source party HoT rank.
]]
local function life_chant_rank(
    initial_mana: number,
    mana: number,
    magic_level: number,
    healing: number
): any
    return table.freeze({
        Conditions = EMPTY,
        Effects = table.freeze({
            table.freeze({
                Modifiers = EMPTY,
                count = 15,
                name = "HealOverTime",
                stackOrder = healing,
                stackType = "HpRecover",
                time = 1,
                val = healing,
            }),
        }),
        Modifiers = EMPTY,
        Sets = table.freeze({
            hitTime = 7000,
            isMagic = true,
            magicLvl = magic_level,
            mpConsume = mana,
            mpInitialConsume = initial_mana,
            operateType = "ACTIVE",
            reuseDelay = 20000,
            skillRadius = 1000,
            skillType = "BUFF",
            target = "TARGET_PARTY",
        }),
    })
end

local DATA = table.freeze({
    [250] = table.freeze({
        Id = 250,
        Name = "Weapon Mastery",
        Ranks = table.freeze({
            [1] = weapon_mastery_rank(1.5, 1.9),
            [2] = weapon_mastery_rank(2.8, 3.5),
            [3] = weapon_mastery_rank(4.5, 5.7),
            [4] = weapon_mastery_rank(5.7, 7.2),
            [5] = weapon_mastery_rank(6.7, 8.3),
            [6] = weapon_mastery_rank(8.3, 10.3),
            [7] = weapon_mastery_rank(9.5, 11.9),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/0200-0299.xml",
        XmlLevels = 42,
    }),
    [251] = table.freeze({
        Id = 251,
        Name = "Robe Mastery",
        Ranks = table.freeze({
            [1] = armour_mastery_rank(11.6, "Magic", nil, nil, nil),
            [2] = armour_mastery_rank(13.4, "Magic", nil, nil, nil),
            [3] = armour_mastery_rank(16.1, "Magic", nil, nil, nil),
            [4] = armour_mastery_rank(18.4, "Magic", nil, nil, nil),
            [5] = armour_mastery_rank(20.9, "Magic", nil, nil, nil),
            [6] = armour_mastery_rank(23.8, "Magic", nil, nil, nil),
            [7] = armour_mastery_rank(26.9, "Magic", nil, nil, nil),
            [8] = armour_mastery_rank(29.1, "Magic", nil, nil, nil),
            [9] = armour_mastery_rank(32.8, "Magic", nil, nil, nil),
            [10] = armour_mastery_rank(35.4, "Magic", nil, nil, nil),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/0200-0299.xml",
        XmlLevels = 45,
    }),
    [252] = table.freeze({
        Id = 252,
        Name = "Light Armor Mastery",
        Ranks = table.freeze({
            [1] = armour_mastery_rank(12.6, "Light", 1.9, 1.25, 1.2),
            [2] = armour_mastery_rank(14.5, "Light", 1.9, 1.25, 1.2),
            [3] = armour_mastery_rank(17.5, "Light", 1.9, 1.25, 1.2),
            [4] = armour_mastery_rank(19.3, "Light", 1.9, 1.25, 1.2),
            [5] = armour_mastery_rank(21.2, "Light", 1.9, 1.25, 1.2),
            [6] = armour_mastery_rank(23.2, "Light", 1.9, 1.25, 1.2),
            [7] = armour_mastery_rank(25.5, "Light", 1.9, 1.25, 1.2),
            [8] = armour_mastery_rank(27.0, "Light", 1.9, 1.25, 1.2),
            [9] = armour_mastery_rank(30.1, "Light", 1.9, 1.25, 1.2),
            [10] = armour_mastery_rank(32.5, "Light", 1.9, 1.25, 1.2),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/0200-0299.xml",
        XmlLevels = 45,
    }),
    [253] = table.freeze({
        Id = 253,
        Name = "Heavy Armor Mastery",
        Ranks = table.freeze({
            [1] = armour_mastery_rank(11.6, "Heavy", 1.71, 1.25, nil),
            [2] = armour_mastery_rank(13.3, "Heavy", 1.71, 1.25, nil),
            [3] = armour_mastery_rank(15.2, "Heavy", 1.71, 1.25, nil),
            [4] = armour_mastery_rank(17.2, "Heavy", 1.71, 1.25, nil),
            [5] = armour_mastery_rank(19.5, "Heavy", 1.71, 1.25, nil),
            [6] = armour_mastery_rank(21.1, "Heavy", 1.71, 1.25, nil),
            [7] = armour_mastery_rank(23.7, "Heavy", 1.71, 1.25, nil),
            [8] = armour_mastery_rank(25.6, "Heavy", 1.71, 1.25, nil),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/0200-0299.xml",
        XmlLevels = 43,
    }),
    [1001] = table.freeze({
        Id = 1001,
        Name = "Soul Cry",
        Ranks = table.freeze({
            [1] = soul_cry_rank(4.5, 3, 2),
            [2] = soul_cry_rank(14, 6, 3),
            [3] = soul_cry_rank(33.5, 9, 5),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/1000-1099.xml",
        XmlLevels = 10,
    }),
    [1002] = table.freeze({
        Id = 1002,
        Name = "Chant of Flame",
        Ranks = table.freeze({
            [1] = buff_rank({
                mpInitialConsume = 21,
                mpConsume = 84,
                target = "TARGET_PARTY",
                skillRadius = 1000,
                stat = "MAGICAL_ATTACK_SPEED",
                multiplier = 1.15,
                stackType = "mAtkSpeedUp",
            }),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/1000-1099.xml",
        XmlLevels = 3,
    }),
    [1003] = table.freeze({
        Id = 1003,
        Name = "Power of Paagrio",
        Ranks = table.freeze({
            [1] = buff_rank({
                mpInitialConsume = 21,
                mpConsume = 84,
                target = "TARGET_ALLY",
                skillRadius = 400,
                stat = "PHYSICAL_ATTACK",
                multiplier = 1.08,
                stackType = "pAtk",
            }),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/1000-1099.xml",
        XmlLevels = 3,
    }),
    [1006] = table.freeze({
        Id = 1006,
        Name = "Chant of Fire",
        Ranks = table.freeze({
            [1] = buff_rank({
                mpInitialConsume = 16,
                mpConsume = 61,
                target = "TARGET_PARTY",
                skillRadius = 1000,
                stat = "MAGICAL_DEFENCE",
                multiplier = 1.15,
                stackType = "MagicDefUp",
            }),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/1000-1099.xml",
        XmlLevels = 3,
    }),
    [1007] = table.freeze({
        Id = 1007,
        Name = "Chant of Battle",
        Ranks = table.freeze({
            [1] = buff_rank({
                mpInitialConsume = 12,
                mpConsume = 48,
                target = "TARGET_PARTY",
                skillRadius = 1000,
                stat = "PHYSICAL_ATTACK",
                multiplier = 1.08,
                stackType = "pAtk",
            }),
            [2] = buff_rank({
                mpInitialConsume = 18,
                mpConsume = 70,
                target = "TARGET_PARTY",
                skillRadius = 1000,
                stat = "PHYSICAL_ATTACK",
                multiplier = 1.12,
                stackType = "pAtk",
            }),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/1000-1099.xml",
        XmlLevels = 3,
    }),
    [1009] = table.freeze({
        Id = 1009,
        Name = "Chant of Shielding",
        Ranks = table.freeze({
            [1] = buff_rank({
                mpInitialConsume = 16,
                mpConsume = 61,
                target = "TARGET_PARTY",
                skillRadius = 1000,
                stat = "PHYSICAL_DEFENCE",
                multiplier = 1.08,
                stackType = "pDef",
            }),
            [2] = buff_rank({
                mpInitialConsume = 21,
                mpConsume = 84,
                target = "TARGET_PARTY",
                skillRadius = 1000,
                stat = "PHYSICAL_DEFENCE",
                multiplier = 1.12,
                stackType = "pDef",
            }),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/1000-1099.xml",
        XmlLevels = 3,
    }),
    [1010] = table.freeze({
        Id = 1010,
        Name = "Soul Shield",
        Ranks = table.freeze({
            [1] = buff_rank({
                mpInitialConsume = 2,
                mpConsume = 8,
                target = "TARGET_ONE",
                castRange = 400,
                effectRange = 900,
                reuseDelay = 5000,
                stat = "PHYSICAL_DEFENCE",
                multiplier = 1.08,
                stackType = "pDef",
            }),
            [2] = buff_rank({
                mpInitialConsume = 5,
                mpConsume = 18,
                target = "TARGET_ONE",
                castRange = 400,
                effectRange = 900,
                reuseDelay = 5000,
                stat = "PHYSICAL_DEFENCE",
                multiplier = 1.12,
                stackType = "pDef",
            }),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/1000-1099.xml",
        XmlLevels = 3,
    }),
    [1090] = table.freeze({
        Id = 1090,
        Name = "Life Drain",
        Ranks = table.freeze({
            [1] = life_drain_rank(4, 16, 7, 15),
            [2] = life_drain_rank(6, 24, 14, 21),
            [3] = life_drain_rank(8, 31, 20, 26),
            [4] = life_drain_rank(9, 35, 25, 32),
            [5] = life_drain_rank(11, 42, 30, 38),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/1000-1099.xml",
        XmlLevels = 6,
    }),
    [1092] = table.freeze({
        Id = 1092,
        Name = "Fear",
        Ranks = table.freeze({
            [1] = control_rank({
                mpInitialConsume = 3, mpConsume = 12,
                magicLvl = 14, target = "TARGET_ONE",
                castRange = 600, effectRange = 1100,
                reuseDelay = 20000, effectPower = 80,
                effectType = "FEAR", saveVs = "MEN",
                effectName = "Fear", count = 5, time = 4,
                abnormal = "AFRAID",
            }),
            [2] = control_rank({
                mpInitialConsume = 4, mpConsume = 16,
                magicLvl = 20, target = "TARGET_ONE",
                castRange = 600, effectRange = 1100,
                reuseDelay = 20000, effectPower = 80,
                effectType = "FEAR", saveVs = "MEN",
                effectName = "Fear", count = 5, time = 4,
                abnormal = "AFRAID",
            }),
            [3] = control_rank({
                mpInitialConsume = 5, mpConsume = 18,
                magicLvl = 25, target = "TARGET_ONE",
                castRange = 600, effectRange = 1100,
                reuseDelay = 20000, effectPower = 80,
                effectType = "FEAR", saveVs = "MEN",
                effectName = "Fear", count = 5, time = 4,
                abnormal = "AFRAID",
            }),
            [4] = control_rank({
                mpInitialConsume = 6, mpConsume = 21,
                magicLvl = 30, target = "TARGET_ONE",
                castRange = 600, effectRange = 1100,
                reuseDelay = 20000, effectPower = 80,
                effectType = "FEAR", saveVs = "MEN",
                effectName = "Fear", count = 5, time = 4,
                abnormal = "AFRAID",
            }),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/1000-1099.xml",
        XmlLevels = 19,
    }),
    [1095] = table.freeze({
        Id = 1095,
        Name = "Venom",
        Ranks = table.freeze({
            [1] = control_rank({
                mpInitialConsume = 2, mpConsume = 8,
                magicLvl = 7, target = "TARGET_ONE",
                castRange = 600, effectRange = 1100,
                reuseDelay = 12000, effectPower = 70,
                effectType = "POISON", saveVs = "MEN",
                effectName = "Poison", count = 10, time = 3,
                abnormal = "POISON", val = 8,
            }),
            [2] = control_rank({
                mpInitialConsume = 3, mpConsume = 12,
                magicLvl = 14, target = "TARGET_ONE",
                castRange = 600, effectRange = 1100,
                reuseDelay = 12000, effectPower = 70,
                effectType = "POISON", saveVs = "MEN",
                effectName = "Poison", count = 10, time = 3,
                abnormal = "POISON", val = 12,
            }),
            [3] = control_rank({
                mpInitialConsume = 4, mpConsume = 16,
                magicLvl = 20, target = "TARGET_ONE",
                castRange = 600, effectRange = 1100,
                reuseDelay = 12000, effectPower = 70,
                effectType = "POISON", saveVs = "MEN",
                effectName = "Poison", count = 10, time = 3,
                abnormal = "POISON", val = 18,
            }),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/1000-1099.xml",
        XmlLevels = 5,
    }),
    [1096] = table.freeze({
        Id = 1096,
        Name = "Seal of Chaos",
        Ranks = table.freeze({
            [1] = control_rank({
                mpInitialConsume = 4, mpConsume = 16,
                magicLvl = 30, target = "TARGET_AURA",
                skillRadius = 200, hitTime = 1500,
                reuseDelay = 8000, effectPower = 40,
                effectType = "POISON", saveVs = "WIT",
                effectName = "Debuff", count = 1, time = 15,
                stackOrder = 12, stackType = "accuracyDown",
                modifiers = table.freeze({
                    table.freeze({
                        Operation = "sub",
                        order = "0x40",
                        stat = "ACCURACY_COMBAT",
                        val = 12,
                    }),
                }),
            }),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/1000-1099.xml",
        XmlLevels = 16,
    }),
    [1097] = table.freeze({
        Id = 1097,
        Name = "Dreaming Spirit",
        Ranks = table.freeze({
            [1] = control_rank({
                mpInitialConsume = 2, mpConsume = 8,
                magicLvl = 7, target = "TARGET_ONE",
                castRange = 600, effectRange = 1100,
                reuseDelay = 6000, effectPower = 80,
                effectType = "SLEEP", saveVs = "WIT",
                effectName = "Sleep", count = 1, time = 30,
                abnormal = "SLEEP",
            }),
            [2] = control_rank({
                mpInitialConsume = 3, mpConsume = 12,
                magicLvl = 14, target = "TARGET_ONE",
                castRange = 600, effectRange = 1100,
                reuseDelay = 6000, effectPower = 80,
                effectType = "SLEEP", saveVs = "WIT",
                effectName = "Sleep", count = 1, time = 30,
                abnormal = "SLEEP",
            }),
            [3] = control_rank({
                mpInitialConsume = 4, mpConsume = 16,
                magicLvl = 20, target = "TARGET_ONE",
                castRange = 600, effectRange = 1100,
                reuseDelay = 6000, effectPower = 80,
                effectType = "SLEEP", saveVs = "WIT",
                effectName = "Sleep", count = 1, time = 30,
                abnormal = "SLEEP",
            }),
            [4] = control_rank({
                mpInitialConsume = 5, mpConsume = 18,
                magicLvl = 25, target = "TARGET_ONE",
                castRange = 600, effectRange = 1100,
                reuseDelay = 6000, effectPower = 80,
                effectType = "SLEEP", saveVs = "WIT",
                effectName = "Sleep", count = 1, time = 30,
                abnormal = "SLEEP",
            }),
            [5] = control_rank({
                mpInitialConsume = 6, mpConsume = 21,
                magicLvl = 30, target = "TARGET_ONE",
                castRange = 600, effectRange = 1100,
                reuseDelay = 6000, effectPower = 80,
                effectType = "SLEEP", saveVs = "WIT",
                effectName = "Sleep", count = 1, time = 30,
                abnormal = "SLEEP",
            }),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/1000-1099.xml",
        XmlLevels = 20,
    }),
    [1100] = table.freeze({
        Id = 1100,
        Name = "Chill Flame",
        Ranks = table.freeze({
            [1] = control_rank({
                mpInitialConsume = 3, mpConsume = 12,
                magicLvl = 7, target = "TARGET_ONE",
                castRange = 600, effectRange = 1100,
                reuseDelay = 6000, effectPower = 70,
                effectType = "DMG_OVER_TIME", saveVs = "WIT",
                element = "FIRE", effectName = "DamOverTime",
                count = 15, time = 1, val = 20,
            }),
            [2] = control_rank({
                mpInitialConsume = 5, mpConsume = 18,
                magicLvl = 14, target = "TARGET_ONE",
                castRange = 600, effectRange = 1100,
                reuseDelay = 6000, effectPower = 70,
                effectType = "DMG_OVER_TIME", saveVs = "WIT",
                element = "FIRE", effectName = "DamOverTime",
                count = 15, time = 1, val = 30,
            }),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/1100-1199.xml",
        XmlLevels = 2,
    }),
    [1101] = table.freeze({
        Id = 1101,
        Name = "Blaze Quake",
        Ranks = table.freeze({
            [1] = control_rank({
                mpInitialConsume = 10, mpConsume = 40,
                magicLvl = 25, target = "TARGET_AURA",
                skillRadius = 200, reuseDelay = 15000,
                effectPower = 35, effectType = "DMG_OVER_TIME",
                saveVs = "WIT", element = "FIRE",
                effectName = "DamOverTime", count = 15,
                time = 1, val = 44,
            }),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/1100-1199.xml",
        XmlLevels = 2,
    }),
    [1102] = table.freeze({
        Id = 1102,
        Name = "Aura Sink",
        Ranks = table.freeze({
            [1] = control_rank({
                mpInitialConsume = 5, mpConsume = 18,
                magicLvl = 25, target = "TARGET_ONE",
                castRange = 600, effectRange = 1100,
                reuseDelay = 12000, effectPower = 80,
                effectType = "MANA_DMG_OVER_TIME",
                saveVs = "WIT",
                effectName = "ManaDamOverTime",
                count = 15, time = 5, val = 4,
            }),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/1100-1199.xml",
        XmlLevels = 6,
    }),
    [1105] = table.freeze({
        Id = 1105,
        Name = "Madness",
        Ranks = table.freeze({
            [1] = control_rank({
                mpInitialConsume = 4, mpConsume = 16,
                magicLvl = 20, target = "TARGET_MOB",
                reuseDelay = 40000, effectPower = 80,
                effectType = "CONFUSION",
                effectName = "Confusion", count = 5,
                time = 6, abnormal = "CONFUSED",
            }),
            [2] = control_rank({
                mpInitialConsume = 5, mpConsume = 18,
                magicLvl = 25, target = "TARGET_MOB",
                reuseDelay = 40000, effectPower = 80,
                effectType = "CONFUSION",
                effectName = "Confusion", count = 5,
                time = 6, abnormal = "CONFUSED",
            }),
            [3] = control_rank({
                mpInitialConsume = 6, mpConsume = 21,
                magicLvl = 30, target = "TARGET_MOB",
                reuseDelay = 40000, effectPower = 80,
                effectType = "CONFUSION",
                effectName = "Confusion", count = 5,
                time = 6, abnormal = "CONFUSED",
            }),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/1100-1199.xml",
        XmlLevels = 18,
    }),
    [1107] = table.freeze({
        Id = 1107,
        Name = "Frost Flame",
        Ranks = table.freeze({
            [1] = control_rank({
                mpInitialConsume = 6, mpConsume = 23,
                magicLvl = 20, target = "TARGET_ONE",
                castRange = 750, effectRange = 1250,
                reuseDelay = 6000, effectPower = 70,
                effectType = "DMG_OVER_TIME", saveVs = "WIT",
                element = "FIRE", effectName = "DamOverTime",
                count = 15, time = 1, val = 44,
            }),
            [2] = control_rank({
                mpInitialConsume = 8, mpConsume = 32,
                magicLvl = 30, target = "TARGET_ONE",
                castRange = 750, effectRange = 1250,
                reuseDelay = 6000, effectPower = 70,
                effectType = "DMG_OVER_TIME", saveVs = "WIT",
                element = "FIRE", effectName = "DamOverTime",
                count = 15, time = 1, val = 60,
            }),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/1100-1199.xml",
        XmlLevels = 2,
    }),
    [1208] = table.freeze({
        Id = 1208,
        Name = "Seal of Binding",
        Ranks = table.freeze({
            [1] = control_rank({
                mpInitialConsume = 7, mpConsume = 27,
                magicLvl = 25, target = "TARGET_AURA",
                skillRadius = 200, reuseDelay = 20000,
                effectPower = 40, effectType = "ROOT",
                saveVs = "WIT", effectName = "Root",
                count = 1, time = 30, abnormal = "ROOT",
                stackOrder = 1, stackType = "Root",
            }),
            [2] = control_rank({
                mpInitialConsume = 8, mpConsume = 32,
                magicLvl = 30, target = "TARGET_AURA",
                skillRadius = 200, reuseDelay = 20000,
                effectPower = 40, effectType = "ROOT",
                saveVs = "WIT", effectName = "Root",
                count = 1, time = 30, abnormal = "ROOT",
                stackOrder = 1, stackType = "Root",
            }),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/1200-1299.xml",
        XmlLevels = 17,
    }),
    [1209] = table.freeze({
        Id = 1209,
        Name = "Seal of Poison",
        Ranks = table.freeze({
            [1] = control_rank({
                mpInitialConsume = 6, mpConsume = 23,
                magicLvl = 20, target = "TARGET_AURA",
                skillRadius = 200, reuseDelay = 15000,
                effectPower = 35, effectType = "POISON",
                saveVs = "MEN", effectName = "Poison",
                count = 10, time = 3, abnormal = "POISON",
                val = 18,
            }),
            [2] = control_rank({
                mpInitialConsume = 8, mpConsume = 32,
                magicLvl = 30, target = "TARGET_AURA",
                skillRadius = 200, reuseDelay = 15000,
                effectPower = 35, effectType = "POISON",
                saveVs = "MEN", effectName = "Poison",
                count = 10, time = 3, abnormal = "POISON",
                val = 24,
            }),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/1200-1299.xml",
        XmlLevels = 6,
    }),
    [1229] = table.freeze({
        Id = 1229,
        Name = "Chant of Life",
        Ranks = table.freeze({
            [1] = life_chant_rank(12, 47, 20, 12),
            [2] = life_chant_rank(15, 57, 25, 15),
            [3] = life_chant_rank(18, 70, 30, 18),
        }),
        SourceFile =
            "L2jAdmins_Data/data/xml/stats/skills/1200-1299.xml",
        XmlLevels = 18,
    }),
})

return DATA
