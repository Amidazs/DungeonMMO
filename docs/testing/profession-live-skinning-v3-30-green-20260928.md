# Live Dungeon Skinning acceptance evidence — v3.30
**Date:** 28 September 2026

## Scope

This record validates the first real animal-like Dungeon encounter source for
the profession economy.

## Source head

Branch:

`wip/phase-4-test-hud-integration-v1`

Accepted source/test head:

`9901108d4499fb7fa915d51039acb144d4dc94e9`

Fresh validation:

- `git diff --check`: PASS;
- `rojo build default.project.json`: PASS.

## Mixed Room 1 pack

Temple Room 1 now resolves exactly two combat-pack entries:

- Marauder x1;
- Wolf x1.

The Wolf archetype routes through the registered `ForestWolf` factory.

The generic combat-pack executor remains responsible for both entries.

## Forest Wolf contract

Focused factory evidence confirms the spawned model carries the explicit
Skinning identity required by the existing eligibility service while retaining
normal Dungeon enemy contracts.

Current presentation is a temporary animal-like placeholder built on the shared
combat skeleton. This evidence does not approve final art or animation.

## Focused backend package

Fresh current-head Studio Play returned:

`VERIFIED_LIVE_SKINNING_BACKEND_FOCUS_PASS 14`

Included suites:

1. DungeonEncounterSpawnCatalogTest;
2. DungeonWolfFactoryTest;
3. DungeonEnemyCleanupTest;
4. CombatPackEncounterExecutorTest;
5. DungeonEncounterExecutionBootstrapTest;
6. DungeonEncounterExecutorsTest;
7. DungeonEnemyFactoryRegistryTest;
8. Depth1EncounterBindingsTest;
9. Depth1EncounterFlowTest;
10. DungeonEncounterFlowTest;
11. SkinningEligibilityTest;
12. CorpseSkinningRuntimeTest;
13. CorpseSkinningTwoUserTest;
14. ProfessionGatherTierTest.

## Live end-to-end rehearsal

The unpublished live fixture exercised the actual Dungeon runtime.

Accepted markers:

- `[Wolf Dungeon Live] ENCOUNTER_LOOT_CORPSE_PASS`
- `[Wolf Dungeon Live] LEVEL3_THICK_HIDE_PASS`
- `[Wolf Dungeon Live] CLIENT_ONCE_ONLY_HIDE_PASS`
- `[Wolf Dungeon Live] VERIFIED_PLAY_MODE_PASS`

Observed lifecycle:

1. Studio player admitted to the real Dungeon session.
2. Physical Temple Room 1 trigger activated the encounter.
3. `Room1_Wolf_1` spawned with Forest Wolf / Beast credentials.
4. `Room1_Marauder_1` spawned without animal credentials.
5. Living wolf exposed no Skinning prompt.
6. Wolf and Marauder were defeated.
7. Normal rewards completed and Room 2 unlocked.
8. Wolf remained as a retired, looted corpse with Skinning prompt.
9. Level-3 Skinning interaction granted exactly one `thick_hide`.
10. Corpse recorded `SkinningClaimed = true`.
11. A second client attempt found the prompt depleted and granted nothing.

## Regression diagnosis

One focused run initially showed
`DungeonEncounterExecutorsTest: Known pack must validate`.

The executor itself returned `ok=true` in isolation. Inspection showed the
open Studio place still contained the old test fixture that knew only the
Marauder factory even though GitHub/local tracked source already knew
`ForestWolf`.

A uniquely named fresh current-head build removed that stale in-memory copy.
The complete 14-suite package then passed.

No production validation rule was loosened.

## Non-claims

This checkpoint does not claim final wolf visuals, dedicated quadruped combat
animation/AI, complete bestiary animal variety, final profession presentation,
production publication or main-branch merge.
