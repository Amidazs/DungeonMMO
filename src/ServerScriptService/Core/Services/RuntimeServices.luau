--!strict
-- Central runtime composition for Base/Dungeon Places.
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Core = ServerScriptService:WaitForChild("Core")
local Adapters = Core:WaitForChild("Adapters")
local Services = Core:WaitForChild("Services")

local DataStoreProfileAdapter = require(Adapters:WaitForChild("DataStoreProfileAdapter"))
local InMemoryMapAdapter = require(Adapters:WaitForChild("InMemoryMapAdapter"))
local InMemoryEntityAdapter = require(Adapters:WaitForChild("InMemoryEntityAdapter"))
local RobloxEntityAdapter = require(Adapters:WaitForChild("RobloxEntityAdapter"))
local InMemoryProfileAdapter = require(Adapters:WaitForChild("InMemoryProfileAdapter"))
local MemoryStoreMapAdapter = require(Adapters:WaitForChild("MemoryStoreMapAdapter"))

local ProfileLeaseService = require(Services:WaitForChild("ProfileLeaseService"))
local ProfileService = require(Services:WaitForChild("ProfileService"))
local DungeonSessionService = require(Services:WaitForChild("DungeonSessionService"))
local DungeonDifficultyProgressionService = require(
    Services:WaitForChild("DungeonDifficultyProgressionService")
)
local ProgressionService = require(Services:WaitForChild("ProgressionService"))
local InventoryService = require(Services:WaitForChild("InventoryService"))
local C4SourceShotService = require(
    Services:WaitForChild("C4SourceShotService")
)
local C4SourceCombatCalculationService = require(
    Services:WaitForChild("C4SourceCombatCalculationService")
)
local C4SourceCombatExecutor = require(
    Services:WaitForChild("C4SourceCombatExecutor")
)
local C4CombatDispatchAdapter = require(
    Services:WaitForChild("C4CombatDispatchAdapter")
)
local C4CombatCutoverCoordinator = require(
    Services:WaitForChild("C4CombatCutoverCoordinator")
)
local RewardService = require(Services:WaitForChild("RewardService"))
local WeeklyWorldBossService = require(
    Services:WaitForChild("WeeklyWorldBossService")
)
local WeeklyWorldBossSessionBridge = require(
    Services:WaitForChild("WeeklyWorldBossSessionBridge")
)
local AttributeService = require(Services:WaitForChild("AttributeService"))
local LoadoutService = require(Services:WaitForChild("LoadoutService"))
local SkillProgressionService = require(Services:WaitForChild("SkillProgressionService"))
local ProficiencyService = require(Services:WaitForChild("ProficiencyService"))
local IdentityService = require(Services:WaitForChild("IdentityService"))
local EquipmentService = require(Services:WaitForChild("EquipmentService"))
local ProfessionService = require(Services:WaitForChild("ProfessionService"))
local RecipeKnowledgeService = require(
    Services:WaitForChild("RecipeKnowledgeService")
)

local BankService = require(Services:WaitForChild("BankService"))

local TravelService = require(Services:WaitForChild("TravelService"))

local QuestService = require(Services:WaitForChild("QuestService"))
local ClassAdvancementService = require(
    Services:WaitForChild("ClassAdvancementService")
)

local ContributionService = require(
    Services:WaitForChild("ContributionService")
)

local BestiaryService = require(Services:WaitForChild("BestiaryService"))
local ReputationService = require(Services:WaitForChild("ReputationService"))
local GuildService = require(Services:WaitForChild("GuildService"))
local GuildHallService = require(Services:WaitForChild("GuildHallService"))
local MarketService = require(Services:WaitForChild("MarketService"))
local RaceChangeService = require(Services:WaitForChild("RaceChangeService"))
local EconomyAuditService = require(Services:WaitForChild("EconomyAuditService"))
local RateLimitService = require(Services:WaitForChild("RateLimitService"))

local RuntimeServices = {}

function RuntimeServices.new(place_kind: string): any
    assert(
        place_kind == "Base" or place_kind == "Dungeon",
        "place_kind must be Base or Dungeon"
    )

    local studio = RunService:IsStudio()
    local profile_adapter = if studio
        then InMemoryProfileAdapter.new()
        else DataStoreProfileAdapter.new()
    local lease_map = if studio
        then InMemoryMapAdapter.new()
        else MemoryStoreMapAdapter.new("ProfileLeases")
    local session_map = if studio
        then InMemoryMapAdapter.new()
        else MemoryStoreMapAdapter.new("DungeonSessions")
    local entity_adapter = if studio
        then InMemoryEntityAdapter.new()
        else RobloxEntityAdapter.new("SharedEntities")

    local job_id = game.JobId
    local server_id = if type(job_id) == "string" and job_id ~= ""
        then place_kind .. ":" .. job_id
        else place_kind .. ":Studio:" .. HttpService:GenerateGUID(false)

    local leases = ProfileLeaseService.new(lease_map, server_id)
    local profiles = ProfileService.new(profile_adapter, leases)
    local bestiary = BestiaryService.new(profiles)
    local reputation = ReputationService.new(profiles)
    local guilds = GuildService.new(entity_adapter)
    local guild_hall = GuildHallService.new(guilds)
    local market = MarketService.new(entity_adapter, profiles)
    local race_change = RaceChangeService.new(profiles)
    local audit = EconomyAuditService.new()
    local rate_limits = RateLimitService.new()
    local sessions = DungeonSessionService.new(session_map)
    local dungeon_difficulty_progression =
        DungeonDifficultyProgressionService.new(profiles)
    local contributions = ContributionService.new(sessions)
    local progression = ProgressionService.new(profiles)
    local inventory = InventoryService.new(profiles)
    local c4_source_shots = C4SourceShotService.new(inventory)
    C4SourceCombatCalculationService.set_shot_authority(
        c4_source_shots
    )

    local c4_resource_cutover = nil
    if place_kind == "Dungeon" then
        c4_resource_cutover = require(
            Services:WaitForChild("C4ResourceCutoverService")
        )
        C4CombatDispatchAdapter.bind_participant_provider(
            function(attacker: any): boolean
                return c4_resource_cutover.is_active(attacker)
            end
        )
    end

    local c4_source_combat_executor =
        C4SourceCombatExecutor.new({
            ResourceAuthority = c4_resource_cutover,
        })

    local c4_combat_cutover_coordinator = nil
    if place_kind == "Dungeon" then
        c4_combat_cutover_coordinator =
            C4CombatCutoverCoordinator.new({
                ResourceAuthority = c4_resource_cutover,
                CombatProvider =
                    C4SourceCombatCalculationService,
                Executor = c4_source_combat_executor,
                Dispatch = C4CombatDispatchAdapter,
            })
    end

    local recipe_knowledge = RecipeKnowledgeService.new(
        profiles,
        inventory
    )
    local rewards = RewardService.new(profiles, progression, inventory, sessions)
    local weekly_world_boss = WeeklyWorldBossService.new(profiles)
    local weekly_world_boss_sessions = WeeklyWorldBossSessionBridge.new(
        sessions, weekly_world_boss
    )
    rewards:set_audit_service(audit)
    guilds:set_audit_service(audit)
    market:set_audit_service(audit)
    race_change:set_audit_service(audit)
    local attributes = AttributeService.new(profiles)
    local loadout = LoadoutService.new(profiles)
    local skills = SkillProgressionService.new(profiles, inventory, loadout)
    local proficiency = ProficiencyService.new(profiles)
    local identity = IdentityService.new(profiles)
    local equipment = EquipmentService.new(profiles, place_kind)
    local professions = ProfessionService.new(profiles, inventory)
    local bank = BankService.new(profiles, place_kind)
    local travel = TravelService.new(profiles, place_kind)
    local quests = QuestService.new(profiles)
    local class_advancement = ClassAdvancementService.new(
        profiles,
        quests,
        place_kind
    )

    return {
        IsStudio = studio,
        ServerId = server_id,
        LeaseService = leases,
        ProfileService = profiles,
        SessionService = sessions,
        DungeonDifficultyProgressionService =
            dungeon_difficulty_progression,
        ContributionService = contributions,
        BestiaryService = bestiary,
        ReputationService = reputation,
        EntityAdapter = entity_adapter,
        GuildService = guilds,
        GuildHallService = guild_hall,
        MarketService = market,
        RaceChangeService = race_change,
        EconomyAuditService = audit,
        RateLimitService = rate_limits,
        ProgressionService = progression,
        InventoryService = inventory,
        C4SourceShotService = c4_source_shots,
        C4SourceCombatExecutor = c4_source_combat_executor,
        C4CombatCutoverCoordinator =
            c4_combat_cutover_coordinator,
        RecipeKnowledgeService = recipe_knowledge,
        RewardService = rewards,
        WeeklyWorldBossService = weekly_world_boss,
        WeeklyWorldBossSessionBridge = weekly_world_boss_sessions,
        AttributeService = attributes,
        LoadoutService = loadout,
        SkillProgressionService = skills,
        ProficiencyService = proficiency,
        IdentityService = identity,
        EquipmentService = equipment,
        ProfessionService = professions,
        BankService = bank,
        TravelService = travel,
        QuestService = quests,
        ClassAdvancementService = class_advancement,
    }
end

return table.freeze(RuntimeServices)
