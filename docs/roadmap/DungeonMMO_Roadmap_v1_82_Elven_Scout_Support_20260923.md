# DungeonMMO roadmap v1.82 — Elven Scout support and movement

Date: 23 September 2026
Backend branch: `wip/phase-4-test-hud-integration-v1`

## Which roadmap governs this increment

This is the latest **C4 backend/first-transfer skill supplement**
after [v1.81 verified Party Heal](
DungeonMMO_Roadmap_v1_81_C4_Party_Heal_20260923.md).
The separate newer humanoid-animation production roadmap remains
authoritative for rigs, animations and visual acceptance.
No character models, meshes or art were edited in this increment.

## Implementation completed directly in GitHub

- [x] Elven Scout level-24 `CureWounds` maps to purchased,
  race-gated, real self-only health restoration on an actual
  living character with mana and cooldown.
- [x] Level-28 `AttackBuff` maps to a real stamina-costed,
  non-stacking timed status. Ranger ranged-damage calculation
  now consumes the same actual PhysicalPower buff as Rogue
  melee attacks rather than silently ignoring an active bow
  buff.
- [x] Level-32 `SpeedBuff` maps to an explicitly activated,
  paid timed Movement status: actual server WalkSpeed is
  recomputed on cast and expiry, while blocking movement
  during normal dodge/death/windup still takes precedence.
- [x] Level-36 `MovementSlow` maps to Elf Ranger-only
  `SnaringShot`, using the actual bought longbow projectile
  and the existing server NPC slow authority.
- [x] All four skills are registered in authentic class trainers,
  class skill lists, rank-gated definitions and source inventory.
  Ranger and Rogue share the three fitting Elf support abilities;
  only Ranger may learn the longbow shot. Human cannot
  purchase or execute the Elf-only ranks.
- [x] Source-count and effect-contract tests updated without
  marking any unimplemented family as complete.
- [x] Actual unpublished Studio **5/5** focused suites PASS;
  original C4 Scout inventory test **1,084 assertions PASS**;
  new rank/source/effect test **55 assertions PASS**.
- [x] Actual one-client unpublished Dungeon gameplay PASS for
  three client-requested skills: real HP recovery, physical
  damage bonus for both melee and bow, paid cooldowns,
  real movement speed change and correct expiry.
  See [v1.82 execution record](
../testing/c4-elf-scout-v1-82-2026-09-23.md).
- [x] All script, runner, project JSON and document mutations
  made in GitHub. Local computer used solely for safe
  fast-forward pulls, disposable Rojo/Studio tests and
  read-only diagnostics. No `main` merge, publish,
  reset, production DataStore operation or paid action.

## Accurate C4 source inventory (not all first-transfer classes)

| Original C4 class | Functional / raw ranks | Remaining |
| --- | ---: | ---: |
| Human Fighter | 39 / 39 | 0 |
| Elven Fighter | 43 / 43 | 0 |
| Human Mystic | 44 / 44 | 0 |
| Elven Mystic | 42 / 42 | 0 |
| Human Rogue (partial first-transfer) | 81 / 99 | 18 |
| Elven Scout (partial first-transfer) | 112 / 129 | 17 |
| **Six inventoried classes** | **361 / 396** | **35** |

The original four starting-class source ranks remain **168/168**.
Only two of the nine original first-transfer classes have partial
source inventories, and **0/9 first-transfer paths are complete**.
Seven wholly separate first-transfer class skill catalogues still
need original C4 source enumeration and backend implementation.

## Next work to implement and test

- [ ] Test **one actual live longbow Snaring Shot impact** against
  a living NPC and verify hit-confirmed damage, actual AI movement
  reduction and later status expiry. The current one-client
  acceptance proves the other three skills, not this projectile.
- [ ] Implement genuine purchased `CriticalPowerToggle`
  (five original rank entries per Rogue/Scout source class)
  and `AccuracyToggle` (one each), with a real server
  activation/deactivation contract, bounded continuous resource
  upkeep, actual hit/critical calculations, reset on death,
  and anti-spam/weapon/class authorization. Do not replace
  these source toggles with inert one-click icon flags.
- [ ] Add actual first-transfer `CommonItemCreation` ranks
  at levels 20, 28 and 36 for both partially mapped classes,
  using the existing **one gathering + one crafting profession
  per character** rule. Upgrading creation ability must never
  grant a second crafting career or bypass the marketplace,
  original learned blueprints or consumed ingredients.
- [ ] Add real level-20 `EquipmentExpertise`, source
  `LungCapacity` and `FallResistance`, five ranked
  `Lockpicking` world interactions per source class, and
  Human-only level-20 `Sprint`, with real environment
  or gameplay effects and appropriate security limits.
  Locks are not permission to open another player's inventory,
  bank or marketplace, or skip Gathering profession ownership.
- [ ] Complete the remaining seven distinct original C4
  first-transfer class source inventories and class-quest
  prerequisites, then integrated progression and gameplay.
- [ ] The independent v1.78 Mystic enemy weakening genuine
  client-to-NPC combat acceptance remains open. The previously
  documented broad `SkillProgressionServiceTest` unrelated
  proficiency assertion remains an independent release gate.
  Avoid repeatedly running accepted wipe/paid revive/aggro
  suites without a relevant change.

**v1.82 source-mapped Scout support work: targeted Studio PASS;
three real client casts PASS; snaring arrow actual client hit
still pending. Full original C4 catalogue: INCOMPLETE.**
