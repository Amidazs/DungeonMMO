# DungeonMMO roadmap v1.84 — verified active Scout Accuracy

Date: 23 September 2026
Backend branch: `wip/phase-4-test-hud-integration-v1`

## Roadmap precedence

This is the latest **C4 backend and original-class catalogue**
supplement, following [v1.83 verified Critical Power](
DungeonMMO_Roadmap_v1_83_C4_Scout_Critical_Power_20260923.md).
The separate humanoid/quadruped animation production roadmap
remains authoritative for character models, rigs, animations
and visual approvals. The agreed WoW-inspired **one Gathering
plus one Crafting profession per character** remains mandatory.

## Completed and verified in this increment

- [x] Human Rogue and Elven Scout level-24 original
  `AccuracyToggle`: one distinct purchased rank each.
  The existing real Ranger/Rogue class trainers, normal
  race/class/level progression gates and active loadout
  authorize the new ability.
- [x] A genuine on/off stance, requested through the real
  client SkillRequest rather than an inert icon. Activation
  costs three actual stamina, continuous upkeep consumes
  another three stamina/second, and a second cast switches
  the stance off. Stamina exhaustion, a revoked skill,
  stale loadout, session exclusion, death and respawn
  disable its effect.
- [x] An authorized active Accuracy stance adds +0.12
  real hit probability against NPCs with server-authored
  physical evasiveness. The existing server combat damage
  service checks player melee and physical ranged attacks.
  NPCs without such evasiveness retain their former
  hit behavior; no global random miss regression was added.
  A miss neither damages an NPC nor triggers a free
  Ranger on-hit snare, stagger or control reward.
- [x] Combat probability calculation separated into a
  small pure shared module with bounded inputs; the
  server owns the roll, hit result, skill rank and stamina.
  Accuracy does **not** add a second profession, free
  Critical Power or client-controlled damage.
- [x] Authored source inventory counts reconciled to
  **373/396**; exactly **23** source-ranked entries remain
  in the six currently inventoried original C4 classes.
- [x] Executed actual unpublished Studio focused suite:
  **7/7 passed, 0 failed**; new source/accuracy test
  **39 assertions**; updated inventory audit
  **1,112 assertions**. Luau source parsing and
  focused/full Dungeon Rojo builds passed.
- [x] Ran the existing checked-in `DamageServiceTest`
  independently in unpublished Studio: **15/15 assertions
  passed**, preserving legacy physical hit and critical
  damage behavior after the Accuracy change.
- [x] An actual admitted one-client unpublished Dungeon
  playtest verified activation/off via the real skill
  remote, a deterministic server melee/bow miss becoming
  a real HP hit while active, ongoing stamina upkeep,
  switching off returning both to the original hit chance,
  and exhaustion removing the effect. The server combat
  test contexts were controlled for reproducible 0.90
  hit rolls; an actual click-fired bow projectile was
  **not** used for this deterministic comparison.
  See [executed test record](
../testing/c4-scout-accuracy-toggle-v1-84-2026-09-23.md).
- [x] Game scripts, focused tests, runner and docs
  created/edited through GitHub only. Local desktop
  used for clean fast-forward pulls, read-only state,
  disposable Rojo builds and real Studio testing.
  No publish, `main` merge, production DataStore
  modification or forced reset.

## Accurate C4 inventory progress

| Original C4 source class | Functional / raw ranks | Missing |
| --- | ---: | ---: |
| Human Fighter | 39 / 39 | 0 |
| Elven Fighter | 43 / 43 | 0 |
| Human Mystic | 44 / 44 | 0 |
| Elven Mystic | 42 / 42 | 0 |
| Human Rogue (partial first transfer) | 87 / 99 | 12 |
| Elven Scout (partial first transfer) | 118 / 129 | 11 |
| **Six inventoried classes** | **373 / 396** | **23** |

All four original starting-class source inventories remain
**168/168**. Seven additional distinct original C4
first-transfer class catalogues still need source enumeration
and implementation. The **23** remaining ranks refer only
to the currently inventoried six classes; **0/9 original
first-transfer paths are completely finished**.

## Next backend work — do not count placeholders

- [ ] Implement the three original first-transfer
  `CommonItemCreation` ranks per Human Rogue and
  Elven Scout at source levels 20, 28 and 36.
  Require their existing source Recipe Reading prerequisite
  and the player's single selected creation profession.
  The three ranks must grant actual scalable recipe
  functionality with real ingredient consumption,
  saved progression, existing material-market dependencies
  and no other-profession bypass. Real two-character
  craft/trade acceptance is required; do not award
  a source rank simply for adding an icon or inert entry.
- [ ] Implement five source `Lockpicking` ranks
  per Human Rogue/Elven Scout with server-owned
  dungeon/world interactables, distinct lock levels,
  range and instance checks. Never allow lockpicking
  to open another player's bank, inventory or
  marketplace, or bypass their gathering profession.
- [ ] Add source `EquipmentExpertise`,
  `LungCapacity` and `FallResistance` for each;
  Human Rogue additionally needs `Sprint`.
  Verify genuine progression-gated inventory/
  environment/combat effects rather than passive labels.
- [ ] Continue source-mapping and implementing the
  seven *additional* original first-transfer classes;
  verify their level/skill/prerequisite/advancement
  quest gating and genuine server effects.
- [ ] Preserve the separate v1.78 Mystic hostile-
  weakening real-client combat acceptance gate;
  the successful Scout test does not resolve it.
  Avoid repeating accepted wipe/aggro/paid-revive
  suites without relevant changes.

**v1.84 paid Accuracy Toggle: focused and real-client
combat integration PASS. Full original C4 catalogue:
INCOMPLETE.**
