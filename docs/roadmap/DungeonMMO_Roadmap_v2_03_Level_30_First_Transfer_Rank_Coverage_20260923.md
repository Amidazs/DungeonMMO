# DungeonMMO backend roadmap v2.03 — first-transfer level-30 rank coverage

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Continues [v2.02 initial level-30 launch scope](
DungeonMMO_Roadmap_v2_02_Level_30_Launch_Skill_Parity_20260923.md).
Acceptance: [v2.03 actually executed Studio tests](
../testing/original-first-transfer-level30-ranks-v2-03-20260923.md).
Independent humanoid/quadruped animation roadmaps are not superseded.

## Complete this increment

- [x] Preserve the **level-30 planned initial release**, including
  the original first-transfer training brackets **20, 24 and 28**.
  Level-32+ skills, next advancement tiers and higher-level dungeons
  remain update backlog, not immediate launch requirements.
- [x] Implement distinct earned-Fighter-original class
  bow and dagger attack lines, each with nine real progressively
  stronger, individually purchased 20/24/28 ranks and prerequisite
  starter training/proficiency. Use the existing authoritative
  Ranger projectile and dagger melee combat executors, not
  artificial client damage or legacy Rogue/Ranger class aliases.
- [x] Implement nine original bow mastery and four original dagger
  mastery ranks, with authentic purchased passive server damage
  bonuses and no benefit from spoofed class ID/mentor receipt.
  Original light-armour and defense/utility passives stay
  class/race restricted and interact with the actual server
  equipment, movement and damage calculations.
- [x] Allow both earned original careers to learn their relevant
  existing shared source-inspired equipment, lock, stance,
  armour, movement and combat support skills, with the
  original class ID and physical trainer required. Human-only
  critical/rest recovery and Elf-only self-recovery/status
  care/focus remain restricted. Preserve old standalone
  Ranger/Rogue catalogue entitlements without handing an
  unadvanced Fighter their abilities.
- [x] Add an independently named real server-hit dagger-wound
  skill at level 24 and nine separately purchased Elf-only
  threat-reducing arrow ranks through 28. Neither a client
  forged threat claim nor an unregistered enemy hit is accepted.
- [x] Keep common-item crafting dependent on a legitimately
  selected **one** crafting profession and prerequisite
  recipe training. No rank bypass of the one-gathering /
  one-creation profession rule or player trading economy.
- [x] Add an explicit, machine-checked **source family →
  actual original class/trainer skill/rank mapping**.
  Human Rogue reference: **59/59** skill-rank schedule
  entries matched for 20/24/28; Elven Scout reference:
  **77/77** matched. These are individually offered/purchased
  ranks, not different hotbar icons or comprehensive
  equivalence of every combat effect. Both careers still
  have open full live gameplay/effect acceptance.
- [x] New external-historical rank-family audit for the next
  two first-transfer branches: Human Warrior **20+19+23 = 62**
  and Human Knight **16+16+22 = 54** reference rows through
  30. Neither branch has a current playable transfer or
  certified skills yet. The remaining 14 first-transfer
  source inventories still need level-30 source review.
- [x] Local unpublished disposable Base/Dungeon Rojo builds
  passed. Focused actual Class/Skill/Profile Studio suite
  **2/2 PASS: 459 first-transfer assertions + 8 adjacent
  migration assertions**, verifying rank purchases, class
  isolation, mastery damage, crafting prerequisite denial,
  forged-passive denial and save/reload. Expanded level-30
  reference audit **25 assertions PASS**. Repeated physical
  unpublished two-client Base mentor/trainer regression
  **PASS** (`VERIFIED_TWO_CLIENT_FIRST_TRANSFER_PASS`).
- [x] All permanent code and documents edited directly in GitHub;
  the desktop was used only for clean branch pull, disposable
  local Rojo builds and unpublished Studio checks.
  No Roblox publish, `main` merge or production save change.

**Coverage boundary:** The 59/77 mapped rows are the recorded
*first-transfer* source training brackets at 20/24/28. The complete
historical starter-class level-1–19 ranks and the in-game behaviour of
every shared/passive/utility effect have **not** been certified against
C4, so the full level-1–30 class catalogue is not yet release accepted.
The original SourceRankScheduleMapped flag represents training rows,
not mechanically identical or fully player-tested skills.

## Next implementation order

1. **Complete original two-class gameplay acceptance:** use
   genuine clients to purchase and cast the new Wayfinder
   first/last ranks, wound and Elf calming arrow on actual
   instanced monsters. Verify correct weapon, target threat,
   damage-over-time, passive armour/critical/recovery effect,
   race, skill visibility, owned equipment, active cooldown,
   actual trainer UI and class/skill save/reconnect. This
   is required before certifying all C4-through-30
   functional equivalence; current 59/77 rank matching
   alone does not establish combat/mechanics equivalence.
2. **Implement the next playable Human Warrior career:**
   independently author its DungeonMMO identity, original
   source quest, true physical level-20 transfer mentor,
   saved receipt, race/Fighter/class gating and 20/24/28
   complete skill rows. Reference the already audited
   **62** historical source rank opportunities while
   designing distinct sword/blunt, polearm, armour,
   defensive control, buff and equipment/utility skills.
   All actual abilities must work with the real combat,
   trainer, equipment and SP/proficiency authorities.
3. **Then Human Knight and Human Mage classes:** the Knight
   historical 54-rank through-cap source is inventoried,
   but no Knight career or quest is implemented. Give it
   an independently authored guarded-tank/taunt/defense
   identity, real saved class transfer and each actual
   rank effect. Continue Human Wizard/Cleric alongside
   Knight before the other races, keeping the C4 first
   advancement structure as inspiration but not copied
   game-specific text or protected NPC/monster names.
4. **Remaining original 14 branch historical catalogues,
   gameplay identities, quests and mentors**, including
   Elven Knight/Wizard/Oracle, Dark Elf, Orc and Dwarf,
   keeping the five-race 18-branch source registry
   authoritative. Do not label source-audited but
   unimplemented branches playable.
5. **Launch readiness:** implement a migration-safe
   server-enforced level-30 cap and hide >30 trainer
   offerings when the release rollout is approved,
   without discarding any existing above-cap test or
   player profiles. Accept each advertised class's
   uninterrupted fully player-controlled Base →
   instanced Dungeon → Base quest/mentor/trainer
   journey, personal proof item ownership,
   wipe/reconnect behavior, real cross-place
   lease/save and replay protections. Roblox
   publication and production DataStore operations
   still require explicit user approval.

## Do not conflate separate completion metrics

- **2/18** actual original first-transfer class identities
  currently have physically verified level-20 awards.
- **2/18** current careers have every *recorded* C4
  source rank through the intended cap represented by
  a class-authorized trainer/skill definition and
  exercised via isolated server profile purchase tests.
- **4/18** historical through-cap source inventories
  are audited: the two existing Scouts plus Human
  Warrior and Human Knight. The next two do not
  have implemented classes/quests/skills.
- **0/18** class catalogues have complete
  accepted real-client gameplay/functional effect
  coverage or uninterrupted cross-place progression.
  Level 30 is a **planned** launch cap, not an
  already enforced live gameplay limit.

Keep the hub/instanced dungeon structure, party-wide
difficulty unlocks, closest-before-hit/highest-threat
aggro with real taunt, animal-only skinning, independent
original game assets/narrative, one creation and one
gathering profession, trading and separate animation
roadmaps. Use GitHub for all permanent changes.
