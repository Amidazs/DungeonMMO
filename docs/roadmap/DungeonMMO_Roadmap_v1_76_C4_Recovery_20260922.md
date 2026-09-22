# DungeonMMO roadmap v1.76 — conditional C4 recovery

Date: 22 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
[Latest source audit and focused Studio evidence](../testing/c4-conditional-recovery-v1-76-2026-09-22.md)

## Implemented and tested this increment

- [x] Source Human Fighter level-five seated Stamina recovery.
- [x] Human Rogue first-transfer seated recovery ranks at
  levels 24/32, and both original Scout races' running
  recovery rank at source level 36.
- [x] The actual server Stamina Heartbeat now uses these
  purchased, race/class-authorized ranks only while the
  actual Humanoid is seated or moving. No generic fake
  subject bonus, free preview bonus, shorter post-spend
  delay, bypassed exhaustion or paused regeneration.
- [x] Focused Studio tests: 42 recovery, 1,079 Scout
  source inventory, 55 starting-class source audit and
  seven strict overall completion assertions PASS.
- [x] Both unpublished Base/Dungeon Rojo compositions PASS.
  Disposable live Studio player seated in a real Seat:
  actual spent Stamina regenerated measurably faster with
  the purchased Fighter rank; `VERIFIED_PLAY_MODE_PASS`.
- [x] C4 six-inventory scoped count: Human Fighter 37/39,
  Elf Fighter 41/43, Human Mystic 36/44, Elf Mystic
  34/42, Human Rogue 81/99, Elven Scout 107/129.
  **336/396 functional analogue ranks; 60 missing**.
- [x] Original C4 first-transfer source paths still
  **0/9 complete**; seven distinct source class skill
  inventories are not yet enumerated or implemented.

## Remains required before the requested full C4 milestone

- [ ] Finish 20 sourced first-tier ranks: real common
  crafting and recipe-reading, party healing, poison
  cleansing, poison/attack-speed/physical debuffs.
- [ ] Finish 40 mapped Rogue/Scout source rank gaps:
  ten ranked critical toggles, ten lockpicking ranks,
  missing environment/equipment/recovery-support,
  resource-controlled accuracy toggle, sprint, common
  crafting and Elf-only support/buff/cleanse effects.
- [ ] Source-map and implement the SEVEN distinct
  first-transfer career trees still missing:
  Human Warrior, Human Knight, Human Wizard, Cleric,
  Elven Knight, Elven Wizard and Elven Oracle.
  Preserve correct original race, first-transfer
  quests, class-trial prerequisites and level/proficiency
  gates; do not pretend independent starter Ranger/Rogue
  are exact original C4 advancement choices.
- [ ] Integrate real persisted-player trainer GUI and
  skill purchases, real multiplayer/party/world interaction
  checks, and a single full regression at milestone closeout.
  The independent Phase2A paid-revive automatic failure is
  still an unresolved release blocker.

Scripts, tests and docs via GitHub only. Local desktop is
restricted to clean pull, temporary unpublished Rojo builds,
Studio tests and read-only logs. Do not merge `main`,
publish Roblox, touch production DataStores, use paid operations
or rerun unrelated old dungeon lifecycle suites.

**Overall C4 basic plus first-transfer milestone: INCOMPLETE.**
