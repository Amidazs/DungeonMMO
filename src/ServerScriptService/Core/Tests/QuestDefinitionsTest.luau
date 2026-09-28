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
    #adventures == 5
        and adventures[1].Id == "WorldrootRelic"
        and adventures[2].Id == "ForestWolfBounty"
        and adventures[3].Id == "MarauderCaptainBounty"
        and adventures[4].Id == "MineEchoes"
        and adventures[5].Id == "ExpeditionProvisioning",
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
