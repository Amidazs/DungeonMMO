# DungeonMMO Roadmap v2.81 — C4 NPC Source Boundary

Date: 25 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.80](
DungeonMMO_Roadmap_v2_80_C4_Live_Skill_Execution_20260925.md).

## Goal

Give current standard Dungeon enemies reviewed Chronicle 4 combat-stat
boundaries so player-to-NPC source formulas can be validated before any live
combat dispatch is switched.

## Pinned source

Source commit:

`07f8536384e799f128d44198dd7ab23519660eea`.

Reviewed source files include:

- `L2jAdmins_Data/sql/game/npc.sql`;
- `L2jAdmins_Data/sql/game/npc_skills.sql`;
- `NpcData.java`;
- common `L2Character` stat functions;
- the C4 physical/magical/accuracy/evasion/critical calculator functions.

## Creative-to-source mapping

Only internal source IDs are stored. Source NPC names are deliberately not
exposed to players.

Current mappings:

| Creative archetype | Internal source NPC ID | Level | C4 race |
| --- | ---: | ---: | --- |
| Marauder | 325 | 5 | NONE |
| Wolf | 525 | 4 | ANIMAL |

The creative names remain `Marauder` and `Wolf`.

The Wolf source row carries source race skill 4293, which the reviewed C4
`NpcData` maps to `ANIMAL`. The Marauder source row's race skill does not
map to a special race in that source loader, so it remains `NONE`.

## Exact NPC derivation

`C4NpcSourceReference` now reproduces the reviewed ordinary-NPC calculator
path for:

- P.Atk;
- P.Def;
- M.Atk;
- M.Def;
- P.Atk speed;
- M.Atk speed;
- run/walk speed;
- Accuracy;
- Evasion;
- physical critical rate;
- magical critical rate;
- Max HP;
- Max MP;
- Max CP.

The resulting current boundaries include:

### Marauder

- HP 126;
- MP 85;
- P.Atk 13;
- P.Def 48;
- M.Atk 4;
- M.Def 39;
- Accuracy 38;
- Evasion 38;
- physical critical 418.

### Wolf

- HP 107;
- MP 75;
- P.Atk 12;
- P.Def 46;
- M.Atk 4;
- M.Def 37;
- Accuracy 37;
- Evasion 37;
- physical critical 418;
- source race `ANIMAL`.

## Server ownership

Combat-pack spawning now stamps
`DungeonEnemyArchetypeId` on each spawned server enemy.

`C4NpcSourceBoundaryService` accepts only a living Workspace Model carrying
that server-owned archetype identity. Display names and arbitrary client stat
tables are not used to select source stats.

Unsupported enemy archetypes fail closed.

## Source combat integration

`C4SourceCombatCalculationService` now accepts either:

- an authenticated player UserId; or
- a validated detached NPC source boundary.

Player-to-NPC source combat now supports:

- ordinary hit/evasion;
- ordinary physical damage;
- PDAM;
- MDAM;
- target weapon vulnerability;
- elemental vulnerability;
- exact C4 NPC physical race modifiers.

PvP modifiers are exactly neutral for NPC targets because the reviewed source
applies those only when both attacker and target are playable.

The reviewed UNDEAD fall-through into BEAST is preserved: an undead target
would consume both `PHYSICAL_ATK_UNDEAD` and
`PHYSICAL_ATK_MONSTERS`.

Player source candidates now seed neutral C4 NPC-race attack stats so source
passives/effects can modify those calculator values later without inventing
new balancing constants.

## Fresh acceptance

Candidate:

`c86a771ac5e67ea7949761340cbc60ab65a9c8d9`.

Fresh unpublished Rojo:

- Base: PASS;
- Dungeon: PASS;
- git diff validation: PASS.

Focused Studio:

- Base: **18/18 PASS**;
- Dungeon: **20/20 PASS**;
- NPC source boundary: **13 assertions PASS**;
- source combat calculation: **38 assertions PASS**;
- live executor regression: **13 assertions PASS**;
- Dungeon resource cutover: **7 assertions PASS**.

Targeted Dungeon spawn identity:

- CombatPackEncounterExecutor: **16 assertions PASS**;
- spawned archetype identity probe: PASS.

## Safety boundary

This milestone does not switch current Dungeon damage dispatch.

Bosses, optional bosses and world bosses are not silently assigned a standard
NPC source record. They remain fail-closed until individually reviewed and
mapped.

No `main` merge, Roblox publish, production persistence mutation, client
damage authority or animation edit occurred.

## Next backend implementation

Extend the disabled live executor to player-to-NPC targets.

That layer must:

1. resolve the live NPC boundary from the actual server-spawned Model;
2. keep current server hitbox/projectile target validation;
3. apply accepted C4 damage to the real NPC Humanoid;
4. preserve existing damage callbacks used by threat, quest combat ledgers and
   contribution tracking;
5. remain disabled and reversible;
6. avoid changing normal gameplay until targeted adapter acceptance is green.
