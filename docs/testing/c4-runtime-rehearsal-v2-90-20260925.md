# C4 Runtime Cutover Rehearsal v2.90 — Acceptance

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## Result

**GREEN — real unpublished Dungeon cutover and rollback passed.**

## Candidate

`094e51e53d401dcce091fbb6de02cf879e2ab32b`.

## Fresh static/build evidence

- Base Rojo: PASS;
- Dungeon Rojo: PASS;
- git diff validation: PASS.

## Focused Studio evidence

Fresh final-candidate runs:

- Base: `environment=Base passed=24 total=24`;
- Dungeon: `environment=Dungeon passed=27 total=27`.

Relevant markers included:

- `[C4 Source Combat] SOURCE_ONLY_PASS: 40 assertions`;
- `[C4 Combat Dispatch] DISPATCH_PASS: 18 assertions`;
- `[C4 Combat Cutover] CUTOVER_PASS`;
- `[C4 Combat Cutover Registry] REGISTRY_PASS`;
- `[C4 Cutover Studio Bridge] STUDIO_BRIDGE_PASS`;
- `[C4 Resource Cutover] SOURCE_ONLY_PASS`.

## Real Play rehearsal evidence

The unpublished Dungeon was run in Studio Play with one real connected Studio
player.

Initial bridge snapshot:

`Enabled=false ActivePlayerCount=0 ExecutorGate=false ResourceGate=false DispatchGate=false CombatCalculationGate=false`

Player evidence:

- `C4ResourceCutoverActive=false`;
- MaxHealth approximately `113.4`.

The server-only bridge then invoked atomic enable with a test-only explicit
configuration:

- `SourceUnitsPerStud=1`;
- `IsNight=false`;
- participant list containing only the connected server player.

Enabled snapshot:

`Enabled=true ActivePlayerCount=1 ExecutorGate=true ResourceGate=true DispatchGate=true CombatCalculationGate=true`

Player evidence:

- `C4ResourceCutoverActive=true`;
- source MaxHealth `98`.

The same runtime bridge then invoked disable.

Rollback snapshot:

`Enabled=false ActivePlayerCount=0 ExecutorGate=false ResourceGate=false DispatchGate=false CombatCalculationGate=false`

Player evidence after rollback:

- `C4ResourceCutoverActive=false`;
- MaxHealth restored to approximately `113.4`.

## Interpretation

The exact coordinator owned by the real Dungeon runtime completed both the
forward transaction and reverse transaction successfully.

The rehearsal unit scale is not a production mapping. It exists only to prove
that explicit trusted spatial configuration passes through the atomic runtime
path.

## Safety boundary

No default source activation, production source spatial mapping, client
activation remote, Roblox publish, production persistence, `main` merge or
animation edit occurred.
