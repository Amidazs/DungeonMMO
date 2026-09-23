# Oathguard shield-mastery v2.08 — GitHub-only test status

Date: 24 September 2026 (local)
Branch: `wip/phase-4-test-hud-integration-v1`

The user reported Remote Desktop Commander unavailable. No local
Roblox Studio or Rojo build was run. Do not carry forward older v2.07
PASS results as verification of these new shield changes.

## Implemented and staged in GitHub

- `C4OathguardFoundationTest.server.luau`: source ranks at 20/28,
  forged/unawarded character must receive zero purchased protection;
  copied shield ranks may not bypass own-class trainer authority.
- `C4OathguardQuestAwardTest.server.luau`: purchases two ranks on a
  genuinely quest-awarded Oathguard, verifies 0.8% at rank one,
  zero without shield and 1.6% at rank two with registered
  `marauder_shield`; rejects unknown and wrong-slot items, reads the
  authenticated combat snapshot and denies copied ranks to a Fighter.
  The fixture sets a registered OffHand item ID directly in an isolated
  test profile; it does **not** prove normal inventory/equip UI flow.
- `C4Level30LaunchCoverageTest.server.luau`: asserts 37/54 mapped
  Knight source-rank opportunities and 17 unmapped, while the
  release-complete flag remains false.
- `PassiveSkillEffects.oathguard_shield_reduction` validates the real
  OffHand item category/slot and original awarded class before applying
  an earned rank. `ProgressionRuntimeState` accesses its immutable
  equipment snapshot; `DamageService` consumes it only on hostile
  `EnemyMelee`/`EnemyArea` branches.

## Required verification, not yet executed

- [ ] Run both focused Studio suites through
  `scripts/studio/c4_oathguard_quest_focus.luau` and
  `scripts/studio/c4_level30_launch_coverage_focus.luau`.
- [ ] Build temporary Base and Dungeon compositions using Rojo;
  do not overwrite `DungeonMMO.rbxl`.
- [ ] Real client: genuine Oathguard with bought rank 1 and rank 2
  receives the correct reduction from the **same** enemy melee/area
  hit with an equipped shield. Unequipping eliminates the bonus.
- [ ] Real client: spell hits, player damage, unawarded Fighter,
  another party member and invalid OffHand gear do not receive it.
- [ ] Check prior v2.07 `OathguardMendingOath` owner-only healing and
  `OathguardRunicResistance` enemy spell mitigation with genuine
  client casts, cooldown, resources and wrong-class rejection.
- [ ] Save/rejoin, cross-place transfer and existing dungeon
  multiplayer/party-difficulty rules require independent proof.

Status: **GITHUB IMPLEMENTED / STUDIO PENDING**, not physically
accepted, release-ready, published or merged. No production DataStore
or paid-product operations were performed.
