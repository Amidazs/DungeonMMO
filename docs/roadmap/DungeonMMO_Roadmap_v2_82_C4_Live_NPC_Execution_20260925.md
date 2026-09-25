# DungeonMMO Roadmap v2.82 — C4 Live NPC Execution

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.81](
DungeonMMO_Roadmap_v2_81_C4_NPC_Source_Boundary_20260925.md).

## Goal

Extend the still-disabled source executor from player targets to real
server-owned NPC Models without changing current Dungeon combat dispatch.

## Implementation

`C4SourceCombatExecutor` now has dedicated player-to-NPC paths for:

- ordinary attacks;
- PDAM skills;
- MDAM skills.

Each NPC action requires:

1. live executor explicitly enabled;
2. source calculation provider enabled;
3. source resource authority enabled;
4. attacking player source-resource cutover active;
5. reviewed NPC boundary from the server Model;
6. explicit source spatial scale/night mapping where spatial input is needed;
7. a trusted NPC damage observer.

NPC damage bypasses Combat Points exactly because the reviewed standard NPC
boundary has no player CP layer.

Damage is applied to the server Humanoid and the executor emits a
DamageService-compatible trusted context only after real positive HP loss.
That context carries the original attacker, target, source kind, source ID,
sequence ID and a `C4SourceResolved` marker.

The observer requirement is deliberately fail-closed. Production composition
does not install the observer yet, so these paths cannot silently bypass the
existing threat, quest and contribution callbacks.

## Fresh acceptance

Candidate:

`a7718fd68be36b86237c8f50ac4bc4c7adfaa2fb`.

Fresh unpublished Rojo:

- Base: PASS;
- Dungeon: PASS;
- git diff validation: PASS.

Focused Studio:

- Base: **18/18 PASS**;
- Dungeon: **20/20 PASS**;
- live executor: **17 assertions PASS**;
- NPC source boundary: **13 assertions PASS**;
- source combat calculation: **38 assertions PASS**;
- Dungeon resource cutover: **7 assertions PASS**.

The executor fixture proves:

- NPC ordinary damage reaches HP with zero CP absorption;
- NPC PDAM reaches HP with zero CP absorption;
- NPC MDAM reaches HP with zero CP absorption;
- all three emit trusted bookkeeping context;
- source sequence IDs survive into callback context;
- existing player-vs-player CP-first paths remain green.

## Safety boundary

The production executor is still OFF.

No NPC damage observer is installed in normal gameplay yet. No existing
DamageService, melee hitbox, projectile or skill dispatch path has been
replaced.

No `main` merge, Roblox publish, production save mutation or animation edit
occurred.

## Next backend implementation

Add a disabled source dispatch adapter at the shared DamageService boundary.

The adapter should let current hitboxes/projectiles continue owning target
contact while replacing only the damage formula/application when explicitly
enabled. Existing threat, contribution and quest callbacks must receive the
same trusted post-damage context.
