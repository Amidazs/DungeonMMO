--!strict
-- DungeonMMO first-transfer identities: never aliases for legacy classes.
local Stages = require(script.Parent.C4OriginalFirstTransferQuestStages)

local Definitions = {}

local ENTRIES = table.freeze({
    HumanKnight = table.freeze({
        BranchId = "HumanKnight",
        Id = "Oathguard",
        DisplayName = "Oathguard",
        RaceId = "Human",
        BaseClassId = "Fighter",
        MentorId = "CaptainRowan",
        MentorName = "Captain Rowan",
        SkillId = "OathguardShieldImpact",
        TrainerId = "OathguardTrainer",
    }),
    HumanWarrior = table.freeze({
        BranchId = "HumanWarrior",
        Id = "Ironvow",
        DisplayName = "Ironvow",
        RaceId = "Human",
        BaseClassId = "Fighter",
        MentorId = "MarshalTorren",
        MentorName = "Marshal Torren",
        SkillId = "IronvowDrivingStrike",
        TrainerId = "IronvowTrainer",
    }),
    HumanWizard = table.freeze({
        BranchId = "HumanWizard",
        Id = "Emberweaver",
        DisplayName = "Emberweaver",
        RaceId = "Human",
        BaseClassId = "Mage",
        MentorId = "MagisterOrwyn",
        MentorName = "Magister Orwyn",
        SkillId = "EmberweaverEmberBolt",
        TrainerId = "EmberweaverTrainer",
    }),
    HumanCleric = table.freeze({
        BranchId = "HumanCleric",
        Id = "Dawnkeeper",
        DisplayName = "Dawnkeeper",
        RaceId = "Human",
        BaseClassId = "Mage",
        MentorId = "PriestessElara",
        MentorName = "Priestess Elara",
        SkillId = "DawnkeeperHealingLight",
        TrainerId = "DawnkeeperTrainer",
    }),
    HumanRogue = table.freeze({
        BranchId = "HumanRogue",
        Id = "Ashenblade",
        DisplayName = "Ashenblade",
        RaceId = "Human",
        BaseClassId = "Fighter",
        MentorId = "MarshalBriar",
        MentorName = "Marshal Briar",
        SkillId = "HumanScoutSprint",
        TrainerId = "AshenbladeTrainer",
    }),
    ElvenKnight = table.freeze({
        BranchId = "ElvenKnight",
        Id = "GreenwardWarden",
        DisplayName = "Greenward Warden",
        RaceId = "Elf",
        BaseClassId = "Fighter",
        MentorId = "SentinelIlyra",
        MentorName = "Sentinel Ilyra",
        TrainerId = "GreenwardWardenTrainer",
    }),
    ElvenScout = table.freeze({
        BranchId = "ElvenScout",
        Id = "GreenwardScout",
        DisplayName = "Greenward Scout",
        RaceId = "Elf",
        BaseClassId = "Fighter",
        MentorId = "PathwardenSiora",
        MentorName = "Pathwarden Siora",
        SkillId = "ElvenScoutGuard",
        TrainerId = "GreenwardScoutTrainer",
    }),
})
local BY_ID = table.freeze({
    Oathguard = ENTRIES.HumanKnight,
    Ironvow = ENTRIES.HumanWarrior,
    Ashenblade = ENTRIES.HumanRogue,
    Emberweaver = ENTRIES.HumanWizard,
    Dawnkeeper = ENTRIES.HumanCleric,
    GreenwardScout = ENTRIES.ElvenScout,
    GreenwardWarden = ENTRIES.ElvenKnight,
})

--[[
Finds a supported original DungeonMMO first-transfer career.

Args:
    branch_id (string): Existing stable saved source quest branch.

Returns:
    any?: Exact immutable transfer configuration, or nil if unsupported.
]]
function Definitions.for_branch(branch_id: string): any?
    return ENTRIES[branch_id]
end

--[[
Finds the corresponding career by its independently named class ID.

Args:
    class_id (string): Persisted first-transfer identity identifier.

Returns:
    any?: Corresponding immutable transfer definition, or nil.
]]
function Definitions.for_class(class_id: string): any?
    return BY_ID[class_id]
end

--[[
Lists original class careers with authoritative source and mentor gates.

Args:
    None.

Returns:
    {any}: Supported authored, immutable first-transfer definitions.
]]
function Definitions.all(): {any}
    return table.freeze({
        ENTRIES.HumanKnight, ENTRIES.HumanWarrior,
        ENTRIES.HumanRogue, ENTRIES.HumanWizard,
        ENTRIES.HumanCleric, ENTRIES.ElvenScout,
        ENTRIES.ElvenKnight,
    })
end

--[[
Checks source-quest completion independently of its temporary world actor.

Args:
    character (any): Exclusive server-owned current selected character.
    definition (any): Supported branch's immutable career metadata.

Returns:
    (boolean, string?): Complete personal proof or reason for denial.
]]
local function earned_quest(
    character: any, definition: any
): (boolean, string?)
    if type(character) ~= "table"
        or type(character.Identity) ~= "table"
        or type(character.ClassAdvancement) ~= "table"
    then
        return false, "OriginalTransferCharacterUnavailable"
    end
    local identity = character.Identity
    local advancement = character.ClassAdvancement
    local source = Stages.get(definition.BranchId)
    local state = advancement.OriginalFirstTransferQuest
    if not source
        or identity.CreationStage ~= "Complete"
        or identity.RaceId ~= definition.RaceId
        or identity.BaseClassId ~= definition.BaseClassId
        or advancement.OriginalFirstTransferChoiceId
            ~= definition.BranchId
        or advancement.ActiveClassId ~= nil
    then
        return false, "OriginalTransferWrongClass"
    end
    if (tonumber(character.Level) or 0) < source.TransferLevel then
        return false, "OriginalTransferLevelTooLow"
    end
    if type(state) ~= "table" or state.QuestId ~= source.Id
        or state.BranchId ~= definition.BranchId
        or state.Ready ~= true
        or state.Step ~= #source.Steps + 1
        or type(state.Proofs) ~= "table"
    then
        return false, "OriginalTransferQuestNotReady"
    end
    for _, proof_id in ipairs(source.RequiredProofIds) do
        if state.Proofs[proof_id] ~= true then
            return false, "OriginalTransferMissingProof"
        end
    end
    return true, nil
end

--[[
Checks an unadvanced starter for one eligible first-transfer class award.

Args:
    character (any): Actual selected server-authoritative character.
    branch_id (string): Requested existing exact saved branch identity.

Returns:
    (boolean, string?, any?): Eligibility, reason and original definition.
]]
function Definitions.can_transfer(
    character: any, branch_id: string
): (boolean, string?, any?)
    local definition = ENTRIES[branch_id]
    if not definition then
        return false, "OriginalTransferBranchUnavailable", nil
    end
    local valid, reason = earned_quest(character, definition)
    if not valid then return false, reason, definition end
    local advancement = character.ClassAdvancement
    if advancement.OriginalFirstTransferClassId ~= nil
        or character.Identity.ClassId ~= definition.BaseClassId
    then
        return false, "OriginalTransferAlreadyCompleted", definition
    end
    return true, nil, definition
end

--[[
Validates the entire saved awarded class, not a mere client-facing flag.

Args:
    character (any): Real selected profile or freshly migrated character.

Returns:
    any?: Earned first-transfer definition; nil on inconsistent save data.
]]
function Definitions.awarded(character: any): any?
    local advancement = character and character.ClassAdvancement
    local identity = character and character.Identity
    if type(advancement) ~= "table" or type(identity) ~= "table"
    then
        return nil
    end
    local class_id = advancement.OriginalFirstTransferClassId
    local definition = if type(class_id) == "string"
        then BY_ID[class_id] else nil
    local receipt = advancement.OriginalFirstTransferReceiptId
    if not definition
        or type(receipt) ~= "string" or receipt == ""
        or #receipt > 120
        or identity.ClassId ~= definition.Id
    then
        return nil
    end
    local valid = earned_quest(character, definition)
    return if valid then definition else nil
end

return table.freeze(Definitions)
