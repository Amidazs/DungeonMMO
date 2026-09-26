# DungeonMMO Roadmap v3.13 — Elven Oracle / Lifebinder

Date: 27 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous green class milestone: v3.12 Elven Wizard / Moonweaver.

## Status

**GREEN — level-30 Elven Oracle / Lifebinder backend and unpublished Play
acceptance complete.**

Accepted code candidate:

`45fd554aecd58099b3a0fb359deaadf3118471b4`.

Acceptance evidence:
[Elven Oracle / Lifebinder v3.13](
../testing/c4-elven-oracle-lifebinder-v3-13-green-20260927.md).

## Level-30 source coverage

The exact Elven Oracle class-29 source schedule is now represented through
level 30:

- level 20: 26 source rank rows;
- level 25: 32 source rank rows;
- level 30: 33 source rank rows;
- total: **91 / 91 mapped source rank rows**;
- creative families: **25**;
- source tree scope: `ElvenOracle`;
- creative career: `Lifebinder`.

The common level-30 source tree now tracks 13 paths / 830 rows / 114 unique
source skill IDs, including all exact Elven Oracle rows from the pinned C4
`skill_trees.sql`.

## Oracle-specific mechanics

Three Elven Oracle mechanics received explicit source and runtime coverage:

### Mana Recharge

`LifebinderManaRecharge` rank 2 -> Recharge 1013 rank 2:

- MANARECHARGE;
- power 52;
- 11 initial MP + 42 launch MP;
- 400 cast range;
- 900 effect range;
- authoritative target recharge-MP multiplier;
- live ManaService restoration.

### Agility

`LifebinderAgility` -> Agility 1087 rank 1:

- TARGET_ONE support buff;
- 1200-second duration;
- EVASION_RATE +2;
- server-owned active source effect state.

### Wind Shackle

`LifebinderWindShackle` rank 3 -> Wind Shackle 1206 rank 4:

- magical WIT-resisted DEBUFF;
- effect power 80;
- magic level 30;
- PHYSICAL_ATTACK_SPEED x0.8;
- exact 20 percent attack-rate reduction;
- 15-second duration;
- no outgoing-damage reduction;
- server-owned EnemyWeakeningService state.

The attack-rate reduction fraction is rounded to six decimal places so the
exact source 0.20 value remains stable instead of exposing floating-point
0.199999... artifacts.

## Shared support / control catalogue

Lifebinder also routes its reviewed inherited and first-transfer families
through the already accepted source systems:

- Healing Light;
- Battle Mend;
- Group Mend;
- Revive;
- Exorcism / TARGET_UNDEAD;
- Mind Ward;
- Stone Ward;
- Sacred Edge;
- Might;
- Slumber;
- Breath Blessing;
- Concentration;
- Rootbind;
- Windstep;
- passive resistance/casting/mana/armor/weapon families.

## Migration-boundary fix

The live rehearsal exposed a real integration omission: Elven Oracle had an
independent source inventory and creative mapping but was missing from
`C4Level30SkillTreeSource`.

That caused the owned-passive resolver to return
`OriginalSkillTreeUnavailable`, correctly preventing source cutover.

v3.13 adds all exact 91 Elven Oracle source rows to the common tree and adds
Lifebinder to the creative source-link audit. This closes the actual live
cutover prerequisite rather than weakening the migration guard.

## Studio backend acceptance

A fresh unpublished Studio build was used:

`DungeonMMO_ElvenOracle_Acceptance4.rbxlx`.

The final focused backend acceptance ran **25 / 25 suites PASS**, including:

- Oracle source audit;
- Lifebinder foundation;
- Lifebinder exact source effects;
- Lifebinder direct-magic routing;
- Lifebinder support-magic routing;
- level-30 launch coverage;
- creative source-link audit;
- exact source tree;
- source effects / primary stats / owned passives;
- unified stat and migration boundaries;
- status-effect references;
- direct/support cast services;
- active-effect state;
- cast runtime composition;
- source combat calculation/executor;
- ManaService;
- EnemyWeakening;
- death/runtime binding/Dungeon source-cast regressions.

The Lifebinder runner is also now bounded per fixture so a yielding regression
cannot hang Studio automation indefinitely.

## Real unpublished Play rehearsal

The dedicated `C4ElvenOracleLiveHarness` completed **PASS** in real Play
mode.

Observed live evidence:

- `WIND_SHACKLE_PASS rate=0.2 duration=15`;
- `AGILITY_PASS duration=1200 evasion=+2`;
- `MANA_RECHARGE_PASS restored=52`;
- `SHACKLE_PLUS_AGILITY_PLUS_RECHARGE_PASS`;
- `VERIFIED_PLAY_MODE_PASS`;
- final CreatorError count: **0**.

The rehearsal used a real admitted Studio player, authentic level-30
Lifebinder progression state, source cutover, staged direct/support casting,
authoritative ManaService and reviewed Marauder NPC boundary.

## Next class

Continue the original C4 first-transfer sequence with the next uncompleted
career. Keep the same acceptance rule:

`source rows -> creative schedule -> exact effects -> runtime routing ->
focused Studio suites -> unpublished real Play rehearsal -> documentation`.

No `main` merge or Roblox publish was performed.
