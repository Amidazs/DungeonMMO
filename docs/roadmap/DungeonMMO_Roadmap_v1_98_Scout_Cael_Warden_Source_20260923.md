# DungeonMMO backend roadmap v1.98 — Scout Cael and the Bracken Ward

Date: 23 September 2026
Branch: `wip/phase-4-test-hud-integration-v1`
Supersedes the [v1.97 source quest roadmap](
DungeonMMO_Roadmap_v1_97_Source_Cinder_Quest_Handoff_20260923.md)
for current original first-transfer backend status.
[Executed v1.98 Scout live Studio acceptance](
../testing/c4-scout-cael-source-v1-98-20260923.md)

## Completed backend and focused gameplay acceptance

- [x] Preserve distinct DungeonMMO player-visible actor names:
  Scout Cael, Bracken Warden, Warden Thorne and Pathfinder Elyra.
  Save-only original-era proof/item keys remain opaque legacy
  identifiers until a separate versioned save migration exists.
- [x] Physically spawn real Scout Cael only inside active
  instanced combat rooms with a participating stage-five,
  stage-six or stage-seven Elven Scout; use the same actor
  for authentic stage-five discovery and stage-seven rescue.
  Restrict physical ProximityPrompt progress to the actual
  live owner within ten studs and the correct party/session,
  with exact, single-use server-owned proof receipts.
- [x] Spawn one physical Bracken Warden in the eligible
  Scout room at stage five/six; authorize its unique
  stage-six monster-life receipt only after the actual
  Scout advances past Cael's stage-five discovery.
  A qualifying personally contributing killer earns
  exactly one bound Bracken Ward Sigil and saved original
  key-proof flag. Only the same owner can spend that
  sigil at Cael to finish stage seven; failed ownership
  checks cannot consume an item or advance progress.
- [x] Reuse the actual hub Warden Thorne and Pathfinder
  Elyra physical NPCs for ordered stage-eight and
  stage-nine reports. They require authentic accumulated
  rescue proof, reject repeated/wrong-stage prompts and
  can mark the *source quest* ready without transferring
  classes or unlocking unimplemented advanced skills.
- [x] Focused Base source quest/skills/migration:
  **5/5 PASS**, including **170 source quest assertions**.
- [x] Focused Dungeon ledger/source packs/contribution:
  **3/3 PASS**, with **10 + 24 + 13 assertions**.
- [x] Real unpublished two-client Dungeon playtest:
  physical Cael prompt, qualified Warden client attack
  and authoritative finishing damage, single owner
  reward, missing key denial, authentic rescue and
  no cross-owner class or item leakage: **PASS**.
- [x] Real unpublished two-client Base playtest:
  actual final Thorne/Elyra prompts, missing key proof
  denial and final ordered source readiness: **PASS**.
  This Base fixture explicitly seeded the earlier
  completed rescue to isolate hub-stage acceptance.
- [x] Fresh Base profile authority recovered personally
  owned Bracken Ward Sigil and saved quest proof after
  a genuine coordinator save with a simulated transport:
  combined original quest handoff fixture
  **66 assertions PASS**. This is not evidence of a
  real cross-place Roblox teleport.
- [x] Existing v1.97 Human Rogue source path is still
  implemented and previously accepted through its
  final Captain Ashford source report; both source
  paths now have authenticated stage bindings to
  `Ready`, *not* an implemented level-20 class award.
- [x] All permanent source, fixture and roadmap
  edits were made in GitHub; desktop used only for
  non-publishing pulls, disposable builds and tests.

## Next development order

1. Design and implement the genuine level-20 **DungeonMMO**
   first-transfer identities and abilities for both source
   branches. Audit current Fighter starter, existing
   secondary/legacy identities, trainer/skill catalogs,
   profile schema, equipment restrictions and combat
   authority before changing any saved class ID. Do not
   silently remap to the existing legacy Vanguard or
   Windstalker, or grant partially implemented skills.
2. Create separate named physical transfer mentors
   **Marshal Briar** and **Pathwarden Siora** in Base.
   Gate the eventual *atomic* class award on correct
   race/Fighter starting family, selected saved branch,
   actual source quest `Ready`, level >= 20, verified
   physically nearby unique mentor event, and supported
   per-class skill/trainer catalogue. Fail closed
   until the identity/migration and actual skill gates
   are implemented, not merely while the player owns
   a source item or a class-choice flag.
3. Complete the uninterrupted two-client Base →
   actual Dungeon → actual Base flow with 10 Rogue/
   4 Scout distinct client-controlled kills, late
   side challenges, genuine current-room Cael rescue,
   saved personal loot, and final hub prompt without
   **test-only** stage/item seeding. Published place
   teleport is not testable in these unpublished local
   Studio fixtures; don't publish without approval.
   Add reconnect/wipe/retry, outsider/spectator,
   equipment, party gating and replay acceptance.
4. Author independent encounter layouts, NPC dialogue
   and character/monster silhouettes, meshes and
   animations. Existing physical actors are temporary
   parts and quest monsters use the generic Marauder
   rig/bestiary placeholder. Renaming alone does not
   address all copyright risks; use independently
   designed story beats and gameplay expression.
5. Expand other race/Fighter/Mystic branch source quests,
   other advancement tiers and trainer skill progression
   without importing another game's proprietary text,
   assets, artwork, exact skill catalogues or character
   expression.

## Safeguards

**Fully playable first-transfer advanced classes: 0/18.**
Two separately selected Fighter-based source quests
(Human Rogue and Elven Scout) now have physical
ordered paths that can reach source quest `Ready`,
but no actual level-20 advanced-class identity,
trainer or skill award is live. Keep one gathering
and one crafting profession per character, personal
trade economy, hub-based instanced dungeons,
all-member difficulty gating, closest-before-hit/
highest-threat combat aggro, animal-only skinning,
and separate humanoid/quadruped animation roadmaps.
Do not publish Roblox places, merge into `main`,
modify production DataStores or edit source/docs
using Remote Desktop Commander.
