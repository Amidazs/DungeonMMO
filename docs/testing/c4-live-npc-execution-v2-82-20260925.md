# C4 Live NPC Execution v2.82 — Acceptance

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## Result

**GREEN — disabled live player-to-NPC executor paths passed fresh tests.**

## Candidate

`a7718fd68be36b86237c8f50ac4bc4c7adfaa2fb`.

## Evidence

- Base Rojo: PASS;
- Dungeon Rojo: PASS;
- git diff validation: PASS;
- Base focused Studio: **18/18 PASS**;
- Dungeon focused Studio: **20/20 PASS**;
- live executor: **17 assertions PASS**;
- NPC source boundary: **13 assertions PASS**;
- source combat calculation: **38 assertions PASS**;
- Dungeon resource cutover: **7 assertions PASS**.

Executor marker:

`[C4 Source Combat Executor] LIVE_EXECUTOR_PASS: 17 assertions default_off=true live_fixture=true npc=true`.

## Accepted NPC live vectors

- normal: 10 source damage -> 10 NPC HP, 0 CP;
- PDAM: 12 source damage -> 12 NPC HP, 0 CP;
- MDAM: 8 source damage -> 8 NPC HP, 0 CP;
- all three generate trusted post-application callback context;
- no NPC source action can run without a configured observer.

## Safety boundary

No current combat entry point routes through these methods in production.
Executor/calculation/resource gates remain separately controlled and default
OFF.

No publish, production persistence, `main` merge or animation edit occurred.
