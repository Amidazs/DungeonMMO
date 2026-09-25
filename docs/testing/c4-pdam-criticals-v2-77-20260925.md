# C4 PDAM Skill Criticals v2.77 — Acceptance

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## Result

**GREEN — fresh Base and Dungeon focused Studio acceptance passed.**

## Candidate

`971dbd3dffc41cfee64b52ee1efc7c2e57f3d704`.

## Evidence

- Base Rojo: PASS;
- Dungeon Rojo: PASS;
- git diff validation: PASS;
- Base focused Studio: **15/15 PASS**;
- Dungeon focused Studio: **17/17 PASS**;
- formula: **51 assertions PASS**;
- source combat: **30 assertions PASS**.

Source-combat output:

`hit=true critical=true variance=true shield=true normal=true vuln=true pvp=true pdamcrit=true magiccrit=true magicfailure=true element=true shots=true pdam=true mdam=true heal=true live=false`.

## Source contract

The accepted implementation preserves the reviewed C4 PDAM critical order:

1. authored skill `baseCritRate`;
2. multiply by 10;
3. multiply by authenticated source STR bonus;
4. strict server-owned 0–999 comparison;
5. calculate ordinary PDAM without normal physical critical-power handling;
6. double final PDAM only when the skill-specific critical succeeds.

The current Power Strike source rank has no positive authored base critical
rate and therefore returns zero skill-critical chance with no unnecessary roll.

## Safety boundary

The source provider is still disabled by default and does not apply live
damage. No publish, production persistence, `main` merge or animation edits
occurred.
