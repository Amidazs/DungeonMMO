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
--[[
Checks every Dwarf combat quest stage can bind a real enemy model.

Args:
    ledger (any): Disposable physical quest ledger.

Returns:
    {Model}: Created enemies for caller cleanup.
]]
local function check_dwarf_combat_registration(ledger: any): {Model}
    local enemies = {}
    local cases = {
        {"DwarfArtisan", 2, "TunnelGnawer"},
        {"DwarfArtisan", 3, "TunnelGnawerChief"},
        {"DwarfArtisan", 7, "AshclanForgeThief"},
        {"DwarfScavenger", 4, "HoneybackBear"},
        {"DwarfScavenger", 6, "TunnelTarantula"},
    }

    for index, entry in ipairs(cases) do
        local branch_id = entry[1]
        local step_index = entry[2]
        local target_id = entry[3]
        local enemy = make_enemy(target_id)
        enemy:SetAttribute(
            "DungeonEnemyId",
            "DwarfTrialEnemy" .. tostring(index)
        )
        table.insert(enemies, enemy)

        check(
            ledger:register_enemy(
                enemy,
                branch_id,
                "TrialRoomA",
                step_index
            ),
            branch_id
                .. " step "
                .. tostring(step_index)
                .. " accepts its real quest monster"
        )
        check(
            ledger:available(
                assert(Quests.get(branch_id)),
                step_index
            ),
            branch_id
                .. " step "
                .. tostring(step_index)
                .. " becomes world-available"
        )
    end

    return enemies
end

--[[
Checks Deepclaimer Spoil evidence is owner-bound and source-authored.

Args:
    None.

Returns:
    nil: Rejects absent, foreign, claimed and invented salvage marks.
]]
local function check_spoil_ownership()
    local enemy = make_enemy("HoneybackBear")
    local owner_user_id = 956260

    check(
        not Ledger.is_spoil_verified(enemy, owner_user_id),
        "unspoiled monster cannot satisfy Deepclaimer proof"
    )

    enemy:SetAttribute("C4SalvageOwnerUserId", owner_user_id + 1)
    enemy:SetAttribute("C4SalvageSourceSkillId", 254)
    enemy:SetAttribute("C4SalvageClaimed", false)
    check(
        not Ledger.is_spoil_verified(enemy, owner_user_id),
        "another player's Spoil cannot satisfy Deepclaimer proof"
    )

    enemy:SetAttribute("C4SalvageOwnerUserId", owner_user_id)
    check(
        Ledger.is_spoil_verified(enemy, owner_user_id),
        "owner-bound source Spoil satisfies Deepclaimer proof"
    )

    enemy:SetAttribute("C4SalvageSourceSkillId", 302)
    check(
        Ledger.is_spoil_verified(enemy, owner_user_id),
        "owner-bound Spoil Festival also satisfies Deepclaimer proof"
    )

    enemy:SetAttribute("C4SalvageSourceSkillId", 999999)
    check(
        not Ledger.is_spoil_verified(enemy, owner_user_id),
        "invented salvage source skill cannot satisfy quest proof"
    )

    enemy:SetAttribute("C4SalvageSourceSkillId", 254)
    enemy:SetAttribute("C4SalvageClaimed", true)
    check(
        not Ledger.is_spoil_verified(enemy, owner_user_id),
        "already claimed salvage cannot mint fresh quest Spoil proof"
    )

    enemy:Destroy()
end

local function check_original_owner_isolation()
    for _, entry in ipairs({
        {"HumanRogue", 3},
        {"HumanWarrior", 3},
        {"HumanKnight", 3},
        {"ElvenScout", 3},
        {"ElvenKnight", 3},
        {"ElvenKnight", 5},
        {"DwarfArtisan", 2},
        {"DwarfArtisan", 3},
        {"DwarfArtisan", 7},
        {"DwarfScavenger", 4},
        {"DwarfScavenger", 6},
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
    check_spoil_ownership()
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

    local dwarf_enemies = check_dwarf_combat_registration(ledger)

    ledger:clear()
    check(not ledger:available(rogue, 3),
        "Wipe clears pending world availability, not saved owner progress")
    enemy:Destroy()
    for _, dwarf_enemy in ipairs(dwarf_enemies) do
        dwarf_enemy:Destroy()
    end
    print(("[C4 Quest Combat Ledger] PASS: %d assertions")
        :format(assertions))
end

main()
