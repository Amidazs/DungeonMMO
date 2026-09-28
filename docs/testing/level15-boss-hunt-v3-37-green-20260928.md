# Level-fifteen dual-boss Adventure acceptance — v3.37
**Date:** 28 September 2026

## Source checkpoint

Branch:
`wip/phase-4-test-hud-integration-v1`

Validated pre-documentation head:
`b404fb12194aae2e2ff330d1ce0df0a46379f1da`

## Definition

Accepted Adventure:

- ID: `DungeonBossHunt`;
- display: `Break the Chain`;
- minimum level: 15;
- prerequisite: `MineEchoes`;
- objective 1: `EnemyDefeat / marauder_captain / 1`;
- objective 2: `EnemyDefeat / corrupted_foreman / 1`;
- reward: 120 Gold, no items.

## Build

Fresh validation:

- `git diff --check`: PASS;
- Base build: PASS;
- Dungeon build: PASS.

## Base/content package

Marker:

`VERIFIED_PROFESSION_QUEST_CONTENT_FOCUS_PASS 10`

Updated definition/eligibility coverage proves level 14 is rejected and level
15 with Mine Echoes completed is accepted.

## Real cross-dungeon integration

`DungeonBossHuntIntegrationTest` uses:

- real `MarauderCaptainFactory`;
- real `BossEncounterExecutor`;
- real `MineForemanFactory`;
- real `EncounterService`;
- real `QuestService`.

The Captain defeat progresses only the Captain objective. A claim at that
point is rejected with `QuestNotReady`.

The Foreman then spawns through the executor with
`BestiaryCreatureId = corrupted_foreman`; its trusted death completes the
second objective and unlocks the exact 120-Gold reward.

Exactly two monster reward transactions occur: one for each physical boss.

## Combined Dungeon package

Marker:

`VERIFIED_LAUNCH_BOUNTY_DUNGEON_PASS 7`

Included:

- DungeonWolfFactoryTest;
- MarauderCaptainContractTest;
- EncounterServiceTest;
- ForestWolfBountyDungeonIntegrationTest;
- MarauderCaptainBountyDungeonIntegrationTest;
- CorruptedForemanBountyDungeonIntegrationTest;
- DungeonBossHuntIntegrationTest.

## Non-claims

This checkpoint does not claim complete level-1-to-30 quest density, new quest
event types, final boss/monster presentation, released Depths 2-4, production
publish or a main-branch merge.
