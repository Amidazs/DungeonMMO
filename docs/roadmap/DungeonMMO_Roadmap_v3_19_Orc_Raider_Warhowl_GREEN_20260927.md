# DungeonMMO Roadmap v3.19 — Orc Raider / Warhowl GREEN

Date: 27 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v3.18](
DungeonMMO_Roadmap_v3_18_ShIllien_Oracle_Duskseer_GREEN_20260927.md).

## Status

**GREEN — Orc Fighter -> Orc Raider / Warhowl backend accepted through level 30.**

Evidence:
[Warhowl v3.19 green acceptance](
../testing/c4-orc-raider-warhowl-v3-19-green-20260927.md).

Accepted code/test HEAD before documentation:
`1b42c2d0b2de88bc14adec64727db4e3c5177a05`.

## Class and source coverage

Warhowl is the independent DungeonMMO career for the original Orc Raider
first-transfer branch:

- race: Orc;
- starter family: Fighter;
- inherited source starter class: Orc Fighter, class ID 44;
- source first-transfer class: Orc Raider, class ID 45;
- transfer branch: `OrcRaider`;
- creative class: `Warhowl`;
- Orc Fighter starter source rows: **31 / 31** across **9 families**;
- Orc Raider level-30 source rows: **63 / 63 mapped**;
- Orc Raider source brackets: **19 / 21 / 23** at levels **20 / 24 / 28**;
- distinct Warhowl source families: **16**;
- source-map gaps: **0**.

The source inventory remains pinned to C4 commit
`07f8536384e799f128d44198dd7ab23519660eea`.

Tracked source learning coverage is now **18 paths / 1152 rows /
130 unique source skill IDs**. Launch audit coverage is **14 / 18
first-transfer branches source-audited** and **14 / 18 rank schedules mapped**.

## Exact class-45 stats

The accepted Warhowl source template preserves its Orc Fighter ancestry and
exact level-30 resources:

- **1269 HP / 327 MP / 884 CP**;
- source physical timing remains based on authenticated Orc Raider stats;
- inherited class-44 source skills remain resolvable after first transfer.

Owned Orc Fighter and Warhowl passives cross the unified-stat and
resource-migration boundaries without using forged race or client state.

## Runtime completion

The reviewed Warhowl runtime covers:

- inherited Orc Power Strike and Iron Punch;
- Skullbreaker physical damage plus source stun roll;
- Crushing Blow single-target physical damage;
- Sweeping Arc target-area polearm damage;
- Woundbind source bleed cleanse;
- Fury timed self buff;
- War Roar timed self buff plus source heal;
- Precision Stance source toggle;
- Predator Stance source toggle;
- inherited Orc Relax source toggle.

Weapon-family requirements are enforced by authoritative equipment state,
including fist/dual-fist, blunt and polearm routes. Virtual Fist handling keeps
unarmed/fist source requirements explicit instead of bypassing weapon checks.

## Inherited source authority

Warhowl exposed an important source-inheritance boundary. An Orc Raider can
own and cast inherited Orc Fighter ACTIVE/TOGGLE skills whose source rows
remain in class-44 scope.

The accepted source pipeline now carries both identities:

- authenticated current character scope: `OrcRaider`;
- exact inherited source effect scope when applicable: `OrcFighter`.

Cast timing validates the current authenticated character scope while preserving
the inherited source skill identity. This allows genuine Orc Fighter skills to
survive advancement without weakening source-scope checks.

## Live acceptance fixes

### Legacy loadout gate on C4 toggles

The first genuine Play rehearsal passed physical and self-effect phases, then
failed the first stance with `SkillNotEquipped`.

The C4 toggle authority was still consulting the legacy DungeonMMO hotbar
`is_skill_usable()` gate. Source physical/self-effect casting already
authenticates ownership, class, level, equipment and source identity directly.

The toggle service now does the same:

- verifies the purchased creative rank;
- resolves the exact authenticated ACTIVE/TOGGLE source row;
- stores and revalidates source skill/rank identity during upkeep;
- does not require a legacy loadout slot;
- remains server-owned and client-authority-free.

A regression deliberately errors if the toggle service ever consults the
legacy loadout authority again.

### Skullbreaker stun acceptance

The next Play rehearsal exposed a test defect rather than a combat defect.
Skullbreaker damage always reached the live stun-bearing executor, but the C4
stun landing is a real source probability roll. The harness incorrectly
required it to land on every run.

Acceptance now verifies the exact source roll and **9-second** source duration
whether the roll lands or is resisted. A landed roll must apply live NPC stun
state; a resisted roll must not.

## Fresh validation

Final closure at the accepted code/test HEAD:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS;
- focused Orc/Warhowl backend acceptance: **20 / 20 PASS**;
- source-effect catalogue: **130 skills / 527 unique rank/effect pairs**;
- source learning-tree coverage: **18 paths / 1152 rows /
  130 unique source skill IDs**;
- accepted Play log: **0 CreatorErrors**;
- accepted Play log: **0 Warhowl failures**.

Only the pre-existing quadruped Python `__pycache__` folders remain
untracked locally.

## Genuine unpublished Play rehearsal

`C4OrcRaiderLiveHarness` passed against a fresh unpublished Dungeon build
and the real source cutover/cast runtime.

Accepted markers:

- `PHYSICAL_PASS fist_blunt_stun_polearm=true`;
- `SELF_EFFECT_PASS woundbind_fury_roar=true`;
- `TOGGLE_PASS precision_predator_relax=true`;
- `PHYSICAL_SELF_TOGGLE_ROLLBACK_PASS`;
- `VERIFIED_PLAY_MODE_PASS`.

The rehearsal used real authenticated Warhowl progression, reviewed weapons,
real source timing and resource boundaries, reviewed Marauder targets, source
active-effect state, live NPC stun/AoE authorities and clean source-cutover
rollback.

## Next backend class

Continue source order with **Orc Monk**.

Use the same fail-closed sequence:

1. exact source inventory;
2. independent creative career;
3. exact rank mapping;
4. source mechanics and inherited Orc Fighter behavior;
5. focused Studio acceptance;
6. genuine unpublished Play rehearsal;
7. green documentation.

Do not infer the Orc Monk class ID or skill catalogue; derive both from the
same pinned C4 source before authoring gameplay.

No `main` merge, Roblox publish, production DataStore mutation or animation
work was performed.
