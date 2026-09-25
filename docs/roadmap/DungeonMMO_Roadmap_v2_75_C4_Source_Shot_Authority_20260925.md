# DungeonMMO Roadmap v2.75 — C4 Source Shot Authority

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.74](
DungeonMMO_Roadmap_v2_74_C4_Elemental_Resolution_20260925.md).

## Goal

Add server-authoritative Chronicle 4 Soulshot, Spiritshot and Blessed
Spiritshot charging/consumption to the disabled source-combat provider without
copying C4-facing names into DungeonMMO's player item catalogue.

## Reviewed C4 source behaviour

Pinned source commit:

`07f8536384e799f128d44198dd7ab23519660eea`.

The reviewed shot item handlers require:

- an equipped weapon;
- a grade-matching shot item;
- the weapon's exact `soulshots` or `spiritshots` consumption count;
- inventory destruction at charge time;
- no extra consumption when the same family is already charged.

Physical PDAM reads the charged Soulshot state and clears it after the action.
MDAM reads Spiritshot/Blessed Spiritshot, prefers Blessed when both exist, and
clears the selected family. Healing effects use the same magical charge state.

Formula effects already represented in `C4CombatFormulaReference` are:

- Soulshot: physical P.Atk ×2;
- Spiritshot: magic M.Atk ×2;
- Blessed Spiritshot: magic M.Atk ×4;
- Spiritshot heal: ×1.3;
- Blessed Spiritshot heal: ×1.5.

## Reviewed launch weapon requirements

The eight currently reviewed source weapons now carry exact pinned shot
requirements:

- Short Sword 1: 1 Soulshot / 1 Spiritshot;
- Club 4: 1 / 1;
- Apprentice's Wand 6: 1 / 1;
- Dagger 10: 1 / 1;
- Short Bow 13: 1 / 1;
- Trident 291: 2 / 2, D-grade;
- Neti's Bow 1181: 7 / 2;
- Neti's Dagger 1182: 2 / 2.

Gradeless source weapons deliberately retain `Grade=nil` so C4 Expertise
semantics are not corrupted. Shot mapping internally treats that nil grade as
the no-grade shot family.

## DungeonMMO item names

Player-facing consumables use original DungeonMMO names:

- Kinetic Charge;
- Mystic Charge;
- Blessed Mystic Charge;
- D-Grade Kinetic Charge;
- D-Grade Mystic Charge;
- D-Grade Blessed Mystic Charge.

The private source map links those creative items to the reviewed C4 source
item IDs. The historical names/IDs remain implementation provenance, not
DungeonMMO-facing content.

## GitHub implementation

New `C4CreativeShotSourceMap` maps current creative charge items to the
reviewed no-grade/D-grade source shot records.

New server-only `C4SourceShotService`:

- resolves the authenticated reviewed source weapon;
- resolves exact grade and weapon-specific consumption count;
- consumes inventory atomically through existing `InventoryService`;
- keeps charged state private and ephemeral;
- makes recharging the same active family idempotent;
- consumes Soulshot once per physical action;
- gives Blessed magical charge priority without deleting a separately charged
  ordinary Spiritshot;
- clears player charge state on removal.

`RuntimeServices` creates the shot authority from the authoritative inventory
service and installs it into `C4SourceCombatCalculationService`.

The source-combat provider now consumes those private one-use states for PDAM,
MDAM and HEAL. Callers cannot provide shot booleans directly.

## Fresh acceptance

Final candidate:

`7d0e099be945b5531f010293048b1eac45bc8dd9`.

Fresh unpublished Rojo:

- Base: PASS;
- Dungeon: PASS;
- `git diff --check`: PASS.

Fresh focused Studio:

- Base: **15/15 PASS**;
- Dungeon: **17/17 PASS**;
- launch source gear: **15 assertions PASS**;
- source shot service: **11 assertions PASS**;
- source combat: **25 assertions PASS**;
- Dungeon resource cutover: **7 assertions PASS**.

Source-shot marker:

`inventory=true grade=true one_use=true`.

Source-combat marker:

`hit=true critical=true variance=true shield=true magiccrit=true magicfailure=true element=true shots=true pdam=true mdam=true heal=true live=false`.

Two earlier Base attempts exposed testable integration mistakes: representing
gradeless source weapons as the literal grade `"None"`, and one stale test
expectation for Neti's Bow. Both were corrected in GitHub before the final
15/15 and 17/17 acceptance runs.

## Safety boundary

The source-combat calculation gate remains OFF by default. No source damage is
applied to live HP/CP.

No client controls source shot grade, consumption count, charged state, source
item identity or formula multiplier.

No main merge, Roblox publish, production DataStore mutation or animation
project edits are part of this milestone.

## Next backend implementation

Next audit and integrate the remaining C4 PvP/source-target physical and magic
formula modifiers. Before a live executor is enabled, also close the source
normal-attack damage composition so hit/critical/variance/shield/shot are
resolved as one authoritative result rather than isolated previews.

Then build the separately gated live source-combat executor and perform
targeted player/NPC/class regressions.
