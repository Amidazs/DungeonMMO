# DungeonMMO Roadmap v3.20 — Orc Monk / Spiritclaw GREEN

Date: 27 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous:
[Roadmap v3.19](
DungeonMMO_Roadmap_v3_19_Orc_Raider_Warhowl_GREEN_20260927.md).

## Status

**GREEN — Orc Fighter -> Orc Monk / Spiritclaw backend accepted through
level 30.**

Evidence:
[Spiritclaw v3.20 green acceptance](
../testing/c4-orc-monk-spiritclaw-v3-20-green-20260927.md).

Accepted code/test HEAD before documentation:
`fe3511593089c05b49fb37ed0b13307d50ce0488`.

## Class and source coverage

Spiritclaw is the independent DungeonMMO career for the original Orc Monk
first-transfer branch:

- race: Orc;
- starter family: Fighter;
- inherited source starter class: Orc Fighter, class ID 44;
- source first-transfer class: Orc Monk, class ID 47;
- transfer branch: `OrcMonk`;
- creative class: `Spiritclaw`;
- Orc Fighter starter source rows: **31 / 31** across **9 families**;
- Orc Monk level-30 source rows: **41 / 41 mapped**;
- Orc Monk source brackets: **12 / 14 / 15** at levels **20 / 24 / 28**;
- distinct Spiritclaw source families: **10**;
- source-map gaps: **0**.

The source inventory remains pinned to C4 commit
`07f8536384e799f128d44198dd7ab23519660eea`.

Tracked source learning coverage is now **19 paths / 1193 rows /
138 unique source skill IDs**. The common source-effect catalogue covers
**138 source skills / 553 unique rank-effect pairs**.

Launch audit coverage is **15 / 18 first-transfer branches source-audited**
and **15 / 18 rank schedules mapped**.

## Exact class-47 stats

The accepted Spiritclaw source template preserves exact class-47 level-30
resources:

- **1230 HP / 327 MP / 617 CP**;
- STR 40 / DEX 26 / CON 47;
- INT 18 / WIT 12 / MEN 27;
- CON bonus 1.77;
- MEN bonus 1.31.

Inherited Orc Fighter source skills and passives remain resolvable after first
transfer through authenticated current-class plus exact source-effect scope.

## Runtime completion

The reviewed Spiritclaw runtime covers:

- inherited Orc Iron Punch;
- Spiritclaw Iron Fist;
- Stunning Fist physical damage plus exact source stun roll;
- Crippling Palm physical damage plus source movement slow;
- Focus Force server-owned source charge generation;
- Force Burst charge-gated physical damage;
- Bear Aspect timed self buff;
- Wolf Aspect timed self buff;
- inherited Orc Relax source toggle;
- Fist/DualFist weapon-condition enforcement;
- inherited Orc Fighter passives, unified stats and resource migration.

### Force charge authority

Focus Force creates exactly one server-owned C4 charge and has the exact
**1000 ms** source reuse. A second cast after reuse proves the one-charge cap
without increasing the stored charge.

Force Burst fails before source cast spend when no charge exists. With one
charge it consumes exactly one charge and applies the exact reviewed
**0.8 source charge damage multiplier**, leaving zero charges.

### Control effects

Stunning Fist preserves its real C4 success roll. A landed roll applies the
exact **9-second** NPC stun; a resisted roll applies no stun state.

Crippling Palm preserves the reviewed physical-slow authority:

- source slow multiplier: **0.7**;
- source duration: **120 seconds**;
- landed/resisted state follows the exact source success calculation.

### Aspects and inherited Relax

Bear Aspect and Wolf Aspect each preserve the exact **120-second** source
duration and enter authoritative active-source state.

Inherited Orc Relax remains usable after advancement and crosses the live
source-toggle authority with its sitting/missing-health condition and clean
deactivation.

## Fresh validation

Final closure at the accepted code/test HEAD:

- `git diff --check`: PASS;
- fresh Dungeon Rojo build: PASS;
- focused Spiritclaw/backend acceptance: **15 / 15 PASS**;
- source-effect catalogue: **138 skills / 553 unique rank-effect pairs**;
- source learning-tree coverage:
  **19 paths / 1193 rows / 138 unique source skill IDs**;
- launch source audit: **15 / 18 branches**;
- launch rank schedules mapped: **15 / 18 branches**;
- accepted Play log: **0 CreatorErrors**;
- accepted Play log: **0 Spiritclaw failures**.

Only the pre-existing quadruped Python `__pycache__` folders remain
untracked locally.

## Genuine unpublished Play rehearsal

`C4OrcMonkLiveHarness` passed against a fresh unpublished Dungeon build and
the real source cutover/cast runtime.

Accepted markers:

- `PHYSICAL_PASS inherited_fist_stun_cripple=true`;
- `FORCE_PASS gate_focus_cap_burst=true`;
- `ASPECT_PASS bear_wolf=true`;
- `RELAX_PASS inherited=true`;
- `PHYSICAL_FORCE_ASPECT_RELAX_ROLLBACK_PASS`;
- `VERIFIED_PLAY_MODE_PASS`.

The live rehearsal uses a real authenticated level-30 Spiritclaw state,
reviewed Fist equipment, inherited Orc Fighter skills, reviewed Marauder
targets, real source timing/reuse, server-owned charge state, NPC
stun/movement-slow authorities, active-source state, Relax upkeep and complete
source-cutover rollback.

The final harness correction waits beyond Focus Force's exact source
**1000 ms reuse** before testing max-charge behavior. This avoids converting a
real source reuse rejection into a false gameplay failure.

## Next backend class

Continue source order with **Orc Shaman**.

Use the same fail-closed sequence:

1. exact pinned source inventory;
2. Orc Mystic starter inheritance audit where required;
3. independent creative career;
4. exact rank mapping;
5. source mechanics and inherited starter behavior;
6. focused Studio acceptance;
7. genuine unpublished Play rehearsal;
8. green documentation.

Do not infer Orc Shaman skill IDs, ranks, stats or mechanics. Derive them from
the same pinned C4 source before authoring gameplay.

No `main` merge, Roblox publish, production DataStore mutation or animation
work was performed.
