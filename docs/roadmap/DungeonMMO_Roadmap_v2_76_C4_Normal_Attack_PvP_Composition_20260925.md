# DungeonMMO Roadmap v2.76 — C4 Normal Attack and PvP Composition

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.75](
DungeonMMO_Roadmap_v2_75_C4_Source_Shot_Authority_20260925.md).

## Goal

Close the remaining player-versus-player C4 formula composition before a live
source-combat executor is allowed to apply damage.

This milestone combines the already-reviewed ordinary attack pieces into one
authoritative source-only result and wires the reviewed C4 player PvP damage
stats and weapon vulnerability path into physical and magical calculations.

## Reviewed C4 source behaviour

Pinned source commit:

`07f8536384e799f128d44198dd7ab23519660eea`.

For one ordinary single-target physical strike, the reviewed source resolves:

1. hit/miss;
2. shield use;
3. physical critical;
4. physical damage;
5. successful-hit Soulshot discharge.

`calcPhysDam` selects a target vulnerability stat from the attacker's active
weapon kind before applying random damage. The currently reviewed launch weapon
kinds map to:

- Bow → `BOW_WPN_VULN`;
- Blunt → `BLUNT_WPN_VULN`;
- Dagger → `DAGGER_WPN_VULN`;
- Polearm → `POLE_WPN_VULN`;
- Sword → `SWORD_WPN_VULN`.

For playable attacker against playable target, the source then uses:

- ordinary physical attack → `PVP_PHYSICAL_DMG`;
- physical skill damage → `PVP_PHYS_SKILL_DMG`;
- magical damage → `PVP_MAGICAL_DMG`.

All three neutral source bases are 1 until a reviewed source effect changes
them.

## GitHub implementation

The final source stat candidate now carries neutral source bases for the five
currently reachable weapon-vulnerability families and all three reviewed PvP
damage families.

`C4SourceCombatCalculationService` now provides one complete
`normal_attack(...)` calculation that:

- uses authenticated final Accuracy/Evasion;
- stops immediately on a miss;
- preserves a charged Soulshot on a miss;
- resolves shield only after a hit;
- resolves critical and critical-power inputs server-side;
- resolves reviewed weapon or unarmed random variance;
- resolves target weapon vulnerability from authenticated source state;
- resolves `PVP_PHYSICAL_DMG`;
- consumes the private Soulshot only for a successful strike;
- feeds the complete source input set into `physical_damage`;
- remains source-only and never changes live HP/CP.

Existing PDAM now uses source weapon vulnerability plus
`PVP_PHYS_SKILL_DMG`.

Existing MDAM now uses `PVP_MAGICAL_DMG` in addition to its reviewed magic
critical, optional failure, elemental and shot inputs.

## Real source-target regression

The focused source-combat test uses source skill 112, Deflect Arrow, on a
valid Oathguard target. Its reviewed rank-one effect multiplies
`BOW_WPN_VULN` by 0.84.

A reviewed Short Bow attacker therefore exercises a real non-neutral target
modifier rather than proving only neutral base-one arithmetic.

The test also verifies that repeated misses do not consume an already charged
Soulshot and that the first successful hit does consume it.

## Fresh acceptance

Source/test candidate:

`2b8e74d7dd930969ccb881eae242882cca79587f`.

Fresh unpublished Rojo:

- Base: PASS;
- Dungeon: PASS;
- `git diff --check`: PASS.

Fresh focused Studio:

- Base: **15/15 PASS**;
- Dungeon: **17/17 PASS**;
- combat formula: **49 assertions PASS**;
- source combat: **30 assertions PASS**;
- Dungeon resource cutover: **PASS**.

Source-combat marker:

`hit=true critical=true variance=true shield=true normal=true vuln=true pvp=true magiccrit=true magicfailure=true element=true shots=true pdam=true mdam=true heal=true live=false`.

An initial Base run failed because the new Deflect Arrow test attached source
skill 112 to a starter Fighter fixture that cannot legally learn that active
source rank. The fixture was corrected to a fully valid Oathguard advancement
record in GitHub. No production behaviour was relaxed to make the test pass.

## Deliberate remaining boundaries

This milestone is still player-target/source-only.

The following remain explicit before broad live parity can be claimed:

- runtime position/elevation/night hit-condition mapping;
- authoritative world-transform shield-facing resolution;
- target-specific critical modifiers not yet represented in current scope;
- PDAM skill-critical semantics;
- NPC race-specific physical modifiers;
- live damage application.

## Next backend implementation

Audit and close the remaining spatial/source-target inputs required by the
live executor, especially server-owned hit condition and shield facing.

Then build the separately gated live source-combat executor and acceptance-test
the cutover against player and NPC paths without making source combat the
default.

No main merge, Roblox publish, production DataStore mutation or animation
project edits are part of this milestone.
