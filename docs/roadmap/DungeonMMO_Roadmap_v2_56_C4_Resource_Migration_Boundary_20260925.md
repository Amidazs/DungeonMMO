# DungeonMMO Roadmap v2.56 — C4 Resource Migration Boundary

Date: 25 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.  
Previous: [v2.55](
DungeonMMO_Roadmap_v2_55_C4_Shared_Heal_And_Split_MP_Rules_20260925.md).

## Goal

Continue the all-class Chronicle 4 migration by defining the exact server-side
boundary that must be crossed before any authenticated Human/Elf starter or
first-transfer character can have live HP, MP or CP switched to the original
C4 model.

The project already has exact source base HP/MP/CP for all nine current
original paths. The unsafe step would be to apply those values while leaving
the current custom equipment, purchased-passive, active-buff and resource
systems layered on top. v2.56 therefore makes the cutover fail closed instead
of mixing two balance models.

Pinned source remains:

`Neco-spain/l2jadmins_C4-Scions-of-Destiny`  
commit `07f8536384e799f128d44198dd7ab23519660eea`.

## GitHub implementation

### Shared migration boundary

Added
`src/ReplicatedStorage/Core/Shared/C4ResourceMigrationBoundary.luau`.

For an authenticated server-owned original character it exposes:

- exact source base MaxHP;
- exact source base MaxMP;
- exact source base MaxCP;
- verified source class scope and level;
- source provenance;
- explicit live-integration flags;
- an immutable list of unresolved cutover blockers.

The current blockers are:

1. `OriginalInventoryMappingIncomplete`;
2. `OriginalOwnedPassiveMappingIncomplete`;
3. `ActiveEffectOrderingIncomplete`;
4. `LiveCPRuntimeUnavailable`.

`CanApplyLive` is therefore always false in this milestone.

This is deliberate. Current creative equipment bonuses, current purchased
passive effects and custom active buffs must not be applied on top of exact
C4 source base resources and then described as C4 parity.

### Authenticated runtime API

Extended
`src/ServerScriptService/Core/Services/ProgressionRuntimeState.luau` with:

`get_c4_resource_migration_boundary(user_id)`.

The function uses only the already-seeded authoritative selected-character
snapshot. It does not accept client-supplied race, class, level or advancement
proof.

Copied first-transfer ClassIds without the genuine original mentor/quest
receipt remain rejected through the same source identity rules used by the
existing C4 stat and skill previews.

## Tests authored, execution pending

Added
`C4ResourceMigrationBoundaryTest.server.luau`.

It covers all nine original paths at level 30:

- Human Fighter: 922 / 319 / 418 HP/MP/CP;
- Human Mystic: 699 / 466 / 366;
- Elven Fighter: 792 / 324 / 353;
- Elven Mystic: 666 / 469 / 348;
- Human Warrior / Ironvow: 1070 / 320 / 849;
- Human Knight / Oathguard: 1018 / 320 / 610;
- Human Rogue / Ashenblade: 983 / 320 / 399;
- Elven Knight / GreenwardWarden: 902 / 325 / 453;
- Elven Scout / GreenwardScout: 874 / 325 / 354.

The test also asserts that every path remains live-disabled with all four
coordinated blockers present, and that missing owners, forged advancement
receipts and level 31 fail closed.

**No v2.56 Rojo build or Studio execution is claimed.**

The v2.53 500-assertion result and earlier source-stat tests remain valid for
their own commits only; they do not validate this new boundary.

## What this milestone does not do

v2.56 does not:

- change Humanoid MaxHealth;
- change ManaService MaxMP or regeneration;
- add a CP runtime;
- translate current creative inventory into the complete original item model;
- translate every actually owned creative passive rank back to its source rank;
- replace current active buffs with C4 active-effect ordering;
- enable the Scout Elemental Heal;
- relabel any candidate creative skill as exact C4 parity.

## Next implementation

The next safe GitHub-only work is to close the resource blockers in dependency
order rather than activating one class early:

1. build a server-owned current-item to reviewed C4 source-item migration map,
   keeping unsupported items explicit rather than guessed;
2. build owned creative-rank to source-passive resolution for the nine
   authenticated paths using the existing source link map and learning tree;
3. extend the unified source stat calculator so exact source item and owned
   passive ordering can produce the actual live-resource candidate;
4. define active-effect ordering and the first CP runtime contract;
5. only then switch Humanoid/ManaService/CP coherently and run all-class,
   multiplayer, interruption and exploit regressions;
6. after that, enable source skill families such as the Scout Elemental Heal on
   the shared live resource path.

No main merge, Roblox publication, production DataStore mutation or
art/animation worktree changes. Permanent scripts and documents remain GitHub
only.
