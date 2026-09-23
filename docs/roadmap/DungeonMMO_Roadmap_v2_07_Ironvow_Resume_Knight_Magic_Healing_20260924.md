# DungeonMMO backend roadmap v2.07 — resumed Warrior, Knight spell defence

Date: 24 September 2026 (local)
Branch: `wip/phase-4-test-hud-integration-v1`
Continues [v2.06 physical original Warrior/Knight acceptance](
DungeonMMO_Roadmap_v2_06_Original_Warrior_Knight_Physical_Acceptance_20260923.md).
[Actually executed v2.07 tests and limitations](
../testing/ironvow-resume-oathguard-magic-healing-v2-07-20260924.md).
The separate humanoid, wolf and quadruped animation
roadmaps remain current and unchanged.

## Accepted this increment

- [x] Recovered from a timed-out Ironvow Base test setup.
  The first test on the previously pulled branch genuinely
  failed because a physical NPC prompt did not trigger.
  Following a fast-forward update to the latest v2.06
  hub/visibility fixes, a genuinely **two-client
  unpublished Ironvow physical Base rerun passed**:
  both source NPC prompts, personal four-marker and
  boss-seal physical turn-ins, actual level-20 mentor
  class award and client-originated nearby
  trainer purchase. Success was confirmed by the
  specific Ironvow Studio process log because
  another concurrent test had overwritten the
  generic named output file.
- [x] Add a real purchased **Oathguard Runic
  Resistance** line: eight distinct rank purchases
  at levels 20/24/28, personally earned Knight
  class-only, 0.6% EnemyMagic mitigation per rank.
  Authenticated character runtime and damage
  calculation now apply **up to 4.8%** of
  server-authoritative enemy spell protection,
  not free physical damage protection.
- [x] Add a separate **Oathguard Mending Oath**
  self-heal line: three individually purchased
  level-28 ranks with a paid Fighter endurance
  prerequisite and existing owner-only server
  healing executor (30/37/44 base healing),
  mana spending and cooldown.
- [x] Both source-controlled Knight lines appear
  only on the authentically awarded original
  Oathguard career/physical trainer and are mapped
  to the corresponding historical first-transfer
  magic-resistance and self-recovery rank families.
  No client-supplied HP, resistance or raw
  class identity is trusted.
- [x] Disposable Base and Dungeon Rojo builds
  passed. Knight focused actual
  Quest/Skill/Profile Studio tests **2/2 PASS**
  (56 quest and 56 skill/foundation assertions),
  covering all 11 separate purchased ranks,
  original mentor, SP/prerequisite levels,
  server runtime magic mitigation,
  forged-class resistance denial and save.
  Level-30 source-rank inventory audit
  **27 assertions PASS**, now representing
  **35/54** mapped Oathguard historical
  first-transfer training rows.

## Exact progress, not release certification

| Original path | Recorded 20/24/28 source rank entries | Mapped and trainer-authorized rank schedules | Still unmapped |
|---|---:|---:|---:|
| Human Rogue → Ashenblade | 59 | 59 | 0 |
| Elf Scout → Greenward Scout | 77 | 77 | 0 |
| Human Warrior → Ironvow | 62 | 27 | 35 |
| Human Knight → Oathguard | 54 | 35 | 19 |

Recorded historical rank entries are rank opportunities,
not different skill buttons. Two Scout schedules remain
mapped but that is not complete live effect equivalence.
**4/18** original classes have current authentic physical
source, mentor and trainer acceptance. The original
level-1–19 starter source catalogue, real uninterrupted
Base → Dungeon → Base journey, every rank/effect,
remaining 14 classes and migration-safe level-30
release cap remain incomplete. **0/18** classes
are certified as fully release complete.

## Continue without early completion claims

1. Fully client-triggered real Oathguard Mending Oath
   first/third rank self-healing and enemy-cast
   Runic Resistance damage comparisons; verify
   the resource/cooldown, genuine owner, unrelated
   party-member isolation and wrong-class claims.
   Regress unaffected normal physical damage.
2. Complete the Knight's **19 outstanding source-rank
   rows** with genuinely different shield mastery,
   sword/blunt, owned drain-on-hit, defensive
   stance, low-health response, ranged protection,
   creation/equipment and full per-rank
   training/equipment authority. Do not map
   a blunt hit to an unimplemented sword-only
   combat executor.
3. Complete the Warrior's **35 outstanding
   source-rank rows**: sword/blunt weapon
   mastery, distinct polearm targets, critical
   stance, health recovery, true separate
   physical control and common/equipment
   skills, with real effects and earned
   level/rank/proficiency/weapon gates.
4. Source-audit and implement the remaining
   Human Wizard/Cleric, other Elf, Dark Elf,
   Orc and Dwarf first-transfer classes
   plus all actual starter 1–19 skill ranks,
   physical original source quest/mentors
   and verified combat/healing/passive effects.
   Preserve the original 18-branch
   first-transfer structure and independent
   DungeonMMO class/skill/NPC narrative.
5. Require honest release acceptance for
   each advertised level-30 class: client-
   controlled genuine quest kills and owner
   loot, personally authentic mentor,
   trainer and every distinct skill effect,
   one-owner profile lease/save/rejoin,
   all-party dungeon difficulty gating
   and uninterrupted cross-place journey.
   Publishing Roblox places and production
   DataStore mutation require explicit
   user approval. Level 32+ remains future.

Project rules: keep one gathering and one
crafting profession, trading dependency,
hub plus instanced dungeons, closest-before-
damage/highest-threat taunt aggro and animal-
only skinning. Permanent edits through
GitHub only; local desktop only for
fast-forward pull, disposable build,
unpublished Studio playtests and logs.
Do not merge `main` or publish without
approval.
