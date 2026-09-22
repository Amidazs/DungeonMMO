# DungeonMMO roadmap v1.75 — C4 Scout evasion and Mystic healing

Date: 22 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
[Detailed focused test record](../testing/c4-scout-evasion-base-healing-2026-09-22.md)

## Completed, tested in this increment

- [x] Purchased level-24 Scout Evasion (+3%) and moving-only
  level-28 Scout Running Evasion (+2.5%) for current Human/Elven
  Ranger/Rogue analogues. Actual direct enemy-melee DamageService
  now rolls the bounded server-owned evasion chance before wards
  and health, without changing magic, area damage or PvP.
- [x] Level-14 three-rank Mystic Battle Heal for both starting
  Human/Elven Mage classes. Existing MageHeal backend owns
  friendly healing, mana spending, cooldown and heal contribution.
  Bought MysticHealingPrayer rank 3 and earned proficiency
  55/125 gate its purchased training ranks.
- [x] Human-only two-rank Mystic Life Drain at level 14,
  requiring purchased MysticWindBolt rank 2 and 65 earned
  proficiency for the second rank. A real NPC projectile hit
  heals the original authenticated caster by 20%/30% of actual
  health damage. Elven Mystic has no access.
- [x] Focused tests: Scout passives 286, Scout source inventory
  1070, Battle Heal 28, Life Drain 11, production in-memory
  trainer/save/reload 37, base source audit 57, unified strict
  source-coverage gate 7 assertions PASS.
- [x] Both Base and Dungeon disposable Rojo builds succeeded.
  A real unpublished Studio Play client passed 16 actual
  hotbar-to-combat ability cases, including Battle Heal and
  NPC-hit Life Drain, and printed VERIFIED_PLAY_MODE_PASS.
- [x] Source-backed rank coverage for SIX currently mapped
  Human/Elf base and partial first-transfer classes: **328/396
  functional analogues, 68 still missing**. Starting classes
  total 147/168, partial Scout source classes 181/228.

## OPEN: requested basic + first-advancement C4 catalogue

- [ ] Starting Human Fighter 3, Elven Fighter 2, Human Mystic 8
  and Elven Mystic 8 source rank entries remain unmapped.
  Genuine recipe/common-item crafting, sitting recovery,
  poison cure/status, party-member heal, attack debuffs and
  Human poison curse need existing-game integration.
- [ ] Human Rogue **22** and Elven Scout **25** source rank
  entries remain unmapped; includes 10 continuous-mana critical
  toggle ranks across both, lock/key expertise, utility skills
  and status/conditional combat mechanics. Names/counts are
  printed by `C4ScoutSkillInventory.audit(race_id).MissingFamilies`.
- [ ] Original nine Human/Elf C4 first-transfer choices must
  have separate source rank catalogues and real server skills:
  only Human Rogue and Elven Scout are PARTIAL; the other
  seven source classes have NOT been inventoried or built.
  The current game's independent Ranger/Rogue starting
  and secondary role tree must not masquerade as authentic
  nine-path C4 first-transfer completion.
- [ ] Extend the source and implementation audits to the
  game's intended remaining races/roles and any additional
  advancements before making an overall game claim.
- [ ] Integrate real first-transfer quests, authorized trainer
  menus, full selected-class history and earned prerequisites
  into the existing persistent account flow. Do not grant
  missing ranks by seeding metadata or altering production data.
- [ ] Verify RNG dodge path using a deterministic real-player
  melee acceptance harness; repeat actual saved-profile
  client trainer purchases and multiple real-party support
  tests after those mechanics are implemented.
- [ ] One milestone-wide regression after all basic + first
  transfer ranks are functional; separate Phase2A paid-revive
  automatic failure remains a release blocker.

The strict `C4CatalogueCoverage.report().Completed` flag remains
FALSE and must not be relaxed to achieve a cosmetic green gate.

## Workflow

All scripts, tests and docs via GitHub only. Remote Desktop
only fast-forward pull, disposable TEMP Rojo build, unpublished
Studio visual/play test and log read. No `main` merge,
Roblox publish, production DataStore writes, paid operations,
force-push or unrelated dungeon wipe/aggro/revive test cycle.

**v1.75 result: focused backend increment accepted, original
full C4 catalogue request remains INCOMPLETE.**
