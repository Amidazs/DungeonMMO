--!strict
-- Exact C4 Palus Knight active/passive source-effect regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Effects = require(
    ReplicatedStorage.Core.Shared.C4SkillEffectSource
)

local checks = 0

--[[
Counts one Palus Knight source-effect assertion.

Args:
    condition (boolean): Observed exact source metadata.
    label (string): Failure description.

Returns:
    nil: Raises on mismatch.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Palus Effects] " .. label)
end

--[[
Returns one exact source modifier.

Args:
    rank (any): Exact source rank definition.
    stat_name (string): Source stat key.

Returns:
    any?: Matching modifier.
]]
local function modifier(rank: any, stat_name: string): any?
    for _, row in ipairs(rank.Modifiers or {}) do
        if row.stat == stat_name then
            return row
        end
    end
    for _, effect in ipairs(rank.Effects or {}) do
        for _, row in ipairs(effect.Modifiers or {}) do
            if row.stat == stat_name then
                return row
            end
        end
    end
    return nil
end

--[[
Runs exact Palus Knight source-effect acceptance.

Args:
    None.

Returns:
    nil: Prints green source-effect evidence.
]]
local function main()
    local drain = assert(Effects.get_rank(70, 10))
    check(
        drain.Sets.power == 35
            and drain.Sets.magicLvl == 28
            and drain.Sets.mpInitialConsume == 4
            and drain.Sets.mpConsume == 15
            and drain.Sets.absorbPart == 0.2
            and drain.Sets.element == "DARK",
        "Drain Health rank ten preserves exact inherited C4 values"
    )

    local confusion = assert(Effects.get_rank(2, 2))
    check(
        confusion.Sets.effectType == "CONFUSION"
            and confusion.Sets.effectPower == 80
            and confusion.Sets.magicLvl == 28
            and confusion.Effects[1].name == "Confusion"
            and confusion.Effects[1].count == 5
            and confusion.Effects[1].time == 6,
        "Confusion rank two preserves five six-second retarget actions"
    )

    local aggression = assert(Effects.get_rank(28, 6))
    check(
        aggression.Sets.skillType == "AGGDAMAGE"
            and aggression.Sets.power == 803
            and aggression.Sets.castRange == 400
            and aggression.Effects[1].name == "TargetMe",
        "Aggression rank six preserves source threat power and target effect"
    )

    local poison = assert(Effects.get_rank(129, 1))
    check(
        poison.Sets.effectType == "POISON"
            and poison.Sets.effectPower == 70
            and poison.Effects[1].val == 18
            and poison.Effects[1].count == 10
            and poison.Effects[1].time == 3,
        "Poison rank one preserves exact 18 x 10 every three seconds"
    )

    local sting = assert(Effects.get_rank(223, 6))
    check(
        sting.Sets.skillType == "PDAM"
            and sting.Sets.power == 64
            and sting.Sets.effectType == "BLEED"
            and sting.Sets.effectPower == 50
            and sting.Effects[1].val == 13
            and sting.Effects[1].count == 7
            and sting.Effects[1].time == 20,
        "Sting rank six preserves direct power and seven Bleed ticks"
    )

    local attack_aura = assert(Effects.get_rank(77, 2))
    local attack_modifier = assert(modifier(
        attack_aura,
        "PHYSICAL_ATTACK"
    ))
    check(
        attack_modifier.Operation == "mul"
            and attack_modifier.val == 1.12
            and attack_aura.Effects[1].time == 1200,
        "Attack Aura rank two preserves 1.12 physical attack for 1200s"
    )

    local defense_aura = assert(Effects.get_rank(91, 2))
    local defense_modifier = assert(modifier(
        defense_aura,
        "PHYSICAL_DEFENCE"
    ))
    check(
        defense_modifier.Operation == "mul"
            and defense_modifier.val == 1.12
            and defense_aura.Effects[1].time == 1200,
        "Defense Aura rank two preserves 1.12 physical defense for 1200s"
    )

    local last_stand = assert(Effects.get_rank(110, 1))
    check(
        last_stand.Effects[1].name == "ImmobileBuff"
            and assert(modifier(
                last_stand,
                "PHYSICAL_DEFENCE"
            )).val == 1800
            and assert(modifier(
                last_stand,
                "MAGICAL_DEFENCE"
            )).val == 1350
            and last_stand.Effects[1].time == 30,
        "Ultimate Defense preserves exact immobile dual-defense buff"
    )

    local arrow_ward = assert(Effects.get_rank(112, 1))
    check(
        assert(modifier(
            arrow_ward,
            "BOW_WPN_VULN"
        )).val == 0.84
            and arrow_ward.Effects[1].time == 1200,
        "Deflect Arrow preserves 0.84 bow vulnerability for 1200s"
    )

    check(
        assert(modifier(
            assert(Effects.get_rank(147, 8)),
            "MAGICAL_DEFENCE"
        )).val == 28
            and assert(modifier(
                assert(Effects.get_rank(153, 2)),
                "SHIELD_DEFENCE_RATE"
            )).val == 1.7
            and assert(modifier(
                assert(Effects.get_rank(217, 4)),
                "PHYSICAL_ATTACK"
            )).val == 5.2
            and assert(modifier(
                assert(Effects.get_rank(232, 9)),
                "PHYSICAL_DEFENCE"
            )).val == 33.6,
        "level-30 passive source ranks preserve exact final modifiers"
    )

    print((
        "[C4 Palus Effects] PASS: %d assertions "
            .. "drain=70:10 confusion=2:2 aggression=28:6 "
            .. "poison=129:1 sting=223:6"
    ):format(checks))
end

main()
