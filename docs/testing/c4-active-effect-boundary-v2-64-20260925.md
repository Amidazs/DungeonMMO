# C4 Active Effect Boundary v2.64 — Acceptance

Date: 25 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.

## Commit tested

`1e01640f5eda5729d6feb1564dbe2f1edf2b2204`

## Fresh build results

- Base: PASS;
- Dungeon: PASS.

## Focused Studio results

Base: **10/10 PASS**.  
Dungeon: **11/11 PASS**.

Notable results:

- C4 Resource Boundary — 47 assertions, fixed blockers=1;
- C4 Active Source State — 17 assertions;
- C4 Persistent Active Coverage — 4 assertions,
  skills=21, ranks=25, missing=0, reviews=0;
- C4 Combined Effects — 14 assertions;
- C4 Nine-Class Skills — 554 assertions;
- Mana Service — 13 assertions in Dungeon.

## Active-effect guarantees

The source candidate now receives actual server-observed toggles and timed
effects rather than learned-skill assumptions.

Timed effects expire from server monotonic time. Unmapped live effects remain
visible and keep the source migration blocked. Forged source ranks from another
class are rejected again at the unified-stat boundary.

All currently trainable persistent stat-effect ranks through level 30 are
covered by the pinned C4 active/toggle source catalogue.

## Remaining coordinated blocker

`LiveCPRuntimeUnavailable` is the only fixed resource migration blocker.

This does not mean live C4 HP/MP/CP has been enabled. The boundary still has
`CanApplyLive=false`, and the existing gameplay resources remain unchanged.

## Environment note

The second Studio launch printed OpenXR loader warnings because no active XR
runtime is registered on the test machine. Both requested focused suites still
completed successfully.

Evidence directory:

`%TEMP%\DungeonMMO_v264_active_boundary_r2`

No place publish, production DataStore write or main merge occurred.
