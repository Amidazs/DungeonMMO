--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")

local module = Shared:FindFirstChild("TrainerCatalogues")
if not module then
    error("[Trainer Catalogues Tests] RED: TrainerCatalogues is missing.")
end

local TrainerCatalogues = require(module)
local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Trainer Catalogues Tests] " .. message, 2)
    end
end

local function fighter(race_id: string): any
    return {
        Identity = {
            Version = 1,
            RaceId = race_id,
            BaseClassId = "Fighter",
            ClassId = "Fighter",
            CreationStage = "Complete",
        },
    }
end

--[[
Finds a registered trainer skill without relying on a fixed UI row order.

Args:
    skills (any): Actual class-filtered trainer skill catalogue.
    skill_id (string): Expected permanent skill identifier.

Returns:
    any?: Registered trainer entry or nil when absent.
]]
local function find_skill(skills: any, skill_id: string): any?
    for _, entry in ipairs(skills) do
        if entry.SkillId == skill_id then
            return entry
        end
    end
    return nil
end

local human = TrainerCatalogues.resolve_for_character("FighterTrainer", fighter("Human"))
local elf = TrainerCatalogues.resolve_for_character("FighterTrainer", fighter("Elf"))
check(human.ok == true, "Human Fighter must resolve FighterTrainer.")
check(elf.ok == true, "Elf Fighter must resolve FighterTrainer.")
check(type(human.Trainer) == "table", "trainer snapshot must exist.")
check(human.Trainer.DisplayName == "Fighter Trainer", "trainer display name mismatch.")
check(#human.Trainer.Skills >= 5,
    "Fighter trainer must expose novice and starter combat skills.")
for _, skill_id in ipairs({
    "NoviceProtection", "ShieldBash", "Mend", "ArcSlash", "Taunt",
}) do
    check(find_skill(human.Trainer.Skills, skill_id) ~= nil,
        skill_id .. " missing from starting Fighter trainer.")
end
local arc_slash = find_skill(human.Trainer.Skills, "ArcSlash")
check(arc_slash.SourceItemId == "arc_slash_book_bound",
    "Arc Slash book source mismatch.")
check(
    TrainerCatalogues.can_offer(
        "FighterTrainer", fighter("Human"), "Taunt"
    ).ok == true,
    "Fighter Trainer must offer Taunt."
)
check(TrainerCatalogues.can_offer("FighterTrainer", fighter("Human"), "FakeSkill").ok == false, "arbitrary skill must reject.")

print(string.format("[Trainer Catalogues Tests] PASS: %d assertions.", assertions))
