# C4 Source Combat Calculation Provider v2.68 — Acceptance

Date: 25 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.

## Commit tested

`0e859222eb47aba6e8ffdf942fda4c26a208e4bd`.

## Build evidence

- Base Rojo build: PASS;
- Dungeon Rojo build: PASS.

## Focused results

Base:

`[C4 v2.55-v2.68 Focus] RESULT environment=Base passed=13 total=13`

Dungeon:

`[C4 v2.55-v2.68 Focus] RESULT environment=Dungeon passed=15 total=15`

New provider:

`[C4 Source Combat] SOURCE_ONLY_PASS: 9 assertions
pdam=true mdam=true heal=true live=false`

## Verified source vectors

The provider resolves source identities from actually owned creative ranks and
then calculates from authenticated source stats.

Covered source examples:

- Power Strike 3 rank 1 — PDAM power 25;
- Wind Strike 1177 rank 1 — MDAM power 12;
- Self Heal 1216 rank 1 — direct heal effect power 42.

Provider results match direct `C4CombatFormulaReference` calculations.

## Deliberate non-live boundary

The provider does not modify real HP or MP and remains disabled by default.

Shots, critical resolution, random weapon range, shield, magic failure,
elemental and PvP multipliers are not yet claimed live or complete.

No place was published and no production save was changed.
