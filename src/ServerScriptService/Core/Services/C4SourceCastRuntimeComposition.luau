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

local C4SourceCastRuntimeComposition = {}
C4SourceCastRuntimeComposition.__index =
    C4SourceCastRuntimeComposition

--[[
Builds the disabled-by-default Dungeon source cast service graph.

Args:
    source_shots (any): Existing server-owned C4 source shot authority.
    source_executor (any): Existing disabled source combat executor.

Returns:
    any: Composed resource, timing, scheduler and direct-MDAM services.
]]
function C4SourceCastRuntimeComposition.new(
    source_shots: any,
    source_executor: any
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

    local resources = CastResources.new()
    local timing = CastTiming.new(source_shots)
    local scheduler = CastScheduler.new(resources, timing)
    local direct_magic = DirectMagic.new(
        scheduler,
        source_executor
    )

    return setmetatable({
        SourceShots = source_shots,
        Resources = resources,
        Timing = timing,
        Scheduler = scheduler,
        DirectMagic = direct_magic,
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
    }
end

return C4SourceCastRuntimeComposition
