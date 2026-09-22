# DungeonMMO roadmap v1.77 — C4 poison and curing backend

Date: 22 September 2026
Backend branch: `wip/phase-4-test-hud-integration-v1`
[Current source and live-Play evidence](
../testing/c4-poison-status-v1-77-2026-09-22.md)

## Roadmap precedence

This version is the next **backend C4 supplement** after
[v1.76 conditional recovery](
DungeonMMO_Roadmap_v1_76_C4_Recovery_20260922.md).
The most recently updated overall roadmap index also references
the separate [humanoid animation authoring roadmap](
DungeonMMO_Humanoid_Animation_Pipeline_20260922.md). Preserve its
no-manual-Blender user workflow, visual approval requirement and
unpublished-isolation rules. This increment does not replace or
mark any of those animation/art gates complete.

## This backend increment: implemented and tested

- [x] Human Mystic level-seven purchased `MysticPoisonCurse`,
  with genuine wand, class/race, level and prior magic gates.
  A real hostile projectile hit initiates three authored,
  non-stacking server-owned poison damage ticks.
- [x] Human/Elf Mystic level-seven `MysticCurePoison`
  removes an actual server-owned poison from a valid
  facing/range/line-of-sight friendly target or the caster,
  even when the poisoned player has full health.
- [x] Elf-only Scout level-24
  `ElvenScoutPoisonRecovery` uses the existing
  mana-funded, cooldown-checked skill flow but is self-only.
- [x] Common `PoisonStatusService` invalidates old timers
  on reapply, cleanse, invalid caster and status completion;
  real ticks pass through authoritative `DamageService`.
  This is a reusable server primitive; scripted enemy/boss
  poison attacks remain a separate content gate.
- [x] Focused 20 progression, 49 basic inventory,
  1,080 Scout inventory, seven fail-closed overall audit
  assertions PASS; disposable Base and Dungeon Rojo builds PASS.
- [x] Real unpublished Play client successfully sent
  curse and both cures through the project hotbar.
  Its live target lost initial damage and three distinct
  four-HP poison ticks, and each full-health friendly
  cleanse stopped subsequent ticks.
- [x] Scoped six-inventory C4 count: Human Fighter
  37/39, Elven Fighter 41/43, Human Mystic 38/44,
  Elven Mystic 35/42, Human Rogue 81/99,
  Elven Scout 108/129. **340/396** functional
  DungeonMMO analogue ranks, **56 missing**.
  Original first-transfer class paths still **0/9 complete**.

## Next open C4 implementation gates

- [ ] Finish 17 sourced starting-class ranks: four
  RecipeReading, four CommonItemCreation, six
  PartyHeal and three physical/attack-speed debuffs.
  Connect crafting to existing recipe/profession
  authority; party healing must use real party identity,
  not an unrestricted nearby-player heal.
- [ ] Finish 39 source Rogue/Elven Scout ranks:
  sustained toggles with real resource upkeep,
  lock/key/world interactions, common crafting,
  equipment/environment effects and Elf support.
- [ ] Source-map and implement the seven still
  unenumerated ORIGINAL C4 first-transfer class trees:
  Human Warrior, Human Knight, Human Wizard, Cleric,
  Elven Knight, Elven Wizard, Elven Oracle. Keep all
  original race/class paths distinct from current
  DungeonMMO starter Ranger/Rogue role analogues.
- [ ] Integrate first-transfer trials, persistent class
  identity and trainer visibility, one real normal
  saved-player purchase/client path and the relevant
  real multiplayer support contracts.
- [ ] At the proper milestone closeout, run ONE
  targeted breadth regression, not repeated historical
  dungeon wipe/aggro/revive tests. Separate Phase2A
  paid-revive automated failure remains unresolved.
- [ ] Before release, independently author and accept
  visual creature animation/rig families under the
  preserved newest animation roadmap. No animation
  prototype is production-ready by virtue of this
  C4 backend work.

No merge to `main`, Roblox publishing, paid operations,
production DataStore changes or live cloud acceptance.
All scripts and docs edited directly in GitHub; remote
used only for clean pull, disposable builds, unpublished
Play and read-only test logs.

**Full basic + first-transfer C4 catalogue: INCOMPLETE.**
