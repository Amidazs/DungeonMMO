# DungeonMMO Roadmap v3.03 — Human Wizard Ember Field

Date: 26 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v3.02](
DungeonMMO_Roadmap_v3_02_Human_Wizard_Frost_Lance_20260926.md).

## Status

**IMPLEMENTED — fresh Base/Dungeon builds pass; Studio acceptance pending.**

Code candidate:

`19173565960c2137a2f95e8699dea83e7e3bd6a3`.

Pending evidence:
[Human Wizard Ember Field v3.03](
../testing/c4-human-wizard-ember-field-v3-03-pending-20260926.md).

## Exact source behavior

`EmberweaverEmberField` rank 3 maps to source Flame Strike 1181 rank 3.

The reviewed source contract is preserved:

- FIRE MDAM, power 19;
- magic level 30;
- cast range 500 source units;
- effect range 1000 source units;
- skill radius 200 source units;
- TARGET_AREA targeting;
- 8 initial MP + 32 launch MP;
- 4000 ms base hit time;
- 15000 ms base reuse.

The existing source timing/reuse pipeline remains authoritative.

## C4 TARGET_AREA semantics

The pinned C4 `TargetArea` implementation keeps the selected target and then
tests additional offensive targets against `skillRadius` from the caster.

DungeonMMO now mirrors that shape for reviewed NPC combat:

1. the selected server-bound NPC remains the primary target;
2. additional living reviewed NPCs are discovered inside the converted
   200-source-unit radius around the caster;
3. secondaries must share the primary NPC's `DungeonEncounterId`;
4. arbitrary client target lists are never accepted.

The source implementation appears capable of adding the selected target twice
when it is also inside radius. DungeonMMO deliberately does not reproduce that
duplicate-list behavior; one NPC receives one area hit per cast.

## One-shot multi-target calculation

The pinned C4 MDAM handler snapshots Spiritshot/Blessed Spiritshot before its
target loop and clears the charge after the loop.

The source combat calculator now exposes the same one-shot area model:

- all target boundaries are validated first;
- one magical shot state is consumed;
- each target receives its own magic critical/failure/element calculation;
- every target uses the same captured shot state;
- the charge is not consumed again per target.

This keeps area damage scaling consistent with the source without multiplying
shot cost by enemy count.

## Live NPC application

The source executor discovers the legal area set server-side, calculates the
whole target set, then applies each result through the existing NPC source
damage function.

Each damaged NPC therefore preserves the normal:

- threat update;
- contribution bookkeeping;
- quest damage observer;
- lethal/nonlethal evidence;
- action sequence attribution.

NPCs in another encounter are excluded even when physically nearby.

## Staged cast bridge

The targeted magic bridge now reviews five Human Wizard spell families:

- Ember Bolt;
- Flame Burst;
- Focused Bolt;
- Frost Lance;
- Ember Field.

Ember Field selects the dedicated TARGET_AREA executor route with source radius
200. The selected target still passes normal cast-range validation before the
initial MP spend and effect-range validation before launch MP.

## Added regression coverage

Existing suites were extended to cover:

- exact Ember Field 1181:3 mapping;
- source power 19 / FIRE / radius 200 metadata;
- one Spiritshot shared across multiple calculated targets;
- area bridge routing and exact source radius handoff;
- same-encounter secondary selection;
- exclusion of a nearby different-encounter NPC;
- per-target source bookkeeping callbacks.

No parallel custom AOE combat formula was introduced.

## Local validation

Fresh local validation after GitHub fast-forward:

1. `git diff --check`: PASS;
2. Base Rojo build: PASS;
3. Dungeon Rojo build: PASS;
4. candidate HEAD:
   `19173565960c2137a2f95e8699dea83e7e3bd6a3`;
5. only the pre-existing quadruped Python `__pycache__` folders remain
   untracked.

Studio-focused and unpublished live acceptance have not yet been rerun for
this candidate, so v3.03 is not marked green.

## Next acceptance gate

Run the existing Human Wizard focused and large backend runners, then one
unpublished Dungeon Ember Field rehearsal with multiple reviewed NPCs.

The live rehearsal must prove:

`targeted cast -> one shot -> primary damage -> same-encounter radius damage
-> no cross-encounter damage -> per-target contribution/threat -> clean log`.

After this gate, the next non-companion Wizard behavior is Life Siphon/drain
healing semantics.

No `main` merge, Roblox publish, production DataStore mutation or animation
work.
