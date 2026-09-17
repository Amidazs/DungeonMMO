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
    SecondaryClassDefinitions.resolve("Human", "Fighter") == nil,
    "Fighter must not gain an unapproved v1 secondary class."
)
check(
    SecondaryClassDefinitions.resolve("Elf", "Ranger") == nil,
    "Ranger must not gain an unapproved v1 secondary class."
)

print(string.format("[Quest Definition Tests] PASS: %d assertions.", assertions))
