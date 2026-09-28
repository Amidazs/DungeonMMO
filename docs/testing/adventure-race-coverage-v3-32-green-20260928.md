# Creation-enabled Adventure coverage evidence — v3.32
**Date:** 28 September 2026

## Source and build

Accepted source head before documentation:

`0073a4d3051b380b510907b87502bca0e66f9f42`

Fresh validation:

- `git diff --check`: PASS;
- Base Rojo build: PASS;
- Dungeon Rojo build: PASS.

## Focus package

Final marker:

`VERIFIED_PROFESSION_QUEST_CONTENT_FOCUS_PASS 10`

New focused results:

- `[Adventure Eligibility] PASS: 17 assertions`
- `[Dark Elf Adventure] PASS: 18 assertions`

## Eligibility contract

RaceDefinitions currently marks Human, Elf and Dark Elf as creation-enabled.
Orc and Dwarf explicitly remain disabled.

Every launch Adventure now includes the enabled three-race set. The test
fails if an enabled race is missing or if Orc/Dwarf are accidentally exposed
before their creation gates are opened.

## Real-service Dark Elf proof

The Dark Elf integration uses real ProfileService, QuestService and
InventoryService with a complete Dark Elf Fighter identity.

The full chain is completed in order and the Provisioning reward is checked
after persistence/reload.

No profession slot is selected or required.

## Non-claims

This does not enable Orc or Dwarf creation, release higher dungeon Depths,
or claim complete level-1-to-30 quest coverage.
