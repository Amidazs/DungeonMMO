# C4 Physical Random Variance v2.71 — Acceptance

Date: 25 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.

## Result

**GREEN — fresh Base and Dungeon focused Studio acceptance passed.**

## Candidate

`a196c45ab548255d1fe8b4a08e556858cb0df9c7`.

## Verified source contracts

The reviewed C4 source uses:

`1 + Rnd.get(-random_damage, random_damage) / 100`.

For weapon attacks, `random_damage` is the active weapon's pinned
`rnd_dam`. Unarmed attacks use:

`5 + floor(sqrt(level))`.

Current reviewed source weapon ranges are pinned for all eight mapped source
weapons: 10/20/20/5/5/10/5/5.

## Fresh build evidence

- Base Rojo build: PASS;
- Dungeon Rojo build: PASS.

## Fresh Studio evidence

Base focused result:

`environment=Base passed=14 total=14`

Dungeon focused result:

`environment=Dungeon passed=16 total=16`

Relevant exact outputs:

- `[C4 Launch Core Gear] SOURCE_ONLY_PASS: 12 assertions`;
- `[C4 Combat Formula] SOURCE_FORMULA_PASS: 30 assertions, live=false`;
- `[C4 Source Combat] SOURCE_ONLY_PASS: 15 assertions hit=true critical=true variance=true pdam=true mdam=true heal=true live=false`;
- Dungeon Mana Service: 13 assertions PASS;
- Dungeon Resource Cutover: 7 assertions PASS.

No focused failure was reported.

## Non-live boundary

The provider gate remains OFF by default.

Random variance is server-owned source calculation only. No live HP/CP damage,
publish, production persistence or `main` merge occurred.
