# C4 Magic Failure and Critical v2.73 — Acceptance

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## Result

**GREEN — fresh Base and Dungeon focused Studio acceptance passed.**

## Candidate

`6f5fe20ac26d3c01b6c5938bf87127228b53da59`.

## Verified source contracts

The pinned C4 source establishes:

- `MagicFailures=false` by default;
- exact magic-success threshold
  `round(pow(1.3, levelDifference) * 100)`;
- strict `Rnd.get(10000) > threshold` success;
- independent second roll for the optional half-damage branch;
- full resistance to one damage otherwise;
- current-scope template M.Crit base 8;
- maximum M.Crit 300/1000;
- strict `mRate > Rnd.get(1000)` critical comparison;
- successful magic critical damage ×4.

## Fresh local verification

Rojo:

- Base: PASS;
- Dungeon: PASS.

Git diff validation:

- PASS.

## Fresh Studio evidence

Base:

`[C4 v2.55-v2.73 Focus] RESULT environment=Base passed=14 total=14`

Dungeon:

`[C4 v2.55-v2.73 Focus] RESULT environment=Dungeon passed=16 total=16`

Relevant exact outputs:

- `[C4 Combat Formula] SOURCE_FORMULA_PASS: 46 assertions, live=false`;
- `[C4 Source Combat] SOURCE_ONLY_PASS: 23 assertions hit=true critical=true variance=true shield=true magiccrit=true magicfailure=true pdam=true mdam=true heal=true live=false`;
- Dungeon `[C4 Resource Cutover] SOURCE_ONLY_PASS: 7 assertions default_off=true reversible=true`.

No focused failure was reported.

## Non-live boundary

The provider remains disabled by default. These are server-owned source
calculations only; no HP/CP mutation, publish, production persistence,
`main` merge or animation work occurred.
