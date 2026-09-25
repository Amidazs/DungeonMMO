# DungeonMMO Roadmap v2.71 — C4 Physical Random Variance

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.70](
DungeonMMO_Roadmap_v2_70_C4_Physical_Critical_Resolution_20260925.md).

## Goal

Integrate the exact Chronicle 4 physical random-damage multiplier into the
disabled source-combat provider without applying source damage live.

## Reviewed C4 source behaviour

Pinned source commit:

`07f8536384e799f128d44198dd7ab23519660eea`.

`L2Character.getRandomDamageMultiplier()`:

- reads `rnd_dam` from the active weapon;
- when unarmed, uses `5 + (int) sqrt(level)`;
- rolls an inclusive integer from `-random` through `+random`;
- returns `1 + roll / 100`.

`Formulas.calcPhysDam` applies that multiplier after weapon-vulnerability
handling and before later race/PvP multipliers.

## Reviewed weapon source data

The current eight reviewed source weapons now carry their pinned C4
`rnd_dam` values:

- Short Sword 1: 10;
- Club 4: 20;
- Apprentice's Wand 6: 20;
- Dagger 10: 5;
- Short Bow 13: 5;
- Trident 291: 10;
- Neti's Bow 1181: 5;
- Neti's Dagger 1182: 5.

These values come from the pinned C4 `weapon.sql`, not current creative
combat modifiers.

## GitHub implementation

`C4SourceItemReference` now stores the exact reviewed `RandomDamage` value
for each current source weapon.

`C4CombatFormulaReference` now provides:

- `unarmed_random_damage_range(level)`;
- `physical_random_damage_multiplier(random_damage, roll)`.

`C4SourceCombatCalculationService` now:

- resolves random range only from the authenticated reviewed source loadout;
- uses the exact unarmed level fallback when no source weapon is equipped;
- owns the inclusive random roll server-side;
- exposes `physical_random_variance(...)` for later normal-attack execution;
- feeds the same source multiplier into PDAM physical-skill calculations.

The caller cannot provide `rnd_dam`, the roll or the multiplier.

## Fresh local acceptance

Commit built and tested:

`a196c45ab548255d1fe8b4a08e556858cb0df9c7`.

Fresh unpublished Rojo builds:

- Base: PASS;
- Dungeon: PASS.

Focused Studio:

- Base: **14/14 PASS**;
- Dungeon: **16/16 PASS**;
- reviewed launch gear: **12 assertions PASS**;
- combat formula: **30 assertions PASS**;
- source combat: **15 assertions PASS**;
- Dungeon Mana Service: **13 assertions PASS**;
- Dungeon Resource Cutover: **7 assertions PASS**.

Source-combat result marker:

`hit=true critical=true variance=true pdam=true mdam=true heal=true live=false`.

## Safety boundary

The source-combat provider remains OFF by default.

This milestone does not:

- apply source damage to live HP or CP;
- consume shots;
- publish;
- touch production saves;
- merge to `main`;
- edit animation work.

## Next backend implementation

Next integrate exact C4 shield handling:

1. source shield-defence success;
2. shield defence power;
3. perfect-shield source roll;
4. physical formula application;
5. strict no-shield/no-source-equipment behaviour.

After shield handling: magic failure/resistance, elemental resolution, shots,
PvP/source-target modifiers, then a separately gated live source executor.
