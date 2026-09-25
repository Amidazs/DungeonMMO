# C4 Live Periodic Status v2.87 — Acceptance

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## Result

**GREEN — source DEBUFF execution, scheduling and dispatch passed fresh Base
and Dungeon focused Studio validation.**

## Candidate

`9a6855ac431e14bc75219f48520316e326b4eb7d`.

## Evidence

- Base Rojo: PASS;
- Dungeon Rojo: PASS;
- git diff validation: PASS;
- Base focused Studio: **21/21 PASS**;
- Dungeon focused Studio: **24/24 PASS**;
- status reference: **14 assertions PASS**;
- source combat: **40 assertions PASS**;
- live executor: **22 assertions PASS**;
- damage-family audit: **25 assertions PASS**, blockers=1;
- dispatch: **19 assertions PASS**;
- Dungeon damage dispatch integration: **2 assertions PASS**;
- resource cutover: **7 assertions PASS**.

## Accepted live vectors

The live executor fixture verifies:

- source Bleed schedules 13 x 4 at five-second intervals;
- a 20-HP NPC receives 13 then 6 and remains at 1 HP;
- periodic callbacks are explicitly nonlethal;
- source Poison schedules 8 x 10 at three-second intervals;
- periodic observer attribution retains source skill and original cast
  sequence;
- resisted DEBUFF schedules no ticks;
- periodic status capability remains server-only.

## Dispatch contract

- Wayfinder Wound is intercepted as source DEBUFF before PDAM.
- Mystic Poison Curse is intercepted as source DEBUFF before MDAM.
- successful casts return zero direct damage, preventing legacy creative
  periodic services from starting;
- legacy StatusPhysical/StatusMagic ticks are suppressed after source cutover;
- source failures remain fail-closed.

Only `RangerArea` remains in the activation blocker list.

## Safety boundary

Source combat remains disabled in normal gameplay. No production cutover,
publish, persistence change, `main` merge or animation edit occurred.
