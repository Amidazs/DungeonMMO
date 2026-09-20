# Phase 4 — Depth 1–4 progression integration checkpoint

Date: 20 September 2026.
Integration branch: `wip/phase-4-test-hud-integration-v1`.

## Scope and implementation

The existing Temple (`TestDungeon`) and Abandoned Mine
(`AbandonedMine`) four-depth ladders were reused. No runtime difficulty
definitions, encounter executors, checkpoint service, completion logic,
profile schema, content registration or model/mesh assets were recreated.

Created one new maintainable test:
`src/ServerScriptService/Dungeon/Tests/DungeonDepthLadderIntegrationTest.server.luau`
and its focused Studio runner:
`scripts/studio/phase4_depth_ladder_focused_tests.luau`.
All authored changes were committed through GitHub first, fast-forward
pulled into the existing clean Windows integration worktree, then tested
in an unpublished local Roblox Studio/Rojo Dungeon build.

## Focused difficulty and recovery tests — PASS

The final new integration suite passed **454 assertions** across both
dungeons. Its five-suite focused Studio runner passed. It verifies:

- Depth1/2/3/4 required encounter counts of 3/4/5/6 per dungeon.
- Depth4 Room2, Room4 and Room5 minibosses retain the exact boss IDs
  from Depth1, Depth2 and Depth3 respectively; Room6 keeps the distinct
  Depth4 final boss identity.
- Logical Depth2/3/4 unlocks happen in order; attempting a higher clear
  without the previous clear fails.
- The actual DungeonDifficultyProgressionService and CompletionService
  persist each successful depth clear and save the player's profile.
  The next depth is unlocked once; a repeat completion cannot grant
  its reward a second time.
- Two dungeons' progression stays independent in one persisted profile
  across service recreation between each simulated depth.
- The existing DungeonEncounterRuntimeController enforces encounter
  order, refuses repeated Active/Cleared encounter starts, and restores
  interrupted Depth4 minibosses as Pending with their checkpoint intact.
- A fixture-injected readiness provider is used ONLY to exercise
  logically unlocked higher-depth progression. The *actual*
  DungeonRuntimeContentReadiness and release flags still reject entry to
  Depth2–4 in ordinary gameplay. No content release switches were enabled.

Final, post-refactor Studio log:
`0.739.0.7390687_20260920T171142Z_Studio_8FA20_last.log`.
Markers: `[Depth Ladder Integration Tests] PASS: 454 assertions.`
and `[Depth Ladder Studio Focus] PASS: 5 suites.`

## Broader regression and builds — PASS

The existing backend gameplay matrix passed 30/30 selected suites
(log `0.739.0.7390687_20260920T170828Z_Studio_5EC30_last.log`).
All four local Rojo compositions built: Dungeon, Base, published-style
Dungeon, and published-style Base. These builds were NOT published.
The Base Play-mode regression passed
`[Phase 4 Base Live] VERIFIED_PLAY_MODE_PASS`
(log `0.739.0.7390687_20260920T171022Z_Studio_7C51D_last.log`).

## Physical-route evidence and limits

One fresh Temple Depth2 Play-mode run followed real placeholder triggers,
spawned each room's pack/boss, and cleared its 4-room route with assisted
enemy defeats:
`0.739.0.7390687_20260920T170700Z_Studio_397A3_last.log`.
The attempt to run all six higher-depth cases sequentially inside a
single Studio RunScript invocation completed only Temple Depth2; Studio
stopped after the first Play-mode session. The unsupported matrix runner
was removed from GitHub. It is **not** counted as six new passes.

Individual Temple and Mine Depth2/3/4 physical-route fixtures previously
passed on 19 September; see
`docs/testing/phase4-placeholder-playable-layouts-closeout-2026-09-19.md`
for the six specific original Studio logs. No production encounter or
physical-layout code changed during this follow-up, but these historical
runs are not misrepresented as fresh independent Play-mode repeats.

The service-level ladder fixture uses disposable in-memory sessions,
profile storage and synthetic unlock readiness. It is not proof that
unreleased high-depth content can be entered in a published server.
Optional Event/Secret encounters remain distinct from the ordinary
higher-depth sequences. Manual unassisted combat for every higher-depth
room, real player cross-server reconnect, release acceptance and authored
visuals remain separate tasks. The user confirmed their earlier manual
solo optional-boss playtest passed; it was not repeated here.

## Source and data safety

No forced Git operations, main/backend/HUD branch reset, Roblox cloud
publish, player DataStore change, existing authored map overwrite, or
model/mesh work. The canonical long-form roadmap DOCX remains v1.47;
this checkpoint is recorded in its Markdown index and handoff.
