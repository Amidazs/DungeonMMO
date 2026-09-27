# C4 Orc Monk / Spiritclaw v3.20 Green Acceptance

Date: 27 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Accepted code/test HEAD:
`fe3511593089c05b49fb37ed0b13307d50ce0488`.

## Scope

This record closes the level-30 Orc Fighter -> Orc Monk / Spiritclaw backend
gate.

It covers exact class-44 starter inheritance, class-47 source inventory,
independent DungeonMMO progression, exact rank schedules, source effects,
passives, unified stats, resource migration, Fist physical casting, charge
authority, stun, physical movement slow, self aspects, inherited Relax and
genuine unpublished Play behavior.

No production publish, `main` merge, production DataStore mutation or
animation work is included.

## Source result

- starter source class: **Orc Fighter**, class ID **44**;
- starter source rows through first transfer: **31**;
- starter source families: **9**;
- first-transfer source class: **Orc Monk**, class ID **47**;
- creative class: **Spiritclaw**;
- exact first-transfer rows through level 30: **41**;
- mapped first-transfer rows: **41**;
- source brackets: **12 / 14 / 15** at 20 / 24 / 28;
- creative/source families: **10**;
- source-map gaps: **0**;
- exact level-30 resources: **1230 HP / 327 MP / 617 CP**.

The catalogue is pinned to C4 commit
`07f8536384e799f128d44198dd7ab23519660eea`.

## Inherited Orc Fighter behavior

Spiritclaw retains genuine class-44 source ownership after first transfer.

Accepted inheritance covers:

- Orc Iron Punch;
- Orc Relax;
- Orc Fighter passive source ranks;
- current Orc Monk authenticated scope plus exact inherited Orc Fighter
  source-effect scope.

This keeps advancement inheritance explicit without copying class-44 rows into
the class-47 tree.

## Physical combat

The live physical bridge accepts the reviewed Orc Monk paths:

- inherited Orc Iron Punch;
- Spiritclaw Iron Fist;
- Stunning Fist;
- Crippling Palm;
- Force Burst after source charge validation.

Weapon conditions are authoritative and require the reviewed
Fist/DualFist family where the source demands it.

### Stunning Fist

Stunning Fist reaches the live NPC physical-stun authority. The rehearsal
validates:

- exact source roll output;
- `Landed == (Roll < Rate)`;
- exact source stun duration **9 seconds**;
- landed rolls apply NPC stun;
- resisted rolls do not apply stun state.

### Crippling Palm

Crippling Palm reaches the live physical movement-slow authority and preserves:

- movement multiplier **0.7**;
- duration **120 seconds**;
- exact landed/resisted result from source success calculation.

## Force charge runtime

Focus Force uses server-owned `C4SourceChargeService` state:

- starts at 0;
- creates exactly 1 charge;
- maximum charges = 1;
- exact source reuse = **1000 ms**;
- a post-reuse second cast stays capped at 1.

Force Burst:

- rejects before cast spend when charge is 0;
- requires exactly 1 charge;
- consumes exactly 1 charge;
- leaves 0 charges;
- applies exact reviewed source-charge damage multiplier **0.8**;
- deals real live NPC damage.

The final Play harness waits 1.1 seconds before the max-charge Focus Force
attempt so the assertion tests the charge cap instead of intentionally
colliding with source reuse.

## Self effects and inherited toggle

Bear Aspect and Wolf Aspect each reach the live timed self-effect authority and
preserve their exact **120-second** durations.

Each aspect enters authoritative active-source state and is cleared between
checks so the rehearsal does not hide stacking/state leakage.

Inherited Orc Relax reaches the source-toggle authority, enforces its
sitting/missing-health requirement and deactivates cleanly.

## Regression evidence

Final closure:

- `git diff --check`: PASS;
- fresh Dungeon Rojo build: PASS;
- focused Spiritclaw/backend set: **15 / 15 PASS**;
- source-effect catalogue: **138 skills / 553 unique rank-effect pairs**;
- level-30 skill-tree coverage:
  **19 paths / 1193 rows / 138 unique source skill IDs**;
- launch source audit: **15 / 18 branches**;
- launch rank schedules mapped: **15 / 18 branches**;
- accepted Play log `FLog::CreatorError` count: **0**;
- accepted Play `[Spiritclaw Live] FAIL` count: **0**.

## Play evidence

A fresh unpublished Dungeon build ran `C4OrcMonkLiveHarness` through
StudioTestService Play mode.

Observed accepted markers:

- `PHYSICAL_PASS inherited_fist_stun_cripple=true`;
- `FORCE_PASS gate_focus_cap_burst=true`;
- `ASPECT_PASS bear_wolf=true`;
- `RELAX_PASS inherited=true`;
- `PHYSICAL_FORCE_ASPECT_RELAX_ROLLBACK_PASS`;
- `VERIFIED_PLAY_MODE_PASS`.

The run crossed real source cutover, authenticated class-47 progression,
inherited class-44 active ownership, source timing and reuse, real reviewed
equipment, live NPC damage, NPC stun and movement-slow authorities,
server-owned source charges, active source-effect state, source toggle upkeep
and complete rollback.

## Repository state

Expected local-only residue after acceptance:

- `tools/animation/quadruped/engine/quadruped_blender/__pycache__/`;
- `tools/animation/quadruped/engine/quadruped_core/__pycache__/`.

These pre-existing folders were not modified or cleaned.
