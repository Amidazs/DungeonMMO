# C4 Shillien Oracle / Duskseer v3.18 Green Acceptance

Date: 27 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Accepted code/test HEAD:
`95204b9278b4637f380bb29d1c53ae047bd67ca4`.

## Scope

This record closes the level-30 Shillien Oracle / Duskseer backend gate.

It covers exact class-42 source inventory, independent DungeonMMO career and
advancement metadata, exact rank schedules, source effects, owned passives,
unified stats, resource migration, support/hostile cast routing, live normal
attack absorption and genuine unpublished Play behavior.

No production publish, `main` merge, production DataStore mutation or
animation work is included.

## Source result

- source class ID: **42**;
- source class: **Shillien Oracle**;
- creative class: **Duskseer**;
- exact source rows through level 30: **92**;
- mapped source rows: **92**;
- source brackets: **26 / 32 / 34** at 20 / 25 / 30;
- creative/source families: **26**;
- source-map gaps: **0**;
- exact level-30 resources: **732 HP / 482 MP / 368 CP**;
- exact Dark Elf Mage MEN bonus: **1.45**.

The source catalogue is pinned to commit
`07f8536384e799f128d44198dd7ab23519660eea`.

## Unique class-42 effects

Twenty-four source IDs already had exact reviewed source-effect data from
earlier Cleric/Oracle work.

The two genuinely new effect definitions were:

### Greater Empower 1059:1

- target buff;
- 400 cast / 900 effect range;
- 1200-second duration;
- MP 5 + 18;
- `MAGICAL_ATTACK x1.55`.

### Vampiric Rage 1268:1

- target buff;
- 400 cast / 900 effect range;
- 1200-second duration;
- MP 6 + 21;
- `ABSORB_DAMAGE_PERCENT +6`;
- stack type `vampRage`.

## Passive and stat boundary

All eight owned Duskseer passive families resolve back to their exact source
ranks and survive the authenticated stat/resource boundary.

The final passive fixture includes exact Anti Magic, Quick Recovery, Boost
Mana, Fast Spell Casting, Fast Mana Recovery, Robe Mastery, Light Armor
Mastery and Weapon Mastery ranks.

Empower and Blood Rite also survive active-source composition. The combined
fixture proves the live stat candidate carries both raised magical attack and
`ABSORB_DAMAGE_PERCENT = 6`.

## Defects found during acceptance

### Vampiric Rage target asymmetry

The first implementation applied normal-attack absorption only on the NPC
executor path.

Pinned C4 attack logic showed that successful non-bow ordinary attacks apply
Vampiric Rage independently of whether the target is a player or NPC. PvP
normal attacks now use the same server-owned absorption path.

### Wrong absorption basis risk

The accepted C4 attack flow computes the heal from source attack damage rather
than the target's remaining HP. The executor now explicitly receives the
calculated normal-attack amount for absorption.

### NPC overkill bookkeeping

The overkill regression exposed a Humanoid reaching negative HP in the test
runtime. That made applied HP loss exceed the target's remaining health.

The NPC damage executor now clamps post-hit health to zero before calculating
applied HP loss. This preserves a separate raw/source damage value for
Vampiric Rage while keeping drain, contribution and other applied-HP
bookkeeping bounded to actual remaining health.

### Live harness shot inventory

The first Play rehearsal stocked only magical `mystic_charge`. Blood Rite's
melee proof requires physical Soulshots, whose no-grade creative item is
`kinetic_charge`. The final harness stocks both exact shot families.

## Regression evidence

Final clean closure:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS;
- focused Duskseer/backend set: **18 / 18 PASS**;
- source effects: **1076 assertions PASS**;
- source-effect catalogue: **124 skills / 476 unique rank pairs**;
- level-30 skill-tree coverage: **16 paths / 1058 rows /
  124 unique source skill IDs**;
- launch source audit: **13 / 18 branches**;
- launch rank schedules mapped: **13 / 18 branches**;
- accepted Play log `FLog::CreatorError` count: **0**.

## Play evidence

A fresh unpublished Dungeon build ran
`C4ShillienOracleLiveHarness` through StudioTestService Play mode.

Observed accepted markers:

- `WIND_SHACKLE_PASS rate=0.2 duration=15`;
- `EMPOWER_PASS duration=1200 matk=40.916`;
- `BLOOD_RITE_PASS absorb=6 healed=2`;
- `MANA_RECHARGE_PASS restored=52`;
- `SHACKLE_PLUS_EMPOWER_PLUS_BLOOD_RITE_PLUS_RECHARGE_PASS`;
- `VERIFIED_PLAY_MODE_PASS`.

The live run crossed real source cutover, real cast bridges, real active-effect
state, real inventory-backed shot consumption, a reviewed Marauder boundary
and the real normal-attack executor. Cleanup disabled casts, rolled back
cutover and cleared the temporary owner state.

## Repository state

Expected local-only residue after acceptance:

- `tools/animation/quadruped/engine/quadruped_blender/__pycache__/`;
- `tools/animation/quadruped/engine/quadruped_core/__pycache__/`.

These pre-existing folders were not modified or cleaned.
