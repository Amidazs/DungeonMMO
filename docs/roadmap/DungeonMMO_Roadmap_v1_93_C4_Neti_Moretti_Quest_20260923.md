# DungeonMMO backend roadmap v1.93 — genuine C4 second quest NPCs

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`

## Roadmap precedence and design commitments

This is the newest **original Chronicle 4 class/
quest backend supplement**, following
[v1.92 real original quest starter NPCs](
DungeonMMO_Roadmap_v1_92_C4_Original_NPC_Quest_20260923.md).
The original five-race Fighter/Mystic starting
structure, level-18 explicit first-transfer
branch choice and authentic level-20 class
transfer quest remain the class authority.
Retain the subsequent original level-40 and
76 advancement paths, not automatic
DungeonMMO-specific classes.

The game remains hub-and-instanced-dungeon,
not an open world. Exactly **one gathering
and one crafting profession** per character,
real trade/material interdependence, party
difficulty checks, legacy saves and the
separate latest humanoid/quadruped art/
animation roadmap remain unchanged.
No merge to `main` or Roblox publishing
until requested.

## v1.93 actual completed backend work

- [x] In the original live Base, register
  **Neti** and **Guard Moretti** as genuine
  physical, server-owned prompt actors
  after Captain Bezique and Master Reisa,
  respectively. Preserve first-stage
  NPCs, race/Fighter identity, source
  class choice, actual 10-stud distance,
  living player, per-NPC ordered stage,
  interaction throttle and single-use
  owner-specific server world receipt.
- [x] Source-stage `available`,
  `verify` and `_talk` now check the
  physically registered actor for the
  **exact current stage**; stage three
  (real dungeon quest monsters and item
  drops) remains inaccessible, not
  silently authorized by the presence
  of an NPC in the hub.
- [x] Authentic Rogue Neti talk
  **atomically** grants one personally
  bound `neti_trial_dagger` and one
  `neti_trial_bow` inside the same
  original quest profile mutation.
  Both are real, Fighter-equippable
  Dagger/Longbow inventory gear;
  trade and shared bank refuse them.
  Repeating the NPC cannot duplicate
  quest gear or skip ordered stages.
- [x] Authentic Elven Scout Guard
  Moretti talk updates **only its
  separate source quest stage**.
  No Rogue trial items, Prias letter
  fragments, earned kills or advanced
  class are granted to an Elf.
- [x] The existing closable first-
  transfer UI now explains which real
  second NPC is available, and
  distinguishes that meeting from
  the unbuilt later monster/quest
  stages and level-20 class award.
- [x] Actual **unpublished two-client
  Base Studio playtest PASS**: Human
  Fighter/Rogue and Elf Fighter/Scout
  chose distinct historical paths
  and completed first **and** second
  NPC prompts. The Human's Neti
  trial dagger and bow appeared
  individually and were both
  equippable by the real equipment
  service; the other player gained
  neither. Forged Neti evidence,
  wrong-race NPC, second NPC replay,
  and unbuilt stage-three advancement
  did not bypass authorization.
- [x] Focused affected suite
  **5/5 PASS**, including **125**
  original quest-stage assertions,
  actual inventory equipment/owner
  persistence through save/release/
  reload, unchanged C4 class
  choice/race restrictions,
  unchanged 0/18 full original
  path coverage and quest-profile
  migration. Existing one-client
  actual Bezique first-stage
  gameplay test also **PASS** after
  updating the now-live second-
  stage availability expectation.
- [x] Changed Luau sources parse;
  disposable Base and Dungeon
  Rojo compositions build.
  Source, tests and roadmap edits
  made directly in GitHub.
  Remote Desktop Commander used
  only for clean local pull,
  read-only diagnostics, builds
  and unpublished Studio tests.
  Unrelated quadruped local
  Python caches untouched.
  See [v1.93 genuine NPC and
  two-client test evidence](
../testing/c4-original-second-npc-v1-93-20260923.md).

## Next original C4 class backend work

- [ ] **Human Rogue stage three:**
  author real instanced source
  Spartoi/skeleton encounter
  with valid party/session/room
  identity, alive NPC state,
  genuine server-authoritative
  combat damage and original
  Neti trial weapon equipped.
  Each qualified kill yields
  exactly one bound source bone
  proof, with **ten distinct
  server-owned kill receipts**,
  no fake client or duplicate
  credit, no borrowed bone
  from another character,
  no unearned profession
  or quest shortcut.
- [ ] **Elven Scout stage three:**
  author real Ol Mahum patrol
  encounters within a protected
  instanced quest room, with
  four separately owned genuine
  letter-fragment drops and
  receipt deduplication.
  An Elf must not use Rogue
  trial equipment/kill receipts
  as source quest proof.
- [ ] After genuine combat
  evidence, bind actual return
  to Neti, Bezique and Moretti
  and physical Prias/sentry/
  bandit/letter turn-in stages
  as appropriate. Each quest
  source item and transfer
  recommendation must come
  from a validated world or
  inventory transaction and
  persist on its rightful owner.
- [ ] **Final original level-20
  transfer:** require the exact
  historical class-choice
  branch, authentic completed
  quest plus owned proof,
  race/starting family/level,
  unclaimed previous transfer
  and fully implemented
  original source skill/trainer
  authority in one server
  mutation. Register Ramos
  and Rains only once real
  transfer behavior is secure.
- [ ] **Original C4 skills in
  parallel:** source-inventory
  Human Warrior/Knight beyond
  the existing 28 level-20
  source entries and implement
  the actual distinct effects,
  trainer permissions, skill
  prerequisites and mastery.
  Reaudit Human Rogue/Elven
  Scout functional analogue
  ranks against complete
  original source lists.
  Do not describe the six-
  list 396/396 analogue
  subset as complete C4
  class/skill parity.
- [ ] Later Human/Elf Mystic
  original alternatives,
  Dark Elf/Orc/Dwarf races,
  second/third transfer trees
  and versioned opt-in legacy
  specialist save migration.
- [ ] After real quest enemies
  and drops exist, playtest
  both original branches through
  actual source combat,
  authenticated item turn-in,
  class award, class-specific
  skill use and persistence
  with two separate clients.
  Do not publish before
  requested.

## Current readiness (do not overclaim)

**18** original five-race first-transfer
branches are source catalogued.
Fresh currently playable races:
Human and Elf, starting Fighter or
Mystic only. Genuine source NPC
stages one **and two** are
playable for Human Rogue and
Elven Scout in the Base.
Human Rogue owns actual trial
weapons only after Neti;
Elven Scout has reached the
real Moretti conversation.
Authenticated instanced source
monster/drop stages and actual
level-20 original class awards:
**NOT IMPLEMENTED**.

**Original class paths fully
playable: 0/18**. Actual
C4 original full skill
catalogue: INCOMPLETE.
