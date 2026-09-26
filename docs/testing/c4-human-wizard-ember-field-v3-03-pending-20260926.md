# Human Wizard Ember Field v3.03 — Pending Studio Acceptance

Date: 26 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Code candidate: `19173565960c2137a2f95e8699dea83e7e3bd6a3`.

## Implemented

`EmberweaverEmberField` rank 3 now routes through source Flame Strike
1181 rank 3 with:

- FIRE MDAM power 19;
- magic level 30;
- 500 cast range;
- 1000 effect range;
- 200 source-unit TARGET_AREA radius;
- 8 + 32 split MP;
- existing source cast/reuse timing.

The source calculator captures one magical shot for the whole target list,
matching the pinned C4 MDAM target loop. Each target retains independent magic
critical/failure/element resolution.

## Server area authority

The live executor:

- always retains the reviewed selected NPC;
- discovers secondary NPCs inside source radius around the caster;
- accepts only reviewed living NPC boundaries;
- requires secondaries to match the primary `DungeonEncounterId`;
- applies each result through existing source NPC damage bookkeeping.

No client-supplied area target list or damage value is accepted.

## Completed local checks

- GitHub fast-forward: PASS.
- `git diff --check`: PASS.
- Base Rojo build: PASS.
- Dungeon Rojo build: PASS.
- Direct targeted-magic constructor fakes updated.
- Source calculation tests extended.
- Live executor regression extended with primary, same-encounter secondary and
  nearby different-encounter NPC fixtures.
- No `main` merge or publish.
- Existing quadruped `__pycache__` folders left untouched.

## Studio checks still required

Before marking v3.03 green:

1. run `c4_human_wizard_source_cast_focus.luau`;
2. run `c4_human_wizard_big_backend_focus.luau`;
3. confirm source-combat, executor, staged integration and targeted bridge
   suites pass;
4. run an unpublished Dungeon Ember Field cast against at least two reviewed
   NPCs in the same encounter;
5. place or identify a nearby NPC from another encounter and confirm it is not
   damaged;
6. verify one Spiritshot/Blessed Spiritshot is consumed for the cast, not one
   per target;
7. verify threat/contribution callbacks occur independently for damaged NPCs;
8. verify the final log has no project CreatorErrors.

Until those checks pass, v3.01 remains the latest fully accepted Wizard batch;
v3.02 Frost Lance and v3.03 Ember Field are implemented but Studio-pending.
