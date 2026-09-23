# DungeonMMO backend roadmap v1.94 — original C4 stage-three proof foundation

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Predecessor: [v1.93 genuine Neti and Moretti NPCs](
DungeonMMO_Roadmap_v1_93_C4_Neti_Moretti_Quest_20260923.md)

## Current scope: staged backend only

- [x] Add separate original Human Rogue `spartoi_bone` and
  four distinct Elven Scout `prias_letter_1` through
  `prias_letter_4` definitions. All are owner-bound,
  non-tradeable and non-bankable quest materials.
- [x] Add one server-side profile mutation combining the
  already world-verified monster event, stable monster-life
  receipt, original source proof, bound item grant and
  ordered quest counter. No drop is granted if any
  validation fails.
- [x] Human Rogue skeleton progress requires the real owner
  to have Neti's personal trial dagger or bow equipped,
  with both original weapons owned. Ten authenticated,
  distinct kills are necessary to create ten personal
  bones and derive `SpartoiBone10`.
- [x] Each Elven Scout Ol Mahum kill may grant precisely
  one *new* letter fragment. Duplicate letter proofs,
  one kill claiming multiple fragments, and an old
  monster life presented under a new event ID are refused.
- [x] Actual Neti and Moretti stage-four return validation
  now requires the complete, personally owned stage-three
  source loot, as well as accumulated source proof.
- [x] Extend the existing source quest fixture with
  no-equipped-weapon denial, missing life receipt,
  duplicate monster-life receipt, multiple-letter denial,
  ten genuine distinct test receipts, four individual
  fragments and owner-specific save/reload checks.
  **These are simulated server fixture events, not
  physical monster kills.**
- [x] Disposable local Rojo Base and Dungeon builds
  completed successfully after GitHub fast-forward pull.
- [ ] Run the focused unpublished Studio test suite after
  the latest changes and record the actual outcome;
  no Studio test result is claimed in this version.

## Next: bind genuine stage-three combat, then complete source quests

- [ ] Author instanced original Rogue trial skeleton/Spartoi
  and Elven Scout Ol Mahum patrol encounters, using the
  existing dungeon run/party/room lifecycle. They must
  have unique server-owned encounter ID and enemy life ID.
- [ ] Instrument the real server damage/kill authority to
  establish the participating quest owner's contribution,
  last valid trial weapon at attack time, live monster death,
  run/session/room identity, and exactly one death receipt.
  **A client hit report, event flag, mere party membership,
  ordinary shared monster reward or arbitrary
  `ServerVerified` boolean is not sufficient proof.**
- [ ] Bind the actual quest service to that trusted
  instanced combat receipt only, and never expose its
  verifier or evidence-creation function to remotes.
  Reject spectator, outsider, wrong branch, mismatched
  session and stale/disconnected character evidence.
- [ ] Preserve each bound quest item on the rightful
  character when returning from Dungeon to Base. Test
  separate owners, disconnect/rejoin and replay attacks
  across a fresh world adapter; do not lose progress
  during the existing teleport/profile handoff.
- [ ] The current first/second-stage NPC world binder must
  remain unchanged and fail closed for stage three until
  real quest monsters and server combat receipts are wired.
  The original full path remains **0/18**, and the original
  level-20 class award remains unimplemented.
- [ ] Next bind real Neti/Moretti turn-ins, Cats Eye
  Bandit loot, Prias and sentry/key, subsequent source
  NPC stages and original level-20 Ramos/Rains transfer.
  Continue original distinct C4 first-transfer
  skill/trainer authority in parallel.

## Existing design decisions retained

Five original Chronicle 4 race/class trees, Fighter/Mystic
fresh starters (Dwarf Fighter only when implemented),
explicit original class-branch choice and original
advancement quests remain authoritative. DungeonMMO keeps
hub-based instanced travel, one Gathering and one Crafting
profession, player trading, existing saves, and separate
humanoid/quadruped animation roadmaps. Do not merge
to `main`, publish Roblox places or modify production
DataStores without explicit instruction.
