# C4 NPC Source Boundary v2.81 — Acceptance

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.

## Result

**GREEN — reviewed standard-NPC boundaries and player-to-NPC formulas passed.**

## Candidate

`c86a771ac5e67ea7949761340cbc60ab65a9c8d9`.

## Evidence

- Base Rojo: PASS;
- Dungeon Rojo: PASS;
- git diff validation: PASS;
- Base focused Studio: **18/18 PASS**;
- Dungeon focused Studio: **20/20 PASS**;
- NPC source boundary: **13 assertions PASS**;
- source combat calculation: **38 assertions PASS**;
- source combat executor regression: **13 assertions PASS**;
- Dungeon resource cutover: **7 assertions PASS**;
- CombatPackEncounterExecutor targeted test: **16 assertions PASS**.

## Accepted mappings

- creative `Marauder` -> internal source NPC 325, level 5, race NONE;
- creative `Wolf` -> internal source NPC 525, level 4, race ANIMAL.

Source NPC names are not exposed through the creative runtime boundary.

## Accepted formula behaviour

- NPC Evasion participates in ordinary source hit chance;
- NPC P.Def participates in ordinary and PDAM damage;
- NPC M.Def and elemental vulnerability participate in MDAM;
- player PvP damage multipliers are neutral against NPCs;
- physical NPC race modifiers use the reviewed source switch semantics;
- Wolf uses `PHYSICAL_ATK_ANIMALS`;
- malformed/forged NPC source provenance fails closed.

## Server-world identity

Combat-pack enemies now retain a server-stamped
`DungeonEnemyArchetypeId`. The dedicated boundary service requires a living
Workspace Model and a reviewed archetype mapping.

## Safety boundary

Current CombatService damage remains unchanged. No standard source record is
guessed for bosses or unmapped archetypes.

No publish, production save mutation, `main` merge or animation edit
occurred.
