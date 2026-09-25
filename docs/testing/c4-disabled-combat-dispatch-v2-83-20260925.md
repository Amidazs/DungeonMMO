# C4 Disabled Combat Dispatch v2.83 — Acceptance

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## Result

**GREEN — disabled source dispatch and DamageService integration passed.**

## Candidate

`c424a2c46ebb6e2550c57cf4398725c39669774e`.

## Evidence

- Base Rojo: PASS;
- Dungeon Rojo: PASS;
- git diff validation: PASS;
- Base focused Studio: **19/19 PASS**;
- Dungeon focused Studio: **22/22 PASS**;
- dispatch adapter: **12 assertions PASS**;
- DamageService source-hook integration: **2 assertions PASS**;
- live executor: **17 assertions PASS**;
- NPC boundary: **13 assertions PASS**;
- source calculation: **38 assertions PASS**;
- resource cutover: **7 assertions PASS**.

Dispatch marker:

`[C4 Combat Dispatch] DISPATCH_PASS: 12 assertions default_off=true fail_closed=true`.

DamageService marker:

`[C4 Damage Dispatch Integration] PASS: 2 assertions handled=true fallback=true`.

## Accepted contracts

- disabled source dispatch leaves current DamageService formulas unchanged;
- dispatch cannot enable without a bound, enabled live executor;
- server skill ranks decide PDAM/MDAM routing;
- normal melee and unranked ranged physical use source normal attack;
- enabled unsupported source damage fails closed rather than using legacy
  damage;
- handled source damage bypasses the legacy DamageService formula;
- unhandled adapter results preserve the legacy DamageService path;
- the source executor receives the same trusted contribution/quest/threat
  observer used by current DamageService.

## Safety boundary

No production source gate is enabled.

No spatial conversion, production night mapping, publish, production
persistence mutation, `main` merge or animation edit occurred.
