# DungeonMMO roadmap v1.85 — verified Rogue/Scout ranked crafting

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`

## Roadmap precedence and existing commitments

This is the latest **C4 backend and original-class source-rank
supplement** after [v1.84 verified Accuracy](
DungeonMMO_Roadmap_v1_84_C4_Scout_Accuracy_20260923.md).
Do not supersede the separately maintained newer
humanoid/quadruped animation production roadmap.
The WoW-style **one gathering + one crafting profession
per character**, existing material trading/auction-house
restrictions and class-training progression remain mandatory.

## Completed, committed and actually tested

- [x] Implemented **three purchased first-transfer C4 Common
  Item Creation ranks per original Human Rogue and Elven Scout**.
  Source levels: **20, 28, 36**. The registered skill
  `ScoutCommonItemCreation` requires an explicitly selected
  creation career, separately purchased `C4RecipeReading`,
  and previous rank(s) before training higher ranks.
- [x] The Ranger/Rogue class skill lists and real class
  trainers teach their actual Recipe Reading and
  three-rank Common Item Creation progression; their
  source race/class/level gates apply, not an unearned
  base-class starter skill grant.
- [x] Four independently selected crafting careers each
  have three *real* material-backed tiered recipes (12 total).
  Ranked recipes use real authored inputs, output, profession
  XP, station, selected creation career and required
  purchased rank. Higher tiers need ingredients produced
  by other professions rather than adding a new
  crafting career to the character.
- [x] Server station preview, start and completion require
  the purchased rank; the atomic profile/inventory
  commit **revalidates rank and career** before materials
  are consumed. An unlearned/downgraded rank cannot be
  bypassed with an earlier prepared minigame. The
  existing station UI keeps unlearned rank recipes locked.
- [x] Original four starter-class crafting recipes, base
  progression and selected career rules remain intact;
  the new three-rank skill is separate from starter
  level-five `C4CommonItemCreation`.
- [x] Actual unpublished Studio focused test
  **5/5 PASS**, including **290** new ranked-crafting
  assertions, **1,150** source-inventory assertions,
  original starter-class C4 profession and two-career
  market regressions. Four isolated source characters
  completed all twelve recipes, traded produced materials
  through actual market escrow and consumed purchased
  ingredients in subsequent ranked crafts.
- [x] Actual **two-client unpublished Base playtest PASS**:
  real selection windows and choice persistence, Human
  Rogue/Blacksmithing rank-one client craft, attempted
  Elf Ranger/Alchemist cross-profession forgery denied,
  genuine Smith-to-Alchemist market delivery, and
  client-requested rank-two Alchemy at its own workstation
  consuming the **traded iron bar**. Source rank and
  skill purchases used the real progression service.
  The test supplied disposable Alchemy XP, silverleaf
  and character level to isolate this flow rather than
  repeat prior accepted gathering/XP playtests.
  See the [v1.85 executed Studio and gameplay record](
../testing/c4-scout-ranked-crafting-v1-85-2026-09-23.md).
- [x] All script, tests, documentation and roadmap
  changes committed **directly through GitHub**.
  Desktop access used solely for read-only status,
  clean fast-forward pulls, disposable Luau/Rojo
  checks and unpublished Studio testing. No
  `main` merge, Roblox publishing, production
  DataStore write or local source-code edit.

## Current honest C4 source audit

| Original C4 inventory | Functional / raw | Missing |
| --- | ---: | ---: |
| Human Fighter | 39 / 39 | 0 |
| Elven Fighter | 43 / 43 | 0 |
| Human Mystic | 44 / 44 | 0 |
| Elven Mystic | 42 / 42 | 0 |
| Human Rogue (partially inventoried first transfer) | 90 / 99 | 9 |
| Elven Scout (partially inventoried first transfer) | 121 / 129 | 8 |
| **Six currently inventoried classes** | **379 / 396** | **17** |

The original four starting-class inventories remain **168/168**.
The seven **other** original first-advancement class
catalogues are still unenumerated/unimplemented, outside
this 17-rank remainder. **0/9 original first-transfer
paths have been fully completed.** Source-rank mapping
does not mean all original Lineage 2 items/recipes have
been recreated.

## Remaining work and next backend priorities

- [ ] Implement **five real Lockpicking ranks each** for
  Human Rogue and Elven Scout. Dungeon/world containers
  need authored lock difficulty, server-owned proximity,
  party/instance/quest/ownership validation, one-time
  reward and replay resistance; no access to another
  player's private inventory, bank or auction house,
  or bypassing profession-locked resource nodes.
  Source level brackets: 20, 24, 28, 32, 36.
- [ ] Implement each class's source
  `EquipmentExpertise`, `LungCapacity`, and
  `FallResistance` as real gameplay/world effects;
  Human Rogue additionally requires real `Sprint`.
  Verify progression gates, actual player movement/
  environmental interactions and server-side authority.
- [ ] Enumerate and implement each of the **seven
  additional original first-advancement classes**
  with original source skills, true training level,
  required prior skill ranks/proficiency and
  class advancement quests. Reuse backend combat,
  party and profession authorities where possible.
- [ ] Review actual crafting recipe yield/XP and trade
  volumes before release; this is future economy
  balancing, not a blocker to the proven backend
  behavior or a reason to grant multiple careers.
- [ ] Preserve the separate v1.78 Mystic enemy
  weakening real-client-to-NPC acceptance gate
  and previously recorded unrelated proficiency
  regression. Avoid repeating already accepted
  aggro, wipe and paid-revive suites without relevant
  changes.

**v1.85 Rogue/Scout ranked crafting: focused Studio PASS;
two-client ranked marketplace and station gameplay PASS.
Entire original C4 catalogue: INCOMPLETE.**
