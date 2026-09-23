--!strict
-- Optional personal advancement enemies inside existing instanced combat packs.
-- This module does not create a new dungeon, teleport, quest or class award.
local ServerScriptService = game:GetService("ServerScriptService")
local DungeonMarauderFactory = require(
    ServerScriptService.Dungeon.DungeonMarauderFactory
)
local Source = require(
    game:GetService("ReplicatedStorage")
        .Core.Shared.C4OriginalFirstTransferQuestStages
)

local Spawns = {}
local PER_BRANCH_PER_ROOM = 2
local CHALLENGES = table.freeze({
    HumanRogue = table.freeze({
        Name = "Crypt Sentinel",
        SourceId = "CryptSentinel",
        Health = 65,
    }),
    ElvenScout = table.freeze({
        Name = "Bracken Raider",
        SourceId = "BrackenRaider",
        Health = 65,
    }),
    HumanRogueSix = table.freeze({
        Name = "Cinder Brigand",
        SourceId = "CinderBrigand",
        BranchId = "HumanRogue",
        Step = 6,
        Health = 95,
    }),
    ElvenScoutSix = table.freeze({
        Name = "Bracken Warden",
        SourceId = "BrackenWarden",
        BranchId = "ElvenScout",
        Step = 6,
        Health = 105,
    }),
})

--[[
Finds source challenge branches selected by participating loaded characters.

Args:
    profiles (any): Current authoritative Dungeon profile service.
    user_ids ({number}): Server-owned active encounter member roster.

Returns:
    {string}: Sorted eligible branch/stage challenge identifiers.
]]
function Spawns.eligible_branches(
    profiles: any, user_ids: {number}
): {string}
    local found = {}
    for _, user_id in ipairs(user_ids) do
        local character = profiles:get_character(user_id)
        local advancement = character and character.ClassAdvancement
        local state = advancement
            and advancement.OriginalFirstTransferQuest
        local branch = state and state.BranchId
        local quest = branch and Source.get(branch)
        local challenge_id = if state and state.Step == 6
            and branch == "HumanRogue"
            then "HumanRogueSix"
            elseif state and (state.Step == 5 or state.Step == 6)
                and branch == "ElvenScout"
            then "ElvenScoutSix" else branch
        local challenge = CHALLENGES[challenge_id]
        local step = quest and quest.Steps[
            if challenge_id == "ElvenScoutSix"
                then 6 else state.Step
        ]
        if quest and challenge and state.Ready ~= true
            and step and step.Kind == "QuestMonsterDefeat"
            and step.TargetId == challenge.SourceId
            and advancement.OriginalFirstTransferChoiceId == branch
            and character.Level >= quest.StartLevel
            and character.Identity
            and character.Identity.ClassId == "Fighter"
        then
            found[challenge_id] = true
        end
    end
    local branches = {}
    for branch in pairs(found) do
        table.insert(branches, branch)
    end
    table.sort(branches)
    return branches
end

--[[
Creates one source monster with unique encounter, enemy and life identity.

Args:
    options (any): Trusted Dungeon spawn factory settings.
    factory (any): Registered Dungeon-only Marauder factory.

Returns:
    Model: Physical world enemy eligible for explicit receipt registration.
]]
local function create_challenge(options: any, factory: any): Model
    local enemy = factory.create(options)
    assert(typeof(enemy) == "Instance" and enemy:IsA("Model"))
    enemy:SetAttribute("SourceQuestMonsterId", options.SourceId)
    return enemy
end

--[[
Spawns a small optional quest pack beside the existing instanced room pack.
The existing generic encounter owns, rewards and cleans up every new model.

Args:
    options (any): Server profiles, party, execution, encounter and folder.
    factory (any?): Optional injected physical enemy factory for tests.

Returns:
    {any}: Explicit outcome and newly spawned branch/model pairs.
]]
function Spawns.augment(options: any, factory: any?): any
    if type(options) ~= "table"
        or not options.profiles or not options.execution
        or type(options.user_ids) ~= "table"
        or type(options.encounter_id) ~= "string"
        or type(options.execution.Enemies) ~= "table"
        or #options.execution.Enemies == 0
    then
        return {ok = false, reason = "InvalidQuestSpawnContext"}
    end
    local branches = Spawns.eligible_branches(
        options.profiles, options.user_ids
    )
    if #branches == 0 then
        return {ok = true, registrations = {}}
    end
    local base = options.execution.Enemies[1]
    if typeof(base) ~= "Instance" or not base:IsA("Model")
        or not base.PrimaryPart
        or typeof(options.folder) ~= "Instance"
        or not options.folder:IsA("Folder")
    then
        return {ok = false, reason = "QuestSpawnAnchorUnavailable"}
    end
    local registrations = {}
    for branch_index, branch in ipairs(branches) do
        local challenge = CHALLENGES[branch]
        local count = if branch == "ElvenScoutSix"
            then 1 else PER_BRANCH_PER_ROOM
        for index = 1, count do
            local name = challenge.SourceId
                .. tostring(branch_index) .. "_" .. tostring(index)
            local spawn_at = base.PrimaryPart.CFrame
                * CFrame.new(5 * index, 0, 5 * branch_index)
            local created, enemy = pcall(create_challenge, {
                Parent = options.folder,
                Name = name,
                SourceId = challenge.SourceId,
                SpawnCFrame = spawn_at,
                SpawnIndex = 6000 + branch_index * 10 + index,
                RespawnEnabled = false,
                ControllerEnabled = true,
                EncounterId = options.encounter_id,
                EnemyId = name,
                LifeIndex = 1,
                -- EncounterService requires positive XP even for a
                -- quest-only enemy. A valid minimal ordinary reward is
                -- necessary for death accounting and room clear.
                RewardXP = 1,
                RewardGoldMin = 0,
                RewardGoldMax = 0,
                -- Temporary combat rig is a Marauder; register a valid
                -- known bestiary key until unique quest models exist.
                BestiaryCreatureId = "marauder",
                BaseMaxHealth = challenge.Health,
                HealthMultiplier = options.health_multiplier or 1,
                DamageMultiplier = options.damage_multiplier or 1,
            }, factory or DungeonMarauderFactory)
            if not created then
                for _, registration in ipairs(registrations) do
                    registration.enemy:Destroy()
                end
                return {ok = false, reason = "QuestSpawnFactoryFailed"}
            end
            table.insert(registrations, {
                enemy = enemy,
                branch_id = challenge.BranchId or branch,
                step_index = challenge.Step or 3,
            })
        end
    end
    for _, registration in ipairs(registrations) do
        table.insert(options.execution.Enemies, registration.enemy)
    end
    return {ok = true, registrations = registrations}
end

return table.freeze(Spawns)
