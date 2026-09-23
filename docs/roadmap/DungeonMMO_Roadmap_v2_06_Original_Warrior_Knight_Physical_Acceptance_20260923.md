# DungeonMMO backend roadmap v2.06 — Human Warrior and Knight acceptance

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Continues [v2.05 Ironroot and Ironvow backend](
DungeonMMO_Roadmap_v2_05_Ironroot_Quest_And_Ironvow_Transfer_20260923.md).
Detailed [actually executed v2.06 Studio evidence and limitations](
../testing/ironvow-oathguard-physical-and-rank-audit-v2-06-20260923.md).
The independently maintained humanoid and quadruped animation
roadmaps remain separate and are not superseded.

## Accepted in this increment

- [x] Replace the first-transfer trainer's two-class hardcoded
  proximity exception with a **server-side registry-backed
  ten-stud requirement** for each registered original
  career, including Ironvow and Oathguard. This applies
  to trainer snapshots, first skill purchases **and**
  subsequent rank purchases. Character race, owned class,
  unique earned proof, level, prerequisite proficiency,
  equipment restrictions and SP remain independently
  enforced. Trainer prompt line of sight is disabled
  only to allow interaction beside unfinished hub
  geometry; proximity is still checked on the server.
- [x] Restore the missing source-controlled genuine
  two-client **Ironvow physical Base** test after a
  previous interrupted file creation. Real client-held
  Marshal Torren and Smith Orla source prompts,
  actual four-marker hand-in, real boss-seal final
  hand-in, level-18 physical mentor denial,
  personally earned level-20 Ironvow award, actual
  in-range trainer catalogue and client-originating
  skill purchase now all **PASS**. An unadvanced
  Elf or the Human outside station range cannot
  purchase Warrior mastery. Earlier dungeon
  monster drops are prepared only in the
  disposable **Base** test fixture; this is not
  uninterrupted cross-place progression.
- [x] New independently authored earned Warrior
  **IronvowFortitude** maximum-health ranks
  at levels 20 and 28 and
  **IronvowRestRecovery** seated-only stamina
  rank at 24. All are genuinely purchased with
  SP and valid starter prerequisites. Two
  fortitude ranks add **16 real server MaxHealth**;
  recovery changes only the true seated
  server stamina multiplier. Wrong or forged
  Fighter identity earns neither effect. A
  fresh profile writer retains the paid ranks.
- [x] Isolated Ironvow suite **31 source + 79
  award/trainer/HP/armour/save + 58 rank/forgery
  checks PASS**. Existing source/class/quest
  compatibility runner **5/5 PASS**, including
  **170** first-transfer quest assertions,
  after updating its stale denial reason.
- [x] Repair stale actual Knight playtest
  identifiers to the authentic **three**
  Stonewatch badges and owned
  `OathguardShieldImpact`. Separate the
  physical Captain Rowan/Quartermaster
  Dena quest actors and Oathguard mentor
  from Ironvow's overlapping temporary
  hub prompts. The corrected genuine
  **two-client physical Base Knight** test
  now **PASS**: NPC starts, personal
  badge/seal turn-ins, level-20 award and
  actual client trainer purchase.
- [x] Existing original **Oathguard** isolated
  source/award/skill tests **29 + 38 PASS**,
  dungeon monster registration **11 PASS**.
  Corrected the same three-badge proof in
  its real two-client instanced Dungeon
  script: **PASS** for genuine client hits
  on actual quest enemies followed by
  server test-driver finishing blows
  and owner-only quest drops. This does
  not prove wholly client-controlled
  four/three-monster and boss completion.
- [x] Strengthen the original 20/24/28 rank
  audit with only skill families that have
  actual class/trainer rank definitions.
  Unpublished Studio launch audit **27
  assertions PASS**. Records are still
  a *training-schedule inventory*, not
  verification of every skill's mechanic.

## Planned level-30 release: exact class status

| Original first-transfer path | Repo-recorded 20/24/28 source rank entries | Mapped original rank schedules | Unmapped rank entries |
|---|---:|---:|---:|
| Human Rogue → Ashenblade | 59 | 59 | 0 |
| Elf Scout → Greenward Scout | 77 | 77 | 0 |
| Human Warrior → Ironvow | 62 | 27 | 35 |
| Human Knight → Oathguard | 54 | 24 | 30 |

The mapped values do **not** certify matching source-game
combat mechanics, all skill/passive effects, or the
separate starting levels 1–19 catalogue. A historical
*rank entry* is not a separate skill icon.
**Four of eighteen** registered original paths
now have authenticated source/award backends and
genuine physical Base mentor/trainer client
acceptance. The Warrior and Knight additionally
have genuine two-client stage-specific dungeon
combat/owner-bound drop proof. **Zero of eighteen**
have the entire original-level-1–30 skill set
and uninterrupted natural multi-place quest,
combat, award and trainer journey accepted.

## Continue implementation without false completion flags

1. **Complete Ironvow's remaining 35 recorded
   first-transfer rank entries** with individually
   purchased, independently authored abilities:
   real sword/blunt and polearm handling,
   multi-target polearm attack, critical stance,
   HP and recovery utility, control and
   common/equipment progression. Maintain
   weapon-tagged server hit authority, owned
   prerequisite skills/proficiency, SP, armour
   type and proper class-race identity.
   The four original actual skill combat checks
   and all currently implemented passives
   require dedicated real-client gameplay
   acceptance before marking class parity.
2. **Complete Oathguard's remaining 30 recorded
   first-transfer rank entries:** independently
   authored sword/blunt mastery, shield block,
   magical damage resistance, server-owned
   life drain, true defensive stance and
   low-health response, ranged defence,
   restorative utility, general skills
   and shield/armour interaction. Its
   current real shield, taunt and heavy
   armour families represent only
   **24/54** recorded purchase rows.
   Validate client-caused threat, targeted
   block and combat damage independently;
   do not label a sword executor as a
   finished shield or blunt mechanic.
3. Audit **starting-class level-1–19**
   source rank inventories for each
   currently advertised Human/Elf
   Fighter and Mystic. Complete genuine
   starter skill acquisition, mastery,
   equipment and rank-effect acceptance,
   rather than inferring it from a
   first-transfer source table.
4. Continue Human Wizard and Cleric:
   unique DungeonMMO career identifiers,
   race/base-class gates, original
   non-copied source quests and real
   physical combat/item proofs; genuine
   spell damage, healing, mana, buffs
   and individually purchased first-transfer
   rank ladders through level 30.
   Then Elf Knight/Wizard/Oracle,
   Dark Elf, Orc and Dwarf branches.
   Keep **18 original first-transfer
   paths** and their source class
   advancement structure as the
   scope; don't prematurely label
   an unfinished class playable.
5. For each claimed launch class,
   require a fully client-controlled,
   uninterrupted Base → instanced
   Dungeon → Base quest and naturally
   earned training path. Playtest
   every distinct skill effect,
   wrong race/class, wrong weapon,
   out-of-range prompt, forged event,
   cooldown/SP replay, party membership,
   wipe/reconnect and profile writer
   lease/save handoff. A local
   unpublished two-place simulation
   is not an accepted real published
   cross-place journey.
6. Implement a server-enforced level-30
   cap **only when** migration-safe
   initial release progression is
   ready. Existing above-cap test/player
   data must not be truncated.
   Level-32+ skills and later class
   transfers belong in future updates.
   No Roblox publish or production
   DataStore changes without user approval.

Preserve original DungeonMMO NPC/monster/story
expression, hub plus instanced dungeon
architecture, all-party higher-difficulty
unlocks, highest-threat/nearest-unharmed
aggro with taunt, animal-only skinning,
one gathering plus one crafting profession
per character, trading economy and
separate art/animation roadmaps.

Only use GitHub for permanent scripts and
docs. Desktop Commander is permitted only
for local clean pulls, temporary builds,
unpublished Studio playtesting and logs;
do not use it to edit source files.
Do not merge to `main` or publish.
