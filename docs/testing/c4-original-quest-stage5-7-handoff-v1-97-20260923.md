# DungeonMMO v1.97 — source quest handoff, Cinder combat and final captain test

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Scope: Unpublished local Studio only. This document records both the
initial unsuccessful extended combat test **and** the successful
regression after correcting the cause. No published Roblox place,
cross-place live teleport, production DataStore or final class award.

## Work committed directly in GitHub

- Added owner-specific source quest save/reload acceptance across actual
  `TeleportCoordinator:return_to_base` profile saves, simulated routing
  and two **separate** `ProfileService` caches sharing the same
  deterministic in-memory storage adapter. Human's 10 personal Crypt
  Sentinel Fragments and Elven Scout's four distinct Cael report
  fragments survived the first return without being inserted into
  teleport routing data; an independently earned four-item Cinder cache
  survived a second mocked return. The quest state, proof ownership
  and original Fighter class identity survived both transfers.
- Added a genuine **stage-five Captain Ashford** ProximityPrompt return
  on the existing original-named physical Base NPC. Only the actual
  owner with completed personal Vela trial proof reaches the stage-six
  combat quest, without awarding any new class.
- Added actual server-instanced **Cinder Brigands** only for connected,
  active Human Rogue owners currently at stage six. A Cinder monster
  is a physical combat model with its own exact encounter identity,
  source-monster ID, stage-six binding and one-life receipt. The
  server-owned source quest damage ledger authenticates real player
  contribution and an equipped Vela trial weapon; one qualified
  Cinder defeat awards four **separate** personal bound supply items
  and moves the character to stage seven. Legacy saved quest proof
  keys were kept while the four player-facing item names and supply
  recovery storyline are original DungeonMMO content.
- The physical Captain Ashford prompt now handles stage-seven return.
  It requires the accumulated four unique source proofs **and**
  ownership of all four actual bound materials, consumes all four
  in the same authoritative character-profile mutation, and marks
  the Human Rogue **source quest** ready. Source completion does
  **not** grant the unfinished level-20 advanced class or skills.
- Corrected the quest-monster reward contract: the first extended
  two-client test showed that zero quest-enemy XP and an empty
  bestiary ID caused `EncounterService` to refuse enemy death with
  `InvalidMonsterReward`, preventing an instanced room from
  clearing. Source monsters now have a valid minimal ordinary
  reward (1 XP, zero gold and a temporary known bestiary key) so
  their deaths count toward real encounter completion. The
  temporary Marauder rig/bestiary mapping will be replaced by
  independently authored source monsters later.

## Actually executed Studio checks

1. Disposable Base and Dungeon Rojo builds: **PASS** after GitHub
   fast-forward pulls. Existing unrelated untracked local quadruped
   caches were left untouched.
2. Focused Base source quest, class/skills and migration suite:
   **5/5 PASS**, including **165** source quest assertions
   after four Cinder material grants, consumption and save/reload.
3. Focused Dungeon registration/contribution/quest tests after the
   ordinary-reward fix: **3/3 PASS**, comprising physical ledger
   **10 assertions**, optional mixed-branch stage-three/stage-six
   packs and valid reward attributes **24 assertions**, and existing
   damage/contribution fan-out **13 assertions**.
4. Focused actual source-profile persistence test:
   **1/1 PASS, 58 assertions**. Two owners earned 10/4 fragments
   through *authenticated server fixture events* (not client
   monster attacks). The real coordinator saved each actual owner
   before simulated routing; two new profile caches recovered
   personal items, ordered progress and appropriate proofs.
   A separate four-item Cinder cache also survived a subsequent
   saved return. No actual multi-place Roblox teleport was used.
5. Actual unpublished **two-client Dungeon live test**:
   `scripts/studio/c4_source_quest_two_client_dungeon_live.luau`.
   Both clients joined one real dungeon instance. Crypt Sentinels
   and Bracken Raiders physically spawned in the first triggered
   combat room, a genuine normal player client attack struck an
   authenticated Crypt Sentinel, and each distinct contributor
   gained only their own source quest material from an actual
   server-authoritative lethal damage event. To isolate the next
   story step the Human test profile was then moved to stage six
   **in temporary Studio code**, and leftover room-one enemies
   were defeated by the test driver. The next physical room
   spawned a real Cinder Brigand. A normal client attack struck
   it and subsequent server-authoritative lethal damage granted
   exactly the four correct personal supply items and advanced
   Human Rogue progress to stage seven; the Elf gained none.
   Final Studio marker:
   `[C4 Source Two Client] VERIFIED_REAL_DUNGEON_COMBAT_PASS`.
   **The lethal finishing blows came from the server-side
   playtest, not uninterrupted player-controlled combat.**
   The earlier extended attempt timed out because invalid
   zero-XP monster rewards blocked room clear; the production
   reward contract was fixed and the subsequent live test passed.
6. Actual unpublished **two-client Base NPC live test**:
   `scripts/studio/c4_original_second_npc_two_client_live.luau`.
   Real client prompt interactions passed first/second-stage
   NPCs, stage-four personal-material checks and consumption,
   the new stage-five Ashford report, and stage-seven Ashford
   cache-material ownership/consumption and source-quest
   completion. Stage-four and stage-seven completed item
   inventories were **test-only seeded in the Base fixture**,
   not transferred from the separate Dungeon live playtest.
   Missing personally owned items and repeated prompts could
   not complete steps; the unrelated Elf remained on her
   separate source quest; neither character received a new
   advanced class. Final Studio marker:
   `[C4 Original Second NPC Live] VERIFIED_ROGUE_FINAL_SOURCE_PASS`.

## What remains unverified or not implemented

The real uninterrupted live Base → Dungeon → Base trip for both
clients, ten/four completely player-controlled kills across
multiple rooms/runs, disconnect/reconnect, wipe/retry, rollback on
a failed cross-place lease/teleport and no extra materials across
room retries are **still outstanding**. The temporary Cinder
stage-six fixture cannot substitute for playing the earlier
stages in the same uninterrupted session.

The physical later Elven Scout rescue, Bracken Warden key,
Scout Cael return, Warden Thorne report and Pathfinder Elyra
recommendation are not implemented. The Human Rogue *source
quest* can now reach `Ready`; its actual level-20 named
mentor, original advanced-class identity grant, trainer and
skill unlocks are still missing. **Fully playable original
first-transfer advanced classes: 0/18.** No publication,
merge to `main`, or changes to production DataStores.
