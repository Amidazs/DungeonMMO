# Human Wizard Life Siphon v3.04 — Pending Studio Acceptance

Date: 26 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Code candidate: `5291dac8eaa4497a928001e953f4ae533c73ce34`.

## Implemented

`EmberweaverLifeSiphon` rank 4 now routes through source Vampiric Touch
1147 rank 6 with:

- DARK DRAIN power 32;
- magic level 25;
- 600 cast range;
- 1100 effect range;
- absorbPart 0.4;
- absorbAbs 0;
- 7 + 27 split MP;
- source cast/reuse timing.

## Drain authority

The live NPC route remains fully server-owned. Source magic calculation owns
the one magical shot. The executor then applies NPC HP damage through the
existing source bookkeeping path and computes healing from the actual HP
removed, not the uncapped raw damage.

Caster healing is capped by server Humanoid MaxHealth.

## Completed local checks

- GitHub fast-forward: PASS.
- `git diff --check`: PASS.
- Base Rojo build: PASS.
- Dungeon Rojo build: PASS.
- Source calculation regression extended.
- Live executor regression extended.
- Targeted magic bridge regression extended.
- Cross-service staged cast regression extended.
- Runtime composition fake executor contract updated.
- No `main` merge or publish.
- Existing quadruped `__pycache__` folders left untouched.

## Studio checks still required

Before marking v3.04 green:

1. run `c4_human_wizard_source_cast_focus.luau`;
2. run `c4_human_wizard_big_backend_focus.luau`;
3. confirm source-combat, executor, targeted bridge and staged integration
   suites pass;
4. run an unpublished Dungeon Life Siphon cast against a reviewed NPC;
5. verify one Spiritshot/Blessed Spiritshot is consumed;
6. verify source DARK damage is applied once;
7. verify caster healing equals 40 percent of actual HP removed;
8. verify healing cannot exceed MaxHealth;
9. verify contribution/threat bookkeeping still updates;
10. verify the final log has no project CreatorErrors.

v3.01 remains the latest fully accepted Wizard batch until the pending
v3.02-v3.04 Studio acceptance work is completed.
