# Human Wizard Scorch Mark v3.06 — Pending Studio Acceptance

Date: 26 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Core code candidate:
`29b28b0d0aaa417fc12196810c27c17ce67b5bb9`.

## Implemented

`EmberweaverScorchMark` rank 2 maps to source Surrenders To Fire 1083:2:

- magical DEBUFF;
- WIT resistance;
- effect power 80;
- magic level 30;
- 750 cast range;
- 1250 effect range;
- FIRE_VULN x1.25;
- 15-second duration;
- 3 + 11 split MP;
- 1500 ms authored hit time;
- 8000 ms authored reuse.

The current level-30 Human Wizard timing candidate resolves those authored
timings to a 1.5-second cast and 6-second final reuse.

## Runtime elemental authority

A landed Scorch Mark now installs the exact source fire-vulnerability
multiplier in a server-owned NPC authority.

The authority never edits the pinned NPC source reference. Instead it decorates
a fresh combat boundary when the NPC is used in a later source calculation.
This allows the existing elemental magic formula to read FIRE_VULN 1.25 while
all unrelated vulnerability stats remain unchanged.

Repeated weaker applications cannot reduce or multiply the active effect.

Training Marauder and Marauder Captain life cleanup now removes elemental
debuff state so an old effect cannot survive a death/respawn boundary.

## Completed local checks

- GitHub fast-forward: PASS.
- `git diff --check`: PASS.
- Base Rojo build: PASS.
- Dungeon Rojo build: PASS.
- Source status-plan regression extended.
- Source combat-calculation regression extended.
- Live executor regression extended.
- Dedicated elemental-vulnerability authority regression added.
- Targeted bridge regression extended.
- Cross-service staged integration regression extended.
- Source-cast runner expanded to 16 suites.
- Broad Human Wizard runner expanded to 36 suites.
- No `main` merge or publish.
- Existing quadruped `__pycache__` folders left untouched.

## Studio checks still required

Before marking v3.06 green:

1. run `c4_human_wizard_source_cast_focus.luau`;
2. run `c4_human_wizard_big_backend_focus.luau`;
3. confirm all 16 focused and 36 broad suites pass;
4. cast Scorch Mark against a reviewed unpublished Dungeon NPC;
5. verify one Spiritshot/Blessed Spiritshot is consumed;
6. verify a landed cast exposes FIRE_VULN 1.25 for 15 seconds;
7. cast a reviewed fire spell and verify its elemental multiplier is 1.25;
8. verify non-fire elemental stats remain neutral;
9. verify a weaker/repeated application does not multiply the effect;
10. verify death/respawn cleanup removes old vulnerability state;
11. verify the final log has no project CreatorErrors.

v3.01 remains the latest fully accepted Wizard batch until the pending
v3.02-v3.06 Studio acceptance work is completed.
