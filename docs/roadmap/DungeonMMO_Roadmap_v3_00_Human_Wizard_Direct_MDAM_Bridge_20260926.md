# DungeonMMO Roadmap v3.00 — Human Wizard Direct MDAM Bridge

Date: 26 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.99](
DungeonMMO_Roadmap_v2_99_Human_Wizard_Source_Cast_Scheduler_20260925.md).

## Status

**IMPLEMENTED IN GITHUB — STUDIO/ROJO VALIDATION PENDING.**

Remote Desktop Commander is intentionally unavailable tonight, so no local
checkout, Rojo build or Studio runner was used for this slice.

Implementation candidate before documentation:

`bdeaf5f69dba81fb4dec265e31c3af419ac639a2`.

Do not mark v3.00 green until the pending validation plan is completed.

## Direct MDAM bridge

The first direct Human Wizard damage bridge is now implemented as
`C4SourceDirectMagicCastService`.

The bridge is:

- disabled by default;
- server-only;
- limited to `EmberweaverEmberBolt`;
- bound to one server-reviewed NPC at cast start;
- revalidated against the same NPC at hit time;
- connected to the private source scheduler;
- connected to the existing source combat executor;
- still outside ordinary client spell input.

The target cannot be swapped after cast start because the bridge stores the NPC
privately instead of accepting another target at launch.

## Hit-time validation order

The launch path now follows this order:

1. verify the direct-MDAM bridge itself is enabled;
2. resolve the private target-bound cast receipt;
3. revalidate the same reviewed NPC through the live source executor;
4. if the target is invalid, cancel before launch-time MP is committed;
5. ask the source scheduler to commit the cast;
6. verify scheduler skill/rank identity still matches cast-start identity;
7. call the existing source NPC magic executor;
8. let the source calculation layer consume the charged magical shot exactly
   once while calculating the spell;
9. apply the reviewed source damage through the existing NPC bookkeeping path.

The bridge itself never consumes Spiritshots/Blessed Spiritshots.

## Executor preflight

`C4SourceCombatExecutor` now exposes a read-only
`can_magic_skill_npc(...)` preflight.

It reuses the existing:

- executor gate;
- source calculation gate;
- source resource cutover gate;
- per-player cutover authority;
- reviewed NPC boundary;
- NPC damage observer availability.

It does not calculate damage, consume a shot or mutate HP.

## Dungeon runtime composition

A new `C4SourceCastRuntimeComposition` now builds the Dungeon-only service
graph:

- source shots;
- source cast resources;
- source timing;
- source scheduler;
- direct magic bridge.

`RuntimeServices.new("Dungeon")` now exposes that composition as
`C4SourceCastRuntime`.

`RuntimeServices.new("Base")` deliberately leaves it nil.

The direct-magic bridge remains disabled after composition.

## Disconnect cleanup

Dungeon `PlayerRemoving` now clears private source cast/scheduler/shot state
before removing the player from the C4 combat cutover coordinator.

This prevents an unfinished cast or charged one-use shot record surviving a
departing source-cutover participant.

## Tests authored

The following GitHub-side tests were added or extended:

- direct magic bridge unit coverage;
- read-only executor NPC magic preflight coverage;
- Base runtime assertion that Dungeon source cast composition is absent;
- Human Wizard focused runner expanded to include:
  - direct MDAM bridge;
  - real source combat executor.

The focused Human Wizard runner now contains **11 suites**.

These tests are authored but not executed tonight.

## Pending validation

Tomorrow, after Remote Desktop Commander is available:

1. fast-forward the local worktree;
2. run `git diff --check`;
3. build Base with Rojo;
4. build Dungeon with Rojo;
5. run `c4_human_wizard_source_cast_focus.luau`;
6. confirm all **11/11** focused suites pass;
7. confirm the direct bridge test passes;
8. confirm the real executor preflight test passes;
9. inspect Studio logs for unexpected startup/runtime errors;
10. only then mark v3.00 green.

A real player-to-NPC Emberweaver cast rehearsal is still a later gate. This
slice creates the server handoff required for that rehearsal.

## Safety boundary

v3.00 does **not**:

- enable direct magic at runtime;
- route ordinary client spell input through this bridge;
- publish Roblox places;
- merge to `main`;
- mutate production DataStores;
- implement Wizard status/AOE/recovery families;
- implement companion/servitor rows;
- use Remote Desktop Commander tonight.

## Next after validation

If v3.00 passes tomorrow, the next bounded step is to expose this bridge only
to an unpublished Studio rehearsal with an authenticated Emberweaver test
character and one reviewed NPC.

That rehearsal should prove the complete sequence:

`cast start -> initial MP -> source timing -> hit-time target validation ->
launch MP -> one magical shot consumed -> C4 MDAM -> NPC HP/bookkeeping ->
reuse gate`.
