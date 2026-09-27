# C4 Orc Raider / Warhowl v3.19 Green Acceptance

Date: 27 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Accepted code/test HEAD:
`1b42c2d0b2de88bc14adec64727db4e3c5177a05`.

## Scope

This record closes the level-30 Orc Fighter -> Orc Raider / Warhowl backend
gate.

It covers exact class-44 starter inheritance, class-45 source inventory,
independent DungeonMMO progression, exact rank schedules, source effects,
passives, unified stats, resource migration, physical cast routing, self
effects, source toggles and genuine unpublished Play behavior.

No production publish, `main` merge, production DataStore mutation or
animation work is included.

## Source result

- starter source class: **Orc Fighter**, class ID **44**;
- starter source rows through first transfer: **31**;
- starter source families: **9**;
- first-transfer source class: **Orc Raider**, class ID **45**;
- creative class: **Warhowl**;
- exact first-transfer rows through level 30: **63**;
- mapped first-transfer rows: **63**;
- source brackets: **19 / 21 / 23** at 20 / 24 / 28;
- creative/source families: **16**;
- source-map gaps: **0**;
- exact level-30 resources: **1269 HP / 327 MP / 884 CP**.

The catalogue is pinned to C4 commit
`07f8536384e799f128d44198dd7ab23519660eea`.

## Inherited Orc Fighter behavior

Warhowl retains genuine owned class-44 skills after first transfer rather than
copying them into the class-45 tree.

Acceptance covers inherited:

- Orc Iron Punch;
- Orc Power Strike;
- Orc Relax;
- Orc passive source ranks and source stat baselines.

The active resolver can return `OrcFighter` as the exact source-effect scope
while the current authenticated class boundary remains `OrcRaider`.

## Physical combat

The live physical bridge covers five reviewed Orc families:

- Orc Power Strike;
- Orc Iron Punch;
- Warhowl Crushing Blow;
- Warhowl Skullbreaker;
- Warhowl Sweeping Arc.

The runtime preserves source weapon conditions, source cast/effect ranges,
physical attack-speed timing, physical reuse, server-owned damage and
Soulshot/source effect behavior.

Skullbreaker routes through live NPC physical damage followed by the exact
source stun success roll. Sweeping Arc uses source target-area behavior and
the reviewed radius.

## Self effects and toggles

Accepted self effects:

- Woundbind -> source bleed cleanse;
- Fury -> exact 60-second source timed self buff;
- War Roar -> exact 600-second source timed self buff plus source heal.

Accepted source toggles:

- Precision Stance;
- Predator Stance;
- inherited Orc Relax.

Relax preserves its source sitting/missing-HP conditions and periodic upkeep.
Precision/Predator preserve their source MP upkeep formula.

## Defects found during live acceptance

### C4 toggles were still loadout-dependent

The first Play run reached physical and self-effect success, then failed at
the first stance with `SkillNotEquipped`.

Root cause: `C4SourceToggleService` still delegated activation/upkeep
authorization to the legacy DungeonMMO equipped-skill gate. That was wrong for
the newer source runtime and particularly exposed Warhowl inheritance.

The service now authenticates:

- actual purchased creative rank;
- exact ACTIVE/TOGGLE source resolution;
- exact stored source skill/rank identity during continuation;
- current character ownership.

Capability now explicitly reports owned-source-rank authority and legacy
loadout independence. A regression fails if the old loadout gate is consulted.

### Skullbreaker harness required RNG success

A later Play run reached Skullbreaker but failed because the harness required
the stun to land every time.

The live executor was correct: damage lands first, then C4 stun success is
rolled. On resistance the live result remains a stun-bearing physical cast
with the exact source roll but does not apply NPC stun state.

The final harness therefore verifies:

- live stun executor route;
- exact numeric source rate and roll;
- `Landed == (Roll < Rate)`;
- nested source duration **9 seconds**;
- landed rolls apply 9-second NPC stun;
- resisted rolls apply no stun state.

## Regression evidence

Final closure:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS;
- focused Orc/Warhowl backend set: **20 / 20 PASS**;
- source-effect catalogue: **130 skills / 527 unique rank pairs**;
- level-30 skill-tree coverage: **18 paths / 1152 rows /
  130 unique source skill IDs**;
- launch source audit: **14 / 18 branches**;
- launch rank schedules mapped: **14 / 18 branches**;
- accepted Play log `FLog::CreatorError` count: **0**;
- accepted Play `[Warhowl Live] FAIL` count: **0**.

## Play evidence

A fresh unpublished Dungeon build ran `C4OrcRaiderLiveHarness` through
StudioTestService Play mode.

Observed accepted markers:

- `PHYSICAL_PASS fist_blunt_stun_polearm=true`;
- `SELF_EFFECT_PASS woundbind_fury_roar=true`;
- `TOGGLE_PASS precision_predator_relax=true`;
- `PHYSICAL_SELF_TOGGLE_ROLLBACK_PASS`;
- `VERIFIED_PLAY_MODE_PASS`.

The Play run crossed real source cutover, inherited Orc Fighter source
resolution, source physical timing, real reviewed equipment, physical damage,
NPC stun/AoE authorities, active source effects, toggle upkeep and full
rollback.

## Repository state

Expected local-only residue after acceptance:

- `tools/animation/quadruped/engine/quadruped_blender/__pycache__/`;
- `tools/animation/quadruped/engine/quadruped_core/__pycache__/`.

These pre-existing folders were not modified or cleaned.
