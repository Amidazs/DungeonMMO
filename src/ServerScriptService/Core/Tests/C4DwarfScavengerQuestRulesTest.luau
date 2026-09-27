--!strict
-- Deepclaimer Q417-shaped ordered quest and Spoil-proof regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Core.Shared

local Rules = require(Shared.C4OriginalQuestProgressRules)
local Stages = require(Shared.C4OriginalFirstTransferQuestStages)

local checks = 0

--[[
Counts one Deepclaimer quest-rule assertion.

Args:
    valid (boolean): Expected ordered quest condition.
    label (string): Diagnostic description for failure.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[Deepclaimer Quest Rules] " .. label)
end

--[[
Builds an eligible or deliberately under-level Dwarven Fighter.

Args:
    level (number): Character level to test against Q417 start gating.

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
            OriginalFirstTransferChoiceId = "DwarfScavenger",
        },
    }
end

--[[
Builds the initial persisted quest state for direct rule testing.

Args:
    quest (any): Exact Deepclaimer source-shaped quest blueprint.

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
    spoil_verified (boolean?): Server Spoil ownership evidence.

Returns:
    any: Trusted-world-shaped event for the generic quest rules.
]]
local function event_for(
    quest: any,
    step_index: number,
    count: number,
    spoil_verified: boolean?
): any
    local step = quest.Steps[step_index]

    return {
        EventId = "deepclaimer-"
            .. tostring(step_index)
            .. "-"
            .. tostring(count),
        Kind = step.Kind,
        TargetId = step.TargetId,
        MonsterReceiptId = if step.Kind == "QuestMonsterDefeat"
            then "deepclaimer-life-"
                .. tostring(step_index)
                .. "-"
                .. tostring(count)
            else nil,
        SpoilVerified = spoil_verified == true,
        VerifiedProofIds = {},
    }
end

--[[
Advances one complete step with distinct server events.

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
        local event = event_for(
            quest,
            step_index,
            count,
            step.RequiresSpoil == true
        )
        local result = Rules.advance(quest, state, event)
        check(
            result.ok == true,
            "ordered step " .. tostring(step_index) .. " advances"
        )
    end
end

--[[
Runs the full Q417-shaped Deepclaimer source-rule regression.

Args:
    None.

Returns:
    nil: Prints a bounded pass marker after all proof gates succeed.
]]
local function main()
    local quest = assert(Stages.get("DwarfScavenger"))

    check(
        quest.SourceQuestId == 417
            and quest.StartLevel == 19
            and quest.TransferLevel == 20,
        "Q417 keeps exact level-19 source start and level-20 transfer"
    )

    local low_ok, low_reason = Rules.can_start(
        make_character(18),
        "DwarfScavenger"
    )
    check(
        not low_ok and low_reason == "OriginalQuestLevelTooLow",
        "level 18 Dwarven Fighter cannot start Q417"
    )

    local start_ok = Rules.can_start(
        make_character(19),
        "DwarfScavenger"
    )
    check(start_ok == true, "level 19 Dwarven Fighter can start Q417")

    local state = make_state(quest)

    complete_step(quest, state, 1)
    complete_step(quest, state, 2)
    complete_step(quest, state, 3)

    local forged = event_for(quest, 4, 1, false)
    local forged_ok, forged_reason = Rules.can_progress(
        quest,
        state,
        forged
    )
    check(
        not forged_ok
            and forged_reason == "OriginalQuestSpoilRequired",
        "ordinary Honeyback Bear kill cannot replace player Spoil proof"
    )

    complete_step(quest, state, 4)
    check(
        state.Proofs.SpoiledHoneyJars5 == true,
        "five spoiled Honeyback Bears mint personal jar proof"
    )

    complete_step(quest, state, 5)

    local tarantula = event_for(quest, 6, 1, false)
    local tarantula_ok, tarantula_reason = Rules.can_progress(
        quest,
        state,
        tarantula
    )
    check(
        not tarantula_ok
            and tarantula_reason == "OriginalQuestSpoilRequired",
        "ordinary tarantula kill cannot replace player Spoil proof"
    )

    complete_step(quest, state, 6)
    check(
        state.Proofs.SpoiledSalvageBeads20 == true,
        "twenty spoiled tarantulas mint personal bead proof"
    )

    for step_index = 7, #quest.Steps do
        complete_step(quest, state, step_index)
    end

    check(
        state.Proofs.QuartermasterErrands == true,
        "quartermaster sequence mints personal errands proof"
    )
    check(
        state.Proofs.WandererProofToken == true,
        "wanderer stage mints personal token proof"
    )
    check(
        state.Ready == true
            and state.Step == #quest.Steps + 1,
        "all eleven ordered stages produce ready transfer state"
    )

    for _, proof_id in ipairs(quest.RequiredProofIds) do
        check(
            state.Proofs[proof_id] == true,
            "required transfer proof exists: " .. proof_id
        )
    end

    print(
        ("[Deepclaimer Quest Rules] PASS: %d assertions")
            :format(checks)
    )
end

main()
