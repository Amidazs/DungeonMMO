--!strict
-- New Elven Scout C4 ranks: real source gates and authored combat effects.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared
local Schema = require(Shared.ProfileSchema)
local Skills = require(Shared.SkillProgressionDefinitions)
local Unlocks = require(Shared.SkillUnlockRules)
local Trainers = require(Shared.TrainerCatalogues)
local Combat = require(RS.Combat.Shared.SkillDefinitions)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)
local Status = require(SSS.Combat.CombatStatusService)
local Slow = require(SSS.Combat.RangerSlowService)

local checks = 0
local SPECS = {
    {Id = "ElvenScoutCureWounds", Level = 24, Kind = "MageHeal"},
    {Id = "ElvenScoutBattleFocus", Level = 28, Kind = "Buff"},
    {Id = "ElvenScoutWindRun", Level = 32, Kind = "Buff"},
    {Id = "ElvenScoutSnaringShot", Level = 36,
        Kind = "RangerProjectile"},
}

--[[
Raises on an invalid source, trainer or authoritative combat contract.

Args:
    condition (boolean): Required server-owned gameplay property.
    message (string): Precise Studio failure diagnostic.

Returns:
    nil: Increments the count after every successful assertion.
]]
local function check(condition: boolean, message: string)
    checks += 1
    assert(condition, "[C4 Elf Scout Missing Skills] " .. message)
end

--[[
Creates an isolated source-appropriate Ranger or Rogue character.

Args:
    race_id (string): Actual Human or Elf race.
    class_id (string): Supported Ranger or Rogue class.
    owner_id (number): Unique isolated server runtime identity.

Returns:
    any: Editable, properly equipped character for rank gates.
]]
local function character_for(
    race_id: string, class_id: string, owner_id: number
): any
    local character = Schema.create_default(owner_id).Characters.Slot1
    character.Identity.RaceId = race_id
    character.Identity.ClassId = class_id
    character.Identity.BaseClassId = class_id
    character.Identity.CreationStage = "Complete"
    character.Equipment.Weapon = if class_id == "Ranger"
        then "apprentice_longbow" else "scout_dagger"
    character.Level = 36
    return character
end

--[[
Checks level/race/class/weapon/owned-rank restrictions on all four skills.

Args:
    spec (any): Source skill, purchase level and execution kind.
    class_id (string): Requested Ranger or Rogue branch.
    owner_id (number): Isolated combat runtime identity.

Returns:
    nil: Verifies only the intended race and branch can execute.
]]
local function check_ownership(
    spec: any, class_id: string, owner_id: number
)
    local source = assert(Skills.get(spec.Id))
    local elf = character_for("Elf", class_id, owner_id)
    elf.Level = spec.Level - 1
    check(not Unlocks.can_show(elf, source),
        spec.Id .. " appeared before its source level")
    elf.Level = spec.Level
    check(Unlocks.can_show(elf, source),
        spec.Id .. " cannot unlock at its source level")
    local trainer_id = class_id .. "Trainer"
    check(Trainers.can_offer(trainer_id, elf, spec.Id).ok,
        "Missing legitimate class trainer offer for " .. spec.Id)

    local human = character_for("Human", class_id, owner_id + 100)
    check(not Unlocks.can_show(human, source),
        "Human class can unlock Elf-only skill " .. spec.Id)
    check(not Trainers.can_offer(
        trainer_id, human, spec.Id
    ).ok, "Human trainer sells Elf-only rank " .. spec.Id)

    elf.Progression.Skills[spec.Id] = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    elf.Progression.Loadout[1] = spec.Id
    Runtime.set_character(owner_id, elf)
    check(Runtime.is_skill_usable(owner_id, spec.Id),
        "Server rejected owned/equipped skill " .. spec.Id)
    if spec.Id == "ElvenScoutSnaringShot" then
        elf.Equipment.Weapon = nil
        Runtime.set_character(owner_id, elf)
        check(not Runtime.is_skill_usable(owner_id, spec.Id),
            "Snaring Shot bypassed its required equipped longbow")
    end
    Runtime.clear_character(owner_id)
end

--[[
Checks the four real combat definitions and real slow/expiry primitives.

Args:
    None.

Returns:
    nil: Rejects inert spellbook entries, fake speed and cosmetic snare.
]]
local function check_effects()
    for _, spec in ipairs(SPECS) do
        local effect = assert(Combat.get_for_rank(spec.Id, 1))
        check(effect.KIND == spec.Kind
            and effect.COOLDOWN_SECONDS > 0,
            spec.Id .. " lacks a real costly, cooldown-gated action")
        if spec.Kind == "MageHeal" then
            check(effect.SELF_ONLY == true
                and effect.TOTAL_HEAL > 0 and effect.MANA_COST > 0
                and effect.ELF_INSTANT_FRACTION == 1,
                "Wound recovery must only restore real owner health")
        elseif spec.Kind == "Buff" then
            local kind = if spec.Id == "ElvenScoutWindRun"
                then "Movement" else "PhysicalPower"
            check(effect.BUFF_KIND == kind
                and effect.BUFF_MAGNITUDE > 0
                and effect.BUFF_SECONDS > 0
                and effect.STAMINA_COST > 0,
                "Buff must actually use the paid timed status engine")
        else
            check(effect.MAX_TARGETS == 1
                and effect.ELF_SLOW_FRACTION > 0
                and effect.ELF_SLOW_SECONDS > 0
                and effect.BASE_DAMAGE > 0,
                "Snaring Shot requires real server bow damage and slow")
        end
    end

    local npc = Instance.new("Model")
    npc.Name = "C4ElfScoutSnare_TEMP"
    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = npc
    npc.Parent = workspace
    check(Slow.apply(npc, 0.35, 0.06),
        "Server NPC slow must apply a genuine movement multiplier")
    check(math.abs(Slow.get_multiplier(npc) - 0.65) < 0.001,
        "Snare has no real server-owned enemy speed impairment")
    task.wait(0.10)
    check(Slow.get_multiplier(npc) == 1,
        "Expired Scout snare continued reducing enemy movement")
    npc:Destroy()

    local status_owner = Instance.new("Model")
    status_owner.Name = "C4ElfScoutBuff_TEMP"
    status_owner.Parent = workspace
    check(Status.get(status_owner, "Movement") == 0,
        "Missing genuine movement cast must provide no free speed")
    status_owner:Destroy()
end

--[[
Executes the four-source-rank, both-race, both-branch focused contract.

Args:
    None.

Returns:
    nil: Reports exactly the checked isolated source/effect assertions.
]]
local function main()
    for index, spec in ipairs(SPECS) do
        check_ownership(spec, "Ranger", 99400 + index)
        if spec.Id ~= "ElvenScoutSnaringShot" then
            check_ownership(spec, "Rogue", 99450 + index)
        end
    end
    check_effects()
    print(("[C4 Elf Scout Missing Skills] PASS: %d assertions")
        :format(checks))
end

main()
