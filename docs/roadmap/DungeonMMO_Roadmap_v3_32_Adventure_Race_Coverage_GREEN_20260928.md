# DungeonMMO Roadmap v3.32
## Creation-enabled Adventure coverage GREEN
**Date:** 28 September 2026

This checkpoint closes the launch Adventure eligibility gap found after v3.31.

## Creation-enabled launch roster

Fresh character creation currently permits:

- Human Fighter / Mage;
- Elf Fighter / Mage;
- Dark Elf Fighter.

Orc and Dwarf remain deliberately creation-disabled.

The three launch Adventures now use one shared race set containing Human, Elf
and Dark Elf. Orc and Dwarf remain excluded until their creation gates are
intentionally enabled.

## Dark Elf Adventure chain

A real QuestService integration now proves one Dark Elf Fighter can:

1. start and claim Worldroot Relic after a Temple clear;
2. start and claim Mine Echoes after an Abandoned Mine clear;
3. start Provisioning;
4. record one fresh Temple and Mine clear;
5. claim 75 Gold plus 2 Deep Iron Ore, 2 Moonpetal and 2 Thick Hide;
6. complete the chain without selecting any profession;
7. save/reload with all three completions and reward materials intact.

## Regression protection

AdventureEligibilityTest derives the currently enabled race roster directly
from RaceDefinitions and requires every Adventure to include each enabled
race while rejecting disabled Orc/Dwarf pre-release access.

Fresh Play from source head
`0073a4d3051b380b510907b87502bca0e66f9f42` returned:

- `VERIFIED_PROFESSION_QUEST_CONTENT_FOCUS_PASS 10`;
- Adventure Eligibility: **17 assertions**;
- Dark Elf Adventure: **18 assertions**;
- Quest Definitions: **31 assertions**;
- Quest Service: **48 assertions**;
- Profession Quest Integration: **27 assertions**;
- Profession Economy Topology: **113 assertions**;
- Profession Blueprint Acquisition: **33 assertions**;
- Profession Gather Tier: **21 assertions**;
- Base Environment: **10 assertions**;
- Base Adventure Board: **6 assertions**.

## Next development gate

Continue expanding launch-level Adventure/side-quest content using only
trusted gameplay signals that exist in released content.

Current generic Adventure progression receives authoritative DungeonClear
events. Higher Depths 2-4 remain runtime-release-disabled, so do not publish
player-facing quests that require them yet.

If richer objectives are needed, add one reviewed server-owned event boundary
first rather than inventing client-authored progress.
