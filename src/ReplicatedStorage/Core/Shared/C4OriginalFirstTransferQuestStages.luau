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

local function spoiled_defeat(
    monster_id: string,
    count: number,
    summary: string
): any
    return table.freeze({
        Kind = "QuestMonsterDefeat",
        TargetId = monster_id,
        Required = count,
        Summary = summary,
        RequiresSpoil = true,
    })
end

local QUESTS = table.freeze({
    DwarfScavenger = table.freeze({
        Id = "DeepclaimerTrial",
        BranchId = "DwarfScavenger",
        SourceQuestId = 417,
        SourceTitle = "The Deepclaimer Trial",
        StartLevel = 19,
        TransferLevel = 20,
        TransferNpcId = "SalvageMasterVeyda",
        Recommendation = "DeepclaimerRavenSeal",
        Steps = table.freeze({
            talk(
                "SalvageMasterVeyda",
                "Accept the Deepclaimer salvage trial."
            ),
            talk(
                "QuartermasterBrel",
                "Complete the quartermaster's rotating supply errands."
            ),
            talk(
                "ProspectorNessa",
                "Begin the field salvage examination."
            ),
            spoiled_defeat(
                "HoneybackBear",
                5,
                "Spoil five honeyback bears and recover five honey jars."
            ),
            talk(
                "ProspectorNessa",
                "Present the five spoiled honey jars."
            ),
            spoiled_defeat(
                "TunnelTarantula",
                20,
                "Spoil tunnel tarantulas and recover twenty salvage beads."
            ),
            talk(
                "ProspectorNessa",
                "Present the twenty spoiled salvage beads."
            ),
            talk(
                "GatewardenHarl",
                "Deliver the sealed salvage parcel."
            ),
            talk(
                "WandererKest",
                "Recover the wanderer's proof token."
            ),
            talk(
                "GatewardenHarl",
                "Return the proof token and receive the raven seal."
            ),
            talk(
                "SalvageMasterVeyda",
                "Present the raven seal and become a Deepclaimer."
            ),
        }),
        RequiredProofIds = table.freeze({
            "QuartermasterErrands",
            "SpoiledHoneyJars5",
            "SpoiledSalvageBeads20",
            "WandererProofToken",
        }),
        WorldBindingStatus = "NotImplemented",
    }),
    DwarfArtisan = table.freeze({
        Id = "GearwrightTrial",
        BranchId = "DwarfArtisan",
        SourceQuestId = 418,
        SourceTitle = "The Gearwright Trials",
        StartLevel = 19,
        TransferLevel = 20,
        TransferNpcId = "ForgekeeperOrda",
        Recommendation = "GearwrightPassCertificate",
        Steps = table.freeze({
            talk(
                "ForgekeeperOrda",
                "Accept the three smiths' Gearwright trials."
            ),
            defeat(
                "TunnelGnawer",
                10,
                "Recover ten personally earned forge-test teeth."
            ),
            defeat(
                "TunnelGnawerChief",
                2,
                "Recover two personally earned chief teeth."
            ),
            talk(
                "ForgekeeperOrda",
                "Present the mine trophies for the first smith test."
            ),
            talk(
                "MasterSmithVarka",
                "Begin the second smith's test."
            ),
            talk(
                "SmithDorrin",
                "Trace the component chest stolen from the forge."
            ),
            defeat(
                "AshclanForgeThief",
                1,
                "Recover the personally earned stolen component chest."
            ),
            talk(
                "SmithDorrin",
                "Return the recovered component chest."
            ),
            talk(
                "MasterSmithVarka",
                "Complete the second smith's examination."
            ),
            talk(
                "ForgekeeperOrda",
                "Present the final certificate and become a Gearwright."
            ),
        }),
        RequiredProofIds = table.freeze({
            "ForgeTestTeeth10",
            "ForgeChiefTeeth2",
            "StolenComponentChest",
        }),
        WorldBindingStatus = "NotImplemented",
    }),
    OrcShaman = table.freeze({
        Id = "AshspeakerTrial",
        BranchId = "OrcShaman",
        SourceTitle = "The Ashspeaker Trial",
        StartLevel = 18,
        TransferLevel = 20,
        TransferNpcId = "FlameSeerKharuk",
        Recommendation = "AshspeakerEmberSeal",
        Steps = table.freeze({
            talk(
                "FlameSeerKharuk",
                "Accept the Ashspeaker spirit trial."
            ),
            talk(
                "AncestorKeeperMogra",
                "Learn the rites of flame, spirit and binding."
            ),
            defeat(
                "AshenSpiritAcolyte",
                4,
                "Recover four personally earned ember fetishes."
            ),
            talk(
                "AncestorKeeperMogra",
                "Return the four ember fetishes."
            ),
            defeat(
                "CinderTotemKeeper",
                1,
                "Recover the keeper's personal ancestor seal."
            ),
            talk(
                "FlameSeerKharuk",
                "Present the seal and complete the Ashspeaker trial."
            ),
        }),
        RequiredProofIds = table.freeze({
            "EmberFetishes4",
            "AncestorSeal",
        }),
        WorldBindingStatus = "NotImplemented",
    }),
    OrcMonk = table.freeze({
        Id = "SpiritclawTrial",
        BranchId = "OrcMonk",
        SourceTitle = "The Spiritclaw Trial",
        StartLevel = 18,
        TransferLevel = 20,
        TransferNpcId = "TotemKeeperRokka",
        Recommendation = "SpiritclawTotemSeal",
        Steps = table.freeze({
            talk(
                "TotemKeeperRokka",
                "Accept the Spiritclaw proving rite."
            ),
            talk(
                "PitSageMorga",
                "Learn the old fist and totem forms."
            ),
            defeat(
                "AshpeltBrawler",
                4,
                "Recover four personally earned spirit knots."
            ),
            talk(
                "PitSageMorga",
                "Return the four spirit knots."
            ),
            defeat(
                "TotemfangChampion",
                1,
                "Recover the champion's personal totem seal."
            ),
            talk(
                "TotemKeeperRokka",
                "Present the seal and complete the Spiritclaw rite."
            ),
        }),
        RequiredProofIds = table.freeze({
            "SpiritKnots4",
            "TotemfangSeal",
        }),
        WorldBindingStatus = "NotImplemented",
    }),
    OrcRaider = table.freeze({
        Id = "WarhowlTrial",
        BranchId = "OrcRaider",
        SourceTitle = "The Warhowl Trial",
        StartLevel = 18,
        TransferLevel = 20,
        TransferNpcId = "WarcallerGorun",
        Recommendation = "WarhowlOathMark",
        Steps = table.freeze({
            talk(
                "WarcallerGorun",
                "Accept the Warhowl proving trial."
            ),
            talk(
                "PitMasterKorga",
                "Learn the raider trial grounds."
            ),
            defeat(
                "AshjawMarauder",
                4,
                "Recover four personally earned ashjaw war marks."
            ),
            talk(
                "PitMasterKorga",
                "Return the four earned war marks."
            ),
            defeat(
                "CraghideChampion",
                1,
                "Recover the champion's personal proving seal."
            ),
            talk(
                "WarcallerGorun",
                "Present the proving seal and take the Warhowl oath."
            ),
        }),
        RequiredProofIds = table.freeze({
            "AshjawWarMarks4",
            "CraghideProvingSeal",
        }),
        WorldBindingStatus = "NotImplemented",
    }),
    ShillienOracle = table.freeze({
        Id = "DuskseerCovenant",
        BranchId = "ShillienOracle",
        SourceTitle = "The Duskseer Covenant",
        StartLevel = 18,
        TransferLevel = 20,
        TransferNpcId = "VeilPriestessMirel",
        Recommendation = "DuskseerCovenantSeal",
        Steps = table.freeze({
            talk(
                "VeilPriestessMirel",
                "Accept the Duskseer covenant."
            ),
            talk(
                "RitualistSaela",
                "Learn the rites used to bind shadow and life."
            ),
            defeat(
                "GloamLeechAcolyte",
                4,
                "Recover four personally earned duskglass beads."
            ),
            talk(
                "RitualistSaela",
                "Return the four duskglass beads."
            ),
            defeat(
                "HollowChoirKeeper",
                1,
                "Recover the keeper's personal covenant seal."
            ),
            talk(
                "VeilPriestessMirel",
                "Present the seal and complete the covenant."
            ),
        }),
        RequiredProofIds = table.freeze({
            "DuskglassBeads4",
            "HollowChoirSeal",
        }),
        WorldBindingStatus = "NotImplemented",
    }),
    DarkWizard = table.freeze({
        Id = "NightweaverTrial",
        BranchId = "DarkWizard",
        SourceTitle = "The Nightweaver Trial",
        StartLevel = 18,
        TransferLevel = 20,
        TransferNpcId = "UmbralScholarVeyra",
        Recommendation = "NightweaverSigil",
        Steps = table.freeze({
            talk(
                "UmbralScholarVeyra",
                "Accept the Nightweaver trial."
            ),
            talk(
                "ArchivistSelyn",
                "Study the fractured shadow focus."
            ),
            defeat(
                "HollowMistAdept",
                4,
                "Recover four personally earned shadow fragments."
            ),
            talk(
                "ArchivistSelyn",
                "Return the four shadow fragments."
            ),
            defeat(
                "GloamRitualist",
                1,
                "Recover the ritualist's personal umbral sigil."
            ),
            talk(
                "UmbralScholarVeyra",
                "Present the sigil and complete the trial."
            ),
        }),
        RequiredProofIds = table.freeze({
            "ShadowFragments4",
            "UmbralRitualSigil",
        }),
        WorldBindingStatus = "NotImplemented",
    }),
    DarkElfAssassin = table.freeze({
        Id = "VeilbladeTrial",
        BranchId = "DarkElfAssassin",
        SourceTitle = "The Veilblade Trial",
        StartLevel = 18,
        TransferLevel = 20,
        TransferNpcId = "ShadeWardenLyss",
        Recommendation = "VeilbladeShadowSeal",
        Steps = table.freeze({
            talk(
                "ShadeWardenLyss",
                "Accept the Veilblade trial."
            ),
            talk(
                "ScoutVael",
                "Learn where the shadow patrol vanished."
            ),
            defeat(
                "NightglassStalker",
                4,
                "Recover four personally earned shadowglass marks."
            ),
            talk(
                "ScoutVael",
                "Return the recovered shadowglass marks."
            ),
            defeat(
                "VeilbreakerCaptain",
                1,
                "Recover the captain's personal veil seal."
            ),
            talk(
                "ShadeWardenLyss",
                "Present the veil seal and complete the trial."
            ),
        }),
        RequiredProofIds = table.freeze({
            "ShadowglassMarks4",
            "VeilbreakerSeal",
        }),
        WorldBindingStatus = "NotImplemented",
    }),
    PalusKnight = table.freeze({
        Id = "DuskguardVigil",
        BranchId = "PalusKnight",
        SourceTitle = "The Duskguard Vigil",
        StartLevel = 18,
        TransferLevel = 20,
        TransferNpcId = "WardenNyx",
        Recommendation = "DuskguardOathSeal",
        Steps = table.freeze({
            talk("WardenNyx", "Accept the Duskguard vigil."),
            talk(
                "WatcherVeyra",
                "Trace the raiders threatening the shadow border."
            ),
            defeat(
                "GloomfangRaider",
                3,
                "Recover three personally earned nightsteel tokens."
            ),
            talk(
                "WatcherVeyra",
                "Return the recovered nightsteel tokens."
            ),
            defeat(
                "UmbralSiegebreaker",
                1,
                "Recover the siegebreaker's personal dusk seal."
            ),
            talk(
                "WardenNyx",
                "Present the dusk seal and complete the vigil."
            ),
        }),
        RequiredProofIds = table.freeze({
            "NightsteelTokens3",
            "UmbralDuskSeal",
        }),
        WorldBindingStatus = "NotImplemented",
    }),
    -- Independent DungeonMMO Warrior route. These identifiers belong
    -- to original game actors and owned loot, not third-party content.
    -- Independent Human Knight story; no borrowed NPC, item or
    -- protected source-game dialogue/monster artwork is required.
    HumanKnight = table.freeze({
        Id = "StonewatchVigil", BranchId = "HumanKnight",
        SourceTitle = "The Stonewatch Vigil",
        StartLevel = 18, TransferLevel = 20,
        TransferNpcId = "CaptainRowan",
        Recommendation = "StonewatchOathSeal",
        Steps = table.freeze({
            talk("CaptainRowan", "Answer the Stonewatch call."),
            talk("QuartermasterDena", "Learn the watch-post signals."),
            defeat("GloamStriker", 3,
                "Recover three personally earned watch-post badges."),
            talk("QuartermasterDena", "Return the three watch badges."),
            defeat("GloamBulwark", 1,
                "Defeat the gate-breaker and recover its ward seal."),
            talk("CaptainRowan", "Present the ward seal and take the oath."),
        }),
        RequiredProofIds = table.freeze({
            "StonewatchBadge3", "GloamBulwarkSeal",
        }),
        WorldBindingStatus = "NotImplemented",
    }),

    HumanWarrior = table.freeze({
        Id = "IronvowTrial", BranchId = "HumanWarrior",
        SourceTitle = "The Ironroot Oath",
        StartLevel = 18, TransferLevel = 20,
        TransferNpcId = "MarshalTorren",
        Recommendation = "IronrootOathToken",
        Steps = table.freeze({
            talk("MarshalTorren", "Hear the Ironroot watcher's request."),
            talk("SmithOrla", "Learn where the raiders broke the line."),
            defeat("RidgeMarauder", 4,
                "Recover four separate Ironroot dispatch markers."),
            talk("SmithOrla", "Return the four earned markers."),
            defeat("Ridgebreaker", 1,
                "Recover the ridgebreaker's personal oath seal."),
            talk("MarshalTorren", "Present the recovered oath seal."),
        }),
        RequiredProofIds = table.freeze({
            "IronrootToken4", "RidgebreakerSigil",
        }),
        WorldBindingStatus = "NotImplemented",
    }),
    -- Original Elven Knight quest: Base NPC steps are implemented first.
    -- Combat proof and the final class award stay locked until authored.
    ElvenKnight = table.freeze({
        Id = "VerdantOathTrial", BranchId = "ElvenKnight",
        SourceTitle = "The Verdant Oath",
        StartLevel = 18, TransferLevel = 20,
        TransferNpcId = "SentinelIlyra",
        Recommendation = "VerdantOathSeal",
        Steps = table.freeze({
            talk("SentinelIlyra", "Answer the grove's watch call."),
            talk("WardenCaer", "Learn the missing patrol's last route."),
            defeat("RootboundMarauder", 3,
                "Recover three personally earned patrol reports."),
            talk("WardenCaer", "Return the patrol reports."),
            defeat("ThornboundColossus", 1,
                "Recover the colossus's personal guardian seal."),
            talk("SentinelIlyra", "Present the seal and swear the oath."),
        }),
        RequiredProofIds = table.freeze({
            "VerdantPatrolReports3", "VerdantGuardianSeal",
        }),
        WorldBindingStatus = "NotImplemented",
    }),
    HumanWizard = table.freeze({
        Id = "EmberglassTrial",
        BranchId = "HumanWizard",
        SourceTitle = "The Emberglass Trial",
        StartLevel = 18,
        TransferLevel = 20,
        TransferNpcId = "MagisterOrwyn",
        Recommendation = "EmberglassAccord",
        Steps = table.freeze({
            talk("MagisterOrwyn", "Answer the Emberglass summons."),
            talk("ArchivistNeris", "Learn how the broken wards are traced."),
            defeat(
                "AshveilAcolyte",
                3,
                "Recover three personally earned aetherglass shards."
            ),
            talk("ArchivistNeris", "Return the three aetherglass shards."),
            defeat(
                "CinderboundConjurer",
                1,
                "Recover the conjurer's personal ember sigil."
            ),
            talk("MagisterOrwyn", "Present the sigil and seal the accord."),
        }),
        RequiredProofIds = table.freeze({
            "AetherglassShards3",
            "CinderboundEmberSigil",
        }),
        WorldBindingStatus = "NotImplemented",
    }),
    ElvenWizard = table.freeze({
        Id = "MoonwellConcord",
        BranchId = "ElvenWizard",
        SourceTitle = "The Moonwell Concord",
        StartLevel = 18,
        TransferLevel = 20,
        TransferNpcId = "ArcanistLethiel",
        Recommendation = "MoonwellConcordSeal",
        Steps = table.freeze({
            talk("ArcanistLethiel", "Accept the Moonwell concord trial."),
            talk("LorekeeperVaela", "Trace the fractured moonwell wards."),
            defeat(
                "DuskbloomAcolyte",
                3,
                "Recover three personally earned moonwell fragments."
            ),
            talk("LorekeeperVaela", "Return the moonwell fragments."),
            defeat(
                "TideglassBinder",
                1,
                "Recover the binder's personal tideglass sigil."
            ),
            talk(
                "ArcanistLethiel",
                "Present the sigil and complete the concord."
            ),
        }),
        RequiredProofIds = table.freeze({
            "MoonwellFragments3",
            "TideglassBinderSigil",
        }),
        WorldBindingStatus = "NotImplemented",
    }),
    ElvenOracle = table.freeze({
        Id = "LifebinderVigil",
        BranchId = "ElvenOracle",
        SourceTitle = "The Lifebinder Vigil",
        StartLevel = 18,
        TransferLevel = 20,
        TransferNpcId = "SeerAelwyn",
        Recommendation = "LifebinderVow",
        Steps = table.freeze({
            talk("SeerAelwyn", "Accept the Lifebinder vigil."),
            talk(
                "KeeperThalia",
                "Learn where the wounded grove spirits were taken."
            ),
            defeat(
                "DuskrootDefiler",
                3,
                "Recover three personally earned living-bark fragments."
            ),
            talk(
                "KeeperThalia",
                "Return the living-bark fragments."
            ),
            defeat(
                "BlightveilBinder",
                1,
                "Recover the binder's personal moonleaf seal."
            ),
            talk(
                "SeerAelwyn",
                "Present the moonleaf seal and complete the vigil."
            ),
        }),
        RequiredProofIds = table.freeze({
            "LivingBarkFragments3",
            "BlightveilMoonleafSeal",
        }),
        WorldBindingStatus = "NotImplemented",
    }),
    HumanCleric = table.freeze({
        Id = "DawnkeeperVigil",
        BranchId = "HumanCleric",
        SourceTitle = "The Dawnkeeper Vigil",
        StartLevel = 18,
        TransferLevel = 20,
        TransferNpcId = "PriestessElara",
        Recommendation = "DawnkeeperVow",
        Steps = table.freeze({
            talk("PriestessElara", "Accept the Dawnkeeper vigil."),
            talk("BrotherTavian", "Learn where the blighted relics lie."),
            defeat(
                "GloamCultist",
                3,
                "Recover three personally earned dawn relic fragments."
            ),
            talk("BrotherTavian", "Return the three relic fragments."),
            defeat(
                "HollowAcolyte",
                1,
                "Recover the acolyte's personal shadow seal."
            ),
            talk(
                "PriestessElara",
                "Present the shadow seal and complete the vigil."
            ),
        }),
        RequiredProofIds = table.freeze({
            "DawnRelicFragments3",
            "HollowAcolyteSeal",
        }),
        WorldBindingStatus = "NotImplemented",
    }),
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
            talk("ScoutCael", "Find Cael at the overgrown outpost."),
            defeat("BrackenWarden", 1,
                "Recover the ward sigil from the Bracken Warden."),
            talk("ScoutCael", "Use the ward sigil to free Cael."),
            talk("WardenThorne", "Report Cael's recovery."),
            talk("PathfinderElyra", "Submit the Greenward field report."),
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
    return table.freeze({
        QUESTS.DwarfScavenger,
        QUESTS.DwarfArtisan,
        QUESTS.DarkWizard,
        QUESTS.DarkElfAssassin,
        QUESTS.HumanKnight, QUESTS.HumanWarrior,
        QUESTS.HumanRogue, QUESTS.HumanWizard,
        QUESTS.HumanCleric, QUESTS.ElvenWizard,
        QUESTS.ElvenOracle, QUESTS.ElvenScout,
        QUESTS.ElvenKnight,
    })
end

return table.freeze(SourceQuests)
