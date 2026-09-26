--!strict
-- First-transfer C4 active evade and Elf-only physical guard skill gates.

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared

local Schema = require(Shared.ProfileSchema)
local Progression = require(Shared.SkillProgressionDefinitions)
local Unlocks = require(Shared.SkillUnlockRules)
local Trainers = require(Shared.TrainerCatalogues)
local Effects = require(RS.Combat.Shared.SkillDefinitions)
local Status = require(SSS.Combat.CombatStatusService)

local assertions = 0

--[[
Checks one earned skill or authoritative timed status invariant.

Args:
    condition (boolean): Whether the sourced skill is valid.
    description (string): Detailed test failure diagnostic.

Returns:
    nil: Records success or raises immediately.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 Scout Active Status] " .. description)
end

--[[
Creates a temporary complete source-race Scout character.

Args:
    user_id (number): Isolated fake owner of the detached character.
    race_id (string): Human or Elf.
    class_id (string): Ranger or Rogue gameplay analogue.

Returns:
    any: Editable server-style character for a skill-gating test.
]]
local function make_character(
    user_id: number, race_id: string, class_id: string
): any
    local character = Schema.create_default(user_id).Characters.Slot1
    character.Identity.RaceId = race_id
    character.Identity.BaseClassId = class_id
    character.Identity.ClassId = class_id
    character.Identity.CreationStage = "Complete"
    character.Level = 36
    return character
end

--[[
Checks one race/level-specific source skill against real combat data.

Args:
    race_id (string): Human or Elf authentic source race.
    class_id (string): Authorized gameplay Scout class.
    user_id (number): Fake test-only user ID.

Returns:
    nil: Confirms offered skills and fails closed for an ineligible race.
]]
local function check_training(
    race_id: string, class_id: string, user_id: number
)
    local character = make_character(user_id, race_id, class_id)
    local dodge = assert(Progression.get("ScoutEvasiveFocus"))
    local guard = assert(Progression.get("ElvenScoutGuard"))
    character.Level = 27
    check(not Unlocks.can_show(character, dodge),
        "Active evade was visible below C4 source level 28")
    character.Level = 28
    check(Trainers.can_offer(
        class_id .. "Trainer", character, dodge.Id
    ).ok, "Legitimate Scout cannot train active evade")
    local effect = assert(Effects.get_for_rank(dodge.Id, 1))
    check(effect.KIND == "Buff" and effect.BUFF_KIND == "Evasion"
        and effect.BUFF_MAGNITUDE == 0.14
        and effect.BUFF_SECONDS == 7
        and effect.COOLDOWN_SECONDS > 0
        and effect.STAMINA_COST > 0,
        "Purchased Scout evade is not a real expiring combat buff")

    character.Level = 20
    if race_id == "Elf" then
        check(Trainers.can_offer(
            class_id .. "Trainer", character, guard.Id
        ).ok, "Elf cannot train C4 level-20 defensive buff")
    else
        check(not Unlocks.can_show(character, guard),
            "Elf-only defensive rank leaked to a Human")
    end
    local shield = assert(Effects.get_for_rank(guard.Id, 1))
    check(shield.KIND == "Buff"
        and shield.BUFF_KIND == "PhysicalGuard"
        and shield.BUFF_MAGNITUDE == 0.07
        and shield.MANA_COST > 0,
        "Elf defensive skill has no actual guarded-hit status")
end

--[[
Checks server status magnitude is live only before its expiry.

Args:
    None.

Returns:
    nil: Verifies status readers reject missing, expired and bogus buffs.
]]
local function check_status_lifecycle()
    local character = Instance.new("Model")
    character.Name = "TEMP_C4ScoutStatus"
    character.Parent = workspace
    check(Status.get(character, "Evasion") == 0,
        "Uncast active evade granted a permanent effect")
    character:SetAttribute("C4EvasionBonus", 0.14)
    character:SetAttribute("C4EvasionExpiresAt", os.clock() + 5)
    check(math.abs(Status.get(character, "Evasion") - 0.14)
        < 0.0001, "Live server evade status has no magnitude")
    character:SetAttribute("C4EvasionExpiresAt", os.clock() - 1)
    check(Status.get(character, "Evasion") == 0,
        "Expired evasive focus continued evading")
    character:SetAttribute("C4PhysicalGuardBonus", 0.07)
    character:SetAttribute("C4PhysicalGuardExpiresAt", os.clock() + 5)
    check(math.abs(Status.get(character, "PhysicalGuard") - 0.07)
        < 0.0001, "Elven defensive buff has no real physical reduction")
    character:Destroy()
end

--[[
Runs focused source-class and status-expiry checks without live players.

Args:
    None.

Returns:
    nil: Reports the verified assertion count.
]]
local function main()
    local user_id = 78001
    for _, race_id in ipairs({"Human", "Elf"}) do
        for _, class_id in ipairs({"Ranger", "Rogue"}) do
            check_training(race_id, class_id, user_id)
            user_id += 1
        end
    end
    check_status_lifecycle()
    print(("[C4 Scout Active Status] PASS: %d assertions.")
        :format(assertions))
end

main()
