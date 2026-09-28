# Corrupted Foreman bounty acceptance evidence — v3.36
**Date:** 28 September 2026

## Source checkpoint

Branch:
`wip/phase-4-test-hud-integration-v1`

Validated pre-documentation head:
`cc32bc0f4f1bb88314948e491a35f4e7c8da50ae`

## Definition

Accepted Adventure:

- ID: `CorruptedForemanBounty`;
- display: `The Foreman's Reckoning`;
- minimum level: **10**;
- prerequisite: `MineEchoes`;
- objective: `EnemyDefeat / corrupted_foreman / 1`;
- reward: **80 Gold**, no item payload.

Expedition Provisioning still depends only on Mine Echoes.

## Build

Fresh validation:

- `git diff --check`: PASS;
- Base build: PASS;
- Dungeon build: PASS.

## Base/content package

Marker:

`VERIFIED_PROFESSION_QUEST_CONTENT_FOCUS_PASS 10`

This includes updated quest definitions, Adventure eligibility, Dark Elf
launch integration, QuestService, profession-aware rewards, economy topology,
blueprint acquisition, gather tiers, Base environment and physical Adventure
Board contracts.

The new eligibility checks reject level 9, reject level 10 without Mine Echoes,
and accept level 10 after Mine Echoes.

## Real Mine boss integration

`CorruptedForemanBountyDungeonIntegrationTest` constructs the boss through
the real `BossEncounterExecutor` using the real `MineForemanFactory`.

The spawned model is required to expose:

- `BossId = CorruptedForeman`;
- `BestiaryCreatureId = corrupted_foreman`.

The model then runs through real EncounterService and QuestService.

Accepted behavior:

- one real Foreman death readies the bounty;
- claim grants exactly 80 Gold and no items;
- Gold commits to the authoritative character;
- one monster reward transaction is recorded;
- duplicate death cannot duplicate reward or quest credit;
- repeated claim is rejected;
- Expedition Provisioning remains startable.

## Combined Dungeon package

Marker:

`VERIFIED_LAUNCH_BOUNTY_DUNGEON_PASS 6`

Included:

- DungeonWolfFactoryTest;
- MarauderCaptainContractTest;
- EncounterServiceTest;
- ForestWolfBountyDungeonIntegrationTest;
- MarauderCaptainBountyDungeonIntegrationTest;
- CorruptedForemanBountyDungeonIntegrationTest.

## Non-claims

This checkpoint does not claim final Foreman presentation, final quest
dialogue, complete level-1-to-30 quest density, released Depths 2-4, production
publish or a main-branch merge.
