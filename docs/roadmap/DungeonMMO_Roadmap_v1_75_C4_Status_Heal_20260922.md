# DungeonMMO roadmap v1.75 — functional C4 Scout combat and first-tier healing

Date: 22 September 2026
Working branch: `wip/phase-4-test-hud-integration-v1`
[Exact source inventory and real Studio evidence](../testing/c4-source-catalogue-v1-75-2026-09-22.md)

## This increment — implemented, committed and focused tested

- [x] New level-14 three-rank `MysticBattleHeal` in both
  Human and Elven starting Mage source inventories, genuine
  bought Healing Prayer prerequisite, real mana/wand/friendly
  target/executor/health effects.
- [x] Scout source levels 24/28 bought passive evasion and
  moving-only evasion; actual server direct NPC melee resolution.
- [x] Source level-28 purchased stamina/cooldown/timed
  `ScoutEvasiveFocus` and Elf-only level-20 mana/cooldown/timed
  `ElvenScoutGuard`, registered in both class trainers with
  race and level gates; actual authoritative statuses affect
  real melee dodge/physical-hit mitigation.
- [x] Source six-inventory scoped count: Human Fighter 36/39,
  Elf Fighter 41/43, Human Mystic 36/44, Elf Mystic 34/42,
  Human Rogue 78/99 and Elven Scout 106/129; **331/396**
  functional analogues, **65 sourced rank entries still missing**.
- [x] Original Human/Elf C4 first-transfer class choices remain
  nine distinct paths; NONE is complete and seven class
  skill inventories have not yet been source-mapped.
- [x] Current focused Base tests: Battle Heal 28; Scout
  passives 286; Scout inventory 1,073; active statuses 24;
  latest Base implementation audit 57; overall strict
  completion audit 7. The completion flag remains FALSE.
- [x] Disposable unpublished Dungeon Play verified 18
  authenticated client-sent skills including both new
  real server status effects. No broad release regression
  or full persisted-player trainer test is claimed.

## Open before requested basic + first-transfer C4 catalogue is done

- [ ] Resolve 21 remaining starting-class source ranks: Human
  Fighter 3, Elf Fighter 2, Human Mystic 8, Elf Mystic 8.
  Requires real crafting/recipe knowledge, shared party healing,
  regeneration and poison/debuff mechanisms.
- [ ] Resolve 44 remaining first-transfer Scout source ranks:
  Human Rogue 21 and Elven Scout 23. Requires real world/key
  interaction, ranked toggles with mana upkeep, conditions,
  mobility/recovery, profession support, cleansing and buffs.
- [ ] Source-audit and implement the seven other original C4
  first-transfer career inventories (Warrior, Human Knight,
  Human Wizard, Cleric, Elven Knight, Elven Wizard, Elven Oracle);
  do not silently substitute an existing DungeonMMO role
  with a different source class tree.
- [ ] Integrate verified first-transfer advancement quests,
  prerequisites, trainer visibility, race/class permissions
  and persistent real player purchases; preserve current
  saves and established gameplay.
- [ ] Focused functional acceptance for every rank family,
  real client/party/world interactions and one full regression
  at completion. Existing unrelated Phase2A paid-revive
  automated failure is still a separate release blocker.

All scripts, tests and documents edited straight through GitHub.
Remote Desktop only fast-forward pulled and used TEMP builds,
unpublished Studio tests and logs. No merge to `main`,
Roblox publish, paid operations, production saves or repeated
old dungeon lifecycle loops.

**Requested complete C4 basic + first-transfer milestone: OPEN.**
