# DungeonMMO Roadmap v2.92 — C4 Multiplayer Cutover Hardening

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.91](
DungeonMMO_Roadmap_v2_91_C4_Live_Player_NPC_Rehearsal_20260925.md).

## Goal

Close the last cutover-hardening gap before returning to the wider MMORPG
backend roadmap: make source dispatch explicitly participant-scoped, support
safe removal of one participant while others remain active, and guarantee that
the final participant leaving cannot strand any global C4 source gate.

## Why this pass was required

v2.91 proved the real existing player attack path can move through source
combat and roll back cleanly for one player.

The multiplayer rehearsal adds a different risk: the global dispatch gate is
server-wide, while resource cutover is intentionally per-player. A global
dispatch gate must therefore never cause a player who was not selected for the
rehearsal to start using source damage.

The coordinator also needs to remain internally consistent when a selected
player disconnects. Removing one player must not disable source mode for other
selected participants, while removing the final participant must not leave
source calculation, executor or dispatch gates active with nobody opted in.

## Implemented hardening

### Explicit dispatch participant scope

`C4CombatDispatchAdapter` now requires a server-owned participant provider
before source dispatch can enable.

The Dungeon runtime binds that provider to
`C4ResourceCutoverService.is_active(attacker)`.

Result:

- selected cutover participants may route through source dispatch;
- unselected players continue through the existing combat model;
- a missing or failing participant authority fails closed;
- binding no provider disables source dispatch rather than widening access.

The capability snapshot now reports:

- `ParticipantProviderBound`;
- `ExplicitParticipantScope`.

### Safe participant removal

`C4CombatCutoverCoordinator` now exposes
`remove_player(player)`.

Behaviour:

- removing a selected player clears that participant from source resource
  authority;
- remaining selected participants stay active;
- removing the last selected participant triggers full reverse-order rollback;
- repeated removal of an inactive player returns a stable rejection and makes
  no additional mutation.

The coordinator capability now reports
`ParticipantRemovalSupported=true`.

### Dungeon disconnect integration

The real Dungeon `PlayerRemoving` path now informs the active cutover
coordinator before normal profile/session teardown.

This makes disconnect cleanup part of the real server lifecycle rather than a
test-only helper.

### Studio rehearsal bridge

The unpublished server-only cutover bridge now supports one bounded
`remove` action for a single connected participant.

It remains:

- ServerStorage-only;
- Studio-only;
- unavailable to clients;
- unavailable in published servers.

## Regression coverage added

`C4CombatDispatchAdapterTest` now proves:

- dispatch cannot enable without an explicit participant authority;
- a selected player reaches source dispatch;
- an unselected player remains on the existing combat path;
- capability metadata exposes participant scoping.

`C4CombatCutoverCoordinatorTest` now proves:

- one of two active participants can be removed without shutting down the
  remaining participant;
- removing the last participant shuts down all global source gates;
- repeated removal fails without mutation;
- the coordinator can activate again after cleanup.

`C4CombatCutoverStudioBridgeTest` now proves invalid participant-removal
requests fail closed.

## Static/build acceptance

Implementation candidate:

`c85ab93d8595d3845d53862fc016e57ef6cb7776`.

Fresh local verification after fast-forwarding the GitHub branch:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS.

The only pre-existing local untracked files were Python `__pycache__`
directories under the quadruped animation tools. They were not edited or
committed.

## Remaining live acceptance

One bounded unpublished multiplayer rehearsal remains:

1. start two connected Dungeon players;
2. diagnose both source boundaries;
3. atomically enable both participants;
4. prove both have source resource authority;
5. make both damage the same reviewed NPC through existing client input;
6. verify contribution and threat are tracked separately by player;
7. verify the higher threat participant is the active aggro target;
8. remove or disconnect one selected participant;
9. verify the remaining participant still uses source combat;
10. verify the removed/unselected participant cannot use source dispatch;
11. remove the final participant and prove all source gates shut down;
12. re-enable both, then use coordinator-wide disable and prove both return to
    the existing model.

This should be the final cutover-hardening rehearsal. It should not become
another repeated single-player combat test.

## Safety boundary

v2.92 does **not**:

- enable source combat by default;
- choose production Roblox-to-C4 elevation conversion;
- choose production source-night mapping;
- expose cutover authority to clients;
- publish Roblox places;
- merge to `main`;
- mutate production DataStores;
- change animation assets.

## After the live multiplayer gate

Resume the wider MMORPG backend roadmap rather than extending cutover work:

- progression, advancement quests and level-30 launch content;
- gathering and crafting professions with one gathering plus one crafting
  profession per character;
- recipes, blueprints, trading and economy dependencies;
- guild systems and guild halls;
- raids and weekly world-boss progression;
- PvP and castle-capture systems;
- remaining dungeon/content/backend integration.
