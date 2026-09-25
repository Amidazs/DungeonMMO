# C4 Reversible Resource Cutover v2.67 — Acceptance

Date: 25 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.

## Production candidate

The tested cutover path consists of:

- disabled C4 resource override provider;
- reversible ManaService authority;
- fraction-preserving CP runtime refresh;
- disabled C4ResourceCutoverService;
- optional DamageService CP routing;
- CombatService lifecycle wiring.

No source mode is enabled merely by loading these modules.

## Build and focused evidence

Disposable Rojo builds:

- Base: PASS;
- Dungeon: PASS.

Focused final Base result:

`[C4 v2.55-v2.67 Focus] RESULT environment=Base passed=12 total=12`

Focused Dungeon result:

`[C4 v2.55-v2.67 Focus] RESULT environment=Dungeon passed=14 total=14`

The Dungeon run includes the new seven-assertion default-off cutover test.

## Genuine two-player Play

The first automated runs timed out waiting for a second living player. The
cause was the disposable test fixture using DungeonRuntime's normal one-player
Studio-session bootstrap.

The test-only runner was repaired to use the established two-player Studio
session injection. No production runtime rule was weakened.

Final child-server marker:

`[C4 Resource Cutover Live] DEFAULT_OFF_FRACTION_CP_REGEN_RESPAWN_ROLLBACK_PASS`

Final parent task marker:

`[C4 Resource Cutover Live] VERIFIED_PLAY_MODE_PASS`

The successful run verifies real server resources across enable, playable
damage, NPC damage, three-second regeneration, rollback and respawn.

## Verified live behaviour

- default source gate is OFF;
- source enable requires explicit server action;
- authenticated source max HP/MP/CP are used;
- HP and MP fractions are preserved into source mode;
- player damage consumes CP before HP;
- NPC damage bypasses CP;
- HP/MP/CP source regeneration runs on the C4 three-second tick;
- rollback restores custom HP/MP maxima and clears CP;
- source mode reapplies after a real player respawn;
- global disable removes source mode.

## Non-claims

The test does not enable source mode in production, publish a place or mutate
production saves.

It certifies the resource cutover mechanism, not the remaining live C4
physical/magic/healing damage formula migration.
