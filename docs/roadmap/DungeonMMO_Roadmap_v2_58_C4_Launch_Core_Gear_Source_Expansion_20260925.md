# DungeonMMO Roadmap v2.58 — C4 Launch Core Gear Source Expansion

Date: 25 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.  
Previous: [v2.57](
DungeonMMO_Roadmap_v2_57_C4_Creative_Item_Source_Map_20260925.md).

## Goal

Continue closing the all-class Chronicle 4 inventory blocker by expanding the
reviewed original source-item set and linking every currently usable
Weapon/Body/OffHand item in the launch backend to an explicit original C4
source record.

This remains source-first migration work. Current custom CombatModifiers are
not accepted as C4 values.

Pinned source remains:

`Neco-spain/l2jadmins_C4-Scions-of-Destiny`  
commit `07f8536384e799f128d44198dd7ab23519660eea`.

## New reviewed source items

`C4SourceItemReference` now additionally records:

- item 291 Trident — D-grade polearm, P.Atk 40, M.Atk 10,
  crit 8, accuracy -3, attack speed 325, two-handed;
- item 1181 Neti's Bow — P.Atk 45, M.Atk 5,
  crit 12, accuracy -3, attack speed 293, two-handed;
- item 1182 Neti's Dagger — P.Atk 19, M.Atk 5,
  crit 12, accuracy -3, attack speed 433;
- item 352 Brigandine Tunic — D-grade heavy body, P.Def 103;
- item 395 Manticore Skin Shirt — D-grade light body, P.Def 77.

These values come directly from the pinned C4 `weapon.sql` and
`armor.sql` records used by the existing source reference layer.

## Current creative core-slot coverage

`C4CreativeItemSourceMap` now has 18 reviewed creative links covering every
currently defined Weapon, Body and OffHand launch item.

New links include:

- current Warrior polearm -> C4 Trident 291;
- all three current class-specific D-grade heavy bodies -> Brigandine 352;
- Scout expert light body -> Manticore 395;
- exact trial dagger/bow -> Neti's Dagger 1182 / Neti's Bow 1181;
- Human Knight training mace -> reviewed C4 Club 4;
- Warrior basic light body -> reviewed C4 Leather Shirt 22.

The three class-specific creative D-grade heavy bodies intentionally share the
same original source stat record. Their names and class acquisition remain
DungeonMMO presentation/progression distinctions; the source stat model is the
historical C4 heavy-body record.

## Six-slot safety

DungeonMMO has six current equipment slots:

- Weapon;
- OffHand;
- Helmet;
- Body;
- Gloves;
- Boots.

The C4 stat calculator currently integrates only Weapon/Body/OffHand source
operations. `resolve_loadout` therefore now rejects any equipped
Helmet/Gloves/Boots with
`AdditionalCreativeEquipmentSlotsNotIntegrated` instead of silently ignoring
them.

This means the core-slot catalogue is now reviewed, but the overall inventory
migration blocker remains open until head/hands/feet source ordering and values
are integrated.

## Resource boundary integration

`C4ResourceMigrationBoundary` now attempts to translate the actual
server-owned current equipment snapshot through the reviewed source map.

It exposes:

- `ReviewedCoreLoadoutReady`;
- `ReviewedCoreLoadoutReason`;
- `ReviewedSourceItemIds`;
- `ReviewedSourceKinds`.

Even with a fully reviewed core loadout,
`OriginalInventoryIntegrated=false` and `CanApplyLive=false` remain correct
until the other paperdoll slots and the remaining resource blockers are closed.

## Tests authored

Updated `C4CreativeItemSourceMapTest.server.luau` for all 18 reviewed
core-slot creative links, exact polearm/D-grade mappings, and extra-slot
fail-closed behavior.

Updated `C4ResourceMigrationBoundaryTest.server.luau` so an authenticated
Knight with reviewed sword/heavy/shield exposes exact source IDs, while adding
an unintegrated helmet blocks the reviewed loadout.

Added `C4LaunchCoreGearSourceTest.server.luau` for the five new source items,
their exact values and the two-handed polearm/shield exclusion.

## Execution status

At authoring time these v2.58 tests are not yet claimed green. The user has now
re-enabled local playtesting, so the next action is to fast-forward the local
worktree, build disposable Base/Dungeon places and execute the focused pending
v2.55-v2.58 source/resource suites in Studio.

No Roblox publish, production DataStore mutation or main merge is part of that
test pass.

## Next backend work after tests

Once the pending source/resource suites are green:

1. source and integrate Helmet/Gloves/Boots C4 paperdoll operations;
2. close the actual-owned-passive translation blocker;
3. define active-effect ordering and CP authority;
4. then perform one coherent all-nine live HP/MP/CP/resource cutover;
5. only after that enable source active-skill families such as the Scout heal.

Permanent code and documentation changes remain GitHub-only. Remote Desktop
Commander is reserved for fast-forwarding, disposable builds and unpublished
playtesting.
