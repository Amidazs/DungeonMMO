# C4 Live Combat Executor v2.79 — Acceptance

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## Result

**GREEN — executor foundation and fresh focused Studio acceptance passed.**

## Candidate

`d7dd81b32f3580ad9db20cb9cbe7411d7a25c57e`.

## Evidence

- Base Rojo: PASS;
- Dungeon Rojo: PASS;
- git diff validation: PASS;
- Base focused Studio: **17/17 PASS**;
- Dungeon focused Studio: **19/19 PASS**;
- live executor: **10 assertions PASS**;
- source combat: **30 assertions PASS**;
- Dungeon resource cutover: **7 assertions PASS**.

Live-executor marker:

`[C4 Source Combat Executor] LIVE_EXECUTOR_PASS: 10 assertions default_off=true live_fixture=true`.

## Accepted live-executor contracts

The isolated live fixture verifies:

- executor default OFF;
- enable fails before spatial configuration;
- independent source calculation gate is required;
- both participants must be source-resource-cut-over;
- miss causes no HP mutation;
- hit routes three fixture points through CP before HP;
- 10 raw damage becomes 3 CP + 7 HP in the fixture;
- authoritative root transforms are used;
- explicit source-unit conversion is used;
- server night state is used;
- self-target attack is rejected;
- executor gate is reversible.

## Runtime composition probes

Fresh Base composition:

`executor=true resource=false enabled=false`.

Fresh Dungeon composition:

`executor=true resource=true enabled=false`.

The Base resource absence is intentional. Current live C4 resource authority
depends on Dungeon combat/ManaService composition, so the Base executor cannot
accidentally enable.

## Safety boundary

No production C4 live combat was activated.

No guessed elevation scale, production night mapping, current-combat
replacement, client damage authority, Roblox publish, production persistence,
`main` merge or animation edit occurred.
