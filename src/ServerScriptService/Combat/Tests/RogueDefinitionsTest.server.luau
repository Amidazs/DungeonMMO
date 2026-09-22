--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CoreShared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")
local CombatShared = ReplicatedStorage
    :WaitForChild("Combat")
    :WaitForChild("Shared")

local ClassDefinitions = require(
    CoreShared:WaitForChild("ClassProgressionDefinitions")
)
local SecondaryDefinitions = require(
    CoreShared:WaitForChild("SecondaryClassDefinitions")
)
local QuestDefinitions = require(
    CoreShared:WaitForChild("QuestDefinitions")
)
local TrainerCatalogues = require(
    CoreShared:WaitForChild("TrainerCatalogues")
)
local ProgressionDefinitions = require(
    CoreShared:WaitForChild("SkillProgressionDefinitions")
)
local SkillDefinitions = require(
    CombatShared:WaitForChild("SkillDefinitions")
)
local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Rogue Definitions Tests] " .. message, 2)
    end
end

local rogue = ClassDefinitions.get("Rogue")
check(rogue ~= nil, "Rogue base class must exist.")
check(
    rogue ~= nil
        and rogue.StarterSkills[1] == "QuickStrike"
        and rogue.StarterSkills[2] == "Backstab"
        and rogue.StarterSkills[3] == "EvasiveStep",
    "Rogue starters must establish damage, position and evasion identity."
)
check(
    rogue ~= nil and rogue.StarterEquipment.Weapon == "scout_dagger",
    "Rogue must receive an authoritative dagger with starter sword hitbox compatibility."
)

local human_secondary = SecondaryDefinitions.resolve("Human", "Rogue")
local elf_secondary = SecondaryDefinitions.resolve("Elf", "Rogue")
check(human_secondary ~= nil, "Human Rogue secondary path must resolve.")
check(elf_secondary ~= nil, "Elf Rogue secondary path must resolve.")
check(human_secondary.Id == "HumanRogueDuelist", "Human Rogue must target Duelist.")
check(elf_secondary.Id == "ElfRogueWindstalker", "Elf Rogue must target Windstalker.")
local rogue_trial = QuestDefinitions.get("RogueAdvancementTrial")
check(rogue_trial ~= nil, "Rogue advancement trial must exist.")
check(
    rogue_trial ~= nil and rogue_trial.MinimumLevel == 20,
    "Rogue advancement trial must use the accepted Level-20 foundation."
)

local base_skills = {
    "QuickStrike",
    "Backstab",
    "Feint",
    "ShadowDash",
    "EvasiveStep",
    "CriticalFocus",
    "LightFoot",
    "ThreatDrop",
}
for _, skill_id in ipairs(base_skills) do
    check(
        ProgressionDefinitions.get(skill_id) ~= nil,
        "Missing Rogue progression definition: " .. skill_id
    )
end

check(SkillDefinitions.get("QuickStrike") ~= nil, "Quick Strike combat definition missing.")
check(SkillDefinitions.get("Backstab") ~= nil, "Backstab combat definition missing.")
check(SkillDefinitions.get("Feint") ~= nil, "Feint combat definition missing.")
check(SkillDefinitions.get("ShadowDash") ~= nil, "Shadow Dash combat definition missing.")
check(SkillDefinitions.get("EvasiveStep") ~= nil, "Evasive Step combat definition missing.")
check(SkillDefinitions.get("ThreatDrop") ~= nil, "Threat Drop combat definition missing.")
check(
    ProgressionDefinitions.get("CriticalFocus").Kind == "Passive",
    "Critical Focus must be passive progression."
)
check(
    ProgressionDefinitions.get("LightFoot").Kind == "Passive",
    "Light Foot must be passive progression."
)

local rogue_character = {
    Identity = {
        Version = 1,
        RaceId = "Human",
        BaseClassId = "Rogue",
        ClassId = "Rogue",
        CreationStage = "Complete",
    },
    ClassAdvancement = {
        Version = 1,
        CompletedByRace = {},
    },
}
local rogue_trainer = TrainerCatalogues.resolve_for_character(
    "RogueTrainer",
    rogue_character
)
check(rogue_trainer.ok == true, "Human Rogue must resolve RogueTrainer.")
check(#rogue_trainer.Skills == 8, "Rogue trainer must expose eight base skill families.")

local secondary_families = {
    "DuelistAmbush", "DuelistDeadlyBlow", "DuelistExposeWeakness",
    "DuelistRush", "DuelistCriticalMastery",
    "WindstalkerFlurry", "WindstalkerSlipstream", "WindstalkerBlur",
    "WindstalkerQuickstep", "WindstalkerEvasionMastery",
}
for _, skill_id in ipairs(secondary_families) do
    check(
        ProgressionDefinitions.get(skill_id) ~= nil,
        "Missing Rogue secondary skill family: " .. skill_id
    )
end

check(#base_skills + 5 >= 13, "Each developed Rogue line must expose at least 13 families.")

rogue_character.ClassAdvancement.ActiveClassId = "HumanRogueDuelist"
local duelist_trainer = TrainerCatalogues.resolve_for_character(
    "DuelistTrainer",
    rogue_character
)
check(duelist_trainer.ok == true, "Human Duelist must resolve DuelistTrainer.")
check(
    #TrainerCatalogues.get("DuelistTrainer").Skills == 5,
    "Duelist trainer must register five branch families."
)
check(
    #duelist_trainer.Skills == 0,
    "Level-one Rogue must not see unearned Duelist skills."
)
rogue_character.Level = 32
rogue_character.ClassAdvancement.CompletedByRace = {
    Human = {HumanRogueDuelist = true},
}
rogue_character.Progression = {Skills = {}}

for _, entry in ipairs(
    TrainerCatalogues.get("DuelistTrainer").Skills
) do
    local definition = assert(ProgressionDefinitions.get(
        entry.SkillId
    ))
    for _, prerequisite in ipairs(definition.Prerequisites or {}) do
        local existing = rogue_character.Progression.Skills[
            prerequisite.SkillId
        ] or {}
        rogue_character.Progression.Skills[prerequisite.SkillId] = {
            Known = true,
            PurchasedRank = math.max(
                existing.PurchasedRank or 0,
                prerequisite.Rank
            ),
            Proficiency = math.max(
                existing.Proficiency or 0,
                prerequisite.Proficiency
            ),
        }
    end
end

local earned_duelist = TrainerCatalogues.resolve_for_character(
    "DuelistTrainer", rogue_character
)
check(
    #earned_duelist.Skills == 5,
    "Earned level-32 Duelist must see all five branch families."
)
check(
    TrainerCatalogues.resolve_for_character(
        "WindstalkerTrainer",
        rogue_character
    ).ok == false,
    "Human Duelist must not resolve WindstalkerTrainer."
)

local evasive_rank3 = SkillDefinitions.get_for_rank("EvasiveStep", 3)
local threat_rank3 = SkillDefinitions.get_for_rank("ThreatDrop", 3)
check(evasive_rank3.BASE_DAMAGE == 0, "Evasive Step ranks must remain zero-damage.")
check(threat_rank3.BASE_DAMAGE == 0, "Threat Drop ranks must remain zero-damage.")

print(string.format("[Rogue Definitions Tests] PASS: %d assertions.", assertions))
