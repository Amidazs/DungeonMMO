# DungeonMMO Roadmap v2.90 — C4 Runtime Cutover Rehearsal

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.89](
DungeonMMO_Roadmap_v2_89_C4_Atomic_Combat_Cutover_20260925.md).

## Goal

Rehearse the real v2.89 atomic cutover coordinator against an unpublished
Dungeon runtime and an actual connected Studio player, then prove complete
rollback through the same runtime-owned coordinator.

## Runtime access boundary

The production coordinator remains server-only.

v2.90 adds two unpublished-test-only access layers:

- `C4CombatCutoverRegistry` exposes the actual coordinator only inside
  server code;
- `C4CombatCutoverStudioBridge` creates a `ServerStorage`
  `BindableFunction` only when `RunService:IsStudio()`,
  `PlaceId == 0` and `GameId == 0`.

No RemoteEvent, RemoteFunction or client-callable activation path was added.

The Dungeon runtime owns the bindings. RuntimeServices only composes the
coordinator/executor objects; place-owned binding prevents isolated module
tests from silently replacing the live Dungeon wiring.

## Test isolation fixes

Focused singleton tests now preserve and restore mutable dispatch state rather
than clearing the actual live runtime binding.

The tests that would mutate process-wide cutover/resource singletons are
skipped during a genuine Play session and continue to run in focused Edit-mode
acceptance. This prevents test fixtures from disabling the coordinator being
rehearsed by the real Dungeon runtime.

## Fresh build and focused acceptance

Source/runtime candidate:

`094e51e53d401dcce091fbb6de02cf879e2ab32b`.

Fresh unpublished builds:

- Base: PASS;
- Dungeon: PASS;
- git diff validation: PASS.

Fresh focused Studio:

- Base: **24/24 PASS**;
- Dungeon: **27/27 PASS**;
- source combat calculation: **40 assertions PASS**;
- dispatch adapter: **18 assertions PASS**;
- cutover coordinator: PASS;
- cutover registry: PASS;
- Studio bridge: PASS;
- Dungeon resource cutover: PASS.

## Genuine unpublished Dungeon rehearsal

A real Studio Play server was started from the unpublished Dungeon build with
one connected Studio player.

The rehearsal used the server-only `ServerStorage` bridge and the exact
runtime coordinator composed by `DungeonRuntime.server.luau`.

The explicit rehearsal inputs were:

- participants: the connected Studio player only;
- `SourceUnitsPerStud = 1`;
- `IsNight = false`.

The scale of 1 is **test-only rehearsal input**. It is not a production
Roblox-to-C4 unit decision.

Initial runtime snapshot:

- coordinator disabled;
- resource gate disabled;
- source calculation disabled;
- live executor disabled;
- dispatch disabled;
- active source participants: 0;
- player `C4ResourceCutoverActive = false`;
- current-model MaxHealth approximately 113.4.

After atomic enable:

- coordinator enabled;
- resource gate enabled;
- source calculation enabled;
- live executor enabled;
- dispatch enabled;
- active source participants: 1;
- player `C4ResourceCutoverActive = true`;
- source MaxHealth: 98.

After atomic disable:

- all five source/live gates disabled again;
- active source participants returned to 0;
- player `C4ResourceCutoverActive = false`;
- MaxHealth restored to approximately 113.4.

This proves the actual unpublished Dungeon runtime can enter and leave source
combat through the real coordinator without leaving the player in partial
cutover state.

## Safety boundary

Normal Dungeon bootstrap still performs no automatic source activation.

v2.90 does **not**:

- choose a production source-units-per-stud conversion;
- choose a production source-night mapping;
- publish either Roblox place;
- enable source combat by default;
- expose activation to clients;
- merge to `main`;
- mutate production DataStores;
- edit animation projects.

## Next backend implementation

The next acceptance step is a genuine source-mode player-to-NPC combat
rehearsal while the coordinator is enabled:

1. cut over one connected Studio player;
2. attack one real reviewed Dungeon NPC through the existing combat input;
3. prove `DamageService` dispatch uses the C4 source path;
4. prove real NPC health changes by the source result;
5. prove contribution/threat/quest observers still receive the trusted hit;
6. disable the coordinator;
7. prove subsequent combat returns to the existing model.

That should be completed before considering any default activation or broader
multiplayer rollout.
