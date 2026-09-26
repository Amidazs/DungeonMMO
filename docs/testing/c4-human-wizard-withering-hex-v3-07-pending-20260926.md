# Human Wizard Withering Hex v3.07 — Pending Studio Acceptance

Date: 26 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Core code candidate:
`b2fb6ac0348501b49a2abf471874137f60599f81`.

## Implemented

`EmberweaverWitheringHex` rank 3 maps to source Curse: Weakness 1164:4:

- magical DEBUFF;
- source effect type CONFUSION;
- WIT resistance;
- effect power 80;
- magic level 30;
- 600 cast range;
- 1100 effect range;
- PHYSICAL_ATTACK x0.8;
- 15-second duration;
- 3 + 11 split MP;
- 1500 ms authored hit time;
- 8000 ms authored reuse.

The current level-30 Human Wizard timing candidate resolves those authored
timings to a 1.5-second cast and 6-second final reuse.

## Live authority

A landed Withering Hex delegates to the existing server-owned
`EnemyWeakeningService` with a 0.20 power reduction and zero rate reduction.

Supported NPC outgoing damage already flows through
`EnemyDamageMultiplierRules`, so this results in an exact 0.8 outgoing
physical-damage multiplier. Attack interval remains unchanged.

Training Marauder and Marauder Captain life cleanup now explicitly clears the
weakening authority so a prior-life debuff cannot leak into a new NPC life.

## Completed local checks

- GitHub fast-forward: PASS.
- `git diff --check`: PASS.
- Base Rojo build: PASS.
- Dungeon Rojo build: PASS.
- Source status-plan regression extended.
- Source combat-calculation regression extended.
- Live executor regression extended.
- Targeted bridge regression extended.
- Cross-service staged integration regression extended.
- Runtime composition fake contract extended.
- Broad Wizard runner now includes `C4EnemyWeakeningTest`.
- No `main` merge or publish.
- Existing quadruped `__pycache__` folders left untouched.

## Studio checks still required

Before marking v3.07 green:

1. run `c4_human_wizard_source_cast_focus.luau` (16 suites);
2. run `c4_human_wizard_big_backend_focus.luau` (37 suites);
3. cast Withering Hex against a reviewed unpublished Dungeon NPC;
4. verify one Spiritshot/Blessed Spiritshot is consumed;
5. verify a landed cast exposes 0.20 power weakening for 15 seconds;
6. verify the NPC's outgoing physical hit is 80 percent of the same
   pre-defence base path;
7. verify its attack interval is unchanged;
8. verify a resisted cast applies no weakening;
9. verify repeated weaker effects do not multiply the reduction;
10. verify death/respawn cleanup removes old weakening state;
11. verify the final log has no project CreatorErrors.

v3.01 remains the latest fully accepted Wizard batch until the pending
v3.02-v3.07 Studio acceptance work is completed.
