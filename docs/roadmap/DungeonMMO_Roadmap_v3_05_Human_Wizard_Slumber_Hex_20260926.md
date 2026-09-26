# DungeonMMO Roadmap v3.05 — Human Wizard Slumber Hex

Date: 26 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v3.04](
DungeonMMO_Roadmap_v3_04_Human_Wizard_Life_Siphon_20260926.md).

## Status

**IMPLEMENTED — fresh Base/Dungeon builds pass; Studio acceptance pending.**

Code candidate will be recorded after the final documentation fast-forward.

Pending evidence:
[Human Wizard Slumber Hex v3.05](
../testing/c4-human-wizard-slumber-hex-v3-05-pending-20260926.md).

## Exact source behavior

`EmberweaverSlumberHex` rank 6 maps directly to source Sleep 1069 rank 6.

The reviewed source contract is preserved:

- magical DEBUFF;
- effect type SLEEP;
- WIT resistance;
- effect power 80;
- magic level 30;
- cast range 600 source units;
- effect range 1100 source units;
- 30-second source duration;
- 6 initial MP + 21 launch MP;
- 2500 ms authored hit time;
- 6000 ms authored reuse;
- single-target `TARGET_ONE`.

With the current level-30 Human Wizard source timing candidate
(M.Atk.Spd 333 and MAGICAL_SKILL_REUSE 0.75), Slumber Hex resolves to a
2.5-second cast and 4.5-second final reuse from cast start.

## Reviewed C4 Sleep semantics

Pinned C4 Sleep starts by aborting the target's current attack and cast,
stopping movement and putting AI into an idle sleeping state. While sleeping,
movement, attacks and skills are disabled.

The pinned HP-reduction path also wakes Sleep before ordinary damage is
applied. By contrast, Bleed and Poison ticks use the source NPC
`awake=false` path, so those periodic ticks do not wake an attackable NPC.

DungeonMMO now preserves those distinctions:

1. the source land roll uses exact WIT/effect-power/magic-level inputs;
2. one server-owned Spiritshot/Blessed Spiritshot charge is consumed by the
   Sleep cast;
3. a resisted cast applies no live control;
4. a landed cast creates a server-owned 30-second NPC Sleep state;
5. supported NPC AI suppresses movement and new attacks while asleep;
6. an attack already winding up is interrupted when Sleep becomes active;
7. ordinary direct source damage clears Sleep before HP loss;
8. existing periodic Bleed/Poison ticks do not use the direct-damage wake path.

## NPC Sleep authority

A reusable server service now owns NPC Sleep state rather than embedding it in
one spell or one enemy controller.

It records:

- `C4Sleeping`;
- `C4SleepEndsAt`;
- non-stacking/refresh-safe expiry;
- explicit wake-on-direct-damage behavior.

The first supported NPC controllers are:

- Training Marauder;
- Marauder Captain.

Both now stop chasing/attacking during Sleep. Captain and training attack
windups also re-check Sleep so a control spell can interrupt an action already
in progress.

## Staged cast bridge

The targeted magic bridge now reviews seven Human Wizard spell families:

- Ember Bolt;
- Flame Burst;
- Focused Bolt;
- Frost Lance;
- Ember Field;
- Life Siphon;
- Slumber Hex.

Slumber Hex selects the dedicated Sleep executor route while retaining the same
server-owned cast-range check, split MP lifecycle, effect-range revalidation and
private target binding as the other staged spells.

## Added regression coverage

Existing suites now cover:

- creative rank 6 -> source 1069 rank 6;
- exact WIT / effect-power 80 / magic-level 30 land inputs;
- exact 30-second control duration;
- one-use magical shot ownership;
- resisted versus landed control behavior;
- live Sleep state with no damage callback;
- ordinary direct damage waking Sleep;
- exact 600/1100 ranges;
- exact 6 + 21 MP split spend;
- exact 2.5-second hit / 4.5-second reuse timing;
- targeted bridge routing;
- runtime composition executor compatibility.

## Local validation

The Slumber Hex code candidate passed:

1. `git diff --check`;
2. Base Rojo build;
3. Dungeon Rojo build;
4. direct-magic constructor/fake audit.

Only the pre-existing quadruped Python `__pycache__` folders remain
untracked.

Studio-focused and unpublished live acceptance have not yet been rerun for
this batch, so v3.05 is not marked green.

## Next acceptance gate

Run the existing Human Wizard focused runner and large backend runner, then one
unpublished Dungeon Slumber Hex rehearsal proving:

`cast -> one magical shot -> WIT roll -> 30-second Sleep -> movement/attack
suppression -> in-progress attack interruption -> direct-damage wake -> clean
logs`.

A follow-up live check should also confirm that an existing reviewed periodic
Bleed/Poison tick does not incorrectly wake a sleeping attackable NPC.

After this gate, continue the remaining level-30 non-companion Wizard control
families. Scorch Mark / source Surrender to Fire is the next useful family.

No `main` merge, Roblox publish, production DataStore mutation or animation
work.
