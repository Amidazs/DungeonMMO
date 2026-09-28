--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")

local QuestDefinitions = require(Shared:WaitForChild("QuestDefinitions"))
local SecondaryClassDefinitions = require(
    Shared:WaitForChild("SecondaryClassDefinitions")
)

local assertions = 0

local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Quest Definition Tests] " .. message, 2)
    end
end

local quest = QuestDefinitions.get("MageAdvancementTrial")
check(quest ~= nil, "Mage advancement trial must exist.")
check(quest.MinimumLevel == 20, "Prototype advancement level must be 20.")
check(#quest.Objectives == 1, "Foundation trial must have one objective.")
check(quest.Objectives[1].Type == "DungeonClear", "Trial objective must be a DungeonClear.")
check(quest.Objectives[1].Required == 1, "Trial must require one qualifying clear.")

local human = SecondaryClassDefinitions.resolve("Human", "Mage")
check(human ~= nil, "Human Mage advancement must resolve.")
check(human.Id == "HumanArcanist", "Human Mage must resolve to HumanArcanist.")
check(human.DisplayName == "Arcanist", "Human class display name must be Arcanist.")
check(human.QuestId == "MageAdvancementTrial", "Human advancement must use the Mage trial.")

local elf = SecondaryClassDefinitions.resolve("Elf", "Mage")
check(elf ~= nil, "Elf Mage advancement must resolve.")
check(elf.Id == "ElfSpellweaver", "Elf Mage must resolve to ElfSpellweaver.")
check(elf.DisplayName == "Spellweaver", "Elf class display name must be Spellweaver.")
check(elf.QuestId == "MageAdvancementTrial", "Elf advancement must use the Mage trial.")

check(
    SecondaryClassDefinitions.resolve("Human", "Fighter").Id
        == "HumanVanguard",
    "Human Fighter must resolve to its approved Vanguard class."
)
check(
    SecondaryClassDefinitions.resolve("Elf", "Ranger").Id
        == "ElfWindrunner",
    "Elf Ranger must resolve to its approved Windrunner class."
)
local adventures = QuestDefinitions.adventures()
check(
    #adventures == 11
        and adventures[1].Id == "WorldrootRelic"
        and adventures[2].Id == "ForestWolfBounty"
        and adventures[3].Id == "MarauderCaptainBounty"
        and adventures[4].Id == "HiddenWardDiscovery"
        and adventures[5].Id == "MineEchoes"
        and adventures[6].Id == "RuinSurvey"
        and adventures[7].Id == "MineSurveyorEscort"
        and adventures[8].Id == "CorruptedForemanBounty"
        and adventures[9].Id == "FractureTrail"
        and adventures[10].Id == "DungeonBossHunt"
        and adventures[11].Id == "ExpeditionProvisioning",
    "Adventure catalogue keeps optional bounties beside the story chain."
)

local wolf_bounty = assert(
    QuestDefinitions.get("ForestWolfBounty")
)
check(
    wolf_bounty.PrerequisiteQuestId == "WorldrootRelic"
        and #wolf_bounty.Objectives == 1
        and wolf_bounty.Objectives[1].Type == "EnemyDefeat"
        and wolf_bounty.Objectives[1].TargetId == "forest_wolf"
        and wolf_bounty.Objectives[1].Required == 2,
    "Forest Wolf bounty requires two trusted wolf defeats after Worldroot."
)
check(
    wolf_bounty.Reward.Gold == 40
        and wolf_bounty.Reward.ItemId == nil
        and wolf_bounty.Reward.Items == nil,
    "Forest Wolf bounty is intentionally Gold-only."
)

local captain_bounty = assert(
    QuestDefinitions.get("MarauderCaptainBounty")
)
check(
    captain_bounty.MinimumLevel == 5
        and captain_bounty.PrerequisiteQuestId
            == "WorldrootRelic"
        and #captain_bounty.Objectives == 1
        and captain_bounty.Objectives[1].Type == "EnemyDefeat"
        and captain_bounty.Objectives[1].TargetId
            == "marauder_captain"
        and captain_bounty.Objectives[1].Required == 1,
    "Captain bounty is a level-five optional boss Adventure."
)
check(
    captain_bounty.Reward.Gold == 60
        and captain_bounty.Reward.ItemId == nil
        and captain_bounty.Reward.Items == nil,
    "Captain bounty is intentionally Gold-only."
)

local hidden_ward = assert(
    QuestDefinitions.get("HiddenWardDiscovery")
)
check(
    hidden_ward.MinimumLevel == 6
        and hidden_ward.PrerequisiteQuestId == "WorldrootRelic"
        and #hidden_ward.Objectives == 2
        and hidden_ward.Objectives[1].Type == "WorldInteraction"
        and hidden_ward.Objectives[1].TargetId
            == "TestDungeon:HiddenPanel:Room2"
        and hidden_ward.Objectives[2].Type == "ItemCollected"
        and hidden_ward.Objectives[2].TargetId
            == "hidden_ward_fragment",
    "Hidden Ward Adventure combines interaction and item collection."
)
check(
    type(hidden_ward.TurnInItems) == "table"
        and #hidden_ward.TurnInItems == 1
        and hidden_ward.TurnInItems[1].ItemId
            == "hidden_ward_fragment"
        and hidden_ward.Reward.Gold == 50
        and hidden_ward.Reward.Items[1].ItemId
            == "warding_essence",
    "Hidden Ward Adventure turns in its quest fragment for a mixed reward."
)

local ruin_survey = assert(
    QuestDefinitions.get("RuinSurvey")
)
check(
    ruin_survey.MinimumLevel == 8
        and ruin_survey.PrerequisiteQuestId == "MineEchoes"
        and #ruin_survey.Objectives == 2
        and ruin_survey.Objectives[1].Type
            == "CheckpointReached"
        and ruin_survey.Objectives[1].TargetId
            == "TestDungeon:EncounterStart:CombatRoom2"
        and ruin_survey.Objectives[2].Type
            == "CheckpointReached"
        and ruin_survey.Objectives[2].TargetId
            == "AbandonedMine:EncounterStart:CombatRoom2",
    "Ruin Survey uses two released trusted checkpoint objectives."
)
check(
    ruin_survey.Reward.Gold == 60
        and type(ruin_survey.Reward.Items) == "table"
        and #ruin_survey.Reward.Items == 4,
    "Ruin Survey pays Gold plus the reviewed component cache."
)

local surveyor_escort = assert(
    QuestDefinitions.get("MineSurveyorEscort")
)
check(
    surveyor_escort.MinimumLevel == 9
        and surveyor_escort.PrerequisiteQuestId == "MineEchoes"
        and #surveyor_escort.Objectives == 1
        and surveyor_escort.Objectives[1].Type
            == "EscortCompleted"
        and surveyor_escort.Objectives[1].TargetId
            == "AbandonedMine:MineSurveyor",
    "Lost Surveyor is a level-nine trusted escort Adventure."
)
check(
    surveyor_escort.Reward.Gold == 70
        and type(surveyor_escort.Reward.Items) == "table"
        and #surveyor_escort.Reward.Items == 1
        and surveyor_escort.Reward.Items[1].ItemId
            == "deep_iron_ore"
        and surveyor_escort.Reward.Items[1].Quantity == 2,
    "Lost Surveyor pays Gold plus two tradeable Deep Iron Ore."
)

local foreman_bounty = assert(
    QuestDefinitions.get("CorruptedForemanBounty")
)
check(
    foreman_bounty.MinimumLevel == 10
        and foreman_bounty.PrerequisiteQuestId == "MineEchoes"
        and #foreman_bounty.Objectives == 1
        and foreman_bounty.Objectives[1].Type == "EnemyDefeat"
        and foreman_bounty.Objectives[1].TargetId
            == "corrupted_foreman"
        and foreman_bounty.Objectives[1].Required == 1,
    "Foreman bounty is a level-ten optional Mine boss Adventure."
)
check(
    foreman_bounty.Reward.Gold == 80
        and foreman_bounty.Reward.ItemId == nil
        and foreman_bounty.Reward.Items == nil,
    "Foreman bounty is intentionally Gold-only."
)

local fracture_trail = assert(
    QuestDefinitions.get("FractureTrail")
)
check(
    fracture_trail.MinimumLevel == 12
        and fracture_trail.PrerequisiteQuestId == "RuinSurvey"
        and #fracture_trail.Objectives == 2
        and fracture_trail.Objectives[1].Type
            == "CheckpointReached"
        and fracture_trail.Objectives[1].TargetId
            == "TestDungeon:EncounterStart:CombatRoom2"
        and fracture_trail.Objectives[2].Type == "DungeonClear"
        and fracture_trail.Objectives[2].TargetId
            == "AbandonedMine",
    "Fracture Trail mixes a trusted checkpoint with a fresh Mine clear."
)
check(
    fracture_trail.Reward.Gold == 90
        and type(fracture_trail.Reward.Items) == "table"
        and #fracture_trail.Reward.Items == 1
        and fracture_trail.Reward.Items[1].ItemId
            == "warding_essence"
        and fracture_trail.Reward.Items[1].Quantity == 2,
    "Fracture Trail pays the reviewed Gold plus Warding Essence reward."
)

local boss_hunt = assert(
    QuestDefinitions.get("DungeonBossHunt")
)
check(
    boss_hunt.MinimumLevel == 15
        and boss_hunt.PrerequisiteQuestId == "MineEchoes"
        and #boss_hunt.Objectives == 2
        and boss_hunt.Objectives[1].TargetId == "marauder_captain"
        and boss_hunt.Objectives[2].TargetId == "corrupted_foreman",
    "Break the Chain is a level-fifteen released dual-boss Adventure."
)
check(
    boss_hunt.Reward.Gold == 120
        and boss_hunt.Reward.ItemId == nil
        and boss_hunt.Reward.Items == nil,
    "Break the Chain is intentionally Gold-only."
)
check(
    QuestDefinitions.get("MineEchoes").PrerequisiteQuestId
        == "WorldrootRelic",
    "Optional wolf bounty must not block the Mine story quest."
)

local provisioning = assert(
    QuestDefinitions.get("ExpeditionProvisioning")
)
check(
    provisioning.PrerequisiteQuestId == "MineEchoes",
    "Provisioning must follow the existing Mine story quest."
)
check(
    #provisioning.Objectives == 2
        and provisioning.Objectives[1].TargetId == "TestDungeon"
        and provisioning.Objectives[2].TargetId == "AbandonedMine",
    "Provisioning must require one fresh clear of both launch dungeons."
)
check(
    type(provisioning.Reward.Items) == "table"
        and #provisioning.Reward.Items == 3
        and provisioning.Reward.Gold == 75,
    "Provisioning must expose the reviewed three-material reward bundle."
)

for _, trial_id in ipairs({
    "FighterAdvancementTrial",
    "MageAdvancementTrial",
    "RangerAdvancementTrial",
    "RogueAdvancementTrial",
}) do
    local trial = assert(QuestDefinitions.get(trial_id))
    check(
        trial.MinimumLevel == 20 and #trial.SkillPrerequisites == 2,
        "Every first advancement requires level 20 and two mastered skills."
    )
    for _, requirement in ipairs(trial.SkillPrerequisites) do
        check(
            requirement.Rank == 3 and requirement.Proficiency >= 300,
            "Each required basic skill needs full rank and earned mastery."
        )
    end
end

print(string.format("[Quest Definition Tests] PASS: %d assertions.", assertions))
