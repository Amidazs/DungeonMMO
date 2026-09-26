# DungeonMMO Roadmap v3.07 — Human Wizard Withering Hex

Date: 26 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v3.06](
DungeonMMO_Roadmap_v3_06_Human_Wizard_Scorch_Mark_20260926.md).

## Status

**IMPLEMENTED — fresh Base/Dungeon builds pass; Studio acceptance pending.**

Core code candidate:
`b2fb6ac0348501b49a2abf471874137f60599f81`.

Pending evidence:
[Human Wizard Withering Hex v3.07](
../testing/c4-human-wizard-withering-hex-v3-07-pending-20260926.md).

## Exact source behavior

`EmberweaverWitheringHex` rank 3 maps to source Curse: Weakness 1164
rank 4.

The reviewed level-30 source contract is preserved:

- magical DEBUFF;
- source effect type `CONFUSION`;
- WIT resistance;
- effect power 80;
- magic level 30;
- cast range 600 source units;
- effect range 1100 source units;
- `PHYSICAL_ATTACK x0.8`;
- 15-second duration;
- source stack type `pAtkDown`;
- 3 initial MP + 11 launch MP;
- 1500 ms authored hit time;
- 8000 ms authored reuse;
- single-target `TARGET_ONE`.

With the current level-30 Human Wizard source timing candidate
(M.Atk.Spd 333 and MAGICAL_SKILL_REUSE 0.75), Withering Hex resolves to a
1.5-second cast and 6-second final reuse from cast start.

## Live weakening behavior

The existing server-owned `EnemyWeakeningService` already provides the
correct non-stacking outgoing physical-power boundary used by supported
Marauders and the Marauder Captain.

Withering Hex now uses that authority with:

- power reduction fraction 0.20;
- attack-rate reduction fraction 0;
- duration 15 seconds.

This preserves the C4 distinction: Curse: Weakness changes physical attack
power only. It does not slow attack cadence.

The existing `EnemyDamageMultiplierRules` consumes the weakening power
multiplier for supported NPC attacks, so a landed source debuff now reduces
their outgoing physical damage to 80 percent while leaving timing unchanged.

## Source SkillDebuff semantics

The pinned C4 `SkillDebuff` handler snapshots magical-shot state, includes
that state in the hostile-effect success calculation and consumes the magical
shot once after the target loop.

DungeonMMO mirrors that contract:

1. source rank 1164:4 is resolved from owned creative rank 3;
2. one Spiritshot/Blessed Spiritshot is consumed by source calculation;
3. the WIT/effect-power/magic-level roll is server-owned;
4. a resisted cast changes no live weakening state;
5. a landed cast applies exactly 20 percent outgoing physical-power reduction;
6. attack-rate reduction remains neutral;
7. repeated weaker weakening cannot stack multiplicatively;
8. supported NPC death/respawn clears weakening state.

## Staged cast bridge

The targeted magic bridge now reviews nine Human Wizard spell families:

- Ember Bolt;
- Flame Burst;
- Focused Bolt;
- Frost Lance;
- Ember Field;
- Life Siphon;
- Slumber Hex;
- Scorch Mark;
- Withering Hex.

Withering Hex selects the dedicated physical-attack weakening executor while
retaining server-owned cast-range checking, split MP lifecycle, effect-range
revalidation and private target binding.

## Regression coverage

Coverage now checks:

- creative rank 3 -> source 1164 rank 4;
- exact WIT / effect-power 80 / magic-level 30 land inputs;
- exact source effect type CONFUSION;
- one-use magical-shot ownership;
- PHYSICAL_ATTACK x0.8;
- exact 20 percent outgoing power reduction;
- no attack-rate reduction;
- exact 15-second duration and pAtkDown stack identity;
- live debuff application with no damage callback;
- exact 600/1100 ranges;
- exact 3 + 11 MP split spend;
- exact 1.5-second hit / 6-second reuse timing;
- targeted bridge routing;
- existing outgoing NPC damage-rule integration.

The focused source-cast runner remains 16 suites. The broad Human Wizard
backend runner is now 37 suites because it also includes the existing
`C4EnemyWeakeningTest` authority regression.

## Local validation

Fresh local validation after GitHub fast-forward:

1. `git diff --check`: PASS;
2. Base Rojo build: PASS;
3. Dungeon Rojo build: PASS;
4. Withering Hex references resolve across progression, source map, runtime
   bridge and regression files;
5. only the pre-existing quadruped Python `__pycache__` folders remain
   untracked.

Studio-focused and unpublished live acceptance remain pending.

## Next acceptance gate

Run the existing Human Wizard focused and broad runners, then one unpublished
Dungeon rehearsal proving:

`cast -> one magical shot -> WIT roll -> 20% NPC physical power reduction ->
attack cadence unchanged -> expiry/death cleanup -> clean logs`.

After this gate, continue the remaining non-companion level-30 Human Wizard
families. Venom Cloud / source Poisonous Cloud is the next useful family and
requires TARGET_AREA periodic-status application.

No `main` merge, Roblox publish, production DataStore mutation or animation
work.
