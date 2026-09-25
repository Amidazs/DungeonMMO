# Human Wizard Targeted Cast Batch v3.01 — Pending Validation

Date: 26 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## State

**BACKEND BATCH STAGED; LOCAL BUILD AND STUDIO ACCEPTANCE DEFERRED UNTIL REMOTE
DESKTOP ACCESS RETURNS.**

No Remote Desktop Commander calls were made while this batch was implemented.

## Code candidate

`a8d66d1dda51816a52f64a7eacc33aa44aa5f598`.

This is an implementation candidate, not a green acceptance commit.

## New staged coverage

The pending batch now covers:

- three reviewed single-target direct MDAM spells;
- one reviewed single-target periodic poison spell;
- neutral non-elemental C4 magic;
- exact source cast/effect range phases;
- source-range server preflight;
- cross-family scheduler overlap;
- Dungeon cast runtime composition and teardown.

## Prepared test surfaces

### Focused cast runner

`scripts/studio/c4_human_wizard_source_cast_focus.luau`

Expected fixture count: **14**.

### Big backend runner

`scripts/studio/c4_human_wizard_big_backend_focus.luau`

Expected fixture count: **32**.

The big runner includes Core and Combat tests and places each temporary
ModuleScript next to its original source so relative paths are preserved.

## Important expected checks

Tomorrow's run should confirm:

- Ember Bolt maps to source 1220 rank 6;
- Flame Burst maps to 1172 rank 6 and remains non-elemental/neutral;
- Focused Bolt maps to 1274 rank 3 and remains non-elemental/neutral;
- Venom Hex maps to Poison 1168 rank 3;
- exact split MP is preserved for all four staged spells;
- cast/effect ranges survive contract -> timing -> scheduler -> bridge;
- out-of-range preflight makes no HP/status mutation;
- hit-time range failure occurs before launch MP and shot consumption;
- direct/periodic casts cannot overlap on one owner;
- source shots are still consumed only by source effect calculation;
- source damage continues through contribution, quest and threat bookkeeping;
- both new bridges remain disabled by default;
- Base runtime never composes the Dungeon-only source cast runtime.

## Acceptance requirement

Do not convert this file to green evidence from GitHub inspection alone.

Required fresh evidence:

- `git diff --check`;
- Base Rojo build;
- 32/32 big backend runner;
- 14/14 cast focus;
- Dungeon Rojo build;
- clean relevant Studio/runtime logs.

Any failure should be fixed and the complete affected runner repeated before a
live spell rehearsal.

## Latest validated baseline

v2.99 remains the latest fully accepted baseline tonight.
