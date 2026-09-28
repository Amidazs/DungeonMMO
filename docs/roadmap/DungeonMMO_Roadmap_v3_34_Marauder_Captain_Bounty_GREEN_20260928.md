# DungeonMMO Roadmap v3.34
## Level-five Marauder Captain bounty GREEN
**Date:** 28 September 2026

This checkpoint adds the first level-paced optional Adventure on top of the
v3.33 trusted EnemyDefeat boundary.

## New optional Adventure

**The Captain's Price**

- quest ID: `MarauderCaptainBounty`;
- kind: Adventure;
- minimum level: **5**;
- prerequisite: Worldroot Relic;
- objective: defeat **1** `marauder_captain`;
- reward: **60 Gold only**.

The quest is optional. Mine Echoes continues to require only Worldroot Relic,
so level-gated side content cannot block the launch story chain.

## Released boss identity

The quest uses the real released Temple boss identity.

`MarauderCaptainFactory` creates:

- `BossId = "MarauderCaptain"`;
- `BestiaryCreatureId = "marauder_captain"`.

EncounterService therefore emits the already-reviewed trusted
`EnemyDefeat` event after the boss reward transaction succeeds.

No new client-authored quest signal was introduced.

## Level pacing

Fresh eligibility coverage proves:

- level 4 + Worldroot complete -> Captain bounty unavailable;
- level 5 + Worldroot complete -> Captain bounty eligible;
- the existing level-1 Dark Elf Adventure chain remains fully playable;
- creation-enabled Human, Elf and Dark Elf remain included;
- creation-disabled Orc and Dwarf remain excluded.

The Base board now renders the objective as
**"Defeat the Marauder Captain"**.

## Real Dungeon integration

A focused integration uses:

- real `MarauderCaptainFactory`;
- real `EncounterService`;
- real `QuestService`;
- a launch-valid level-5 Dark Elf Fighter.

The real Captain death:

1. commits one monster reward transaction;
2. emits trusted `EnemyDefeat / marauder_captain`;
3. readies the Captain bounty;
4. allows exactly one 60-Gold claim;
5. does not duplicate reward or quest credit on a repeated death callback;
6. leaves Mine Echoes available afterward.

## Fresh acceptance

Pre-documentation code/test head:

`0e18f3c77ae37e00a571ad5592975cfe53dbe719`

Fresh local checks:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS.

Base marker:

`VERIFIED_PROFESSION_QUEST_CONTENT_FOCUS_PASS 10`

Notable Base results:

- Quest Definitions: **36 assertions**;
- Adventure Eligibility: **27 assertions**;
- Dark Elf Adventure: **23 assertions**;
- Quest Service: **59 assertions**;
- Profession Quest Integration: **27 assertions**;
- Profession Economy Topology: **113 assertions**;
- Profession Blueprint Acquisition: **33 assertions**;
- Profession Gather Tier: **21 assertions**;
- Base Environment: **10 assertions**;
- Base Adventure Board: **6 assertions**.

Dungeon marker:

`VERIFIED_LAUNCH_BOUNTY_DUNGEON_PASS 5`

Results:

- Wolf Factory: **11 assertions**;
- Marauder Captain Contract: **22 assertions**;
- Encounter Service: **29 assertions**;
- Forest Wolf Bounty Dungeon Integration: **14 assertions**;
- Marauder Captain Bounty Dungeon Integration: **13 assertions**.

## What is GREEN

- first level-gated optional Adventure;
- level-5 eligibility;
- released Marauder Captain quest identity;
- real boss death -> trusted quest event -> claim flow;
- Gold-only boss-bounty reward;
- duplicate death idempotence;
- optional-story independence;
- existing profession-aware Adventure content underneath.

## Next development gate

Continue launch-level content, but do not author a Mine-boss quest until its
quest-facing identity is audited. The Mine factory uses a distinct BossId while
shared reward metadata still carries the generic captain bestiary identity.

Next safe work:

1. audit/fix released Mine boss identity;
2. then add level-paced Mine content using the trusted EnemyDefeat boundary;
3. continue adding side/story content through the launch level range;
4. keep profession ownership optional for core progression.
