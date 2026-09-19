# Phase 4 Remaining Release Gates: Local Progress (19 September 2026)

Branch: wip/phase-4-event-secret-policy-v1
Status: **PARTIAL LOCAL GATE EVIDENCE, NOT RELEASE ACCEPTANCE**
Last test-only source commit: 0c2251633b70f92314abc4d0ec9d4fd50bb1dbe4
All tests used locally built unpublished TEMP Studio .rbxl places with
PlaceId=0 and GameId=0. No TEST/PROD game was published and no main merge or
production datastore mutation was performed. Event/Secret rollout flags
remain false in both unmodified dungeon definitions.

## Actual simulated network leave and multiplayer lifecycle

Script: scripts/studio/phase4_multiclient_join_leave_probe.luau
Source: 42881c8. A StudioTestService two-client Base session saw distinct
clients -1/-2 arrive. Client -1 invoked LeaveTest from its actual client
DataModel; the real server observed PlayerRemoving (-1). Client -2 remained
connected, and a newly added client -3 triggered a separate PlayerAdded.
Plugin log: 0.739.0.7390687_20260919T182420Z_Studio_924D5_last.log
Server log: 0.739.0.7390687_20260919T182427Z_Studio_B43BE_last.log
Result: MULTIPLAYER_REAL_LEAVE_JOIN_PASS, REAL_LEAVE_PASS,
REPLACEMENT_JOIN_PASS.

Script: scripts/studio/phase4_dungeon_multiclient_disconnect_fixture.luau
Source: 0c22516. In a new TEMP Dungeon with **fixture-only** Studio group
admission wiring, two simulated clients entered one authoritative active
Dungeon session. The actual departing client called LeaveTest; the Dungeon
runtime PlayerRemoving handler persisted that member Connected=false.
The peer remained connected; session stayed Active; checkpoint and frozen
encounter plan were preserved. No code or gameplay flag was changed in the
repository's production admission path.
Plugin log: 0.739.0.7390687_20260919T183206Z_Studio_3EFDC_last.log
Server log: 0.739.0.7390687_20260919T183213Z_Studio_0F88A_last.log
Result: MULTIPLAYER_SAVED_DISCONNECT_PASS,
SAVED_MEMBER_DISCONNECT_PASS, PEER_SESSION_AND_PLAN_PRESERVED.

**Limit:** AddPlayers creates a different Studio synthetic UserId. This is a
real client departure and separate new-client arrival, *not* the departed
Roblox account returning with its original identity. Genuine same-user
rejoin, teleport handoff and data persistence between independent servers
remain an explicitly separate published TEST-environment gate requiring
the project owner's approval. The TEMP group-admission override does not
prove unchanged production party matching or player-facing group UI.

## TEMP side-room physical walking

Scripts: scripts/studio/phase4_temple_walk_navigation_fixture.luau
and scripts/studio/phase4_mine_walk_navigation_fixture.luau
Sources: 410837e (Temple), 691b212 (Mine).
Both tests let an actual live Humanoid walk connected entrance, Room1,
EventArena bridge, Room2, SecretArena bridge and final boss room via
explicit server-issued MoveTo waypoints. The harness never teleported the
player between encounter triggers. Both entered all five triggers naturally,
recorded optional boss transactions and completed.
Temple log: 0.739.0.7390687_20260919T182616Z_Studio_C709D_last.log
Mine log: 0.739.0.7390687_20260919T183001Z_Studio_E2F7C_last.log
Results: TEMPLE_WALKED_PLAY_MODE_PASS and MINE_WALKED_PLAY_MODE_PASS.

**Limits:** The arenas, bridge meshes and paths were inserted in the TEMP
Studio DataModel, not into authored release layouts. WalkSpeed was set
to 26 for faster automated walking, and enemy HP was set to zero to isolate
navigation and encounter progression. This is no substitute for natural
player navigation through final authored side rooms or unassisted combat.

## Normal live client combat damage

Script: scripts/studio/phase4_temple_normal_combat_probe.luau
Source: 42eb6a3. After using debug defeat for prerequisite Room1 enemies
and staging the player in melee range, an ordinary client LocalScript used
CombatInputActions.request_attack(), which sends the existing attack remote
and exercises server-authoritative damage. The Temple Event boss's actual
Humanoid health fell from 144 to 134 after one normal client attack. The
player's own health was not increased or directly modified; neither was the
Event boss's health.
Log: 0.739.0.7390687_20260919T182904Z_Studio_34C84_last.log
Result: NORMAL_CLIENT_ATTACK_LIVE_PASS,
PARTIAL_COMBAT_PASS_NO_DEBUG_BOSS_DEFEAT.

**Limits:** This verifies live input-to-damage for one normal attack only,
not a full boss kill, attack pattern dodging, death/revive, visibility of
telegraphs, standard player navigation to the boss, reward UI or combat
enjoyment. The player was positioned near the boss by the fixture; earlier
prerequisite enemies were debug-defeated. The complete unassisted fight and
visual/player-facing acceptance still require separate testing.

## Release safety and next action

Neither dungeon has production physical optional rooms. Both
OptionalBossRuntimeEnabled flags remain false. Existing backend focused
suites and prior Base/Dungeon regressions are recorded in
docs/testing/phase4-optional-boss-four-backend-steps-closeout-2026-09-19.md.

Next meaningful verification is a genuine same-account leave/rejoin and
cross-place handoff in an isolated published TEST environment with explicit
user approval; further final authored-room and human-visible combat checks
follow when physical content is ready. Do not describe the TEMP synthetic
fixtures as complete content, production multiplayer, or release acceptance.
