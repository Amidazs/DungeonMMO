# C4 Combat Point Runtime v2.65 — Acceptance

Date: 25 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.

## Commit tested

`2aae512409e00bb1f706ae11b7ebe689c4e4ce60`.

## Fresh builds

- Base Rojo build: PASS;
- Dungeon Rojo build: PASS.

Evidence directory:

`%TEMP%\DungeonMMO_v265_cp_runtime`

## Focused Studio

Base: **11/11 PASS**.  
Dungeon: **12/12 PASS**.

The new `C4CombatPointRuntimeTest` passes **18 assertions**.

## Source checks

The acceptance locks the pinned C4 behaviour:

- three-second CP regeneration period;
- default CP regeneration multiplier 1.0;
- BaseHpRegen + source level-band arithmetic;
- C4 level modifier and CON bonus;
- sitting x1.5;
- standing x1.1;
- walking x1;
- running x0.7;
- playable-attacker damage consumes CP first;
- NPC/non-playable damage bypasses CP.

These rules were verified against pinned `Formulas`, `Config` and
`PcStatus` source before the test was accepted.

## Runtime checks

The isolated server runtime proves:

- unconfigured CP cannot alter damage;
- incomplete/uncertified source boundaries cannot configure max CP;
- certified source `MAX_CP` can configure current/max CP;
- playable damage mutates server-owned CP;
- NPC damage leaves CP untouched;
- restore clamps at source max;
- preserving a resource across a lower max clamps correctly;
- replacing the character invalidates stale CP state;
- capability metadata is authoritative and live-disabled by default.

## Migration-boundary result

For clean reviewed launch characters:

- equipment source mapping: ready;
- actually-owned passive mapping: ready;
- authoritative active-effect state: ready;
- CP runtime capability: ready;
- activation blockers: **0**;
- `CutoverPrerequisitesReady=true`;
- `CanApplyLive=false`;
- all live HP/MP/CP integration flags remain false.

No live resource cutover was enabled and no normal Dungeon PvE damage path was
changed.
