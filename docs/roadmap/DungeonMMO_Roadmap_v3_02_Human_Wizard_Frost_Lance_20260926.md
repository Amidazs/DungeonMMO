# DungeonMMO Roadmap v3.02 — Human Wizard Frost Lance

Date: 26 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v3.01](
DungeonMMO_Roadmap_v3_01_Human_Wizard_Targeted_Cast_Batch_20260926.md).

## Status

**IMPLEMENTED — fresh Base/Dungeon builds pass; Studio acceptance pending.**

Current code candidate:

`484363b3ffec2d911314201380fe5408ad154d40`.

Pending evidence:
[Human Wizard Frost Lance v3.02](
../testing/c4-human-wizard-frost-lance-v3-02-pending-20260926.md).

## Exact source behavior

`EmberweaverFrostLance` rank 2 maps to source Ice Bolt 1184 rank 6.

The reviewed source contract is preserved:

- WATER direct MDAM, power 16;
- cast range 600 and effect range 1100 source units;
- magical level 20;
- WIT-resisted DEBUFF, effect power 60;
- RUN_SPEED multiplier 0.7;
- one 120-second source effect;
- source stack type `RunSpeedDown`.

The source layer therefore records a 30 percent movement slow rather than
inventing a custom DungeonMMO value.

## WIT resistance boundary

Player resource boundaries and reviewed NPC source boundaries now expose the
exact C4 WIT bonus already derived by the pinned primary-stat implementation.

The hostile slow calculation uses that source WIT bonus in the existing C4
effect-success formula. No client stat or target-provided resistance is
accepted.

## One-use Spiritshot semantics

Frost Lance calculates the direct MDAM first through the existing source magic
path. That calculation owns the one magical shot consumption.

The slow roll reuses the resulting Spiritshot/Blessed Spiritshot state rather
than consuming another charge. This preserves the C4 effect-success adjustment
without introducing double shot consumption.

## Live NPC application

The live source executor now supports a combined magic-damage/movement-slow
operation.

Damage still flows through the existing NPC damage application path, preserving
contribution, quest and threat observers. If the slow lands and the NPC
survives the direct hit, the server applies the movement multiplier through the
existing non-stacking NPC slow authority.

The direct cast bridge now reviews four targeted spell families:

- Ember Bolt;
- Flame Burst;
- Focused Bolt;
- Frost Lance.

Frost Lance selects the combined damage/slow executor path. Ember Field remains
excluded because its area targeting still needs a separate source-authoritative
AOE boundary.

## Added regression coverage

The existing source tests now also cover:

- exact source Frost Lance movement-slow metadata;
- player and NPC source WIT resistance exposure;
- combined MDAM + slow calculation;
- one-use Spiritshot behavior;
- staged Frost Lance scheduler/executor routing.

No new test runner was added; these checks extend suites already present in the
15-suite Human Wizard focused runner and the larger backend runner.

## Local build validation

Fresh local validation after fast-forward:

1. Base Rojo build: PASS;
2. Dungeon Rojo build: PASS;
3. branch HEAD: `484363b3ffec2d911314201380fe5408ad154d40`;
4. only pre-existing quadruped Python `__pycache__` folders remain untracked.

Studio-focused and unpublished live acceptance have not yet been rerun for this
candidate, so v3.02 is not marked green.

## Next acceptance gate

Run the existing Human Wizard focused and large backend suites in Studio, then
perform one unpublished Dungeon Frost Lance rehearsal proving:

`cast -> direct source damage -> one shot consumption -> WIT slow roll ->
0.7 movement multiplier -> contribution/threat preserved -> clean logs`.

After that gate, the next Wizard backend family is Ember Field/AOE magic.

No `main` merge, Roblox publish, production DataStore mutation or animation
work.
