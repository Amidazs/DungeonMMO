--!strict
-- Dungeon-only composition for staged Human Wizard source cast services.

local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService.Core.Services

local CastResources = require(
    Services.C4SourceCastResourceService
)
local CastTiming = require(
    Services.C4SourceCastTimingService
)
local CastScheduler = require(
    Services.C4SourceCastSchedulerService
)
local DirectMagic = require(
    Services.C4SourceDirectMagicCastService
)
local SupportMagic = require(
    Services.C4SourceSupportMagicCastService
)
local PeriodicMagic = require(
    Services.C4SourcePeriodicMagicCastService
)
local SelfMagic = require(
    Services.C4SourceSelfMagicCastService
)
local CorpseMagic = require(
    Services.C4SourceCorpseMagicCastService
)
local CompanionService = require(
    Services.C4SourceCompanionService
)
local CompanionMagic = require(
    Services.C4SourceCompanionCastService
)

local C4SourceCastRuntimeComposition = {}
C4SourceCastRuntimeComposition.__index =
    C4SourceCastRuntimeComposition

--[[
Builds the disabled-by-default Dungeon source cast service graph.

Args:
    source_shots (any): Existing server-owned C4 source shot authority.
    source_executor (any): Existing disabled source combat executor.
    inventory (any): Existing server-owned inventory authority.
    source_combat (any): Existing C4 source calculation provider.

Returns:
    any: Composed resource, timing, scheduler and direct-MDAM services.
]]
function C4SourceCastRuntimeComposition.new(
    source_shots: any,
    source_executor: any,
    inventory: any,
    source_combat: any
): any
    assert(
        source_shots
            and type(source_shots.snapshot) == "function"
            and type(source_shots.remove_player) == "function",
        "Source cast runtime requires source shot authority"
    )
    assert(
        source_executor
            and type(source_executor.magic_skill_npc) == "function",
        "Source cast runtime requires source combat executor"
    )
    assert(
        inventory
            and type(inventory.consume_item) == "function",
        "Source cast runtime requires inventory authority"
    )
    assert(
        source_combat
            and type(
                source_combat.companion_summon_plan
            ) == "function",
        "Source cast runtime requires source companion calculations"
    )

    local resources = CastResources.new()
    local timing = CastTiming.new(source_shots)
    local scheduler = CastScheduler.new(resources, timing)
    local direct_magic = DirectMagic.new(
        scheduler,
        source_executor
    )
    local support_magic = SupportMagic.new(
        scheduler,
        source_executor
    )
    local periodic_magic = PeriodicMagic.new(
        scheduler,
        source_executor
    )
    local self_magic = SelfMagic.new(
        scheduler,
        source_executor
    )
    local corpse_magic = CorpseMagic.new(
        scheduler,
        source_executor
    )
    local companions = CompanionService.new(
        inventory,
        source_combat
    )
    local companion_magic = CompanionMagic.new(
        scheduler,
        companions
    )

    return setmetatable({
        SourceShots = source_shots,
        Resources = resources,
        Timing = timing,
        Scheduler = scheduler,
        DirectMagic = direct_magic,
        SupportMagic = support_magic,
        PeriodicMagic = periodic_magic,
        SelfMagic = self_magic,
        CorpseMagic = corpse_magic,
        Companions = companions,
        CompanionMagic = companion_magic,
    }, C4SourceCastRuntimeComposition)
end

--[[
Clears every ephemeral source-cast/shot record for one departing player.

Args:
    player (any): Departing server-owned player.

Returns:
    nil: Clears private cast state before resource cutover teardown.
]]
function C4SourceCastRuntimeComposition:clear_owner(
    player: any
)
    self.DirectMagic:clear_owner(player)
    self.SupportMagic:clear_owner(player)
    self.PeriodicMagic:clear_owner(player)
    self.SelfMagic:clear_owner(player)
    self.CorpseMagic:clear_owner(player)
    self.CompanionMagic:clear_owner(player)
    self.Companions:clear_owner(player, "OwnerCleared")

    if player and type(player.UserId) == "number" then
        self.SourceShots:remove_player(player.UserId)
    end
end

--[[
Returns detached staged-runtime capability metadata.

Args:
    None.

Returns:
    any: Composition and direct-MDAM default-gate state.
]]
function C4SourceCastRuntimeComposition:capability(): any
    local direct = self.DirectMagic:capability()
    local support = self.SupportMagic:capability()
    local periodic = self.PeriodicMagic:capability()
    local self_magic = self.SelfMagic:capability()
    local corpse_magic = self.CorpseMagic:capability()
    local companion_magic = self.CompanionMagic:capability()

    return {
        Available = true,
        SourceShotAuthority = true,
        SourceCastResources = true,
        SourceCastTiming = true,
        SourceCastScheduler = true,
        DirectMagicBridge = true,
        DirectMagicDefaultEnabled =
            direct.DefaultEnabled == true,
        DirectMagicCurrentlyEnabled =
            direct.CurrentlyEnabled == true,
        SupportMagicBridge = true,
        SupportMagicDefaultEnabled =
            support.DefaultEnabled == true,
        SupportMagicCurrentlyEnabled =
            support.CurrentlyEnabled == true,
        PeriodicMagicBridge = true,
        PeriodicMagicDefaultEnabled =
            periodic.DefaultEnabled == true,
        PeriodicMagicCurrentlyEnabled =
            periodic.CurrentlyEnabled == true,
        SelfMagicBridge = true,
        SelfMagicDefaultEnabled =
            self_magic.DefaultEnabled == true,
        SelfMagicCurrentlyEnabled =
            self_magic.CurrentlyEnabled == true,
        CorpseMagicBridge = true,
        CorpseMagicDefaultEnabled =
            corpse_magic.DefaultEnabled == true,
        CorpseMagicCurrentlyEnabled =
            corpse_magic.CurrentlyEnabled == true,
        CompanionAuthority = true,
        CompanionMagicBridge = true,
        CompanionMagicDefaultEnabled =
            companion_magic.DefaultEnabled == true,
        CompanionMagicCurrentlyEnabled =
            companion_magic.CurrentlyEnabled == true,
    }
end

return C4SourceCastRuntimeComposition
