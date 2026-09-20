# TEST Temple placeholder optional entrance gates (20 September 2026)

## Player report
After publishing the previous Secret-backtracking candidate, the player saw "Secret arena sealed for this run. The secret route was not unlocked at..." and noticed that placeholder side-room corridors had no physical barrier before their preceding rooms were cleared. This message describes a run in which the optional Secret boss was not issued at entry, not an eligible Secret boss failing to start. The two visible branches are one Event arena and one Secret arena, not two guaranteed Secret encounters.

## Changes
- The TEST Temple replaceable placeholder's EventBridge and SecretBridge now contain server-controlled visible EntranceGate parts at the main-room end of the side bridges. They begin collidable/closed even before the session is loaded; they are not semantic environment anchors and they do not replace authored terrain.
- DungeonOptionalEntranceGates checks the frozen server encounter plan AND preceding required room state. Eligible Event opens after Room1 clears, eligible Secret opens after Room2 clears. A side boss not selected for this run remains physically sealed. Once open, Secret stays accessible for legitimate backtracking even if the player passes its room, and clearing its boss does not re-lock the path.
- DungeonRuntime synchronizes gates on session initialization/recovery and each encounter clear. Touching a closed gate issues a concise throttled, server-authenticated explanation: "Clear Room 1 first.", "Clear Room 2 first.", "Event unavailable this run.", or "Secret route unavailable this run." The prior ineligible-arena objective banner was shortened. The gate cannot issue secret unlocks, activate events, grant rewards, or bypass encounter progression rules.
- The new gate handling is scoped to TEST Temple placeholder root. Future authored dungeon geometry needs explicitly authored gates.

## Local validation
- All 562 source Luau files and 52 Studio runner files compiled: 614 total, zero failures.
- 13/13 optional-boss focused Studio test suites passed, including 13 new physical-gate assertions. Log: 20260920T105524Z_Studio_23935_last.log.
- Physical unpublished TEST Temple fixture: both side gates initially closed; Room1 opened eligible Event but not Secret; Room2 opened eligible Secret; after passing the optional room the player backtracked into Secret, spawned and cleared that boss, then completed the main route. PASS markers: BOTH_SIDE_GATES_CLOSED_BEFORE_ROOM1, ROOM1_EVENT_OPEN_SECRET_CLOSED, ROOM2_SECRET_GATE_OPEN, BACKTRACK_SECRET_CLEARED_MAIN_ROUTE_INTACT, TEMPLE_FIGHT_PLACEHOLDER_PLAY_PASS. Log: 20260920T105553Z_Studio_1D08C_last.log. Unrelated Roblox ControlsEmulator and ChatScript CoreGui registration errors occurred in this headless test.
- Existing dungeon baseline (20260920T105705Z_Studio_F5B34_last.log), optional skip (20260920T105736Z_Studio_7EB70_last.log), and published-style local test (20260920T105802Z_Studio_5CFB3_last.log) passed. The latter two produced an unrelated Roblox ChatScript CoreGui registration error.
- Exact full placeholder candidate: C:\Users\Remko\Documents\Roblox\DungeonMMO_ReleaseCandidates\TEST_Temple_SecretBacktrack_SideGates_v2_UNPUBLISHED.rbxl; SHA256 18835D6962AC5A0B414F4150F43103744C45FE1C0E74020D781A6FB1CA4520C5; 519397 bytes. This candidate passed restored HUD, TEST content/no-test-script-leak, and published-style local checks with zero Creator errors. Logs: 20260920T105939Z_Studio_CE64C_last.log, 20260920T105953Z_Studio_C8FDC_last.log, and 20260920T110010Z_Studio_04F63_last.log.

## Deployment status and safety
The gated candidate was prepared and passed local tests; an authenticated Studio Publish As attempt on 20 September 2026 at about 14:15 local targeted the existing TEST Dungeon place 117293035754309 / universe 10765241947 (log 20260920T121504Z_Studio_BF4A3_last.log, publishAs target and PublishPlaceTime). However, after the place publish timing marker, Studio logged repeated HTTP 429 Too Many Requests responses for https://apis.roblox.com/publish/v1/Scripts while committing script assets to Version History (205 Commit Failure lines). These may affect the script version-history commit independently of place upload; the log does NOT verify the complete new place/script version is playable. The latest available Player log contains no fresh TEST Dungeon join after the attempted publish. **Treat the live gate version as unverified; do not automatically republish/retry during possible rate-limiting.** Check the current cloud TEST Dungeon Version History, join a genuinely fresh TEST Dungeon server, verify the new visible gates and prerequisite behaviour, and capture F9 server errors before declaring the new candidate live. The previous FIVE-script hotfix project is obsolete for this revision: the runtime now also needs the new DungeonOptionalEntranceGates module AND revised DungeonPlaceholderPhysicalContent builder. Do not run the old hotfix launcher or publish its scripts-only rbxl. For full placeholder release, back up the current cloud TEST Temple and note its Roblox version history before overwriting the existing TEST Dungeon place 117293035754309 in universe 10765241947. Do not publish over Lobby 134132328219009 or PROD, and do not reset player profiles or DataStores. Source-only Git checkpoints are not cloud place backups.

## 20 September 2026 — gate-recovery regression follow-up

The current integration branch already includes the implemented TEST Temple
optional entrance barriers at f6d6401 and the v1.47 roadmap closeout at
1083c01. A fresh local TEST placeholder Rojo build and separate Dungeon
edit-mode test build succeeded. The focused Studio runner passed 13/13 suites;
DungeonOptionalEntranceGatesTest passed 16 assertions, including three new
recovery/resynchronization checks. Studio log:
20260920T151636Z_Studio_1BE9F_last.log. Studio emitted unrelated shutdown
plugin errors after the runner PASS; the gameplay tests themselves passed.
The earlier full physical-route and backtracking tests remain the latest
physical gameplay evidence; this follow-up did not rerun those play fixtures.

The cloud version is still unverified after the documented 429 rate-limit
publish attempt. No Roblox publish or DataStore mutation was performed during
this follow-up. Confirm the existing TEST Dungeon's current version and back
it up before any future authenticated publish; leave Lobby and PROD untouched.
