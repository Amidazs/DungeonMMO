# Human Wizard Slumber Hex v3.05 — Pending Studio Acceptance

Date: 26 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## Implemented

`EmberweaverSlumberHex` rank 6 now maps to source Sleep 1069 rank 6 with:

- magical SLEEP DEBUFF;
- WIT resistance;
- effect power 80;
- magic level 30;
- 600 cast range;
- 1100 effect range;
- 30-second duration;
- 6 + 21 split MP;
- 2500 ms authored hit time;
- 6000 ms authored reuse.

The current level-30 Wizard timing candidate resolves those authored timing
values to a 2.5-second cast and 4.5-second reuse.

## Live control behavior

A landed source Sleep now:

- stops supported NPC movement/chasing;
- blocks new attacks;
- interrupts supported attack windups;
- preserves the 30-second source duration;
- wakes before ordinary direct source damage is applied.

The generic NPC Sleep service owns the status and expiry. Training Marauders
and the Marauder Captain currently consume that authority.

The implementation deliberately keeps periodic Bleed/Poison ticks outside the
direct-damage wake path, matching the pinned source behavior for attackable
NPCs.

## Completed local checks

- GitHub fast-forward: PASS.
- DirectMagic constructor/fake audit: PASS.
- `git diff --check`: PASS.
- Base Rojo build: PASS.
- Dungeon Rojo build: PASS.
- Source status plan regression extended.
- Source combat calculation regression extended.
- Live source executor regression extended.
- Targeted bridge regression extended.
- Cross-service staged integration regression extended.
- No `main` merge or publish.
- Existing quadruped `__pycache__` folders left untouched.

## Studio checks still required

Before marking v3.05 green:

1. run `c4_human_wizard_source_cast_focus.luau`;
2. run `c4_human_wizard_big_backend_focus.luau`;
3. confirm status, source-combat, executor, targeted bridge and staged
   integration suites pass;
4. run an unpublished Slumber Hex cast against a reviewed Dungeon NPC;
5. verify one Spiritshot/Blessed Spiritshot is consumed;
6. verify the WIT land roll and 30-second source duration;
7. verify an in-progress attack is cancelled;
8. verify the NPC does not move or start attacks while sleeping;
9. apply ordinary direct damage and verify Sleep clears before HP reduction;
10. where practical, verify reviewed NPC Bleed/Poison ticks do not wake Sleep;
11. verify the final log has no project CreatorErrors.

v3.01 remains the latest fully accepted Wizard batch until the pending
v3.02-v3.05 Studio acceptance work is completed.
