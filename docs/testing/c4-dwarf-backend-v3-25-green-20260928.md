# Dwarf backend acceptance evidence — v3.25
**Date:** 28 September 2026

## Scope

Validation covered Dwarven Fighter inheritance plus both independent Dwarf
first-transfer careers: Gearwright (Artisan source class 56) and Deepclaimer
(Scavenger source class 54).

Permanent source changes were made in GitHub. Studio was used only to build and
exercise an unpublished Rojo validation place.

## Validation environment

- Branch: `wip/phase-4-test-hud-integration-v1`
- Rojo: 7.7.0-rc.1
- Studio: unpublished temporary `.rbxlx` built from
  `default.project.json`
- Tests executed on the **Server DataModel during Play**

## Focused backend result

Final marker:

`VERIFIED_DWARF_BACKEND_FOCUS_PASS 25`

The 25-suite package covered:

- Artisan and Scavenger source audits;
- Gearwright and Deepclaimer progression;
- 1G+2C and 2G+1C profession capacity including spoof rejection and
  persistence;
- Q418/Q417 ordered quest proof rules;
- both Dwarf mentor-award chains;
- salvage table/economy boundaries;
- Spoil/Sweep server authority;
- scheduled salvage cast bridge;
- Dwarven Fighter source inheritance;
- first-transfer registry;
- creative/source link audit;
- complete level-30 source tree/effect coverage;
- exact source primary stats;
- owned-passive and active-source state;
- unified source stats;
- physical/self-effect/companion cast bridges;
- source-cast runtime composition.

## Corpse-retention result

Final marker:

`VERIFIED_DWARF_CORPSE_RETENTION_PASS`

The existing Dungeon enemy cleanup regression confirms:

- unspoiled non-beasts retain normal fast retirement;
- registered skinnable beasts retain their harvest window;
- spoiled, unclaimed non-beasts retain a visible non-colliding corpse;
- normal loot completes before salvage interaction;
- already-Swept enemies do not gain the extended salvage window.

## Live Workspace lifecycle

Final marker:

`VERIFIED_DWARF_LIVE_SPOIL_SWEEP_LIFECYCLE_PASS`

A real server Workspace model was:

1. spawned alive,
2. marked through `C4DwarfSalvageService` with source Spoil,
3. killed,
4. passed through real `DungeonEnemyCleanup.retire`,
5. verified visible/non-colliding with `LootComplete=true`,
6. Swept once for one deterministic specialist material,
7. checked again to prove duplicate Sweep rejection and no duplicate grant.

Observed accepted result:

- item: `dense_mineral_shard`
- inventory grants: **1**
- duplicate grants: **0**

## Validation fixes discovered by Studio

Studio exposed and we corrected:

1. stale Gearwright aggregate source totals after adding Scavenger;
2. incomplete profession test quest fixtures that migration correctly
   sanitized;
3. incorrect Scavenger per-level summary counts.

The pinned Scavenger row file contains 49 rows and proves:

- level 20: **15**
- level 24: **15**
- level 28: **19**

## Remaining non-claims

This evidence does not claim:

- fresh Dwarf creation is enabled;
- Q417/Q418 NPC/world binding is complete;
- Spoil Festival has a reviewed Roblox radius conversion;
- salvage source casting is enabled in production;
- Dwarf final VFX/animations/UI are complete;
- anything was published to production.
