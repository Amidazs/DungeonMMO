# DungeonMMO roadmap v1.78 — C4 Mystic enemy weakening

Date: 23 September 2026
Backend branch: `wip/phase-4-test-hud-integration-v1`

## Precedence and scope

This is the next **backend supplement** after
[v1.77 poison and curing](DungeonMMO_Roadmap_v1_77_C4_Poison_Cure_20260922.md).
The separately updated [humanoid animation production roadmap](
DungeonMMO_Humanoid_Animation_Pipeline_20260922.md) remains the
authority for humanoid rig, animation and art decisions. This
backend increment does not mark that visual acceptance complete.

## New code committed directly to GitHub

- [x] Human/Elf starting Mystic level-14 `MysticFeebleCurse`:
  purchased, prerequisite-gated wand projectile. On a genuine
  server-confirmed hostile NPC hit, applies a bounded 20% reduction
  to physical outgoing attacks for six seconds.
- [x] Elf-only starting Mystic level-14 `ElvenMysticLanguor`:
  purchased, prerequisite-gated wand projectile. On a genuine
  server-confirmed hostile NPC hit, applies bounded attack-rate
  impairment to future Marauder and Captain attack intervals.
- [x] Reusable `EnemyWeakeningService` owns non-stacking statuses;
  status attributes are informational only. Invalid and expired
  status is rejected on authoritative damage/cadence reads.
  Separate power/rate effects can coexist and the strongest active
  magnitude is retained on reapplication.
- [x] Existing enemy damage multiplier authority and both prototype
  enemy attack schedulers consume the new server-only weakening.
- [x] Base and Dungeon disposable Rojo composition builds succeeded
  after a clean fast-forward-only pull to the candidate commit.
- [x] Dedicated focused `C4EnemyWeakeningTest` added in GitHub for
  race, level, trainer, non-stacking damage/cadence and expiry.

## Remaining acceptance for this increment

- [ ] Execute and review the new focused test in an unpublished
  Dungeon Studio server. **A green Rojo build is not an executed
  Luau test or a real-client combat effect proof.**
- [ ] Execute one real unpublished client projectile impact into a
  damaging NPC, verify physical damage and next-attack cadence
  through actual authoritative combat, with race/weapon denial.
- [ ] Review first-tier audit and overall strict coverage test.
  On code review, these three source rank entries may advance
  source mappings from the prior **340/396** to a **candidate
  343/396**, with **53** still open, but do not report that as
  tested functional coverage until the focused contract and real
  game impact pass. Seven separate original first-transfer skill
  inventories remain unmapped; **0/9** source transfer paths are
  complete.

## Next unfinished C4 catalogue content

- [ ] Starting classes: four RecipeReading, four
  CommonItemCreation, six true-party PartyHeal entries.
  Recipe and crafting ranks must call the existing authoritative
  professions system rather than becoming inert skill entries;
  party heals must use genuine party identity and eligibility.
- [ ] Partial Rogue/Elven Scout: the remaining 39 original source
  ranks across resource-upkeep toggles, lock/key world interaction,
  crafting, equipment/environment checks and Elf support.
- [ ] Enumerate and genuinely implement the seven missing distinct
  original C4 first-transfer class inventories: Human Warrior,
  Human Knight, Human Wizard, Cleric, Elven Knight, Elven Wizard
  and Elven Oracle; do not conflate their source career paths
  with current DungeonMMO Ranger/Rogue starting roles.
- [ ] Complete first-transfer quests and persisted class identity,
  saved-player trainer/client purchases, representative multiplayer
  support and one milestone-level integrated regression.
  The independent Phase2A paid-revive automated failure remains
  open as a separate release gate.

Do not merge to `main`, publish, use paid operations or mutate
production DataStores. All script and roadmap edits are GitHub-first;
the desktop is permitted only for clean pull, disposable builds,
unpublished Studio testing and read-only diagnostics.

**Overall basic + original first-transfer catalogue: INCOMPLETE.**
