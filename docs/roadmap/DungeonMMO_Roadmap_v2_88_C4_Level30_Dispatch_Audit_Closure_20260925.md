# DungeonMMO Roadmap v2.88 — C4 Level-30 Dispatch Audit Closure

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.87](
DungeonMMO_Roadmap_v2_87_C4_Live_Periodic_Status_20260925.md).

## Goal

Resolve the final player-to-NPC dispatch blocker without inventing a source
skill that does not exist in the current C4 level-30 launch scope.

## Ranger area audit

The remaining creative damage family was `RangerArea`, produced by the old
legacy specialist skill `Volley`.

The current project already marks the `Ranger` class:

- `FreshCreationAllowed=false`;
- `LegacySpecialistClass=true`.

The intended launch class structure now follows Chronicle 4 rather than that
older generic Ranger path.

Pinned C4 source review found the direct source analogue for area bow damage:

- source skill 24, Burst Shot;
- `TARGET_AREA`;
- radius 150 source units;
- bow-only PDAM;
- first source rank has `magicLvl=44`.

That source skill is therefore outside the agreed level-30 initial game scope.
Mapping the level-1 creative Volley to Burst Shot would manufacture a
progression path that C4 does not have.

## Implementation decision

`RangerArea` is now classified as:

`LegacyC4ScopeExcluded`.

It is not silently translated into Burst Shot and it is not allowed to fall
back to the creative area-damage formula after source dispatch is enabled.

If a retained legacy Ranger attempts that old area attack while C4 source
dispatch is active, it fails closed with:

`C4LegacyRangerAreaOutsideLevel30Scope`.

This preserves the legacy implementation for rollback/testing while keeping
the level-30 C4 cutover source-clean.

## Dispatch audit result

All player-to-NPC damage families in the intended level-30 C4 launch scope now
have a reviewed disposition:

- normal melee -> source normal attack;
- ordinary ranged physical -> source normal or source PDAM by owned rank;
- physical skill -> source PDAM;
- magical skill -> source MDAM or source DEBUFF;
- creative basic magic contact -> source normal attack;
- Bleed/Poison -> source DEBUFF plus source periodic scheduler;
- old periodic callbacks -> suppressed after cutover;
- legacy RangerArea -> explicitly outside current C4 source scope.

The activation blocker list is now empty.

This means the **audit is activation-ready**. It does not mean gameplay has
been switched on.

## Fresh acceptance

Candidate:

`703f8fad090c7d92a5e9191e3fa572d19b4b60eb`.

Fresh unpublished Rojo:

- Base: PASS;
- Dungeon: PASS;
- git diff validation: PASS.

Focused Studio:

- Base: **21/21 PASS**;
- Dungeon: **24/24 PASS**;
- damage-family audit: **24 assertions PASS**,
  `blockers=0 activation_ready=true`;
- dispatch adapter: **18 assertions PASS**;
- Dungeon integration: **2 assertions PASS**;
- source resource cutover: **7 assertions PASS**.

## Safety boundary

All source/live gates remain OFF by default.

No player can activate source mode through a RemoteEvent and no production
place has been switched.

No main merge, Roblox publish, production persistence or animation project
mutation is included.

## Next backend implementation

Add one server-only cutover coordinator that changes the independent source
gates as a single reversible transaction.

The coordinator must:

1. start OFF;
2. validate dispatch audit readiness;
3. configure explicit spatial rules;
4. enable resource cutover, source calculation, live executor and dispatch in
   a safe order;
5. roll back already-changed gates if any later step fails;
6. disable in reverse order;
7. expose no client authority;
8. support isolated Studio cutover/revert acceptance before any normal gameplay
   activation.
