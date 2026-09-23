# DungeonMMO backend roadmap v1.92 — real original C4 quest starters

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`

## Design that remains authoritative

DungeonMMO follows original **Lineage 2 Chronicle 4**:
five original race sources, Fighter/Mystic starting
families where historically supported (Dwarf: Fighter
only), explicit level-18 first-transfer branch
selection, authentic branch-specific quests and
level-20 class awards, followed by original
level-40 and level-76 advancement trees.
Hub-and-instanced-dungeon travel remains the
DungeonMMO world rule, not an open-world redesign.

This supersedes [v1.91 original C4 quests and skills](
DungeonMMO_Roadmap_v1_91_C4_Quest_And_Skills_20260923.md)
for **current C4 backend work** while retaining
its authentic quest source sequence, original
Warrior/Knight rank inventory and unresolved
source-vs-analogue skill gap. The separate newer
humanoid/quadruped animation/art roadmap is
not superseded.

## Newly implemented and verified

- [x] The live Base now registers genuine physical
  **Captain Bezique** and **Master Reisa** hub
  NPC prompts as backend-only placeholder parts
  near its resolved spawn anchor. These are the
  original first talk actors for Human Rogue
  and Elven Scout; no final art is required.
- [x] The server validates a real player, loaded
  selected profile, living avatar, server-owned
  10-stud physical proximity, correct original
  race/Fighter family and explicit saved branch
  before starting the corresponding genuine
  original quest. It generates a one-use
  server-only event receipt and commits
  precisely its first ordered NPC stage
  through the original persistent quest service.
  No client may submit a monster kill,
  source quest drop, stage number or
  advanced class as proof.
- [x] The existing closable class-path GUI
  receives the real original quest snapshot
  and displays the first NPC progress without
  implying the rest of the original C4 quest
  can already be completed.
- [x] Current physical world availability is
  **stage-specific**. After the first real
  NPC talk, the next unbuilt source world
  step is blocked by
  `OriginalQuestWorldNotReady`. The
  `FirstNpcReady`, `WorldReady` and
  `FullWorldReady` fields distinguish
  a first actor from a completely playable
  historical quest. Client requests
  cannot skip forward to Neti, bandits,
  Moretti, Ol Mahum, Prias or transfer NPCs.
- [x] An unpublished **actual one-client
  Base playtest PASS** observed a genuine
  client `ProximityPrompt` hold:
  unchosen class refusal, Human Fighter
  level-18 Rogue choice, actual Captain
  Bezique event and persistent stage-two
  snapshot, exact original class
  remaining Fighter, blocked unbuilt
  next stage, first NPC replay denial
  and honest actual client GUI.
  Only the test session's source level
  was seeded; this is not a full
  real-world dungeon playthrough.
- [x] Affected original C4 source quest,
  selection, coverage and profile
  migration Studio regression
  **5/5 PASS**, including **117**
  original stage/skill-source assertions.
  Changed Luau parses and disposable
  Base/Dungeon Rojo builds PASS.
  [v1.92 actual test evidence](
../testing/c4-original-first-npc-v1-92-20260923.md).
- [x] All code, testing and docs edited
  **in GitHub**. Remote desktop used
  only for clean pulls, disposable
  parser/build, diagnostic logs and
  unpublished Studio testing. Unrelated
  untracked quadruped Python cache
  was not modified. No `main` merge,
  publish, production DataStore
  mutation or paid action.

## Next — actual original quests AND original skill trees

- [ ] **Bind the next hub NPC stages to genuine
  authored rewards.** Human Rogue:
  secure Neti NPC proximity and genuine
  separately owned trial dagger/bow
  inventory; returning to Neti and
  Bezique must require real monster
  receipts and quest-item proof.
  Elven Scout: real Moretti NPC and
  its actual letter-fragment handoff
  into the selected original source
  quest. Do not set
  `TrialWeaponsGranted` on an
  event until the two real Neti
  weapons have been atomically
  supplied/owned by that character.
- [ ] **Build secure instanced quest
  combat and drops** without
  inventing open-world travel.
  Original Rogue Spartoi/skeleton
  combat needs ten unique validated
  bone drops with its real trial
  weapon and Cats Eye Bandit
  requires four distinct actually
  earned stolen items. Elven
  Scout Ol Mahum patrols must
  yield four distinct letter
  fragments and sentry key;
  Prias must be a genuine
  rescuable world actor.
  Bind each victory to
  authenticated server combat/
  loot authority and the correct
  party/instance/quest owner;
  no client-forged `ServerVerified`
  or repeating one kill/dropped
  object for multiple quests.
- [ ] **Authentic source NPC completion
  and level-20 atomic transfer.**
  Verify Ramos and Rains transfer
  NPCs, exact selected C4 branch,
  original stage/quest-item proofs,
  level, race, Fighter/Mystic
  family, already-earned legacy
  history and eventual original
  class-specific training gates
  inside one authoritative
  profile mutation. No quest
  stage or mere selected choice
  grants an advanced class.
- [ ] **Original class skill work in
  parallel**, not after all
  quests. Complete real original
  Warrior/Knight C4 source
  inventories beyond the
  currently enumerated 28
  level-20 source entries,
  implement their distinct
  owned source skill ranks/
  weapon effects, mastery and
  trainer prerequisites. Then
  source-audit the existing
  Rogue/Scout 228 analogue
  ranks and the four original
  starter inventories before
  certifying exact original
  C4 skill parity. Move on to
  the other fourteen currently
  unmapped original full
  first-transfer skill lists.
- [ ] Enable authentic Human/
  Elven Mystic alternatives
  (Wizard/Cleric and Elven
  Wizard/Oracle), then the
  original Dark Elf, Orc and
  Dwarf race families with
  complete starting skills/
  race stats and actual unique
  first-transfer quests, not
  bare registry names.
- [ ] Continue the original
  level-40 and 76 class
  transfer source trees after
  implementing their lower
  prerequisite class paths and
  genuine mastered skill ranks.
- [ ] Maintain exactly **one
  Gathering and one Crafting
  profession** per character,
  original subclass/race
  exclusivity, trade economy,
  party difficulty, dungeon
  combat and profile history.
  Do not reset or silently
  award an original advanced
  class to an old Ranger/Rogue
  or legacy custom-advancement
  save; versioned opt-in
  migration remains pending.
- [ ] Actual two-client
  different-branch quest
  playtest after real quest
  combat actors are present:
  independent original NPC
  and loot evidence,
  successful real source
  NPC class transfers,
  correct mutually exclusive
  new class skills, rejoin
  persistence and replay/
  wrong-race protection.
  v1.92 tested only one
  genuine Human Rogue client
  physical first NPC; Elven
  Scout NPC is registered
  but not separately accepted
  through a real Elf client.

## Honest current game readiness

- Source-only five-race original first-transfer
  registry: **18** historically distinct paths.
- Fresh playable race/start options: Human/Elf
  Fighter/Mystic only; no advanced starter.
- Explicit original first-transfer choice:
  implemented, previously tested with
  two independent real clients.
- **Physical original quest stage-one start:**
  Human Rogue tested with an actual
  client; both Human Rogue and
  Elven Scout hub NPCs bound in Base.
- Original historical quests fully
  playable end-to-end: **0/18**.
- Exact original first-transfer classes
  earned with genuine finished quest
  and authentic source skill tree:
  **0/18**.
- Existing 396 functional-analogue
  ranks across six partial
  inventories **do not certify
  full original C4 class/skill
  implementation**. Entire
  Chronicle 4 game class system
  remains INCOMPLETE.
