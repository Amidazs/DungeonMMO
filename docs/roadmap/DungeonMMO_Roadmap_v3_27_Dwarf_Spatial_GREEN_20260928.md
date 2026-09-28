# DungeonMMO Roadmap v3.27
## Dwarf source spatial binding GREEN
**Date:** 28 September 2026

This checkpoint closes the reviewed Roblox world-distance boundary required by
Dwarven Spoil, Sweep and Spoil Festival. It builds on the already accepted
v3.25 Dwarf backend and v3.26 Dwarf world-infrastructure checkpoints.

## Reviewed world scale

DungeonMMO now has one explicit launch mapping:

- **14 C4 source units = 1 Roblox stud**
- source metadata remains stored unchanged;
- conversion happens only at the server world boundary;
- this is a reviewed launch calibration, not a claim that the original game
  exposed an exact physical metre identity.

Representative conversions:

- source castRange 20 -> **1.43 studs** before collision allowance;
- source castRange 40 -> **2.86 studs** before collision allowance;
- source radius 150 -> **10.71 studs**;
- Spoil Festival radius 200 -> **14.29 studs**;
- source range 600 -> **42.86 studs**;
- source radius 1000 -> **71.43 studs**.

The value was chosen as a cross-engine/world calibration rather than by
copying the old Studio-only 1:1 harness value.

## Exact C4 collision-range behavior

The pinned C4 source commit already used by the project was rechecked at:

`07f8536384e799f128d44198dd7ab23519660eea`

In `CharacterAI.maybeMoveToPawn`, C4 adds the caster collision radius and
the target collision radius to the authored cast offset before performing the
inside-radius check.

DungeonMMO now mirrors that rule for Dwarf salvage casts by using each
authoritative `HumanoidRootPart` horizontal half-extent as the Roblox
collision-radius proxy.

This is especially important for Sweep: its exact source `castRange = 20`
stays intact without forcing the player to overlap the corpse's centre point.

## Source Dwarf spatial contracts

Exact source metadata remains:

- Spoil / skill 254: `castRange = 40`;
- Spoil Festival / skill 302:
  `castRange = 40`, `skillRadius = 200`, `TARGET_AREA`;
- Sweep / skill 42: `castRange = 20`.

The server world resolver now enforces:

- a living authenticated caster;
- a reviewed Dungeon NPC source boundary;
- collision-adjusted source cast range before the scheduler starts;
- horizontal cast-distance checks matching the source movement/range model;
- caster-centred Spoil Festival radius;
- same-`DungeonEncounterId` filtering for Festival secondary targets;
- source-reviewed living NPCs only for Festival;
- reviewed corpse source boundary for Sweep;
- no client authority.

## No MP/reuse loss on invalid range

The salvage cast bridge now resolves the player's exact source timing/rank
before scheduling.

Out-of-range Spoil/Sweep is rejected **before**
`C4SourceCastSchedulerService:begin_cast`, so an invalid world target cannot
consume initial MP or start source reuse.

The target is revalidated again at launch.

## Quest-pack source certification

Validation exposed one cross-system gap: optional first-transfer quest-pack
enemies were spawned after the normal combat-pack executor, so they did not
inherit `DungeonEnemyArchetypeId`.

`C4QuestEncounterSpawns` now stamps the temporary reviewed
`Marauder` source archetype on those physical quest enemies. This makes the
Dwarf Honeyback Bear / Tunnel Tarantula world lives eligible for the same C4
NPC boundary used by the rest of source combat.

This remains explicitly temporary combat-rig metadata until unique quest
creature source boundaries are authored.

## Runtime composition

The Dwarf salvage world resolver is now bound into
`C4SourceCastRuntimeComposition`.

It reads the **current source executor scale**, so all staged source systems
share the same configured conversion. The salvage bridge remains
**disabled by default** and does not independently activate source combat.

The approved launch mapping is stored in
`C4WorldScaleReference`; deterministic Studio cutover harnesses may still
supply another explicit scale when they are intentionally testing spatial
logic.

## Studio acceptance

Fresh unpublished Rojo Dungeon build from the accepted branch returned:

- `VERIFIED_C4_QUEST_PACK_SOURCE_BOUNDARY_PASS`
- `VERIFIED_DWARF_SPATIAL_V2_PASS 4`
- `VERIFIED_DWARF_BACKEND_SPATIAL_V2_PASS 27`

The focused spatial package proves:

1. the 14:1 reviewed conversion;
2. collision-adjusted Spoil range;
3. out-of-range rejection;
4. caster-centred Festival radius 200;
5. same-encounter inclusion;
6. other-encounter exclusion;
7. unreviewed NPC exclusion;
8. close-range corpse Sweep with collision allowance;
9. Sweep rejection beyond the adjusted range;
10. range rejection before scheduler/MP start;
11. runtime composition binds timing, range and Festival area authorities.

## What is GREEN

- reviewed Dwarf salvage world scale;
- Spoil cast range;
- Sweep cast range;
- Spoil Festival area radius;
- C4-style collision allowance;
- same-encounter Festival filtering;
- source NPC boundary enforcement;
- quest-pack source-boundary certification;
- pre-MP spatial rejection;
- default-off runtime composition.

## What is still deliberately not GREEN

- source combat is not enabled by default in production;
- Dwarf creation is still not enabled for fresh players;
- final Dwarf NPC/monster art and VFX are not implied by this checkpoint;
- the temporary quest monsters still use Marauder source combat boundaries;
- no production publish or main-branch merge is part of this checkpoint.

## Next development gate

The Dwarf class/backend/world/spatial launch boundaries are now sufficiently
closed to move out of class-system work.

Proceed with **professions and economy content**:

1. audit the current gathering/crafting content against the approved
   1G+1C / Gearwright 1G+2C / Deepclaimer 2G+1C authority;
2. define launch-level gathering nodes, materials, recipes and blueprint
   dependencies;
3. ensure no profession can self-supply every important chain;
4. preserve meaningful player trading and auction-house pressure;
5. add profession progression and recipe unlock tests;
6. then continue launch-level quest/content expansion.

Do not add another Dwarf class mechanic merely because the source class has
crafting flavor; profession identity and class identity remain separate.
