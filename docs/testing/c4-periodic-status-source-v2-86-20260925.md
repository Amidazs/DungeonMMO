# C4 Periodic Status Source v2.86 — Acceptance

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## Result

**GREEN — exact C4 Bleed/Poison source plans and land arithmetic accepted.**

## Candidate

`d490faa2a285c31957ec2c082132320da5688e46`.

## Evidence

- Base Rojo: PASS;
- Dungeon Rojo: PASS;
- git diff validation: PASS;
- Base focused Studio: **21/21 PASS**;
- Dungeon focused Studio: **24/24 PASS**;
- status reference: **14 assertions PASS**;
- source combat calculation: **38 assertions PASS**;
- dispatch adapter: **17 assertions PASS**;
- resource cutover: **7 assertions PASS**.

## Exact accepted source vectors

Bleed rank one:

`13 damage x 4 ticks @ 5 seconds, saveVs=CON, power=100, magicLvl=24`.

Poison rank one:

`8 damage x 10 ticks @ 3 seconds, saveVs=MEN, power=70, magicLvl=7`.

Periodic ticks are nonlethal and cannot reduce HP below one.

The source effect-success calculation now has deterministic coverage for
equal-roll resistance and Spiritshot/Blessed Spiritshot rate changes.

## Safety boundary

Status execution is source-reference only at this milestone. Existing live
creative Bleed/Poison remains unchanged because source dispatch is still OFF
and status families remain activation blockers.
