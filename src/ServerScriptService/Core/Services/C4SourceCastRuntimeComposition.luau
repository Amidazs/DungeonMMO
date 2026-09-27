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
local PhysicalCast = require(
    Services.C4SourcePhysicalCastService
)
local CastInterruption = require(
    Services.C4SourceCastInterruptionService
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
local SelfEffect = require(
    Services.C4SourceSelfEffectCastService
)
local SourceToggle = require(
    Services.C4SourceToggleService
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
local DuskguardCast = require(
    Services.C4SourceDuskguardCastService
)
local VeilbladeCast = require(
    Services.C4SourceVeilbladeCastService
)

local C4SourceCastRuntimeComposition = {}
C4SourceCastRuntimeComposition.__index =
    C4SourceCastRuntimeComposition

--[[
Cancels a pending cast through the bridge that owns its private receipt.

Args:
    bridges (any): Ordered source cast bridge collection.
    player (any): Server-owned cast owner.
    cast_id (number): Shared source scheduler receipt.

Returns:
    (boolean, string?): Success or stable no-owner reason.
]]
local function cancel_bridge_cast(
    bridges: any,
    player: any,
    cast_id: number
): (boolean, string?)
    for _, bridge in ipairs(bridges) do
        local cancelled = bridge:cancel_cast(player, cast_id)
        if cancelled then
            return true, nil
        end
    end

    return false, "C4SourceCastInterruptBridgeReceiptInvalid"
end

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
    local physical_cast = PhysicalCast.new(
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
    local self_effect = SelfEffect.new(scheduler)
    local source_toggle = SourceToggle.new()
    source_toggle:bind_runtime()
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
    local duskguard_cast = DuskguardCast.new(
        scheduler,
        source_executor
    )
    local veilblade_cast = VeilbladeCast.new(
        scheduler,
        source_executor
    )

    local cancellable_bridges = {
        direct_magic,
        physical_cast,
        support_magic,
        periodic_magic,
        self_magic,
        self_effect,
        corpse_magic,
        companion_magic,
        duskguard_cast,
        veilblade_cast,
    }

    local interruption = CastInterruption.new(
        scheduler,
        nil,
        function(player, cast_id)
            return cancel_bridge_cast(
                cancellable_bridges,
                player,
                cast_id
            )
        end
    )

    return setmetatable({
        SourceShots = source_shots,
        Resources = resources,
        Timing = timing,
        Scheduler = scheduler,
        Interruption = interruption,
        DirectMagic = direct_magic,
        PhysicalCast = physical_cast,
        SupportMagic = support_magic,
        PeriodicMagic = periodic_magic,
        SelfMagic = self_magic,
        SelfEffect = self_effect,
        SourceToggle = source_toggle,
        CorpseMagic = corpse_magic,
        Companions = companions,
        CompanionMagic = companion_magic,
        DuskguardCast = duskguard_cast,
        VeilbladeCast = veilblade_cast,
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
    self.PhysicalCast:clear_owner(player)
    self.SupportMagic:clear_owner(player)
    self.PeriodicMagic:clear_owner(player)
    self.SelfMagic:clear_owner(player)
    self.SelfEffect:clear_owner(player)
    self.SourceToggle:clear_owner(player)
    self.CorpseMagic:clear_owner(player)
    self.CompanionMagic:clear_owner(player)
    self.DuskguardCast:clear_owner(player)
    self.VeilbladeCast:clear_owner(player)
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
    local physical = self.PhysicalCast:capability()
    local support = self.SupportMagic:capability()
    local periodic = self.PeriodicMagic:capability()
    local self_magic = self.SelfMagic:capability()
    local self_effect = self.SelfEffect:capability()
    local source_toggle = self.SourceToggle:capability()
    local corpse_magic = self.CorpseMagic:capability()
    local companion_magic = self.CompanionMagic:capability()
    local duskguard_cast = self.DuskguardCast:capability()
    local veilblade_cast = self.VeilbladeCast:capability()

    return {
        Available = true,
        SourceShotAuthority = true,
        SourceCastResources = true,
        SourceCastTiming = true,
        SourceCastScheduler = true,
        SourceCastInterruption = true,
        SourceCastInterruptionCapability =
            self.Interruption:capability(),
        DirectMagicBridge = true,
        DirectMagicDefaultEnabled =
            direct.DefaultEnabled == true,
        DirectMagicCurrentlyEnabled =
            direct.CurrentlyEnabled == true,
        PhysicalCastBridge = true,
        PhysicalCastDefaultEnabled =
            physical.DefaultEnabled == true,
        PhysicalCastCurrentlyEnabled =
            physical.CurrentlyEnabled == true,
        PhysicalCastReviewedActiveSkillCount =
            physical.ReviewedActiveSkillCount,
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
        SelfEffectBridge = true,
        SelfEffectDefaultEnabled =
            self_effect.DefaultEnabled == true,
        SelfEffectCurrentlyEnabled =
            self_effect.CurrentlyEnabled == true,
        SelfEffectReviewedSkillCount =
            self_effect.ReviewedSkillCount,
        SourceToggleAuthority = true,
        SourceToggleDefaultEnabled =
            source_toggle.DefaultEnabled == true,
        SourceToggleCurrentlyEnabled =
            source_toggle.CurrentlyEnabled == true,
        SourceToggleReviewedSkillCount =
            source_toggle.ReviewedSkillCount,
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
        DuskguardCastBridge = true,
        DuskguardCastDefaultEnabled =
            duskguard_cast.DefaultEnabled == true,
        DuskguardCastCurrentlyEnabled =
            duskguard_cast.CurrentlyEnabled == true,
        VeilbladeCastBridge = true,
        VeilbladeCastDefaultEnabled =
            veilblade_cast.DefaultEnabled == true,
        VeilbladeCastCurrentlyEnabled =
            veilblade_cast.CurrentlyEnabled == true,
    }
end

return C4SourceCastRuntimeComposition
