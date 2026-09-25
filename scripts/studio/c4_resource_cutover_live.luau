--!strict
-- Disposable two-player acceptance for reversible live C4 HP/MP/CP cutover.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "C4 resource cutover Play requires an unpublished Dungeon place"
)

local ServerScriptService = game:GetService("ServerScriptService")
local StudioTestService = game:GetService("StudioTestService")

local driver = Instance.new("Script")
driver.Name = "TEMP_C4ResourceCutoverDriver"
driver.Source = [==[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StudioTestService = game:GetService("StudioTestService")

local Shared = ReplicatedStorage.Core.Shared

local Cutover = require(
    ServerScriptService.Core.Services.C4ResourceCutoverService
)
local CombatPoints = require(
    ServerScriptService.Core.Services.C4CombatPointRuntime
)
local Damage = require(
    ServerScriptService.Combat.DamageService
)
local Mana = require(
    ServerScriptService.Combat.ManaService
)
local ProfileSchema = require(Shared.ProfileSchema)
local Regen = require(Shared.C4ResourceRegenSourceRules)
local Runtime = require(
    ServerScriptService.Core.Services.ProgressionRuntimeState
)

local TEST_TIMEOUT = 95

--[[
Waits for a live condition with a bounded timeout.

Args:
    callback (() -> any): Predicate returning a truthy result when ready.
    label (string): Diagnostic text for a timeout.
    seconds (number): Maximum wall-clock wait.

Returns:
    any: First truthy callback result.
]]
local function wait_for(
    callback,
    label,
    seconds
)
    local deadline = os.clock() + seconds

    repeat
        local result = callback()
        if result then
            return result
        end
        task.wait(0.1)
    until os.clock() >= deadline

    error("[C4 Resource Cutover Live] TIMEOUT " .. label)
end

--[[
Builds a source-ready Human Fighter without forged advancement state.

Args:
    user_id (number): Real connected Studio player user ID.

Returns:
    any: Complete starter Fighter character snapshot at level 30.
]]
local function fighter_fixture(user_id)
    local character = ProfileSchema
        .create_default(user_id).Characters.Slot1

    character.Level = 30
    character.Identity = {
        Version = 1,
        RaceId = "Human",
        BaseClassId = "Fighter",
        ClassId = "Fighter",
        CreationStage = "Complete",
    }
    character.ClassAdvancement = {
        Version = 1,
    }

    return character
end

--[[
Returns one living humanoid after normal Dungeon spawning finishes.

Args:
    player (Player): Real connected Studio player.

Returns:
    Humanoid: Current living player Humanoid.
]]
local function living_humanoid(player)
    return wait_for(function()
        local character = player.Character
        local humanoid = character
            and character:FindFirstChildOfClass("Humanoid")

        if humanoid and humanoid.Health > 0 then
            return humanoid
        end
        return nil
    end, "living player humanoid", 30)
end

--[[
Checks two floating values are approximately equal.

Args:
    actual (number): Runtime observed value.
    expected (number): Expected source or fraction value.
    tolerance (number): Maximum absolute error.
    label (string): Failure diagnostic.

Returns:
    nil: Raises when the values differ beyond tolerance.
]]
local function close_to(
    actual,
    expected,
    tolerance,
    label
)
    assert(
        math.abs(actual - expected) <= tolerance,
        (
            "[C4 Resource Cutover Live] %s: %.6f ~= %.6f"
        ):format(label, actual, expected)
    )
end

--[[
Routes deterministic server damage through the ordinary DamageService.

Args:
    attacker (Player?): Real playable attacker, or nil for NPC-like damage.
    defender (Player): Real player whose Humanoid receives the hit.
    damage (number): Uncritical unblocked pre-resource damage.

Returns:
    number: Actual HP damage returned by DamageService.
]]
local function apply_hit(attacker, defender, damage)
    return Damage.apply_damage({
        attacker = attacker,
        attacker_character = attacker and attacker.Character or nil,
        target = assert(defender.Character),
        source_kind = if attacker then "Melee" else "C4TestNPC",
        source_id = "TEMP_C4ResourceCutoverHit",
        base_damage = damage,
        multiplier = 1,
    })
end

--[[
Verifies disabled-by-default enable, CP routing, source regen and rollback.

Args:
    attacker (Player): Real second Studio player used for playable damage.
    defender (Player): Real source-ready Studio player.

Returns:
    nil: Requires real HP, ManaService and CP state changes.
]]
local function verify_cutover(attacker, defender)
    local character = fighter_fixture(defender.UserId)
    Runtime.set_character(defender.UserId, character)
    Runtime.apply_runtime_stats(defender)
    Mana.reset_player(defender)

    attacker:SetAttribute("DungeonCombatAllowed", true)
    defender:SetAttribute("DungeonCombatAllowed", true)

    local humanoid = living_humanoid(defender)
    local custom_max_hp = humanoid.MaxHealth
    local custom_max_mp = Mana.get_max(defender)

    assert(custom_max_hp > 0 and custom_max_mp > 0)
    humanoid.Health = custom_max_hp * 0.5
    assert(Mana.try_spend(defender, custom_max_mp * 0.5))

    local denied, denied_reason = Cutover.enable_player(defender)
    assert(
        not denied
            and denied_reason == "C4ResourceCutoverDisabled",
        "source resources activated without the explicit server gate"
    )

    local boundary = assert(
        Runtime.get_c4_resource_migration_boundary(
            defender.UserId
        )
    )
    assert(
        boundary.CutoverPrerequisitesReady
            and #boundary.ActivationBlockers == 0,
        "clean Fighter source prerequisites are not ready"
    )

    Cutover.set_enabled(true)
    local enabled, reason = Cutover.enable_player(defender)
    assert(
        enabled and reason == nil,
        "explicit source cutover failed: " .. tostring(reason)
    )

    local source = assert(boundary.SourceStatCandidate)
    local active = Cutover.snapshot(defender)
    assert(active.Active and active.CombatPoints.Configured)

    close_to(
        humanoid.MaxHealth,
        source.MAX_HP,
        0.001,
        "source max HP"
    )
    close_to(
        Mana.get_max(defender),
        source.MAX_MP,
        0.001,
        "source max MP"
    )
    close_to(
        active.CombatPoints.MaxCP,
        source.MAX_CP,
        0.001,
        "source max CP"
    )
    close_to(
        humanoid.Health / humanoid.MaxHealth,
        0.5,
        0.01,
        "HP fraction preserved into source mode"
    )
    close_to(
        Mana.get(defender) / Mana.get_max(defender),
        0.5,
        0.01,
        "MP fraction preserved into source mode"
    )

    local hp_before_pvp = humanoid.Health
    local cp_before_pvp =
        Cutover.snapshot(defender).CombatPoints.CurrentCP
    local pvp_hp_damage = apply_hit(attacker, defender, 50)
    local after_pvp = Cutover.snapshot(defender).CombatPoints

    close_to(pvp_hp_damage, 0, 0.001, "PvP HP damage while CP remains")
    close_to(
        humanoid.Health,
        hp_before_pvp,
        0.001,
        "PvP hit did not bypass available CP"
    )
    close_to(
        cp_before_pvp - after_pvp.CurrentCP,
        50,
        0.001,
        "PvP hit consumed CP first"
    )

    local cp_before_npc = after_pvp.CurrentCP
    local hp_before_npc = humanoid.Health
    local npc_hp_damage = apply_hit(nil, defender, 25)
    local after_npc = Cutover.snapshot(defender).CombatPoints

    close_to(npc_hp_damage, 25, 0.001, "NPC damage reaches HP")
    close_to(
        hp_before_npc - humanoid.Health,
        25,
        0.001,
        "NPC damage reduced real Humanoid HP"
    )
    close_to(
        after_npc.CurrentCP,
        cp_before_npc,
        0.001,
        "NPC damage bypasses C4 CP"
    )

    assert(Mana.try_spend(defender, 10))
    local before_regen_hp = humanoid.Health
    local before_regen_mp = Mana.get(defender)
    local before_regen_cp =
        CombatPoints.snapshot(defender).CurrentCP
    local expected_tick = assert(
        Regen.apply_movement(source, "Standing")
    )

    task.wait(3.35)

    local after_regen_cp =
        CombatPoints.snapshot(defender).CurrentCP
    assert(
        humanoid.Health >= math.min(
            humanoid.MaxHealth,
            before_regen_hp + expected_tick.HP
        ) - 0.05,
        "three-second source HP regeneration did not apply"
    )
    assert(
        Mana.get(defender) >= math.min(
            Mana.get_max(defender),
            before_regen_mp + expected_tick.MP
        ) - 0.05,
        "three-second source MP regeneration did not apply"
    )
    assert(
        after_regen_cp >= math.min(
            source.MAX_CP,
            before_regen_cp + expected_tick.CP
        ) - 0.05,
        "three-second source CP regeneration did not apply"
    )

    local source_hp_fraction =
        humanoid.Health / humanoid.MaxHealth
    local source_mp_fraction =
        Mana.get(defender) / Mana.get_max(defender)

    assert(Cutover.disable_player(defender))
    assert(
        not Cutover.is_active(defender)
            and not CombatPoints.snapshot(defender).Configured,
        "per-player rollback left source state active"
    )
    close_to(
        humanoid.MaxHealth,
        custom_max_hp,
        0.001,
        "custom max HP restored"
    )
    close_to(
        Mana.get_max(defender),
        custom_max_mp,
        0.001,
        "custom max MP restored"
    )
    close_to(
        humanoid.Health / humanoid.MaxHealth,
        source_hp_fraction,
        0.02,
        "HP fraction preserved on rollback"
    )
    close_to(
        Mana.get(defender) / Mana.get_max(defender),
        source_mp_fraction,
        0.02,
        "MP fraction preserved on rollback"
    )

    local reenabled = assert(Cutover.enable_player(defender))
    assert(reenabled)
    local old_character = defender.Character
    local added = false
    local connection = defender.CharacterAdded:Connect(function()
        added = true
    end)

    defender:LoadCharacter()
    wait_for(function()
        return added
            and defender.Character ~= old_character
            and defender.Character
            and defender.Character:FindFirstChildOfClass("Humanoid")
    end, "source-mode respawn", 30)
    connection:Disconnect()

    local respawned_humanoid = living_humanoid(defender)
    wait_for(function()
        return Cutover.is_active(defender)
            and defender:GetAttribute("C4ResourceCutoverActive") == true
    end, "source mode reapplied after respawn", 15)

    close_to(
        respawned_humanoid.MaxHealth,
        source.MAX_HP,
        0.001,
        "source max HP reapplied after respawn"
    )
    close_to(
        Mana.get_max(defender),
        source.MAX_MP,
        0.001,
        "source max MP reapplied after respawn"
    )
    assert(
        CombatPoints.snapshot(defender).Configured,
        "source CP was not reconfigured after respawn"
    )

    Cutover.set_enabled(false)
    assert(
        not Cutover.is_enabled()
            and not Cutover.is_active(defender)
            and not CombatPoints.snapshot(defender).Configured,
        "global rollback did not clear the source resource mode"
    )

    Runtime.clear_character(defender.UserId)

    print(
        "[C4 Resource Cutover Live] "
            .. "DEFAULT_OFF_FRACTION_CP_REGEN_RESPAWN_ROLLBACK_PASS"
    )
end

--[[
Runs isolated two-player unpublished resource-cutover acceptance.

Args:
    None.

Returns:
    nil: Ends Studio Play only after every live resource check passes.
]]
local function main()
    local players = wait_for(function()
        local current = Players:GetPlayers()
        if #current == 2 then
            return current
        end
        return nil
    end, "two real Studio players", 45)

    for _, player in ipairs(players) do
        living_humanoid(player)
    end

    verify_cutover(players[1], players[2])
end

task.spawn(function()
    local ok, reason = pcall(main)

    pcall(function()
        Cutover.set_enabled(false)
    end)

    if not ok then
        warn("[C4 Resource Cutover Live] FAIL " .. tostring(reason))
    end

    StudioTestService:EndTest(
        if ok then "PASS" else "FAIL " .. tostring(reason)
    )
end)

task.delay(TEST_TIMEOUT, function()
    StudioTestService:EndTest(
        "FAIL C4 resource cutover Play global timeout"
    )
end)
]==]
driver.Parent = ServerScriptService

local ok, result = pcall(function()
    return StudioTestService:ExecuteMultiplayerTestAsync(
        2,
        "TEMP_C4ResourceCutoverPlay"
    )
end)

driver:Destroy()

assert(
    ok and result == "PASS",
    "C4 resource cutover Play failed: " .. tostring(result)
)

print("[C4 Resource Cutover Live] VERIFIED_PLAY_MODE_PASS")
