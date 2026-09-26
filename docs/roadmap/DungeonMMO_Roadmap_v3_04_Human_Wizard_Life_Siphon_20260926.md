# DungeonMMO Roadmap v3.04 — Human Wizard Life Siphon

Date: 26 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v3.03](
DungeonMMO_Roadmap_v3_03_Human_Wizard_Ember_Field_20260926.md).

## Status

**IMPLEMENTED — fresh Base/Dungeon builds pass; Studio acceptance pending.**

Code candidate:

`5291dac8eaa4497a928001e953f4ae533c73ce34`.

Pending evidence:
[Human Wizard Life Siphon v3.04](
../testing/c4-human-wizard-life-siphon-v3-04-pending-20260926.md).

## Exact source behavior

`EmberweaverLifeSiphon` rank 4 maps to source Vampiric Touch 1147 rank 6.

The reviewed source contract is preserved:

- DARK DRAIN, power 32;
- magic level 25;
- cast range 600 source units;
- effect range 1100 source units;
- absorbPart 0.4;
- absorbAbs 0;
- 7 initial MP + 27 launch MP;
- 4000 ms authored hit time;
- 12000 ms authored reuse.

With the current level-30 Human Wizard source timing candidate
(M.Atk.Spd 333, MAGICAL_SKILL_REUSE 0.75), this resolves to a 4-second hit
and 9-second final reuse from cast start.

## Reviewed C4 drain semantics

The pinned C4 SkillDrain handler:

1. snapshots Spiritshot/Blessed Spiritshot once;
2. calculates ordinary source magic damage;
3. determines the drainable HP portion;
4. heals the caster by `absorbAbs + absorbPart * drain`;
5. caps caster healing at MaxHP;
6. applies the target damage;
7. consumes the magical shot once.

For NPC targets there is no combat-point pool, so the drainable portion is
the HP actually removable by the hit.

DungeonMMO now keeps those semantics in the server source path:

- the source calculator performs exact DARK magic damage;
- one magical shot is consumed by that calculation;
- the live executor applies the NPC damage through the existing source damage
  bookkeeping path;
- healing uses the actual server-observed HP removed;
- the requested heal is `0 + 0.4 * applied HP damage`;
- the caster heal is capped by the live Humanoid MaxHealth.

This prevents over-healing from raw damage that the NPC did not actually have
remaining.

## Staged cast bridge

The targeted magic bridge now reviews six Human Wizard spell families:

- Ember Bolt;
- Flame Burst;
- Focused Bolt;
- Frost Lance;
- Ember Field;
- Life Siphon.

Life Siphon selects the dedicated `MagicDrain` executor route while retaining
normal cast-range validation before initial MP and effect-range validation
before launch MP.

## Added regression coverage

Existing suites were extended to cover:

- creative rank 4 -> source 1147 rank 6;
- DARK source power 32;
- exact absorbPart 0.4 / absorbAbs 0;
- one-use Spiritshot consumption;
- live NPC damage plus caster healing;
- MaxHealth healing cap;
- trusted NPC contribution/threat/quest bookkeeping;
- exact 600/1100 range handoff;
- exact 7 + 27 MP split-spend;
- exact 4-second hit / 9-second reuse timing;
- staged bridge routing to drain execution.

## Local validation

Fresh local validation after GitHub fast-forward:

1. `git diff --check`: PASS;
2. Base Rojo build: PASS;
3. Dungeon Rojo build: PASS;
4. code candidate:
   `5291dac8eaa4497a928001e953f4ae533c73ce34`;
5. only the pre-existing quadruped Python `__pycache__` folders remain
   untracked.

Studio-focused and unpublished live acceptance have not yet been rerun for
this candidate, so v3.04 is not marked green.

## Next acceptance gate

Run the existing Human Wizard focused and large backend runners, then one
unpublished Dungeon Life Siphon rehearsal proving:

`cast -> one magical shot -> DARK source damage -> real NPC HP removed ->
40% caster heal -> MaxHP cap -> threat/contribution preserved -> clean log`.

After this gate, continue the remaining non-companion Wizard control families,
starting with Slumber Hex/sleep semantics.

No `main` merge, Roblox publish, production DataStore mutation or animation
work.
