# Human Wizard Exact Source Combat v2.95 — Acceptance

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## Result

**GREEN — exact Human Wizard learning/effect/stat source data resolves through
the authenticated C4 source combat calculator. Live creative casting remains
deliberately uncertified.**

## Accepted candidate

`3eb7e348a93c10e97bd0e2149d5f503b9e752e8e`.

## Source tree

Human Wizard is now included in the exact level-30 source tree rather than
existing only as a category-count inventory.

The tracked Human Wizard source tree contains all **93** rows through level 30
with exact source skill ID, source rank, SP and minimum level.

Whole tracked source coverage now reports:

- **10** source paths;
- **569** learning rows;
- **95** unique source skill IDs.

Focused marker:

`[C4 Skill Tree] EXACT_SOURCE_PASS: 586 assertions, paths=10 rows=569
uniqueSkillIds=95 live=false`.

## Source effects

The Human Wizard source-effect shard is loaded into the shared immutable effect
catalogue.

Human Wizard inherits several source skills from Human Mystic at later ranks.
The loader therefore merges non-overlapping ranks for the same historical
skill ID while rejecting duplicate rank ambiguity.

Whole required source-effect coverage now reports:

- source skills: **95**;
- unique required skill/rank pairs: **362**.

Focused marker:

`[C4 Skill Effects] EXACT_SOURCE_PASS: 579 assertions, skills=95
uniqueRankPairs=362 live=false`.

Reviewed Human Wizard vectors include source Blaze rank 6 and source Sleep rank
6, while companion effects remain source metadata only.

## Exact Human Wizard class template

The creative earned class `Emberweaver` resolves to the Human Wizard source
template rather than falling back to starter Human Mystic stats.

Focused primary-stat acceptance reports:

`[C4 Primary Stats] EXACT_SOURCE_PASS: 147 assertions, 10 templates,
10 growth curves through level 30, live=false`.

## Creative/source link audit

Every tracked source row still resolves to either a reviewed creative
candidate or an explicit gap:

- rows: **569**;
- candidate rows: **528**;
- explicit gap rows: **41**;
- broken/unexamined rows: **0**.

Human Wizard's four companion-dependent source skill IDs remain explicit gaps,
so the audit cannot silently treat a missing companion runtime as implemented.

Focused marker:

`[C4 CREATIVE LINK] AUDIT_PASS paths=10 rows=569 candidate=528
explicitGap=41 broken=0 differentMP=94 liveEffectParity=NOT_CERTIFIED`.

## Authenticated source preview

A genuinely represented Emberweaver identity now participates in the
authenticated source preview.

Whole tracked preview acceptance:

`[C4 Ten-Path Skills] SOURCE_ONLY_PASS: 649 assertions rows=569
candidates=528 gaps=41 live=false`.

This is still source preview evidence. It does not grant or execute missing
runtime abilities.

## Human Wizard direct MDAM proof

The existing disabled source calculator now verifies an actual mapped Wizard
spell family.

Test owner:

- creative class: `Emberweaver`;
- level: 30;
- owned creative skill: `EmberweaverEmberBolt`;
- purchased rank: 6.

Resolved exact source rank:

- source scope: `HumanWizard`;
- historical skill ID: **1220**;
- source rank: **6**;
- source power: **38**;
- magic level: **30**;
- element: **FIRE**.

The result is recalculated independently with the accepted C4 MDAM formula and
the authenticated source attacker/target stat candidates.

Source-combat marker:

`[C4 Source Combat] SOURCE_ONLY_PASS: 43 assertions ... wizard=true ...
live=false`.

The combined focused runner reports:

`[Human Wizard Source Combat] RESULT passed=6 total=6`.

## Test correction during acceptance

The first run produced one assertion failure because the new test looked for a
`SourceClassId` field directly on `C4ResourceMigrationBoundary`. That field
is intentionally not part of the boundary contract.

No production interface was widened for the test.

The assertion now checks actual exported source evidence:

- `ScopeId == "HumanWizard"`;
- exact level-30 source base max mana;
- valid source magical attack;
- valid source magical critical rate.

The rerun passed all six focused suites.

## Fresh static/build acceptance

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS.

Only the pre-existing quadruped animation Python `__pycache__` directories
remain untracked locally. They were not changed or committed.

## Safety boundary

This acceptance does not:

- enable source combat by default;
- make Emberweaver creative projectile constants equal to C4;
- certify exact live MP/cast/reuse costs;
- expose source authority to clients;
- implement companions/servitors;
- publish Roblox places;
- merge to `main`;
- mutate production DataStores;
- alter animation work.

## Next gate

Build a server-owned source cast-cost/timing contract from the exact source
effect rank, then use that contract for a bounded Human Wizard live-source
rehearsal before enabling ordinary Emberweaver client casting.
