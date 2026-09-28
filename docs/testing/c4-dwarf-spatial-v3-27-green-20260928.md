# Dwarf spatial acceptance evidence — v3.27
**Date:** 28 September 2026

## Scope

This evidence covers the reviewed Roblox spatial boundary for Dwarf
Spoil/Sweep source skills and the quest-pack source-boundary integration needed
by Deepclaimer transfer combat.

## Reviewed source facts

Pinned project source commit:

`07f8536384e799f128d44198dd7ab23519660eea`

Exact Dwarf source metadata:

- skill 254 Spoil: `castRange = 40`;
- skill 302 Spoil Festival:
  `castRange = 40`, `skillRadius = 200`, `TARGET_AREA`;
- skill 42 Sweep:
  `castRange = 20`, `TARGET_CORPSE_MOB`.

The same pinned C4 `CharacterAI.maybeMoveToPawn` implementation adds both
actor collision radii to the requested range before checking whether movement
is necessary.

## Reviewed DungeonMMO mapping

`C4WorldScaleReference` fixes the launch mapping at:

**14 source units per Roblox stud**

Representative values:

| Source distance | Roblox distance |
| ---: | ---: |
| 20 | 1.4286 studs |
| 40 | 2.8571 studs |
| 150 | 10.7143 studs |
| 200 | 14.2857 studs |
| 600 | 42.8571 studs |
| 1000 | 71.4286 studs |

Collision allowance is added separately for cast-range checks.

## Server authority

`C4DwarfSalvageWorldResolver` requires:

- server-owned living caster model;
- source-reviewed NPC/corpse boundary;
- authoritative HumanoidRootPart roots;
- current source-units-per-stud scale;
- exact source castRange;
- same Dungeon encounter for Festival secondary targets.

No client-supplied distance, radius, archetype or encounter value is trusted.

## Transaction ordering

`C4SourceSalvageCastService` now resolves read-only source timing and performs
world target/range validation before calling the cast scheduler.

Acceptance explicitly verifies an out-of-range Spoil:

- returns `C4SalvageTargetOutOfRange`;
- never calls scheduler begin;
- therefore cannot spend initial MP;
- therefore cannot start source reuse.

Launch performs the same target preflight again.

## Quest-pack integration fix

The first-transfer quest pack is appended after normal combat-pack creation.
Those physical enemies therefore needed an explicit temporary source boundary.

`C4QuestEncounterSpawns` now applies:

`DungeonEnemyArchetypeId = "Marauder"`

to its current Marauder-rig quest monsters.

The existing source-pack regression now requires that boundary on Human/Elf
and Dwarf quest lives, including Honeyback Bear and Tunnel Tarantula.

## Fresh Studio evidence

Branch build passed `git diff --check` and Rojo build.

Accepted Play markers:

- `VERIFIED_C4_QUEST_PACK_SOURCE_BOUNDARY_PASS`
- `VERIFIED_DWARF_SPATIAL_V2_PASS 4`
- `VERIFIED_DWARF_BACKEND_SPATIAL_V2_PASS 27`

The 27-suite package includes all previous Dwarf backend coverage plus
`C4WorldScaleReferenceTest` and
`C4DwarfSalvageWorldResolverTest`.

## Non-claims

This checkpoint does not enable the source salvage bridge by default, enable
fresh Dwarf character creation, replace temporary quest-creature art, publish
a production place or merge the branch.
