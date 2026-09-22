# C4 v1.77 — real poison curse and friendly poison recovery

Date: 22 September 2026
Working branch: `wip/phase-4-test-hud-integration-v1`
Previous **backend** milestone:
[conditional recovery v1.76](../roadmap/DungeonMMO_Roadmap_v1_76_C4_Recovery_20260922.md).
The newer, separate [humanoid animation production roadmap](
../roadmap/DungeonMMO_Humanoid_Animation_Pipeline_20260922.md)
remains untouched; its rig/visual acceptance and no-manual-Blender
requirements are NOT superseded by this backend-only increment.

## Source references and exact scope

- [Human Mystic C4 class skill rows](https://l2hub.info/c4/classes/mage)
  list a level-seven Curse: Poison and Cure Poison.
- [Elven Mystic C4 rows](https://l2hub.info/c4/classes/elven_mage)
  list level-seven Cure Poison.
- [Elven Scout C4 rows](https://l2hub.info/c4/classes/elven_scout)
  list self-only Poison Recovery at the first-transfer levels.

The skills below are **DungeonMMO functional analogues**, not a
claim that original C4 poison probabilities, MP costs, tick powers,
class-tree topology or client effects have been copied exactly.

## Implemented and source-gated backend

- Human Mystic `MysticPoisonCurse`: one bought level-seven rank,
  requires purchased `MysticWindBolt` rank one and an actual
  equipped wand. The real server projectile must damage a hostile
  NPC before applying three four-HP poison ticks one second apart.
- Human/Elf Mystic `MysticCurePoison`: bought level-seven,
  mana-funded, friendly aimed/self spell that can remove a real
  server-poisoned ally **even at full health**, and does not
  manufacture a healing effect or cleanse an unpoisoned player.
- Elven Ranger/Rogue `ElvenScoutPoisonRecovery`: bought
  level-24 self-only cleanse. Human Scout and other classes
  cannot buy it or redirect it to another player.
- New `PoisonStatusService` keeps its own server-only status
  records; public character attributes are indicators only.
  It supports NPC-originated player poison through an internal
  trusted server API for future boss/monster poison attacks.
  All tick damage uses accepted `DamageService` mitigation,
  Ward, combat and contribution callbacks. Reapplying does
  not stack timers; curing removes the record so pending
  delayed ticks cannot hurt a cleansed target. Attacker
  disconnect/character replacement invalidates later ticks.
  No client may select poison strength, duration, target or
  tier through a RemoteEvent.

This adds a server-side poison primitive; ordinary authored
enemy poison attack integration is a **separate unimplemented
content task**. No live boss/NPC poisoning behaviour is claimed.

## Actual focused and unpublished Play evidence

- Original Base composition and Dungeon composition built in
  disposable Rojo places. The Base-only source test was corrected
  to avoid requiring Dungeon-only combat runtime modules.
- C4 source class/rank/trainer/purchased-loadout test:
  **20 assertions PASS**.
- Updated first-tier C4 source audit: **49 assertions PASS**;
  Human Fighter 37/39, Elven Fighter 41/43,
  Human Mystic 38/44, Elven Mystic 35/42.
- Updated Scout source audit: **1,080 assertions PASS**;
  Human Rogue 81/99 and Elven Scout 108/129.
- Strict overall completion auditor: **7 assertions PASS**;
  Base=151/168, Scout=189/228, class paths=0/9,
  unmapped original first-transfer classes=7,
  `Completed=false`.
- Isolated real unpublished Play client: issued an actual
  `MysticPoisonCurse` via project `CombatInputActions`.
  A real `TrainingDummy` lost 3 initial HP and **three
  separately timed four-HP server poison ticks**, then
  the poison record expired. With real NPC-originated
  poison on a full-health player, the same client cast
  `MysticCurePoison` and `ElvenScoutPoisonRecovery`
  through the real hotbar; both cleared real server status
  and no delayed poison damage followed.
  Final log: `ALL_THREE_REAL_CLIENT_EFFECTS_PASS` and
  `VERIFIED_PLAY_MODE_PASS`.

Latest unpublished TEMP logs (not uploaded):
`%TEMP%\DungeonMMO_C4_PoisonSkills_Fixed.log`,
`%TEMP%\DungeonMMO_C4_PoisonBaseAudit.log`,
`%TEMP%\DungeonMMO_C4_PoisonScoutAudit.log`,
`%TEMP%\DungeonMMO_C4_PoisonCoverage.log`,
`%TEMP%\DungeonMMO_C4_Poison_Live.log`.

## Remaining catalogue gate

| Original C4 source inventory | Functional analogue ranks | Raw | Missing |
| --- | ---: | ---: | ---: |
| Human Fighter | 37 | 39 | 2 |
| Elven Fighter | 41 | 43 | 2 |
| Human Mystic | 38 | 44 | 6 |
| Elven Mystic | 35 | 42 | 7 |
| Human Rogue | 81 | 99 | 18 |
| Elven Scout | 108 | 129 | 21 |
| **Six inventoried classes** | **340** | **396** | **56** |

Still missing in those SIX inventoried classes: 17 starting
class rank entries (common crafting, recipe reading, party
healing and physical/attack-speed debuffs), 39 partial Scout
rank entries (toggle upkeep, lock/key interaction, crafting,
environment equipment and other Elf support). **Seven
separate original first-transfer class inventories remain
unmapped and unimplemented. No original first-transfer
class is complete (0/9).** The source-backed completion
flag remains FALSE. A data row is never accepted merely
because it has a name, a rank or a metadata-only effect.

Normal saved-player trainer GUI, authored enemy poison
attacks, fully source-equivalent advancement quests,
real multiplayer gameplay, final milestone regression
and published cloud testing remain OPEN. Separate known
Phase2A paid-revive automatic failure remains unresolved.

All code, fixtures and documentation were edited in
GitHub. The connected desktop was used only for clean
pull, temporary unpublished Rojo builds, Studio tests
and read-only log inspection. No merge into `main`,
Roblox publish, paid action or production DataStore
mutation occurred.
