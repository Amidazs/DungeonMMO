# DungeonMMO Roadmap v2.95 — Human Wizard Exact Source Combat

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.94](
DungeonMMO_Roadmap_v2_94_Human_Wizard_Foundation_20260925.md).

## Status

**GREEN — Human Wizard exact source data now reaches the disabled C4 combat
calculator without claiming live-client effect parity.**

Acceptance:
[Human Wizard exact source combat v2.95](
../testing/c4-human-wizard-source-combat-v2-95-20260925.md).

## Delivered

The creative `Emberweaver` identity now participates in the same pinned C4
source stack already used by the accepted starter/Fighter-transfer paths:

- exact Human Wizard level-20/25/28/30 learning rows;
- exact source skill IDs, source ranks, SP and learning levels;
- exact source effect data for the required level-30 ranks;
- exact Human Wizard class/stat template;
- authenticated source preview for an actually earned Emberweaver;
- creative-to-source rank mapping for the 24 non-companion families;
- explicit fail-closed gaps for all four companion-dependent source families.

The shared effect loader now safely merges later Human Wizard ranks of source
skills inherited from Human Mystic instead of duplicating one historical skill
definition.

## Exact source coverage

Tracked C4 launch source coverage is now:

- paths: **10**;
- learning rows: **569**;
- unique source skill IDs: **95**;
- unique required source skill/rank effect pairs: **362**;
- creative candidate rows: **528**;
- explicit source gaps: **41**;
- broken/unexamined rows: **0**.

Human Wizard remains:

- source rows: **93**;
- non-companion trainer-mapped rows: **74**;
- companion-dependent rows deliberately unmapped: **19**.

The 19 unmapped rows are still the source Mana Companion, Combat Companion,
Servitor Heal and Servitor Recharge families. They must not become inert or
client-owned placeholder abilities.

## Exact Human Wizard source class

`C4PrimaryStatReference` now resolves the earned `Emberweaver` to source
scope `HumanWizard`, source class ID 11 and its independently verified level
growth.

The focused stat regression now covers ten source templates and ten growth
curves through level 30.

## Source-only direct magic proof

The existing disabled `C4SourceCombatCalculationService` now has a focused
Human Wizard proof.

A level-30 authenticated Emberweaver owning
`EmberweaverEmberBolt` rank 6 resolves to:

- source skill ID **1220**;
- source rank **6**;
- source power **38**;
- source magic level **30**;
- source element **FIRE**.

The calculated result is compared against the accepted source MDAM formula
using the Human Wizard source stat candidate and the target's source magical
defence/vulnerability state.

The result remains explicitly:

- `SourceOnly=true`;
- `LiveApplied=false`.

This proves the source identity/formula chain without pretending the current
creative Roblox projectile cost, cooldown or presentation is exact C4 runtime
behaviour.

## Fresh verification

Accepted candidate:

`3eb7e348a93c10e97bd0e2149d5f503b9e752e8e`.

Fresh checks:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS;
- source combat calculation: **43 assertions PASS**;
- exact skill tree: **586 assertions PASS**;
- exact skill effects: **579 assertions PASS**;
- exact primary stats: **147 assertions PASS**;
- creative source link audit: **PASS**, 569 rows / 528 candidates /
  41 explicit gaps / 0 broken;
- authenticated ten-path preview: **649 assertions PASS**;
- Human Wizard source-combat focused runner: **6/6 PASS**.

The first focused rerun failed only because the new test asserted a
non-exported `SourceClassId` field on the resource boundary. Production
source data was not changed to satisfy the test. The assertion was corrected
to use the boundary's real exported `ScopeId`, source max mana and stat
candidate, then the complete focused runner passed.

## Boundary still intentionally closed

v2.95 does **not** claim:

- live client casting of Emberweaver spells;
- exact live source MP consumption;
- exact source cast/reuse timing in the existing creative combat executor;
- source-aligned control/debuff application for every Wizard family;
- source passive/equipment parity for all 74 mapped rows;
- any companion/servitor implementation;
- first-transfer release certification.

The old creative `SkillDefinitions` values are not automatically promoted
to C4 parity merely because the exact source effect data now exists.

## Next implementation

Before exposing Human Wizard direct spells as live casts, add one
server-authoritative source cast contract that derives the real source action
cost/timing fields from the authenticated source rank.

The next slice should:

1. resolve `mpInitialConsume`, `mpConsume`, source hit/cast timing and reuse
   metadata from the exact source effect;
2. keep this authority server-only and rank/identity bound;
3. prove an Emberweaver cannot request another class/rank's source cost;
4. wire the contract into a disabled/live-rehearsal path before changing
   ordinary client casting;
5. then move direct MDAM spells into live source execution;
6. continue control/status/recovery/passive families;
7. build server-owned companion authority last for the remaining 19 rows.

After Human Wizard reaches the agreed level-30 launch scope, continue Human
Cleric, Elven Wizard/Oracle, then remaining Dark Elf, Orc and Dwarf paths.

No `main` merge, Roblox publish, production DataStore mutation or animation
work.
