# Human Wizard Frost Lance v3.02 — Pending Studio Acceptance

Date: 26 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Candidate: `484363b3ffec2d911314201380fe5408ad154d40`.

## Implemented

The Human Wizard targeted cast bridge now includes
`EmberweaverFrostLance` rank 2 -> source Ice Bolt 1184 rank 6.

Implemented source behavior:

- direct WATER MDAM power 16;
- WIT-resisted effect power 60;
- 0.7 movement multiplier / 30 percent slow;
- 120-second source duration;
- exact 600 cast / 1100 effect range;
- one-use magical shot ownership shared by damage and effect-success roll;
- server-only NPC movement-slow application after surviving direct damage.

## Completed local checks

- GitHub fast-forward: PASS.
- Base Rojo build: PASS.
- Dungeon Rojo build: PASS.
- DirectMagic constructor call-site audit: PASS; all test fakes updated.
- No `main` merge or publish.
- Pre-existing quadruped `__pycache__` folders were left untouched.

## Studio checks still required

Before marking v3.02 green:

1. run `c4_human_wizard_source_cast_focus.luau`;
2. run `c4_human_wizard_big_backend_focus.luau`;
3. confirm the extended status, source-combat, direct-cast, NPC-boundary and
   resource-boundary suites pass;
4. run an unpublished Dungeon Frost Lance rehearsal against a reviewed NPC;
5. verify direct damage is applied once;
6. verify at most one Spiritshot/Blessed Spiritshot is consumed;
7. when the WIT roll lands, verify movement uses the 0.7 multiplier;
8. verify contribution/threat bookkeeping still updates;
9. verify no project CreatorErrors remain in the final log.

Until those checks pass, v3.01 remains the latest fully green Wizard batch.
