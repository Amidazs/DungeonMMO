# Human Wizard Direct MDAM Bridge v3.00 — Pending Validation

Date: 26 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## State

**CODE COMPLETE FOR THIS SLICE; VALIDATION DEFERRED UNTIL LOCAL/STUDIO ACCESS
RETURNS.**

No Remote Desktop Commander calls were made for this work.

## GitHub implementation present

The branch now contains:

- `C4SourceCombatExecutor:can_magic_skill_npc(...)`;
- `C4SourceDirectMagicCastService`;
- `C4SourceCastRuntimeComposition`;
- Dungeon runtime disconnect cleanup for cast/shot state;
- direct-MDAM unit coverage;
- executor preflight coverage;
- Base/Dungeon runtime-boundary coverage;
- the Human Wizard focused runner expanded to 11 suites.

## Validation still required

Do not record PASS/green evidence yet.

Required tomorrow:

- `git diff --check`;
- Base Rojo build;
- Dungeon Rojo build;
- Human Wizard source-cast focus;
- direct magic bridge test;
- source executor test;
- runtime startup/log inspection.

## Expected invariants

The pending tests should prove:

- bridge default is OFF;
- only Emberweaver Ember Bolt is accepted;
- target is bound at start;
- target is revalidated before launch MP;
- invalid target cancels without source effect execution;
- early launch does not damage;
- scheduler identity/rank drift fails closed;
- successful scheduler launch reaches the source executor once;
- source calculation owns one-use magical shot consumption;
- Base runtime never creates the Dungeon cast composition;
- player teardown clears cast/scheduler/shot state.

## Acceptance rule

v3.00 becomes green only after fresh local build plus Studio evidence. Until
then, v2.99 remains the latest fully validated point.
