# v1.54 weekly world boss — isolated travel and return integration

**Date:** 21 September 2026
**Branch:** `wip/phase-4-test-hud-integration-v1`
**Source and test commit:** `50b4b72e8aa3effd7b2b6ef50b38ad20dedee8ae`
**Status:** Default-off source integration and unpublished Studio contract
acceptance complete. A genuine published Base → reserved world-boss
server → Base network journey has **not** been executed.

## Implemented backend

- `WorldBossBaseRuntime` creates an independent boss-entry
  ProximityPrompt on the **existing** `Base.DungeonBoard` anchor,
  never on the ordinary Temple dungeon portal. It exists only when
  `ServerScriptService.DungeonMMOWeeklyWorldBossEnabled` is true.
  Its server reads the current enable flag and explicit UTC
  start/end at each activation, so disabling the event closes an
  already-attached gateway. Entry checks proximity, loaded character
  identity, original party leader and every other member's readiness.
  An unpublished Studio environment refuses live teleport.
- `TeleportCoordinator.start_weekly_world_boss` checks a trusted
  event window and approved party before reserving the **configured
  dedicated boss place**. It reuses the existing session map,
  profile saves, lease handoff nonces, reserved server access code,
  retry handling and transfer adapter. The weekly event snapshot is
  issued and persisted **before** handoff. TeleportData carries
  routing IDs and an event discriminator, never gold or eligibility.
  `rejoin_session` refuses a different destination place.
- `WeeklyWorldBossArrivalRules` checks the **server-fetched**
  stored world-boss snapshot, authenticated member, original
  destination place and matching routing fields. The dedicated
  destination additionally claims the existing stored profile
  handoff nonce before loading the character. Ordinary
  `DungeonAdmissionRules` explicitly rejects world-boss sessions.
- New `world-boss.project.json` and
  `published-world-boss.project.json` build a **separate**
  world-boss-only place, excluding the normal Dungeon runtime.
  `WorldBossRuntime.server.luau` is opt-in through its independent
  server enable flag, requires a reserved server outside Studio and
  an authored `WorldBossArenaSpawn` anchor, and fails closed when
  those are unavailable. Once admitted, it restores the frozen
  session, creates only the instance-matching guardian prototype,
  persists a verified boss death and retains the contribution and
  weekly reward gates. It reuses the existing Base return handoff.
- A defeated member's return is persisted separately from the
  rest of the party. Base accepts only a boss-tagged return
  associated with that saved state, routes a returning member to
  Base rather than back to the arena, and removes **that member's**
  old dungeon session index only after their Base profile loads.
  Other members retain their recoverable boss session.

## Unpublished local verification

Output directory:
`%TEMP%\DungeonMMO_worldboss_travel_acceptance\`.

| Test | Observed result |
| --- | --- |
| Six Rojo project compositions | all built successfully |
| Base-world-boss return contract | `base_return.log`: 18 assertions PASS |
| Base reserved-route and arrival contract | `base_travel.log`: 18 assertions PASS |
| Dungeon reserved-route and arrival contract | `dungeon_travel.log`: 18 assertions PASS |
| Ordinary dungeon rejects boss sessions | `ordinary_dungeon_guard.log`: 10 assertions PASS |
| Separate disabled boss-place composition and factory | `dedicated_place.log`: 5 assertions PASS |
| Base profession focused suites | `base_professions.log`: 14/14 PASS |
| Dungeon gameplay regression | `dungeon_backend.log`: 30/30 PASS |
| Durable boss session bridge Base/Dungeon | `base_session.log` and `dungeon_session.log`: 30 assertions each PASS |
| Weekly calendar/reward and guardian factory | `weekly_factory.log`: 40 + 8 assertions PASS |
| Real Base Play-mode material-backed crafting after portal wiring | `base_live_crafting_regression.log`: `MATERIAL_CHAIN_PASS`, `RAPID_DUPLICATE_PASS`, `VERIFIED_PLAY_MODE_PASS` |

A separate unpublished dedicated-place Play run under
`%TEMP%\DungeonMMO_worldboss_travel_v3\worldboss_default_off_play.log`
printed `VERIFIED_PLAY_MODE_PASS` and confirmed that no guardian
or return prompt appeared without an explicit enable flag.
That run also emitted a Roblox Studio client ChatScript
`SetCore CoreGuiChatConnections` warning; it was unrelated to
world-boss scripts and did not fail the Play fixture.

A previous Base travel test under the v2 diagnostics directory
printed PASS but Roblox Studio exited with code `-1073741819`.
The **later final Base and Dungeon travel tests** both passed with
Studio exit code 0. The earlier anomalous run is not the acceptance
receipt.

## Important remaining work

This is **not** a completed playable world-boss release.
Neither the Base nor boss place was published, and no actual Roblox
reserved-server teleport or cross-server DataStore/MemoryStore
handoff was exercised. The dedicated place has no authored arena
anchor or complete world-boss combat/AI pipeline yet. The reusable
captain factory is a temporary guardian rig, not a finished boss.
Its contribution gate intentionally prevents payout if genuine
server-recorded damage/support is unavailable; simply entering or
allowing the placeholder to die must not earn weekly gold.

Next backend acceptance: integrate the existing combat/damage
pipeline into the isolated destination, capture eligible real
contributors, implement party wipe and disconnected-member reward
retry, then run a controlled **published TEST** Base → reserved
boss → return journey with actual same-account reconnection and
cloud persistence. Configure published place IDs and event times
only after those independent dependencies are ready and approved.
The current weekly reward amount is provisional.

All source, fixtures, roadmap and handoff edits were made in GitHub.
Remote Desktop was used only to clean fast-forward pull, run six
local Rojo builds, execute unpublished Studio tests and inspect
diagnostics. No production DataStore changes, Roblox publishing,
force-push or merge to `main` occurred.
