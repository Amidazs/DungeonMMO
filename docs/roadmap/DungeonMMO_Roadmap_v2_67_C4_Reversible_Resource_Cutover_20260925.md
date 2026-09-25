# DungeonMMO Roadmap v2.67 — C4 Reversible Resource Cutover

Date: 25 September 2026.  
Branch: `wip/phase-4-test-hud-integration-v1`.  
Previous: [v2.66](
DungeonMMO_Roadmap_v2_66_C4_Resource_Regen_Armor_Sets_20260925.md).

## Goal

Complete the first genuine live HP/MP/CP migration path without enabling it by
default, publishing a place, or making rollback difficult.

The cutover is deliberately an explicit server-only feature gate. Requiring
the service does not change current DungeonMMO gameplay.

## GitHub implementation

### Reversible resource authority

Added
`src/ServerScriptService/Core/Services/C4ResourceCutoverService.luau`.

The service now supports:

- disabled-by-default server-wide gating;
- explicit per-player activation;
- authenticated C4 source HP/MP/CP maxima only;
- HP/MP/CP fraction preservation across source-max changes;
- exact three-second source HP/MP/CP regeneration;
- source-mode ManaService authority with ordinary per-second MP regen disabled;
- CP configuration only while source mode is active;
- playable-player damage consuming CP before HP;
- NPC/non-playable damage bypassing CP;
- source-mode respawn reapplication;
- explicit per-player rollback;
- server-wide rollback;
- no production default activation.

`ProgressionRuntimeState` exposes source max HP/MP only while an active
server-owned cutover record exists. Otherwise the existing DungeonMMO custom
resource formulas remain unchanged.

### Combat lifecycle integration

`CombatService.server.luau` now wires the optional resource layer into the
ordinary combat lifecycle:

- `DamageService` delegates post-mitigation player damage to the cutover
  resolver;
- respawn calls the source-mode reapply path after ordinary resource reset;
- player removal clears private cutover and CP state.

The damage resolver is inert when source mode is not active.

### Mana and CP transition support

`ManaService` can refresh an existing authoritative record while preserving
its current/max fraction and can receive source regeneration amounts without
resetting spend-delay history.

`C4CombatPointRuntime` can reconfigure a certified source maximum while
preserving the prior CP fraction.

No client-supplied maximum, CP value, source item, race, class or skill rank is
accepted by these paths.

## Safety regression

Added
`C4ResourceCutoverServiceTest.server.luau`.

It verifies:

- service default is OFF;
- inactive damage is unchanged;
- no hidden CP record exists while inactive;
- the advertised cutover contract includes rollback, fraction preservation,
  source three-second regen, PvP CP and NPC bypass;
- toggling the server test gate does not automatically opt a character in;
- a non-Player owner cannot activate source resources;
- disabling returns to inert state.

## Genuine unpublished multiplayer acceptance

Added
`scripts/studio/c4_resource_cutover_live.luau`.

The first executions exposed a **test-admission fixture problem**, not a
production resource defect: the default Studio Dungeon session admitted only
one player while the new acceptance required two living players.

The disposable runner was corrected to use the same audited two-client Studio
session injection already used by the project's established multiplayer
Dungeon tests. Production DungeonRuntime was not changed.

Final real two-player unpublished Play verifies:

1. source mode cannot activate before the explicit server gate;
2. a clean Human Fighter has zero prerequisite blockers;
3. enable switches real Humanoid MaxHealth, ManaService max MP and server CP to
   authenticated source values;
4. the existing 50% HP and MP fractions survive activation;
5. 50 playable-player damage is absorbed by CP before HP;
6. 25 NPC-like damage bypasses CP and removes real Humanoid HP;
7. source HP/MP/CP regeneration applies on the three-second C4 tick;
8. per-player rollback restores the pre-cutover custom HP/MP maxima while
   preserving fractions and clears CP;
9. source mode can be enabled again;
10. real character respawn reapplies source HP/MP/CP;
11. global disable rolls everything back.

Final Studio evidence:

- server/client marker:
  `DEFAULT_OFF_FRACTION_CP_REGEN_RESPAWN_ROLLBACK_PASS`;
- task marker:
  `VERIFIED_PLAY_MODE_PASS`.

## Focused regression evidence

Fresh disposable Rojo builds containing the production cutover candidate:

- Base: PASS;
- Dungeon: PASS.

Focused source/resource regressions:

- Base final: **12/12 PASS**;
- Dungeon: **14/14 PASS**.

Dungeon includes:

- ManaServiceTest — 13 assertions;
- C4ResourceCutoverServiceTest — 7 assertions.

Existing source suites remain green, including:

- nine-class authenticated skill preview — 554 assertions;
- resource migration boundary — 47 assertions, prerequisites ready,
  zero blockers;
- creative item source map — 69;
- six-slot/body+legs paperdoll — 14;
- active source state — 17;
- persistent active coverage — 4;
- combat points — 18;
- resource regeneration — 17.

Evidence directory:

`%TEMP%\DungeonMMO_v267_resource_cutover`

Final live acceptance used branch commit
`e2fb63d18fe7c71433c8adacaf7fb35916b85998`.

## Production state

The live cutover is **implemented and acceptance-tested but still OFF by
default**.

This milestone does not:

- publish Roblox places;
- enable source resources for production players;
- change production DataStores;
- merge to `main`;
- claim that every non-resource combat formula is live C4 yet.

`C4ResourceMigrationBoundary.CanApplyLive` remains false as a rollout safety
signal. The tested cutover service instead requires the stricter
`CutoverPrerequisitesReady=true` source boundary plus its own explicit
server gate and per-player enable.

## Next backend implementation

With the resource transport itself proven reversible, the next backend work
should move from **resource readiness** to **live source combat calculation**
without broad default activation.

Recommended order:

1. build a disabled source-combat provider for physical damage, magic damage
   and healing using the already pinned C4 formula modules;
2. feed only authenticated source stats, reviewed source skill power and
   authoritative active effects into it;
3. keep existing Roblox damage/heal executors as the default path;
4. add per-player/per-test source-combat opt-in, just like resource cutover;
5. verify melee, bow, magic and healing against real Humanoid HP with source
   HP/MP active;
6. verify block/parry/dodge/ward/threat layers do not double-apply custom
   percentage bonuses on top of C4 source output;
7. retain immediate rollback and leave production default OFF until those
   combat paths are green.

Permanent scripts and documents remain GitHub-only. Remote Desktop Commander
is reserved for fast-forwarding, disposable builds and unpublished tests.
