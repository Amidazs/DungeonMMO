# DungeonMMO Roadmap v3.06 — Human Wizard Scorch Mark

Date: 26 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v3.05](
DungeonMMO_Roadmap_v3_05_Human_Wizard_Slumber_Hex_20260926.md).

## Status

**IMPLEMENTED — fresh Base/Dungeon builds pass; Studio acceptance pending.**

Core code candidate:
`29b28b0d0aaa417fc12196810c27c17ce67b5bb9`.

Pending evidence:
[Human Wizard Scorch Mark v3.06](
../testing/c4-human-wizard-scorch-mark-v3-06-pending-20260926.md).

## Exact source behavior

`EmberweaverScorchMark` rank 2 maps directly to source Surrenders To Fire
1083 rank 2.

The reviewed source contract is preserved:

- magical DEBUFF;
- WIT resistance;
- effect power 80;
- magic level 30;
- cast range 750 source units;
- effect range 1250 source units;
- `FIRE_VULN x1.25`;
- 15-second duration;
- source stack type `FireAtr`;
- 3 initial MP + 11 launch MP;
- 1500 ms authored hit time;
- 8000 ms authored reuse;
- single-target `TARGET_ONE`.

With the current level-30 Human Wizard source timing candidate
(M.Atk.Spd 333 and MAGICAL_SKILL_REUSE 0.75), Scorch Mark resolves to a
1.5-second cast and 6-second final reuse from cast start.

## Source SkillDebuff semantics

The pinned C4 `SkillDebuff` handler snapshots the current magical-shot state,
uses it in the hostile-effect success calculation and consumes that magical
shot once after the target loop.

A resisted debuff applies no effect. A landed debuff installs the source
effect modifiers.

DungeonMMO now mirrors that contract:

1. the source calculation resolves exact WIT/effect-power/magic-level inputs;
2. one Spiritshot/Blessed Spiritshot is consumed by source calculation;
3. resisted casts leave runtime elemental state unchanged;
4. landed casts install `FIRE_VULN x1.25` for 15 seconds;
5. the immutable reviewed NPC source reference is never modified;
6. a temporary decorated NPC source boundary is generated for subsequent
   source combat calculations;
7. fire MDAM therefore reads the increased vulnerability through the existing
   source elemental damage formula.

## NPC elemental vulnerability authority

A reusable server service now owns runtime elemental vulnerability effects.

It supports the C4 elemental stat family:

- FIRE_VULN;
- WIND_VULN;
- WATER_VULN;
- EARTH_VULN;
- HOLY_VULN;
- DARK_VULN.

Only FIRE_VULN is currently wired to a reviewed Human Wizard skill.

The authority:

- does not multiply repeated applications together;
- keeps the strongest current multiplier;
- refreshes expiry without shortening a stronger effect;
- decorates only the current combat boundary;
- preserves the immutable source reference;
- clears current-life debuffs when supported NPCs die/respawn.

Training Marauder and Marauder Captain death/life handling now clears this
runtime state so a debuff cannot leak into a new NPC life hosted by the same
Model.

## Staged cast bridge

The targeted magic bridge now reviews eight Human Wizard spell families:

- Ember Bolt;
- Flame Burst;
- Focused Bolt;
- Frost Lance;
- Ember Field;
- Life Siphon;
- Slumber Hex;
- Scorch Mark.

Scorch Mark selects the dedicated elemental-vulnerability executor while
retaining the normal server-owned cast-range check, split MP lifecycle,
effect-range revalidation and private target binding.

## Added regression coverage

The focused suites now cover:

- creative rank 2 -> source 1083 rank 2;
- exact WIT / effect-power 80 / magic-level 30 land inputs;
- one-use magical-shot ownership;
- exact FIRE_VULN 1.25 multiplier;
- exact 15-second duration and FireAtr stack identity;
- live debuff application with zero damage callback;
- non-stacking weaker refresh behavior;
- immutable source-boundary decoration;
- current-life cleanup support;
- exact 750/1250 ranges;
- exact 3 + 11 MP split spend;
- exact 1.5-second hit / 6-second reuse timing;
- targeted bridge routing.

The focused source-cast runner now contains 16 suites and the broad Human
Wizard backend runner contains 36 suites. Those expanded Studio runners have
not yet been rerun for v3.06.

## Local validation

Fresh local validation after GitHub fast-forward:

1. `git diff --check`: PASS;
2. Base Rojo build: PASS;
3. Dungeon Rojo build: PASS;
4. only the pre-existing quadruped Python `__pycache__` folders remain
   untracked.

Studio-focused and unpublished live acceptance remain pending.

## Next acceptance gate

Run the existing Human Wizard focused and broad runners, then one unpublished
Dungeon rehearsal proving:

`cast -> one magical shot -> WIT roll -> FIRE_VULN x1.25 -> fire spell uses
1.25 elemental multiplier -> expiry/cleanup -> clean logs`.

After this gate, continue the remaining non-companion level-30 Human Wizard
families. Withering Hex / source Curse: Weakness is the next useful debuff
family.

No `main` merge, Roblox publish, production DataStore mutation or animation
work.
