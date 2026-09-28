# DungeonMMO Roadmap v3.30
## Live Dungeon Skinning supply GREEN
**Date:** 28 September 2026

This checkpoint closes the live animal-like Dungeon supply gap left after the
v3.28 profession economy and v3.29 blueprint acquisition checkpoints.

It does not claim final wolf art, animation or dedicated beast combat AI.
It proves that the real encounter pipeline now contains a genuine server-owned
animal-like enemy that participates in combat, loot, corpse retention and
Skinning without weakening the accepted animal-only rules.

## Live Forest Wolf binding

Temple Depth 1 Room 1 is now a heterogeneous combat pack:

- 1 Marauder;
- 1 Forest Wolf.

The Forest Wolf uses the existing generic combat-pack executor and a registered
`ForestWolf` enemy factory. It is not spawned through a profession-only
side path.

The wolf factory currently reuses the accepted Marauder combat skeleton and
controller contract with a temporary quadruped placeholder silhouette. That is
deliberately presentation debt, not a claim of final creature quality.

## Animal-only identity

The Forest Wolf is server-authored with:

- `CreatureSpeciesId = "forest_wolf"`;
- `CreatureFamily = "Beast"`;
- `DungeonMMOSkinnableBeast` CollectionService tag.

The adjacent Marauder remains non-animal and receives none of those Skinning
credentials.

Skinning eligibility therefore still comes from explicit server identity and
not from display names, arbitrary client values or generic humanoid state.

## Encounter lifecycle

The wolf participates in the normal Room 1 encounter lifecycle.

Accepted behavior:

1. Room 1 trigger activates the mixed pack.
2. Marauder and Forest Wolf both count toward the same encounter objective.
3. Both use normal encounter reward bookkeeping.
4. Defeating both clears the encounter and advances Room 2.
5. Normal loot completion occurs before Skinning.
6. The dead wolf is retained through `DungeonEnemyCleanup` for the harvest
   window.
7. The Marauder does not become skinnable.

## Level-three Thick Hide

The v3.28 Skinning tier now has a real Dungeon supply source.

A player with Skinning level 3 interacting with the real retained Forest Wolf
corpse receives:

- **1 Thick Hide**;
- normal Skinning XP through the existing profession service;
- one successful claim only.

The same corpse cannot award hide twice.

## Backend acceptance

Fresh unpublished Rojo build from branch head
`9901108d4499fb7fa915d51039acb144d4dc94e9` passed
`git diff --check` and build.

Fresh current-head Play returned:

`VERIFIED_LIVE_SKINNING_BACKEND_FOCUS_PASS 14`

The 14-suite focused package covers:

- mixed encounter spawn catalogue;
- Forest Wolf factory identity;
- enemy cleanup/retention;
- combat-pack execution;
- execution bootstrap/registry;
- enemy factory registry;
- Depth-1 bindings and encounter flow;
- animal-only Skinning eligibility;
- single-user and contested two-user corpse Skinning;
- profession gather-tier authority.

## End-to-end Play rehearsal

The real Dungeon live fixture also returned:

- `[Wolf Dungeon Live] ENCOUNTER_LOOT_CORPSE_PASS`
- `[Wolf Dungeon Live] LEVEL3_THICK_HIDE_PASS`
- `[Wolf Dungeon Live] CLIENT_ONCE_ONLY_HIDE_PASS`
- `[Wolf Dungeon Live] VERIFIED_PLAY_MODE_PASS`

The live fixture used the actual Dungeon session/runtime, real Room 1 physical
trigger, actual heterogeneous encounter, real client ProximityPrompt
interaction and authoritative profession result remote.

## Validation issue corrected

An apparent remaining executor failure was traced to an old Studio instance
that had the previous `DungeonEncounterExecutorsTest` source loaded in
memory. GitHub and the local tracked source already contained the ForestWolf
fixture update.

A uniquely named fresh v4 build proved the current source correctly and
returned the 14/14 marker above. No production executor behavior was weakened.

## What is GREEN

- a live animal-like Dungeon combat source;
- mixed humanoid + beast combat-pack execution;
- Forest Wolf server identity;
- animal-only Skinning boundary;
- normal kill/reward/loot lifecycle;
- corpse retention;
- level-3 Thick Hide supply;
- one-claim Skinning;
- contested/two-user Skinning regression;
- existing encounter progression after adding the beast.

## What remains content/presentation work

- final Forest Wolf mesh/rig/animation/AI;
- wider animal variety and bestiary presentation;
- final profession station/resource art;
- final crafting minigames and VFX;
- wider launch quest/content use of profession rewards.

The temporary wolf presentation must not be described as final creature art.

## Next development gate

Move profession systems into **launch-level quest/content integration**:

1. audit current launch quests and Dungeon reward hooks for profession-material
   and blueprint reward opportunities;
2. add optional profession-aware rewards without making a profession mandatory
   for core quest completion;
3. preserve tradeability and cross-profession pressure;
4. avoid duplicating the already-green reward/blueprint authorities;
5. continue broader level-1-to-30 quest/content coverage after the first
   profession-aware quest tranche.

Do not add more profession slots or another parallel gathering system.
