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
        SourceQuestId = 403, SourceTitle = "The Ashen Blade Trial",
        StartLevel = 18, TransferLevel = 20,
        TransferNpcId = "MarshalBriar",
        Recommendation = "AshfordRecommendation",
        Steps = table.freeze({
            talk("CaptainAshford", "Request the Rogue trial."),
            talk("Vela", "Obtain Vela's dagger and bow."),
            defeat("CryptSentinel", 10,
                "Gather ten crypt relics with Vela's weapons.", true),
            talk("Vela", "Deliver your crypt fragments."),
            talk("CaptainAshford", "Report the completed crypt trial."),
            defeat("CinderBrigand", 1,
                "Recover the supply cipher, route map, ward seal and "
                    .. "tideglass lens using Vela's weapons.", true),
            talk("CaptainAshford", "Deliver the captured supply records."),
        }),
        RequiredProofIds = table.freeze({
            "SpartoiBone10", "StolenJewelry", "StolenTomes",
            "StolenRing", "StolenNecklace",
        }),
        WorldBindingStatus = "NotImplemented",
    }),
    ElvenScout = table.freeze({
        Id = "C4PathToElvenScout", BranchId = "ElvenScout",
        SourceQuestId = 407, SourceTitle = "The Greenward Search",
        StartLevel = 18, TransferLevel = 20,
        TransferNpcId = "PathwardenSiora",
        Recommendation = "ElyraRecommendation",
        Steps = table.freeze({
            talk("PathfinderElyra", "Request the Elven Scout trial."),
            talk("WardenThorne", "Investigate Thorne's missing friend."),
            defeat("BrackenRaider", 4,
                "Recover all four torn fragments of Cael's letter."),
            talk("WardenThorne", "Deliver the four letter fragments."),
            talk("ScoutCael", "Find the missing scout Cael."),
            defeat("BrackenWarden", 1, "Recover the shackle key."),
            talk("ScoutCael", "Free scout Cael using the gate key."),
            talk("WardenThorne", "Report the successful rescue."),
            talk("PathfinderElyra", "Receive Elyra's recommendation."),
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
