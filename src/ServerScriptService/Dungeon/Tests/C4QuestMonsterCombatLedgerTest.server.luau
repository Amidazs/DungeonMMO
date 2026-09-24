--!strict
-- Isolated physical-model registration tests; no live quest room is wired.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Ledger = require(SSS.Dungeon.C4QuestMonsterCombatLedger)
local Quests = require(RS.Core.Shared.C4OriginalFirstTransferQuestStages)
local Careers = require(RS.Core.Shared.OriginalFirstTransferDefinitions)

local assertions = 0

--[[
Checks one encounter admission or security refusal.

Args:
    accepted (boolean): Actual tested runtime condition.
    label (string): Specific expected contract.

Returns:
    nil: Raises on a failed source-monster registration expectation.
]]
local function check(accepted: boolean, label: string)
    assertions += 1
    assert(accepted, "[C4 Quest Combat Ledger] " .. label)
end

--[[
Creates one real, server-owned physical target in the disposable scene.

Args:
    source_monster_id (string): Explicit original DungeonMMO enemy type.

Returns:
    Model: Live world model carrying canonical encounter identity.
]]
local function make_enemy(source_monster_id: string): Model
    local model = Instance.new("Model")
    model.Name = source_monster_id
    model:SetAttribute("SourceQuestMonsterId", source_monster_id)
    model:SetAttribute("DungeonEncounterId", "TrialRoomA")
    model:SetAttribute("DungeonEnemyId", "TrialEnemy1")
    model:SetAttribute("DungeonLifeIndex", 1)
    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = model
    model.Parent = workspace
    return model
end

--[[
Creates a valid original Fighter for any existing first-transfer source.

Args:
    branch_id (string): Registered actual race and class route.
    stage (number): Exact original quest monster step.

Returns:
    any: Valid character data without trusting a client-supplied quest ID.
]]
local function original_owner(branch_id: string, stage: number): any
    local career = assert(Careers.for_branch(branch_id))
    local source = assert(Quests.get(branch_id))
    return {
        Level = source.StartLevel,
        Identity = {
            RaceId = career.RaceId,
            BaseClassId = career.BaseClassId,
            ClassId = "Fighter",
        },
        ClassAdvancement = {
            OriginalFirstTransferChoiceId = branch_id,
            OriginalFirstTransferQuest = {
                BranchId = branch_id, Step = stage, Ready = false,
            },
        },
    }
end

--[[
Verifies identity and stage cannot be forged between hit and reward.

Args:
    None.

Returns:
    nil: Covers both races, the original branch and all denial gates.
]]
local function check_original_owner_isolation()
    for _, entry in ipairs({
        {"HumanRogue", 3},
        {"HumanWarrior", 3},
        {"HumanKnight", 3},
        {"ElvenScout", 3},
        {"ElvenKnight", 3},
        {"ElvenKnight", 5},
    }) do
        local branch_id, stage = entry[1], entry[2]
        local original = original_owner(branch_id, stage)
        check(Ledger.is_owner_eligible(original, branch_id, stage),
            "Genuinely selected original Fighter can earn owned loot")
        original.Identity.RaceId =
            if original.Identity.RaceId == "Elf" then "Human" else "Elf"
        check(not Ledger.is_owner_eligible(original, branch_id, stage),
            "Copied quest cannot override original race")
        original = original_owner(branch_id, stage)
        original.Identity.BaseClassId = "Mage"
        check(not Ledger.is_owner_eligible(original, branch_id, stage),
            "Copied quest cannot override original starter base class")
        original = original_owner(branch_id, stage)
        original.Identity.ClassId = "GreenwardWarden"
        check(not Ledger.is_owner_eligible(original, branch_id, stage),
            "An already advanced class cannot farm first-transfer loot")
        original = original_owner(branch_id, stage)
        original.ClassAdvancement.OriginalFirstTransferChoiceId =
            "HumanKnight"
        if branch_id ~= "HumanKnight" then
            check(not Ledger.is_owner_eligible(original, branch_id, stage),
                "Wrong saved branch choice cannot earn monster loot")
        else
            original.ClassAdvancement.OriginalFirstTransferChoiceId =
                "ElvenKnight"
            check(not Ledger.is_owner_eligible(original, branch_id, stage),
                "Copied alternate branch must never grant Human loot")
        end
        original = original_owner(branch_id, stage)
        original.Level = 1
        check(not Ledger.is_owner_eligible(original, branch_id, stage),
            "Underlevel owner cannot mint original source proof")
        original = original_owner(branch_id, stage)
        original.ClassAdvancement.OriginalFirstTransferQuest.Step =
            stage + 1
        check(not Ledger.is_owner_eligible(original, branch_id, stage),
            "A stale hit cannot award after stage transition")
        original = original_owner(branch_id, stage)
        original.ClassAdvancement.OriginalFirstTransferQuest.Ready = true
        check(not Ledger.is_owner_eligible(original, branch_id, stage),
            "Completed quest cannot earn repeated reports or seals")
    end
end

--[[
Checks real physical registration, unique life and fail-closed combat.

Args:
    None.

Returns:
    nil: Reports only fixture checks actually executed in Studio.
]]
local function main()
    check_original_owner_isolation()
    local profiles = {get_character = function(): any
        return nil
    end}
    local ledger = Ledger.new({
        profiles = profiles,
        session_id = "TestDungeonSessionA",
        is_member_active = function(): boolean
            return false
        end,
    })
    local rogue = assert(Quests.get("HumanRogue"))
    local elf = assert(Quests.get("ElvenScout"))
    check(not ledger:available(rogue, 3)
        and not ledger:available(elf, 3),
        "Unbuilt live quest monsters must remain unavailable")
    check(not ledger:register_enemy({} :: any,
        "HumanRogue", "TrialRoomA"),
        "A client-shaped table cannot masquerade as a physical monster")

    local enemy = make_enemy("CryptSentinel")
    check(not ledger:register_enemy(
        enemy, "ElvenScout", "TrialRoomA"
    ), "A Rogue-only source monster cannot become an Elf's proof")
    check(not ledger:register_enemy(
        enemy, "HumanRogue", "DifferentRoom"
    ), "Encounter mismatch rejects a physically real wrong-room monster")
    check(ledger:register_enemy(
        enemy, "HumanRogue", "TrialRoomA"
    ), "Registered real quest monster receives one unique server life")
    check(not ledger:register_enemy(
        enemy, "HumanRogue", "TrialRoomA"
    ), "One physical monster life cannot be registered twice")
    check(ledger:available(rogue, 3)
        and not ledger:available(rogue, 2)
        and not ledger:available(elf, 3),
        "Only this branch's exact combat stage becomes available")
    check(not ledger:record_damage(
        {target = enemy, attacker = {}}, 10, true
    ), "An untrusted attacker table cannot earn original quest loot")
    check(not ledger:verify(123, {
        Kind = "QuestMonsterDefeat",
        TargetId = "CryptSentinel",
    }, rogue, {Step = 3}),
        "World verifier must reject events it never minted")
    ledger:clear()
    check(not ledger:available(rogue, 3),
        "Wipe clears pending world availability, not saved owner progress")
    enemy:Destroy()
    print(("[C4 Quest Combat Ledger] PASS: %d assertions")
        :format(assertions))
end

main()
