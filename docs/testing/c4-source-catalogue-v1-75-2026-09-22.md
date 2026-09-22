# C4 v1.75 — real first-tier healing and Scout defensive combat

Date: 22 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Previous baseline: `docs/testing/c4-base-first-transfer-coverage-2026-09-22.md`

## Functional backend added in this increment

- Base Mystic `MysticBattleHeal`: all three C4 first-tier level-14
  healing ranks for both Human and Elf. Purchase requires the prior
  third `MysticHealingPrayer` rank; real mana, wand, cooldown,
  target availability and server health delivery use the accepted
  MageHeal combat path, with increasing healing each purchased rank.
- First-transfer `ScoutEvasion` at level 24 and
  `ScoutRunningEvasion` at level 28. Purchased ranks add
  three percent standing evasion plus 2.5 percent **only when
  the server-measured Humanoid is moving**. This is a chance to
  avoid direct enemy melee before health/ward damage, not immunity
  to enemy area or magic skills.
- `ScoutEvasiveFocus`: an actual purchased level-28 Human/Elf
  Ranger/Rogue skill that spends stamina, has a cooldown, and
  applies a server-owned, non-stacking 14-percent temporary
  melee-evasion status lasting seven seconds. It is not an
  always-on passive from simply knowing the skill.
- `ElvenScoutGuard`: an Elf-only level-20 Ranger/Rogue
  first-transfer defence buff. The authenticated cast spends
  mana, has a cooldown, and applies an actual server-owned
  seven-percent physical-hit mitigation status for 12 seconds.
  Human characters cannot train it.
- The existing Scout inventory now records those real effects,
  and its functional audit checks the active statuses' type,
  magnitude, cooldown and duration instead of pretending they
  are damage/healing abilities. The combined catalogue audit
  continues to fail closed while source ranks or class paths
  remain missing.

## Latest exact scoped source coverage

| Original C4 source class | Functional analogue ranks | Total source ranks | Missing |
| --- | ---: | ---: | ---: |
| Human Fighter | 36 | 39 | 3 |
| Elven Fighter | 41 | 43 | 2 |
| Human Mystic | 36 | 44 | 8 |
| Elven Mystic | 34 | 42 | 8 |
| Human Rogue first transfer | 78 | 99 | 21 |
| Elven Scout first transfer | 106 | 129 | 23 |
| **Six enumerated classes** | **331** | **396** | **65** |

This is the count of source-to-functional DungeonMMO **analogues**,
not exact Chronicle 4 gameplay fidelity, original class-tree
availability or a complete skills catalogue. Seven additional
original Human/Elf first-transfer class skill inventories remain
unmapped and **0/9 first-transfer paths are complete**. The
source-of-truth is `C4CatalogueCoverage.report()`, whose
`Completed` value remains false.

Current missing source rank families are printed by
`C4BaseImplementationAudit.audit(race_id, class_id)` and
`C4ScoutSkillInventory.audit(race_id).MissingFamilies`.

## Observed focused and unpublished Play tests

- New Battle Heal source ranks: **28 assertions PASS**.
- Scout passive evasion and existing progression:
  **286 assertions PASS**.
- Scout mapped rank inventory: **1,073 assertions PASS**,
  Human 78/99, Elf 106/129.
- Active Scout dodge and Elf guard status/class/expiry:
  **24 assertions PASS**.
- Latest source base audit: **57 assertions PASS**.
- Unified strict completion audit: **7 assertions PASS**,
  `Base=147/168, Scout=184/228, class paths=0/9,
  unmapped=7, overall complete=false`.
- Both Base and Dungeon TEMP Rojo compositions built successfully
  after the incremental C4 implementation.
- The disposable unpublished Dungeon Play client passed the
  existing 16 genuine skill effects plus **two new authenticated
  client hotbar buff casts**, printing
  `ScoutEvasiveFocus LIVE_SERVER_STATUS_PASS`,
  `ElvenScoutGuard LIVE_SERVER_STATUS_PASS`,
  `ALL_EIGHTEEN_C4_SKILL_EFFECTS_PASS` and
  `VERIFIED_PLAY_MODE_PASS`. This also exercised Battle Heal
  and the existing genuine Life Drain hit-to-self-heal effect.
  Only synthetic player skill ownership/loadout fixtures were used,
  not a normal persisted player buying these skills through the GUI.

Latest local TEMP logs (not uploaded):
`%TEMP%\DungeonMMO_C4_BattleHeal_Current.log`;
`%TEMP%\DungeonMMO_C4_StatusFixed.log`;
`%TEMP%\DungeonMMO_C4_InventoryFixed.log`;
`%TEMP%\DungeonMMO_C4_CoverageFixed.log`;
`%TEMP%\DungeonMMO_C4_Base_Audit_Latest.log`;
`%TEMP%\DungeonMMO_C4_ActiveStatus_Live.log`.

## Completion requirements still open

Finish the remaining 65 source rank entries across the six current
inventories as working gameplay mechanics: common item crafting,
recipe reading, recovery, party healing, attack-speed/physical debuffs,
poison and wound cleansing, common item creation, accuracy/critical
toggles with their real resource upkeep, lockpicking and other world
interactions. More importantly, source-inventory and implement the
SEVEN still missing distinct original C4 first-transfer classes:
Human Warrior, Human Knight, Human Wizard, Human Cleric, Elven
Knight, Elven Wizard and Elven Oracle, along with authentic
race/advancement-quest ownership and trainer/level/skill prerequisites.
The current game's Ranger/Rogue starter structure is an original
analogue, **not** source-equivalent first-transfer class selection.

Full ordinary persisted-character trainer UI, physical input,
multiplayer/published validation and milestone-wide regressions
remain open. The separate Phase2A paid-revive automated failure
remains unresolved and is not included in the focused C4 PASS.

Scripts, fixtures and documentation were edited exclusively through
GitHub. Remote Desktop was used solely to fast-forward pull,
build disposable TEMP places, run unpublished Studio tests and
inspect logs. No merge to `main`, publish, paid action or
production DataStore mutation occurred.
