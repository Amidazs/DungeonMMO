# DungeonMMO backend roadmap v1.97 — stage-five/seven Rogue, Cinder and return

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Previous: [v1.96 physical stage-three and stage-four return](
DungeonMMO_Roadmap_v1_96_Source_Quest_Combat_And_Return_20260923.md)
Test record: [v1.97 executed unpublished Studio checks](
../testing/c4-original-quest-stage5-7-handoff-v1-97-20260923.md)

## Done and actually tested

- [x] Keep original visible DungeonMMO identities: Captain Ashford,
  Quartermaster Vela, Pathfinder Elyra, Warden Thorne, Crypt Sentinel,
  Bracken Raider and Cinder Brigand. Saved legacy C4 quest/item proof
  identifiers are unchanged until a versioned migration is tested.
- [x] Existing real Base captain now accepts an **ordered stage-five**
  Human Rogue report after completed Vela trial proof, and a real
  **stage-seven** return after a separately earned Cinder recovery.
  Real physical two-client prompt playtest passed. The initial
  stage-seven missing-item attempt cannot skip the stage, successful
  return consumes all four separately owned quest items in one
  profile transaction, and replay cannot repeat the award.
- [x] Source-specific optional **Cinder Brigand** monsters spawn in
  instanced ordinary combat rooms only when an active Human Rogue
  has reached source quest stage six. Each real monster has a
  unique server-owned life/encounter identity. Its actual
  contribution-authorized death grants exactly four bound
  originally named supply materials and saved legacy proof flags
  to the rightful player, with no Elf or spectator loot sharing.
- [x] Fix real regression found during expanded live testing:
  zero-XP/empty-bestiary quest enemies were failing
  `EncounterService:on_enemy_died` with `InvalidMonsterReward`,
  blocking room progression. Now every optional source enemy has
  a valid minimal normal reward (1 XP/0 gold and temporary
  known placeholder bestiary ID). An actual two-client
  stage-three → next-room stage-six live test subsequently
  completed successfully.
- [x] Preserve unrelated ordinary dungeon reward,
  difficulty and threat paths while observing validated damage.
  Focused Dungeon suites **3/3 PASS**: registration 10,
  mixed-branch stage-three/stage-six spawn/reward 24 and
  contribution fan-out 13 assertions.
- [x] Focused Base progression/skills/migration suite
  **5/5 PASS**, including **165** original source quest
  assertions for Cinder grant/consumption and reload.
- [x] Genuine two-client Base physical NPC test passed
  first/second-stage prompts, stage-four turn-in,
  new stage-five Ashford report and stage-seven final source
  turn-in; all without granting an unfinished class.
- [x] Real coordinator saved source owners before simulated
  cross-server routing. Fresh destination ProfileService
  instances, backed by the same deterministic stored profiles,
  preserved 10 Rogue crypt fragments, four distinct Elf report
  fragments and later four Rogue Cinder supply items.
  Handoff-focused Studio fixture **58 assertions PASS**.
  **It does not simulate a real Roblox cross-place transport.**
- [x] Original Human Rogue *source quest* can now reach
  `Ready` after all seven ordered steps via available
  authenticated NPC/combat bindings. Advanced-class transfer
  at level 20 remains unavailable.

## Next backend execution order

1. Test actual two-client end-to-end Base → Dungeon → Base
   transport with the real handoff/lease, persistent
   quest materials and stage-four/seven physical NPC
   returns. An unpublished local Studio multi-place
   test is not equivalent to a published cross-place
   teleport; do not publish without explicit approval.
2. Run full ten/four individual player-controlled kills
   across multiple dungeon rooms or a second run, with
   reconnect/wipe/retry, outsider/spectator exclusion,
   distinct item ownership and no replayed death receipts.
   Current real live fixtures used server-side finishing
   damage and **test-only stage advancement** to isolate
   later combat, not a full uninterrupted quest run.
3. Add an independently authored Elven Scout side encounter:
   find trapped Scout Cael within an instanced room, defeat
   an actual stage-six Bracken Warden, earn one owner-bound
   key and authenticate physical rescue/return to
   Warden Thorne and Pathfinder Elyra. Preserve the
   race/Fighter/quest branch, personal-item and party
   restrictions. Use original names, dialogue, layouts,
   silhouettes and mission beats; avoid reproducing
   another game's exact expression.
4. Implement distinct level-20 transfer mentor(s),
   authoritative verified source-quest completion,
   required character level and prerequisites,
   permanent original first-transfer class identity,
   new trainer/skill visibility gates and exact
   save/reload/rollback behavior. A merely `Ready`
   source quest cannot grant a class by itself.
5. Expand original first-transfer branches and
   individually reviewed skills/quests, remaining
   racial paths and subsequent advancement, without
   exposing unfinished advanced skills.
6. Replace placeholder Marauder quest rigs and
   temporary bestiary key with separate original
   DungeonMMO monsters, navigable source-specific
   arenas, authored animations, dialogue and UI polish.

## Project guardrails and status

Fully playable first-transfer advanced classes: **0/18**.
Human Rogue source quest steps one through seven have
genuine NPC and instanced enemy integrations, but the
complete uninterrupted real cross-place gameplay route
and advanced-class award are **not accepted**. Elven
Scout source steps one through four are live; later
Scout Cael/key/rescue and mentor stages are still
unimplemented. No level-20 original class/skill
award, `main` merge, Roblox publication or
production DataStore mutation.

Keep the existing hub-and-instanced-dungeon structure,
all-party difficulty unlock gating, animal-only
skinning, closest-before-damage/highest-threat
aggro, one Gathering and one Crafting profession
per character, player trading economy and separate
humanoid/quadruped animation roadmaps. All scripts
and documents stay edited in GitHub; Desktop
Commander may only pull/build/playtest as agreed.
