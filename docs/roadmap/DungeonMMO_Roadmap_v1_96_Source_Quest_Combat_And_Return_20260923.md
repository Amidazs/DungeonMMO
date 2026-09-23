# DungeonMMO roadmap v1.96 — original quest stage-three combat and return

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Previous: [v1.95 original names and combat ledger](
DungeonMMO_Roadmap_v1_95_Original_Quest_Names_Combat_Ledger_20260923.md)
[Actual unpublished Studio acceptance record](
../testing/c4-original-quest-stage3-4-v1-96-20260923.md)

## Completed this stage

- [x] Preserve the original DungeonMMO NPC/monster/item names and keep
  opaque legacy storage/proof identifiers until a safe migration exists.
- [x] Spawn two physical **Crypt Sentinels** per combat room for an
  active stage-three Human Rogue and two **Bracken Raiders** for an
  active stage-three Elven Scout. Mixed eligible parties get both;
  spectators and parties without these active original quests do not.
  The temporary enemies join the same existing instanced encounter
  lifecycle, room-clear and cleanup as its ordinary enemy pack.
- [x] Register actual physical quest monster models and distinct
  server-owned life receipts; accepted damage reaches the existing
  contribution service **and** source quest observer. Unrelated
  kills, wrong-branch attacks, replayed events, unearned equipment
  claims and disconnected/ineligible members cannot supply
  source quest loot.
- [x] Human Rogue: exactly ten distinct registered source kills
  over one or more runs, with an actual trial weapon, yield
  ten personally owned crypt fragments and accumulated proof.
  Elven Scout: individually eligible distinct kills yield
  four separate personal Cael report fragments.
- [x] Reuse the existing physical **Quartermaster Vela** and
  **Warden Thorne** prompts at source quest stage four.
  Authenticated actual personal inventory and accumulated
  proof are required. The real turn-in atomically consumes
  all ten/four earned materials and advances to stage five;
  neither branch receives a class award yet.
- [x] Actual unpublished two-client Dungeon real-movement/
  client-attack/server-lethal test passed: separate original
  stage-three monsters spawned in one party's real room,
  genuine normal client damage hit a Crypt Sentinel, and
  each rightful owner earned one distinct quest material.
- [x] Actual unpublished two-client Base physical mentor
  turn-in passed for both branches, including missing-loot
  refusal, personal material consumption and replay denial.
  The Base fixture explicitly seeded complete personal
  stage-three materials for its independent stage-four test.
- [x] Focused Dungeon suite **3/3 PASS** (10 + 12 + 13
  assertions); focused Base quest/skills/profile suite
  **5/5 PASS**, including 153 quest/turn-in assertions;
  disposable Base/Dungeon Rojo builds PASS.
- [x] All source, tests and docs edited directly in GitHub.
  Remote desktop used solely for clean pulls, disposable
  builds and unpublished Studio tests.

## Remaining actual backend acceptance and development

- [ ] Execute one **continuous** Base quest start → actual dungeon
  admission/handoff → personally earned **10/4** real client kills
  across rooms/repeated runs → actual return-to-Base →
  physical Vela/Thorne stage-four turn-in **without any test-only
  character/item seeding after leaving Base**.
  Test two clients in a party, one correct owner per loot stream,
  replay, wipe/retry, spectator, reconnect and persistence.
- [ ] Dedicated original quest rooms and source-specific
  environment/monster models are future art/encounter content.
  Present integration uses optional enemies inside ordinary
  instanced combat packs and reuses provisional generic rigs;
  test actual spawn navigability, attack reach and hitboxes
  in different dungeon layouts and difficulties.
- [ ] Complete the next separately authored, original-named
  Human Rogue return to Captain Ashford and distinct Cinder
  Brigand stolen-item challenge, plus Elven Scout's real
  **Scout Cael** rescue/Bracken Warden key challenge and
  Pathfinder Elyra recommendation. None of these later
  stages is currently playable.
- [ ] Bind final original-named level-20 transfer NPCs,
  separate original first-transfer class identity awards,
  quest completion, prerequisites, proficiency, trainer
  catalogues, advanced skill unlocks and atomic saved
  transfers. **Original first-transfer classes fully
  playable: 0/18** until this is complete.
- [ ] Continue remaining original class trees, additional
  races, rank catalogues, quests and second/third class
  advancements without importing protected names,
  copyrighted dialogue, character silhouettes, assets
  or exact game-specific quest expression.
- [ ] Refine personal drop UI/status and secure any new
  cross-place quest event or snapshot: server-authoritative,
  no client-created proof receipts or free skill/class
  grants; retest only affected regressions.

## Existing project rules

Keep hub/instanced dungeon travel, one gathering and one
crafting profession per character, trade and party-difficulty
gates, animal-only skinning, existing aggro logic, and the
separate humanoid/quadruped animation roadmap. No publication,
`main` merge, production DataStore edits or local source/
document edits through Remote Desktop Commander without
explicit user approval. Preserve unrelated untracked local files.
