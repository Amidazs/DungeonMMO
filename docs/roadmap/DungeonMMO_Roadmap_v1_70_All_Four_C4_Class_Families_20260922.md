# DungeonMMO roadmap v1.70 — C4-style progression across four families

Date: 22 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Focused-tested gameplay head:
`687e27c7ee8b0b41aa37c15030b4df2d14d4600f`

## Completed local backend feature slice

- [x] Fighter, Mage, Ranger and Rogue each have level-gated
  basics with real combat effects (melee, ranged, magic,
  support/control) and role-appropriate passives.
- [x] Added nine-rank Ranger power shot and Rogue rear
  strike plus six-rank damage masteries that modify
  authoritative ranged/melee multipliers.
- [x] Added distinct level-24 advanced Mage projectile/
  ward skills to the existing Human Arcanist and Elf
  Spellweaver branches. Added level and skill-rank
  prerequisites to both race-specific advanced Rogue
  skill families. Preserved the existing Fighter/Ranger
  specialist skill branches and requirements.
- [x] Advancement quests in all four families require
  the actual character level, full prescribed skill
  ranks and earned proficiency before Start and Claim.
  Advanced skill purchases and use require the correct
  earned active advanced class, race, previous skills
  and level. Skill preview and trainers hide unavailable
  unknown abilities.
- [x] Generalized server Mage projectile mana spending
  and damage attribution to the actual spell ID.
- [x] Targeted four-family contract: **74 assertions**
  PASS; affected earlier advancement **66** and
  Fighter/Ranger specialist **60** passed on the
  earlier gameplay head. Base and Dungeon builds passed
  after the major implementation. Final metadata-only
  Rogue mastery increase passed one Base build and
  the same 74-assertion focused contract.

[Implementation and tested boundaries](../testing/c4-all-four-class-families-2026-09-22.md)

## C4 reference: implement functions, not filler skill names

Chronicle 4's class catalogue shows many progressively
learned attack, protection, status, healing, movement,
weapon/armour mastery and specialization abilities.
DungeonMMO uses comparable gameplay purposes and
stage-gated trainer advancement while keeping original
names, lore, data, balance and effects built on existing
server-authoritative combat services.

Source reference:
https://lineage2wiki.com/c4/class/
and class skill details:
https://l2hub.info/c4/classes/mage
https://l2hub.info/c4/classes/rogue
https://l2hub.info/c4/classes/elven_scout

**Still open:** C4 is a much larger multi-race/multi-class
catalogue than these first four DungeonMMO families.
The existing read-only Fighter/Mage rank manifest still
reports **13/16 mapped brackets mismatched**. Ranger
and Rogue have functional level/rank/skill chains, but
their source-rank count mapping is not yet incorporated
into that manifest. Do not claim exact C4 completeness,
numerical rank parity, or tested in-client effects for
every new ability.

## Next development, without repeating existing dungeon tests

1. One focused genuine client input/impact test for
   Mage's two new specialist spells plus representative
   Ranger/Rogue active skills. Confirm server mana,
   damage, rear positioning and UI visibility.
2. Fill missing mapped C4-era mechanics with **real
   server effects**: race/class appropriate buffs,
   status removal, movement, cast recovery, control,
   weapon/armour mastery, multi-target abilities and
   later specialist skill progression. Expand the
   skill count audit to Ranger/Rogue and advanced
   branches; never create inert ranks to meet totals.
3. Add player-facing advanced trainer/trial UI
   showing precise level, proficiency and fully
   mastered prerequisite skills. Use the existing
   Base remotes and server snapshot rather than a
   second progression service.
4. Continue actual dungeon loot and equipment content,
   professions/raids and guild gameplay in the
   consolidated backlog.

Testing policy: focused new-feature test; broad regression
only at a meaningful milestone closeout or release.
No published server, production data change,
`main` merge or force-push.
