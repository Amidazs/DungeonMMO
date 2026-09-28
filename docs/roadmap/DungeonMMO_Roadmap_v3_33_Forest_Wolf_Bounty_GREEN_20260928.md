# DungeonMMO Roadmap v3.33
## Optional Forest Wolf bounty GREEN
**Date:** 28 September 2026

This checkpoint expands the creation-enabled launch Adventure content after
v3.32 without adding another mandatory story gate.

## Accepted Adventure shape

The launch Adventure catalogue now contains four quests:

1. **A Relic Beneath the World Tree** — Temple clear;
2. **Wolves at the Worldroot** — optional Forest Wolf bounty;
3. **Echoes from the Abandoned Mine** — Mine clear;
4. **Provisions for the Next Expedition** — fresh Temple + Mine clears.

The Forest Wolf bounty requires Worldroot Relic completion, but Mine Echoes
still depends only on Worldroot Relic. The bounty is therefore optional and
cannot block the main launch Adventure chain.

## Forest Wolf objective

The bounty requires:

- objective type: `EnemyDefeat`;
- target: `forest_wolf`;
- required count: **2**;
- reward: **40 Gold only**.

It deliberately grants no profession material or item reward. This keeps the
live Forest Wolf useful outside Skinning while avoiding extra profession supply
inflation.

## Trusted Dungeon event boundary

Dungeon `EncounterService` now emits one server-authored
`EnemyDefeat` quest event only after the monster reward transaction succeeds.

Eligible recipients are the same active/connected encounter members who are
eligible for the monster reward. Spectators and disconnected members do not
receive quest credit.

Event IDs are derived from the stable session/enemy/life reward transaction and
therefore remain idempotent across duplicate death callbacks.

## Species identity fix

Forest Wolves intentionally remain outside Bestiary progress during their
temporary placeholder phase:

- `BestiaryCreatureId = nil`;
- `CreatureSpeciesId = "forest_wolf"`.

The first bounty bridge version looked only at Bestiary/boss identity. Fresh
validation exposed that this would make a real wolf kill invisible to the
quest system.

The accepted quest-target resolution is now:

1. `BestiaryCreatureId`, when authored;
2. `CreatureSpeciesId`, for authored animal identity;
3. `BossId`, when authored.

This keeps Adventure quest identity separate from Bestiary enrollment.

## Gold-only reward support

`QuestService` now supports an Adventure reward that contains Gold without an
item payload.

The claim remains atomic and one-time. Forest Wolf bounty completion grants
exactly **40 Gold**, an empty item-grant list, and cannot pay twice.

## Race/content coverage

The bounty uses the same launch Adventure eligibility as the accepted chain:

- Human: enabled;
- Elf: enabled;
- Dark Elf: enabled;
- Orc: creation-disabled;
- Dwarf: creation-disabled.

A real Dark Elf Fighter completes the optional bounty between Worldroot and
Mine Echoes in the focused integration run, proving the side quest does not
interrupt the existing story progression.

## Fresh Studio acceptance

Fresh Rojo builds:

- Base: PASS;
- Dungeon: PASS;
- `git diff --check`: PASS.

Base focused marker:

`VERIFIED_FOREST_WOLF_BOUNTY_BASE_PASS 5`

Accepted Base results:

- Quest Definitions: **34 assertions**;
- Adventure Eligibility: **21 assertions**;
- Quest Service: **59 assertions**;
- Dark Elf Adventure: **22 assertions**;
- Base Adventure Board: **6 assertions**.

Dungeon focused marker:

`VERIFIED_FOREST_WOLF_BOUNTY_DUNGEON_PASS 3`

Accepted Dungeon results:

- Wolf Factory: **11 assertions**;
- Encounter Service: **29 assertions**;
- Forest Wolf Bounty Dungeon Integration: **14 assertions**.

The final integration uses real `EncounterService` and real `QuestService`.
Two rewarded species-only Forest Wolf deaths advance an active bounty and
unlock the exact 40-Gold reward. Duplicate death callbacks cannot duplicate
monster reward or quest credit.

## What is GREEN

- optional Wolf bounty definition and ordering;
- creation-enabled race eligibility;
- `EnemyDefeat` objective matching;
- Gold-only Adventure reward;
- physical Adventure Board compatibility;
- server-authored encounter death -> quest event bridge;
- species-only Forest Wolf quest identity;
- spectator/disconnect exclusion through encounter eligibility;
- duplicate death idempotence;
- real Dungeon encounter -> real QuestService -> claim integration.

## What remains content work

- more launch-level side quests and story beats;
- broader enemy/objective variety using trusted server events;
- final Forest Wolf mesh/animation/AI presentation;
- richer quest dialogue/presentation;
- final balancing of Gold and progression cadence with real players;
- production publish/main merge.

## Next development gate

Continue **launch-level quest/content expansion**.

Prefer objectives that reuse already trusted server-owned gameplay signals.
When a genuinely new objective type is needed, add and validate its server
event boundary before authoring quests around it.

Keep professions optional for core Adventure completion. Profession materials
can continue to appear as tradeable rewards, but no launch story quest should
require ownership of a specific profession.
