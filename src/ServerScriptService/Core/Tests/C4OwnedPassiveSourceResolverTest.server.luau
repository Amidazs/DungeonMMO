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
    check_fail_closed_owned_state()

    print((
        "[C4 Owned Passives] SOURCE_ONLY_PASS: %d assertions "
        .. "ownership=true inherited=true live=false"
    ):format(checks))
end

main()
