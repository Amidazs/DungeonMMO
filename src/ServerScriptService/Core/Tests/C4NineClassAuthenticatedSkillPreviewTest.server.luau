--!strict
-- All nine original C4 learnable trees from real server-owned identity.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)
local Schema = require(Shared.ProfileSchema)
local Careers = require(Shared.OriginalFirstTransferDefinitions)
local Stages = require(Shared.C4OriginalFirstTransferQuestStages)
local ScoutHeal = require(Shared.C4ScoutHealMigrationPlan)
local Source = require(Shared.C4SkillEffectSource)
local Tree = require(Shared.C4Level30SkillTreeSource)

local OWNER_ID = 938188
local checks = 0

--[[
Records a real original skill reference or anti-forgery assertion.

Args:
    valid (boolean): Expected pinned original source row or gate.
    label (string): Precise diagnostic for the first failed check.

Returns:
    nil: Counts success, raises otherwise.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Nine-Class Skills] " .. label)
end

--[[
Seeds actual server runtime with a valid disposable historical class.

Args:
    race_id (string): Source Elf or Human race.
    class_id (string): Current original starter/first-transfer ID.
    level (number): Source level, up to 30.

Returns:
    nil: Genuine server-owned identity with test-only quest receipt.
]]
local function seed(race_id: string, class_id: string, level: number)
    local character = Schema.create_default(OWNER_ID).Characters.Slot1
    local career = Careers.for_class(class_id)
    character.Level = level
    character.Identity = {
        Version = 1, RaceId = race_id,
        BaseClassId = if career then career.BaseClassId else class_id,
        ClassId = class_id, CreationStage = "Complete",
    }
    if career then
        local source = assert(Stages.get(career.BranchId))
        local proofs = {}
        for _, id in ipairs(source.RequiredProofIds) do
            proofs[id] = true
        end
        character.ClassAdvancement = {
            Version = 1,
            OriginalFirstTransferChoiceId = career.BranchId,
            OriginalFirstTransferClassId = career.Id,
            OriginalFirstTransferReceiptId = "TEMP_NineSourceSkillMentor",
            OriginalFirstTransferQuest = {
                QuestId = source.Id, BranchId = career.BranchId,
                Step = #source.Steps + 1, Ready = true,
                Count = 0, AppliedEvents = {}, Proofs = proofs,
            },
        }
    end
    Runtime.set_character(OWNER_ID, character)
end

--[[
Finds exactly one historical skill and rank in a scoped source preview.

Args:
    preview (any): Authenticated class tree from current server state.
    source_id (number): Pinned source XML skill ID.
    source_rank (number): Exact original C4 skill rank.

Returns:
    any?: Historical row, or nil if the class did not learn this rank.
]]
local function find_row(
    preview: any, source_id: number, source_rank: number
): any?
    for _, row in ipairs(preview.Rows) do
        if row.SourceSkillId == source_id
            and row.SourceSkillLevel == source_rank
        then return row end
    end
    return nil
end

--[[
Audits every current original path without mistaking candidates for parity.

Args:
    None.

Returns:
    nil: Checks all 476 level-30 source rows and 22 unresolved gaps.
]]
local function check_nine_class_trees()
    local paths = {
        {"Human", "Fighter", 39},
        {"Human", "Mage", 44},
        {"Elf", "Fighter", 43},
        {"Elf", "Mage", 42},
        {"Human", "Ironvow", 62},
        {"Human", "Oathguard", 54},
        {"Human", "Ashenblade", 59},
        {"Elf", "GreenwardWarden", 56},
        {"Elf", "GreenwardScout", 77},
    }
    local rows, candidates, gaps = 0, 0, 0
    for _, path in ipairs(paths) do
        seed(path[1], path[2], 30)
        local preview, reason = Runtime.get_c4_source_skill_tree(
            OWNER_ID
        )
        check(preview ~= nil and reason == nil,
            path[2] .. " authentic saved class has its original tree")
        check(preview.SourceRowsAtLevel == path[3]
                and preview.SourceOnly
                and preview.ExactC4EffectCertified == false
                and not preview.LiveIntegrated,
            path[2] .. " exact original row count is not live parity")
        for _, row in ipairs(preview.Rows) do
            check(row.SourceLearnLevel <= 30
                and type(row.SourceSP) == "number"
                and type(row.SourceTotalMP) == "number"
                and row.ExactC4EffectCertified == false,
                "Every source row preserves C4 SP/MP without parity claim")
        end
        rows += preview.SourceRowsAtLevel
        candidates += preview.CreativeCandidateRows
        gaps += preview.ExplicitMissingRows
        Runtime.clear_character(OWNER_ID)
    end
    check(rows == 476 and candidates == 454 and gaps == 22,
        "All nine source trees still expose 476/454/22 rank inventory")
end

--[[
Checks Scout and Warden inherited source healing remain C4-targeted.

Args:
    None.

Returns:
    nil: Original heal 58 rank4 is self-targeted, not arbitrary ally HP.
]]
local function check_heal_source_and_denials()
    seed("Elf", "GreenwardScout", 20)
    local scout = assert(Runtime.get_c4_source_skill_tree(OWNER_ID))
    local first = assert(find_row(scout, 58, 4))
    check(first.CreativeLinkStatus == "Missing"
        and first.CreativeSkillId == nil
        and first.SourceTotalMP == 53
        and first.SourceTarget == "TARGET_SELF"
        and first.OriginalEffects[1].power == 95,
        "Scout's first original heal has real source cost/target/power")
    check(find_row(scout, 58, 7) == nil,
        "Level-20 Scout must not see its level-24 healing ranks")
    seed("Elf", "GreenwardWarden", 20)
    local warden = assert(Runtime.get_c4_source_skill_tree(OWNER_ID))
    local same = assert(find_row(warden, 58, 4))
    check(same.CreativeLinkStatus == "Candidate"
        and same.SourceTotalMP == first.SourceTotalMP
        and same.SourceTarget == first.SourceTarget
        and same.OriginalEffects[1].power == first.OriginalEffects[1].power
        and not same.ExactC4EffectCertified,
        "Independent C4 Scout/Warden heal is not a verified creative copy")
    Runtime.clear_character(OWNER_ID)
    local missing, reason = Runtime.get_c4_source_skill_tree(OWNER_ID)
    check(missing == nil
        and reason == "OriginalCharacterIdentityNotVerified",
        "Missing server-owned character cannot query original skills")
    seed("Elf", "GreenwardWarden", 31)
    local _, unsupported = Runtime.get_c4_source_skill_tree(OWNER_ID)
    check(unsupported == "UnreviewedClassOrLevel",
        "Level31 must not borrow an unreviewed C4 skill rank reference")
    Runtime.clear_character(OWNER_ID)
end

--[[
Checks independent Scout self-heal source-rank contracts and class gates.

Args:
    None.

Returns:
    nil: Nine C4 ranks remain source-only until a real executor exists.
]]
local function check_scout_heal_migration_plan()
    local original_rows = Tree.find_skill("ElvenScout", 58)
    check(#original_rows == 9,
        "Scout has nine separate original first-transfer heal ranks")
    for _, row in ipairs(original_rows) do
        local planned = assert(ScoutHeal.get_rank(row.SkillLevel))
        local effect = assert(Source.get_rank(58, row.SkillLevel))
        local power = effect.Effects[1].power
        check(planned.SourceLearnLevel == row.MinLevel
            and planned.SourceSP == row.SP
            and planned.PlannedCreativeRank == row.SkillLevel - 3
            and planned.SourcePower == power
            and planned.SourceHealUncharged == power
            and planned.SourceHealSpiritshot == power * 1.3
            and planned.SourceHealBlessedSpiritshot == power * 1.5
            and planned.SourceTotalMP
                == effect.Sets.mpInitialConsume
                    + effect.Sets.mpConsume
            and planned.SourceTarget == "TARGET_SELF",
            "Scout rank preserves C4 SP, MP, heal output and targeting")
        check(planned.SourceOnly and not planned.LiveLearnable
            and not planned.LiveCastable
            and planned.ExactC4HealFormulaCertified
            and planned.SplitMPTransactionCertified,
            "Certified source semantics must not grant free live healing")
    end
    check(ScoutHeal.get_rank(3) == nil
        and ScoutHeal.get_rank(13) == nil,
        "Scout source ranks must stay separate from starter and future")
    for _, bracket in ipairs({
        {20, 3}, {24, 6}, {28, 9}, {30, 9},
    }) do
        seed("Elf", "GreenwardScout", bracket[1])
        local character = assert(Runtime.get_character(OWNER_ID))
        local plan, reason = ScoutHeal.for_character(character)
        check(plan ~= nil and reason == nil
            and #plan.Rows == bracket[2]
            and plan.ExactC4HealFormulaCertified
            and plan.SplitMPTransactionCertified
            and not plan.LiveCastable,
            "Scout sees certified source heal ranks without a live grant")
        local preview = assert(Runtime.get_c4_source_skill_tree(OWNER_ID))
        for _, original in ipairs(plan.Rows) do
            local row = assert(find_row(
                preview, 58, original.SourceSkillRank
            ))
            check(row.CreativeLinkStatus == "Missing"
                and row.CreativeSkillId == nil
                and row.SourceOnlyMigrationPlan == original,
                "Scout source plan does not become a fake live candidate")
        end
    end
    seed("Elf", "GreenwardWarden", 30)
    local warden = assert(Runtime.get_character(OWNER_ID))
    check(select(1, ScoutHeal.for_character(warden)) == nil,
        "Scout cannot borrow Warden's independent heal entitlement")
    local warden_preview = assert(
        Runtime.get_c4_source_skill_tree(OWNER_ID)
    )
    check(assert(find_row(
        warden_preview, 58, 4
    )).SourceOnlyMigrationPlan == nil,
        "Warden source healing never inherits Scout's planned family")
    Runtime.clear_character(OWNER_ID)
    check(select(1, ScoutHeal.for_character({})) == nil,
        "Missing original class identity cannot inspect Scout plans")
end

--[[
Executes all nine authenticated historical skill-source trees.

Args:
    None.

Returns:
    nil: Counts source checks and never activates custom C4 combat.
]]
local function main()
    check_nine_class_trees()
    check_heal_source_and_denials()
    check_scout_heal_migration_plan()
    print(("[C4 Nine-Class Skills] SOURCE_ONLY_PASS: %d assertions "
        .. "rows=476 candidates=454 gaps=22 live=false")
        :format(checks))
end

main()
