# Marauder Captain bounty acceptance evidence — v3.34
**Date:** 28 September 2026

## Source checkpoint

Branch:
`wip/phase-4-test-hud-integration-v1`

Validated pre-documentation head:
`0e18f3c77ae37e00a571ad5592975cfe53dbe719`

## Build

Fresh validation:

- `git diff --check`: PASS;
- Base build: PASS;
- Dungeon build: PASS.

## Definition and eligibility

The new Adventure is:

- ID: `MarauderCaptainBounty`;
- display: `The Captain's Price`;
- minimum level: 5;
- prerequisite: Worldroot Relic;
- objective: `EnemyDefeat / marauder_captain / 1`;
- reward: 60 Gold, no item payload.

Mine Echoes still depends only on Worldroot Relic.

Fresh Base package:

`VERIFIED_PROFESSION_QUEST_CONTENT_FOCUS_PASS 10`

Relevant results:

- Quest Definitions: 36 assertions;
- Adventure Eligibility: 27;
- Dark Elf Adventure: 23;
- Quest Service: 59;
- Base Adventure Board: 6.

A level-4 Dark Elf is rejected. A level-5 Dark Elf with Worldroot completed is
eligible. The existing level-1 story run remains green.

## Released boss factory

The integration uses the real `MarauderCaptainFactory`.

Accepted identity:

- `BossId = MarauderCaptain`;
- `BestiaryCreatureId = marauder_captain`.

Factory contract:

`[Marauder Captain Contract Tests] PASS: 22 assertions.`

## End-to-end Dungeon service integration

The test constructs a real Captain through the released factory and passes it
through real `EncounterService` with real `QuestService`.

Accepted result:

`[Marauder Captain Bounty Dungeon Integration] PASS: 13 assertions`

The one boss death readies the quest, the claim grants exactly 60 Gold and no
items, a duplicate death callback cannot duplicate reward/credit, a repeated
claim is rejected, and Mine Echoes remains startable.

## Combined Dungeon package

Marker:

`VERIFIED_LAUNCH_BOUNTY_DUNGEON_PASS 5`

Included:

- Wolf Factory: 11;
- Marauder Captain Contract: 22;
- Encounter Service: 29;
- Forest Wolf Bounty integration: 14;
- Marauder Captain Bounty integration: 13.

## Non-claims

This checkpoint does not claim final quest dialogue, final boss presentation,
complete launch-level quest density, a corrected Mine boss quest identity,
production publish, or main-branch merge.
