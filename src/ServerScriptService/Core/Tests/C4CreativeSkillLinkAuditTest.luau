--!strict
-- All tracked C4 classes: every original rank needs a candidate
-- or an explicit documented gap. A mapped ID is not matching damage.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared
local Audit = require(Shared.C4CreativeSkillLinkAudit)
local Map = require(Shared.C4CreativeSkillSourceMap)

local report = Audit.report()
assert(report.ClassPaths == 23 and report.SourceLearningRows == 1370,
    "All tracked level-30 classes and source ranks must be audited")
assert(report.CandidateRows == 1293
    and report.ExplicitMissingRows == 12,
    "Tracked source rows must preserve candidate and explicit-gap totals")
assert(report.CandidateRows + report.ExplicitMissingRows == 1370,
    "Every historical rank requires a candidate or an explicit gap")
assert(report.UnexaminedOrBrokenRows == 0,
    "Every candidate must resolve to a real class skill and rank")
assert(report.ExplicitMissingRows > 0,
    "Do not silently pretend current skill catalogue is complete")
assert(not report.ExactC4MechanicsCertified
    and not report.LiveSkillMigrationComplete,
    "Source mapping cannot certify skill effects or finished migration")

-- These special ranks cannot be mapped by string-matching names alone.
local wind_one = assert(Map.resolve("HumanMystic", 1177, 1))
local wind_two = assert(Map.resolve("HumanMystic", 1177, 2))
local elven_heal = assert(Map.resolve("ElvenKnight", 58, 4))
local rogue_blade = assert(Map.resolve("HumanRogue", 16, 10))
local elf_aura = assert(Map.resolve("ElvenScout", 91, 2))
local elf_heal = assert(Map.resolve("ElvenScout", 58, 4))
local wizard_bolt = assert(Map.resolve("HumanWizard", 1220, 1))
local wizard_companion = assert(Map.resolve("HumanWizard", 1111, 1))
local cleric_heal = assert(Map.resolve("HumanCleric", 1011, 7))
local cleric_shield = assert(Map.resolve("HumanCleric", 1040, 2))
local oracle_recharge = assert(Map.resolve("ElvenOracle", 1013, 2))
local oracle_shackle = assert(Map.resolve("ElvenOracle", 1206, 4))
local nightweaver_gale = assert(Map.resolve("DarkWizard", 1178, 1))
local nightweaver_drain = assert(Map.resolve("DarkWizard", 1147, 3))
local nightweaver_poison = assert(Map.resolve("DarkWizard", 1168, 2))
local nightweaver_frost = assert(Map.resolve("DarkWizard", 1184, 5))
local nightweaver_surrender = assert(Map.resolve("DarkWizard", 1224, 1))
local dusk_heal = assert(Map.resolve("ShillienOracle", 1011, 7))
local dusk_weapon = assert(Map.resolve("ShillienOracle", 249, 3))
local dusk_shackle = assert(Map.resolve("ShillienOracle", 1206, 2))
local dusk_empower = assert(Map.resolve("ShillienOracle", 1059, 1))
local dusk_blood = assert(Map.resolve("ShillienOracle", 1268, 1))
local orc_punch = assert(Map.resolve("OrcFighter", 29, 9))
local orc_toughness = assert(Map.resolve("OrcFighter", 134, 1))
local orc_body = assert(Map.resolve("OrcFighter", 295, 1))
local warhowl_stun = assert(Map.resolve("OrcRaider", 100, 9))
local warhowl_rage = assert(Map.resolve("OrcRaider", 94, 1))
local warhowl_great = assert(Map.resolve("OrcRaider", 293, 3))
local spirit_punch = assert(Map.resolve("OrcMonk", 29, 10))
local spirit_force = assert(Map.resolve("OrcMonk", 54, 1))
local spirit_stun = assert(Map.resolve("OrcMonk", 120, 9))
local spirit_agile = assert(Map.resolve("OrcMonk", 319, 1))
local mystic_drain = assert(Map.resolve("OrcMystic", 1090, 2))
local shaman_weapon = assert(Map.resolve("OrcShaman", 250, 3))
local shaman_life = assert(Map.resolve("OrcShaman", 1229, 3))
assert(wind_one.CreativeSkillId == "WindStrike"
    and wind_one.CreativeRank == 1
    and wind_two.CreativeSkillId == "MysticWindBolt"
    and wind_two.CreativeRank == 1,
    "Starter Wind Strike must not lose its distinct first rank")
assert(elven_heal.CreativeRank == 1
    and rogue_blade.CreativeRank == 1
    and elf_aura.CreativeRank == 1
    and elf_heal.Status == "Candidate"
    and elf_heal.CreativeSkillId == "GreenwardScoutElementalHeal"
    and elf_heal.CreativeRank == 1,
    "Original first-transfer offsets and live Elf Scout heal matter")
assert(wizard_bolt.Status == "Candidate"
    and wizard_bolt.CreativeSkillId == "EmberweaverEmberBolt"
    and wizard_bolt.CreativeRank == 1
    and wizard_companion.Status == "Candidate"
    and wizard_companion.CreativeSkillId
        == "EmberweaverManaCompanion",
    "Wizard direct and companion skills both map after summon authority")

assert(cleric_heal.Status == "Candidate"
    and cleric_heal.CreativeSkillId == "DawnkeeperHealingLight"
    and cleric_heal.CreativeRank == 1
    and cleric_shield.Status == "Candidate"
    and cleric_shield.CreativeSkillId == "DawnkeeperStoneWard"
    and cleric_shield.CreativeRank == 1,
    "Cleric inherited source ranks map to exact Dawnkeeper creative ranks")

assert(oracle_recharge.Status == "Candidate"
    and oracle_recharge.CreativeSkillId == "LifebinderManaRecharge"
    and oracle_recharge.CreativeRank == 2
    and oracle_shackle.Status == "Candidate"
    and oracle_shackle.CreativeSkillId == "LifebinderWindShackle"
    and oracle_shackle.CreativeRank == 3,
    "Oracle source ranks map to exact Lifebinder creative ranks")

assert(nightweaver_gale.Status == "Candidate"
    and nightweaver_gale.CreativeSkillId == "NightweaverGaleBolt"
    and nightweaver_gale.CreativeRank == 1
    and nightweaver_drain.CreativeSkillId == "NightweaverUmbralSiphon"
    and nightweaver_drain.CreativeRank == 1
    and nightweaver_poison.CreativeSkillId == "NightweaverVenomHex"
    and nightweaver_poison.CreativeRank == 1
    and nightweaver_frost.CreativeSkillId == "NightweaverFrostLance"
    and nightweaver_frost.CreativeRank == 1
    and nightweaver_surrender.CreativeSkillId == "NightweaverVenomRend"
    and nightweaver_surrender.CreativeRank == 1,
    "Dark Wizard offsets map to independent Nightweaver ranks")

assert(dusk_heal.Status == "Candidate"
    and dusk_heal.CreativeSkillId == "DuskseerHealingLight"
    and dusk_heal.CreativeRank == 1
    and dusk_weapon.CreativeSkillId == "DuskseerWeaponTraining"
    and dusk_weapon.CreativeRank == 1
    and dusk_shackle.CreativeSkillId == "DuskseerWindShackle"
    and dusk_shackle.CreativeRank == 1,
    "Shillien Oracle inherited rank offsets map to Duskseer ranks")

assert(warhowl_stun.Status == "Candidate"
    and warhowl_stun.CreativeSkillId == "WarhowlSkullbreaker"
    and warhowl_stun.CreativeRank == 9
    and warhowl_rage.CreativeSkillId == "WarhowlFury"
    and warhowl_rage.CreativeRank == 1
    and warhowl_great.CreativeSkillId
        == "WarhowlGreatWeaponTraining"
    and warhowl_great.CreativeRank == 3,
    "Orc Raider unique and shared source families map to Warhowl")

assert(orc_punch.Status == "Candidate"
    and orc_punch.CreativeSkillId == "OrcIronPunch"
    and orc_punch.CreativeRank == 9
    and orc_toughness.CreativeSkillId == "OrcToughness"
    and orc_body.CreativeSkillId == "OrcIronBody",
    "Orc Fighter unique source families map independently")

assert(spirit_punch.Status == "Candidate"
    and spirit_punch.CreativeSkillId == "SpiritclawIronFist"
    and spirit_punch.CreativeRank == 1
    and spirit_force.CreativeSkillId == "SpiritclawForceBurst"
    and spirit_force.CreativeRank == 1
    and spirit_stun.CreativeSkillId == "SpiritclawStunningFist"
    and spirit_stun.CreativeRank == 9
    and spirit_agile.CreativeSkillId == "SpiritclawAgileMovement"
    and spirit_agile.CreativeRank == 1,
    "Orc Monk inherited offsets and unique families map to Spiritclaw")

assert(mystic_drain.Status == "Candidate"
    and mystic_drain.CreativeSkillId == "OrcMysticLifeDrain"
    and mystic_drain.CreativeRank == 2
    and shaman_weapon.CreativeSkillId
        == "AshspeakerWeaponTraining"
    and shaman_weapon.CreativeRank == 1
    and shaman_life.CreativeSkillId == "AshspeakerLifeChant"
    and shaman_life.CreativeRank == 3,
    "Orc Mystic inheritance and Shaman offsets map independently")

assert(dusk_empower.Status == "Candidate"
    and dusk_empower.CreativeSkillId == "DuskseerEmpower"
    and dusk_empower.CreativeRank == 1
    and dusk_blood.Status == "Candidate"
    and dusk_blood.CreativeSkillId == "DuskseerBloodRite"
    and dusk_blood.CreativeRank == 1,
    "Shillien Oracle unique support families map independently")

for _, class in ipairs(report.Classes) do
    local gaps = {}
    local issues = {}
    for _, row in ipairs(class.Rows) do
        if row.Status == "Missing" then
            table.insert(gaps, ("%s:%s %s"):format(
                row.SourceSkillId, row.SourceRank, row.Reason
            ))
        elseif row.Issue then
            table.insert(issues, ("%s:%s %s"):format(
                row.SourceSkillId, row.SourceRank, row.Issue
            ))
        end
    end
    print(("[C4 CREATIVE LINK] %s sourceRows=%d missing=%d "
        .. "broken=%d creativeExtra=%d")
        :format(class.ScopeId, class.SourceRows, #gaps, #issues,
            #class.CreativeSkillsOutsideThisSourceTree))
    for _, item in ipairs(gaps) do
        print("[C4 CREATIVE GAP] " .. class.ScopeId .. " " .. item)
    end
    for _, id in ipairs(class.CreativeSkillsOutsideThisSourceTree) do
        print("[C4 CREATIVE EXTRA] " .. class.ScopeId .. " " .. id)
    end
end
print(("[C4 CREATIVE LINK] AUDIT_PASS paths=%d rows=%d "
    .. "candidate=%d explicitGap=%d broken=%d differentMP=%d "
    .. "liveEffectParity=NOT_CERTIFIED")
    :format(report.ClassPaths, report.SourceLearningRows,
        report.CandidateRows, report.ExplicitMissingRows,
        report.UnexaminedOrBrokenRows,
        report.CandidateRowsWithDifferentMpNumbers))
