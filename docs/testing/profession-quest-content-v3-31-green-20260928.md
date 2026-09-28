# Profession-aware Adventure content acceptance — v3.31
**Date:** 28 September 2026

## Source head

Validation source before documentation:

`fcaaa5549fa2881271bd7aca86a0fbac00e3fb3f`

Fresh builds:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS.

## Focused backend/content package

Final current-head marker:

`VERIFIED_PROFESSION_QUEST_CONTENT_FOCUS_PASS 8`

Included suites:

- QuestDefinitionsTest;
- QuestServiceTest;
- ProfessionQuestRewardIntegrationTest;
- ProfessionLaunchEconomyTopologyTest;
- ProfessionBlueprintAcquisitionIntegrationTest;
- ProfessionGatherTierTest;
- BaseEnvironmentContractTest;
- BaseQuestBoardContractTest.

Notable observed results in the same Play session:

- Quest Definition Tests: **31 assertions**;
- Quest Service Tests: **48 assertions**;
- Profession Quest Integration: **27 assertions**;
- Profession Economy Topology: **113 assertions**;
- Profession Blueprint Acquisition: **33 assertions**;
- Profession Gather Tier: **21 assertions**;
- Base Environment Contract: **10 assertions**;
- Base Adventure Board: **6 assertions**.

## Provisioning reward integration

The real-service integration proves:

- quest player has no gathering or crafting profession selected;
- all story prerequisites complete in order;
- one fresh Temple and one fresh Mine clear ready Provisioning;
- claim grants 75 Gold and three advanced material stacks;
- the quest player owns 2 Deep Iron Ore, 2 Moonpetal and 2 Thick Hide;
- Deep Iron can be listed through MarketService;
- a Blacksmith who chose Herbalism instead of Mining can buy that ore;
- the purchased ore enters the normal crafting economy.

## Current-head client renderer

The latest QuestBoard card-rendering refactor was exercised through the real
client LocalScript using server QuestSnapshot events.

Initial state marker:

`VERIFIED_ADVENTURE_BOARD_V2_INITIAL_RENDER_PASS`

Observed:

- Worldroot Relic: Start Quest;
- Mine Echoes: Locked;
- Expedition Provisioning: Locked;
- correct reward text for all three cards.

Ready state marker:

`VERIFIED_ADVENTURE_BOARD_V2_READY_RENDER_PASS`

Observed Provisioning card:

- Action = Claim Reward;
- Clear the Temple 1/1;
- Clear the Abandoned Mine 1/1;
- reward = 75 Gold + 2 Deep Iron Ore + 2 Moonpetal + 2 Thick Hide.

Context marker:

`VERIFIED_ADVENTURE_BOARD_V2_DISTANCE_CLOSE_PASS`

The panel was made visible under the real LocalScript and the client character
was moved **40.0000076 studs** from the board. The real heartbeat/context logic
closed the window.

The physical prompt itself is independently covered by the six-assertion
BaseQuestBoardContractTest. A previous live v1 rehearsal also completed a real
server quest start before the presentation-only card refactor.

## Non-claims

This evidence does not claim:

- every launch race/class is already eligible for the Adventure chain;
- final quest writing/NPC/board presentation;
- complete level-1-to-30 side-quest coverage;
- mandatory profession quests;
- production publish or main-branch merge.
