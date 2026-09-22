# DungeonMMO roadmap v1.74 — C4 basic and first-transfer coverage

Date: 22 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
[Exact focused source coverage and test receipts](../testing/c4-base-first-transfer-coverage-2026-09-22.md)

## Current accepted local backend

- [x] Entire original C4 Human/Elf starting Fighter/Mystic source rank
  inventory recorded and exact per-level source totals tested.
- [x] Human/Elf first-transfer source tree enumerated as **nine
  separate choices**, with the current game's different career
  topology explicitly distinguished. Two Scout skill inventories
  PARTIAL, seven further source career inventories NOT IMPLEMENTED.
- [x] Previously tested Fighter sword, bow, dagger, physical and
  armour passive ranks, Mage wind/heal, buffs, elemental slow and
  magic/physical defence ranks.
- [x] Newly purchased starting Mystic robe-only casting rate,
  mana regeneration and physical attack rate have actual backend
  multipliers with gear/class ownership. Purchased novice protection
  reduces real physical NPC hits by 2% through level 19 only.
- [x] Base Rojo missing-status-service composition fixed. Both
  Base and Dungeon compositions built after current changes.
- [x] Focused latest source audit: Human Fighter 36/39,
  Elven Fighter 41/43, Human Mystic 31/44 and Elven Mystic 31/42
  functional analogue rank entries.
- [x] Existing first-transfer Scout audits: Human Rogue 75/99
  and Elven Scout 102/129. Raw six-class source coverage:
  316/396 functional analogues, 80 unmapped source rank entries.
- [x] Unified C4CatalogueCoverage.report() fails completion while
  source rank gaps remain or original C4 first-transfer branches
  are incomplete. Current class paths COMPLETE: 0/9.
- [x] Focused Studio: 152 source inventory, 88 Fighter bow/dagger,
  52 Mystic wind/heal, 72 Fighter passives, 38 Mage robe,
  36 novice defense, 32 real isolated trainer/persistence,
  44 first-transfer source, 63 latest base mapping and
  7 unified strict-coverage assertions PASS.

## Required work before even this scoped C4 milestone is complete

- [ ] Human Fighter 3 and Elven Fighter 2 actual ranks pending:
  recipe reading, common item creation, and Human sitting recovery.
- [ ] Human Mystic 13 and Elven Mystic 11 actual ranks pending:
  common item/recipe functions, three ranks each of battle heal
  and party heal, physical attack debuff, poison cleanse, plus
  Human life drain and poison curse or Elven attack-speed debuff.
- [ ] Human Rogue 24 and Elven Scout 27 functional analogue
  source rank entries pending (exact family ledger in
  `C4ScoutSkillInventory.audit(race_id).MissingFamilies`).
- [ ] Source-enumerate and implement distinct C4 first-transfer
  Human Warrior, Human Knight, Human Wizard, Cleric, Elven
  Knight, Elven Wizard and Elven Oracle ability/rank inventories.
- [ ] Integrate authentic first-transfer choices/quests, class
  history and correct trainer visibility into gameplay without
  treating current Ranger/Rogue or original specialist role
  labels as exact C4 branch completion.
- [ ] Focused actual live client/persisted-player purchase tests
  after feature integration. No general Dungeon acceptance is
  claimed; the prior unrelated Phase2A paid-revive automatic
  failure remains a release blocker.

## Non-destructive workflow

All code, fixtures and documents through **GitHub**. Remote
Desktop only for fast-forward pull, TEMP build, unpublished
Roblox Studio test and log reads. Do not edit scripts/docs
through Remote Commander. No merge to `main`, publish,
production DataStore edits, paid operations, unrelated art work
or repeated old dungeon wipe/aggro/revive/replay test loops.

**Current milestone state: PARTIAL. Do not publish or call C4 done.**
