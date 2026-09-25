# C4 Spatial Combat v2.78 — Acceptance

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## Result

**GREEN — fresh Base and Dungeon focused Studio acceptance passed.**

## Candidate

`0b5b724e258d4d6b032c132d148c69d62e1c315e`.

## Evidence

- Base Rojo: PASS;
- Dungeon Rojo: PASS;
- git diff validation: PASS;
- Base focused Studio: **16/16 PASS**;
- Dungeon focused Studio: **18/18 PASS**;
- formula: **51 assertions PASS**;
- spatial reference: **11 assertions PASS**;
- source combat: **30 assertions PASS**;
- Dungeon resource cutover: PASS.

## Accepted source spatial contract

- Front arc: +/-45 degrees;
- Back arc: +/-45 degrees around rear;
- Side: remaining horizontal directions;
- Front +0%;
- Side +5%;
- Back +10%;
- High: +3% only above +50 source units;
- Low: -3% only below -50 source units;
- Night: -10%;
- rain intentionally not active because the reviewed C4 source has no rain
  support wired;
- shield base arc: 120 degrees;
- shield facing is derived from trusted server spatial context;
- ordinary hit resolution consumes the exact spatial multiplier.

## Safety boundary

The source combat provider remains disabled by default and source-only.

Height conversion is not guessed. The provider requires
`HeightDeltaSourceUnits`, which the later live executor must derive from
server-owned Roblox transforms through an explicit conversion rule.

No live source damage, publish, production persistence, `main` merge or
animation edit occurred.
