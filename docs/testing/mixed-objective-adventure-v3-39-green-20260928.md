# v3.39 Mixed-Objective Adventure — Test Evidence
**Date:** 28 September 2026

## Scope

Validation for the level-12 **Follow the Fracture** Adventure and its regression
surface.

Quest contract:

- ID: `FractureTrail`;
- prerequisite: `RuinSurvey`;
- minimum level: 12;
- Temple Room-2 `CheckpointReached`;
- Abandoned Mine `DungeonClear`;
- reward: 90 Gold + 2 Warding Essence.

## Source head tested

`8481e6639019c1fb7e2cfb8ad4d5c8b999ba9fb1`

## Static/build checks

- `git diff --check 9210c29a..HEAD`: PASS.
- `rojo build base.project.json`: PASS.
- `rojo build default.project.json`: PASS.

Generated unpublished test places:

- `_tmp_fracture_trail_base_v1.rbxlx`;
- `_tmp_fracture_trail_dungeon_v1.rbxlx`.

## Base regression

Fresh unpublished Base Play returned:

`VERIFIED_PROFESSION_QUEST_CONTENT_FOCUS_PASS 10`

Included suites:

1. QuestDefinitionsTest;
2. AdventureEligibilityTest;
3. DarkElfAdventureIntegrationTest;
4. QuestServiceTest;
5. ProfessionQuestRewardIntegrationTest;
6. ProfessionLaunchEconomyTopologyTest;
7. ProfessionBlueprintAcquisitionIntegrationTest;
8. ProfessionGatherTierTest;
9. BaseEnvironmentContractTest;
10. BaseQuestBoardContractTest.

Result: **10/10 PASS**.

## Dungeon regression

Fresh unpublished Dungeon Play returned:

`VERIFIED_CHECKPOINT_ADVENTURE_FOCUS_PASS 5`

Included suites:

1. CheckpointServiceTest;
2. CompletionQuestBridgeTest;
3. DungeonCheckpointQuestBridgeTest;
4. RuinSurveyCheckpointIntegrationTest;
5. FractureTrailMixedIntegrationTest.

Result: **5/5 PASS**.

## Fracture Trail integration coverage

The focused integration verifies:

- eligible level-12 character can start after Ruin Survey;
- trusted Mine clear progresses only the Mine objective;
- Mine clear alone does not complete the quest;
- trusted Temple Room-2 checkpoint progresses the exploration objective;
- both objectives together make the quest ready;
- duplicate checkpoint publication does not over-progress;
- replayed dungeon completion remains already-applied/idempotent;
- claim returns exactly 90 Gold and one item grant;
- inventory receives exactly 2 Warding Essence;
- no profession selection is required;
- second claim is rejected as already completed;
- save succeeds;
- reload retains completion, Gold and item reward.

## Acceptance

**GREEN.**

The launch Adventure catalogue now contains a proven mixed-objective quest using
two already trusted server event boundaries. No new client-trusted event type
was added.
