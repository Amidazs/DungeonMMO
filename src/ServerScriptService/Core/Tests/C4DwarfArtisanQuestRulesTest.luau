--!strict
-- Gearwright Q418-shaped ordered quest proof regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Core.Shared

local Rules = require(Shared.C4OriginalQuestProgressRules)
local Stages = require(Shared.C4OriginalFirstTransferQuestStages)

local checks = 0

--[[
Counts one Gearwright quest-rule assertion.

Args:
    valid (boolean): Expected ordered quest condition.
    label (string): Diagnostic description for failure.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[Gearwright Quest Rules] " .. label)
end

--[[
Builds an eligible or deliberately under-level Dwarven Fighter.

Args:
    level (number): Character level to test against Q418 start gating.

Returns:
    any: Detached authoritative-style character state.
]]
local function make_character(level: number): any
    return {
        Level = level,
        Identity = {
            Version = 1,
            CreationStage = "Complete",
            RaceId = "Dwarf",
            BaseClassId = "Fighter",
            ClassId = "Fighter",
        },
        ClassAdvancement = {
            ActiveClassId = nil,
            OriginalFirstTransferChoiceId = "DwarfArtisan",
        },
    }
end

--[[
Builds initial persisted quest state for direct rule testing.

Args:
    quest (any): Exact Gearwright source-shaped quest blueprint.

Returns:
    any: Mutable ordered quest state.
]]
local function make_state(quest: any): any
    return {
        QuestId = quest.Id,
        BranchId = quest.BranchId,
        Step = 1,
        Count = 0,
        Ready = false,
        AppliedEvents = {},
        Proofs = {},
    }
end

--[[
Builds one unique server-authored event for the current step.

Args:
    quest (any): Exact quest blueprint.
    step_index (number): Current ordered quest step.
    count (number): Unique event number within that step.

Returns:
    any: Trusted-world-shaped event for the generic quest rules.
]]
local function event_for(
    quest: any,
    step_index: number,
    count: number
): any
    local step = quest.Steps[step_index]

    return {
        EventId = "gearwright-"
            .. tostring(step_index)
            .. "-"
            .. tostring(count),
        Kind = step.Kind,
        TargetId = step.TargetId,
        MonsterReceiptId = if step.Kind == "QuestMonsterDefeat"
            then "gearwright-life-"
                .. tostring(step_index)
                .. "-"
                .. tostring(count)
            else nil,
        VerifiedProofIds = {},
    }
end

--[[
Advances one complete Gearwright step with distinct server events.

Args:
    quest (any): Exact quest blueprint.
    state (any): Mutable current quest state.
    step_index (number): Expected current step.

Returns:
    nil: Applies the step's exact count or raises on a rule regression.
]]
local function complete_step(
    quest: any,
    state: any,
    step_index: number
)
    local step = quest.Steps[step_index]

    for count = 1, step.Required do
        local result = Rules.advance(
            quest,
            state,
            event_for(quest, step_index, count)
        )
        check(
            result.ok == true,
            "ordered step " .. tostring(step_index) .. " advances"
        )
    end
end

--[[
Runs the full Q418-shaped Gearwright source-rule regression.

Args:
    None.

Returns:
    nil: Prints a bounded pass marker after all proof gates succeed.
]]
local function main()
    local quest = assert(Stages.get("DwarfArtisan"))

    check(
        quest.SourceQuestId == 418
            and quest.StartLevel == 19
            and quest.TransferLevel == 20,
        "Q418 keeps exact level-19 source start and level-20 transfer"
    )

    local low_ok, low_reason = Rules.can_start(
        make_character(18),
        "DwarfArtisan"
    )
    check(
        not low_ok and low_reason == "OriginalQuestLevelTooLow",
        "level 18 Dwarven Fighter cannot start Q418"
    )

    local start_ok = Rules.can_start(
        make_character(19),
        "DwarfArtisan"
    )
    check(start_ok == true, "level 19 Dwarven Fighter can start Q418")

    local state = make_state(quest)

    for step_index = 1, #quest.Steps do
        complete_step(quest, state, step_index)
    end

    check(
        state.Proofs.ForgeTestTeeth10 == true,
        "ten mine trophies mint first smith proof"
    )
    check(
        state.Proofs.ForgeChiefTeeth2 == true,
        "two chief trophies mint second mine proof"
    )
    check(
        state.Proofs.StolenComponentChest == true,
        "stolen component recovery mints final material proof"
    )
    check(
        state.Ready == true
            and state.Step == #quest.Steps + 1,
        "all ten ordered stages produce ready transfer state"
    )

    for _, proof_id in ipairs(quest.RequiredProofIds) do
        check(
            state.Proofs[proof_id] == true,
            "required transfer proof exists: " .. proof_id
        )
    end

    print(
        ("[Gearwright Quest Rules] PASS: %d assertions")
            :format(checks)
    )
end

main()
