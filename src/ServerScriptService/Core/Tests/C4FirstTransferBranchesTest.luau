--!strict
-- Original Chronicle 4: five historical races and eighteen first transfers.
-- This source-only inventory does not turn unsupported races playable.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared
local Branches = require(Shared.C4FirstTransferBranches)
local Inventory = require(Shared.C4ScoutSkillInventory)
local RaceDefinitions = require(Shared.RaceDefinitions)

local EXPECTED = {
    Human = {
        Fighter = {"Warrior", "Human Knight", "Rogue"},
        Mage = {"Human Wizard", "Cleric"},
    },
    Elf = {
        Fighter = {"Elven Knight", "Elven Scout"},
        Mage = {"Elven Wizard", "Elven Oracle"},
    },
    DarkElf = {
        Fighter = {"Palus Knight", "Assassin"},
        Mage = {"Dark Wizard", "Shillien Oracle"},
    },
    Orc = {
        Fighter = {"Orc Raider", "Orc Monk"},
        Mage = {"Orc Shaman"},
    },
    Dwarf = {
        Fighter = {"Artisan", "Scavenger"},
    },
}
local checks = 0

--[[
Checks one source branch, tier, unique ID or unsupported-class invariant.

Args:
    condition (boolean): Required original Chronicle 4 source fact.
    description (string): Exact failing branch or gate.

Returns:
    nil: Records the assertion or fails the real Studio fixture.
]]
local function check(condition: boolean, description: string)
    checks += 1
    assert(condition, "[C4 First Transfers] " .. description)
end

--[[
Checks source inventory metadata for one partially implemented branch.

Args:
    option (any): First-transfer branch metadata under test.
    race_id (string): Source race used by scout inventory audit.

Returns:
    nil: Raises when a partial branch claims the wrong source inventory.
]]
local function check_partial_branch(
    option: any,
    race_id: string
)
    if option.Id == "HumanWizard" then
        check(
            option.SourceSkillInventory
                == "C4HumanWizardLevel30Sources",
            "Human Wizard partial branch needs its own source inventory"
        )
        return
    end

    if option.Id == "HumanCleric" then
        check(
            option.SourceSkillInventory
                == "C4HumanClericLevel30Sources",
            "Human Cleric partial branch needs its own source inventory"
        )
        return
    end

    check(
        option.SourceSkillInventory == "C4ScoutSkillInventory",
        "Scout partial branch needs the scout source inventory"
    )
    local audit = assert(Inventory.audit(race_id))
    check(
        audit.Missing == 0,
        "Previously implemented Rogue/Scout ranks regressed"
    )
end

--[[
Checks original five-race paths without claiming unimplemented gameplay.

Args:
    None.

Returns:
    nil: Prints actual source and partial-implementation assertions.
]]
local function main()
    local total = 0
    local partial = 0
    local ids = {}
    check(#Branches.races() == 5,
        "Original Chronicle 4 has five playable source races")
    for race_id, families in pairs(EXPECTED) do
        for base_id, names in pairs(families) do
            local options = assert(Branches.get(race_id, base_id))
            check(#options == #names,
                race_id .. " " .. base_id .. " branch count changed")
            for index, source_class in ipairs(names) do
                local option = options[index]
                check(option.SourceClass == source_class
                    and option.SourceRace == race_id,
                    "Wrong original first transfer " .. source_class)
                check(option.SourceTransferLevel == 20
                    and option.SourceQuestStartLevel == 18
                    and type(option.SourceQuestName) == "string"
                    and option.SourceQuestName ~= "",
                    "Original first transfer needs its own level-18 quest")
                check(not ids[option.Id], "Duplicate original class ID")
                ids[option.Id] = true
                check(Branches.find(
                    race_id, base_id, option.Id
                ) == option, "Exact selected path not resolved")
                check(Branches.find(
                    "Human", "Mage", option.Id
                ) == (if race_id == "Human" and base_id == "Mage"
                    then option else nil),
                    "Wrong starting family could select another branch")
                check(not Branches.is_complete(option),
                    "Unimplemented C4 transfer was falsely made playable")
                if option.GameplayStatus == "Partial" then
                    partial += 1
                    check_partial_branch(option, race_id)
                else
                    check(option.GameplayStatus == "NotImplemented",
                        "Unfinished source class was marked implemented")
                end
                total += 1
            end
        end
    end
    check(total == 18 and partial == 4,
        "Original C4 requires eighteen paths, four partially mapped")
    for _, race_id in ipairs({"DarkElf", "Orc", "Dwarf"}) do
        check(RaceDefinitions.get(race_id) == nil,
            "Source class registry cannot prematurely unlock a race")
    end
    check(Branches.get("Dwarf", "Mage") == nil,
        "Invented Dwarven Mystic path must not exist")
    check(Branches.find("Elf", "Fighter", "HumanRogue") == nil,
        "Cross-race class selection must be rejected")
    print(("[C4 First Transfers] PASS: %d assertions, "
        .. "%d original source classes, %d partial."):format(
        checks, total, partial
    ))
end

main()
