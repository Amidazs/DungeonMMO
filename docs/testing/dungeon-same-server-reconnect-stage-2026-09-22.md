# Same-server dungeon reconnect: GitHub implementation pending Studio validation

Date: 22 September 2026
Feature branch: `wip/phase-4-test-hud-integration-v1`
Latest implementation/test source: `7d684f583020df64e2591a00acef14c90f35ecb1`

## Implemented in GitHub

- Production `DungeonAdmissionRules.same_server_reconnect` permits
  the **existing active Dungeon server** to admit a previously connected
  Roblox UserId whose member is now recorded as disconnected and not
  abandoned. The server must already be bound to that exact SessionId.
  First-time admission, a connected duplicate, a different server,
  missing departure history and an expired/failed/complete run are
  not eligible for the nonce-free reconnect path.
- The existing initial Base -> Dungeon handoff still requires its
  single-use nonce. Only the above already-bound same-server route
  can proceed without a fresh handoff nonce.
- Existing `DungeonAdmissionRules.validate` still checks session,
  dungeon and authenticated member identity and now also rejects
  an explicitly abandoned member.
- The returning player's normal `ProfileService:load` still claims
  the server-owned writer lease: passing the reconnect gate is **not**
  a profile lease bypass. The server subsequently calls
  `mark_connected` and preserves the session, consumed free revives,
  member mode, room checkpoint and previously issued reward receipts.
- `DungeonDeathService:send_member_state` replays the authoritative
  member's revive status after admission. `DungeonUi` also requests
  its own snapshot after attaching RemoteEvent listeners, protecting
  against an early admission push being missed by a fresh client.
  Neither request can grant a revive; the server refuses absent
  or disconnected members.

## GitHub regression fixtures

`src/ServerScriptService/Dungeon/Tests/DungeonReconnectAdmissionTest.server.luau`
exercises in-memory **production** DungeonSessionService,
DungeonAdmissionRules, ProfileLeaseService,
DungeonDeathService and DungeonRecoveryRules. It checks first-admit
nonce enforcement, rejection of wrong run/dungeon/server/stranger,
abandoned/terminal/duplicate members, preserved spectator mode and
spent free revive, checkpoint/party continuity and exclusive writer
lease acquisition on a same-UserId simulated return.

`scripts/studio/dungeon_reconnect_admission_tests.luau`
runs that fixture in an **unpublished** Studio place.
`DungeonDeathServiceTest.server.luau` separately checks that
only a connected member gets their current revive UI state.

## Verification state — IMPORTANT

At the attempted local pull/build/test on 22 September,
Remote Desktop Commander reported **no online devices**.
Consequently **the new code has NOT been Rojo-built or run in Studio**
at this source head. GitHub file contents and required fixture
anchors were read and verified; GitHub reported no CI status
checks for the latest source commit. This is source inspection,
not a Luau parser or gameplay test result.

Previous v1.59 six-build and 30/30 backend acceptance
belongs to the **older** gameplay head, not to this change.

## Outstanding acceptance and routing limitations

- Run all six Rojo compositions; the ordinary Dungeon backend
  matrix and the new focused reconnect runner at the same source head.
- In unpublished Studio, test the real client revive UI and normal
  dungeon admission with a temporarily simulated same-user return.
  Do **not** claim that simulating departure is a genuine Roblox
  network reconnect.
- A genuine same-account disconnect and rejoin to the **same
  published reserved server**, including `GetJoinData().TeleportData`
  availability and actual profile lease release/reacquisition,
  cannot be established by a disposable local Studio fixture.
  The current entry still requires valid platform routing data.
  If a direct reconnect lacks TeleportData, the server rejects
  admission rather than guessing a run from a client-provided ID.
- Confirm a reconnecting spectator cannot participate in combat
  despite Roblox creating a new character model; preserve the
  paid-revive and reward eligibility policy.
- Verify concurrent party completion, late return, duplicate
  joins and cross-server recovery using published TEST instances
  only after separate user approval.
- No published place, `main` merge, force-push or production
  DataStore/purchase operation was performed.

All changes to scripts and documentation were made directly
through GitHub. The unavailable desktop connection was not
used to edit repository files.
