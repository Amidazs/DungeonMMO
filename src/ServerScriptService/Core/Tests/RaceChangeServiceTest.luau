--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Core = ServerScriptService:WaitForChild("Core")
local Adapters = Core:WaitForChild("Adapters")
local Services = Core:WaitForChild("Services")

local InMemoryProfileAdapter = require(Adapters:WaitForChild("InMemoryProfileAdapter"))
local ProfileService = require(Services:WaitForChild("ProfileService"))
local RaceChangeService = require(Services:WaitForChild("RaceChangeService"))
local InventoryService = require(Services:WaitForChild("InventoryService"))

local assertions = 0
local function check(value: boolean, message: string)
    assertions += 1
    if not value then error("[Race Change Service Tests] " .. message, 2) end
end

local profiles = ProfileService.new(InMemoryProfileAdapter.new())
assert(profiles:load(8201))
assert(profiles:mutate(8201, function(profile: any)
    local c = profile.Characters.Slot1
    c.Identity = {
        Version = 1, RaceId = "Human", BaseClassId = "Rogue",
        ClassId = "Rogue", CreationStage = "Complete",
    }
    c.Progression.SkillPointEntitlement = 30
    c.Progression.Attributes = {Strength=7,Dexterity=5,Vitality=7,Intellect=5,Spirit=5}
    c.Progression.Skills.QuickStrike = {
        Known=true, StarterGranted=true, PurchasedRank=1, Proficiency=50,
    }
    c.Progression.Skills.DuelistDeadlyBlow = {
        Known=true, StarterGranted=false, PurchasedRank=2, Proficiency=250,
    }
    c.Progression.Loadout = {[1]="QuickStrike", [2]="DuelistDeadlyBlow"}
    c.ClassAdvancement = {
        Version = 1,
        CompletedByRace = {
            Human = {HumanRogueDuelist = true},
            Elf = {ElfRogueWindstalker = true},
        },
        ActiveClassId = "HumanRogueDuelist",
    }
    c.RaceChange.ArchivedByRace.Elf = {
        Skills = {
            WindstalkerFlurry = {
                Known=true, StarterGranted=false, PurchasedRank=2, Proficiency=300,
            },
        },
        Advancement = {},
    }
end))

local service = RaceChangeService.new(profiles, "TEST", function() return 123456 end)
local preview = service:preview(8201, "Elf")
check(preview.ok == true, "TEST preview must succeed.")
local entitlement_before = assert(profiles:get_character(8201, 1)).Progression.SkillPointEntitlement
local book_before = InventoryService.count_item(assert(profiles:get_character(8201, 1)), "arc_slash_book")

local applied = service:apply(8201, "Elf", preview.Hash, "race-tx-1")
check(applied.ok == true and applied.already_applied == false,
    "First Race Change apply must succeed once.")
local elf = assert(profiles:get_character(8201, 1))
check(elf.Identity.RaceId == "Elf", "Race must change to Elf.")
check(elf.ClassAdvancement.ActiveClassId == "ElfRogueWindstalker",
    "Completed target-race advancement must become active.")
check(elf.Progression.Skills.DuelistDeadlyBlow.Known == false,
    "Human secondary skill must be deactivated.")
check(elf.Progression.Skills.WindstalkerFlurry.Known == true
        and elf.Progression.Skills.WindstalkerFlurry.PurchasedRank == 0
        and elf.Progression.Skills.WindstalkerFlurry.Proficiency == 300,
    "Archived target skill knowledge/proficiency must restore without refunded ranks.")
check(elf.Progression.SkillPointEntitlement == entitlement_before,
    "Race Change must not increase lifetime SP entitlement.")
check(InventoryService.count_item(elf, "arc_slash_book") == book_before,
    "Race Change must not manufacture consumed/refund Skill Books.")
check(elf.ClassAdvancement.CompletedByRace.Human.HumanRogueDuelist == true
        and elf.ClassAdvancement.CompletedByRace.Elf.ElfRogueWindstalker == true,
    "Per-race advancement history must remain recorded.")
check(elf.RaceChange.ArchivedByRace.Human.Skills.DuelistDeadlyBlow.Proficiency == 250,
    "Source secondary proficiency must be archived.")

local replay = service:apply(8201, "Elf", preview.Hash, "race-tx-1")
check(replay.ok == true and replay.already_applied == true,
    "Same Race Change transaction must replay stored receipt.")
check(assert(profiles:get_character(8201, 1)).Identity.RaceId == "Elf",
    "Replay must not change state again.")

assert(profiles:mutate(8201, function(profile: any)
    profile.Characters.Slot1.Equipment.Helmet = "test_elf_helmet"
end))
local back_preview = service:preview(8201, "Human")
check(back_preview.ok == true, "Round-trip preview back to Human must succeed.")
check(#back_preview.EquipmentSlotsToUnequip == 1
        and back_preview.EquipmentSlotsToUnequip[1] == "Helmet",
    "Elf-only equipment must be unequipped on Human return.")
local back = service:apply(8201, "Human", back_preview.Hash, "race-tx-2")
check(back.ok == true, "Round-trip apply back to Human must succeed.")
local human = assert(profiles:get_character(8201, 1))
check(human.Identity.RaceId == "Human", "Round trip must restore Human race.")
check(human.ClassAdvancement.ActiveClassId == "HumanRogueDuelist",
    "Historical Human advancement must reactivate.")
check(human.Progression.Skills.DuelistDeadlyBlow.Known == true
        and human.Progression.Skills.DuelistDeadlyBlow.PurchasedRank == 0
        and human.Progression.Skills.DuelistDeadlyBlow.Proficiency == 250,
    "Returning race restores skill knowledge/proficiency but not refunded ranks.")
check(human.Equipment.Helmet == nil, "Invalid equipment must remain unequipped.")
assert(profiles:load(8202))
assert(profiles:mutate(8202, function(profile: any)
    local c = profile.Characters.Slot1
    c.Identity = {
        Version = 1, RaceId = "Human", BaseClassId = "Fighter",
        ClassId = "Fighter", CreationStage = "Complete",
    }
    c.Progression.Attributes = {Strength=5,Dexterity=4,Vitality=6,Intellect=5,Spirit=5}
end))
local stale_preview = service:preview(8202, "Elf")
check(stale_preview.ok == true, "Stale-preview fixture must preview successfully.")
assert(profiles:mutate(8202, function(profile: any)
    profile.Characters.Slot1.Progression.Attributes.Strength += 1
end))
local stale = service:apply(8202, "Elf", stale_preview.Hash, "race-stale")
check(stale.ok == false and stale.reason == "RaceChangePreviewStale",
    "Apply must reject when authoritative profile changed after preview.")
check(assert(profiles:get_character(8202, 1)).Identity.RaceId == "Human",
    "Stale preview rejection must not mutate race.")

local prod = RaceChangeService.new(profiles, "PROD")
local blocked = prod:preview(8201, "Elf")
check(blocked.ok == false and blocked.reason == "RaceChangeUnavailable",
    "Race Change must fail closed in PROD.")

print(string.format("[Race Change Service Tests] PASS: %d assertions.", assertions))
