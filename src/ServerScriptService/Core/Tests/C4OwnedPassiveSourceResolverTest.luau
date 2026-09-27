--!strict
-- Actually-owned creative passive to C4 source-rank migration regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Core.Shared

local Careers = require(Shared.OriginalFirstTransferDefinitions)
local ProfileSchema = require(Shared.ProfileSchema)
local QuestStages = require(Shared.C4OriginalFirstTransferQuestStages)
local Resolver = require(Shared.C4OwnedPassiveSourceResolver)

local TEST_OWNER = 938177
local checks = 0

--[[
Counts one owned-passive source migration assertion.

Args:
    valid (boolean): Expected source rank, inheritance or denial condition.
    label (string): Diagnostic description for a failed assertion.

Returns:
    nil: Increments the check count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Owned Passives] " .. label)
end

--[[
Builds a complete original starter or first-transfer character fixture.

Args:
    race_id (string): Human or Elf original race.
    class_id (string): Starter or first-transfer creative class ID.
    level (number): Current launch-level character level.

Returns:
    any: Profile-shaped authenticated character fixture.
]]
local function original_character(
    race_id: string,
    class_id: string,
    level: number
): any
    local character = ProfileSchema
        .create_default(TEST_OWNER).Characters.Slot1
    local career = Careers.for_class(class_id)
    local base_class = if career then career.BaseClassId else class_id

    character.Level = level
    character.Identity = {
        Version = 1,
        RaceId = race_id,
        BaseClassId = base_class,
        ClassId = class_id,
        CreationStage = "Complete",
    }

    if career then
        local stage = assert(QuestStages.get(career.BranchId))
        local proofs = {}

        for _, proof_id in ipairs(stage.RequiredProofIds) do
            proofs[proof_id] = true
        end

        character.ClassAdvancement = {
            Version = 1,
            OriginalFirstTransferChoiceId = career.BranchId,
            OriginalFirstTransferClassId = career.Id,
            OriginalFirstTransferReceiptId =
                "TEMP_C4OwnedPassiveMentor",
            OriginalFirstTransferQuest = {
                QuestId = stage.Id,
                BranchId = career.BranchId,
                Step = #stage.Steps + 1,
                Count = 0,
                Ready = true,
                AppliedEvents = {},
                Proofs = proofs,
            },
        }
    end

    return character
end

--[[
Stores one genuinely owned creative passive rank in the fixture.

Args:
    character (any): Mutable server-owned test character.
    skill_id (string): Creative passive skill identifier.
    rank (number): Purchased rank to persist.

Returns:
    nil: Mutates only the disposable fixture skill state.
]]
local function own_passive(
    character: any,
    skill_id: string,
    rank: number
)
    character.Progression.Skills[skill_id] = {
        Known = true,
        StarterGranted = false,
        PurchasedRank = rank,
        Proficiency = 0,
    }
end

--[[
Finds one resolved historical source passive rank.

Args:
    result (any): Owned-passive source resolution snapshot.
    source_skill_id (number): Historical C4 source skill ID.

Returns:
    any?: Matching highest owned source rank, or nil.
]]
local function find_source_rank(
    result: any,
    source_skill_id: number
): any?
    for _, row in ipairs(result.SourceRanks) do
        if row.SkillId == source_skill_id then
            return row
        end
    end

    return nil
end

--[[
Checks starter passives use only actually purchased creative ranks.

Args:
    None.

Returns:
    nil: Prevents level eligibility from becoming free passive ownership.
]]
local function check_starter_owned_ranks()
    local character = original_character("Human", "Fighter", 15)
    own_passive(character, "FighterPhysicalTraining", 3)
    own_passive(character, "FighterArmorTraining", 5)
    own_passive(character, "C4RecipeReading", 1)

    local result, reason = Resolver.for_character(character)
    check(
        result ~= nil and reason == nil and result.Ready,
        "reviewed starter owned passives resolve cleanly"
    )

    local weapon = assert(find_source_rank(result, 141))
    local armour = assert(find_source_rank(result, 142))

    check(
        weapon.Rank == 3
            and weapon.CreativeSkillId == "FighterPhysicalTraining"
            and weapon.CreativeRank == 3,
        "owned Fighter weapon training resolves to source rank 3"
    )
    check(
        armour.Rank == 5
            and armour.CreativeSkillId == "FighterArmorTraining"
            and armour.CreativeRank == 5,
        "owned Fighter armour training resolves to source rank 5"
    )
    check(
        #result.UnsupportedOwnedCreativePassives == 0
            and #result.UnresolvedOwnedPassiveRanks == 0,
        "non-stat recipe reading does not block C4 combat migration"
    )
end

--[[
Checks first-transfer characters retain actually owned starter passives.

Args:
    None.

Returns:
    nil: Confirms inherited starter and transfer passives resolve together.
]]
local function check_first_transfer_inheritance()
    local character = original_character("Human", "Oathguard", 28)
    own_passive(character, "FighterPhysicalTraining", 3)
    own_passive(character, "OathguardHeavyArmorTraining", 9)
    own_passive(character, "OathguardShieldMastery", 1)

    local result = assert(Resolver.for_character(character))
    local inherited = assert(find_source_rank(result, 141))
    local heavy = assert(find_source_rank(result, 232))
    local shield = assert(find_source_rank(result, 153))

    check(
        result.Ready
            and inherited.Rank == 3
            and heavy.Rank == 9
            and shield.Rank == 1,
        "Knight resolves inherited Fighter and owned transfer passives"
    )
end

--[[
Checks Human Wizard reuse passives migrate only from actually owned ranks.

Args:
    None.

Returns:
    nil: Confirms Quick Recovery rank two resolves from Emberweaver ownership.
]]
local function check_human_wizard_reuse_passive()
    local character = original_character(
        "Human",
        "Emberweaver",
        30
    )
    own_passive(character, "EmberweaverQuickWeave", 2)

    local result = assert(Resolver.for_character(character))
    local recovery = assert(find_source_rank(result, 164))

    check(
        result.Ready
            and recovery.Rank == 2
            and recovery.CreativeSkillId == "EmberweaverQuickWeave"
            and recovery.CreativeRank == 2,
        "owned Emberweaver Quick Weave resolves Quick Recovery rank two"
    )
end

--[[
Checks Dawnkeeper owned passives resolve exact inherited Cleric ranks.

Args:
    None.

Returns:
    nil: Confirms exact level-30 Cleric passive source ownership.
]]
local function check_human_cleric_owned_passives()
    local character = original_character(
        "Human",
        "Dawnkeeper",
        30
    )
    own_passive(character, "DawnkeeperQuickPrayer", 2)
    own_passive(character, "DawnkeeperRobeTraining", 6)
    own_passive(character, "DawnkeeperLightArmorTraining", 6)

    local result = assert(Resolver.for_character(character))
    local reuse = assert(find_source_rank(result, 164))
    local robe = assert(find_source_rank(result, 235))
    local light = assert(find_source_rank(result, 236))

    check(
        result.Ready
            and result.ScopeId == "HumanCleric"
            and reuse.Rank == 2
            and robe.Rank == 6
            and light.Rank == 6,
        "owned Dawnkeeper passives resolve exact Cleric source ranks"
    )
end

--[[
Checks Moonweaver owned passives resolve exact Elven Wizard source ranks.

Args:
    None.

Returns:
    nil: Confirms level-30 Elven Wizard passive source ownership.
]]
local function check_elven_wizard_owned_passives()
    local character = original_character(
        "Elf",
        "Moonweaver",
        30
    )
    own_passive(character, "MoonweaverQuickWeave", 2)
    own_passive(character, "MoonweaverRobeTraining", 6)
    own_passive(character, "MoonweaverManaChanneling", 6)

    local result = assert(Resolver.for_character(character))
    local reuse = assert(find_source_rank(result, 164))
    local robe = assert(find_source_rank(result, 234))
    local mana_gain = assert(find_source_rank(result, 285))

    check(
        result.Ready
            and result.ScopeId == "ElvenWizard"
            and reuse.Rank == 2
            and reuse.CreativeSkillId == "MoonweaverQuickWeave"
            and robe.Rank == 6
            and robe.CreativeSkillId == "MoonweaverRobeTraining"
            and mana_gain.Rank == 6
            and mana_gain.CreativeSkillId
                == "MoonweaverManaChanneling",
        "owned Moonweaver passives resolve exact Elven Wizard ranks"
    )
end

--[[
Checks Nightweaver owned passives resolve exact Dark Wizard source ranks.

Args:
    None.

Returns:
    nil: Confirms all eight level-30 Dark Wizard passive families.
]]
local function check_nightweaver_owned_passives()
    local character = original_character(
        "DarkElf",
        "Nightweaver",
        30
    )
    own_passive(character, "NightweaverArcaneResistance", 6)
    own_passive(character, "NightweaverQuickWeave", 2)
    own_passive(character, "NightweaverManaReservoir", 2)
    own_passive(character, "NightweaverRobeTraining", 6)
    own_passive(character, "NightweaverFocusTraining", 5)
    own_passive(character, "NightweaverManaChanneling", 6)
    own_passive(character, "NightweaverFastCasting", 1)
    own_passive(character, "NightweaverManaRecovery", 1)

    local result = assert(Resolver.for_character(character))
    local arcane = assert(find_source_rank(result, 146))
    local reuse = assert(find_source_rank(result, 164))
    local mana = assert(find_source_rank(result, 213))
    local robe = assert(find_source_rank(result, 234))
    local focus = assert(find_source_rank(result, 249))
    local mana_gain = assert(find_source_rank(result, 285))
    local casting = assert(find_source_rank(result, 228))
    local recovery = assert(find_source_rank(result, 229))

    check(
        result.Ready
            and result.ScopeId == "DarkWizard"
            and #result.SourceRanks == 8
            and #result.UnsupportedOwnedCreativePassives == 0
            and #result.UnresolvedOwnedPassiveRanks == 0,
        "all owned Nightweaver passives resolve without hidden gaps"
    )
    check(
        arcane.Rank == 10
            and arcane.CreativeSkillId
                == "NightweaverArcaneResistance"
            and arcane.CreativeRank == 6,
        "Arcane Resistance rank six resolves Anti Magic rank ten"
    )
    check(
        reuse.Rank == 2
            and reuse.CreativeSkillId == "NightweaverQuickWeave"
            and mana.Rank == 2
            and mana.CreativeSkillId == "NightweaverManaReservoir",
        "Nightweaver reuse and mana passives preserve source ranks"
    )
    check(
        robe.Rank == 6
            and robe.CreativeSkillId == "NightweaverRobeTraining"
            and focus.Rank == 7
            and focus.CreativeSkillId == "NightweaverFocusTraining",
        "Nightweaver robe and weapon training preserve source offsets"
    )
    check(
        mana_gain.Rank == 6
            and mana_gain.CreativeSkillId
                == "NightweaverManaChanneling",
        "Nightweaver mana gain preserves its exact source rank"
    )
    check(
        casting.Rank == 1
            and casting.CreativeSkillId == "NightweaverFastCasting"
            and recovery.Rank == 1
            and recovery.CreativeSkillId
                == "NightweaverManaRecovery",
        "Nightweaver casting and mana recovery preserve source rank one"
    )
end

--[[
Checks Duskseer owned passives resolve exact Shillien Oracle source ranks.

Args:
    None.

Returns:
    nil: Confirms all eight level-30 Shillien Oracle passive families.
]]
local function check_duskseer_owned_passives()
    local character = original_character(
        "DarkElf",
        "Duskseer",
        30
    )
    own_passive(character, "DuskseerArcaneResistance", 6)
    own_passive(character, "DuskseerQuickPrayer", 2)
    own_passive(character, "DuskseerManaReservoir", 2)
    own_passive(character, "DuskseerFastCasting", 1)
    own_passive(character, "DuskseerManaRecovery", 1)
    own_passive(character, "DuskseerRobeTraining", 6)
    own_passive(character, "DuskseerLightArmorTraining", 6)
    own_passive(character, "DuskseerWeaponTraining", 5)

    local result = assert(Resolver.for_character(character))
    local arcane = assert(find_source_rank(result, 146))
    local reuse = assert(find_source_rank(result, 164))
    local mana = assert(find_source_rank(result, 213))
    local casting = assert(find_source_rank(result, 228))
    local recovery = assert(find_source_rank(result, 229))
    local robe = assert(find_source_rank(result, 235))
    local light = assert(find_source_rank(result, 236))
    local weapon = assert(find_source_rank(result, 249))

    check(
        result.Ready
            and result.ScopeId == "ShillienOracle"
            and #result.SourceRanks == 8
            and #result.UnsupportedOwnedCreativePassives == 0
            and #result.UnresolvedOwnedPassiveRanks == 0,
        "all owned Duskseer passives resolve without hidden gaps"
    )
    check(
        arcane.Rank == 10
            and arcane.CreativeSkillId
                == "DuskseerArcaneResistance"
            and arcane.CreativeRank == 6,
        "Duskseer Arcane Resistance resolves Anti Magic rank ten"
    )
    check(
        reuse.Rank == 2
            and reuse.CreativeSkillId == "DuskseerQuickPrayer"
            and mana.Rank == 2
            and mana.CreativeSkillId == "DuskseerManaReservoir",
        "Duskseer reuse and mana passives preserve source ranks"
    )
    check(
        casting.Rank == 1
            and casting.CreativeSkillId == "DuskseerFastCasting"
            and recovery.Rank == 1
            and recovery.CreativeSkillId == "DuskseerManaRecovery",
        "Duskseer casting and recovery preserve source rank one"
    )
    check(
        robe.Rank == 6
            and robe.CreativeSkillId == "DuskseerRobeTraining"
            and light.Rank == 6
            and light.CreativeSkillId
                == "DuskseerLightArmorTraining",
        "Duskseer robe and light armour preserve exact source ranks"
    )
    check(
        weapon.Rank == 7
            and weapon.CreativeSkillId == "DuskseerWeaponTraining"
            and weapon.CreativeRank == 5,
        "Duskseer Weapon Training rank five resolves source rank seven"
    )
end

--[[
Checks Warhowl inherits exact Orc Fighter and Raider passive source ranks.

Args:
    None.

Returns:
    nil: Confirms class-44 and class-45 passives resolve together.
]]
local function check_warhowl_owned_passives()
    local character = original_character(
        "Orc",
        "Warhowl",
        30
    )

    own_passive(character, "OrcToughness", 1)
    own_passive(character, "OrcLucky", 1)
    own_passive(character, "OrcWeaponTraining", 3)
    own_passive(character, "OrcArmorTraining", 5)
    own_passive(character, "OrcIronBody", 1)

    own_passive(character, "WarhowlEndurance", 1)
    own_passive(character, "WarhowlBloodFortitude", 2)
    own_passive(character, "WarhowlRecovery", 1)
    own_passive(character, "WarhowlPolearmTraining", 4)
    own_passive(character, "WarhowlLightArmorTraining", 7)
    own_passive(character, "WarhowlHeavyArmorTraining", 7)
    own_passive(character, "WarhowlSteelAndStoneTraining", 4)
    own_passive(character, "WarhowlGreatWeaponTraining", 3)

    local result = assert(Resolver.for_character(character))

    local toughness = assert(find_source_rank(result, 134))
    local starter_weapon = assert(find_source_rank(result, 141))
    local starter_armor = assert(find_source_rank(result, 142))
    local iron_body = assert(find_source_rank(result, 295))
    local endurance = assert(find_source_rank(result, 148))
    local boost_hp = assert(find_source_rank(result, 211))
    local recovery = assert(find_source_rank(result, 212))
    local polearm = assert(find_source_rank(result, 216))
    local light = assert(find_source_rank(result, 227))
    local heavy = assert(find_source_rank(result, 231))
    local sword_blunt = assert(find_source_rank(result, 257))
    local two_handed = assert(find_source_rank(result, 293))

    check(
        result.Ready
            and result.ScopeId == "OrcRaider"
            and #result.SourceRanks == 12
            and #result.UnsupportedOwnedCreativePassives == 0
            and #result.UnresolvedOwnedPassiveRanks == 0,
        "all owned Warhowl source-stat passives resolve without gaps"
    )
    check(
        toughness.Rank == 1
            and starter_weapon.Rank == 3
            and starter_armor.Rank == 5
            and iron_body.Rank == 1,
        "Warhowl inherits exact class-44 passive source ranks"
    )
    check(
        endurance.Rank == 1
            and boost_hp.Rank == 2
            and recovery.Rank == 1
            and polearm.Rank == 4,
        "Warhowl preserves exact first Raider passive ranks"
    )
    check(
        light.Rank == 7
            and heavy.Rank == 7
            and sword_blunt.Rank == 4
            and two_handed.Rank == 3,
        "Warhowl preserves exact armour and weapon mastery ranks"
    )
end

--[[
Checks Lifebinder owned passives resolve exact Elven Oracle source ranks.

Args:
    None.

Returns:
    nil: Confirms level-30 Elven Oracle passive source ownership.
]]
local function check_elven_oracle_owned_passives()
    local character = original_character(
        "Elf",
        "Lifebinder",
        30
    )
    own_passive(character, "LifebinderQuickPrayer", 2)
    own_passive(character, "LifebinderRobeTraining", 6)
    own_passive(character, "LifebinderLightArmorTraining", 6)

    local result = assert(Resolver.for_character(character))
    local reuse = assert(find_source_rank(result, 164))
    local robe = assert(find_source_rank(result, 235))
    local light = assert(find_source_rank(result, 236))

    check(
        result.Ready
            and result.ScopeId == "ElvenOracle"
            and reuse.Rank == 2
            and reuse.CreativeSkillId == "LifebinderQuickPrayer"
            and robe.Rank == 6
            and robe.CreativeSkillId == "LifebinderRobeTraining"
            and light.Rank == 6
            and light.CreativeSkillId
                == "LifebinderLightArmorTraining",
        "owned Lifebinder passives resolve exact Elven Oracle ranks"
    )
end

--[[
Checks unsupported or corrupted owned passive state remains fail-closed.

Args:
    None.

Returns:
    nil: Surfaces custom passives and ranks beyond reviewed source ownership.
]]
local function check_fail_closed_owned_state()
    local mage = original_character("Human", "Mage", 15)
    own_passive(mage, "MysticRobeCasting", 1)

    local unsupported = assert(Resolver.for_character(mage))
    check(
        not unsupported.Ready
            and unsupported.UnsupportedOwnedCreativePassives[1]
                == "MysticRobeCasting",
        "unmapped custom combat passive blocks exact C4 passive migration"
    )

    local fighter = original_character("Human", "Fighter", 15)
    own_passive(fighter, "FighterPhysicalTraining", 9)

    local overflow = assert(Resolver.for_character(fighter))
    check(
        not overflow.Ready
            and #overflow.UnresolvedOwnedPassiveRanks == 1
            and overflow.UnresolvedOwnedPassiveRanks[1].SkillId
                == "FighterPhysicalTraining"
            and overflow.UnresolvedOwnedPassiveRanks[1].OwnedRank == 9
            and overflow.UnresolvedOwnedPassiveRanks[1].MaxReviewedRank == 3,
        "saved creative rank above reviewed C4 rank fails closed"
    )
end

--[[
Runs actually-owned passive source migration acceptance.

Args:
    None.

Returns:
    nil: Prints a bounded source-only success marker.
]]
local function main()
    check_starter_owned_ranks()
    check_first_transfer_inheritance()
    check_human_wizard_reuse_passive()
    check_human_cleric_owned_passives()
    check_elven_wizard_owned_passives()
    check_nightweaver_owned_passives()
    check_duskseer_owned_passives()
    check_warhowl_owned_passives()
    check_elven_oracle_owned_passives()
    check_fail_closed_owned_state()

    print((
        "[C4 Owned Passives] SOURCE_ONLY_PASS: %d assertions "
        .. "ownership=true inherited=true live=false"
    ):format(checks))
end

main()
