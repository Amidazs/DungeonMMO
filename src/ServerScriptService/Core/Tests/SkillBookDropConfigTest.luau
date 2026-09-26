--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")

local module = Shared:FindFirstChild("SkillBookDropConfig")
if not module then
    error("[Skill Book Drop Config Tests] RED: SkillBookDropConfig is missing.")
end

local Config = require(module)
local ItemDefinitions = require(Shared:WaitForChild("ItemDefinitions"))

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Skill Book Drop Config Tests] " .. message, 2)
    end
end

local boss = Config.get_boss("MarauderCaptain")
local foreman = Config.get_boss("CorruptedForeman")
local temple = Config.get_completion("TestDungeon")
local mine = Config.get_completion("AbandonedMine")

check(boss ~= nil and boss.Chance == 0.02, "Marauder Captain chance must be 2%.")
check(foreman ~= nil and foreman.Chance == 0.02, "Corrupted Foreman chance must be 2%.")
check(temple ~= nil and temple.Chance == 0.01, "Temple completion chance must be 1%.")
check(mine ~= nil and mine.Chance == 0.01, "Mine completion chance must be 1%.")

local book = ItemDefinitions.get("arc_slash_book")
check(book ~= nil, "tradable Arc Slash book must exist.")
check(book.Name == "Arc Slash Skill Book", "book must be identified by exact name.")
check(
    book.Kind == "SkillBook"
        and book.SkillId == "ArcSlash"
        and book.Learnable == true,
    "book must teach Arc Slash."
)
check(
    book.Stackable == true
        and book.Tradeable == true
        and book.Bound == false,
    "book must be stackable and tradable."
)

local low: any = {}
function low:NextNumber(minimum: number, _maximum: number): number
    return minimum
end

local high: any = {}
function high:NextNumber(_minimum: number, maximum: number): number
    return maximum
end

check(Config.roll(boss, low) == "arc_slash_book", "low deterministic roll must succeed.")
check(Config.roll(boss, high) == nil, "high deterministic roll must fail.")
check(Config.first_item(mine) == "arc_slash_book", "first configured item must be Arc Slash book.")

print(string.format("[Skill Book Drop Config Tests] PASS: %d assertions.", assertions))
