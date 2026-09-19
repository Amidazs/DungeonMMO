# Optional Boss Step 1 Validation

Date: 19 September 2026
Result: BACKEND REGRESSION VERIFIED; PHYSICAL FEATURE NOT RELEASED
Source: cb29a7c54637e371e1041ab68009c4951b579d00
Branch: wip/phase-4-event-secret-policy-v1

## Source and isolation

Validated a clean feature worktree at cb29a7c. Fresh Rojo builds were opened
as local TEMP places with PlaceId=0 and GameId=0. Edit-mode inspection confirmed
the finite-number issuer guard and its new negative tests in each place.
No source, rollout setting, profile schema, published place or UI/art worktree
was modified. Both Studio play sessions were stopped after capture.

GitHub main independently resolved to a3c2625cfc53dbb1c2bb8d6ce17f5f3749809fa9.
GitHub optional-boss feature independently resolved to cb29a7c54637e371e1041ab68009c4951b579d00.
This supersedes the v1.44 snapshot's uncommitted/unpushed qualification.

## Fresh static and build evidence

- luau-compile --null: 539 Lua/Luau source files, zero failures.
- Compiler: previously installed Luau 0.738 executable under TEMP.
- default.project.json: PASS.
- base.project.json: PASS.
- published-dungeon.project.json: PASS.
- published-base.project.json: PASS.
- Worktree and staged git diff --check: PASS before documentation update.
- Build directory: C:/Users/Remko/AppData/Local/Temp/DungeonMMO_Step1_20260919_165657.

## Fresh Dungeon Studio evidence

Server LogService capture contained 248 PASS markers and zero MessageError entries.
The full captured console is evidence/2026-09-19-optional-boss-cb29a7c/dungeon-console.txt.

| Suite | Assertions |
| --- | ---: |
| Optional Boss Run State | 34 |
| Dungeon Instance Director | 23 |
| Optional Boss Policy | 49 |
| Optional Boss Flow | 9 |
| Optional Boss Factories | 24 |
| Optional Boss Release Lock | 14 |
| Dungeon Runtime Content Readiness | 70 |
| Dungeon Encounter Bindings | 34 |
| Dungeon Encounter Runtime Controller | 22 |
| Dungeon Encounter Executors | 21 |
| Depth2 / Depth3 / Depth4 content | 32 / 36 / 38 |
| Depth2 / Depth3 / Depth4 boss factories | 8 / 8 / 10 |
| Training Dummy / Combat Target Rules | 9 / 9 |

All listed suites PASS. The live local player was admitted to the synthetic
Temple Depth1 session. The accepted death/revive, reward, recovery, contribution,
equipment, progression, profession and economy tests also emitted PASS.

## Fresh Base Studio evidence

Server LogService capture contained 132 PASS markers and zero MessageError entries.
Client LogService independently contained zero MessageError entries.
The full captured console is evidence/2026-09-19-optional-boss-cb29a7c/base-console.txt.

Issuer 34, readiness 70, party difficulty 22, party difficulty entry 32,
Teleport Coordinator 19 and difficulty definitions 114 assertions PASS.
Party Service, Party Entry Coordinator and Party Remote Contract PASS.
Base profile lifecycle became ready and loaded the local player's Slot1.

Both compositions passed the Phase 3 stress harness:
profiles=250 market=1000 replay=1000 guild=250 sessions=100 race_roundtrips=100.

## Diagnostic qualification

The audit-sink-unavailable warning is deliberately raised by
EconomyAuditIntegrationTest's failure fixture; its 27 assertions PASS.
Dungeon reports that AnimSaves is absent and source-controlled fallback
animations are used. These warnings are not new runtime failures.

This closes the outstanding Studio evidence gap for the extended director and
latest issuer tests. It does not prove optional arenas, higher-depth physical
traversal, published cross-place group entry, event scheduling or secret discovery
gameplay. Those remain distinct content/integration gates.

## Preserved release boundary and next step

Both dungeon optional-boss rollout flags remain false; run-owned enablement
remains required. Higher-depth physical layouts remain unregistered.
No feature acceptance, merge or publish is implied by these regression results.

Report step 1 complete to the user. Next ordered work is a bounded Event/Secret
gameplay-rules design and test-first implementation using existing services.
No new event timetable, discovery condition or reward balance is locked here.
