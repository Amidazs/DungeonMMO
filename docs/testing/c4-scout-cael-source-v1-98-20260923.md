# DungeonMMO v1.98 — Scout Cael and Bracken Warden acceptance

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Execution: disposable unpublished local Base and Dungeon Studio places.
No `main` merge, Roblox publication or production DataStore write.

## Implemented directly in GitHub

- A stage-five/seven physically registered **Scout Cael** is available
  inside eligible instanced combat-pack rooms to connected, active
  Elven Scout owners, not to spectators or an unrelated Human Rogue.
  The server creates its own ProximityPrompt, confirms the genuine
  player is alive and within ten studs, validates current
  instance/encounter membership and consumes an exact one-use
  player-bound NPC event. No client remote accepts quest proof.
- For a Scout who reaches the rescue stage, the same room also
  generates one physically authenticated **Bracken Warden** with
  the exact stage-six monster identity and unique encounter/life
  receipt. A stage-five discovery prompt advances the individual
  Scout to stage six; a qualified server-authoritative kill then
  grants one personally bound **Bracken Ward Sigil** and legacy
  saved `RustedKey` proof. The stage-seven Cael prompt
  requires that specific owner's sigil, consumes it in the same
  character-profile mutation as stage advancement, and leaves
  proof and progress available for subsequent hub reports.
- The existing physical **Warden Thorne** and **Pathfinder Elyra**
  prompts now authenticate Scout stages eight and nine in the
  hub, respectively. Both stages require the previously earned
  sigil proof, remain single-use, and mark only the *source quest*
  ready. They do not grant level-20 classes or skills.
- The visible source story now concerns a Bracken ward sigil
  at an overgrown outpost rather than a copied shackle-key
  description. `RustedKey` remains solely an opaque legacy
  saved proof key. Final story, visual silhouettes, dialogue
  and assets still require distinct original DungeonMMO
  authoring rather than reliance on changed labels alone.

## Actual focused Studio results

- Disposable Base and Dungeon Rojo builds: **PASS**.
- Focused Base quest/selection/class/skill/migration suite:
  **5/5 PASS**, including **170 source-quest assertions**.
  The new assertions cover Warden sigil ownership, bound
  trade/bank restrictions, missing-item rescue rejection
  and item consumption. These proof events use an isolated
  server fixture, not simulated player input.
- Focused Dungeon source-pack/ledger/contribution suite:
  **3/3 PASS** (the prior stage-three/six regression,
  **10 + 24 + 13 assertions**); the new physical rescue
  NPC was instead exercised by the live two-client test.
- The first real two-client Scout run spawned Cael and
  the Warden but timed out on stage-five discovery because
  the client attempted to hold the prompt before Roblox
  had shown it. The test-only client driver now waits for
  a genuinely visible ProximityPrompt before holding it.
  The corrected second run completed successfully.
- **Real two-client Dungeon Scout rescue: PASS**.
  `scripts/studio/c4_scout_cael_two_client_dungeon_live.luau`
  joined two clients in one active instanced room. The
  Human could not advance the Elf's stage by interacting
  with Cael. A real client hold on Cael's prompt advanced
  only the eligible Elf to stage six. A real Elf client
  normal attack damaged the physically registered Warden;
  an authoritative server finishing blow awarded exactly
  one owned sigil and advanced to stage seven. Removing
  that sigil in the disposable test caused the real Cael
  prompt to deny rescue. Restoring that *previously earned*
  item allowed a real owner prompt to consume it and
  advance to stage eight; replay could not advance further.
  The other client gained no sigil or advanced class.
  Recorded final marker:
  `[Scout Cael Live] VERIFIED_TWO_CLIENT_SCOUT_RESCUE_PASS`.
- **Real two-client Base hub reports: PASS**.
  `scripts/studio/c4_original_second_npc_two_client_live.luau`
  retained prior genuine NPC acceptance, then separately
  seeded the Elf's completed earlier rescue at stage eight
  *in the disposable Base test only*. The actual Warden
  Thorne prompt refused a missing earned key-proof claim;
  the actual Thorne and Pathfinder Elyra prompt holds
  accepted the valid ordered reports and readied the
  Scout source quest. Neither character received an
  advanced class. Recorded marker:
  `VERIFIED_SCOUT_SOURCE_COMPLETE_PASS`.
- **Owner-specific persistence: PASS, 66 assertions**.
  The focused `C4OriginalQuestHandoffTest` used the real
  save-before-handoff coordinator and new destination
  ProfileService caches sharing a deterministic in-memory
  store. It checked earlier Human 10/Elf 4 material
  ownership, later Cinder supplies and the additional
  Warden sigil across a separate simulated return.
  **This was not an actual live Roblox cross-place
  teleport or an uninterrupted multi-place quest run.**

## Outstanding before playable first-transfer class awards

The full uninterrupted Base → Dungeon → Base quest journey,
complete ten/four player-controlled victories across rooms
and runs, reconnect/wipe/retry, actual cross-place lease
transfer and persistent item handoff are not accepted yet.
Scout stage-five discovery/warden kill/rescue and final
Base reports were separate clearly test-only seeded
two-client sessions. The Warden finishing blow was
server-applied; only the initial client attack was
player-input-driven. The NPCs are temporary parts and the
Warden reuses an ordinary Marauder combat rig and reward
identity. Neither first-transfer class is yet granted.
**Completed first-transfer advanced classes: 0/18.**
