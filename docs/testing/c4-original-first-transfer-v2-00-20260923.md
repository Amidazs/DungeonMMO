# DungeonMMO v2.00 — two-class skills and real trainer client acceptance

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Previous: [v1.99 physical class awards](
c4-original-first-transfer-v1-99-20260923.md).
All permanent changes went directly into GitHub.
Local desktop use was restricted to a clean pull, temporary Rojo
builds and unpublished Roblox Studio test runs. No place publication,
`main` merge, production DataStore change or local source edit.

## New authoritative DungeonMMO class abilities

- **Ashenblade Opening** (`AshenbladeOpening`): Human Fighter who
  actually earned the Human Rogue source quest and Marshal Briar's
  Ashenblade award. Level 24 first rank requires the pre-transfer
  `FighterDaggerStrike` purchased rank 3 and 80 actual use
  proficiency. Rank two requires character level 28 plus 80 use
  proficiency earned on the new ability. A real dagger must be
  equipped for combat. Both ranks use the existing authoritative
  dagger hit executor; server damage rises from 20 to 27 before
  the ordinary combat modifiers.
- **Greenward Renewal** (`GreenwardRenewal`): Elf Fighter who
  earned the Elven Scout source quest and Pathwarden Siora's
  Greenward Scout class. Level-24 first rank requires the previously
  purchased `ElvenFighterRenewal` rank 1 and 30 earned use
  proficiency. Rank two requires level 28 plus 80 use proficiency
  on the new ability. Both ranks use the real server-owned
  self-healing executor; base restoration increases from 35 to
  52 before ordinary healing modifiers.
- Both are separate DungeonMMO authored class abilities,
  rather than an automatic remapping of legacy Rogue/Ranger
  skill catalogues. They are absent from unadvanced starter
  trainers and other classes' transfer catalogues. The normal
  trainer remains the sole way to purchase their ranks and
  spends earned SP. Quest completion never grants them for free.
- Existing original level-20 Ashenblade Sprint and Greenward
  Scout Guard remain unchanged; each first-transfer class
  now has **two implemented trainable abilities**. This does
  not complete either first-transfer skill catalogue.

## Actual executed acceptance

1. Disposable **Base and Dungeon Rojo builds PASS** after the new
   skill registration. No production publishing.
2. Focused actual Base Studio script
   `scripts/studio/c4_original_first_transfer_focus.luau`:
   **2/2 PASS** with **93 original-transfer assertions** and
   **8 adjacent quest/advancement migration assertions**.
   It exercised genuine ProfileService and
   SkillProgressionService purchase/save/load paths with
   test-only prepared earlier earned source/skill progress.
   Tested level-20 lock, level-24 prerequisite purchased
   ranks and earned use proficiency, level-28 second rank
   and actual use proficiency, correct advanced trainer
   offers, per-class real rank-scaled combat/heal definitions,
   durable both-class rank-two saves and fresh-profile
   reloads. The Combat runtime test additionally checked
   an unequipped Ashenblade dagger strike is refused, a
   properly equipped/earned ability can pass runtime
   authorization, and replacing the earned current class
   with Fighter blocks that ability. This is a runtime
   *authorization/definition* test, not a live enemy hit
   or live self-heal cast.
3. The first added runtime check encountered a **FAILED**
   focused handoff test: after the test-only dagger equipment
   mutation, `forget_for_handoff` correctly rejected a dirty
   profile. The test now saves that real test mutation
   before releasing its writer; the final 2/2 suite passed.
4. The dedicated unpublished real **two-client Base Studio**
   physical mentor/trainer test
   `scripts/studio/c4_original_first_transfer_two_client_live.luau`
   **PASSED for both classes**, confirmed by
   `REAL_CLIENT_TRAINER_Ashenblade_PASS`,
   `REAL_CLIENT_TRAINER_GreenwardScout_PASS` and
   `VERIFIED_TWO_CLIENT_FIRST_TRANSFER_PASS`.
   Each client physically held its own original class
   mentor prompt and received its earned original class.
   With level-24/prerequisite progress prepared in that
   **disposable test only**, the client interacted with
   the separate registered `ProgressionTrainerPrompt`,
   received the correct server trainer catalogue and
   observed the new advanced skill in the real in-game
   trainer window. The actual client then issued its
   `SkillLearnRequest` and received an authenticated
   server `ProgressionActionResult`. Requests made while
   physically out of range, using the other class's
   trainer ID and with exhausted earned SP were rejected
   and did not award the skill or cross-grant it to the
   other client. The eligible owner bought one saved
   level-24 rank. The client test explicitly sent the
   existing request remote after showing the UI; it
   **did not synthesize a mouse click on the Learn button**.
5. The first attempt to create a no-SP case by setting
   entitlement to zero **FAILED the new negative test**:
   profile migration correctly restores the skill point
   entitlement earned by a level-24 character. The test
   was corrected to seed previously purchased permitted
   Fighter ranks in its isolated fixture to exhaust
   that entitlement; the final real two-client test passed.
   Neither of these test-only skill fixtures grants
   starting players new abilities.

## Outstanding, not covered by these claims

- The two new skills have been validated via actual server
  combat definition/rank and runtime authorization, but
  **a client-controlled Ashenblade hit on a real monster
  and a real Greenward self-heal cast are still pending**.
  So are a true UI Learn-button activation test, simultaneous
  skill requests, full reconnect/wipe/retry, multiple trainer
  visits and uninterrupted real multi-place travel.
- Both level-24 class prerequisites were explicitly
  prepared in test fixtures; an end-to-end player-earned
  proficiency journey was not demonstrated.
- The earlier source quests and mentor class-awards were
  accepted in separate live tests. The v2.00 focused
  trainer test seeds completed quests in disposable Base;
  it is not proof of an uninterrupted Base → Dungeon →
  Base journey, nor does it authorize Roblox publishing.
- Other class skills/first transfers and independently
  authored character art, monster models and narrative
  remain in the separate roadmap backlog.
