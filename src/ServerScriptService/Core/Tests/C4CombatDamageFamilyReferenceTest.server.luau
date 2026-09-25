--!strict
-- Deterministic C4 DamageService source-family audit regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Families = require(
    ReplicatedStorage.Core.Shared.C4CombatDamageFamilyReference
)

local checks = 0

--[[
Counts one damage-family audit assertion.

Args:
    valid (boolean): Expected audit condition.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Damage Family Audit] " .. label)
end

--[[
Checks one reviewed family route and activation state.

Args:
    source_kind (string): Existing DamageService family.
    route (string): Expected source route.
    blocker (boolean): Expected activation-blocker state.

Returns:
    nil: Records the reviewed family assertions.
]]
local function check_family(
    source_kind: string,
    route: string,
    blocker: boolean
)
    local family = assert(Families.get(source_kind))
    check(
        family.Route == route,
        source_kind .. " route remains reviewed"
    )
    check(
        family.ActivationBlocker == blocker,
        source_kind .. " blocker state remains reviewed"
    )
end

--[[
Runs the complete current player-to-NPC damage-family audit.

Args:
    None.

Returns:
    nil: Prints deterministic audit acceptance evidence.
]]
local function main()
    check_family("Melee", "SourceNormal", false)
    check_family(
        "RangedPhysical",
        "SourcePhysicalByRank",
        false
    )
    check_family("Skill", "SourcePDAM", false)
    check_family("MagicSkill", "SourceMDAM", false)

    check_family("MagicBasic", "SourceNormal", false)
    check_family("RangerArea", "Unsupported", true)
    check_family(
        "StatusPhysical",
        "LegacyPeriodicTickSuppressed",
        false
    )
    check_family(
        "StatusMagic",
        "LegacyPeriodicTickSuppressed",
        false
    )

    for _, source_kind in ipairs({
        "EnemyMelee",
        "EnemyArea",
        "EnemyBow",
        "EnemyMagic",
    }) do
        local family = assert(Families.get(source_kind))
        check(
            family.Route == "LegacyEnemyOutgoing"
                and not family.PlayerToNpc
                and not family.ActivationBlocker,
            source_kind
                .. " remains outside player-to-NPC activation"
        )
    end

    check(
        Families.is_periodic_status_skill("WayfinderWound")
            and Families.is_periodic_status_skill(
                "MysticPoisonCurse"
            )
            and not Families.is_periodic_status_skill("IronCleave"),
        "reviewed DEBUFF casts are intercepted before generic damage"
    )

    local blockers = Families.activation_blockers()
    check(
        #blockers == 1,
        "only RangerArea still blocks player-to-NPC activation"
    )
    check(
        blockers[1] == "RangerArea",
        "activation blocker list remains deterministic"
    )
    check(
        not Families.activation_ready(),
        "production dispatch audit remains not ready"
    )
    check(
        Families.get("UnknownDamageFamily") == nil,
        "unknown source kinds remain explicitly unaudited"
    )

    print((
        "[C4 Damage Family Audit] FAMILY_AUDIT_PASS: "
            .. "%d assertions blockers=1 activation_ready=false"
    ):format(checks))
end

main()
