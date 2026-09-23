--!strict
-- Original Chronicle 4 first-transfer *source* quest sequences. These
-- blueprints do not enable missing NPC, monster, weapon or item content.
-- Neither a saved class choice nor any client claim completes these quests.
local SourceQuests = {}

local function talk(npc_id: string, summary: string): any
    return table.freeze({
        Kind = "NpcTalk", TargetId = npc_id,
        Required = 1, Summary = summary,
    })
end

local function defeat(
    monster_id: string, count: number, summary: string,
    requires_trial_weapon: boolean?
): any
    return table.freeze({
        Kind = "QuestMonsterDefeat", TargetId = monster_id,
        Required = count, Summary = summary,
        RequiresTrialWeapon = requires_trial_weapon == true,
    })
end

local QUESTS = table.freeze({
    HumanRogue = table.freeze({
        Id = "C4PathToRogue", BranchId = "HumanRogue",
        SourceQuestId = 403, SourceTitle = "Path to a Rogue",
        SourceUrl = "https://l2hub.info/c4/quests/403-path-to-a-rogue",
        StartLevel = 18, TransferLevel = 20,
        TransferNpcId = "GrandMasterRamos",
        Recommendation = "BeziqueRecommendation",
        Steps = table.freeze({
            talk("CaptainBezique", "Request the Rogue trial."),
            talk("Neti", "Obtain Neti's dagger and bow."),
            defeat("RogueTrialSkeleton", 10,
                "Gather ten Spartoi bones with Neti's weapons.", true),
            talk("Neti", "Return the skeleton proof."),
            talk("CaptainBezique", "Present Neti's recognition."),
            defeat("CatsEyeBandit", 1,
                "Recover all four stolen items using Neti's weapons.", true),
            talk("CaptainBezique", "Return the stolen items."),
        }),
        RequiredProofIds = table.freeze({
            "SpartoiBone10", "StolenJewelry", "StolenTomes",
            "StolenRing", "StolenNecklace",
        }),
        WorldBindingStatus = "NotImplemented",
    }),
    ElvenScout = table.freeze({
        Id = "C4PathToElvenScout", BranchId = "ElvenScout",
        SourceQuestId = 407, SourceTitle = "Path to an Elven Scout",
        SourceUrl = "https://l2hub.info/c4/quests/407-path-to-an-elven-scout",
        StartLevel = 18, TransferLevel = 20,
        TransferNpcId = "GrandMasterRains",
        Recommendation = "ReisaRecommendation",
        Steps = table.freeze({
            talk("MasterReisa", "Request the Elven Scout trial."),
            talk("GuardMoretti", "Investigate Moretti's missing friend."),
            defeat("OlMahumPatrol", 4,
                "Recover all four torn fragments of Prias's letter."),
            talk("GuardMoretti", "Deliver the four letter fragments."),
            talk("Prias", "Find the imprisoned Prias."),
            defeat("OlMahumSentry", 1, "Recover the shackle key."),
            talk("Prias", "Release Prias with the key."),
            talk("GuardMoretti", "Report the successful rescue."),
            talk("MasterReisa", "Receive Reisa's recommendation."),
        }),
        RequiredProofIds = table.freeze({
            "PriasLetter1", "PriasLetter2", "PriasLetter3",
            "PriasLetter4", "RustedKey",
        }),
        WorldBindingStatus = "NotImplemented",
    }),
})

--[[
Returns an explicitly source-documented original C4 class quest.

Args:
    branch_id (string): Exact original first-transfer class identity.

Returns:
    any?: Immutable source quest blueprint or nil if not yet mapped.
]]
function SourceQuests.get(branch_id: string): any?
    return QUESTS[branch_id]
end

--[[
Lists currently researched original C4 first-transfer quest blueprints.

Args:
    None.

Returns:
    {any}: Source quest data only, not a completed in-world encounter.
]]
function SourceQuests.inventoried(): {any}
    return table.freeze({QUESTS.HumanRogue, QUESTS.ElvenScout})
end

return table.freeze(SourceQuests)
